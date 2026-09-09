#!/usr/bin/env python3
"""Focused deterministic audit for Caelum Argenteum 4.33.0c."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path, PurePosixPath


RUNTIME_FILES = {
    "CAPALOMO",
    "MAPINFO",
    "ZSCRIPT",
    "maps/MAP01.wad",
    "caelum/core/CaelumConstants.zs",
    "caelum/actors/CaelumAnchoredResident.zs",
    "caelum/actors/CaelumArgento.zs",
    "caelum/actors/CaelumCaella.zs",
    "caelum/actors/CaelumRulo.zs",
    "caelum/actors/CaelumRonnie.zs",
    "caelum/world/CaelumSecretPassage.zs",
}

NEW_RUNTIME_FILES = {
    "caelum/actors/CaelumAnchoredResident.zs",
    "caelum/world/CaelumSecretPassage.zs",
}

PROJECT_FILES = {
    "APLICAR_4_33_0c.txt",
    "PRUEBAS_4_33_0c.txt",
    "docs/DIALOGUE.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAP01_SECRET_PASSAGE_4_33_0c.md",
    "docs/QUESTS_REPUTATION_FACTIONS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_33_0c.py",
    "tools/build_source_patch_4_33_0c.py",
    "tools/rebuild_map01_4_33_0c.py",
}

FIXED_ZIP_TIME = (2026, 9, 9, 15, 0, 0)
BASELINE_MAP_SHA256 = "98371479812a41fc9d166c72c4a2d37fef37f002bf541eac8002a36b8682f5f8"
OUTPUT_MAP_SHA256 = "715e5e59f65e2ba203872203aea2bf2b091dd1ee31708843a88c5322a0111f86"

EXPECTED_RESIDENTS = {
    18021: (1040.0, -378.0, 136.0, 90),
    18022: (-290.0, -378.0, 136.0, 90),
    18020: (-290.0, 378.0, 136.0, 270),
    18023: (1036.0, 378.0, 136.0, 270),
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_text(path: Path) -> str:
    require(path.is_file(), f"falta archivo: {path}")
    return path.read_text(encoding="utf-8")


def runtime_path(project: Path, relative: str) -> Path:
    return project / "src" / relative


def expected_package_entries() -> set[str]:
    return {
        *(f"src/{relative}" for relative in RUNTIME_FILES),
        *PROJECT_FILES,
    }


def strip_comments_and_strings(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    return re.sub(r'"(?:\\.|[^"\\])*"', '""', text)


def check_delimiters(text: str, label: str) -> None:
    clean = strip_comments_and_strings(text)
    pairs = {"{": "}", "(": ")", "[": "]"}
    stack: list[tuple[str, int]] = []
    for index, char in enumerate(clean):
        if char in pairs:
            stack.append((char, index))
        elif char in pairs.values():
            require(bool(stack) and pairs[stack[-1][0]] == char,
                    f"delimitador inesperado {char!r} en {label}:{index}")
            stack.pop()
    require(not stack, f"delimitador sin cerrar en {label}: {stack[-1:]}")


def constant_value(text: str, name: str) -> str:
    match = re.search(
        rf"(?m)^\s*const\s+{re.escape(name)}\s*=\s*([^;]+);", text
    )
    require(match is not None, f"falta constante {name}")
    return match.group(1).strip()


def read_wad(path: Path) -> tuple[list[str], dict[str, bytes]]:
    data = path.read_bytes()
    require(len(data) >= 12, "MAP01 truncado")
    identity, count, directory_offset = struct.unpack_from("<4sii", data, 0)
    require(identity in {b"PWAD", b"IWAD"}, "cabecera MAP01 inválida")
    require(directory_offset + count * 16 <= len(data), "directorio MAP01 truncado")
    order: list[str] = []
    lumps: dict[str, bytes] = {}
    for index in range(count):
        offset, size, raw_name = struct.unpack_from(
            "<ii8s", data, directory_offset + index * 16
        )
        name = raw_name.rstrip(b"\0").decode("ascii")
        require(offset >= 0 and size >= 0 and offset + size <= len(data),
                f"lump {name} fuera de rango")
        order.append(name)
        lumps[name] = data[offset:offset + size]
    return order, lumps


def parse_udmf_blocks(text: str, kind: str) -> list[dict[str, object]]:
    result: list[dict[str, object]] = []
    for body in re.findall(
        rf"(?ms)^\s*{re.escape(kind)}\s*\{{(.*?)^\s*\}}", text
    ):
        entry: dict[str, object] = {}
        for key, raw in re.findall(
            r"(?m)^\s*([A-Za-z0-9_]+)\s*=\s*([^;]+);", body
        ):
            value = raw.strip()
            if value.startswith('"') and value.endswith('"'):
                parsed: object = value[1:-1]
            elif value in {"true", "false"}:
                parsed = value == "true"
            else:
                try:
                    parsed = float(value) if "." in value else int(value)
                except ValueError:
                    parsed = value
            entry[key] = parsed
        result.append(entry)
    return result


def find_things(things: list[dict[str, object]], type_id: int) -> list[dict[str, object]]:
    return [entry for entry in things if entry.get("type") == type_id]


def assert_thing(
    things: list[dict[str, object]],
    type_id: int,
    x: float,
    y: float,
    z: float,
    angle: int,
    args: dict[int, int] | None = None,
) -> dict[str, object]:
    matching = [
        entry for entry in find_things(things, type_id)
        if entry.get("x") == x and entry.get("y") == y
        and entry.get("height") == z and entry.get("angle") == angle
    ]
    require(len(matching) == 1,
            f"Thing {type_id} no es único en ({x},{y},{z},{angle})")
    entry = matching[0]
    for arg_index, expected in (args or {}).items():
        actual = int(entry.get(f"arg{arg_index}", 0))
        require(actual == expected,
                f"Thing {type_id} arg{arg_index}: {actual} != {expected}")
    return entry


def audit_runtime_reconstruction(
    project: Path, baseline_runtime: Path, full_runtime: Path
) -> None:
    baseline_files = {
        path.relative_to(baseline_runtime).as_posix()
        for path in baseline_runtime.rglob("*") if path.is_file()
    }
    current_files = {
        path.relative_to(full_runtime).as_posix()
        for path in full_runtime.rglob("*") if path.is_file()
    }
    require(current_files == baseline_files | NEW_RUNTIME_FILES,
            "runtime completo no equivale a V4.33.0b + archivos nuevos")
    for relative in sorted(baseline_files - RUNTIME_FILES):
        require((baseline_runtime / relative).read_bytes()
                == (full_runtime / relative).read_bytes(),
                f"cambió runtime aceptado ajeno: {relative}")
    for relative in RUNTIME_FILES:
        require(runtime_path(project, relative).read_bytes()
                == (full_runtime / relative).read_bytes(),
                f"runtime completo no contiene la fuente 0c: {relative}")


def audit_dialogue(project: Path) -> None:
    dialogue = read_text(runtime_path(project, "CAPALOMO"))
    require(dialogue.count("$CA_DLG_M01_UNKNOWN_VOICE_SILENCE") == 1,
            "Guardar silencio debe aparecer exactamente una vez en CAPALOMO")
    require(re.search(
        r'goodbye\s*=\s*"\$CA_DLG_M01_UNKNOWN_VOICE_SILENCE"\s*;', dialogue
    ) is not None, "falta salida nativa Guardar silencio")
    require(re.search(
        r'text\s*=\s*"\$CA_DLG_M01_UNKNOWN_VOICE_SILENCE"\s*;', dialogue
    ) is None, "persiste la copia explícita de Guardar silencio")


def audit_resident_sources(project: Path) -> None:
    constants = read_text(runtime_path(project, "caelum/core/CaelumConstants.zs"))
    require(constant_value(constants, "STORY_NPC_ANCHORED") == "1",
            "flag de anclaje narrativo cambió")
    require(constant_value(constants, "STORY_NPC_RETURN_DISTANCE") == "500.0",
            "distancia de retorno narrativa cambió")
    require(constant_value(constants, "M01_SECRET_ELEVATOR_WIDTH") == "84",
            "ancho del ascensor cambió")
    require(constant_value(constants, "M01_SECRET_ELEVATOR_DEPTH") == "88",
            "profundidad del ascensor cambió")

    anchor = read_text(runtime_path(
        project, "caelum/actors/CaelumAnchoredResident.zs"
    ))
    check_delimiters(anchor, "CaelumAnchoredResident.zs")
    for token in [
        "class CaelumAnchoredResident : CaelumCombatActor abstract",
        "homeDistance >= CaelumConstants.STORY_NPC_RETURN_DISTANCE",
        "bSolid = true",
        "bInvulnerable = true",
        "bFriendly = true",
        'SetState(FindState("See"))',
        'SetState(FindState("Spawn"))',
    ]:
        require(token in anchor, f"falta contrato de residente: {token}")

    for name in ["Argento", "Caella", "Rulo", "Ronnie"]:
        source = read_text(runtime_path(
            project, f"caelum/actors/Caelum{name}.zs"
        ))
        check_delimiters(source, f"Caelum{name}.zs")
        require(f"class Caelum{name} : CaelumAnchoredResident" in source,
                f"{name} no hereda el anclaje")
        require("A_CaelumResidentLook" in source
                and "A_CaelumResidentChase" in source,
                f"{name} no usa acciones narrativas")


def audit_secret_sources(project: Path) -> None:
    root = read_text(runtime_path(project, "ZSCRIPT"))
    mapinfo = read_text(runtime_path(project, "MAPINFO"))
    secret = read_text(runtime_path(
        project, "caelum/world/CaelumSecretPassage.zs"
    ))
    check_delimiters(secret, "CaelumSecretPassage.zs")
    require(root.index('CaelumCombatActor.zs')
            < root.index('CaelumAnchoredResident.zs')
            < root.index('CaelumArgento.zs'),
            "orden de includes del residente inválido")
    require(root.index('CaelumMineralVeins.zs')
            < root.index('CaelumSecretPassage.zs'),
            "el pasadizo debe incluirse después de las vetas")

    mappings = {
        18533: "CaelumM01VeinIron",
        18534: "CaelumM01VeinCoal",
        18535: "CaelumM01VeinCopper",
        18536: "CaelumM01VeinTin",
        18537: "CaelumWalkThroughWallPanel",
        18538: "CaelumSecretElevator",
        18539: "CaelumM01HatchetPickup",
    }
    for number, name in mappings.items():
        require(re.search(rf"(?m)^\s*{number}\s*=\s*{name}\s*$", mapinfo)
                is not None, f"DoomEdNum incorrecto: {number}={name}")
    for name in mappings.values():
        require(f"class {name} " in secret or f"class {name}:" in secret,
                f"falta clase {name}")
    require(secret.count("CATALOGUE_DAMAGE_BLUNT") == 4,
            "las cuatro vetas tutoriales deben aceptar golpe romo")
    require("GetDefaultSizeForCharacterTier" in secret
            and "WEAPON_TYPE_HATCHET" in secret,
            "la hachuela no adapta su talle")


def audit_map(project: Path, baseline_runtime: Path) -> None:
    baseline_map = baseline_runtime / "maps/MAP01.wad"
    current_map = runtime_path(project, "maps/MAP01.wad")
    require(sha256(baseline_map) == BASELINE_MAP_SHA256,
            "MAP01 base no es la V4.33.0b aceptada")
    require(sha256(current_map) == OUTPUT_MAP_SHA256,
            "MAP01 0c no coincide con la reconstrucción fijada")

    order, lumps = read_wad(current_map)
    require(order == ["MAP01", "TEXTMAP", "ENDMAP"],
            f"lumps MAP01 inesperados: {order}")
    text = lumps["TEXTMAP"].decode("utf-8")
    require(text.count("CAELUM_MAP01_4_33_0C_BEGIN") == 1
            and text.count("CAELUM_MAP01_4_33_0C_END") == 1,
            "marcadores 0c inválidos")
    expected_counts = {
        "vertex": 1489,
        "linedef": 2077,
        "sidedef": 3724,
        "sector": 648,
        "thing": 340,
    }
    for kind, expected in expected_counts.items():
        require(len(parse_udmf_blocks(text, kind)) == expected,
                f"conteo {kind} inesperado")

    things = parse_udmf_blocks(text, "thing")
    for type_id, (x, y, z, angle) in EXPECTED_RESIDENTS.items():
        assert_thing(things, type_id, x, y, z, angle, {0: 1})
        require(len(find_things(things, type_id)) == 1,
                f"residente duplicado: {type_id}")
    assert_thing(things, 18036, -1440.0, 0.0, 0.0, 180, {0: 1})
    require(len(find_things(things, 18036)) == 1, "Palomo duplicado")

    assert_thing(things, 18537, 1842.0, -360.0, 0.0, 90,
                 {0: 232, 1: 120})
    assert_thing(things, 18537, 1944.0, -87.0, 0.0, 180,
                 {0: 320, 1: 120})
    require(len(find_things(things, 18537)) == 2, "pared falsa duplicada")
    assert_thing(things, 18026, 1842.0, 366.0, 0.0, 270,
                 {0: 0, 1: 232})
    assert_thing(things, 18538, 1917.0, 316.0, 0.0, 90,
                 {0: 0, 1: 84, 2: 88})
    assert_thing(things, 18538, -20400.0, 32000.0, 0.0, 180,
                 {0: 1, 1: 84, 2: 88})
    require(len(find_things(things, 18538)) == 2, "ascensores inválidos")
    assert_thing(things, 18539, -20180.0, 32000.0, 0.0, 0)
    require(len(find_things(things, 18539)) == 1, "hachuela tutorial duplicada")
    for type_id in [18533, 18534, 18535, 18536]:
        require(len(find_things(things, type_id)) == 1,
                f"cantidad de veta tutorial inválida: {type_id}")

    # x=1875..1959 e y=272..360 permanece dentro del sector 92 comprobado.
    require(1917.0 - 84.0 / 2.0 >= 1816.0
            and 1917.0 + 84.0 / 2.0 <= 1961.0
            and 316.0 - 88.0 / 2.0 >= 272.0
            and 316.0 + 88.0 / 2.0 <= 383.0,
            "la huella del ascensor sobresale del sector 92")
    require(84.0 > 2.0 * (16.0 * 2.4 / 1.8)
            and 88.0 > 2.0 * (16.0 * 2.4 / 1.8),
            "el ascensor no admite el diámetro XL máximo")

    rebuild = project / "tools/rebuild_map01_4_33_0c.py"
    with tempfile.TemporaryDirectory(prefix="caelum_map01_0c_") as temp_dir:
        candidate = Path(temp_dir) / "MAP01.wad"
        subprocess.run([
            sys.executable, str(rebuild),
            "--input", str(baseline_map),
            "--output", str(candidate),
        ], check=True, capture_output=True, text=True)
        require(candidate.read_bytes() == current_map.read_bytes(),
                "reconstrucción MAP01 no determinista")


def audit_docs(project: Path) -> None:
    implementation = read_text(project / "docs/IMPLEMENTATION_STATUS.md")
    dialogue = read_text(project / "docs/DIALOGUE.md")
    quests = read_text(project / "docs/QUESTS_REPUTATION_FACTIONS.md")
    roadmap = read_text(project / "docs/ROADMAP.md")
    layout = read_text(project / "docs/MAP01_SECRET_PASSAGE_4_33_0c.md")
    tests = read_text(project / "PRUEBAS_4_33_0c.txt")
    apply = read_text(project / "APLICAR_4_33_0c.txt")
    for name, body in {
        "implementation": implementation,
        "dialogue": dialogue,
        "quests": quests,
        "roadmap": roadmap,
        "layout": layout,
        "tests": tests,
        "apply": apply,
    }.items():
        require("4.33.0c" in body, f"{name} no documenta 4.33.0c")
    require("una única salida nativa" in dialogue,
            "DIALOGUE no documenta el silencio único")
    require("84×88" in layout and "500 MU" in layout,
            "documentación física incompleta")
    require("no completa objetivos" in layout.lower(),
            "falta declarar el límite narrativo")


def audit_package(project: Path, package: Path) -> None:
    require(package.is_file(), f"falta paquete: {package}")
    with zipfile.ZipFile(package) as archive:
        names = archive.namelist()
        require(len(names) == len(set(names)), "entradas ZIP duplicadas")
        require(set(names) == expected_package_entries(),
                "conjunto de entradas ZIP inesperado")
        require(names == sorted(names), "ZIP no está ordenado")
        for info in archive.infolist():
            path = PurePosixPath(info.filename)
            require(not path.is_absolute() and ".." not in path.parts,
                    f"ruta ZIP insegura: {info.filename}")
            require(info.date_time == FIXED_ZIP_TIME,
                    f"timestamp ZIP no determinista: {info.filename}")
            require(not info.filename.lower().endswith(".pk3"),
                    "el parche fuente no debe incluir PK3")
            expected_path = project / info.filename
            require(archive.read(info.filename) == expected_path.read_bytes(),
                    f"bytes ZIP distintos: {info.filename}")
        wad_entries = [name for name in names if name.lower().endswith(".wad")]
        require(wad_entries == ["src/maps/MAP01.wad"],
                f"único WAD fuente esperado: {wad_entries}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0b-runtime", type=Path, required=True)
    parser.add_argument("--full-runtime", type=Path, required=True)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    baseline = args.baseline_0b_runtime.resolve()
    full_runtime = args.full_runtime.resolve()

    for relative in sorted(RUNTIME_FILES):
        require(runtime_path(project, relative).is_file(),
                f"falta runtime del parche: {relative}")
    for relative in sorted(PROJECT_FILES):
        require((project / relative).is_file(),
                f"falta archivo de proyecto: {relative}")

    audit_runtime_reconstruction(project, baseline, full_runtime)
    audit_dialogue(project)
    audit_resident_sources(project)
    audit_secret_sources(project)
    audit_map(project, baseline)
    audit_docs(project)
    if args.package is not None:
        audit_package(project, args.package.resolve())

    print("[OK] Caelum Argenteum 4.33.0c focused audit passed")


if __name__ == "__main__":
    main()
