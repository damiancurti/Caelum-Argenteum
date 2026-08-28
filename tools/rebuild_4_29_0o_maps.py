"""Añade cuatro bloques independientes al primer piso de MAP01.

La base autorizada es MAP01 4.29.0n, idéntica a 4.29.0i. Cada bloque ocupa
todo el ancho entre dos habitaciones existentes, pero comienza 119 MU después
del último peldaño. De este modo cada escalera interior conserva un descanso
cuadrado de 119x119 MU y ningún pasillo, escalera o habitación se desplaza.
Las piezas quedan cerradas: sus conexiones se decidirán en otro parche.
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


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "73c2983e7c94bd357218f2bc64487431a10e7c72ffe6e9c786f7f2630012e9f2"
BASE_COUNTS = (398, 489, 948, 99, 210)
UPDATED_COUNTS = (454, 569, 1108, 107, 210)
ROOM_TAGS = (510, 511)

# nombre, contorno exterior, cortes X y sectores base por intervalo.
# Los índices son estables porque el hash de entrada se valida antes de editar.
BLOCKS = (
    (
        "noroeste",
        (-121.0, 391.0, 192.0, 544.0),
        (-121.0, -25.0, -24.0, 95.0, 96.0, 192.0),
        (37, 0, 72, 0, 41),
    ),
    (
        "noreste",
        (544.0, 391.0, 857.0, 544.0),
        (544.0, 640.0, 641.0, 760.0, 761.0, 857.0),
        (41, 0, 74, 0, 53),
    ),
    (
        "sudoeste",
        (-121.0, -544.0, 192.0, -391.0),
        (-121.0, -25.0, -24.0, 95.0, 96.0, 192.0),
        (45, 0, 76, 0, 49),
    ),
    (
        "sudeste",
        (544.0, -544.0, 857.0, -391.0),
        (544.0, 640.0, 641.0, 760.0, 761.0, 857.0),
        (49, 0, 78, 0, 57),
    ),
)

INTERNAL_VERTICALS = {
    "noroeste": (-25.0, -24.0, 95.0, 96.0),
    "noreste": (640.0, 641.0, 760.0, 761.0),
    "sudoeste": (-25.0, -24.0, 95.0, 96.0),
    "sudeste": (640.0, 641.0, 760.0, 761.0),
}

LANDINGS = (
    (-24.0, 272.0, 95.0, 391.0),
    (641.0, 272.0, 760.0, 391.0),
    (-24.0, -391.0, 95.0, -272.0),
    (641.0, -391.0, 760.0, -272.0),
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


def make_room_sector(identifier: int) -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("heightfloor", "0"),
            ("heightceiling", "30000"),
            ("texturefloor", '"FLOOR0_1"'),
            ("textureceiling", '"F_SKY1"'),
            ("lightlevel", "176"),
            ("id", str(identifier)),
        )
    )


def vertex_position(blocks, index: int) -> tuple[float, float]:
    vertex = blocks["vertex"][index]
    return float(vertex["x"]), float(vertex["y"])


def line_positions(blocks, line) -> tuple[tuple[float, float], tuple[float, float]]:
    return (
        vertex_position(blocks, integer(line, "v1")),
        vertex_position(blocks, integer(line, "v2")),
    )


def get_or_add_vertex(blocks, point: tuple[float, float]) -> int:
    for index, vertex in enumerate(blocks["vertex"]):
        if (float(vertex["x"]), float(vertex["y"])) == point:
            return index
    blocks["vertex"].append(make_vertex(*point))
    return len(blocks["vertex"]) - 1


def clone_side(blocks, side_index: int) -> int:
    blocks["sidedef"].append(OrderedDict(blocks["sidedef"][side_index]))
    return len(blocks["sidedef"]) - 1


def clone_line_segment(blocks, source, first, second) -> None:
    line = OrderedDict(source)
    line["v1"] = str(get_or_add_vertex(blocks, first))
    line["v2"] = str(get_or_add_vertex(blocks, second))
    for side_name in ("sidefront", "sideback"):
        if side_name in line:
            line[side_name] = str(
                clone_side(blocks, integer(source, side_name))
            )
    blocks["linedef"].append(line)


def split_vertical_lines(blocks, x: float, cuts: tuple[float, ...]) -> None:
    original_count = len(blocks["linedef"])
    for index in range(original_count):
        line = blocks["linedef"][index]
        first, second = line_positions(blocks, line)
        if first[0] != x or second[0] != x or first[1] == second[1]:
            continue
        low = min(first[1], second[1])
        high = max(first[1], second[1])
        applicable = sorted(cut for cut in cuts if low < cut < high)
        if not applicable:
            continue

        ordered = applicable if first[1] < second[1] else list(reversed(applicable))
        points = [first] + [(x, cut) for cut in ordered] + [second]
        line["v1"] = str(get_or_add_vertex(blocks, points[0]))
        line["v2"] = str(get_or_add_vertex(blocks, points[1]))
        for segment in range(1, len(points) - 1):
            clone_line_segment(
                blocks,
                line,
                points[segment],
                points[segment + 1],
            )


def sector_id(blocks, side_index: int) -> int | None:
    sector = integer(blocks["sidedef"][side_index], "sector")
    return integer(blocks["sector"][sector], "id")


def vertical_segments(blocks, x: float, low: float, high: float):
    for index, line in enumerate(blocks["linedef"]):
        first, second = line_positions(blocks, line)
        if first[0] != x or second[0] != x:
            continue
        segment_low = min(first[1], second[1])
        segment_high = max(first[1], second[1])
        if segment_low >= low and segment_high <= high and segment_low < segment_high:
            yield index, line, segment_high - segment_low


def attach_closed_side(blocks, x: float, low: float, high: float, wall: int) -> None:
    covered = 0.0
    for _, line, length in vertical_segments(blocks, x, low, high):
        candidates = []
        for side_name in ("sidefront", "sideback"):
            if side_name not in line:
                continue
            side = integer(line, side_name)
            if sector_id(blocks, side) not in ROOM_TAGS:
                candidates.append(side)
        if len(candidates) != 1:
            raise ValueError(
                f"Borde X={x:g}, Y={low:g}..{high:g}: lado base ambiguo"
            )
        blocks["sidedef"][candidates[0]]["sector"] = str(wall)
        covered += length
    if covered != high - low:
        raise ValueError(
            f"Borde X={x:g}: cobertura {covered:g}, esperada {high - low:g}"
        )


def collect_carved_lines(blocks, x: float, low: float, high: float) -> set[int]:
    result = set()
    covered = 0.0
    for index, _, length in vertical_segments(blocks, x, low, high):
        result.add(index)
        covered += length
    if covered != high - low:
        raise ValueError(
            f"Corte X={x:g}: cobertura {covered:g}, esperada {high - low:g}"
        )
    return result


def add_two_sided_line(blocks, first, second, front: int, back: int) -> None:
    start = get_or_add_vertex(blocks, first)
    end = get_or_add_vertex(blocks, second)
    if start == end:
        raise ValueError(f"Línea nula solicitada en {first}")
    sidefront = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(front))
    sideback = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(back))
    blocks["linedef"].append(
        OrderedDict(
            (
                ("v1", str(start)),
                ("v2", str(end)),
                ("sidefront", str(sidefront)),
                ("sideback", str(sideback)),
                ("twosided", "true"),
            )
        )
    )


def add_inner_contour(blocks, outer, interior: int, wall: int) -> None:
    minimum_x, minimum_y, maximum_x, maximum_y = outer
    points = (
        (minimum_x + 8.0, minimum_y + 8.0),
        (minimum_x + 8.0, maximum_y - 8.0),
        (maximum_x - 8.0, maximum_y - 8.0),
        (maximum_x - 8.0, minimum_y + 8.0),
    )
    for index, first in enumerate(points):
        add_two_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            interior,
            wall,
        )


def add_horizontal_boundaries(blocks, outer, breaks, bases, wall: int) -> None:
    minimum_x, minimum_y, maximum_x, maximum_y = outer
    segments = list(zip(breaks[:-1], breaks[1:], bases))
    north = minimum_y > 0.0
    if north:
        # Contorno horario: fondo hacia el este y frente hacia el oeste.
        for first, second, base in segments:
            add_two_sided_line(
                blocks, (first, maximum_y), (second, maximum_y), wall, base
            )
        for first, second, base in reversed(segments):
            add_two_sided_line(
                blocks, (second, minimum_y), (first, minimum_y), wall, base
            )
    else:
        # Reflejo horario: frente hacia el este y fondo hacia el oeste.
        for first, second, base in segments:
            add_two_sided_line(
                blocks, (first, maximum_y), (second, maximum_y), wall, base
            )
        for first, second, base in reversed(segments):
            add_two_sided_line(
                blocks, (second, minimum_y), (first, minimum_y), wall, base
            )

    if breaks[0] != minimum_x or breaks[-1] != maximum_x:
        raise ValueError("Los cortes horizontales no cubren el bloque")


def compact_geometry(blocks, removed_lines: set[int]) -> None:
    lines = blocks["linedef"]
    sides = blocks["sidedef"]
    vertices = blocks["vertex"]
    sectors = blocks["sector"]

    removed_sides = {
        integer(lines[index], side_name)
        for index in removed_lines
        for side_name in ("sidefront", "sideback")
        if side_name in lines[index]
    }
    kept_sides = [index for index in range(len(sides)) if index not in removed_sides]
    side_map = {old: new for new, old in enumerate(kept_sides)}

    rebuilt_lines = []
    for index, line in enumerate(lines):
        if index in removed_lines:
            continue
        line["sidefront"] = str(side_map[integer(line, "sidefront")])
        if "sideback" in line:
            line["sideback"] = str(side_map[integer(line, "sideback")])
        rebuilt_lines.append(line)
    blocks["linedef"] = rebuilt_lines
    blocks["sidedef"] = [sides[index] for index in kept_sides]

    used_vertices = {
        integer(line, field)
        for line in blocks["linedef"]
        for field in ("v1", "v2")
    }
    kept_vertices = [
        index for index in range(len(vertices)) if index in used_vertices
    ]
    vertex_map = {old: new for new, old in enumerate(kept_vertices)}
    for line in blocks["linedef"]:
        line["v1"] = str(vertex_map[integer(line, "v1")])
        line["v2"] = str(vertex_map[integer(line, "v2")])
    blocks["vertex"] = [vertices[index] for index in kept_vertices]

    used_sectors = {integer(side, "sector") for side in blocks["sidedef"]}
    kept_sectors = [index for index in range(len(sectors)) if index in used_sectors]
    sector_map = {old: new for new, old in enumerate(kept_sectors)}
    for side in blocks["sidedef"]:
        side["sector"] = str(sector_map[integer(side, "sector")])
    blocks["sector"] = [sectors[index] for index in kept_sectors]


def find_edge(blocks, first, second):
    expected = {first, second}
    return [
        line
        for line in blocks["linedef"]
        if set(line_positions(blocks, line)) == expected
    ]


def validate_landings(blocks) -> None:
    for minimum_x, minimum_y, maximum_x, maximum_y in LANDINGS:
        if maximum_x - minimum_x != 119.0 or maximum_y - minimum_y != 119.0:
            raise ValueError("Un descanso dejó de medir 119x119 MU")
        stair_y = minimum_y if minimum_y > 0.0 else maximum_y
        if len(find_edge(blocks, (minimum_x, stair_y), (maximum_x, stair_y))) != 1:
            raise ValueError("El borde superior de una escalera cambió")

        for line in blocks["linedef"]:
            first, second = line_positions(blocks, line)
            midpoint = (
                (first[0] + second[0]) * 0.5,
                (first[1] + second[1]) * 0.5,
            )
            if (
                minimum_x < midpoint[0] < maximum_x
                and minimum_y < midpoint[1] < maximum_y
            ):
                raise ValueError("Una línea invade el descanso de escalera")


def validate_map(blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0o inesperada: {counts}")

    ids = [integer(sector, "id") for sector in blocks["sector"]]
    if ids.count(510) != 10 or ids.count(511) != 8:
        raise ValueError(
            f"Sectores de planta alta inesperados: 510={ids.count(510)}, "
            f"511={ids.count(511)}"
        )

    controls = [
        line
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in ROOM_TAGS
    ]
    tags = [integer(line, "arg0") for line in controls]
    if tags.count(510) != 2 or tags.count(511) != 1:
        raise ValueError("Los controles 3D 510/511 cambiaron")

    positions = [vertex_position(blocks, index) for index in range(len(blocks["vertex"]))]
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

    # Cada sector nuevo debe conservar un único contorno cerrado. Esta prueba
    # evita que una futura edición repita los huecos de los prototipos
    # rechazados aunque todas las referencias sigan dentro de rango.
    expected_new_ids = (510, 511, 510, 511, 510, 511, 510, 511)
    for offset, expected_id in enumerate(expected_new_ids):
        sector_index = 99 + offset
        if integer(blocks["sector"][sector_index], "id") != expected_id:
            raise ValueError(f"Sector nuevo {sector_index} perdió su etiqueta")
        degree: defaultdict[tuple[float, float], int] = defaultdict(int)
        for line in blocks["linedef"]:
            belongs = any(
                side_name in line
                and integer(
                    blocks["sidedef"][integer(line, side_name)], "sector"
                ) == sector_index
                for side_name in ("sidefront", "sideback")
            )
            if belongs:
                first, second = line_positions(blocks, line)
                degree[first] += 1
                degree[second] += 1
        if not degree or any(value != 2 for value in degree.values()):
            raise ValueError(f"Sector nuevo {sector_index} no forma un contorno cerrado")

    for name, outer, _, _ in BLOCKS:
        minimum_x, minimum_y, maximum_x, maximum_y = outer
        for x in INTERNAL_VERTICALS[name]:
            for _, line, _ in vertical_segments(
                blocks, x, minimum_y, maximum_y
            ):
                first, second = line_positions(blocks, line)
                midpoint = (first[1] + second[1]) * 0.5
                if minimum_y < midpoint < maximum_y:
                    raise ValueError(f"{name}: quedó una división base en X={x:g}")

        inner = (
            (minimum_x + 8.0, minimum_y + 8.0),
            (minimum_x + 8.0, maximum_y - 8.0),
            (maximum_x - 8.0, maximum_y - 8.0),
            (maximum_x - 8.0, minimum_y + 8.0),
        )
        if not all(point in positions for point in inner):
            raise ValueError(f"{name}: contorno interior incompleto")

    validate_landings(blocks)


def is_updated(blocks) -> bool:
    ids = [integer(sector, "id") for sector in blocks["sector"]]
    positions = {
        vertex_position(blocks, index) for index in range(len(blocks["vertex"]))
    }
    return (
        ids.count(510) == 10
        and ids.count(511) == 8
        and (-113.0, 399.0) in positions
        and (849.0, -399.0) in positions
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
            f"MAP01 no coincide con la base 4.29.0n: {counts}, {digest}"
        )

    cut_values = (-544.0, -391.0, 391.0, 544.0)
    all_verticals = sorted(
        {
            value
            for name, outer, _, _ in BLOCKS
            for value in (
                outer[0],
                outer[2],
                *INTERNAL_VERTICALS[name],
            )
        }
    )
    for x in all_verticals:
        split_vertical_lines(blocks, x, cut_values)

    removed_lines: set[int] = set()
    for name, outer, breaks, bases in BLOCKS:
        minimum_x, minimum_y, maximum_x, maximum_y = outer
        interior = len(blocks["sector"])
        blocks["sector"].append(make_room_sector(510))
        wall = len(blocks["sector"])
        blocks["sector"].append(make_room_sector(511))

        attach_closed_side(
            blocks, minimum_x, minimum_y, maximum_y, wall
        )
        attach_closed_side(
            blocks, maximum_x, minimum_y, maximum_y, wall
        )
        for x in INTERNAL_VERTICALS[name]:
            removed_lines.update(
                collect_carved_lines(
                    blocks, x, minimum_y, maximum_y
                )
            )

        add_horizontal_boundaries(blocks, outer, breaks, bases, wall)
        add_inner_contour(blocks, outer, interior, wall)

    compact_geometry(blocks, removed_lines)
    validate_map(blocks)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)
    return True


def main() -> None:
    print(
        "MAP01: constructor 4.29.0o obsoleto; usa rebuild_4_29_0p_maps.py"
    )


if __name__ == "__main__":
    main()
