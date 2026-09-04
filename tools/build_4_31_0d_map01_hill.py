#!/usr/bin/env python3
"""Agrega una colina facetada y transitable al césped sur de MAP01."""

from __future__ import annotations

import argparse
from collections import Counter, OrderedDict
from hashlib import sha256
import math
import os
from pathlib import Path
import re
import stat
import struct
import tempfile
from typing import Iterable, Sequence


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MAP = ROOT / "src/maps/MAP01.wad"

BASE_SHA256 = "815f2ed0cd6f52fb03e63eaab3f8b8db560fc9b96c4fbe63a87b1e94e7ef8e60"
UPDATED_SHA256 = "e2fad8a944d7a508b255db2529fe0464e1528d7a08623b6387c3fac08b3cbdc9"
BASE_COUNTS = (1469, 2049, 3672, 638, 322)
UPDATED_COUNTS = (1485, 2073, 3720, 647, 322)

HILL_CENTER = (600.0, -1100.0)
HILL_OUTER_OFFSETS = (
    (320.0, 0.0),
    (224.0, 224.0),
    (0.0, 320.0),
    (-224.0, 224.0),
    (-320.0, 0.0),
    (-224.0, -224.0),
    (0.0, -320.0),
    (224.0, -224.0),
)
HILL_INNER_OFFSETS = (
    (96.0, 0.0),
    (67.2, 67.2),
    (0.0, 96.0),
    (-67.2, 67.2),
    (-96.0, 0.0),
    (-67.2, -67.2),
    (0.0, -96.0),
    (67.2, -67.2),
)
HILL_HEIGHT = 48.0
HILL_MARKER = "// CAELUM_HILL_4_31_0D_BEGIN"

BLOCK_PATTERN = re.compile(
    r"(?ms)^([A-Za-z_][A-Za-z0-9_]*)\s*\{\s*.*?^\}[ \t]*$"
)
PROPERTY_PATTERN = re.compile(
    r"(?m)^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*;\s*$"
)
MAP_KINDS = ("vertex", "linedef", "sidedef", "sector", "thing")


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    if len(data) < 12:
        raise ValueError(f"WAD truncado: {path}")
    signature, lump_count, directory_offset = struct.unpack_from("<4sII", data)
    if signature not in (b"IWAD", b"PWAD"):
        raise ValueError(f"Firma WAD inválida: {signature!r}")
    if directory_offset + lump_count * 16 > len(data):
        raise ValueError("El directorio WAD excede el archivo")

    lumps: list[tuple[bytes, bytes]] = []
    for index in range(lump_count):
        position, size, raw_name = struct.unpack_from(
            "<II8s", data, directory_offset + index * 16
        )
        if position + size > len(data):
            raise ValueError(f"Lump {index} fuera del WAD")
        lumps.append((raw_name.rstrip(b"\0"), data[position : position + size]))
    return signature, lumps


def render_wad(signature: bytes, lumps: Sequence[tuple[bytes, bytes]]) -> bytes:
    output = bytearray(b"\0" * 12)
    directory: list[tuple[int, int, bytes]] = []
    for name, contents in lumps:
        position = len(output)
        output.extend(contents)
        directory.append((position, len(contents), name))
    directory_offset = len(output)
    for position, size, name in directory:
        output.extend(struct.pack("<II8s", position, size, name.ljust(8, b"\0")))
    struct.pack_into(
        "<4sII", output, 0, signature, len(lumps), directory_offset
    )
    return bytes(output)


def write_atomic(path: Path, contents: bytes) -> None:
    # El reemplazo atómico evita dejar un WAD parcial si la escritura falla.
    mode = stat.S_IMODE(path.stat().st_mode)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(contents)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary_path, mode)
        os.replace(temporary_path, path)
    finally:
        if temporary_path.exists():
            temporary_path.unlink()


def parse_blocks(text: str) -> dict[str, list[dict[str, str]]]:
    result: dict[str, list[dict[str, str]]] = {kind: [] for kind in MAP_KINDS}
    for match in BLOCK_PATTERN.finditer(text):
        kind = match.group(1)
        if kind in result:
            result[kind].append(dict(PROPERTY_PATTERN.findall(match.group(0))))
    return result


def map_counts(blocks: dict[str, list[dict[str, str]]]) -> tuple[int, ...]:
    return tuple(len(blocks[kind]) for kind in MAP_KINDS)


def point(offset: tuple[float, float]) -> tuple[float, float]:
    return (HILL_CENTER[0] + offset[0], HILL_CENTER[1] + offset[1])


def signed_area(indices: Sequence[int], vertices: Sequence[tuple[float, float]]) -> float:
    area = 0.0
    for index, first in enumerate(indices):
        second = indices[(index + 1) % len(indices)]
        area += vertices[first][0] * vertices[second][1]
        area -= vertices[second][0] * vertices[first][1]
    return area * 0.5


def clockwise(indices: Sequence[int], vertices: Sequence[tuple[float, float]]) -> list[int]:
    result = list(indices)
    if signed_area(result, vertices) > 0.0:
        result.reverse()
    return result


def floor_plane(
    first: tuple[float, float, float],
    second: tuple[float, float, float],
    third: tuple[float, float, float],
) -> tuple[float, float, float, float]:
    ux, uy, uz = (second[i] - first[i] for i in range(3))
    vx, vy, vz = (third[i] - first[i] for i in range(3))
    nx = uy * vz - uz * vy
    ny = uz * vx - ux * vz
    nz = ux * vy - uy * vx
    if abs(nz) <= 0.000001:
        raise ValueError("Plano vertical inválido para el piso de la colina")
    a = nx / nz
    b = ny / nz
    c = 1.0
    d = -(a * first[0] + b * first[1] + first[2])
    return (a, b, c, d)


def vertex_block(x: float, y: float) -> str:
    return f"vertex\n{{\n    x = {x:.6f};\n    y = {y:.6f};\n}}\n"


def sector_block(plane: tuple[float, float, float, float] | None) -> str:
    floor_height = 0 if plane is not None else int(HILL_HEIGHT)
    lines = [
        "sector",
        "{",
        f"    heightfloor = {floor_height};",
        "    heightceiling = 30000;",
        '    texturefloor = "CMGR01A";',
        '    textureceiling = "F_SKY1";',
        "    lightlevel = 176;",
    ]
    if plane is not None:
        names = ("a", "b", "c", "d")
        for name, value in zip(names, plane):
            lines.append(f"    floorplane_{name} = {value:.15f};")
    lines.extend(("}", ""))
    return "\n".join(lines)


def sidedef_block(sector: int) -> str:
    return "\n".join((
        "sidedef",
        "{",
        "    offsetx = 0;",
        "    offsety = 0;",
        '    texturetop = "-";',
        '    texturebottom = "-";',
        '    texturemiddle = "-";',
        f"    sector = {sector};",
        "}",
        "",
    ))


def linedef_block(v1: int, v2: int, sidefront: int, sideback: int) -> str:
    return "\n".join((
        "linedef",
        "{",
        f"    v1 = {v1};",
        f"    v2 = {v2};",
        "    twosided = true;",
        f"    sidefront = {sidefront};",
        f"    sideback = {sideback};",
        "}",
        "",
    ))


def ensure_empty_site(
    blocks: dict[str, list[dict[str, str]]],
    vertices: Sequence[tuple[float, float]],
) -> None:
    min_x = HILL_CENTER[0] - 321.0
    max_x = HILL_CENTER[0] + 321.0
    min_y = HILL_CENTER[1] - 321.0
    max_y = HILL_CENTER[1] + 321.0
    for index, line in enumerate(blocks["linedef"]):
        first = vertices[int(line["v1"])]
        second = vertices[int(line["v2"])]
        if (
            max(first[0], second[0]) >= min_x
            and min(first[0], second[0]) <= max_x
            and max(first[1], second[1]) >= min_y
            and min(first[1], second[1]) <= max_y
        ):
            raise ValueError(f"Linedef {index} invade el sitio reservado para la colina")
    for index, thing in enumerate(blocks["thing"]):
        x = float(thing["x"])
        y = float(thing["y"])
        if min_x <= x <= max_x and min_y <= y <= max_y:
            raise ValueError(f"Thing {index} invade el sitio reservado para la colina")


def add_hill(text: str) -> str:
    blocks = parse_blocks(text)
    if map_counts(blocks) != BASE_COUNTS:
        raise ValueError(f"Estructura MAP01 inesperada: {map_counts(blocks)}")

    old_vertices = [
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    ]
    ensure_empty_site(blocks, old_vertices)

    hill_vertices = [point(offset) for offset in HILL_OUTER_OFFSETS]
    hill_vertices.extend(point(offset) for offset in HILL_INNER_OFFSETS)
    all_vertices = old_vertices + hill_vertices
    first_vertex = len(old_vertices)
    outer = [first_vertex + index for index in range(8)]
    inner = [first_vertex + 8 + index for index in range(8)]
    first_sector = len(blocks["sector"])

    polygons: list[tuple[list[int], int]] = []
    for index in range(8):
        following = (index + 1) % 8
        polygon = clockwise(
            (outer[index], outer[following], inner[following], inner[index]),
            all_vertices,
        )
        polygons.append((polygon, first_sector + index))
    polygons.append((clockwise(inner, all_vertices), first_sector + 8))

    edges: OrderedDict[tuple[int, int], dict[str, int | None]] = OrderedDict()
    for polygon, sector in polygons:
        for index, v1 in enumerate(polygon):
            v2 = polygon[(index + 1) % len(polygon)]
            key = tuple(sorted((v1, v2)))
            if key not in edges:
                edges[key] = {"v1": v1, "v2": v2, "front": sector, "back": None}
            else:
                edge = edges[key]
                if edge["v1"] != v2 or edge["v2"] != v1 or edge["back"] is not None:
                    raise ValueError(f"Topología no orientable en borde {key}")
                edge["back"] = sector

    if len(edges) != 24:
        raise ValueError(f"La colina debe tener 24 bordes; obtuvo {len(edges)}")

    vertex_text = "\n".join(vertex_block(x, y) for x, y in hill_vertices)
    sector_text: list[str] = []
    for index in range(8):
        following = (index + 1) % 8
        ox1, oy1 = all_vertices[outer[index]]
        ox2, oy2 = all_vertices[outer[following]]
        ix1, iy1 = all_vertices[inner[index]]
        plane = floor_plane(
            (ox1, oy1, 0.0),
            (ox2, oy2, 0.0),
            (ix1, iy1, HILL_HEIGHT),
        )
        sector_text.append(sector_block(plane))
    sector_text.append(sector_block(None))

    side_text: list[str] = []
    line_text: list[str] = []
    next_side = len(blocks["sidedef"])
    for edge in edges.values():
        front_side = next_side
        back_side = next_side + 1
        next_side += 2
        side_text.append(sidedef_block(int(edge["front"])))
        side_text.append(sidedef_block(
            int(edge["back"]) if edge["back"] is not None else 0
        ))
        line_text.append(linedef_block(
            int(edge["v1"]), int(edge["v2"]), front_side, back_side
        ))

    addition = "\n".join((
        "",
        HILL_MARKER,
        "// Octágono exterior a z=0, meseta interior a z=48 y ocho planos.",
        vertex_text,
        "\n".join(sector_text),
        "\n".join(side_text),
        "\n".join(line_text),
        "// CAELUM_HILL_4_31_0D_END",
        "",
    ))
    return text.rstrip() + addition


def validate_updated(text: str) -> None:
    blocks = parse_blocks(text)
    counts = map_counts(blocks)
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura actualizada inesperada: {counts}")
    if text.count(HILL_MARKER) != 1:
        raise ValueError("La marca de la colina debe aparecer exactamente una vez")

    vertex_count = len(blocks["vertex"])
    side_count = len(blocks["sidedef"])
    sector_count = len(blocks["sector"])
    side_uses: Counter[int] = Counter()
    for index, line in enumerate(blocks["linedef"]):
        for key in ("v1", "v2"):
            value = int(line[key])
            if not 0 <= value < vertex_count:
                raise ValueError(f"Linedef {index}: {key} fuera de rango")
        for key in ("sidefront", "sideback"):
            if key not in line:
                continue
            value = int(line[key])
            if not 0 <= value < side_count:
                raise ValueError(f"Linedef {index}: {key} fuera de rango")
            side_uses[value] += 1
    if any(side_uses[index] != 1 for index in range(side_count)):
        raise ValueError("Hay sidedefs huérfanos o compartidos")
    for index, side in enumerate(blocks["sidedef"]):
        sector = int(side["sector"])
        if not 0 <= sector < sector_count:
            raise ValueError(f"Sidedef {index}: sector fuera de rango")


def rebuild(path: Path) -> bool:
    original = path.read_bytes()
    original_digest = sha256(original).hexdigest()
    signature, lumps = read_wad(path)
    text_indexes = [index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"]
    if len(text_indexes) != 1:
        raise ValueError(f"MAP01 debe contener un TEXTMAP: {text_indexes}")
    text_index = text_indexes[0]
    text = lumps[text_index][1].decode("utf-8")

    if original_digest == UPDATED_SHA256:
        validate_updated(text)
        return False
    if original_digest != BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base 4.31.0c ni con la salida 4.31.0d: "
            f"{original_digest}"
        )
    if HILL_MARKER in text:
        raise ValueError("La base contiene inesperadamente la marca de la colina")

    updated_text = add_hill(text)
    validate_updated(updated_text)
    lumps[text_index] = (b"TEXTMAP", updated_text.encode("utf-8"))
    updated_wad = render_wad(signature, lumps)
    updated_digest = sha256(updated_wad).hexdigest()
    if UPDATED_SHA256 != "TO_BE_FILLED" and updated_digest != UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.31.0d inesperado: {updated_digest}")
    write_atomic(path, updated_wad)
    print(f"MAP01 4.31.0d SHA-256: {updated_digest}")
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--map", type=Path, default=DEFAULT_MAP)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    changed = rebuild(args.map)
    if changed:
        print("MAP01: colina sur agregada")
    else:
        print("MAP01: colina 4.31.0d ya presente")


if __name__ == "__main__":
    main()
