"""Une las hileras del primer piso de MAP01 para V4.29.0l.

Las seis envolventes anteriores se sustituyen por dos sectores continuos, uno
al norte y otro al sur. Cada hilera conserva el balcón frontal de 96 MU y se
ensancha solamente detrás de los tres desembarcos de escalera de 119 MU. Las
paredes son sectores nativos tag 511; la losa transitable conserva tag 510.
No se abren conexiones laterales en esta etapa.
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


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
ROOM_TAGS = (510, 511)
OBSOLETE_SIDE_DOORS = (900, 901, 903, 904)
STAIR_X = (-24.0, 95.0, 641.0, 760.0, 1306.0)


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


def sector_id(blocks, side_index: int) -> int | None:
    sector_index = integer(blocks["sidedef"][side_index], "sector")
    return integer(blocks["sector"][sector_index], "id")


def compact_geometry(blocks, removed_lines: set[int]) -> dict[int, int]:
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
    kept_side_indices = [
        index for index in range(len(sides)) if index not in removed_sides
    ]
    side_map = {old: new for new, old in enumerate(kept_side_indices)}

    rebuilt_lines = []
    for index, line in enumerate(lines):
        if index in removed_lines:
            continue
        line["sidefront"] = str(side_map[integer(line, "sidefront")])
        if "sideback" in line:
            line["sideback"] = str(side_map[integer(line, "sideback")])
        rebuilt_lines.append(line)
    blocks["linedef"] = rebuilt_lines
    blocks["sidedef"] = [sides[index] for index in kept_side_indices]

    used_vertices = {
        integer(line, key)
        for line in blocks["linedef"]
        for key in ("v1", "v2")
    }
    kept_vertex_indices = [
        index for index in range(len(vertices)) if index in used_vertices
    ]
    vertex_map = {old: new for new, old in enumerate(kept_vertex_indices)}
    for line in blocks["linedef"]:
        line["v1"] = str(vertex_map[integer(line, "v1")])
        line["v2"] = str(vertex_map[integer(line, "v2")])
    blocks["vertex"] = [vertices[index] for index in kept_vertex_indices]

    used_sectors = {
        integer(side, "sector") for side in blocks["sidedef"]
    }
    kept_sector_indices = [
        index for index in range(len(sectors)) if index in used_sectors
    ]
    sector_map = {old: new for new, old in enumerate(kept_sector_indices)}
    for side in blocks["sidedef"]:
        side["sector"] = str(sector_map[integer(side, "sector")])
    blocks["sector"] = [sectors[index] for index in kept_sector_indices]
    return sector_map


def merge_base_sectors(blocks) -> None:
    # Las tres habitaciones de cada hilera heredaron sectores base distintos
    # pero idénticos. Unificarlos cierra la nueva envolvente sin crear bordes
    # invisibles entre módulos.
    replacements = {41: 37, 53: 37, 49: 45, 57: 45}
    for side in blocks["sidedef"]:
        current = integer(side, "sector")
        if current in replacements:
            side["sector"] = str(replacements[current])


def find_vertex(blocks, point: tuple[float, float]) -> int | None:
    for index, vertex in enumerate(blocks["vertex"]):
        if (float(vertex["x"]), float(vertex["y"])) == point:
            return index
    return None


def get_or_add_vertex(blocks, point: tuple[float, float]) -> int:
    existing = find_vertex(blocks, point)
    if existing is not None:
        return existing
    blocks["vertex"].append(make_vertex(*point))
    return len(blocks["vertex"]) - 1


def line_positions(blocks, line) -> tuple[tuple[float, float], tuple[float, float]]:
    vertices = blocks["vertex"]
    first = vertices[integer(line, "v1")]
    second = vertices[integer(line, "v2")]
    return (
        (float(first["x"]), float(first["y"])),
        (float(second["x"]), float(second["y"])),
    )


def find_line(blocks, first, second) -> int:
    expected = {first, second}
    matches = [
        index
        for index, line in enumerate(blocks["linedef"])
        if set(line_positions(blocks, line)) == expected
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Arista {first}<->{second}: se hallaron {len(matches)} líneas"
        )
    return matches[0]


def split_line(blocks, first, second, point) -> None:
    index = find_line(blocks, first, second)
    line = blocks["linedef"][index]
    start = integer(line, "v1")
    old_end = integer(line, "v2")
    split = get_or_add_vertex(blocks, point)

    duplicate = OrderedDict(line)
    line["v2"] = str(split)
    duplicate["v1"] = str(split)
    duplicate["v2"] = str(old_end)
    for side_name in ("sidefront", "sideback"):
        if side_name not in duplicate:
            continue
        old_side = integer(duplicate, side_name)
        blocks["sidedef"].append(OrderedDict(blocks["sidedef"][old_side]))
        duplicate[side_name] = str(len(blocks["sidedef"]) - 1)
    blocks["linedef"].append(duplicate)

    if start == split or old_end == split:
        raise ValueError("La división de línea produjo un extremo nulo")


def add_two_sided_line(blocks, first, second, front_sector, back_sector) -> None:
    start = get_or_add_vertex(blocks, first)
    end = get_or_add_vertex(blocks, second)
    if start == end:
        raise ValueError(f"Línea nula solicitada en {first}")
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


def add_polygon_boundary(blocks, points, front_sector, back_sector) -> None:
    for index, first in enumerate(points):
        second = points[(index + 1) % len(points)]
        add_two_sided_line(blocks, first, second, front_sector, back_sector)


def add_divider_box(blocks, box, interior_sector, wall_sector) -> None:
    minimum_x, minimum_y, maximum_x, maximum_y = box
    points = (
        (minimum_x, minimum_y),
        (minimum_x, maximum_y),
        (maximum_x, maximum_y),
        (maximum_x, minimum_y),
    )
    add_polygon_boundary(blocks, points, wall_sector, interior_sector)


def set_floor_zero_side_to_wall(blocks, first, second, wall_sector) -> None:
    line = blocks["linedef"][find_line(blocks, first, second)]
    matches = []
    for side_name in ("sidefront", "sideback"):
        if side_name not in line:
            continue
        side_index = integer(line, side_name)
        sector_index = integer(blocks["sidedef"][side_index], "sector")
        if integer(blocks["sector"][sector_index], "heightfloor") == 0:
            matches.append(side_index)
    if len(matches) != 1:
        raise ValueError(
            f"Arista de escalera {first}<->{second}: lado base ambiguo"
        )
    blocks["sidedef"][matches[0]]["sector"] = str(wall_sector)


def attach_stair_boundaries(blocks, wall_sector) -> None:
    # Los tramos 176--208 se dividen exactamente en el frente de las
    # habitaciones. Así no se modifica la parte inferior de las escaleras.
    for x in STAIR_X:
        split_line(blocks, (x, 176.0), (x, 208.0), (x, 192.0))
        split_line(blocks, (x, -208.0), (x, -176.0), (x, -192.0))

    for x in STAIR_X:
        for first_y, second_y in (
            (192.0, 208.0),
            (208.0, 240.0),
            (240.0, 272.0),
            (-272.0, -240.0),
            (-240.0, -208.0),
            (-208.0, -192.0),
        ):
            set_floor_zero_side_to_wall(
                blocks,
                (x, first_y),
                (x, second_y),
                wall_sector,
            )

    # Sólo las dos escaleras internas tienen la habitación detrás de su
    # desembarco. La tercera toca la pared exterior por su costado izquierdo.
    for first, second in (
        ((-24.0, 272.0), (95.0, 272.0)),
        ((641.0, 272.0), (760.0, 272.0)),
        ((-24.0, -272.0), (95.0, -272.0)),
        ((641.0, -272.0), (760.0, -272.0)),
    ):
        set_floor_zero_side_to_wall(blocks, first, second, wall_sector)


def add_rows(blocks, north_base, south_base, interior, wall) -> None:
    # Contornos exteriores añadidos. Los costados de las escaleras que forman
    # parte del mismo contorno fueron reutilizados por attach_stair_boundaries.
    for first, second in (
        ((-473.0, 192.0), (-473.0, 544.0)),
        ((-473.0, 544.0), (1306.0, 544.0)),
        ((1306.0, 544.0), (1306.0, 272.0)),
        ((-24.0, 192.0), (-473.0, 192.0)),
        ((641.0, 192.0), (95.0, 192.0)),
        ((1306.0, 192.0), (760.0, 192.0)),
    ):
        add_two_sided_line(blocks, first, second, wall, north_base)

    for first, second in (
        ((-473.0, -544.0), (-473.0, -192.0)),
        ((-473.0, -192.0), (-24.0, -192.0)),
        ((95.0, -192.0), (641.0, -192.0)),
        ((760.0, -192.0), (1306.0, -192.0)),
        ((1306.0, -272.0), (1306.0, -544.0)),
        ((1306.0, -544.0), (-473.0, -544.0)),
    ):
        add_two_sided_line(blocks, first, second, wall, south_base)

    north_inner = (
        (-465.0, 200.0),
        (-465.0, 536.0),
        (1298.0, 536.0),
        (1298.0, 200.0),
        (768.0, 200.0),
        (768.0, 280.0),
        (633.0, 280.0),
        (633.0, 200.0),
        (103.0, 200.0),
        (103.0, 280.0),
        (-32.0, 280.0),
        (-32.0, 200.0),
    )
    south_inner = (
        (-465.0, -536.0),
        (-465.0, -200.0),
        (-32.0, -200.0),
        (-32.0, -280.0),
        (103.0, -280.0),
        (103.0, -200.0),
        (633.0, -200.0),
        (633.0, -280.0),
        (768.0, -280.0),
        (768.0, -200.0),
        (1298.0, -200.0),
        (1298.0, -536.0),
    )
    add_polygon_boundary(blocks, north_inner, interior, wall)
    add_polygon_boundary(blocks, south_inner, interior, wall)

    for box in (
        (32.0, 280.0, 40.0, 536.0),
        (364.0, 200.0, 372.0, 336.0),
        (364.0, 400.0, 372.0, 536.0),
        (697.0, 280.0, 705.0, 536.0),
        (32.0, -536.0, 40.0, -280.0),
        (364.0, -536.0, 372.0, -400.0),
        (364.0, -336.0, 372.0, -200.0),
        (697.0, -536.0, 705.0, -280.0),
    ):
        add_divider_box(blocks, box, interior, wall)


def remove_obsolete_doors(blocks) -> None:
    blocks["thing"] = [
        thing
        for thing in blocks["thing"]
        if not (
            integer(thing, "type") == 18025
            and integer(thing, "arg0") in OBSOLETE_SIDE_DOORS
            and float(thing.get("height", "0")) == 136.0
        )
    ]


def validate_map(blocks) -> None:
    ids = [integer(sector, "id") for sector in blocks["sector"]]
    if ids.count(510) != 1 or ids.count(511) != 1:
        raise ValueError("Las hileras no comparten exactamente un tag 510/511")

    controls = [
        line
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in ROOM_TAGS
    ]
    if [integer(line, "arg0") for line in controls].count(510) != 2:
        raise ValueError("Los dos controles de losa 510 cambiaron")
    if [integer(line, "arg0") for line in controls].count(511) != 1:
        raise ValueError("El control de pared 511 cambió")

    for thing in blocks["thing"]:
        if (integer(thing, "type") == 18025
            and integer(thing, "arg0") in OBSOLETE_SIDE_DOORS
            and float(thing.get("height", "0")) == 136.0):
            raise ValueError("Quedó una puerta lateral flotante")

    positions = [
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    ]
    edge_counts: defaultdict[tuple[tuple[float, float], ...], int] = defaultdict(int)
    for index, line in enumerate(blocks["linedef"]):
        if "sidefront" not in line:
            raise ValueError(f"Linedef {index} sin front sidedef")
        first = positions[integer(line, "v1")]
        second = positions[integer(line, "v2")]
        if first == second:
            raise ValueError(f"Linedef {index} de longitud nula")
        edge_counts[tuple(sorted((first, second)))] += 1
    duplicates = [edge for edge, count in edge_counts.items() if count > 1]
    if duplicates:
        raise ValueError(f"Líneas coincidentes detectadas: {duplicates[:4]}")

    for first, second in (
        ((-24.0, 272.0), (95.0, 272.0)),
        ((641.0, 272.0), (760.0, 272.0)),
        ((1306.0, 272.0), (1425.0, 272.0)),
    ):
        if abs(second[0] - first[0]) != 119.0:
            raise ValueError("El ancho de escalera dejó de ser 119 MU")
        find_line(blocks, first, second)


def is_updated(blocks) -> bool:
    ids = [integer(sector, "id") for sector in blocks["sector"]]
    positions = {
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    }
    return (
        ids.count(510) == 1
        and ids.count(511) == 1
        and (1298.0, 536.0) in positions
        and (697.0, 280.0) in positions
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(i for i, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_map(blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != (398, 489, 948, 99, 210):
        raise ValueError(f"MAP01 no coincide con la base 4.29.0i: {counts}")

    merge_base_sectors(blocks)
    removed_lines = {
        index
        for index, line in enumerate(blocks["linedef"])
        if any(
            sector_id(blocks, integer(line, side_name)) in ROOM_TAGS
            for side_name in ("sidefront", "sideback")
            if side_name in line
        )
    }
    if len(removed_lines) != 172:
        raise ValueError(
            f"Se esperaban 172 líneas de habitaciones; hay {len(removed_lines)}"
        )

    sector_map = compact_geometry(blocks, removed_lines)
    north_base = sector_map[37]
    south_base = sector_map[45]

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

    attach_stair_boundaries(blocks, wall)
    add_rows(blocks, north_base, south_base, interior, wall)
    remove_obsolete_doors(blocks)
    validate_map(blocks)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)
    return True


def main() -> None:
    changed = rebuild_map01()
    print(f"MAP01: {'hileras extendidas' if changed else 'ya actualizado'}")


if __name__ == "__main__":
    main()
