"""Cierra muros extremos y conecta las habitaciones superiores de MAP01.

La entrada autorizada es MAP01 4.29.0p. Las antiguas aberturas laterales de
los cuartos extremos se cierran por completo y se reemplazan por cuatro
portales de 64 MU contenidos dentro de los tramos realmente compartidos con
las habitaciones centrales en T. El divisor central aceptado y sus dos puertas
se conservan y se validan; ninguna escalera, descanso ni Thing anterior se mueve.
"""

from __future__ import annotations

from collections import OrderedDict, defaultdict
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
    split_vertical_lines,
    vertex_position,
    vertical_segments,
)
from rebuild_4_29_0p_maps import LANDINGS


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "f2fcb9c16b582ee210b7db24588923221875093b9887645fb3ef5b3acbc93fe0"
BASE_COUNTS = (448, 559, 1088, 99, 210)
UPDATED_COUNTS = (460, 575, 1120, 99, 214)

LEFT_INTERIOR = 83
LEFT_WALL = 84
LEFT_PORTAL = 85
RIGHT_INTERIOR = 92
RIGHT_WALL = 93
RIGHT_PORTAL = 94
NORTH_INTERIOR = 95
NORTH_WALL = 96
SOUTH_INTERIOR = 97
SOUTH_WALL = 98

# Portal de 64 MU y una hoja del mismo ancho. La hoja norte se oculta hacia
# Y positivo y la sur hacia Y negativo, siempre dentro de los 153 MU de pared.
CONNECTION_DOORS = (
    (-121.0, 432.0, 906, 1),
    (857.0, 432.0, 907, 1),
    (-121.0, -432.0, 908, -1),
    (857.0, -432.0, 909, -1),
)

CENTRAL_DOORS = (
    (368.0, 368.0, 902),
    (368.0, -368.0, 905),
)

DIVIDER_BOXES = (
    ((364.0, 200.0), (364.0, 336.0), (372.0, 336.0), (372.0, 200.0)),
    ((364.0, 400.0), (364.0, 536.0), (372.0, 536.0), (372.0, 400.0)),
    ((364.0, -536.0), (364.0, -400.0), (372.0, -400.0), (372.0, -536.0)),
    ((364.0, -336.0), (364.0, -200.0), (372.0, -200.0), (372.0, -336.0)),
)

OBSOLETE_CAPS = (
    ((-129.0, 304.0), (-121.0, 304.0)),
    ((-129.0, 432.0), (-121.0, 432.0)),
    ((857.0, 304.0), (865.0, 304.0)),
    ((857.0, 432.0), (865.0, 432.0)),
    ((-129.0, -432.0), (-121.0, -432.0)),
    ((-129.0, -304.0), (-121.0, -304.0)),
    ((857.0, -432.0), (865.0, -432.0)),
    ((857.0, -304.0), (865.0, -304.0)),
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
            ("angle", "0"),
            ("type", "18025"),
            ("arg0", str(group)),
            ("arg1", str(direction)),
            ("arg2", "1"),
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


def line_sector_indices(blocks, line) -> set[int]:
    return {
        integer(blocks["sidedef"][integer(line, side_name)], "sector")
        for side_name in ("sidefront", "sideback")
        if side_name in line
    }


def find_edge_indices(blocks, first, second) -> list[int]:
    expected = {first, second}
    return [
        index
        for index, line in enumerate(blocks["linedef"])
        if set(line_positions(blocks, line)) == expected
    ]


def collect_vertical_range(
    blocks,
    x: float,
    low: float,
    high: float,
) -> set[int]:
    result: set[int] = set()
    covered = 0.0
    for index, _, length in vertical_segments(blocks, x, low, high):
        result.add(index)
        covered += length
    if covered != high - low:
        raise ValueError(
            f"Cobertura vertical X={x:g}, Y={low:g}..{high:g}: "
            f"{covered:g}, esperada {high - low:g}"
        )
    return result


def add_vertical(
    blocks,
    x: float,
    first_y: float,
    second_y: float,
    front: int,
    back: int,
) -> None:
    add_two_sided_line(
        blocks,
        (x, first_y),
        (x, second_y),
        front,
        back,
    )


def add_horizontal(
    blocks,
    first_x: float,
    second_x: float,
    y: float,
    front: int,
    back: int,
) -> None:
    add_two_sided_line(
        blocks,
        (first_x, y),
        (second_x, y),
        front,
        back,
    )


def add_north_connections(blocks) -> None:
    # Cuarto extremo oeste, muro compartido y contorno interior de la T.
    add_vertical(blocks, -129.0, 304.0, 400.0, LEFT_WALL, LEFT_INTERIOR)
    add_vertical(blocks, -129.0, 400.0, 464.0, LEFT_PORTAL, LEFT_INTERIOR)
    add_vertical(blocks, -129.0, 464.0, 536.0, LEFT_WALL, LEFT_INTERIOR)
    add_vertical(blocks, -121.0, 304.0, 391.0, 37, LEFT_WALL)
    add_vertical(blocks, -121.0, 391.0, 400.0, NORTH_WALL, LEFT_WALL)
    add_vertical(blocks, -121.0, 464.0, 544.0, NORTH_WALL, LEFT_WALL)
    add_vertical(blocks, -113.0, 399.0, 400.0, NORTH_INTERIOR, NORTH_WALL)
    add_vertical(blocks, -113.0, 400.0, 464.0, NORTH_INTERIOR, LEFT_PORTAL)
    add_vertical(blocks, -113.0, 464.0, 536.0, NORTH_INTERIOR, NORTH_WALL)

    # Cuarto extremo este, reflejado sin alterar la orientación de sidedefs.
    add_vertical(blocks, 865.0, 304.0, 400.0, RIGHT_INTERIOR, RIGHT_WALL)
    add_vertical(blocks, 865.0, 400.0, 464.0, RIGHT_INTERIOR, RIGHT_PORTAL)
    add_vertical(blocks, 865.0, 464.0, 536.0, RIGHT_INTERIOR, RIGHT_WALL)
    add_vertical(blocks, 857.0, 304.0, 391.0, RIGHT_WALL, 53)
    add_vertical(blocks, 857.0, 391.0, 400.0, RIGHT_WALL, NORTH_WALL)
    add_vertical(blocks, 857.0, 464.0, 544.0, RIGHT_WALL, NORTH_WALL)
    add_vertical(blocks, 849.0, 536.0, 464.0, NORTH_INTERIOR, NORTH_WALL)
    add_vertical(blocks, 849.0, 464.0, 400.0, NORTH_INTERIOR, RIGHT_PORTAL)
    add_vertical(blocks, 849.0, 400.0, 399.0, NORTH_INTERIOR, NORTH_WALL)

    # Tapas del portal: debajo queda pared; encima comienza el hueco. En Y=464
    # se invierte la relación para cerrar el hueco contra la pared posterior.
    add_horizontal(blocks, -129.0, -121.0, 400.0, LEFT_WALL, LEFT_PORTAL)
    add_horizontal(blocks, -121.0, -113.0, 400.0, NORTH_WALL, LEFT_PORTAL)
    add_horizontal(blocks, -129.0, -121.0, 464.0, LEFT_PORTAL, LEFT_WALL)
    add_horizontal(blocks, -121.0, -113.0, 464.0, LEFT_PORTAL, NORTH_WALL)

    add_horizontal(blocks, 849.0, 857.0, 400.0, NORTH_WALL, RIGHT_PORTAL)
    add_horizontal(blocks, 857.0, 865.0, 400.0, RIGHT_WALL, RIGHT_PORTAL)
    add_horizontal(blocks, 849.0, 857.0, 464.0, RIGHT_PORTAL, NORTH_WALL)
    add_horizontal(blocks, 857.0, 865.0, 464.0, RIGHT_PORTAL, RIGHT_WALL)


def add_south_connections(blocks) -> None:
    add_vertical(blocks, -129.0, -536.0, -464.0, LEFT_WALL, LEFT_INTERIOR)
    add_vertical(blocks, -129.0, -464.0, -400.0, LEFT_PORTAL, LEFT_INTERIOR)
    add_vertical(blocks, -129.0, -400.0, -304.0, LEFT_WALL, LEFT_INTERIOR)
    add_vertical(blocks, -121.0, -544.0, -464.0, SOUTH_WALL, LEFT_WALL)
    add_vertical(blocks, -121.0, -400.0, -391.0, SOUTH_WALL, LEFT_WALL)
    add_vertical(blocks, -121.0, -391.0, -304.0, 45, LEFT_WALL)
    add_vertical(blocks, -113.0, -536.0, -464.0, SOUTH_INTERIOR, SOUTH_WALL)
    add_vertical(blocks, -113.0, -464.0, -400.0, SOUTH_INTERIOR, LEFT_PORTAL)
    add_vertical(blocks, -113.0, -400.0, -399.0, SOUTH_INTERIOR, SOUTH_WALL)

    add_vertical(blocks, 865.0, -536.0, -464.0, RIGHT_INTERIOR, RIGHT_WALL)
    add_vertical(blocks, 865.0, -464.0, -400.0, RIGHT_INTERIOR, RIGHT_PORTAL)
    add_vertical(blocks, 865.0, -400.0, -304.0, RIGHT_INTERIOR, RIGHT_WALL)
    add_vertical(blocks, 857.0, -544.0, -464.0, RIGHT_WALL, SOUTH_WALL)
    add_vertical(blocks, 857.0, -400.0, -391.0, RIGHT_WALL, SOUTH_WALL)
    add_vertical(blocks, 857.0, -391.0, -304.0, RIGHT_WALL, 57)
    add_vertical(blocks, 849.0, -399.0, -400.0, SOUTH_INTERIOR, SOUTH_WALL)
    add_vertical(blocks, 849.0, -400.0, -464.0, SOUTH_INTERIOR, RIGHT_PORTAL)
    add_vertical(blocks, 849.0, -464.0, -536.0, SOUTH_INTERIOR, SOUTH_WALL)

    add_horizontal(blocks, -129.0, -121.0, -464.0, LEFT_WALL, LEFT_PORTAL)
    add_horizontal(blocks, -121.0, -113.0, -464.0, SOUTH_WALL, LEFT_PORTAL)
    add_horizontal(blocks, -129.0, -121.0, -400.0, LEFT_PORTAL, LEFT_WALL)
    add_horizontal(blocks, -121.0, -113.0, -400.0, LEFT_PORTAL, SOUTH_WALL)

    add_horizontal(blocks, 849.0, 857.0, -464.0, SOUTH_WALL, RIGHT_PORTAL)
    add_horizontal(blocks, 857.0, 865.0, -464.0, RIGHT_WALL, RIGHT_PORTAL)
    add_horizontal(blocks, 849.0, 857.0, -400.0, RIGHT_PORTAL, SOUTH_WALL)
    add_horizontal(blocks, 857.0, 865.0, -400.0, RIGHT_PORTAL, RIGHT_WALL)


def has_door(blocks, x: float, y: float, group: int, direction: int | None = None) -> bool:
    for thing in blocks["thing"]:
        if integer(thing, "type") != 18025:
            continue
        if (
            float(thing["x"]) == x
            and float(thing["y"]) == y
            and float(thing.get("height", "0")) == 136.0
            and integer(thing, "arg0") == group
            and integer(thing, "arg2") == 1
            and (direction is None or integer(thing, "arg1") == direction)
        ):
            return True
    return False


def validate_dividers(blocks) -> None:
    for points in DIVIDER_BOXES:
        for index, first in enumerate(points):
            second = points[(index + 1) % len(points)]
            matches = find_edge_indices(blocks, first, second)
            if len(matches) != 1:
                raise ValueError(f"Divisor central incompleto: {first} -> {second}")

    for x, y, group in CENTRAL_DOORS:
        if not has_door(blocks, x, y, group):
            raise ValueError(f"Falta la puerta central {group}")


def validate_landings(blocks) -> None:
    for minimum_x, minimum_y, maximum_x, maximum_y in LANDINGS:
        if maximum_x - minimum_x != 119.0 or maximum_y - minimum_y != 119.0:
            raise ValueError("Un descanso dejó de medir 119x119 MU")
        for line in blocks["linedef"]:
            first, second = line_positions(blocks, line)
            midpoint = ((first[0] + second[0]) * 0.5, (first[1] + second[1]) * 0.5)
            if (
                minimum_x < midpoint[0] < maximum_x
                and minimum_y < midpoint[1] < maximum_y
            ):
                raise ValueError("Una línea invade un descanso de escalera")


def validate_references(blocks) -> None:
    positions = [
        vertex_position(blocks, index) for index in range(len(blocks["vertex"]))
    ]
    edge_counts: defaultdict[tuple[tuple[float, float], ...], int] = defaultdict(int)
    side_usage: defaultdict[int, int] = defaultdict(int)
    for index, line in enumerate(blocks["linedef"]):
        if "sidefront" not in line:
            raise ValueError(f"Linedef {index} sin front sidedef")
        first = positions[integer(line, "v1")]
        second = positions[integer(line, "v2")]
        if first == second:
            raise ValueError(f"Linedef {index} de longitud nula")
        edge_counts[tuple(sorted((first, second)))] += 1
        for side_name in ("sidefront", "sideback"):
            if side_name not in line:
                continue
            side = integer(line, side_name)
            if not 0 <= side < len(blocks["sidedef"]):
                raise ValueError(f"Linedef {index} referencia sidedef inválido")
            side_usage[side] += 1
            sector = integer(blocks["sidedef"][side], "sector")
            if not 0 <= sector < len(blocks["sector"]):
                raise ValueError(f"Sidedef {side} referencia sector inválido")

    duplicates = [edge for edge, count in edge_counts.items() if count > 1]
    if duplicates:
        raise ValueError(f"Líneas coincidentes: {duplicates[:4]}")
    shared = [side for side, count in side_usage.items() if count != 1]
    if shared:
        raise ValueError(f"Sidedefs compartidos o huérfanos: {shared[:4]}")


def validate_closed_sector(blocks, sector_index: int) -> None:
    degree: defaultdict[tuple[float, float], int] = defaultdict(int)
    for line in blocks["linedef"]:
        if sector_index not in line_sector_indices(blocks, line):
            continue
        first, second = line_positions(blocks, line)
        degree[first] += 1
        degree[second] += 1
    failures = {point: value for point, value in degree.items() if value != 2}
    if not degree or failures:
        raise ValueError(
            f"Sector superior {sector_index} no cierra sus contornos: {failures}"
        )


def validate_connections(blocks) -> None:
    for x, y, group, direction in CONNECTION_DOORS:
        if not has_door(blocks, x, y, group, direction):
            raise ValueError(f"Falta la puerta de conexión {group}")

    # En el centro de cada abertura no puede quedar un linedef compartido: el
    # portal 510 atraviesa las dos paredes y la hoja móvil aporta el bloqueo.
    for x in (-121.0, 857.0):
        for low, high in ((400.0, 464.0), (-464.0, -400.0)):
            for _, line, _ in vertical_segments(blocks, x, low, high):
                first, second = line_positions(blocks, line)
                midpoint = (first[1] + second[1]) * 0.5
                if low < midpoint < high:
                    raise ValueError(f"La abertura X={x:g} conserva una pared")

    required_edges = (
        ((-129.0, 400.0), (-121.0, 400.0)),
        ((-121.0, 400.0), (-113.0, 400.0)),
        ((849.0, 400.0), (857.0, 400.0)),
        ((857.0, 400.0), (865.0, 400.0)),
        ((-129.0, 464.0), (-121.0, 464.0)),
        ((-121.0, 464.0), (-113.0, 464.0)),
        ((849.0, 464.0), (857.0, 464.0)),
        ((857.0, 464.0), (865.0, 464.0)),
        ((-129.0, -464.0), (-121.0, -464.0)),
        ((-121.0, -464.0), (-113.0, -464.0)),
        ((849.0, -464.0), (857.0, -464.0)),
        ((857.0, -464.0), (865.0, -464.0)),
        ((-129.0, -400.0), (-121.0, -400.0)),
        ((-121.0, -400.0), (-113.0, -400.0)),
        ((849.0, -400.0), (857.0, -400.0)),
        ((857.0, -400.0), (865.0, -400.0)),
    )
    for first, second in required_edges:
        if len(find_edge_indices(blocks, first, second)) != 1:
            raise ValueError(f"Portal incompleto: {first} -> {second}")


def validate_map(blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if UPDATED_COUNTS is not None and counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0q inesperada: {counts}")

    ids = [integer(sector, "id") for sector in blocks["sector"]]
    if ids.count(510) != 6 or ids.count(511) != 4:
        raise ValueError(
            f"Sectores de planta alta inesperados: 510={ids.count(510)}, "
            f"511={ids.count(511)}"
        )

    controls = [
        line
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in (510, 511)
    ]
    tags = [integer(line, "arg0") for line in controls]
    if tags.count(510) != 2 or tags.count(511) != 1:
        raise ValueError("Los controles 3D 510/511 cambiaron")

    validate_references(blocks)
    for sector_index in (
        LEFT_INTERIOR,
        LEFT_WALL,
        LEFT_PORTAL,
        RIGHT_INTERIOR,
        RIGHT_WALL,
        RIGHT_PORTAL,
        NORTH_INTERIOR,
        NORTH_WALL,
        SOUTH_INTERIOR,
        SOUTH_WALL,
    ):
        validate_closed_sector(blocks, sector_index)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)


def is_updated(blocks) -> bool:
    return all(
        has_door(blocks, x, y, group, direction)
        for x, y, group, direction in CONNECTION_DOORS
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
            f"MAP01 no coincide con la base aceptada 4.29.0p: {counts}, {digest}"
        )

    vertical_cuts = (-544.0, -536.0, -464.0, -432.0, -400.0, -399.0,
                     -391.0, -304.0, 304.0, 391.0, 399.0, 400.0, 432.0,
                     464.0, 536.0, 544.0)
    for x in (-129.0, -121.0, -113.0, 849.0, 857.0, 865.0):
        split_vertical_lines(blocks, x, vertical_cuts)

    removed_lines: set[int] = set()
    for x, low, high in (
        (-129.0, 304.0, 536.0),
        (-121.0, 304.0, 544.0),
        (-113.0, 399.0, 536.0),
        (849.0, 399.0, 536.0),
        (857.0, 304.0, 544.0),
        (865.0, 304.0, 536.0),
        (-129.0, -536.0, -304.0),
        (-121.0, -544.0, -304.0),
        (-113.0, -536.0, -399.0),
        (849.0, -536.0, -399.0),
        (857.0, -544.0, -304.0),
        (865.0, -536.0, -304.0),
    ):
        removed_lines.update(collect_vertical_range(blocks, x, low, high))

    for first, second in OBSOLETE_CAPS:
        matches = find_edge_indices(blocks, first, second)
        if len(matches) != 1:
            raise ValueError(f"Abertura antigua inesperada: {first} -> {second}")
        removed_lines.add(matches[0])

    add_north_connections(blocks)
    add_south_connections(blocks)
    blocks["thing"].extend(
        make_door(x, y, group, direction)
        for x, y, group, direction in CONNECTION_DOORS
    )

    compact_geometry(blocks, removed_lines)
    validate_map(blocks)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)
    return True


def main() -> None:
    changed = rebuild_map01()
    print(
        "MAP01: "
        + ("muros extremos y cuatro puertas conectados" if changed else "ya actualizado")
    )


if __name__ == "__main__":
    main()
