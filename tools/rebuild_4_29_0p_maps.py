"""Reconstruye las dos habitaciones centrales superiores de MAP01 para 4.29.0p.

La entrada autorizada es el MAP01 limpio de 4.29.0n (idéntico a 4.29.0i).
No fusiona los cuatro bloques de 4.29.0o: elimina por completo los contornos
centrales anteriores y crea dos habitaciones continuas en forma de T. Cada T
absorbe las dos alas traseras, conserva descansos de escalera de 119x119 MU y
recupera el divisor central con su abertura de puerta de 64 MU.
"""

from __future__ import annotations

from collections import defaultdict
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
    attach_closed_side,
    collect_carved_lines,
    compact_geometry,
    find_edge,
    line_positions,
    split_vertical_lines,
    vertex_position,
    vertical_segments,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "73c2983e7c94bd357218f2bc64487431a10e7c72ffe6e9c786f7f2630012e9f2"
BASE_COUNTS = (398, 489, 948, 99, 210)
UPDATED_COUNTS = (448, 559, 1088, 99, 210)

# Índices estables en la base validada. Se reutilizan en vez de añadir sectores:
# el suelo transitable conserva tag 510 y el volumen vertical conserva tag 511.
NORTH_INTERIOR = 95
NORTH_WALL = 96
SOUTH_INTERIOR = 97
SOUTH_WALL = 98
CENTRAL_SECTORS = {
    NORTH_INTERIOR,
    NORTH_WALL,
    SOUTH_INTERIOR,
    SOUTH_WALL,
}

LANDINGS = (
    (-24.0, 272.0, 95.0, 391.0),
    (641.0, 272.0, 760.0, 391.0),
    (-24.0, -391.0, 95.0, -272.0),
    (641.0, -391.0, 760.0, -272.0),
)

# Segmentación de los sectores base bajo la barra posterior de cada T. Los
# intervalos de una unidad pertenecen a los muros laterales de las escaleras.
BREAKS = (
    -121.0,
    -25.0,
    -24.0,
    95.0,
    96.0,
    192.0,
    544.0,
    640.0,
    641.0,
    760.0,
    761.0,
    857.0,
)
NORTH_BASES = (37, 0, 72, 0, 41, 41, 41, 0, 74, 0, 53)
SOUTH_BASES = (45, 0, 76, 0, 49, 49, 49, 0, 78, 0, 57)
INTERNAL_VERTICALS = (-25.0, -24.0, 95.0, 96.0, 640.0, 641.0, 760.0, 761.0)

NORTH_OUTER = (
    (544.0, 192.0),
    (192.0, 192.0),
    (192.0, 391.0),
    (-121.0, 391.0),
    (-121.0, 544.0),
    (857.0, 544.0),
    (857.0, 391.0),
    (544.0, 391.0),
)
NORTH_INNER = (
    (536.0, 200.0),
    (200.0, 200.0),
    (200.0, 399.0),
    (-113.0, 399.0),
    (-113.0, 536.0),
    (849.0, 536.0),
    (849.0, 399.0),
    (536.0, 399.0),
)
SOUTH_OUTER = (
    (544.0, -544.0),
    (192.0, -544.0),
    (-121.0, -544.0),
    (-121.0, -391.0),
    (192.0, -391.0),
    (192.0, -192.0),
    (544.0, -192.0),
    (544.0, -391.0),
    (857.0, -391.0),
    (857.0, -544.0),
)
SOUTH_INNER = (
    (536.0, -536.0),
    (200.0, -536.0),
    (-113.0, -536.0),
    (-113.0, -399.0),
    (200.0, -399.0),
    (200.0, -200.0),
    (536.0, -200.0),
    (536.0, -399.0),
    (849.0, -399.0),
    (849.0, -536.0),
)


def line_sector_indices(blocks, line) -> set[int]:
    return {
        integer(blocks["sidedef"][integer(line, side_name)], "sector")
        for side_name in ("sidefront", "sideback")
        if side_name in line
    }


def add_polygon(blocks, points, front: int, back: int) -> None:
    for index, first in enumerate(points):
        add_two_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            front,
            back,
        )


def add_segmented_horizontal(
    blocks,
    y: float,
    first_x: float,
    second_x: float,
    wall: int,
    bases: tuple[int, ...],
) -> None:
    """Añade un tramo siguiendo BREAKS y conserva su dirección solicitada."""

    increasing = second_x > first_x
    segments = [
        (start, end, base)
        for start, end, base in zip(BREAKS[:-1], BREAKS[1:], bases)
        if start >= min(first_x, second_x) and end <= max(first_x, second_x)
    ]
    if not increasing:
        segments.reverse()
    for start, end, base in segments:
        if increasing:
            add_two_sided_line(blocks, (start, y), (end, y), wall, base)
        else:
            add_two_sided_line(blocks, (end, y), (start, y), wall, base)


def add_north_outer(blocks) -> None:
    # Contorno horario. Los flancos exteriores X=-121 y X=857 ya pertenecen
    # a las habitaciones laterales y sólo reciben el nuevo sector al dorso.
    add_two_sided_line(
        blocks, (544.0, 192.0), (192.0, 192.0), NORTH_WALL, 41
    )
    add_two_sided_line(
        blocks, (192.0, 192.0), (192.0, 391.0), NORTH_WALL, 41
    )
    add_segmented_horizontal(
        blocks, 391.0, 192.0, -121.0, NORTH_WALL, NORTH_BASES
    )
    add_segmented_horizontal(
        blocks, 544.0, -121.0, 857.0, NORTH_WALL, NORTH_BASES
    )
    add_segmented_horizontal(
        blocks, 391.0, 857.0, 544.0, NORTH_WALL, NORTH_BASES
    )
    add_two_sided_line(
        blocks, (544.0, 391.0), (544.0, 192.0), NORTH_WALL, 41
    )


def add_south_outer(blocks) -> None:
    # Reflejo horario del contorno norte.
    add_segmented_horizontal(
        blocks, -544.0, 857.0, -121.0, SOUTH_WALL, SOUTH_BASES
    )
    add_segmented_horizontal(
        blocks, -391.0, -121.0, 192.0, SOUTH_WALL, SOUTH_BASES
    )
    add_two_sided_line(
        blocks, (192.0, -391.0), (192.0, -192.0), SOUTH_WALL, 49
    )
    add_two_sided_line(
        blocks, (192.0, -192.0), (544.0, -192.0), SOUTH_WALL, 49
    )
    add_two_sided_line(
        blocks, (544.0, -192.0), (544.0, -391.0), SOUTH_WALL, 49
    )
    add_segmented_horizontal(
        blocks, -391.0, 544.0, 857.0, SOUTH_WALL, SOUTH_BASES
    )


def add_dividers(blocks) -> None:
    # Se conserva exactamente la abertura de puerta central de 64 MU.
    for points, interior, wall in (
        (
            ((364.0, 200.0), (364.0, 336.0), (372.0, 336.0), (372.0, 200.0)),
            NORTH_INTERIOR,
            NORTH_WALL,
        ),
        (
            ((364.0, 400.0), (364.0, 536.0), (372.0, 536.0), (372.0, 400.0)),
            NORTH_INTERIOR,
            NORTH_WALL,
        ),
        (
            ((364.0, -536.0), (364.0, -400.0), (372.0, -400.0), (372.0, -536.0)),
            SOUTH_INTERIOR,
            SOUTH_WALL,
        ),
        (
            ((364.0, -336.0), (364.0, -200.0), (372.0, -200.0), (372.0, -336.0)),
            SOUTH_INTERIOR,
            SOUTH_WALL,
        ),
    ):
        add_polygon(blocks, points, wall, interior)


def validate_landings(blocks) -> None:
    for minimum_x, minimum_y, maximum_x, maximum_y in LANDINGS:
        if maximum_x - minimum_x != 119.0 or maximum_y - minimum_y != 119.0:
            raise ValueError("Un descanso dejó de medir 119x119 MU")
        stair_y = minimum_y if minimum_y > 0.0 else maximum_y
        if len(find_edge(blocks, (minimum_x, stair_y), (maximum_x, stair_y))) != 1:
            raise ValueError("El borde superior de una escalera cambió")
        for line in blocks["linedef"]:
            first, second = line_positions(blocks, line)
            midpoint = ((first[0] + second[0]) * 0.5, (first[1] + second[1]) * 0.5)
            if (
                minimum_x < midpoint[0] < maximum_x
                and minimum_y < midpoint[1] < maximum_y
            ):
                raise ValueError("Una línea invade el descanso de escalera")


def validate_closed_sector(blocks, sector_index: int) -> None:
    degree: defaultdict[tuple[float, float], int] = defaultdict(int)
    for line in blocks["linedef"]:
        if sector_index not in line_sector_indices(blocks, line):
            continue
        first, second = line_positions(blocks, line)
        degree[first] += 1
        degree[second] += 1
    if not degree or any(value != 2 for value in degree.values()):
        failures = {point: value for point, value in degree.items() if value != 2}
        raise ValueError(
            f"Sector central {sector_index} no cierra sus contornos: {failures}"
        )


def validate_map(blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0p inesperada: {counts}")

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

    for sector_index in CENTRAL_SECTORS:
        validate_closed_sector(blocks, sector_index)

    required_points = set(NORTH_OUTER + NORTH_INNER + SOUTH_OUTER + SOUTH_INNER)
    missing = required_points.difference(positions)
    if missing:
        raise ValueError(f"Contorno central incompleto: {sorted(missing)[:4]}")

    for x in INTERNAL_VERTICALS:
        for low, high in ((391.0, 544.0), (-544.0, -391.0)):
            for _, line, _ in vertical_segments(blocks, x, low, high):
                first, second = line_positions(blocks, line)
                midpoint = (first[1] + second[1]) * 0.5
                if low < midpoint < high:
                    raise ValueError(f"Quedó una división base en X={x:g}")

    validate_landings(blocks)


def is_updated(blocks) -> bool:
    positions = {
        vertex_position(blocks, index) for index in range(len(blocks["vertex"]))
    }
    return (
        (-113.0, 399.0) in positions
        and (849.0, 399.0) in positions
        and (-113.0, -399.0) in positions
        and (849.0, -399.0) in positions
        and not find_edge(blocks, (192.0, 391.0), (192.0, 544.0))
        and not find_edge(blocks, (544.0, 391.0), (544.0, 544.0))
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
            f"MAP01 no coincide con la base limpia 4.29.0n: {counts}, {digest}"
        )

    # Crear cortes exactos antes de tocar índices. Las cuatro líneas internas
    # de cada descanso se retiran únicamente dentro de la barra posterior.
    for x in (-121.0, 857.0, *INTERNAL_VERTICALS):
        split_vertical_lines(blocks, x, (-544.0, -391.0, 391.0, 544.0))

    removed_lines = {
        index
        for index, line in enumerate(blocks["linedef"])
        if line_sector_indices(blocks, line) & CENTRAL_SECTORS
    }
    if len(removed_lines) != 32:
        raise ValueError(
            f"La habitación central base no conserva sus 32 líneas: {len(removed_lines)}"
        )

    attach_closed_side(blocks, -121.0, 391.0, 544.0, NORTH_WALL)
    attach_closed_side(blocks, 857.0, 391.0, 544.0, NORTH_WALL)
    attach_closed_side(blocks, -121.0, -544.0, -391.0, SOUTH_WALL)
    attach_closed_side(blocks, 857.0, -544.0, -391.0, SOUTH_WALL)

    for x in INTERNAL_VERTICALS:
        removed_lines.update(collect_carved_lines(blocks, x, 391.0, 544.0))
        removed_lines.update(collect_carved_lines(blocks, x, -544.0, -391.0))

    add_north_outer(blocks)
    add_polygon(blocks, NORTH_INNER, NORTH_INTERIOR, NORTH_WALL)
    add_south_outer(blocks)
    add_polygon(blocks, SOUTH_INNER, SOUTH_INTERIOR, SOUTH_WALL)
    add_dividers(blocks)

    compact_geometry(blocks, removed_lines)
    validate_map(blocks)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)
    return True


def main() -> None:
    print(
        "MAP01: constructor 4.29.0p obsoleto; usa rebuild_4_29_0q_maps.py"
    )


if __name__ == "__main__":
    main()
