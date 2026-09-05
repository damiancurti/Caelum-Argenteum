#!/usr/bin/env python3
"""Construye y audita el parche incremental 4.31.0h desde 4.31.0g."""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


RUNTIME_CHANGES = (
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/equipment/CaelumSpecialItems.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/ui/CaelumDisplayNames.zs",
    "maps/MAP01.wad",
)

PROJECT_CHANGES = (
    "APLICAR_4_31_0h.txt",
    "PRUEBAS_4_31_0h.txt",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "docs/V4_31_WORLD_RESOURCES_AND_STASHES.md",
    "tools/audit_4_31_0h.py",
    "tools/build_patch_4_31_0h.py",
)

EMBEDDED_PK3 = "build/caelum_argenteum_dev.pk3"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    require(text.count(old) == 1, f"Reemplazo ambiguo o ausente: {label}")
    return text.replace(old, new, 1)


def patch_constants(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        """    const SURVIVAL_LOW_PERFORMANCE_MULTIPLIER = 0.75;
    const SURVIVAL_CRITICAL_PERFORMANCE_MULTIPLIER = 0.50;

    // Natural health recovery fills the current maximum in one real hour.""",
        """    const SURVIVAL_LOW_PERFORMANCE_MULTIPLIER = 0.75;
    const SURVIVAL_CRITICAL_PERFORMANCE_MULTIPLIER = 0.50;

    // El agua marcada como potable reemplaza la pérdida pasiva de Sed por
    // una recuperación neta de un punto porcentual por segundo sumergido.
    const POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND = 0.01;

    // Natural health recovery fills the current maximum in one real hour.""",
        "constante de hidratación potable",
    )
    path.write_text(text, encoding="utf-8")


def patch_player(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        """    // Wait until combat ends, then remove ten points per second. TICRATE keeps
    // the result independent of rendering speed and pauses it with the game.
    void UpdateAdrenalineDecay()
    {
        if (!AdrenalineResourceInitialized || CurrentAdrenaline <= 0.0)
        {
            CombatTimeRemaining = Max(0.0, CombatTimeRemaining);
            return;
        }

        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
            return;
        }

        CurrentAdrenaline = Max(
            0.0,
            CurrentAdrenaline
                - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
        );
    }""",
        """    // El tiempo de combate siempre avanza, aun cuando una acción no haya
    // otorgado Adrenalina o ésta ya sea cero. Al terminar los treinta segundos,
    // sólo la reserva positiva entra en su decadencia normal de diez por segundo.
    void UpdateAdrenalineDecay()
    {
        if (!AdrenalineResourceInitialized)
        {
            CombatTimeRemaining = Max(0.0, CombatTimeRemaining);
            return;
        }

        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
            return;
        }

        if (CurrentAdrenaline <= 0.0) { return; }
        CurrentAdrenaline = Max(
            0.0,
            CurrentAdrenaline
                - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
        );
    }""",
        "temporizador de combate independiente",
    )
    text = replace_once(
        text,
        """    // Apply base depletion time and the appropriate Type 3 loss multiplier.
    void UpdateSurvivalResources()
    {
        if (!SurvivalResourcesInitialized || DerivedStats == null)
        {
            return;
        }

        CurrentHunger = Max(0.0, CurrentHunger
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentThirst = Max(0.0, CurrentThirst
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.THIRST_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        CurrentSleep = Max(0.0, CurrentSleep
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.SleepLossMultiplier / TICRATE);
        UpdateSurvivalStates();
    }""",
        """    // Sólo un volumen marcado por el mapa puede hidratar. WaterLevel 3 exige
    // que la cabeza también esté bajo el agua y evita que futuros mares o
    // líquidos peligrosos hereden esta propiedad por accidente.
    bool IsSubmergedInPotableWater()
    {
        return WaterLevel >= 3
            && CurSector != null
            && CurSector.GetUDMFInt('user_ca_potable_water') != 0;
    }

    // Apply base depletion time and the appropriate Type 3 loss multiplier.
    void UpdateSurvivalResources()
    {
        if (!SurvivalResourcesInitialized || DerivedStats == null)
        {
            return;
        }

        CurrentHunger = Max(0.0, CurrentHunger
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.HUNGER_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        if (IsSubmergedInPotableWater())
        {
            CurrentThirst = Min(
                CaelumConstants.SURVIVAL_MAXIMUM,
                CurrentThirst
                    + CaelumConstants.SURVIVAL_MAXIMUM
                    * CaelumConstants.POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND
                    / TICRATE
            );
        }
        else
        {
            CurrentThirst = Max(0.0, CurrentThirst
                - CaelumConstants.SURVIVAL_MAXIMUM
                / (CaelumConstants.THIRST_EMPTY_GAME_HOURS
                    * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
                * DerivedStats.HungerThirstLossMultiplier / TICRATE);
        }
        CurrentSleep = Max(0.0, CurrentSleep
            - CaelumConstants.SURVIVAL_MAXIMUM
            / (CaelumConstants.SLEEP_EMPTY_GAME_HOURS
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR)
            * DerivedStats.SleepLossMultiplier / TICRATE);
        UpdateSurvivalStates();
    }""",
        "hidratación de supervivencia",
    )
    path.write_text(text, encoding="utf-8")


def patch_display_names(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        "    static ui String GetSpecialItemKey(int specialCategory, int specialType)",
        "    static clearscope String GetSpecialItemKey(int specialCategory, int specialType)",
        "alcance de nombres especiales",
    )
    path.write_text(text, encoding="utf-8")


def patch_special_items(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        """    override int GetSpecialTier()
    {
        return CaelumMaterialRules.ResolveTier(GetSpecialType(), args[1]);
    }

    override void PostBeginPlay()""",
        """    override int GetSpecialTier()
    {
        return CaelumMaterialRules.ResolveTier(GetSpecialType(), args[1]);
    }

    // GZDoom consulta este método en el actor original después de completar
    // TryPickup, por lo que Amount conserva la cantidad exacta de la pila.
    override String PickupMessage()
    {
        String materialName = StringTable.Localize(
            CaelumDisplayNames.GetSpecialItemKey(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                GetSpecialType()
            ),
            false
        );
        return String.Format(
            StringTable.Localize("CA_PICKUP_MATERIAL_DETAILED", false),
            materialName,
            Amount
        );
    }

    override void PostBeginPlay()""",
        "mensaje dinámico de materiales",
    )
    path.write_text(text, encoding="utf-8")


def patch_language(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        'CA_PICKUP_MATERIAL_GENERIC = "You found crafting materials.";',
        'CA_PICKUP_MATERIAL_GENERIC = "You found crafting materials.";\n'
        'CA_PICKUP_MATERIAL_DETAILED = "Picked up %s x%d.";',
        "pickup detallado inglés",
    )
    text = replace_once(
        text,
        'CA_PICKUP_MATERIAL_GENERIC = "Encontraste materiales de fabricación.";',
        'CA_PICKUP_MATERIAL_GENERIC = "Encontraste materiales de fabricación.";\n'
        'CA_PICKUP_MATERIAL_DETAILED = "Recogiste %s x%d.";',
        "pickup detallado español",
    )
    path.write_text(text, encoding="utf-8")


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    magic, count, directory = struct.unpack_from("<4sII", data, 0)
    require(magic in (b"IWAD", b"PWAD"), f"WAD inválido: {path}")
    lumps: list[tuple[bytes, bytes]] = []
    for index in range(count):
        offset, size, name = struct.unpack_from(
            "<II8s", data, directory + index * 16
        )
        lumps.append((name, data[offset : offset + size]))
    return magic, lumps


def write_wad(path: Path, magic: bytes, lumps: list[tuple[bytes, bytes]]) -> None:
    body = bytearray()
    directory_entries: list[tuple[int, int, bytes]] = []
    for name, data in lumps:
        offset = 12 + len(body)
        directory_entries.append((offset, len(data), name))
        body.extend(data)
    directory_offset = 12 + len(body)
    result = bytearray(struct.pack("<4sII", magic, len(lumps), directory_offset))
    result.extend(body)
    for offset, size, name in directory_entries:
        result.extend(struct.pack("<II8s", offset, size, name))
    path.write_bytes(result)


def patch_map01(path: Path) -> None:
    magic, lumps = read_wad(path)
    patched: list[tuple[bytes, bytes]] = []
    changed = 0
    for name, data in lumps:
        if name.rstrip(b"\0") != b"TEXTMAP":
            patched.append((name, data))
            continue
        text = data.decode("utf-8")
        sector_pattern = re.compile(r"(?ms)^sector\s*\{.*?^\}")

        def mark_sector(match: re.Match[str]) -> str:
            nonlocal changed
            block = match.group(0)
            if not re.search(r"(?m)^\s*id\s*=\s*940\s*;", block):
                return block
            require(
                "user_ca_potable_water" not in block,
                "La marca potable ya existe en un sector de piscina",
            )
            changed += 1
            return block[:-1] + "    user_ca_potable_water = 1;\n}"

        text = sector_pattern.sub(mark_sector, text)
        patched.append((name, text.encode("utf-8")))
    require(changed == 17, f"Se esperaban 17 sectores de piscina y hubo {changed}")
    write_wad(path, magic, patched)


def copy_zip_info(info: zipfile.ZipInfo) -> zipfile.ZipInfo:
    copied = zipfile.ZipInfo(info.filename, info.date_time)
    copied.comment = info.comment
    copied.extra = info.extra
    copied.create_system = info.create_system
    copied.create_version = info.create_version
    copied.extract_version = info.extract_version
    copied.external_attr = info.external_attr
    copied.internal_attr = info.internal_attr
    copied.flag_bits = info.flag_bits & ~0x08
    copied.compress_type = info.compress_type
    return copied


def rebuild_pk3(base_pk3: Path, runtime: Path, output: Path) -> None:
    substitutions = set(RUNTIME_CHANGES)
    with zipfile.ZipFile(base_pk3, "r") as source, zipfile.ZipFile(
        output, "w", allowZip64=True
    ) as target:
        for info in source.infolist():
            data = (
                (runtime / info.filename).read_bytes()
                if info.filename in substitutions
                else source.read(info.filename)
            )
            target.writestr(copy_zip_info(info), data, compresslevel=9)


def add_file(
    archive: zipfile.ZipFile,
    source: Path,
    destination: str,
    stored: bool = False,
) -> None:
    info = zipfile.ZipInfo(destination, (2026, 9, 5, 12, 0, 0))
    info.create_system = 3
    info.external_attr = (0o100644 & 0xFFFF) << 16
    info.compress_type = zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED
    archive.writestr(info, source.read_bytes(), compresslevel=None if stored else 9)


def build_patch(project: Path, runtime: Path, candidate_pk3: Path, output: Path) -> None:
    temporary = output.with_suffix(output.suffix + ".tmp")
    if temporary.exists():
        temporary.unlink()
    with zipfile.ZipFile(temporary, "w", allowZip64=True) as archive:
        for relative in RUNTIME_CHANGES:
            add_file(archive, runtime / relative, f"src/{relative}")
        for relative in PROJECT_CHANGES:
            add_file(archive, project / relative, relative)
        add_file(archive, candidate_pk3, EMBEDDED_PK3, stored=True)
    with zipfile.ZipFile(temporary) as archive:
        require(archive.testzip() is None, "El ZIP incremental está corrupto")
        require(
            len(archive.infolist())
            == len(RUNTIME_CHANGES) + len(PROJECT_CHANGES) + 1,
            "Cantidad de archivos inesperada",
        )
    os.replace(temporary, output)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-patch", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    base_patch = args.base_patch.resolve()
    output = args.output.resolve()
    require(project.is_dir(), f"No existe el proyecto: {project}")
    require(base_patch.is_file(), f"No existe el parche base: {base_patch}")
    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="ca_4310h_build_") as temporary_name:
        temporary = Path(temporary_name)
        base_pk3 = temporary / "base_4_31_0g.pk3"
        with zipfile.ZipFile(base_patch) as archive:
            require(EMBEDDED_PK3 in archive.namelist(), "La base no contiene el PK3")
            base_pk3.write_bytes(archive.read(EMBEDDED_PK3))

        base_root = temporary / "base_src"
        runtime = temporary / "candidate_src"
        base_root.mkdir()
        with zipfile.ZipFile(base_pk3) as archive:
            archive.extractall(base_root)
        shutil.copytree(base_root, runtime)

        patch_constants(runtime / "caelum/core/CaelumConstants.zs")
        patch_player(runtime / "caelum/player/CaelumPlayer.zs")
        patch_display_names(runtime / "caelum/ui/CaelumDisplayNames.zs")
        patch_special_items(runtime / "caelum/equipment/CaelumSpecialItems.zs")
        patch_language(runtime / "LANGUAGE")
        patch_map01(runtime / "maps/MAP01.wad")

        candidate_pk3 = temporary / "caelum_argenteum_dev.pk3"
        rebuild_pk3(base_pk3, runtime, candidate_pk3)
        subprocess.run(
            [
                sys.executable,
                str(project / "tools/audit_4_31_0h.py"),
                "--runtime-root",
                str(runtime),
                "--base-root",
                str(base_root),
                "--base-pk3",
                str(base_pk3),
                "--candidate-pk3",
                str(candidate_pk3),
            ],
            cwd=project,
            check=True,
        )
        build_patch(project, runtime, candidate_pk3, output)

    print(f"patch: {output}")
    print(f"size: {output.stat().st_size}")
    print(f"sha256: {hashlib.sha256(output.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
