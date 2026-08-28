"""Añade las dos entradas frontales centrales de MAP01 para V4.29.0r.

La base autorizada es MAP01 4.29.0q. Las habitaciones, divisores, conexiones
laterales, descansos y escaleras aprobados permanecen intactos. Este paso abre
un portal doble de 128 MU en el frente de cada bloque central y reutiliza el
mismo par de hojas deslizantes empleado por las habitaciones extremas.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0o_maps import (
    add_two_sided_line,
    compact_geometry,
    line_positions,
    make_room_sector,
)
from rebuild_4_29_0q_maps import (
    validate_closed_sector,
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "74bfcf67985380deb9b637d3d4687c86441655e6e16156c0077b47041a9e8dcd"
BASE_COUNTS = (460, 575, 1120, 99, 214)
UPDATED_COUNTS = (468, 587, 1144, 101, 218)

NORTH_INTERIOR = 95
NORTH_WALL = 96
SOUTH_INTERIOR = 97
SOUTH_WALL = 98
NORTH_PORTAL = 99
SOUTH_PORTAL = 100

# Dos hojas de 64 MU forman cada acceso de 128 MU. Son puertas normales, no
# trampas: se retraen en direcciones opuestas dentro del mismo muro frontal.
FRONT_DOORS = (
    (336.0, 196.0, 910, -1),
    (400.0, 196.0, 910, 1),
    (336.0, -196.0, 911, -1),
    (400.0, -196.0, 911, 1),
)

REPLACED_EDGES = (
    ((544.0, 192.0), (192.0, 192.0)),
    ((536.0, 200.0), (200.0, 200.0)),
    ((192.0, -192.0), (544.0, -192.0)),
    ((200.0, -200.0), (536.0, -200.0)),
)


def make_front_door(
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


def find_edge_indices(blocks, first, second) -> list[int]:
    expected = {first, second}
    return [
        index
        for index, line in enumerate(blocks["linedef"])
        if set(line_positions(blocks, line)) == expected
    ]


def add_north_portal(blocks) -> None:
    # El contorno norte conserva su orientación original de este a oeste.
    add_two_sided_line(blocks, (544.0, 192.0), (432.0, 192.0), NORTH_WALL, 41)
    add_two_sided_line(blocks, (432.0, 192.0), (304.0, 192.0), NORTH_PORTAL, 41)
    add_two_sided_line(blocks, (304.0, 192.0), (192.0, 192.0), NORTH_WALL, 41)

    add_two_sided_line(blocks, (536.0, 200.0), (432.0, 200.0), NORTH_INTERIOR, NORTH_WALL)
    add_two_sided_line(blocks, (432.0, 200.0), (304.0, 200.0), NORTH_INTERIOR, NORTH_PORTAL)
    add_two_sided_line(blocks, (304.0, 200.0), (200.0, 200.0), NORTH_INTERIOR, NORTH_WALL)

    add_two_sided_line(blocks, (304.0, 192.0), (304.0, 200.0), NORTH_PORTAL, NORTH_WALL)
    add_two_sided_line(blocks, (432.0, 192.0), (432.0, 200.0), NORTH_WALL, NORTH_PORTAL)


def add_south_portal(blocks) -> None:
    # El contorno sur conserva su orientación original de oeste a este.
    add_two_sided_line(blocks, (192.0, -192.0), (304.0, -192.0), SOUTH_WALL, 49)
    add_two_sided_line(blocks, (304.0, -192.0), (432.0, -192.0), SOUTH_PORTAL, 49)
    add_two_sided_line(blocks, (432.0, -192.0), (544.0, -192.0), SOUTH_WALL, 49)

    add_two_sided_line(blocks, (200.0, -200.0), (304.0, -200.0), SOUTH_INTERIOR, SOUTH_WALL)
    add_two_sided_line(blocks, (304.0, -200.0), (432.0, -200.0), SOUTH_INTERIOR, SOUTH_PORTAL)
    add_two_sided_line(blocks, (432.0, -200.0), (536.0, -200.0), SOUTH_INTERIOR, SOUTH_WALL)

    add_two_sided_line(blocks, (304.0, -200.0), (304.0, -192.0), SOUTH_PORTAL, SOUTH_WALL)
    add_two_sided_line(blocks, (432.0, -200.0), (432.0, -192.0), SOUTH_WALL, SOUTH_PORTAL)


def validate_front_entries(blocks) -> None:
    for x, y, group, direction in FRONT_DOORS:
        if not has_front_door(blocks, x, y, group, direction):
            raise ValueError(f"Falta la hoja frontal {group} en ({x:g}, {y:g})")

    for y, portal in ((192.0, NORTH_PORTAL), (-192.0, SOUTH_PORTAL)):
        for first_x, second_x in ((304.0, 432.0),):
            matches = find_edge_indices(
                blocks,
                (first_x, y),
                (second_x, y),
            )
            if len(matches) != 1:
                raise ValueError(f"Portal frontal incompleto en Y={y:g}")
        validate_closed_sector(blocks, portal)


def has_front_door(
    blocks,
    x: float,
    y: float,
    group: int,
    direction: int,
) -> bool:
    for thing in blocks["thing"]:
        if integer(thing, "type") != 18025:
            continue
        if (
            float(thing["x"]) == x
            and float(thing["y"]) == y
            and float(thing.get("height", "0")) == 136.0
            and integer(thing, "arg0") == group
            and integer(thing, "arg1") == direction
            and integer(thing, "arg2") == 0
            and integer(thing, "angle") == 90
        ):
            return True
    return False


def validate_map(blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0r inesperada: {counts}")

    ids = [integer(sector, "id") for sector in blocks["sector"]]
    if ids.count(510) != 8 or ids.count(511) != 4:
        raise ValueError(
            f"Sectores de planta alta inesperados: 510={ids.count(510)}, "
            f"511={ids.count(511)}"
        )

    validate_references(blocks)
    for sector_index in range(83, 101):
        if integer(blocks["sector"][sector_index], "id") in (510, 511):
            validate_closed_sector(blocks, sector_index)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)
    validate_front_entries(blocks)


def is_updated(blocks) -> bool:
    return all(
        has_front_door(blocks, x, y, group, direction)
        for x, y, group, direction in FRONT_DOORS
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_map(blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0q: {counts}, {digest}"
        )

    removed_lines: set[int] = set()
    for first, second in REPLACED_EDGES:
        matches = find_edge_indices(blocks, first, second)
        if len(matches) != 1:
            raise ValueError(f"Borde frontal ambiguo: {first} -> {second}")
        removed_lines.add(matches[0])
    compact_geometry(blocks, removed_lines)

    blocks["sector"].append(make_room_sector(510))
    blocks["sector"].append(make_room_sector(510))
    add_north_portal(blocks)
    add_south_portal(blocks)
    blocks["thing"].extend(
        make_front_door(x, y, group, direction)
        for x, y, group, direction in FRONT_DOORS
    )

    validate_map(blocks)
    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print("MAP01: entradas frontales 4.29.0r aplicadas" if changed else "MAP01: entradas frontales 4.29.0r ya presentes")
