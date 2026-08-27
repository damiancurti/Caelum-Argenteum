"""Reconstruye las correcciones UDMF de MAP01 y MAP02 para V4.29.0f.

El script trabaja sobre los WAD fuente, valida la topología esperada y evita
editar índices binarios a mano. Puede ejecutarse una sola vez sobre V4.29.0e;
si el mapa ya está actualizado, termina sin volver a modificarlo.
"""

from __future__ import annotations

import re
import struct
from collections import OrderedDict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

BLOCK_KINDS = ("vertex", "linedef", "sidedef", "sector", "thing")
BLOCK_PATTERN = re.compile(
    r"(?ms)^(vertex|linedef|sidedef|sector|thing)\s*\n\{(.*?)^\}"
)
PROPERTY_PATTERN = re.compile(r"(?m)^\s*(\w+)\s*=\s*(.*?);\s*$")


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    signature, lump_count, directory_offset = struct.unpack_from("<4sII", data, 0)
    if signature not in (b"PWAD", b"IWAD"):
        raise ValueError(f"Firma WAD inválida: {path}")
    lumps: list[tuple[bytes, bytes]] = []
    for index in range(lump_count):
        offset, size, name = struct.unpack_from(
            "<II8s", data, directory_offset + index * 16
        )
        lumps.append((name.rstrip(b"\0"), data[offset : offset + size]))
    return signature, lumps


def write_wad(path: Path, signature: bytes, lumps: list[tuple[bytes, bytes]]) -> None:
    payload = bytearray(struct.pack("<4sII", signature, len(lumps), 0))
    directory: list[tuple[int, int, bytes]] = []
    for name, content in lumps:
        offset = len(payload)
        payload.extend(content)
        directory.append((offset, len(content), name))
    directory_offset = len(payload)
    for offset, size, name in directory:
        payload.extend(struct.pack("<II8s", offset, size, name[:8].ljust(8, b"\0")))
    struct.pack_into("<I", payload, 8, directory_offset)
    path.write_bytes(payload)


def parse_textmap(text: str) -> tuple[str, dict[str, list[OrderedDict[str, str]]]]:
    header_end = min(
        (match.start() for match in BLOCK_PATTERN.finditer(text)),
        default=len(text),
    )
    header = text[:header_end].strip()
    blocks = {kind: [] for kind in BLOCK_KINDS}
    for match in BLOCK_PATTERN.finditer(text):
        properties: OrderedDict[str, str] = OrderedDict()
        for property_match in PROPERTY_PATTERN.finditer(match.group(2)):
            properties[property_match.group(1)] = property_match.group(2)
        blocks[match.group(1)].append(properties)
    return header, blocks


def render_textmap(
    header: str, blocks: dict[str, list[OrderedDict[str, str]]]
) -> str:
    parts = [header, ""]
    for kind in BLOCK_KINDS:
        for properties in blocks[kind]:
            parts.extend((kind, "{"))
            parts.extend(f"    {name} = {value};" for name, value in properties.items())
            parts.extend(("}", ""))
    return "\n".join(parts)


def integer(properties: OrderedDict[str, str], name: str) -> int | None:
    value = properties.get(name)
    return None if value is None else int(value)


def replace_textmap(path: Path, transform) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(i for i, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))
    changed = transform(blocks)
    if not changed:
        return False
    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)
    return True


def remove_map01_control_sector(
    blocks: dict[str, list[OrderedDict[str, str]]], sector_index: int
) -> None:
    lines = blocks["linedef"]
    sides = blocks["sidedef"]
    vertices = blocks["vertex"]
    sectors = blocks["sector"]

    sector_sides = {
        index for index, side in enumerate(sides) if integer(side, "sector") == sector_index
    }
    removed_lines = {
        index
        for index, line in enumerate(lines)
        if integer(line, "sidefront") in sector_sides
        or integer(line, "sideback") in sector_sides
    }
    if len(removed_lines) != 4 or len(sector_sides) != 4:
        raise ValueError("El control 512 no conserva su rectángulo aislado de cuatro líneas")

    removed_vertices = {
        integer(lines[index], key)
        for index in removed_lines
        for key in ("v1", "v2")
    }
    used_elsewhere = {
        integer(line, key)
        for index, line in enumerate(lines)
        if index not in removed_lines
        for key in ("v1", "v2")
    }
    if removed_vertices & used_elsewhere:
        raise ValueError("El control 512 comparte vértices con geometría jugable")

    kept_vertices = [i for i in range(len(vertices)) if i not in removed_vertices]
    kept_lines = [i for i in range(len(lines)) if i not in removed_lines]
    kept_sides = [i for i in range(len(sides)) if i not in sector_sides]
    kept_sectors = [i for i in range(len(sectors)) if i != sector_index]
    vertex_map = {old: new for new, old in enumerate(kept_vertices)}
    side_map = {old: new for new, old in enumerate(kept_sides)}
    sector_map = {old: new for new, old in enumerate(kept_sectors)}

    new_lines: list[OrderedDict[str, str]] = []
    for old_index in kept_lines:
        line = lines[old_index]
        line["v1"] = str(vertex_map[integer(line, "v1")])
        line["v2"] = str(vertex_map[integer(line, "v2")])
        line["sidefront"] = str(side_map[integer(line, "sidefront")])
        if "sideback" in line:
            line["sideback"] = str(side_map[integer(line, "sideback")])
        new_lines.append(line)

    new_sides: list[OrderedDict[str, str]] = []
    for old_index in kept_sides:
        side = sides[old_index]
        side["sector"] = str(sector_map[integer(side, "sector")])
        new_sides.append(side)

    blocks["vertex"] = [vertices[i] for i in kept_vertices]
    blocks["linedef"] = new_lines
    blocks["sidedef"] = new_sides
    blocks["sector"] = [sectors[i] for i in kept_sectors]


def remove_unused_map01_sectors(
    blocks: dict[str, list[OrderedDict[str, str]]]
) -> int:
    sides = blocks["sidedef"]
    sectors = blocks["sector"]
    used = {integer(side, "sector") for side in sides}
    kept = [index for index in range(len(sectors)) if index in used]
    removed = len(sectors) - len(kept)
    if removed == 0:
        return 0
    sector_map = {old: new for new, old in enumerate(kept)}
    for side in sides:
        side["sector"] = str(sector_map[integer(side, "sector")])
    blocks["sector"] = [sectors[index] for index in kept]
    return removed


def update_map01(blocks: dict[str, list[OrderedDict[str, str]]]) -> bool:
    sectors = blocks["sector"]
    if not any(integer(sector, "id") == 512 for sector in sectors):
        if (len(blocks["vertex"]), len(blocks["linedef"]), len(blocks["sidedef"]), len(sectors)) != (
            510,
            517,
            1004,
            99,
        ):
            return False
        return remove_unused_map01_sectors(blocks) > 0
    if (len(blocks["vertex"]), len(blocks["linedef"]), len(blocks["sidedef"]), len(sectors)) != (
        514,
        521,
        1008,
        100,
    ):
        raise ValueError("MAP01 no coincide con la base estructural V4.29.0e")

    # Habitación y umbral son una sola superficie transitable. El tag 511
    # queda reservado exclusivamente al volumen vertical de pared.
    replaced = 0
    for sector in sectors:
        if integer(sector, "id") == 512:
            sector["id"] = "510"
            replaced += 1
    if replaced != 3:
        raise ValueError(f"Se esperaban tres sectores objetivo 512; encontrados {replaced}")

    control_sector = None
    for index, sector in enumerate(sectors):
        if integer(sector, "heightfloor") != 128 or integer(sector, "heightceiling") != 136:
            continue
        sector_sides = {
            side_index
            for side_index, side in enumerate(blocks["sidedef"])
            if integer(side, "sector") == index
        }
        target_lines = [
            line
            for line in blocks["linedef"]
            if integer(line, "sidefront") in sector_sides
            and integer(line, "special") == 160
            and integer(line, "arg0") == 512
        ]
        if target_lines:
            control_sector = index
            break
    if control_sector is None:
        raise ValueError("No se encontró el control de losa independiente del tag 512")

    # El control superior 256–264 ya apunta a 510. Su segunda línea 512 deja
    # de ser especial; la superficie común no necesita un segundo enlace.
    cleared = 0
    for line in blocks["linedef"]:
        if integer(line, "special") == 160 and integer(line, "arg0") == 512:
            front_sector = integer(blocks["sidedef"][integer(line, "sidefront")], "sector")
            if front_sector == control_sector:
                continue
            for name in ("special", "arg0", "arg1", "arg2", "arg3", "arg4"):
                line.pop(name, None)
            cleared += 1
    if cleared != 1:
        raise ValueError(f"Se esperaba un enlace superior 512; encontrados {cleared}")

    remove_map01_control_sector(blocks, control_sector)
    if remove_unused_map01_sectors(blocks) != 1:
        raise ValueError("No se eliminó el sector vacío heredado de V4.29.0e")

    if any(integer(sector, "id") == 512 for sector in blocks["sector"]):
        raise ValueError("Persistió un sector objetivo 512 tras la consolidación")
    if any(
        integer(line, "special") == 160 and integer(line, "arg0") == 512
        for line in blocks["linedef"]
    ):
        raise ValueError("Persistió un control 3D para el tag 512")
    return True


def update_map02(blocks: dict[str, list[OrderedDict[str, str]]]) -> bool:
    vertices = blocks["vertex"]
    lines = blocks["linedef"]
    sides = blocks["sidedef"]
    if any(
        integer(line, "v1") == 7 and integer(line, "v2") == 2
        for line in lines
    ):
        return False
    if (len(vertices), len(lines), len(sides), len(blocks["sector"])) != (80, 71, 134, 1):
        raise ValueError("MAP02 no coincide con la base estructural V4.29.0e")
    if vertices[7].get("x") != "8192.0" or vertices[7].get("y") != "-4096.0":
        raise ValueError("El extremo inferior de la compuerta masiva cambió")
    if vertices[2].get("x") != "8192.0" or vertices[2].get("y") != "4096.0":
        raise ValueError("El extremo superior de la compuerta masiva cambió")

    front = len(sides)
    back = front + 1
    for _ in range(2):
        sides.append(
            OrderedDict(
                (
                    ("sector", "0"),
                    ("texturetop", '"-"'),
                    ("texturebottom", '"-"'),
                    ("texturemiddle", '"CASWRWAL"'),
                )
            )
        )
    lines.append(
        OrderedDict(
            (
                ("v1", "7"),
                ("v2", "2"),
                ("sidefront", str(front)),
                ("sideback", str(back)),
                ("twosided", "true"),
                ("blocking", "true"),
                ("blockmonsters", "true"),
                ("blocksight", "true"),
            )
        )
    )
    return True


def main() -> None:
    changed01 = replace_textmap(MAP01, update_map01)
    changed02 = replace_textmap(MAP02, update_map02)
    print(f"MAP01: {'actualizado' if changed01 else 'sin cambios'}")
    print(f"MAP02: {'actualizado' if changed02 else 'sin cambios'}")


if __name__ == "__main__":
    main()
