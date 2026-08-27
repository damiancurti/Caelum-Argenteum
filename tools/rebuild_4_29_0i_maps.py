"""Completa divisores y puertas del primer piso de MAP01 para V4.29.0i.

La base 4.29.0h ya fue validada visualmente por el autor. Este parche no
reconstruye habitaciones: añade cuatro tramos nativos de pared 3D alrededor de
las dos puertas centrales existentes y coloca dos hojas en cada habitación del
fondo. Los controles 510/511 y todas las puertas anteriores se conservan.
"""

from __future__ import annotations

from collections import OrderedDict
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
CENTRAL_ROOMS = (
    (192.0, 192.0, 544.0, 544.0),
    (192.0, -544.0, 544.0, -192.0),
)
DIVIDER_BOXES = (
    (364.0, 200.0, 372.0, 336.0),
    (364.0, 400.0, 372.0, 536.0),
    (364.0, -536.0, 372.0, -400.0),
    (364.0, -336.0, 372.0, -200.0),
)
REAR_DOORS = (
    (1001.0, 196.0, 717, -1),
    (1065.0, 196.0, 717, 1),
    (1001.0, -196.0, 718, -1),
    (1065.0, -196.0, 718, 1),
)


def make_vertex(x: float, y: float) -> OrderedDict[str, str]:
    return OrderedDict((("x", f"{x:.1f}"), ("y", f"{y:.1f}")))


def make_side(sector: int) -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("offsetx", "0"),
            ("offsety", "0"),
            ("texturetop", '"CMIN01"'),
            ("texturebottom", '"CMIN01"'),
            ("texturemiddle", '"CMIN01"'),
            ("sector", str(sector)),
        )
    )


def make_door(
    x: float,
    y: float,
    group: int,
    direction: int,
) -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("x", f"{x:.1f}"),
            ("y", f"{y:.1f}"),
            ("height", "136.0"),
            ("angle", "90"),
            ("type", "18025"),
            ("arg0", str(group)),
            ("arg1", str(direction)),
            ("arg2", "0"),
            ("arg3", "0"),
            ("skill1", "true"),
            ("skill2", "true"),
            ("skill3", "true"),
            ("skill4", "true"),
            ("skill5", "true"),
            ("single", "true"),
            ("coop", "true"),
            ("dm", "true"),
        )
    )


def sector_id(blocks, side_index: int) -> int:
    sector_index = integer(blocks["sidedef"][side_index], "sector")
    return integer(blocks["sector"][sector_index], "id")


def find_room_sectors(blocks, box) -> tuple[int, int]:
    minimum_x, minimum_y, maximum_x, _ = box
    expected = {
        (minimum_x + 8.0, minimum_y + 8.0),
        (maximum_x - 8.0, minimum_y + 8.0),
    }
    positions = [
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    ]
    matches = []
    for line in blocks["linedef"]:
        endpoints = {
            positions[integer(line, "v1")],
            positions[integer(line, "v2")],
        }
        if endpoints == expected and "sideback" in line:
            matches.append(line)
    if len(matches) != 1:
        raise ValueError(
            f"No se pudo identificar el contorno interior de {box}: "
            f"{len(matches)} coincidencias"
        )

    line = matches[0]
    sides = (integer(line, "sidefront"), integer(line, "sideback"))
    sectors_by_id = {
        sector_id(blocks, side): integer(blocks["sidedef"][side], "sector")
        for side in sides
    }
    if 510 not in sectors_by_id or 511 not in sectors_by_id:
        raise ValueError(f"El módulo {box} no conserva sectores 510/511")
    return sectors_by_id[510], sectors_by_id[511]


def add_two_sided_line(
    blocks,
    start: int,
    end: int,
    front_sector: int,
    back_sector: int,
) -> None:
    front = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(front_sector))
    back = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(back_sector))
    blocks["linedef"].append(
        OrderedDict(
            (
                ("v1", str(start)),
                ("v2", str(end)),
                ("sidefront", str(front)),
                ("sideback", str(back)),
                ("twosided", "true"),
            )
        )
    )


def add_divider_box(blocks, box, interior_sector: int, wall_sector: int) -> None:
    minimum_x, minimum_y, maximum_x, maximum_y = box
    start = len(blocks["vertex"])
    # Horario: el frente (sector de pared) queda a la derecha de cada línea.
    blocks["vertex"].extend(
        (
            make_vertex(minimum_x, minimum_y),
            make_vertex(minimum_x, maximum_y),
            make_vertex(maximum_x, maximum_y),
            make_vertex(maximum_x, minimum_y),
        )
    )
    for first, second in ((0, 1), (1, 2), (2, 3), (3, 0)):
        add_two_sided_line(
            blocks,
            start + first,
            start + second,
            wall_sector,
            interior_sector,
        )


def has_dividers(blocks) -> bool:
    positions = {
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    }
    return all(
        (box[0], box[1]) in positions and (box[2], box[3]) in positions
        for box in DIVIDER_BOXES
    )


def has_rear_doors(blocks) -> bool:
    expected = {(x, y, group, direction) for x, y, group, direction in REAR_DOORS}
    found = set()
    for thing in blocks["thing"]:
        if integer(thing, "type") != 18025:
            continue
        key = (
            float(thing["x"]),
            float(thing["y"]),
            integer(thing, "arg0"),
            integer(thing, "arg1"),
        )
        if key in expected and float(thing.get("height", "0")) == 136.0:
            found.add(key)
    return found == expected


def validate_controls(blocks) -> None:
    controls = [
        line
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in (510, 511)
    ]
    if [integer(line, "arg0") for line in controls].count(510) != 2:
        raise ValueError("Los dos controles de losa 510 cambiaron")
    if [integer(line, "arg0") for line in controls].count(511) != 1:
        raise ValueError("El control de pared 511 cambió")


def rebuild_map01() -> bool:
    signature, lumps = read_wad(MAP01)
    text_index = next(i for i, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    current_counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if current_counts == (398, 489, 948, 99, 210):
        if not has_dividers(blocks) or not has_rear_doors(blocks):
            raise ValueError("MAP01 tiene conteos 4.29.0i pero contenido incompleto")
        validate_controls(blocks)
        return False
    if current_counts != (382, 473, 916, 99, 206):
        raise ValueError(
            "MAP01 no coincide con la base 4.29.0h ni con 4.29.0i: "
            f"{current_counts}"
        )

    room_sectors = [find_room_sectors(blocks, box) for box in CENTRAL_ROOMS]
    for divider_index, divider_box in enumerate(DIVIDER_BOXES):
        interior, wall = room_sectors[divider_index // 2]
        add_divider_box(blocks, divider_box, interior, wall)
    blocks["thing"].extend(
        make_door(x, y, group, direction)
        for x, y, group, direction in REAR_DOORS
    )

    final_counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if final_counts != (398, 489, 948, 99, 210):
        raise ValueError(f"La topología 4.29.0i es inesperada: {final_counts}")
    if not has_dividers(blocks) or not has_rear_doors(blocks):
        raise ValueError("La geometría o las puertas nuevas no quedaron completas")
    validate_controls(blocks)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(MAP01, signature, lumps)
    return True


def main() -> None:
    changed = rebuild_map01()
    print(f"MAP01: {'divisores y puertas añadidos' if changed else 'ya actualizado'}")


if __name__ == "__main__":
    main()
