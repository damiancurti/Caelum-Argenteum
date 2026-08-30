"""Completa la ampliación oriental de MAP01 para V4.29.0ab.

La entrada autorizada es exclusivamente MAP01 de 4.29.0aa. El incremento
cierra la U oriental contra la habitación trasera, abre el muro que quedaría
en medio, prolonga el cerramiento hasta planta baja, cubre todo el recinto y
extiende el balcón exterior a todo el ancho de la nueva fachada. El manual de
procesamiento y el resto de la geometría aceptada permanecen intactos.
"""

from __future__ import annotations

from collections import Counter, OrderedDict
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
    get_or_add_vertex,
    line_positions,
    make_room_sector,
    make_side,
)
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import (
    attach_boundary,
    boundary_vertices,
    edge_indices,
    prepare_boundary,
    validate_closed_sector,
)
from rebuild_4_29_0v_maps import (
    door_group_counts,
    sector_bounds,
    validate_upper_gate,
)
from rebuild_4_29_0w_maps import map_counts, validate_target_sectors
from rebuild_4_29_0y_maps import east_stair_indices
from rebuild_4_29_0aa_maps import (
    PROCESSING_MANUAL_DOOMEDNUM,
    processing_manuals,
    validate_updated_map as validate_0aa_map,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

BASE_COUNTS = (544, 730, 1430, 159, 221)
BASE_SHA256 = "b0d92e3c3ba0a17f59aa160796817aac221a5585c815ac41290eb5eab8d4d9ae"

UPDATED_COUNTS = (568, 777, 1520, 176, 221)
UPDATED_SHA256 = "03a16179216566bb0bdc521f1ff331c1d4b27cc48a2c4ed7a91a3e855ef8b0f0"

WORLD_SECTOR = 0
NORTH_EAST_BASE = 53
SOUTH_EAST_BASE = 57
EAST_ANNEX_SECTOR = 65
EXISTING_UPPER_WALL_SECTOR = 93

FLOOR_ROOF_TAG = 510
UPPER_WALL_TAG = 511
OPEN_FLOOR_TAG = 514
ROOF_ONLY_TAG = 515
FULL_HEIGHT_WALL_TAG = 516

# Las tres piezas de 4.29.0z pasan de 128..256 MU a 0..256 MU.
EXISTING_U_WALL_SECTORS = (156, 157, 158)

# La pared antigua X=1201..1209 se abre desde Y=-383 hasta Y=383. Sus tres
# piezas centrales ya son sectores independientes; los extremos se tallan.
EXISTING_INTERNAL_WALL_SECTORS = (106, 107, 108)
INTERNAL_WALL_OPENINGS = (
    (1201.0, -383.0, 1209.0, -192.0),
    (1201.0, 192.0, 1209.0, 383.0),
)

# El hueco de 97 MU entre la habitación trasera y la U se convierte en parte
# de la misma habitación. X=1305 es una frontera heredada y se conserva como
# corte determinista de un MU.
ROOM_JOIN_RECTANGLES = (
    ((1209.0, -383.0, 1305.0, -96.0), SOUTH_EAST_BASE),
    ((1305.0, -383.0, 1306.0, -96.0), WORLD_SECTOR),
    ((1305.0, -96.0, 1306.0, 96.0), WORLD_SECTOR),
    ((1209.0, 96.0, 1305.0, 383.0), NORTH_EAST_BASE),
    ((1305.0, 96.0, 1306.0, 383.0), WORLD_SECTOR),
)

# Los extremos de la U se unen al perímetro existente. Todas estas piezas y
# las tres paredes originales reciben un volumen sólido de suelo a techo.
CONNECTOR_WALLS = (
    ((1209.0, -391.0, 1305.0, -383.0), SOUTH_EAST_BASE),
    ((1305.0, -391.0, 1306.0, -383.0), WORLD_SECTOR),
    ((1209.0, 383.0, 1305.0, 391.0), NORTH_EAST_BASE),
    ((1305.0, 383.0, 1306.0, 391.0), WORLD_SECTOR),
)

# La plataforma previa sólo alcanzaba Y=±272 al este de X=1544. Estas dos
# celdas completan la losa y cubierta en las esquinas interiores hasta la U.
# Las franjas X=1306..1544 ya pertenecen al sector anfitrión 65 y sólo deben
# recibir su nueva etiqueta de piso y techo; no se vuelven a tallar.
INTERIOR_CORNER_SLABS = (
    (1544.0, -383.0, 1689.0, -272.0),
    (1544.0, 272.0, 1689.0, 383.0),
)

# El balcón conserva los 272 MU de fondo que ya tenía la plataforma y ahora
# ocupa todo el ancho de la fachada nueva: Y=-391..391. Sólo recibe piso.
BALCONY_RECTANGLES = (
    (1697.0, -391.0, 1969.0, -272.0),
    (1697.0, -272.0, 1969.0, 272.0),
    (1697.0, 272.0, 1969.0, 391.0),
)

CONTROL_RECTANGLE = (31180.0, 31000.0, 31228.0, 31048.0)


def side_sector(blocks, line, side_name: str) -> int | None:
    side_index = integer(line, side_name)
    if side_index is None:
        return None
    return integer(blocks["sidedef"][side_index], "sector")


def add_one_sided_line(blocks, first, second, sector_index: int, special=False) -> None:
    start = get_or_add_vertex(blocks, first)
    end = get_or_add_vertex(blocks, second)
    side_index = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(sector_index))
    line = OrderedDict(
        (
            ("v1", str(start)),
            ("v2", str(end)),
            ("sidefront", str(side_index)),
        )
    )
    if special:
        line["special"] = "160"
        line["arg0"] = str(FULL_HEIGHT_WALL_TAG)
        line["arg1"] = "1"
        line["arg2"] = "0"
        line["arg3"] = "255"
    blocks["linedef"].append(line)


def add_full_height_wall_control(blocks) -> int:
    for line in blocks["linedef"]:
        if (
            integer(line, "special") == 160
            and integer(line, "arg0") == FULL_HEIGHT_WALL_TAG
        ):
            front = integer(line, "sidefront")
            return integer(blocks["sidedef"][front], "sector")

    control = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", "0"),
                ("heightceiling", "256"),
                ("texturefloor", '"CMIN01"'),
                ("textureceiling", '"CMIN01"'),
                ("lightlevel", "176"),
            )
        )
    )
    minimum_x, minimum_y, maximum_x, maximum_y = CONTROL_RECTANGLE
    points = (
        (minimum_x, minimum_y),
        (minimum_x, maximum_y),
        (maximum_x, maximum_y),
        (maximum_x, minimum_y),
    )
    for index, first in enumerate(points):
        add_one_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            control,
            special=index == 0,
        )
    return control


def attach_boundary_from_hosts(
    blocks,
    first: tuple[float, float],
    second: tuple[float, float],
    target_sector: int,
    allowed_hosts: set[int],
    outside_sector: int,
) -> None:
    """Talla un borde cuyo interior puede pertenecer a más de un sector base."""

    prepare_boundary(blocks, first, second)
    points = boundary_vertices(blocks, first, second)
    for start, end in zip(points[:-1], points[1:]):
        matches = edge_indices(blocks, start, end)
        if not matches:
            add_two_sided_line(
                blocks,
                start,
                end,
                target_sector,
                outside_sector,
            )
            continue

        candidates = []
        for match in matches:
            line = blocks["linedef"][match]
            existing_first, existing_second = line_positions(blocks, line)
            inside_side = (
                "sidefront"
                if (existing_first, existing_second) == (start, end)
                else "sideback"
            )
            inside_index = integer(line, inside_side)
            if inside_index is None:
                continue
            previous_sector = integer(blocks["sidedef"][inside_index], "sector")
            if previous_sector in allowed_hosts:
                # Los mapas heredados contienen algunos bordes coincidentes.
                # Se prefiere el sector anfitrión 65, que representa la losa
                # oriental, antes que tomar una cara del sector mundial.
                priority = 0 if previous_sector == EAST_ANNEX_SECTOR else 1
                candidates.append((priority, match, inside_index, previous_sector))
        if not candidates:
            raise ValueError(
                f"El borde {start} -> {end} no ofrece un lado de "
                f"{sorted(allowed_hosts)}"
            )
        _, _, inside_index, _ = min(candidates)
        blocks["sidedef"][inside_index]["sector"] = str(target_sector)


def carve_mixed_rectangle(
    blocks,
    rectangle,
    tag: int,
    allowed_hosts: set[int],
    outside_sector: int = WORLD_SECTOR,
) -> int:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    target_sector = len(blocks["sector"])
    blocks["sector"].append(make_room_sector(tag))
    points = (
        (minimum_x, minimum_y),
        (minimum_x, maximum_y),
        (maximum_x, maximum_y),
        (maximum_x, minimum_y),
    )
    for index, first in enumerate(points):
        attach_boundary_from_hosts(
            blocks,
            first,
            points[(index + 1) % len(points)],
            target_sector,
            allowed_hosts,
            outside_sector,
        )
    return target_sector


def tagged_sector_at(blocks, rectangle, tag: int) -> int:
    matches = [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == tag
        and sector_bounds(blocks, index) == rectangle
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Rectángulo {rectangle} con tag {tag}: {len(matches)} coincidencias"
        )
    return matches[0]


def validate_architecture(blocks) -> None:
    for sector_index in EXISTING_U_WALL_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != FULL_HEIGHT_WALL_TAG:
            raise ValueError(f"La pared U {sector_index} no llega a planta baja")

    for rectangle, _ in CONNECTOR_WALLS:
        validate_closed_sector(
            blocks,
            tagged_sector_at(blocks, rectangle, FULL_HEIGHT_WALL_TAG),
        )

    for rectangle in INTERNAL_WALL_OPENINGS + INTERIOR_CORNER_SLABS:
        validate_closed_sector(
            blocks,
            tagged_sector_at(blocks, rectangle, FLOOR_ROOF_TAG),
        )

    for rectangle, _ in ROOM_JOIN_RECTANGLES:
        validate_closed_sector(
            blocks,
            tagged_sector_at(blocks, rectangle, FLOOR_ROOF_TAG),
        )

    for rectangle in BALCONY_RECTANGLES:
        validate_closed_sector(
            blocks,
            tagged_sector_at(blocks, rectangle, OPEN_FLOOR_TAG),
        )

    for sector_index in EXISTING_INTERNAL_WALL_SECTORS + (65, 66, 67, 68, 101):
        if integer(blocks["sector"][sector_index], "id") != FLOOR_ROOF_TAG:
            raise ValueError(f"El sector interior {sector_index} quedó sin techo")

    if len(processing_manuals(blocks)) != 1:
        raise ValueError("El manual de procesamiento no se conservó")
    if integer(processing_manuals(blocks)[0], "type") != PROCESSING_MANUAL_DOOMEDNUM:
        raise ValueError("El manual de procesamiento cambió de clase")


def validate_updated_map(path: Path, blocks) -> None:
    if UPDATED_COUNTS is not None and map_counts(blocks) != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0ab inesperada: {map_counts(blocks)}")

    validate_architecture(blocks)
    identifiers = Counter(integer(sector, "id") for sector in blocks["sector"])
    if identifiers[FULL_HEIGHT_WALL_TAG] != 7:
        raise ValueError(
            f"Sectores con tag 516: {identifiers[FULL_HEIGHT_WALL_TAG]}, esperados 7"
        )
    if identifiers[OPEN_FLOOR_TAG] != 3:
        raise ValueError(
            f"Sectores de balcón: {identifiers[OPEN_FLOOR_TAG]}, esperados 3"
        )

    controls = [
        line
        for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") == FULL_HEIGHT_WALL_TAG
    ]
    if len(controls) != 1:
        raise ValueError(f"Controles del tag 516: {len(controls)}, esperado 1")

    for sector_index in east_stair_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La escalera oriental {sector_index} perdió su techo")

    validate_target_sectors(blocks)
    if door_group_counts(blocks)[912] != 2:
        raise ValueError("El portón superior no conserva sus dos hojas")
    validate_upper_gate(blocks)
    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if UPDATED_SHA256 is not None and digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0ab inesperado: {digest}")


def is_updated(blocks) -> bool:
    return any(
        integer(line, "special") == 160
        and integer(line, "arg0") == FULL_HEIGHT_WALL_TAG
        for line in blocks["linedef"]
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

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0aa: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_0aa_map(path, blocks)

    add_full_height_wall_control(blocks)
    for sector_index in EXISTING_U_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FULL_HEIGHT_WALL_TAG)

    for sector_index in EXISTING_INTERNAL_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FLOOR_ROOF_TAG)
    for rectangle in INTERNAL_WALL_OPENINGS:
        attach_sector = len(blocks["sector"])
        blocks["sector"].append(make_room_sector(FLOOR_ROOF_TAG))
        minimum_x, minimum_y, maximum_x, maximum_y = rectangle
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
                attach_sector,
                EXISTING_UPPER_WALL_SECTOR,
            )

    blocks["sector"][101]["id"] = str(FLOOR_ROOF_TAG)
    for rectangle, host_sector in ROOM_JOIN_RECTANGLES:
        attach_sector = len(blocks["sector"])
        blocks["sector"].append(make_room_sector(FLOOR_ROOF_TAG))
        minimum_x, minimum_y, maximum_x, maximum_y = rectangle
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
                attach_sector,
                host_sector,
            )

    for rectangle, host_sector in CONNECTOR_WALLS:
        attach_sector = len(blocks["sector"])
        blocks["sector"].append(make_room_sector(FULL_HEIGHT_WALL_TAG))
        minimum_x, minimum_y, maximum_x, maximum_y = rectangle
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
                attach_sector,
                host_sector,
            )

    mixed_hosts = {WORLD_SECTOR, EAST_ANNEX_SECTOR}
    for rectangle in INTERIOR_CORNER_SLABS:
        carve_mixed_rectangle(
            blocks,
            rectangle,
            FLOOR_ROOF_TAG,
            mixed_hosts,
        )

    previous_balcony_sectors: set[int] = set()
    for rectangle in BALCONY_RECTANGLES:
        target = carve_mixed_rectangle(
            blocks,
            rectangle,
            OPEN_FLOOR_TAG,
            mixed_hosts | previous_balcony_sectors,
        )
        previous_balcony_sectors.add(target)

    for sector_index in (65, 66, 67, 68):
        blocks["sector"][sector_index]["id"] = str(FLOOR_ROOF_TAG)

    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(
        data for name, data in written_lumps if name == b"TEXTMAP"
    )
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_updated_map(path, written_blocks)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: ampliación oriental 4.29.0ab aplicada"
        if changed
        else "MAP01: ampliación oriental 4.29.0ab ya presente"
    )
