"""Reconstruye MAP01 y MAP02 para el candidato V4.29.0ac.

MAP01 parte exclusivamente del WAD aceptado de 4.29.0ab. Restaura los muros
de las habitaciones traseras que 0ab abrió por error, completa la losa entre
las escaleras orientales, retrae el cerramiento para conservar un balcón
lateral de 96 MU y prepara un acceso exterior convergente al segundo piso.

MAP02 reemplaza los seis recintos locales obsoletos por salas físicas de
percepción y conserva exactamente los 15.000 actores del campo masivo. Ningún
constructor modifica un mapa cuya estructura o hash no coincida con la base
autorizada.
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
    compact_geometry,
    get_or_add_vertex,
    line_positions,
    make_room_sector,
    make_side,
)
from rebuild_4_29_0q_maps import (
    make_door,
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import (
    attach_boundary,
    carve_rectangle,
    validate_closed_sector,
)
from rebuild_4_29_0v_maps import door_group_counts, sector_bounds, validate_upper_gate
from rebuild_4_29_0w_maps import map_counts, validate_target_sectors
from rebuild_4_29_0y_maps import east_stair_indices
from rebuild_4_29_0aa_maps import (
    PROCESSING_MANUAL_DOOMEDNUM,
    processing_manuals,
)
from rebuild_4_29_0ab_maps import validate_updated_map as validate_0ab_map


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = (568, 777, 1520, 176, 221)
MAP01_BASE_SHA256 = (
    "03a16179216566bb0bdc521f1ff331c1d4b27cc48a2c4ed7a91a3e855ef8b0f0"
)

# Se fijan después de generar y auditar la primera salida determinista.
MAP01_UPDATED_COUNTS = (676, 918, 1754, 221, 223)
MAP01_UPDATED_SHA256 = (
    "41085aa4eafffae7d4d24706b31f3aa8e6900c22103d9b2bde0ed40c8498fd67"
)

MAP02_BASE_COUNTS = (80, 72, 136, 1, 16610)
MAP02_BASE_SHA256 = (
    "a51500ffc52ad36fb3918cb807e242ff6d2b3b115556721c68b766e80550b73c"
)
MAP02_UPDATED_COUNTS = (112, 110, 212, 9, 16508)
MAP02_UPDATED_SHA256 = (
    "88956e5074fe4e0ae097cfb539b67a4e0a3b6f33407bddcfcdfb7b73ce8180a9"
)

PERCEPTION_OBSERVER_DOOMEDNUM = 18208
PHYSICS_MONITOR_DOOMEDNUM = 18220
LOCAL_DIAGNOSTIC_TYPES = (18029, 18200, 18201, 18202, 18203, 18204)
MASS_FIELD_TYPES = tuple(range(18020, 18036))

# Seis salas físicas reemplazan los antiguos recintos de Look/Chase/disparo.
# Cada entrada tiene 200 MU y todos los muros son sectores elevados de 128 MU,
# de modo que bloquean realmente movimiento y visión.
PERCEPTION_ROOMS = (
    (-800.0, 1200.0, 1400.0, 3800.0),
    (1800.0, 1200.0, 4000.0, 3800.0),
    (4400.0, 1200.0, 7800.0, 3800.0),
    (-800.0, -3800.0, 1400.0, -1200.0),
    (1800.0, -3800.0, 4000.0, -1200.0),
    (4400.0, -3800.0, 7800.0, -1200.0),
)

# x, y, angle, Perspicacia, sala. Norte mira hacia el acceso sur; sur mira
# hacia el acceso norte. Las salas 3 y 6 reciben divisores de oclusión.
PERCEPTION_OBSERVERS = (
    (300.0, 3400.0, 270, 0, 1),
    (2900.0, 2600.0, 270, 50, 2),
    (6100.0, 3400.0, 270, 100, 3),
    (300.0, -3400.0, 90, 0, 4),
    (2900.0, -2600.0, 90, 50, 5),
    (6100.0, -3400.0, 90, 100, 6),
)

WALL_THICKNESS = 16.0
ROOM_ENTRY_HALF_WIDTH = 100.0

WORLD_SECTOR = 0
EAST_ANNEX_SECTOR = 65
FLOOR_ROOF_TAG = 510
UPPER_WALL_TAG = 511
OPEN_FLOOR_TAG = 514
ROOF_ONLY_TAG = 515
FULL_HEIGHT_WALL_TAG = 516

STAIR_TAGS = tuple(range(530, 538))
SECOND_FLOOR_LANDING_TAG = 538
SECOND_FLOOR_FRAME_TAG = 539
SECOND_FLOOR_LOWER_CENTER_TAG = 540
SECOND_FLOOR_GATE_GROUP = 913

# 0ab abrió también estos dos tramos de la pared perimetral de las habitaciones
# traseras. Sólo los sectores 106--108 pertenecen a la abertura intermedia.
REAR_ROOM_WALL_SECTORS = (160, 161)

# Los tres muros de la U de 0ab ocupaban el borde exterior de la plataforma.
# Se convierten en superficie transitable antes de tallar el nuevo cerramiento
# retranqueado, de modo que el balcón lateral conserve 96 MU útiles.
OBSOLETE_U_WALL_SECTORS = (156, 157, 158)

# El área entre ambas escaleras no es un hueco de circulación. La prolongación
# completa el piso del primer nivel y la cubierta del pasillo inferior.
STAIR_CENTER_SLAB = (1306.0, -80.0, 1401.0, 80.0)

# La pared mantiene el enlace trasero ya aceptado en Y=±383 y luego se retrae.
# Los laterales quedan a 96 MU del borde exterior Y=±391.
RETRACTED_SIDE_WALLS = (
    ((1306.0, -295.0, 1544.0, -287.0), EAST_ANNEX_SECTOR),
    ((1544.0, -295.0, 1689.0, -287.0), 171),
    ((1306.0, 287.0, 1544.0, 295.0), EAST_ANNEX_SECTOR),
    ((1544.0, 287.0, 1689.0, 295.0), 172),
)
RETRACTED_TRANSITION_WALLS = (
    ((1306.0, -383.0, 1314.0, -295.0), EAST_ANNEX_SECTOR),
    ((1306.0, 295.0, 1314.0, 383.0), EAST_ANNEX_SECTOR),
)

# Los corredores laterales usan sólo la losa de piso: no reciben la cubierta
# interior del tag 510. Las piezas de esquina proceden del antiguo muro frontal.
SIDE_BALCONY_RECTANGLES = (
    ((1314.0, -383.0, 1544.0, -295.0), EAST_ANNEX_SECTOR),
    ((1544.0, -383.0, 1689.0, -295.0), 171),
    ((1314.0, 295.0, 1544.0, 383.0), EAST_ANNEX_SECTOR),
    ((1544.0, 295.0, 1689.0, 383.0), 172),
    ((1689.0, -391.0, 1697.0, -295.0), 157),
    ((1689.0, 295.0, 1697.0, 391.0), 157),
)

# La fachada heredada se conserva como un único muro estructural. Sólo el
# centro recibe el volumen inferior para dejar abierto el vano de Z=264..392;
# sus extremos se extraen después como superficie de balcón.
FRONT_LOWER_CENTER_WALL = (1689.0, -64.0, 1697.0, 64.0)

# Dos vuelos de ocho peldaños comienzan en los costados del balcón y convergen
# hacia un descanso de 128×128 MU delante del portón del segundo piso.
NORTH_STEPS = (
    (288.0, 320.0),
    (256.0, 288.0),
    (224.0, 256.0),
    (192.0, 224.0),
    (160.0, 192.0),
    (128.0, 160.0),
    (96.0, 128.0),
    (64.0, 96.0),
)
SOUTH_STEPS = tuple((-high, -low) for low, high in NORTH_STEPS)
STAIR_X_RANGE = (1697.0, 1816.0)
SECOND_FLOOR_LANDING = (1697.0, -64.0, 1825.0, 64.0)

# Los peldaños que cruzan Y=±272 se dividen en dos sectores con el mismo tag;
# así ninguna pieza invade la frontera heredada entre los sectores 173--175.
BALCONY_HOST_SOUTH = 173
BALCONY_HOST_CENTER = 174
BALCONY_HOST_NORTH = 175

CONTROL_ORIGIN_X = 31500.0
CONTROL_ORIGIN_Y = 31000.0


def add_one_sided_line(
    blocks,
    first: tuple[float, float],
    second: tuple[float, float],
    sector_index: int,
    tag: int | None = None,
) -> None:
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
    if tag is not None:
        line["special"] = "160"
        line["arg0"] = str(tag)
        line["arg1"] = "1"
        line["arg2"] = "0"
        line["arg3"] = "255"
    blocks["linedef"].append(line)


def add_3d_floor_control(
    blocks,
    tag: int,
    floor_height: int,
    ceiling_height: int,
    slot: int,
) -> int:
    if floor_height >= ceiling_height:
        raise ValueError(f"Control inválido {tag}: {floor_height}..{ceiling_height}")
    if any(
        integer(line, "special") == 160 and integer(line, "arg0") == tag
        for line in blocks["linedef"]
    ):
        raise ValueError(f"El control {tag} ya existe")

    sector_index = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", str(floor_height)),
                ("heightceiling", str(ceiling_height)),
                ("texturefloor", '"CMIN01"'),
                ("textureceiling", '"CMIN01"'),
                ("lightlevel", "176"),
            )
        )
    )
    minimum_x = CONTROL_ORIGIN_X + slot * 64.0
    minimum_y = CONTROL_ORIGIN_Y
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
    return sector_index


def carve_target(
    blocks,
    rectangle: tuple[float, float, float, float],
    host_sector: int,
    tag: int,
) -> int:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    internal_lines: list[int] = []
    for line_index, line in enumerate(blocks["linedef"]):
        first, second = line_positions(blocks, line)
        midpoint = (
            (first[0] + second[0]) * 0.5,
            (first[1] + second[1]) * 0.5,
        )
        if not (
            minimum_x < midpoint[0] < maximum_x
            and minimum_y < midpoint[1] < maximum_y
        ):
            continue
        sectors = {
            integer(blocks["sidedef"][integer(line, side_name)], "sector")
            for side_name in ("sidefront", "sideback")
            if integer(line, side_name) is not None
        }
        if sectors != {host_sector}:
            raise ValueError(
                f"La pieza {rectangle} invade la línea {line_index} "
                f"{first}->{second} de {sectors}"
            )
        internal_lines.append(line_index)

    if not internal_lines:
        return carve_rectangle(blocks, rectangle, host_sector, tag)

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
    for line_index in internal_lines:
        line = blocks["linedef"][line_index]
        for side_name in ("sidefront", "sideback"):
            side_index = integer(line, side_name)
            if side_index is not None:
                blocks["sidedef"][side_index]["sector"] = str(target_sector)
    return target_sector


def carve_split_step(
    blocks,
    rectangle: tuple[float, float, float, float],
    tag: int,
    split_y: float,
    first_host: int,
    second_host: int,
) -> tuple[int, int]:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    first = carve_target(
        blocks,
        (minimum_x, minimum_y, maximum_x, split_y),
        first_host,
        tag,
    )
    second = carve_target(
        blocks,
        (minimum_x, split_y, maximum_x, maximum_y),
        second_host,
        tag,
    )
    return first, second


def add_second_floor_stairs(blocks) -> list[int]:
    target_sectors: list[int] = []
    minimum_x, maximum_x = STAIR_X_RANGE

    # Tallar desde el centro hacia afuera deja siempre un único lado anfitrión
    # disponible en la frontera compartida entre peldaños consecutivos.
    for index in reversed(range(len(NORTH_STEPS))):
        minimum_y, maximum_y = NORTH_STEPS[index]
        tag = STAIR_TAGS[index]
        rectangle = (minimum_x, minimum_y, maximum_x, maximum_y)
        if minimum_y < 272.0 < maximum_y:
            target_sectors.extend(
                carve_split_step(
                    blocks,
                    rectangle,
                    tag,
                    272.0,
                    BALCONY_HOST_CENTER,
                    BALCONY_HOST_NORTH,
                )
            )
        else:
            host = (
                BALCONY_HOST_CENTER
                if maximum_y <= 272.0
                else BALCONY_HOST_NORTH
            )
            target_sectors.append(carve_target(blocks, rectangle, host, tag))

    for index in reversed(range(len(SOUTH_STEPS))):
        minimum_y, maximum_y = SOUTH_STEPS[index]
        tag = STAIR_TAGS[index]
        rectangle = (minimum_x, minimum_y, maximum_x, maximum_y)
        if minimum_y < -272.0 < maximum_y:
            target_sectors.extend(
                carve_split_step(
                    blocks,
                    rectangle,
                    tag,
                    -272.0,
                    BALCONY_HOST_SOUTH,
                    BALCONY_HOST_CENTER,
                )
            )
        else:
            host = (
                BALCONY_HOST_CENTER
                if minimum_y >= -272.0
                else BALCONY_HOST_SOUTH
            )
            target_sectors.append(carve_target(blocks, rectangle, host, tag))

    target_sectors.append(
        carve_target(
            blocks,
            SECOND_FLOOR_LANDING,
            BALCONY_HOST_CENTER,
            SECOND_FLOOR_LANDING_TAG,
        )
    )

    for index, tag in enumerate(STAIR_TAGS):
        add_3d_floor_control(blocks, tag, 136, 152 + index * 16, index)
    add_3d_floor_control(
        blocks,
        SECOND_FLOOR_LANDING_TAG,
        136,
        264,
        len(STAIR_TAGS),
    )
    return target_sectors


def add_second_floor_frame_controls(blocks) -> None:
    slot = len(STAIR_TAGS) + 1
    # El marco lateral es sólido hasta la superficie del segundo piso y vuelve
    # a ser sólido sobre el vano. Dos controles con el mismo tag forman ambos
    # volúmenes sin dejar una ranura de 8 MU en la losa del umbral.
    add_3d_floor_control(blocks, SECOND_FLOOR_FRAME_TAG, 0, 264, slot)

    # La rutina anterior exige un tag libre; este segundo volumen comparte el
    # destino y por ello se añade como control explícito sin repetir la prueba.
    sector_index = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", "264"),
                ("heightceiling", "392"),
                ("texturefloor", '"CMIN01"'),
                ("textureceiling", '"CMIN01"'),
                ("lightlevel", "176"),
            )
        )
    )
    minimum_x = CONTROL_ORIGIN_X + (slot + 1) * 64.0
    points = (
        (minimum_x, CONTROL_ORIGIN_Y),
        (minimum_x, CONTROL_ORIGIN_Y + 48.0),
        (minimum_x + 48.0, CONTROL_ORIGIN_Y + 48.0),
        (minimum_x + 48.0, CONTROL_ORIGIN_Y),
    )
    for index, first in enumerate(points):
        add_one_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            sector_index,
            SECOND_FLOOR_FRAME_TAG if index == 0 else None,
        )

    add_3d_floor_control(
        blocks,
        SECOND_FLOOR_LOWER_CENTER_TAG,
        0,
        264,
        slot + 2,
    )


def make_second_floor_gate() -> list[OrderedDict[str, str]]:
    leaves = [
        make_door(1693.0, -32.0, SECOND_FLOOR_GATE_GROUP, -1),
        make_door(1693.0, 32.0, SECOND_FLOOR_GATE_GROUP, 1),
    ]
    for leaf in leaves:
        leaf["height"] = "264.0"
    return leaves


def make_perception_wall_sector() -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("heightfloor", "128"),
            ("heightceiling", "512"),
            ("texturefloor", '"CMIN01"'),
            ("textureceiling", '"F_SKY1"'),
            ("lightlevel", "176"),
        )
    )


def add_raised_wall_polygon(
    blocks,
    points: tuple[tuple[float, float], ...],
) -> int:
    if len(points) < 4 or len(set(points)) != len(points):
        raise ValueError("Polígono de muro diagnóstico inválido")
    sector_index = len(blocks["sector"])
    blocks["sector"].append(make_perception_wall_sector())
    for index, first in enumerate(points):
        add_two_sided_line(
            blocks,
            first,
            points[(index + 1) % len(points)],
            sector_index,
            WORLD_SECTOR,
        )
    return sector_index


def add_perception_room(
    blocks,
    rectangle: tuple[float, float, float, float],
) -> int:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    center_x = (minimum_x + maximum_x) * 0.5
    gap_low = center_x - ROOM_ENTRY_HALF_WIDTH
    gap_high = center_x + ROOM_ENTRY_HALF_WIDTH
    thickness = WALL_THICKNESS
    north_room = minimum_y > 0.0
    if north_room:
        points = (
            (gap_low, minimum_y),
            (minimum_x, minimum_y),
            (minimum_x, maximum_y),
            (maximum_x, maximum_y),
            (maximum_x, minimum_y),
            (gap_high, minimum_y),
            (gap_high, minimum_y + thickness),
            (maximum_x - thickness, minimum_y + thickness),
            (maximum_x - thickness, maximum_y - thickness),
            (minimum_x + thickness, maximum_y - thickness),
            (minimum_x + thickness, minimum_y + thickness),
            (gap_low, minimum_y + thickness),
        )
    else:
        points = (
            (gap_low, maximum_y),
            (minimum_x, maximum_y),
            (minimum_x, minimum_y),
            (maximum_x, minimum_y),
            (maximum_x, maximum_y),
            (gap_high, maximum_y),
            (gap_high, maximum_y - thickness),
            (maximum_x - thickness, maximum_y - thickness),
            (maximum_x - thickness, minimum_y + thickness),
            (minimum_x + thickness, minimum_y + thickness),
            (minimum_x + thickness, maximum_y - thickness),
            (gap_low, maximum_y - thickness),
        )
    return add_raised_wall_polygon(blocks, points)


def add_perception_divider(
    blocks,
    rectangle: tuple[float, float, float, float],
) -> int:
    minimum_x, minimum_y, maximum_x, maximum_y = rectangle
    return add_raised_wall_polygon(
        blocks,
        (
            (minimum_x, minimum_y),
            (minimum_x, maximum_y),
            (maximum_x, maximum_y),
            (maximum_x, minimum_y),
        ),
    )


def make_perception_observer(
    x: float,
    y: float,
    angle: int,
    insight: int,
    room: int,
) -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("x", f"{x:.1f}"),
            ("y", f"{y:.1f}"),
            ("height", "0.0"),
            ("angle", str(angle)),
            ("type", str(PERCEPTION_OBSERVER_DOOMEDNUM)),
            ("arg0", str(insight)),
            ("arg1", str(room)),
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


def tagged_sectors(blocks, tag: int) -> list[int]:
    return [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == tag
    ]


def validate_map01_architecture(blocks) -> None:
    for sector_index in REAR_ROOM_WALL_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != UPPER_WALL_TAG:
            raise ValueError(f"La pared trasera {sector_index} sigue abierta")

    expected_u_tags = {
        156: OPEN_FLOOR_TAG,
        157: SECOND_FLOOR_FRAME_TAG,
        158: OPEN_FLOOR_TAG,
    }
    for sector_index, expected_tag in expected_u_tags.items():
        if integer(blocks["sector"][sector_index], "id") != expected_tag:
            raise ValueError(
                f"Sector U {sector_index}: se esperaba {expected_tag}"
            )

    identifiers = Counter(integer(sector, "id") for sector in blocks["sector"])
    for tag in STAIR_TAGS + (
        SECOND_FLOOR_LANDING_TAG,
        SECOND_FLOOR_FRAME_TAG,
        SECOND_FLOOR_LOWER_CENTER_TAG,
    ):
        if identifiers[tag] == 0:
            raise ValueError(f"Falta el destino 3D {tag}")
        controls = [
            line
            for line in blocks["linedef"]
            if integer(line, "special") == 160 and integer(line, "arg0") == tag
        ]
        expected = 2 if tag == SECOND_FLOOR_FRAME_TAG else 1
        if len(controls) != expected:
            raise ValueError(
                f"Controles del tag {tag}: {len(controls)}, esperados {expected}"
            )

    for sector_index in tagged_sectors(blocks, SECOND_FLOOR_LANDING_TAG):
        validate_closed_sector(blocks, sector_index)
    for tag in STAIR_TAGS:
        for sector_index in tagged_sectors(blocks, tag):
            validate_closed_sector(blocks, sector_index)

    if door_group_counts(blocks)[SECOND_FLOOR_GATE_GROUP] != 2:
        raise ValueError("El portón del segundo piso no tiene dos hojas")
    if len(processing_manuals(blocks)) != 1:
        raise ValueError("El manual de procesamiento no se conservó")
    if integer(processing_manuals(blocks)[0], "type") != PROCESSING_MANUAL_DOOMEDNUM:
        raise ValueError("El manual de procesamiento cambió de clase")

    for sector_index in east_stair_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La escalera oriental {sector_index} perdió su techo")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None and map_counts(blocks) != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0ac inesperada: {map_counts(blocks)}")
    validate_map01_architecture(blocks)
    validate_target_sectors(blocks)
    validate_upper_gate(blocks)
    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0ac inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    return door_group_counts(blocks)[SECOND_FLOOR_GATE_GROUP] == 2


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0ab: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_0ab_map(path, blocks)

    for sector_index in REAR_ROOM_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(UPPER_WALL_TAG)
    blocks["sector"][156]["id"] = str(OPEN_FLOOR_TAG)
    blocks["sector"][157]["id"] = str(SECOND_FLOOR_FRAME_TAG)
    blocks["sector"][158]["id"] = str(OPEN_FLOOR_TAG)

    carve_target(
        blocks,
        STAIR_CENTER_SLAB,
        WORLD_SECTOR,
        FLOOR_ROOF_TAG,
    )

    for rectangle, host in RETRACTED_SIDE_WALLS + RETRACTED_TRANSITION_WALLS:
        carve_target(blocks, rectangle, host, FULL_HEIGHT_WALL_TAG)

    # El antiguo muro frontal es un sector independiente. Primero se extraen
    # sus esquinas de balcón y luego se talla la fachada nueva en el centro.
    for rectangle, host in SIDE_BALCONY_RECTANGLES:
        carve_target(blocks, rectangle, host, OPEN_FLOOR_TAG)

    carve_target(
        blocks,
        FRONT_LOWER_CENTER_WALL,
        157,
        SECOND_FLOOR_LOWER_CENTER_TAG,
    )

    add_second_floor_stairs(blocks)
    add_second_floor_frame_controls(blocks)
    blocks["thing"].extend(make_second_floor_gate())

    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def map02_mass_field_count(blocks) -> int:
    return sum(
        1
        for thing in blocks["thing"]
        if integer(thing, "type") in MASS_FIELD_TYPES
        and 8192.0 <= float(thing["x"]) <= 24576.0
        and -8192.0 <= float(thing["y"]) <= 8192.0
    )


def perception_observers(blocks) -> list[OrderedDict[str, str]]:
    return [
        thing
        for thing in blocks["thing"]
        if integer(thing, "type") == PERCEPTION_OBSERVER_DOOMEDNUM
    ]


def validate_map02(path: Path, blocks) -> None:
    if MAP02_UPDATED_COUNTS is not None and map_counts(blocks) != MAP02_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP02 4.29.0ac inesperada: {map_counts(blocks)}")
    if map02_mass_field_count(blocks) != 15000:
        raise ValueError("MAP02 no conserva exactamente 15.000 actores del campo")
    if len(perception_observers(blocks)) != len(PERCEPTION_OBSERVERS):
        raise ValueError("MAP02 no contiene los seis observadores de percepción")

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
        raise ValueError("Persistieron actores de los recintos obsoletos")

    identifiers = Counter(integer(thing, "type") for thing in blocks["thing"])
    for actor_type in (18205, 18206, 18207):
        if identifiers[actor_type] != 500:
            raise ValueError(f"La prueba Quintaesencia {actor_type} cambió")
    if identifiers[PHYSICS_MONITOR_DOOMEDNUM] != 1:
        raise ValueError("MAP02 perdió su monitor único")

    # Los últimos ocho sectores son los seis recintos y sus dos divisores.
    wall_sectors = list(range(len(blocks["sector"]) - 8, len(blocks["sector"])))
    if len(wall_sectors) != 8:
        raise ValueError("Cantidad de sectores físicos de percepción inválida")
    for sector_index in wall_sectors:
        sector = blocks["sector"][sector_index]
        if integer(sector, "heightfloor") != 128:
            raise ValueError(f"Muro de percepción {sector_index} sin altura 128")
        validate_closed_sector(blocks, sector_index)

    validate_references(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP02_UPDATED_SHA256 is not None and digest != MAP02_UPDATED_SHA256:
        raise ValueError(f"Hash MAP02 4.29.0ac inesperado: {digest}")


def map02_is_updated(blocks) -> bool:
    return len(perception_observers(blocks)) == len(PERCEPTION_OBSERVERS)


def rebuild_map02(path: Path = MAP02) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map02_is_updated(blocks):
        validate_map02(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != MAP02_BASE_COUNTS or digest != MAP02_BASE_SHA256:
        raise ValueError(
            "MAP02 no coincide con la base aceptada 4.29.0aa: "
            f"{map_counts(blocks)}, {digest}"
        )
    if map02_mass_field_count(blocks) != 15000:
        raise ValueError("La base MAP02 no contiene los 15.000 actores esperados")

    # 8..49 eran los seis recintos locales anteriores. Los tres recintos
    # remotos de Quintaesencia, el perímetro y el campo masivo se conservan.
    compact_geometry(blocks, set(range(8, 50)))
    blocks["thing"] = [
        thing
        for thing in blocks["thing"]
        if not (
            integer(thing, "type") in LOCAL_DIAGNOSTIC_TYPES
            and float(thing["x"]) < 8192.0
            and -4096.0 < float(thing["y"]) < 4096.0
        )
    ]

    for rectangle in PERCEPTION_ROOMS:
        add_perception_room(blocks, rectangle)
    add_perception_divider(blocks, (5200.0, 2488.0, 6800.0, 2504.0))
    add_perception_divider(blocks, (5200.0, -2504.0, 6800.0, -2488.0))
    blocks["thing"].extend(
        make_perception_observer(*definition)
        for definition in PERCEPTION_OBSERVERS
    )

    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
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
        "MAP01: corrección arquitectónica 4.29.0ac aplicada"
        if changed01
        else "MAP01: corrección arquitectónica 4.29.0ac ya presente"
    )
    print(
        "MAP02: recintos de percepción 4.29.0ac aplicados"
        if changed02
        else "MAP02: recintos de percepción 4.29.0ac ya presentes"
    )


if __name__ == "__main__":
    main()
