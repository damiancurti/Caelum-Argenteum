"""Cierra el primer piso de MAP01 y prepara la base del segundo.

La entrada autorizada es el MAP01 4.29.0t, idéntico al 4.29.0r aceptado.
La intervención no reconstruye habitaciones ni puertas: completa la losa del
hueco central, une las alas norte y sur con muros finitos al oeste y al este,
conserva un vano de entrada de 128 MU, cubre únicamente el interior y deja
descubierto el balcón oriental de 96 MU. Los cuatro descansos interiores
también reciben cubierta.
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
    clone_line_segment,
    get_or_add_vertex,
    line_positions,
    make_room_sector,
    split_vertical_lines,
    vertex_position,
)
from rebuild_4_29_0p_maps import LANDINGS
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "9c307fb31ac88a29d6ff8e6fb851776e43dfdff3207ed90a38b4d0e8bef4f346"
BASE_COUNTS = (468, 587, 1144, 101, 218)

UPDATED_SHA256 = "cd5db426b51570a2a4715223cd0a6bb8afb9373192b67d64fe7263371bcf7d9b"
UPDATED_COUNTS = (516, 690, 1350, 146, 218)

FLOOR_ROOF_TAG = 510
WALL_TAG = 511
OPEN_FLOOR_TAG = 514
ROOF_ONLY_TAG = 515

WORLD_SECTOR = 0
NORTH_WEST_BASE = 37
NORTH_CENTRAL_BASE = 41
NORTH_EAST_BASE = 53
SOUTH_WEST_BASE = 45
SOUTH_CENTRAL_BASE = 49
SOUTH_EAST_BASE = 57

NORTH_DOOR_SECTORS = (38, 39, 40, 42, 43, 44, 54, 55, 56)
SOUTH_DOOR_SECTORS = (46, 47, 48, 50, 51, 52, 58, 59, 60)
INTERIOR_STAIR_SECTORS = tuple(range(1, 25))

# El único puente sin techo es el balcón oriental, fuera del cerramiento.
OPEN_FLOOR_RECTANGLES = (
    ("balcon_este", (1209.0, -96.0, 1305.0, 96.0), WORLD_SECTOR),
)

# Los muros cruzan las divisiones base Y=-96/96. El muro occidental conserva
# el vano principal Y=-64..64; el oriental es continuo. Todos reciben el
# mismo volumen 3D 128..256 del tag 511.
WALL_RECTANGLES = (
    ("muro_oeste_sur", (-473.0, -192.0, -465.0, -96.0), SOUTH_WEST_BASE),
    ("muro_oeste_vano_sur", (-473.0, -96.0, -465.0, -64.0), WORLD_SECTOR),
    ("muro_oeste_vano_norte", (-473.0, 64.0, -465.0, 96.0), WORLD_SECTOR),
    ("muro_oeste_norte", (-473.0, 96.0, -465.0, 192.0), NORTH_WEST_BASE),
    ("muro_este_sur", (1201.0, -192.0, 1209.0, -96.0), SOUTH_EAST_BASE),
    ("muro_este_centro", (1201.0, -96.0, 1209.0, 96.0), WORLD_SECTOR),
    ("muro_este_norte", (1201.0, 96.0, 1209.0, 192.0), NORTH_EAST_BASE),
)

# Celdas de sector 0 que necesitan simultáneamente piso y techo. Se excluyen
# los huecos de escalera; los umbrales existentes se retaguean por separado.
CENTRAL_FLOOR_ROOF_RECTANGLES = (
    ("vestibulo_oeste", (-569.0, -96.0, -473.0, 96.0), WORLD_SECTOR),
    ("vano_oeste", (-473.0, -64.0, -465.0, 64.0), WORLD_SECTOR),
    ("centro", (-465.0, -72.0, 1201.0, 72.0), WORLD_SECTOR),
    ("norte_oeste", (-465.0, 72.0, -377.0, 96.0), WORLD_SECTOR),
    ("norte_entre_puerta_escalera", (-217.0, 72.0, -24.0, 96.0), WORLD_SECTOR),
    ("norte_escalera_oeste_previa", (-24.0, 72.0, 95.0, 80.0), WORLD_SECTOR),
    ("norte_entre_escalera_puerta", (95.0, 72.0, 288.0, 96.0), WORLD_SECTOR),
    ("norte_entre_puertas", (448.0, 72.0, 641.0, 96.0), WORLD_SECTOR),
    ("norte_escalera_este_previa", (641.0, 72.0, 760.0, 80.0), WORLD_SECTOR),
    ("norte_este", (760.0, 72.0, 953.0, 96.0), WORLD_SECTOR),
    ("norte_final", (1113.0, 72.0, 1201.0, 96.0), WORLD_SECTOR),
    ("sur_oeste", (-465.0, -96.0, -377.0, -72.0), WORLD_SECTOR),
    ("sur_entre_puerta_escalera", (-217.0, -96.0, -24.0, -72.0), WORLD_SECTOR),
    ("sur_escalera_oeste_previa", (-24.0, -80.0, 95.0, -72.0), WORLD_SECTOR),
    ("sur_entre_escalera_puerta", (95.0, -96.0, 288.0, -72.0), WORLD_SECTOR),
    ("sur_entre_puertas", (448.0, -96.0, 641.0, -72.0), WORLD_SECTOR),
    ("sur_escalera_este_previa", (641.0, -80.0, 760.0, -72.0), WORLD_SECTOR),
    ("sur_este", (760.0, -96.0, 953.0, -72.0), WORLD_SECTOR),
    ("sur_final", (1113.0, -96.0, 1201.0, -72.0), WORLD_SECTOR),
    ("franja_noroeste", (-465.0, 96.0, -25.0, 192.0), NORTH_WEST_BASE),
    ("franja_norte_central", (96.0, 96.0, 640.0, 192.0), NORTH_CENTRAL_BASE),
    ("franja_noreste", (761.0, 96.0, 1201.0, 192.0), NORTH_EAST_BASE),
    ("franja_suroeste", (-465.0, -192.0, -25.0, -96.0), SOUTH_WEST_BASE),
    ("franja_sur_central", (96.0, -192.0, 640.0, -96.0), SOUTH_CENTRAL_BASE),
    ("franja_sureste", (761.0, -192.0, 1201.0, -96.0), SOUTH_EAST_BASE),
)

# Estas tiras de un MU eran separación estructural de las escaleras. Los
# descansos ya tienen el piso del tag 100. Ambos grupos reciben sólo cubierta:
# añadir otro piso superpuesto produciría solapamientos o cerraría el ascenso.
ROOF_ONLY_RECTANGLES = (
    ("junta_noroeste_1", (-25.0, 96.0, -24.0, 192.0), WORLD_SECTOR),
    ("junta_noroeste_2", (95.0, 96.0, 96.0, 192.0), WORLD_SECTOR),
    ("junta_noreste_1", (640.0, 96.0, 641.0, 192.0), WORLD_SECTOR),
    ("junta_noreste_2", (760.0, 96.0, 761.0, 192.0), WORLD_SECTOR),
    ("junta_suroeste_1", (-25.0, -192.0, -24.0, -96.0), WORLD_SECTOR),
    ("junta_suroeste_2", (95.0, -192.0, 96.0, -96.0), WORLD_SECTOR),
    ("junta_sureste_1", (640.0, -192.0, 641.0, -96.0), WORLD_SECTOR),
    ("junta_sureste_2", (760.0, -192.0, 761.0, -96.0), WORLD_SECTOR),
    ("descanso_noroeste", LANDINGS[0], 72),
    ("descanso_noreste", LANDINGS[1], 74),
    ("descanso_suroeste", LANDINGS[2], 76),
    ("descanso_sureste", LANDINGS[3], 78),
)


def split_horizontal_lines(blocks, y: float, cuts: tuple[float, ...]) -> None:
    """Equivalente horizontal del divisor vertical ya validado."""

    original_count = len(blocks["linedef"])
    for index in range(original_count):
        line = blocks["linedef"][index]
        first, second = line_positions(blocks, line)
        if first[1] != y or second[1] != y or first[0] == second[0]:
            continue
        low = min(first[0], second[0])
        high = max(first[0], second[0])
        applicable = sorted(cut for cut in cuts if low < cut < high)
        if not applicable:
            continue
        ordered = applicable if first[0] < second[0] else list(reversed(applicable))
        points = [first] + [(cut, y) for cut in ordered] + [second]
        line["v1"] = str(get_or_add_vertex(blocks, points[0]))
        line["v2"] = str(get_or_add_vertex(blocks, points[1]))
        for segment in range(1, len(points) - 1):
            clone_line_segment(
                blocks,
                line,
                points[segment],
                points[segment + 1],
            )


def line_sector_indices(blocks, line) -> list[int]:
    return [
        integer(blocks["sidedef"][integer(line, side_name)], "sector")
        for side_name in ("sidefront", "sideback")
        if side_name in line
    ]


def edge_indices(blocks, first, second) -> list[int]:
    expected = {first, second}
    return [
        index
        for index, line in enumerate(blocks["linedef"])
        if set(line_positions(blocks, line)) == expected
    ]


def boundary_vertices(blocks, first, second) -> list[tuple[float, float]]:
    """Devuelve todos los vértices existentes sobre un tramo ortogonal."""

    if first[0] == second[0]:
        low, high = sorted((first[1], second[1]))
        points = {
            vertex_position(blocks, index)
            for index in range(len(blocks["vertex"]))
            if vertex_position(blocks, index)[0] == first[0]
            and low <= vertex_position(blocks, index)[1] <= high
        }
        points.update((first, second))
        return sorted(points, key=lambda point: point[1], reverse=first[1] > second[1])

    if first[1] == second[1]:
        low, high = sorted((first[0], second[0]))
        points = {
            vertex_position(blocks, index)
            for index in range(len(blocks["vertex"]))
            if vertex_position(blocks, index)[1] == first[1]
            and low <= vertex_position(blocks, index)[0] <= high
        }
        points.update((first, second))
        return sorted(points, key=lambda point: point[0], reverse=first[0] > second[0])

    raise ValueError(f"Borde no ortogonal: {first} -> {second}")


def prepare_boundary(blocks, first, second) -> None:
    if first[0] == second[0]:
        cuts = tuple(point[1] for point in boundary_vertices(blocks, first, second))
        split_vertical_lines(blocks, first[0], cuts)
    else:
        cuts = tuple(point[0] for point in boundary_vertices(blocks, first, second))
        split_horizontal_lines(blocks, first[1], cuts)


def attach_boundary(
    blocks,
    first: tuple[float, float],
    second: tuple[float, float],
    target_sector: int,
    host_sector: int,
) -> None:
    prepare_boundary(blocks, first, second)
    points = boundary_vertices(blocks, first, second)
    for start, end in zip(points[:-1], points[1:]):
        matches = edge_indices(blocks, start, end)
        if len(matches) > 1:
            raise ValueError(f"Borde duplicado en {start} -> {end}")
        if not matches:
            add_two_sided_line(blocks, start, end, target_sector, host_sector)
            continue

        line = blocks["linedef"][matches[0]]
        host_sides = [
            side_name
            for side_name in ("sidefront", "sideback")
            if side_name in line
            and integer(
                blocks["sidedef"][integer(line, side_name)], "sector"
            ) == host_sector
        ]
        if len(host_sides) != 1:
            sectors = line_sector_indices(blocks, line)
            raise ValueError(
                f"El borde {start} -> {end} no conserva un único lado "
                f"del sector base {host_sector}: {sectors}"
            )
        side = integer(line, host_sides[0])
        blocks["sidedef"][side]["sector"] = str(target_sector)


def rectangle_has_internal_lines(blocks, rectangle) -> bool:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
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
            return True
    return False


def carve_rectangle(blocks, rectangle, host_sector: int, tag: int) -> int:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    if minimum_x >= maximum_x or minimum_y >= maximum_y:
        raise ValueError(f"Rectángulo inválido: {rectangle}")
    if rectangle_has_internal_lines(blocks, rectangle):
        raise ValueError(f"El rectángulo invade geometría existente: {rectangle}")

    target_sector = len(blocks["sector"])
    blocks["sector"].append(make_room_sector(tag))
    points = (
        (minimum_x, minimum_y),
        (minimum_x, maximum_y),
        (maximum_x, maximum_y),
        (maximum_x, minimum_y),
    )
    for index, first in enumerate(points):
        attach_boundary(
            blocks,
            first,
            points[(index + 1) % len(points)],
            target_sector,
            host_sector,
        )
    return target_sector


def add_control_link(blocks, control_sector: int, tag: int) -> None:
    for line in blocks["linedef"]:
        if integer(line, "special") == 160 and integer(line, "arg0") == tag:
            return

    candidates = []
    for line in blocks["linedef"]:
        front = integer(line, "sidefront")
        if front is None:
            continue
        if integer(blocks["sidedef"][front], "sector") != control_sector:
            continue
        if integer(line, "special") is None:
            candidates.append(line)
    if not candidates:
        raise ValueError(f"El control {control_sector} no tiene una línea libre")

    line = candidates[0]
    line["special"] = "160"
    line["arg0"] = str(tag)
    line["arg1"] = "1"
    line["arg2"] = "0"
    line["arg3"] = "255"


def find_control_sector(blocks, floor: int, ceiling: int, tag: int) -> int:
    for index, sector in enumerate(blocks["sector"]):
        if integer(sector, "heightfloor") != floor:
            continue
        if integer(sector, "heightceiling") != ceiling:
            continue
        for line in blocks["linedef"]:
            front = integer(line, "sidefront")
            if front is None:
                continue
            if integer(blocks["sidedef"][front], "sector") != index:
                continue
            if integer(line, "special") == 160 and integer(line, "arg0") == tag:
                return index
    raise ValueError(f"No se encontró el control {floor}..{ceiling} del tag {tag}")


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
        raise ValueError(f"Sector {sector_index} sin cierre canónico: {failures}")


def door_groups(blocks) -> list[int]:
    return [
        integer(thing, "arg0")
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
    ]


def validate_updated_map(path: Path, blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if UPDATED_COUNTS is not None and counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0u inesperada: {counts}")

    controls = [
        (integer(line, "arg0"), integer(line, "sidefront"))
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in (510, 511, 514, 515)
    ]
    tags = [tag for tag, _ in controls]
    expected_controls = {510: 2, 511: 1, 514: 1, 515: 1}
    for tag, expected in expected_controls.items():
        if tags.count(tag) != expected:
            raise ValueError(
                f"Controles del tag {tag}: {tags.count(tag)}, esperados {expected}"
            )

    identifiers = [integer(sector, "id") for sector in blocks["sector"]]
    expected_targets = {510: 51, 511: 11, 514: 1, 515: 36}
    for tag, expected in expected_targets.items():
        if identifiers.count(tag) != expected:
            raise ValueError(
                f"Sectores objetivo del tag {tag}: {identifiers.count(tag)}, "
                f"esperados {expected}"
            )

    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)

    for index, sector in enumerate(blocks["sector"]):
        if integer(sector, "id") in (510, 511, 514, 515):
            validate_closed_sector(blocks, index)

    groups = door_groups(blocks)
    for group in (902, 905, 906, 907, 908, 909, 910, 911):
        if groups.count(group) != (2 if group in (910, 911) else 1):
            raise ValueError(f"Cantidad inesperada de hojas para la puerta {group}")

    # El balcón oriental queda fuera del muro X=1201..1209 y sólo recibe piso.
    if not any(integer(sector, "id") == OPEN_FLOOR_TAG for sector in blocks["sector"]):
        raise ValueError("Falta el piso exterior del balcón")
    for point in (
        (1209.0, -96.0),
        (1305.0, 96.0),
        (-569.0, -96.0),
        (-473.0, 96.0),
        (-473.0, -64.0),
        (-473.0, 64.0),
    ):
        if point not in {
            vertex_position(blocks, index)
            for index in range(len(blocks["vertex"]))
        }:
            raise ValueError(f"Falta un extremo de la losa exterior: {point}")

    digest = sha256(path.read_bytes()).hexdigest()
    if UPDATED_SHA256 and digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0u inesperado: {digest}")


def is_updated(blocks) -> bool:
    identifiers = [integer(sector, "id") for sector in blocks["sector"]]
    control_tags = [
        integer(line, "arg0")
        for line in blocks["linedef"]
        if integer(line, "special") == 160
    ]
    return (
        OPEN_FLOOR_TAG in identifiers
        and ROOF_ONLY_TAG in identifiers
        and OPEN_FLOOR_TAG in control_tags
        and ROOF_ONLY_TAG in control_tags
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_updated_map(path, blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0t: {counts}, {digest}"
        )

    floor_control = find_control_sector(blocks, 128, 136, FLOOR_ROOF_TAG)
    roof_control = find_control_sector(blocks, 256, 264, FLOOR_ROOF_TAG)
    add_control_link(blocks, floor_control, OPEN_FLOOR_TAG)
    add_control_link(blocks, roof_control, ROOF_ONLY_TAG)

    for sector_index in NORTH_DOOR_SECTORS + SOUTH_DOOR_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FLOOR_ROOF_TAG)
    for sector_index in INTERIOR_STAIR_SECTORS:
        blocks["sector"][sector_index]["id"] = str(ROOF_ONLY_TAG)

    for _, rectangle, host in OPEN_FLOOR_RECTANGLES:
        carve_rectangle(blocks, rectangle, host, OPEN_FLOOR_TAG)
    for _, rectangle, host in WALL_RECTANGLES:
        carve_rectangle(blocks, rectangle, host, WALL_TAG)
    for _, rectangle, host in CENTRAL_FLOOR_ROOF_RECTANGLES:
        carve_rectangle(blocks, rectangle, host, FLOOR_ROOF_TAG)
    for _, rectangle, host in ROOF_ONLY_RECTANGLES:
        carve_rectangle(blocks, rectangle, host, ROOF_ONLY_TAG)

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(path, signature, lumps)

    # Validar los bytes realmente escritos y no sólo la representación previa.
    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_updated_map(path, written_blocks)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: cierre del primer piso 4.29.0u aplicado"
        if changed
        else "MAP01: cierre del primer piso 4.29.0u ya presente"
    )
