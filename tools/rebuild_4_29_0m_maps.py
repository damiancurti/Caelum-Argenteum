"""Corrige la fachada y el pasillo del primer piso de MAP01 para V4.29.0m.

Las hileras de V4.29.0l ya son continuas en X, pero envolvían los descansos de
las escaleras. Esta migración aplana ambas fachadas en Y=±368: entre el borde
de cada descanso (Y=±272) y la pared quedan exactamente 96 MU de pasillo.
"""

from __future__ import annotations

from collections import OrderedDict, defaultdict
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0l_maps import (
    add_divider_box,
    add_two_sided_line,
    compact_geometry,
    find_line,
    line_positions,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
ROOM_TAGS = (510, 511)
FRONT_DOORS = (700, 716, 717, 718)
MIDDLE_DOORS = (902, 905)


def line_sector_indices(blocks, line) -> list[int]:
    return [
        integer(blocks["sidedef"][integer(line, side_name)], "sector")
        for side_name in ("sidefront", "sideback")
        if side_name in line
    ]


def get_base_sector(blocks, first, second, room_sector_indices) -> int:
    line = blocks["linedef"][find_line(blocks, first, second)]
    candidates = [
        sector
        for sector in line_sector_indices(blocks, line)
        if sector not in room_sector_indices
    ]
    if len(candidates) != 1:
        raise ValueError(f"Sector base ambiguo en {first}<->{second}")
    return candidates[0]


def restore_stair_sides(blocks, wall_sector: int) -> None:
    # V4.29.0l convirtió los costados de los descansos en pared de habitación.
    # Antes de retirar las hileras, devolver cada lado al sector de su escalera.
    for line_index, line in enumerate(blocks["linedef"]):
        if line_index >= 327:
            continue
        sides = [
            (side_name, integer(line, side_name))
            for side_name in ("sidefront", "sideback")
            if side_name in line
        ]
        sectors = [
            integer(blocks["sidedef"][side], "sector")
            for _, side in sides
        ]
        if wall_sector not in sectors or len(sides) != 2:
            continue
        other = [sector for sector in sectors if sector != wall_sector]
        if len(other) != 1 or other[0] in (wall_sector,):
            continue
        for _, side in sides:
            if integer(blocks["sidedef"][side], "sector") == wall_sector:
                blocks["sidedef"][side]["sector"] = str(other[0])


def add_segmented_facade(
    blocks,
    y: float,
    base_sector: int,
    interior_sector: int,
    wall_sector: int,
    inner: bool,
) -> None:
    minimum_x = -465.0 if inner else -473.0
    maximum_x = 1298.0 if inner else 1306.0
    segments = (
        (minimum_x, -361.0, wall_sector),
        (-361.0, -233.0, interior_sector),
        (-233.0, 969.0, wall_sector),
        (969.0, 1097.0, interior_sector),
        (1097.0, maximum_x, wall_sector),
    )
    for minimum, maximum, target in segments:
        # En el borde interior ambos lados de una abertura pertenecen al cuarto;
        # en el exterior, el segundo lado conserva el sector del balcón.
        other = interior_sector if inner and target == interior_sector else (
            wall_sector if inner else base_sector
        )
        add_two_sided_line(
            blocks,
            (minimum, y),
            (maximum, y),
            target if not inner else interior_sector,
            other,
        )


def add_row(
    blocks,
    north: bool,
    base_sector: int,
    interior_sector: int,
    wall_sector: int,
) -> None:
    sign = 1.0 if north else -1.0
    outer_front = 368.0 * sign
    inner_front = 376.0 * sign
    outer_back = 544.0 * sign
    inner_back = 536.0 * sign

    add_two_sided_line(
        blocks, (-473.0, outer_front), (-473.0, outer_back),
        wall_sector, base_sector,
    )
    add_two_sided_line(
        blocks, (-473.0, outer_back), (1306.0, outer_back),
        wall_sector, base_sector,
    )
    add_two_sided_line(
        blocks, (1306.0, outer_back), (1306.0, outer_front),
        wall_sector, base_sector,
    )
    add_segmented_facade(
        blocks, outer_front, base_sector, interior_sector, wall_sector, False
    )

    add_two_sided_line(
        blocks, (-465.0, inner_front), (-465.0, inner_back),
        interior_sector, wall_sector,
    )
    add_two_sided_line(
        blocks, (-465.0, inner_back), (1298.0, inner_back),
        interior_sector, wall_sector,
    )
    add_two_sided_line(
        blocks, (1298.0, inner_back), (1298.0, inner_front),
        interior_sector, wall_sector,
    )
    add_segmented_facade(
        blocks, inner_front, base_sector, interior_sector, wall_sector, True
    )

    low = min(inner_front, inner_back)
    high = max(inner_front, inner_back)
    add_divider_box(
        blocks, (32.0, low, 40.0, high), interior_sector, wall_sector
    )
    add_divider_box(
        blocks, (697.0, low, 705.0, high), interior_sector, wall_sector
    )

    # Se conserva la puerta central aceptada, centrada en la nueva profundidad.
    if north:
        add_divider_box(
            blocks, (364.0, 376.0, 372.0, 424.0),
            interior_sector, wall_sector,
        )
        add_divider_box(
            blocks, (364.0, 488.0, 372.0, 536.0),
            interior_sector, wall_sector,
        )
    else:
        add_divider_box(
            blocks, (364.0, -536.0, 372.0, -488.0),
            interior_sector, wall_sector,
        )
        add_divider_box(
            blocks, (364.0, -424.0, 372.0, -376.0),
            interior_sector, wall_sector,
        )


def move_doors(blocks) -> None:
    for thing in blocks["thing"]:
        if integer(thing, "type") != 18025:
            continue
        identifier = integer(thing, "arg0")
        if identifier in (700, 717):
            thing["y"] = "372.0"
        elif identifier in (716, 718):
            thing["y"] = "-372.0"
        elif identifier == 902:
            thing["y"] = "456.0"
        elif identifier == 905:
            thing["y"] = "-456.0"


def set_wall_cap_texture(blocks) -> None:
    controls = [
        line for line in blocks["linedef"]
        if integer(line, "special") == 160 and integer(line, "arg0") == 511
    ]
    if len(controls) != 1:
        raise ValueError("El control 3D de pared 511 no es único")
    side = integer(controls[0], "sidefront")
    sector = integer(blocks["sidedef"][side], "sector")
    blocks["sector"][sector]["textureceiling"] = '"CMCL01"'


def validate_map(blocks) -> None:
    tags = [integer(sector, "id") for sector in blocks["sector"]]
    if tags.count(510) != 1 or tags.count(511) != 1:
        raise ValueError("MAP01 no conserva un único sector 510/511")

    positions = [
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    ]
    edge_counts: defaultdict[tuple[tuple[float, float], ...], int] = defaultdict(int)
    for index, line in enumerate(blocks["linedef"]):
        if "sidefront" not in line:
            raise ValueError(f"Linedef {index} sin front sidedef")
        first, second = line_positions(blocks, line)
        if first == second:
            raise ValueError(f"Linedef {index} de longitud nula")
        edge_counts[tuple(sorted((first, second)))] += 1
    duplicates = [edge for edge, count in edge_counts.items() if count > 1]
    if duplicates:
        raise ValueError(f"Líneas coincidentes: {duplicates[:4]}")

    room_sectors = {
        index for index, tag in enumerate(tags) if tag in ROOM_TAGS
    }
    for line in blocks["linedef"]:
        if not any(
            sector in room_sectors for sector in line_sector_indices(blocks, line)
        ):
            continue
        first, second = line_positions(blocks, line)
        if min(abs(first[1]), abs(second[1])) < 368.0:
            raise ValueError("Una pared de habitación invade el pasillo")

    for first, second in (
        ((-24.0, 272.0), (95.0, 272.0)),
        ((641.0, 272.0), (760.0, 272.0)),
        ((1306.0, 272.0), (1425.0, 272.0)),
    ):
        if abs(second[0] - first[0]) != 119.0:
            raise ValueError("El ancho de escalera dejó de ser 119 MU")
        find_line(blocks, first, second)

    door_positions = {
        integer(thing, "arg0"): float(thing["y"])
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") in FRONT_DOORS + MIDDLE_DOORS
    }
    expected = {
        700: 372.0, 716: -372.0, 717: 372.0, 718: -372.0,
        902: 456.0, 905: -456.0,
    }
    if door_positions != expected:
        raise ValueError(f"Puertas del primer piso desalineadas: {door_positions}")


def is_updated(blocks) -> bool:
    positions = {
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    }
    return (-473.0, 368.0) in positions and (1298.0, 376.0) in positions


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
    if counts != (314, 395, 760, 87, 206):
        raise ValueError(f"MAP01 no coincide con la base 4.29.0l: {counts}")

    tags = [integer(sector, "id") for sector in blocks["sector"]]
    room_sector_indices = {
        index for index, tag in enumerate(tags) if tag in ROOM_TAGS
    }
    if len(room_sector_indices) != 2:
        raise ValueError("La base no tiene exactamente los sectores 510/511")
    wall_old = next(index for index in room_sector_indices if tags[index] == 511)
    north_base_old = get_base_sector(
        blocks, (-473.0, 192.0), (-473.0, 544.0), room_sector_indices
    )
    south_base_old = get_base_sector(
        blocks, (-473.0, -544.0), (-473.0, -192.0), room_sector_indices
    )

    restore_stair_sides(blocks, wall_old)
    removed_lines = {
        index for index, line in enumerate(blocks["linedef"])
        if any(
            sector in room_sector_indices
            for sector in line_sector_indices(blocks, line)
        )
    }
    if len(removed_lines) != 68:
        raise ValueError(
            f"Se esperaban 68 líneas de la hilera 4.29.0l; hay {len(removed_lines)}"
        )
    sector_map = compact_geometry(blocks, removed_lines)
    north_base = sector_map[north_base_old]
    south_base = sector_map[south_base_old]

    template = OrderedDict(
        (
            ("heightfloor", "0"),
            ("heightceiling", "30000"),
            ("texturefloor", '"FLOOR0_1"'),
            ("textureceiling", '"F_SKY1"'),
            ("lightlevel", "176"),
        )
    )
    interior = len(blocks["sector"])
    interior_sector = OrderedDict(template)
    interior_sector["id"] = "510"
    blocks["sector"].append(interior_sector)
    wall = len(blocks["sector"])
    wall_sector = OrderedDict(template)
    wall_sector["id"] = "511"
    blocks["sector"].append(wall_sector)

    add_row(blocks, True, north_base, interior, wall)
    add_row(blocks, False, south_base, interior, wall)
    move_doors(blocks)
    set_wall_cap_texture(blocks)
    validate_map(blocks)

    lumps[text_index] = (
        b"TEXTMAP", render_textmap(header, blocks).encode("utf-8")
    )
    write_wad(path, signature, lumps)
    return True


def main() -> None:
    changed = rebuild_map01()
    print(f"MAP01: {'pasillo corregido' if changed else 'ya actualizado'}")


if __name__ == "__main__":
    main()
