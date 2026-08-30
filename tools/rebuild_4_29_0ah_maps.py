"""Reconstruye MAP01 y MAP02 para el candidato V4.29.0ah.

MAP01 parte exclusivamente de la base aceptada 4.29.0ad. Conserva las
habitaciones del primer piso, las escaleras exteriores, el tunel y los portones
913/914. Sustituye las paredes fragmentarias de la ampliacion por un perimetro
continuo, cierra los retornos del primer piso y deja abierta la planta baja bajo
los balcones. Desplaza la habitacion superior 64 MU hacia el fondo, le agrega
una puerta doble y elimina la antigua losa salvo el corredor de acceso.

MAP02 no mueve vertices, actores ni recintos diagnosticos. Solo aplica los
materiales de alcantarilla a todos los pisos y a todas las caras de pared,
incluidas las superficies interiores que 0ae habia dejado como mansion.
"""

from __future__ import annotations

from collections import Counter, OrderedDict, defaultdict
from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0o_maps import add_two_sided_line, compact_geometry, line_positions
from rebuild_4_29_0p_maps import LANDINGS
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_references,
)
from rebuild_4_29_0u_maps import (
    boundary_vertices,
    edge_indices,
    prepare_boundary,
    rectangle_has_internal_lines,
    validate_closed_sector,
)
from rebuild_4_29_0v_maps import (
    door_group_counts,
    sector_bounds,
    validate_upper_gate,
)
from rebuild_4_29_0w_maps import map_counts
from rebuild_4_29_0aa_maps import (
    PROCESSING_MANUAL_DOOMEDNUM,
    processing_manuals,
)
from rebuild_4_29_0ac_maps import (
    LOCAL_DIAGNOSTIC_TYPES,
    PERCEPTION_OBSERVERS,
    PHYSICS_MONITOR_DOOMEDNUM,
    add_one_sided_line,
    map02_mass_field_count,
    perception_observers,
)
from rebuild_4_29_0ad_maps import (
    SECOND_FLOOR_GATE_GROUP,
    active_controls,
    digest_json,
    map02_geometry_digest,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = (696, 942, 1798, 226, 225)
MAP01_BASE_SHA256 = (
    "7bc0519a11adf058848a7986e456cd0ea8a97457f7e6ec963310a1ed3dbbc3a2"
)
MAP01_UPDATED_COUNTS = (946, 1297, 2356, 383, 227)
MAP01_UPDATED_SHA256 = (
    "faf38441d47a3bc0db36d5b069aff082451e4ddabeb38251cf996396f16ed2f3"
)

MAP02_BASE_COUNTS = (112, 110, 212, 9, 16508)
MAP02_BASE_SHA256 = (
    "2f4568f60512ff3656476f32c506ac2547f6b4949b58b20d2f9b6de8c5fc0b54"
)
MAP02_UPDATED_COUNTS = MAP02_BASE_COUNTS
MAP02_UPDATED_SHA256: str | None = (
    "47e0804417f03e7e913fd2aab47cc7654c61e280f3d42671fd4287e90557cffe"
)

WORLD_SECTOR = 0
FLOOR_ROOF_TAG = 510
UPPER_WALL_TAG = 511
OPEN_FLOOR_TAG = 514
FULL_HEIGHT_WALL_TAG = 516
GROUND_DIVIDER_TAG = 542
FIRST_FLOOR_WALL_TAG = 543
OUTER_PERIMETER_TAG = 544
FIRST_FLOOR_ONLY_TAG = 546
LOWER_GATE_TAG = 547
CORRIDOR_PROFILE_TAG_START = 550
ROOM_PROFILE_TAG_START = 560

MANSION_WALL = '"CMIN01"'
MANSION_FLOOR = '"CMWD01"'
MANSION_CEILING = '"CMCL01"'
SEWER_WALL = '"CASWRWAL"'
SEWER_FLOOR = '"CASWRFLR"'

REMOVED_DIVIDER_GROUPS = (914, 915)
REMOVED_DIVIDER_SECTORS = (222, 223, 224, 225)
NEW_DIVIDER_GROUP = 914
UPPER_ROOM_DOOR_GROUP = 915

# El divisor X=1201..1209 cierra las dos habitaciones inferiores. Su vano de
# 128 MU queda centrado y recibe dos hojas de 64 MU que forman una sola puerta.
GROUND_DIVIDER_WALL_SECTORS = (106, 108)
GROUND_DIVIDER_SPLITS = (
    (1201.0, -96.0, 1209.0, -64.0),
    (1201.0, 64.0, 1209.0, 96.0),
)
GROUND_DIVIDER_DOORWAY = (1201.0, -64.0, 1209.0, 64.0)

# Se eliminan primero todos los perfiles heredados de la ampliacion. Luego se
# asigna una sola intencion vertical a cada pieza: suelo del primer piso,
# pared exterior completa o pared exclusivamente en el primer piso.
LEGACY_UPPER_ONLY_SECTORS = tuple(range(25, 37)) + (70, 71)
FIRST_FLOOR_ONLY_SECTORS = (
    65, 66, 67, 68, 101, 107,
    162, 163, 164, 165, 166,
    171, 172, 176,
    183, 184, 185, 186,
    222, 223, 224, 225,
)
OUTER_PERIMETER_SECTORS = (
    156, 157, 158, 160, 161,
    167, 168, 169, 170,
    187, 188,
)
FIRST_FLOOR_WALL_SECTORS = (177, 178, 179, 180, 181, 182)
LOWER_GATE_SECTOR = 189

# Cada muro interior hacia un balcon conserva un paso central de 64 MU.
BALCONY_DOORWAY_X = (1512.0, 1576.0)
BALCONY_DOORWAY_RECTS = (
    (1512.0, -295.0, 1544.0, -287.0, 177),
    (1544.0, -295.0, 1576.0, -287.0, 178),
    (1512.0, 287.0, 1544.0, 295.0, 179),
    (1544.0, 287.0, 1576.0, 295.0, 180),
)

# El recinto mantiene 1426 x 782 MU. Desde 0ag vuelve 64 MU hacia el fondo
# (este), una medida modular completa, y abre una puerta doble en ese costado.
ROOM_OUTER = (-161.0, -391.0, 1265.0, 391.0)
ROOM_INNER = (-153.0, -383.0, 1257.0, 383.0)
ROOM_EAST_DOORWAY = (-64.0, 64.0)
EXPECTED_ROOM_RECTANGLES = 190

# Solo este corredor conserva la cota z=256..264 entre la puerta nueva y el
# descanso de las escaleras exteriores. El resto de la losa antigua desaparece.
UPPER_CORRIDOR = (1265.0, -64.0, 1697.0, 64.0)
EXPECTED_CORRIDOR_RECTANGLES = 6

GROUND_FLOOR_RANGE = (128, 136, MANSION_CEILING, MANSION_FLOOR)
SECOND_FLOOR_RANGE = (256, 264, MANSION_CEILING, MANSION_FLOOR)
SECOND_FLOOR_WALL_RANGE = (264, 392, MANSION_WALL, MANSION_WALL)
SECOND_FLOOR_ROOF_RANGE = (392, 400, MANSION_CEILING, MANSION_FLOOR)

FIXED_PLATFORM_PROFILES: dict[int, Profile] = {
    GROUND_DIVIDER_TAG: ((0, 128, MANSION_WALL, MANSION_WALL),),
    FIRST_FLOOR_WALL_TAG: ((128, 256, MANSION_WALL, MANSION_WALL),),
    OUTER_PERIMETER_TAG: ((0, 256, MANSION_WALL, MANSION_WALL),),
    FIRST_FLOOR_ONLY_TAG: (GROUND_FLOOR_RANGE,),
    LOWER_GATE_TAG: ((0, 136, MANSION_WALL, MANSION_WALL),),
}

CONTROL_ORIGIN_X = 26000.0
CONTROL_ORIGIN_Y = 30000.0
CONTROL_COLUMNS = 80

MAP02_THINGS_SHA256 = (
    "bd57fb8ee5b72739b03ab195bef787125a90c9cde287e8a530cbf70b08681317"
)
MAP02_GEOMETRY_SHA256 = (
    "229e75fd05b0cfde98f87729cb13ade5000733ca1065ac04da58d0bbb1b22774"
)

ProfileEntry = tuple[int, int, str, str]
Profile = tuple[ProfileEntry, ...]
RoomRectangle = tuple[float, float, float, float, int, str]


def control_profile(blocks, tag: int | None) -> Profile:
    if tag is None:
        return ()
    entries: list[ProfileEntry] = []
    for _, sector_index in active_controls(blocks, tag):
        sector = blocks["sector"][sector_index]
        entries.append(
            (
                integer(sector, "heightfloor"),
                integer(sector, "heightceiling"),
                sector.get("texturefloor", MANSION_CEILING),
                sector.get("textureceiling", MANSION_FLOOR),
            )
        )
    return tuple(sorted(entries))


def add_range(profile: Profile, addition: ProfileEntry) -> Profile:
    """Une un volumen sin crear solapamientos de pisos 3D."""

    floor, ceiling, _, _ = addition
    entries = list(profile)
    for current in entries:
        current_floor, current_ceiling, _, _ = current
        if current_ceiling <= floor or current_floor >= ceiling:
            continue
        if current_floor <= floor and current_ceiling >= ceiling:
            return tuple(sorted(entries))
        raise ValueError(
            f"El volumen {floor}..{ceiling} corta {current_floor}..{current_ceiling}"
        )
    entries.append(addition)
    return tuple(sorted(entries))


def room_profile(base: Profile, kind: str) -> Profile:
    result = add_range(base, SECOND_FLOOR_RANGE)
    if kind == "wall":
        result = add_range(result, SECOND_FLOOR_WALL_RANGE)
    result = add_range(result, SECOND_FLOOR_ROOF_RANGE)
    return result


def profile_covers(profile: Profile, floor: int, ceiling: int) -> bool:
    return any(
        entry_floor <= floor and entry_ceiling >= ceiling
        for entry_floor, entry_ceiling, _, _ in profile
    )


def add_control(
    blocks,
    tag: int,
    entry: ProfileEntry,
    slot: int,
) -> None:
    floor, ceiling, floor_texture, ceiling_texture = entry
    if floor >= ceiling:
        raise ValueError(f"Control invalido {tag}: {floor}..{ceiling}")

    sector_index = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", str(floor)),
                ("heightceiling", str(ceiling)),
                ("texturefloor", floor_texture),
                ("textureceiling", ceiling_texture),
                ("lightlevel", "176"),
            )
        )
    )
    column = slot % CONTROL_COLUMNS
    row = slot // CONTROL_COLUMNS
    minimum_x = CONTROL_ORIGIN_X + column * 64.0
    minimum_y = CONTROL_ORIGIN_Y - row * 64.0
    points = (
        (minimum_x, minimum_y),
        (minimum_x, minimum_y + 48.0),
        (minimum_x + 48.0, minimum_y + 48.0),
        (minimum_x + 48.0, minimum_y),
    )
    for index, first in enumerate(points):
        add_one_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            sector_index,
            tag if index == 0 else None,
        )


def add_profile_controls(
    blocks,
    profile_tags: dict[Profile, int],
    slot_start: int = 0,
) -> None:
    slot = slot_start
    for profile, tag in sorted(profile_tags.items(), key=lambda item: item[1]):
        for entry in profile:
            add_control(blocks, tag, entry, slot)
            slot += 1


def add_fixed_platform_controls(blocks) -> None:
    """Instala perfiles completos para la ampliacion oriental de la mansion."""

    slot = 200
    for tag, profile in sorted(FIXED_PLATFORM_PROFILES.items()):
        for entry in profile:
            add_control(blocks, tag, entry, slot)
            slot += 1


def make_ground_divider_door(source, y: float, direction: int) -> OrderedDict:
    door = OrderedDict(source)
    door["x"] = "1205.0"
    door["y"] = f"{y:.1f}"
    door["height"] = "0.0"
    door["angle"] = "0"
    door["arg0"] = str(NEW_DIVIDER_GROUP)
    door["arg1"] = str(direction)
    door["arg2"] = "1"
    door["arg3"] = "0"
    return door


def make_upper_room_door(source, y: float, direction: int) -> OrderedDict:
    door = OrderedDict(source)
    door["x"] = "1261.0"
    door["y"] = f"{y:.1f}"
    door["height"] = "264.0"
    door["angle"] = "0"
    door["arg0"] = str(UPPER_ROOM_DOOR_GROUP)
    door["arg1"] = str(direction)
    door["arg2"] = "1"
    door["arg3"] = "0"
    return door


def carve_from_host(blocks, rectangle, host_sector: int, tag: int) -> int:
    """Talla un rectangulo y conserva las propiedades del sector anfitrion."""

    if rectangle_has_internal_lines(blocks, rectangle):
        raise ValueError(f"El rectangulo invade geometria: {rectangle}")
    target_sector = len(blocks["sector"])
    target = OrderedDict(blocks["sector"][host_sector])
    target["id"] = str(tag)
    blocks["sector"].append(target)

    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    points = (
        (minimum_x, minimum_y),
        (minimum_x, maximum_y),
        (maximum_x, maximum_y),
        (maximum_x, minimum_y),
    )
    for index, first in enumerate(points):
        second = points[(index + 1) % len(points)]
        prepare_boundary(blocks, first, second)
        points_on_edge = boundary_vertices(blocks, first, second)
        for start, end in zip(points_on_edge[:-1], points_on_edge[1:]):
            matches = edge_indices(blocks, start, end)
            candidates: list[tuple[int, str]] = []
            for match in matches:
                line = blocks["linedef"][match]
                line_start, line_end = line_positions(blocks, line)
                if (line_start, line_end) == (start, end):
                    inside_side = "sidefront"
                elif (line_start, line_end) == (end, start):
                    inside_side = "sideback"
                else:
                    continue
                side_index = integer(line, inside_side)
                if side_index is None:
                    continue
                if integer(blocks["sidedef"][side_index], "sector") == host_sector:
                    candidates.append((match, inside_side))

            if len(candidates) > 1:
                raise ValueError(f"Borde ambiguo {start} -> {end}: {candidates}")
            if candidates:
                match, inside_side = candidates[0]
                side_index = integer(blocks["linedef"][match], inside_side)
                blocks["sidedef"][side_index]["sector"] = str(target_sector)
                continue
            if matches:
                owners = []
                for match in matches:
                    line = blocks["linedef"][match]
                    owners.append(
                        tuple(
                            integer(blocks["sidedef"][integer(line, side)], "sector")
                            for side in ("sidefront", "sideback")
                            if side in line
                        )
                    )
                raise ValueError(
                    f"Borde {start} -> {end} sin lado del anfitrion "
                    f"{host_sector}: {owners}"
                )
            add_two_sided_line(
                blocks,
                start,
                end,
                target_sector,
                host_sector,
            )
    return target_sector


def rebuild_ground_and_balconies(blocks) -> None:
    blocks["thing"] = [
        thing
        for thing in blocks["thing"]
        if not (
            integer(thing, "type") == 18025
            and integer(thing, "arg0") in REMOVED_DIVIDER_GROUPS
        )
    ]
    # Retira por completo la losa y las paredes heredadas de la ampliacion.
    # Cada sector recibe despues un perfil nuevo y unico.
    for sector_index in LEGACY_UPPER_ONLY_SECTORS:
        blocks["sector"][sector_index]["id"] = "0"
    for sector_index in FIRST_FLOOR_ONLY_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FIRST_FLOOR_ONLY_TAG)
    for sector_index in OUTER_PERIMETER_SECTORS:
        blocks["sector"][sector_index]["id"] = str(OUTER_PERIMETER_TAG)
    for sector_index in FIRST_FLOOR_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FIRST_FLOOR_WALL_TAG)
    blocks["sector"][LOWER_GATE_SECTOR]["id"] = str(LOWER_GATE_TAG)

    for sector_index in GROUND_DIVIDER_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(GROUND_DIVIDER_TAG)
    blocks["sector"][107]["id"] = str(FIRST_FLOOR_ONLY_TAG)

    add_fixed_platform_controls(blocks)
    for rectangle in GROUND_DIVIDER_SPLITS:
        carve_from_host(blocks, rectangle, 107, GROUND_DIVIDER_TAG)

    # Los retornos ahora cierran solo el primer piso. La planta baja debajo de
    # ambos balcones queda integrada a las habitaciones; cada balcon conserva
    # un paso central de 64 MU en su pared interior.
    for minimum_x, minimum_y, maximum_x, maximum_y, host in BALCONY_DOORWAY_RECTS:
        carve_from_host(
            blocks,
            (minimum_x, minimum_y, maximum_x, maximum_y),
            host,
            FIRST_FLOOR_ONLY_TAG,
        )

    gate_leaves = sorted(
        (
            thing
            for thing in blocks["thing"]
            if integer(thing, "type") == 18025
            and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
        ),
        key=lambda thing: float(thing["y"]),
    )
    if len(gate_leaves) != 2:
        raise ValueError("El porton 913 no ofrece dos hojas para clonar")
    blocks["thing"].extend(
        (
            make_ground_divider_door(gate_leaves[0], -32.0, -1),
            make_ground_divider_door(gate_leaves[1], 32.0, 1),
        )
    )


def sector_edges(blocks, sector_index: int):
    result = []
    for line in blocks["linedef"]:
        owners = [
            integer(blocks["sidedef"][integer(line, side)], "sector")
            for side in ("sidefront", "sideback")
            if side in line
        ]
        if owners.count(sector_index) == 1:
            result.append(line_positions(blocks, line))
    return result


def optional_sector_bounds(blocks, sector_index: int):
    """Tolera sectores anfitriones consumidos por la nueva subdivisión."""

    try:
        return sector_bounds(blocks, sector_index)
    except ValueError as error:
        if "no tiene contorno" not in str(error):
            raise
        return None


def point_in_sector(edges, x: float, y: float) -> bool:
    crossings = 0
    for (first_x, first_y), (second_x, second_y) in edges:
        if (first_y > y) == (second_y > y):
            continue
        crossing_x = first_x + (y - first_y) * (second_x - first_x) / (
            second_y - first_y
        )
        if crossing_x > x:
            crossings += 1
    return crossings % 2 == 1


def sector_at_point(
    blocks,
    x: float,
    y: float,
    bounds_cache=None,
    edges_cache=None,
) -> int:
    if bounds_cache is None:
        bounds_cache = [
            optional_sector_bounds(blocks, index)
            for index in range(len(blocks["sector"]))
        ]
    if edges_cache is None:
        edges_cache = {}

    matches = []
    for sector_index, bounds in enumerate(bounds_cache):
        if bounds is None:
            continue
        minimum_x, minimum_y, maximum_x, maximum_y = bounds
        if not (minimum_x < x < maximum_x and minimum_y < y < maximum_y):
            continue
        edges = edges_cache.setdefault(
            sector_index,
            sector_edges(blocks, sector_index),
        )
        if point_in_sector(edges, x, y):
            matches.append(sector_index)

    non_world = [index for index in matches if index != WORLD_SECTOR]
    if len(non_world) > 1:
        raise ValueError(f"Punto ({x:g}, {y:g}) en sectores {matches}")
    return non_world[0] if non_world else WORLD_SECTOR


def merge_room_cells(cells) -> list[RoomRectangle]:
    horizontal: list[list] = []
    rows: defaultdict[tuple, list] = defaultdict(list)
    for cell in cells:
        x0, y0, x1, y1, host, kind = cell
        rows[(host, kind, y0, y1)].append(cell)
    for (host, kind, y0, y1), row_cells in sorted(rows.items()):
        row_cells.sort()
        start_x, end_x = row_cells[0][0], row_cells[0][2]
        for cell in row_cells[1:]:
            if cell[0] == end_x:
                end_x = cell[2]
                continue
            horizontal.append([start_x, y0, end_x, y1, host, kind])
            start_x, end_x = cell[0], cell[2]
        horizontal.append([start_x, y0, end_x, y1, host, kind])

    columns: defaultdict[tuple, list] = defaultdict(list)
    for rectangle in horizontal:
        columns[(rectangle[0], rectangle[2], rectangle[4], rectangle[5])].append(rectangle)

    merged: list[RoomRectangle] = []
    for rectangles in columns.values():
        rectangles.sort(key=lambda rectangle: rectangle[1])
        current = rectangles[0][:]
        for rectangle in rectangles[1:]:
            if rectangle[1] == current[3]:
                current[3] = rectangle[3]
                continue
            merged.append(tuple(current))
            current = rectangle[:]
        merged.append(tuple(current))
    return sorted(merged)


def corridor_rectangles(blocks) -> list[RoomRectangle]:
    minimum_x, minimum_y, maximum_x, maximum_y = UPPER_CORRIDOR
    x_coordinates = {minimum_x, maximum_x}
    y_coordinates = {minimum_y, maximum_y}
    for vertex in blocks["vertex"]:
        x = float(vertex["x"])
        y = float(vertex["y"])
        if minimum_x <= x <= maximum_x:
            x_coordinates.add(x)
        if minimum_y <= y <= maximum_y:
            y_coordinates.add(y)

    x_coordinates = sorted(x_coordinates)
    y_coordinates = sorted(y_coordinates)
    bounds_cache = [
        optional_sector_bounds(blocks, index)
        for index in range(len(blocks["sector"]))
    ]
    edges_cache = {}
    cells = []
    for cell_minimum_y, cell_maximum_y in zip(
        y_coordinates,
        y_coordinates[1:],
    ):
        if cell_maximum_y <= minimum_y or cell_minimum_y >= maximum_y:
            continue
        for cell_minimum_x, cell_maximum_x in zip(
            x_coordinates,
            x_coordinates[1:],
        ):
            if cell_maximum_x <= minimum_x or cell_minimum_x >= maximum_x:
                continue
            center_x = (cell_minimum_x + cell_maximum_x) * 0.5
            center_y = (cell_minimum_y + cell_maximum_y) * 0.5
            host = sector_at_point(
                blocks,
                center_x,
                center_y,
                bounds_cache,
                edges_cache,
            )
            cells.append(
                (
                    cell_minimum_x,
                    cell_minimum_y,
                    cell_maximum_x,
                    cell_maximum_y,
                    host,
                    "corridor",
                )
            )

    rectangles = merge_room_cells(cells)
    if (
        EXPECTED_CORRIDOR_RECTANGLES is not None
        and len(rectangles) != EXPECTED_CORRIDOR_RECTANGLES
    ):
        raise ValueError(
            f"Subdivisiones del corredor: {len(rectangles)}, "
            f"esperadas {EXPECTED_CORRIDOR_RECTANGLES}"
        )
    for rectangle in rectangles:
        if rectangle_has_internal_lines(blocks, rectangle[:4]):
            raise ValueError(f"Corredor con linea interior: {rectangle}")
    return rectangles


def add_upper_access_corridor(blocks) -> dict[Profile, int]:
    rectangles = corridor_rectangles(blocks)
    profile_tags: dict[Profile, int] = {}
    prepared = []
    for rectangle in rectangles:
        *bounds, host, _ = rectangle
        base = control_profile(blocks, integer(blocks["sector"][host], "id"))
        profile = add_range(base, SECOND_FLOOR_RANGE)
        if profile not in profile_tags:
            profile_tags[profile] = CORRIDOR_PROFILE_TAG_START + len(profile_tags)
        prepared.append((tuple(bounds), host, profile_tags[profile]))

    for bounds, host, tag in prepared:
        sector_index = carve_from_host(blocks, bounds, host, tag)
        if blocks["sector"][sector_index].get("texturefloor") == '"FLOOR0_1"':
            blocks["sector"][sector_index]["texturefloor"] = MANSION_FLOOR
    add_profile_controls(blocks, profile_tags, 0)
    return profile_tags


def room_rectangles(blocks) -> list[RoomRectangle]:
    outer_minimum_x, outer_minimum_y, outer_maximum_x, outer_maximum_y = ROOM_OUTER
    inner_minimum_x, inner_minimum_y, inner_maximum_x, inner_maximum_y = ROOM_INNER
    x_coordinates = {
        outer_minimum_x,
        inner_minimum_x,
        inner_maximum_x,
        outer_maximum_x,
    }
    y_coordinates = {
        outer_minimum_y,
        inner_minimum_y,
        inner_maximum_y,
        outer_maximum_y,
        *ROOM_EAST_DOORWAY,
    }
    for vertex in blocks["vertex"]:
        x = float(vertex["x"])
        y = float(vertex["y"])
        if outer_minimum_x <= x <= outer_maximum_x:
            x_coordinates.add(x)
        if outer_minimum_y <= y <= outer_maximum_y:
            y_coordinates.add(y)

    x_coordinates = sorted(x_coordinates)
    y_coordinates = sorted(y_coordinates)
    bounds_cache = [
        optional_sector_bounds(blocks, index)
        for index in range(len(blocks["sector"]))
    ]
    edges_cache = {}
    cells = []
    for minimum_y, maximum_y in zip(y_coordinates, y_coordinates[1:]):
        if maximum_y <= outer_minimum_y or minimum_y >= outer_maximum_y:
            continue
        for minimum_x, maximum_x in zip(x_coordinates, x_coordinates[1:]):
            if maximum_x <= outer_minimum_x or minimum_x >= outer_maximum_x:
                continue
            center_x = (minimum_x + maximum_x) * 0.5
            center_y = (minimum_y + maximum_y) * 0.5
            host = sector_at_point(
                blocks,
                center_x,
                center_y,
                bounds_cache,
                edges_cache,
            )
            kind = "interior"
            if (
                center_x < inner_minimum_x
                or center_x > inner_maximum_x
                or center_y < inner_minimum_y
                or center_y > inner_maximum_y
            ):
                kind = "wall"
            if (
                kind == "wall"
                and center_x > inner_maximum_x
                and ROOM_EAST_DOORWAY[0] < center_y < ROOM_EAST_DOORWAY[1]
            ):
                kind = "interior"
            cells.append(
                (
                    minimum_x,
                    minimum_y,
                    maximum_x,
                    maximum_y,
                    host,
                    kind,
                )
            )

    rectangles = merge_room_cells(cells)
    if (
        EXPECTED_ROOM_RECTANGLES is not None
        and len(rectangles) != EXPECTED_ROOM_RECTANGLES
    ):
        raise ValueError(
            f"Subdivisiones del segundo piso: {len(rectangles)}, "
            f"esperadas {EXPECTED_ROOM_RECTANGLES}"
        )
    for rectangle in rectangles:
        if rectangle_has_internal_lines(blocks, rectangle[:4]):
            raise ValueError(f"Subdivision con linea interior: {rectangle}")
    return rectangles


def add_centered_second_floor_room(blocks) -> dict[Profile, int]:
    rectangles = room_rectangles(blocks)
    profile_tags: dict[Profile, int] = {}
    prepared = []
    for rectangle in rectangles:
        *bounds, host, kind = rectangle
        base = control_profile(blocks, integer(blocks["sector"][host], "id"))
        profile = room_profile(base, kind)
        if profile not in profile_tags:
            profile_tags[profile] = ROOM_PROFILE_TAG_START + len(profile_tags)
        prepared.append((tuple(bounds), host, profile_tags[profile]))

    for bounds, host, tag in prepared:
        sector_index = carve_from_host(blocks, bounds, host, tag)
        # Las celdas que antes pertenecían al vacío exterior pasan a formar
        # parte real de la mansión y no deben conservar FLOOR0_1.
        if blocks["sector"][sector_index].get("texturefloor") == '"FLOOR0_1"':
            blocks["sector"][sector_index]["texturefloor"] = MANSION_FLOOR
    add_profile_controls(blocks, profile_tags, 100)

    gate_leaves = sorted(
        (
            thing
            for thing in blocks["thing"]
            if integer(thing, "type") == 18025
            and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
        ),
        key=lambda thing: float(thing["y"]),
    )
    if len(gate_leaves) != 2:
        raise ValueError("El porton 913 no ofrece dos hojas para la puerta superior")
    blocks["thing"].extend(
        (
            make_upper_room_door(gate_leaves[0], -32.0, -1),
            make_upper_room_door(gate_leaves[1], 32.0, 1),
        )
    )
    return profile_tags


def collapse_duplicate_bridges(blocks) -> None:
    """Une dos bordes heredados cuando una subdivisión consume su anfitrión.

    El mapa base contiene dos tapas de 8 MU en Y=+-200. Al tallar ambos lados,
    cada tapa puede quedar representada por dos líneas coincidentes que aún
    comparten el antiguo sector. Se sustituyen por una sola línea entre los
    dos sectores nuevos; no se altera ninguna otra arista.
    """

    by_edge: defaultdict[tuple, list[int]] = defaultdict(list)
    for index, line in enumerate(blocks["linedef"]):
        by_edge[tuple(sorted(line_positions(blocks, line)))].append(index)

    removed: set[int] = set()
    for edge, indices in by_edge.items():
        if len(indices) == 1:
            continue
        if len(indices) != 2:
            raise ValueError(f"Borde coincidente no resoluble {edge}: {indices}")

        owner_maps = []
        for index in indices:
            line = blocks["linedef"][index]
            owner_maps.append(
                {
                    side_name: integer(
                        blocks["sidedef"][integer(line, side_name)],
                        "sector",
                    )
                    for side_name in ("sidefront", "sideback")
                    if side_name in line
                }
            )
        common = set(owner_maps[0].values()) & set(owner_maps[1].values())
        if len(common) != 1:
            raise ValueError(f"Borde coincidente sin puente único {edge}: {owner_maps}")
        shared = next(iter(common))
        first_other = [value for value in owner_maps[0].values() if value != shared]
        second_other = [value for value in owner_maps[1].values() if value != shared]
        if len(first_other) != 1 or len(second_other) != 1:
            raise ValueError(f"Puente degenerado {edge}: {owner_maps}")

        kept_line = blocks["linedef"][indices[0]]
        shared_side = next(
            side_name
            for side_name, owner in owner_maps[0].items()
            if owner == shared
        )
        side_index = integer(kept_line, shared_side)
        blocks["sidedef"][side_index]["sector"] = str(second_other[0])
        removed.add(indices[1])

    if len(removed) != 2:
        raise ValueError(f"Tapas coincidentes resueltas: {len(removed)}, esperadas 2")
    compact_geometry(blocks, removed)


def physical_profile_at(blocks, x: float, y: float) -> Profile:
    bounds_cache = [
        optional_sector_bounds(blocks, index)
        for index in range(len(blocks["sector"]))
    ]
    edges_cache = {}
    entries: set[ProfileEntry] = set()
    for sector_index, bounds in enumerate(bounds_cache):
        if sector_index == WORLD_SECTOR or bounds is None:
            continue
        minimum_x, minimum_y, maximum_x, maximum_y = bounds
        if not (minimum_x < x < maximum_x and minimum_y < y < maximum_y):
            continue
        edges = edges_cache.setdefault(
            sector_index,
            sector_edges(blocks, sector_index),
        )
        if not point_in_sector(edges, x, y):
            continue
        tag = integer(blocks["sector"][sector_index], "id")
        entries.update(control_profile(blocks, tag))
    return tuple(sorted(entries))


def validate_map01_architecture(blocks) -> None:
    groups = door_group_counts(blocks)
    if groups[SECOND_FLOOR_GATE_GROUP] != 2:
        raise ValueError("El acceso 913 no conserva sus dos hojas")
    if groups[NEW_DIVIDER_GROUP] != 2:
        raise ValueError("El divisor inferior no contiene una unica puerta doble")
    if groups[UPPER_ROOM_DOOR_GROUP] != 2:
        raise ValueError("La habitacion superior no contiene su puerta doble")

    gate = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
    }
    if gate != {
        (1693.0, -32.0, 136.0, -1, 1),
        (1693.0, 32.0, 136.0, 1, 1),
    }:
        raise ValueError(f"Acceso 913 inesperado: {gate}")

    divider = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == NEW_DIVIDER_GROUP
    }
    if divider != {
        (1205.0, -32.0, 0.0, -1, 1),
        (1205.0, 32.0, 0.0, 1, 1),
    }:
        raise ValueError(f"Puerta divisoria inesperada: {divider}")

    upper_door = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == UPPER_ROOM_DOOR_GROUP
    }
    if upper_door != {
        (1261.0, -32.0, 264.0, -1, 1),
        (1261.0, 32.0, 264.0, 1, 1),
    }:
        raise ValueError(f"Puerta superior inesperada: {upper_door}")

    for tag, expected_profile in FIXED_PLATFORM_PROFILES.items():
        if control_profile(blocks, tag) != tuple(sorted(expected_profile)):
            raise ValueError(
                f"Perfil fijo {tag} inesperado: {control_profile(blocks, tag)}"
            )

    # El perimetro exterior vuelve a ser un muro continuo de dos plantas.
    perimeter_points = (
        (1400.0, -387.0),
        (1400.0, 387.0),
        (1693.0, -200.0),
        (1693.0, 200.0),
        (1693.0, -387.0),
        (1693.0, 387.0),
    )
    for point in perimeter_points:
        profile = physical_profile_at(blocks, *point)
        if not profile_covers(profile, 0, 256):
            raise ValueError(f"El perimetro exterior sigue abierto en {point}")

    # Los retornos cierran el primer piso, pero no cortan la habitacion de
    # planta baja situada bajo los balcones.
    for point in ((1310.0, -340.0), (1310.0, 340.0)):
        profile = physical_profile_at(blocks, *point)
        if profile_covers(profile, 0, 128):
            raise ValueError(f"El retorno invade la planta baja en {point}")
        if not profile_covers(profile, 128, 256):
            raise ValueError(f"El retorno del primer piso sigue abierto en {point}")

    # Cada balcon conserva piso, espacio libre y un paso central de 64 MU.
    for point in ((1400.0, -340.0), (1400.0, 340.0)):
        profile = physical_profile_at(blocks, *point)
        if not profile_covers(profile, 128, 136):
            raise ValueError(f"Falta el piso del balcon en {point}")
        if profile_covers(profile, 136, 256):
            raise ValueError(f"El balcon quedo bloqueado en {point}")
        if profile_covers(profile, 256, 264):
            raise ValueError(f"Persiste el toldo superior sobre {point}")
    for point in ((1540.0, -291.0), (1550.0, -291.0),
                  (1540.0, 291.0), (1550.0, 291.0)):
        profile = physical_profile_at(blocks, *point)
        if profile_covers(profile, 136, 256):
            raise ValueError(f"El paso al balcon quedo cerrado en {point}")

    # El divisor inferior conserva su vano y queda cubierto solo por el piso
    # real de la habitacion superior, no por una losa exterior heredada.
    for point in ((1205.0, -128.0), (1205.0, 128.0)):
        profile = physical_profile_at(blocks, *point)
        if not profile_covers(profile, 0, 128):
            raise ValueError(f"Falta el divisor inferior en {point}")
        if not profile_covers(profile, 256, 264):
            raise ValueError(f"Falta piso superior sobre el divisor {point}")
    doorway_profile = physical_profile_at(blocks, 1205.0, 0.0)
    if profile_covers(doorway_profile, 0, 128):
        raise ValueError("El divisor cerro el vano de su puerta")
    if not profile_covers(doorway_profile, 256, 264):
        raise ValueError("Falta piso superior sobre el vano inferior")

    # La antigua losa oriental desaparece. Solo el corredor y el descanso
    # aceptado conservan suelo a z=256..264 fuera de la habitacion.
    for point in ((1300.0, 100.0), (1400.0, 100.0), (1400.0, -200.0),
                  (1600.0, 200.0), (1600.0, -200.0)):
        profile = physical_profile_at(blocks, *point)
        if profile_covers(profile, 256, 264):
            raise ValueError(f"Persiste una losa flotante en {point}")
    for point in ((1300.0, 0.0), (1500.0, 0.0), (1693.0, 0.0)):
        if not profile_covers(physical_profile_at(blocks, *point), 256, 264):
            raise ValueError(f"Falta el corredor superior en {point}")

    # Todas las celdas del rectangulo superior reciben piso y techo. Su franja
    # perimetral recibe pared 264..392 salvo el vano oriental de la puerta.
    outer_minimum_x, outer_minimum_y, outer_maximum_x, outer_maximum_y = ROOM_OUTER
    inner_minimum_x, inner_minimum_y, inner_maximum_x, inner_maximum_y = ROOM_INNER
    samples = []
    x_samples = (
        (outer_minimum_x + inner_minimum_x) * 0.5,
        (inner_minimum_x + inner_maximum_x) * 0.5,
        (inner_maximum_x + outer_maximum_x) * 0.5,
    )
    y_samples = (
        (outer_minimum_y + inner_minimum_y) * 0.5,
        -128.0,
        0.0,
        128.0,
        (inner_maximum_y + outer_maximum_y) * 0.5,
    )
    for x in x_samples:
        for y in y_samples:
            samples.append((x, y))
    for x, y in samples:
        profile = physical_profile_at(blocks, x, y)
        if not profile_covers(profile, 256, 264):
            raise ValueError(f"Falta piso del segundo nivel en ({x:g}, {y:g})")
        if not profile_covers(profile, 392, 400):
            raise ValueError(f"Falta techo del segundo nivel en ({x:g}, {y:g})")

        wall_expected = (
            x < inner_minimum_x
            or x > inner_maximum_x
            or y < inner_minimum_y
            or y > inner_maximum_y
        )
        if (
            x > inner_maximum_x
            and ROOM_EAST_DOORWAY[0] < y < ROOM_EAST_DOORWAY[1]
        ):
            wall_expected = False
        has_wall = profile_covers(profile, 264, 392)
        if has_wall != wall_expected:
            raise ValueError(
                f"Pared superior inesperada en ({x:g}, {y:g}): {has_wall}"
            )

    room_targets = [
        index
        for index, sector in enumerate(blocks["sector"])
        if (integer(sector, "id") or 0) >= ROOM_PROFILE_TAG_START
    ]
    if (
        EXPECTED_ROOM_RECTANGLES is not None
        and len(room_targets) != EXPECTED_ROOM_RECTANGLES
    ):
        raise ValueError(
            f"Sectores fisicos del segundo piso: {len(room_targets)}, "
            f"esperados {EXPECTED_ROOM_RECTANGLES}"
        )
    for sector_index in room_targets:
        validate_closed_sector(blocks, sector_index)

    corridor_targets = [
        index
        for index, sector in enumerate(blocks["sector"])
        if CORRIDOR_PROFILE_TAG_START
        <= (integer(sector, "id") or 0)
        < ROOM_PROFILE_TAG_START
    ]
    if (
        EXPECTED_CORRIDOR_RECTANGLES is not None
        and len(corridor_targets) != EXPECTED_CORRIDOR_RECTANGLES
    ):
        raise ValueError(
            f"Sectores fisicos del corredor: {len(corridor_targets)}, "
            f"esperados {EXPECTED_CORRIDOR_RECTANGLES}"
        )
    for sector_index in corridor_targets:
        validate_closed_sector(blocks, sector_index)

    for minimum_x, minimum_y, maximum_x, maximum_y in LANDINGS:
        center = (
            (minimum_x + maximum_x) * 0.5,
            (minimum_y + maximum_y) * 0.5,
        )
        profile = physical_profile_at(blocks, *center)
        if not profile_covers(profile, 256, 264):
            raise ValueError(f"El descanso {center} no alcanza el segundo piso")
        if profile_covers(profile, 264, 392):
            raise ValueError(f"El descanso {center} quedo cerrado por una pared")

    if len(processing_manuals(blocks)) != 1:
        raise ValueError("MAP01 no conserva un manual de procesamiento")
    if integer(processing_manuals(blocks)[0], "type") != PROCESSING_MANUAL_DOOMEDNUM:
        raise ValueError("El manual de procesamiento cambio de clase")


def validate_map01_surface_set(blocks) -> None:
    legacy_sides = []
    for index, side in enumerate(blocks["sidedef"]):
        values = {
            side.get(field)
            for field in ("texturetop", "texturemiddle", "texturebottom")
        }
        if '"STARTAN3"' in values or '"BIGDOOR2"' in values:
            legacy_sides.append(index)
    if legacy_sides:
        raise ValueError(f"Persisten texturas Doom en MAP01: {legacy_sides[:8]}")

    floor0 = [
        index
        for index, sector in enumerate(blocks["sector"])
        if sector.get("texturefloor") == '"FLOOR0_1"'
    ]
    if floor0 != [WORLD_SECTOR]:
        raise ValueError(f"FLOOR0_1 fuera del mundo exterior: {floor0}")
    if any(
        sector.get(field) == '"CEIL5_2"'
        for sector in blocks["sector"]
        for field in ("texturefloor", "textureceiling")
    ):
        raise ValueError("Persistio CEIL5_2 en MAP01")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None and map_counts(blocks) != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP01 4.29.0ah inesperada: {map_counts(blocks)}")
    validate_map01_architecture(blocks)
    validate_map01_surface_set(blocks)
    validate_upper_gate(blocks)
    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0ah inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    return any(
        (integer(sector, "id") or 0) >= ROOM_PROFILE_TAG_START
        for sector in blocks["sector"]
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0ad: "
            f"{map_counts(blocks)}, {digest}"
        )

    rebuild_ground_and_balconies(blocks)
    add_upper_access_corridor(blocks)
    add_centered_second_floor_room(blocks)
    collapse_duplicate_bridges(blocks)

    lumps[text_index] = (b"TEXTMAP", render_textmap(header, blocks).encode("utf-8"))
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02_content(blocks) -> None:
    if digest_json(blocks["thing"]) != MAP02_THINGS_SHA256:
        raise ValueError("MAP02 altero actores o sus argumentos")
    if map02_geometry_digest(blocks) != MAP02_GEOMETRY_SHA256:
        raise ValueError("MAP02 altero geometria fuera de sus texturas")
    if map02_mass_field_count(blocks) != 15000:
        raise ValueError("MAP02 no conserva exactamente 15.000 actores")
    if len(perception_observers(blocks)) != len(PERCEPTION_OBSERVERS):
        raise ValueError("MAP02 no conserva sus seis observadores")
    actual_observers = {
        (
            float(thing["x"]),
            float(thing["y"]),
            integer(thing, "angle"),
            integer(thing, "arg0"),
            integer(thing, "arg1"),
        )
        for thing in perception_observers(blocks)
    }
    if actual_observers != set(PERCEPTION_OBSERVERS):
        raise ValueError(f"Observadores MAP02 inesperados: {actual_observers}")
    legacy = [
        thing
        for thing in blocks["thing"]
        if integer(thing, "type") in LOCAL_DIAGNOSTIC_TYPES
        and float(thing["x"]) < 8192.0
        and -4096.0 < float(thing["y"]) < 4096.0
    ]
    if legacy:
        raise ValueError("MAP02 recupero actores diagnosticos obsoletos")
    identifiers = Counter(integer(thing, "type") for thing in blocks["thing"])
    for actor_type in (18205, 18206, 18207):
        if identifiers[actor_type] != 500:
            raise ValueError(f"La prueba Quintaesencia {actor_type} cambio")
    if identifiers[PHYSICS_MONITOR_DOOMEDNUM] != 1:
        raise ValueError("MAP02 perdio su monitor unico")


def apply_sewer_textures_everywhere(blocks) -> None:
    for sector in blocks["sector"]:
        sector["texturefloor"] = SEWER_FLOOR
    for side in blocks["sidedef"]:
        for field in ("texturetop", "texturemiddle", "texturebottom"):
            if field in side and side[field] != '"-"':
                side[field] = SEWER_WALL


def map02_is_updated(blocks) -> bool:
    return (
        all(sector.get("texturefloor") == SEWER_FLOOR for sector in blocks["sector"])
        and all(
            side.get(field) in (None, '"-"', SEWER_WALL)
            for side in blocks["sidedef"]
            for field in ("texturetop", "texturemiddle", "texturebottom")
        )
    )


def validate_map02(path: Path, blocks) -> None:
    if map_counts(blocks) != MAP02_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP02 4.29.0ah inesperada: {map_counts(blocks)}")
    validate_map02_content(blocks)
    if not map02_is_updated(blocks):
        raise ValueError("MAP02 conserva superficies interiores de mansion")
    if any(sector.get("textureceiling") != '"F_SKY1"' for sector in blocks["sector"]):
        raise ValueError("MAP02 altero los cielos diagnosticos")
    validate_references(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP02_UPDATED_SHA256 is not None and digest != MAP02_UPDATED_SHA256:
        raise ValueError(f"Hash MAP02 4.29.0ah inesperado: {digest}")


def rebuild_map02(path: Path = MAP02) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map02_is_updated(blocks):
        validate_map02(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != MAP02_BASE_COUNTS or digest != MAP02_BASE_SHA256:
        raise ValueError(
            "MAP02 no coincide con la base aceptada 4.29.0ad: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_map02_content(blocks)
    apply_sewer_textures_everywhere(blocks)

    lumps[text_index] = (b"TEXTMAP", render_textmap(header, blocks).encode("utf-8"))
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_map02(path, written_blocks)
    return True


def main() -> None:
    changed01 = rebuild_map01()
    changed02 = rebuild_map02()
    print(
        "MAP01: perimetro, corredor y segundo piso 4.29.0ah aplicados"
        if changed01
        else "MAP01: arquitectura 4.29.0ah ya presente"
    )
    print(
        "MAP02: superficies completas de alcantarilla 4.29.0ah aplicadas"
        if changed02
        else "MAP02: superficies completas de alcantarilla ya presentes"
    )


if __name__ == "__main__":
    main()
