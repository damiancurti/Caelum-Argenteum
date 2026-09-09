#!/usr/bin/env python3
"""Rebuild MAP01 for Caelum Argenteum 4.33.0c from an accepted UDMF WAD."""

from __future__ import annotations

import argparse
import re
import struct
from pathlib import Path


MARKER_BEGIN = "// CAELUM_MAP01_4_33_0C_BEGIN"
MARKER_END = "// CAELUM_MAP01_4_33_0C_END"
STORY_TYPES = {18020, 18021, 18022, 18023, 18036}
PATCH_TYPES = {18533, 18534, 18535, 18536, 18537, 18538, 18539}
CAVE_X = -20000.0
CAVE_Y = 32000.0
CAVE_FLOOR = -256


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def read_wad(path: Path) -> tuple[bytes, list[tuple[str, bytes]]]:
    data = path.read_bytes()
    require(len(data) >= 12, "WAD truncado")
    identity, count, directory_offset = struct.unpack_from("<4sii", data, 0)
    require(identity in {b"IWAD", b"PWAD"}, "cabecera WAD inválida")
    require(directory_offset + count * 16 <= len(data), "directorio WAD truncado")
    lumps: list[tuple[str, bytes]] = []
    for index in range(count):
        offset, size, raw_name = struct.unpack_from(
            "<ii8s", data, directory_offset + index * 16
        )
        require(offset >= 0 and size >= 0 and offset + size <= len(data),
                "lump fuera del WAD")
        name = raw_name.rstrip(b"\0").decode("ascii")
        lumps.append((name, data[offset:offset + size]))
    return identity, lumps


def write_wad(path: Path, identity: bytes, lumps: list[tuple[str, bytes]]) -> None:
    payload = bytearray()
    directory: list[tuple[int, int, str]] = []
    offset = 12
    for name, content in lumps:
        directory.append((offset, len(content), name))
        payload.extend(content)
        offset += len(content)
    directory_offset = 12 + len(payload)
    output = bytearray(struct.pack("<4sii", identity, len(lumps), directory_offset))
    output.extend(payload)
    for lump_offset, size, name in directory:
        raw_name = name.encode("ascii")
        require(len(raw_name) <= 8, f"nombre de lump demasiado largo: {name}")
        output.extend(struct.pack(
            "<ii8s", lump_offset, size, raw_name.ljust(8, b"\0")
        ))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(output)


def block_type(block: str) -> int | None:
    match = re.search(r"(?m)^\s*type\s*=\s*(-?\d+)\s*;", block)
    return int(match.group(1)) if match else None


def remove_previous_content(text: str) -> str:
    marker_pattern = re.compile(
        rf"(?ms)^\s*{re.escape(MARKER_BEGIN)}.*?^\s*{re.escape(MARKER_END)}\s*"
    )
    text = marker_pattern.sub("\n", text)

    # Las posiciones narrativas son únicas. Esto sustituye cualquier ensayo
    # anterior sin borrar galerías, recursos o actores de otras familias.
    thing_pattern = re.compile(r"(?ms)^\s*thing\s*\{.*?^\s*\}\s*")
    return thing_pattern.sub(
        lambda match: "\n" if block_type(match.group(0)) in STORY_TYPES | PATCH_TYPES
        else match.group(0),
        text,
    ).rstrip() + "\n"


def count_blocks(text: str, kind: str) -> int:
    return len(re.findall(rf"(?m)^\s*{re.escape(kind)}\s*$", text))


def thing(
    label: str,
    x: float,
    y: float,
    height: float,
    angle: int,
    type_id: int,
    args: tuple[int, int, int, int, int] = (0, 0, 0, 0, 0),
) -> str:
    fields = [
        f"// {label}",
        "thing",
        "{",
        f"    x = {x:.1f};",
        f"    y = {y:.1f};",
        f"    height = {height:.1f};",
        f"    angle = {angle};",
        f"    type = {type_id};",
    ]
    for index, value in enumerate(args):
        if value:
            fields.append(f"    arg{index} = {value};")
    fields.extend([
        "    skill1 = true;",
        "    skill2 = true;",
        "    skill3 = true;",
        "    skill4 = true;",
        "    skill5 = true;",
        "    single = true;",
        "    coop = true;",
        "    dm = true;",
        "}",
    ])
    return "\n".join(fields)


def vertex(x: float, y: float) -> str:
    return f"vertex\n{{\n    x = {x:.1f};\n    y = {y:.1f};\n}}"


def sector() -> str:
    return "\n".join([
        "sector",
        "{",
        f"    heightfloor = {CAVE_FLOOR};",
        "    heightceiling = 64;",
        '    texturefloor = "CMST02";',
        '    textureceiling = "CMIN01";',
        "    lightlevel = 112;",
        "}",
    ])


def sidedef(sector_index: int) -> str:
    return "\n".join([
        "sidedef",
        "{",
        f"    sector = {sector_index};",
        '    texturetop = "-";',
        '    texturebottom = "-";',
        '    texturemiddle = "CMIN01";',
        "}",
    ])


def linedef(v1: int, v2: int, sidefront: int) -> str:
    return "\n".join([
        "linedef",
        "{",
        f"    v1 = {v1};",
        f"    v2 = {v2};",
        "    blocking = true;",
        "    blockmonsters = true;",
        f"    sidefront = {sidefront};",
        "}",
    ])


def build_patch_block(text: str) -> str:
    vertex_base = count_blocks(text, "vertex")
    sector_index = count_blocks(text, "sector")
    sidedef_base = count_blocks(text, "sidedef")

    cave_vertices = [
        (CAVE_X - 500.0, CAVE_Y - 400.0),
        (CAVE_X - 500.0, CAVE_Y + 400.0),
        (CAVE_X + 500.0, CAVE_Y + 400.0),
        (CAVE_X + 500.0, CAVE_Y - 400.0),
    ]
    parts = [MARKER_BEGIN]
    parts.extend([
        thing("CA_M01_PALOMO_FOYER_SPOT", -1440.0, 0.0, 0.0, 180, 18036,
              (1, 0, 0, 0, 0)),
        thing("CA_M01_ARGENTO_SPOT", 1040.0, -378.0, 136.0, 90, 18021,
              (1, 0, 0, 0, 0)),
        thing("CA_M01_CAELLA_SPOT", -290.0, -378.0, 136.0, 90, 18022,
              (1, 0, 0, 0, 0)),
        thing("CA_M01_RULO_SPOT", -290.0, 378.0, 136.0, 270, 18020,
              (1, 0, 0, 0, 0)),
        thing("CA_M01_RONNIE_SPOT", 1036.0, 378.0, 136.0, 270, 18023,
              (1, 0, 0, 0, 0)),
        thing("CA_M01_SECRET_FALSE_WALL_ENTRY", 1842.0, -360.0, 0.0, 90,
              18537, (232, 120, 0, 0, 0)),
        thing("CA_M01_SECRET_FALSE_WALL_INNER", 1944.0, -87.0, 0.0, 180,
              18537, (320, 120, 0, 0, 0)),
        # El fondo es sólido; su cara sur queda a 6 MU del borde norte del lift.
        thing("CA_M01_SECRET_BACK_WALL", 1842.0, 366.0, 0.0, 270,
              18026, (0, 232, 0, 0, 0)),
        thing("CA_M01_SECRET_ELEVATOR_TOP", 1917.0, 316.0, 0.0, 90, 18538,
              (0, 84, 88, 0, 0)),
        thing("CA_M01_SECRET_ELEVATOR_CAVE", CAVE_X - 400.0, CAVE_Y, 0.0,
              180, 18538, (1, 84, 88, 0, 0)),
        thing("CA_M01_SURVIVAL_HATCHET", CAVE_X - 180.0, CAVE_Y, 0.0, 0,
              18539),
        thing("CA_M01_CAVE_TREE_1", CAVE_X + 40.0, CAVE_Y - 235.0, 0.0,
              35, 18469),
        thing("CA_M01_CAVE_TREE_2", CAVE_X + 110.0, CAVE_Y + 30.0, 0.0,
              170, 18470),
        thing("CA_M01_CAVE_TREE_3", CAVE_X + 5.0, CAVE_Y + 260.0, 0.0,
              290, 18471),
        thing("CA_M01_CAVE_IRON", CAVE_X + 405.0, CAVE_Y - 270.0, 0.0,
              180, 18533),
        thing("CA_M01_CAVE_COAL", CAVE_X + 420.0, CAVE_Y - 90.0, 0.0,
              180, 18534),
        thing("CA_M01_CAVE_COPPER", CAVE_X + 420.0, CAVE_Y + 90.0, 0.0,
              180, 18535),
        thing("CA_M01_CAVE_TIN", CAVE_X + 405.0, CAVE_Y + 270.0, 0.0,
              180, 18536),
    ])
    parts.extend(vertex(x, y) for x, y in cave_vertices)
    parts.append(sector())
    parts.extend(sidedef(sector_index) for _ in range(4))
    # SW→NW→NE→SE→SW mantiene el interior a la derecha de cada línea.
    parts.extend([
        linedef(vertex_base + 0, vertex_base + 1, sidedef_base + 0),
        linedef(vertex_base + 1, vertex_base + 2, sidedef_base + 1),
        linedef(vertex_base + 2, vertex_base + 3, sidedef_base + 2),
        linedef(vertex_base + 3, vertex_base + 0, sidedef_base + 3),
    ])
    parts.append(MARKER_END)
    return "\n\n".join(parts) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    identity, lumps = read_wad(args.input)
    names = [name for name, _ in lumps]
    require(names.count("TEXTMAP") == 1, "MAP01 debe contener un TEXTMAP único")
    require("ENDMAP" in names, "MAP01 UDMF sin ENDMAP")

    rebuilt: list[tuple[str, bytes]] = []
    for name, content in lumps:
        if name != "TEXTMAP":
            rebuilt.append((name, content))
            continue
        text = content.decode("utf-8")
        require(re.search(r'namespace\s*=\s*"(?:ZDoom|GZDoom)"', text) is not None,
                "namespace UDMF no compatible")
        text = remove_previous_content(text)
        text += "\n" + build_patch_block(text)
        rebuilt.append((name, text.encode("utf-8")))

    write_wad(args.output, identity, rebuilt)
    print(f"MAP01 4.33.0c reconstruido: {args.output}")


if __name__ == "__main__":
    main()
