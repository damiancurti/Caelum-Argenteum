#!/usr/bin/env python3
"""Audita el parche incremental 4.31.0h contra la base 4.31.0g."""

from __future__ import annotations

import argparse
import hashlib
import math
import re
import struct
import zipfile
from pathlib import Path


EXPECTED_RUNTIME_CHANGES = {
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/equipment/CaelumSpecialItems.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/ui/CaelumDisplayNames.zs",
    "maps/MAP01.wad",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative_files(root: Path) -> dict[str, Path]:
    return {
        path.relative_to(root).as_posix(): path
        for path in root.rglob("*")
        if path.is_file()
    }


def zip_digests(path: Path) -> dict[str, str]:
    with zipfile.ZipFile(path) as archive:
        return {
            info.filename: hashlib.sha256(archive.read(info.filename)).hexdigest()
            for info in archive.infolist()
            if not info.is_dir()
        }


def read_wad_lumps(path: Path) -> list[tuple[bytes, bytes]]:
    data = path.read_bytes()
    magic, count, directory = struct.unpack_from("<4sII", data, 0)
    require(magic in (b"IWAD", b"PWAD"), f"WAD inválido: {path}")
    lumps: list[tuple[bytes, bytes]] = []
    for index in range(count):
        offset, size, name = struct.unpack_from(
            "<II8s", data, directory + index * 16
        )
        lumps.append((name, data[offset : offset + size]))
    return lumps


def textmap(path: Path) -> str:
    for name, data in read_wad_lumps(path):
        if name.rstrip(b"\0") == b"TEXTMAP":
            return data.decode("utf-8")
    raise AssertionError(f"Falta TEXTMAP en {path}")


def strip_potable_markers(text: str) -> str:
    return text.replace("    user_ca_potable_water = 1;\n", "")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--base-root", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path, required=True)
    parser.add_argument("--candidate-pk3", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    base_root = args.base_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()
    for path in (runtime, base_root):
        require(path.is_dir(), f"No existe el directorio: {path}")
    for path in (base_pk3, candidate_pk3):
        require(path.is_file(), f"No existe el paquete: {path}")

    constants = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text(
        encoding="utf-8"
    )
    items = (runtime / "caelum/equipment/CaelumSpecialItems.zs").read_text(
        encoding="utf-8"
    )
    names = (runtime / "caelum/ui/CaelumDisplayNames.zs").read_text(
        encoding="utf-8"
    )
    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")

    require(
        "POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND = 0.01" in constants,
        "La hidratación potable no es 1% por segundo",
    )
    require("bool IsSubmergedInPotableWater()" in player, "Falta detector potable")
    require("WaterLevel >= 3" in player, "La hidratación no exige inmersión total")
    require(
        "CurSector.GetUDMFInt('user_ca_potable_water') != 0" in player,
        "La hidratación no consulta la marca UDMF potable",
    )
    require(
        "CurrentThirst = Min(" in player
        and "POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND" in player,
        "Falta aplicar la recuperación de Sed",
    )

    combat_function = re.search(
        r"(?ms)^    void UpdateAdrenalineDecay\(\)\n    \{.*?^    \}",
        player,
    )
    require(combat_function is not None, "Falta UpdateAdrenalineDecay")
    combat_text = combat_function.group(0)
    require(
        "!AdrenalineResourceInitialized || CurrentAdrenaline <= 0.0"
        not in combat_text,
        "El bloqueo antiguo del contador sigue presente",
    )
    require(
        combat_text.index("CombatTimeRemaining > 0.0")
        < combat_text.index("CurrentAdrenaline <= 0.0"),
        "La Adrenalina todavía puede detener el contador",
    )
    timeout = 30.0
    for _ in range(30 * 35 - 1):
        timeout = max(0.0, timeout - 1.0 / 35.0)
    require(timeout > 0.0, "El combate termina antes de 30 segundos")
    timeout = max(0.0, timeout - 1.0 / 35.0)
    require(math.isclose(timeout, 0.0, abs_tol=1e-9), "El combate no termina a 30 s")

    thirst = 80.0
    for _ in range(35):
        thirst = min(100.0, thirst + 100.0 * 0.01 / 35.0)
    require(math.isclose(thirst, 81.0, abs_tol=1e-9), "Hidratación inexacta")

    require("override String PickupMessage()" in items, "Falta mensaje dinámico")
    require(
        "CaelumDisplayNames.GetSpecialItemKey(" in items
        and re.search(
            r"(?s)CA_PICKUP_MATERIAL_DETAILED.*?materialName,\s*Amount",
            items,
        ) is not None,
        "El mensaje no combina nombre y cantidad",
    )
    require(
        "static clearscope String GetSpecialItemKey" in names,
        "La tabla de nombres no está disponible de forma segura en gameplay",
    )
    require(
        language.count("CA_PICKUP_MATERIAL_DETAILED") == 2,
        "Deben existir mensajes detallados en inglés y español",
    )
    require(
        'CA_PICKUP_MATERIAL_DETAILED = "Recogiste %s x%d.";' in language,
        "Texto español de pickup inesperado",
    )

    base_map = textmap(base_root / "maps/MAP01.wad")
    candidate_map = textmap(runtime / "maps/MAP01.wad")
    require(
        candidate_map.count("user_ca_potable_water = 1;") == 17,
        "La piscina debe marcar sus 17 sectores objetivo",
    )
    require(
        strip_potable_markers(candidate_map) == base_map,
        "MAP01 cambió fuera de las marcas potables",
    )
    for block_name in ("vertex", "linedef", "sidedef", "sector", "thing"):
        pattern = rf"(?m)^{block_name}\s*$"
        require(
            len(re.findall(pattern, candidate_map))
            == len(re.findall(pattern, base_map)),
            f"Cambió la cantidad de {block_name} en MAP01",
        )

    mapinfo = (runtime / "MAPINFO").read_text(encoding="utf-8")
    require("18509 = CaelumVeinTin" in mapinfo, "Falta la veta de estaño 1")
    require("18510 = CaelumVeinTin2" in mapinfo, "Falta la veta de estaño 2")
    require("18511 = CaelumVeinTin3" in mapinfo, "Falta la veta de estaño 3")

    runtime_files = relative_files(runtime)
    base_files = relative_files(base_root)
    require(runtime_files.keys() == base_files.keys(), "Cambió el catálogo runtime")
    changed_runtime = {
        name
        for name in runtime_files
        if digest(runtime_files[name]) != digest(base_files[name])
    }
    require(
        changed_runtime == EXPECTED_RUNTIME_CHANGES,
        f"Cambios runtime inesperados: {sorted(changed_runtime ^ EXPECTED_RUNTIME_CHANGES)}",
    )

    base_zip = zip_digests(base_pk3)
    candidate_zip = zip_digests(candidate_pk3)
    require(base_zip.keys() == candidate_zip.keys(), "Cambió el catálogo del PK3")
    changed_zip = {name for name in base_zip if base_zip[name] != candidate_zip[name]}
    require(changed_zip == EXPECTED_RUNTIME_CHANGES, "Cambios inesperados en PK3")
    require(len(candidate_zip) == 3952, "El PK3 debe conservar sus 3952 archivos")
    with zipfile.ZipFile(candidate_pk3) as archive:
        require(len(archive.infolist()) == 4062, "El PK3 debe conservar 4062 entradas")
        require(archive.testzip() is None, "El PK3 está corrupto")

    print("4.31.0h audit passed")
    print("runtime changes: 6")
    print("potable MAP01 sectors: 17; hydration: 1%/s")
    print("combat timeout: 1050 tics independent of adrenaline")
    print("material pickup: localized name + exact stack amount")
    print("PK3 entries: 4062; files: 3952")


if __name__ == "__main__":
    main()
