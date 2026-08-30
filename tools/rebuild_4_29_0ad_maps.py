"""Reconstruye MAP01 y MAP02 para el candidato V4.29.0ad.

MAP01 parte exclusivamente de 4.29.0ac. Baja el acceso oriental al primer
piso, vacia el bloque situado bajo su descanso para formar un tunel, restaura
el perimetro completo de la ampliacion y convierte las falsas aletas laterales
en habitaciones con divisiones y puertas. Tambien reemplaza los materiales
heredados de Doom por las superficies propias de la mansion.

MAP02 conserva byte por byte sus actores y su geometria diagnostica; solo
reemplaza el suelo y las paredes de alcantarilla por materiales de mansion.
"""

from __future__ import annotations

from collections import Counter, OrderedDict
from hashlib import sha256
import json
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0o_maps import make_room_sector
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import validate_closed_sector
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
)
from rebuild_4_29_0ab_maps import carve_mixed_rectangle
from rebuild_4_29_0ac_maps import (
    LOCAL_DIAGNOSTIC_TYPES,
    MASS_FIELD_TYPES,
    MAP01_UPDATED_COUNTS as MAP01_BASE_COUNTS,
    MAP01_UPDATED_SHA256 as MAP01_BASE_SHA256,
    MAP02_UPDATED_COUNTS as MAP02_BASE_COUNTS,
    MAP02_UPDATED_SHA256 as MAP02_BASE_SHA256,
    PERCEPTION_OBSERVERS,
    PERCEPTION_OBSERVER_DOOMEDNUM,
    PHYSICS_MONITOR_DOOMEDNUM,
    STAIR_TAGS,
    add_one_sided_line,
    map02_mass_field_count,
    perception_observers,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

# Se fijan despues de generar y auditar la primera salida determinista.
MAP01_UPDATED_COUNTS = (696, 942, 1798, 226, 225)
MAP01_UPDATED_SHA256: str | None = (
    "7bc0519a11adf058848a7986e456cd0ea8a97457f7e6ec963310a1ed3dbbc3a2"
)
MAP02_UPDATED_COUNTS = MAP02_BASE_COUNTS
MAP02_UPDATED_SHA256: str | None = (
    "2f4568f60512ff3656476f32c506ac2547f6b4949b58b20d2f9b6de8c5fc0b54"
)

WORLD_SECTOR = 0
FLOOR_ROOF_TAG = 510
UPPER_WALL_TAG = 511
OPEN_FLOOR_TAG = 514
ROOF_ONLY_TAG = 515
FULL_HEIGHT_WALL_TAG = 516

SECOND_FLOOR_LANDING_TAG = 538
EAST_FACADE_TAG = 539
LOWER_DOORWAY_TAG = 540
SECOND_FLOOR_GATE_GROUP = 913
SOUTH_DIVIDER_DOOR_GROUP = 914
NORTH_DIVIDER_DOOR_GROUP = 915

MANSION_WALL = '"CMIN01"'
MANSION_FLOOR = '"CMWD01"'
MANSION_CEILING = '"CMCL01"'
MANSION_DOOR = '"CMDR03"'

# 0ac restauro por error la pared que 0ab habia abierto para unir la
# habitacion trasera con la ampliacion.
REOPENED_REAR_SECTORS = (160, 161)

# El retranqueo de 0ac produjo paredes interiores y aletas de transicion.
# Estas diez superficies, junto con las dos reaperturas anteriores, vuelven a
# ser parte techada de las habitaciones.
ANNEX_INTERIOR_SECTORS = (
    177,
    178,
    179,
    180,
    181,
    182,
    183,
    184,
    185,
    186,
)

# Se recupera la U original. El frente utiliza un tag propio hasta Z=264 para
# sostener el umbral superior; ya no existe pared en Z=264..392.
SIDE_PERIMETER_SECTORS = (156, 158)
FRONT_FRAME_SECTORS = (157, 187, 188)
LOWER_DOORWAY_SECTOR = 189
LANDING_SECTOR = 208

# Dos paredes de primer piso separan las extensiones norte/sur del recinto
# central. El vano de 64 MU queda centrado en X=1544.
DIVIDER_WALLS = (
    ((1425.0, -286.0, 1512.0, -278.0), SOUTH_DIVIDER_DOOR_GROUP, 183),
    ((1576.0, -286.0, 1689.0, -278.0), SOUTH_DIVIDER_DOOR_GROUP, 171),
    ((1425.0, 278.0, 1512.0, 286.0), NORTH_DIVIDER_DOOR_GROUP, 185),
    ((1576.0, 278.0, 1689.0, 286.0), NORTH_DIVIDER_DOOR_GROUP, 172),
)
DIVIDER_DOORS = (
    (1544.0, -282.0, SOUTH_DIVIDER_DOOR_GROUP, 1),
    (1544.0, 282.0, NORTH_DIVIDER_DOOR_GROUP, -1),
)
DIVIDER_HOSTS = {65, 171, 172, 183, 184, 185, 186}

CONTROL_ORIGIN_X = 31500.0
CONTROL_ORIGIN_Y = 31000.0
NEW_CONTROL_SLOT = 12

MAP02_THINGS_SHA256 = (
    "bd57fb8ee5b72739b03ab195bef787125a90c9cde287e8a530cbf70b08681317"
)
MAP02_GEOMETRY_SHA256 = (
    "229e75fd05b0cfde98f87729cb13ade5000733ca1065ac04da58d0bbb1b22774"
)


def active_controls(blocks, tag: int) -> list[tuple[OrderedDict, int]]:
    """Devuelve cada linea de control 3D y su sector de referencia."""

    result: list[tuple[OrderedDict, int]] = []
    for line in blocks["linedef"]:
        if integer(line, "special") != 160 or integer(line, "arg0") != tag:
            continue
        side_index = integer(line, "sidefront")
        if side_index is None:
            raise ValueError(f"Control {tag} sin lado frontal")
        sector_index = integer(blocks["sidedef"][side_index], "sector")
        result.append((line, sector_index))
    return result


def control_ranges(blocks, tag: int) -> Counter[tuple[int, int]]:
    return Counter(
        (
            integer(blocks["sector"][sector_index], "heightfloor"),
            integer(blocks["sector"][sector_index], "heightceiling"),
        )
        for _, sector_index in active_controls(blocks, tag)
    )


def add_shared_3d_floor_control(
    blocks,
    tag: int,
    floor_height: int,
    ceiling_height: int,
    slot: int,
) -> int:
    """Anade un segundo volumen al mismo tag sin exigir que sea unico."""

    if floor_height >= ceiling_height:
        raise ValueError(f"Control invalido {tag}: {floor_height}..{ceiling_height}")

    sector_index = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", str(floor_height)),
                ("heightceiling", str(ceiling_height)),
                ("texturefloor", MANSION_CEILING),
                ("textureceiling", MANSION_FLOOR),
                ("lightlevel", "176"),
            )
        )
    )
    minimum_x = CONTROL_ORIGIN_X + slot * 64.0
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
            tag if index == 0 else None,
        )
    return sector_index


def make_horizontal_door(
    x: float,
    y: float,
    group: int,
    direction: int,
) -> OrderedDict[str, str]:
    """Crea una hoja de 64 MU contenida en una pared paralela al eje X."""

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


def retarget_controls_for_tunnel(blocks) -> None:
    """Convierte los tres volumenes macizos de 0ac en piso, techo y marco."""

    landing = active_controls(blocks, SECOND_FLOOR_LANDING_TAG)
    if len(landing) != 1 or control_ranges(blocks, SECOND_FLOOR_LANDING_TAG) != Counter({(136, 264): 1}):
        raise ValueError("El descanso 538 de la base no coincide con 0ac")
    landing_sector = blocks["sector"][landing[0][1]]
    landing_sector["heightfloor"] = "256"
    landing_sector["heightceiling"] = "264"
    landing_sector["texturefloor"] = MANSION_CEILING
    landing_sector["textureceiling"] = MANSION_FLOOR

    frame = active_controls(blocks, EAST_FACADE_TAG)
    if len(frame) != 2 or control_ranges(blocks, EAST_FACADE_TAG) != Counter({(0, 264): 1, (264, 392): 1}):
        raise ValueError("El marco 539 de la base no coincide con 0ac")
    upper_line, upper_sector_index = next(
        entry
        for entry in frame
        if integer(blocks["sector"][entry[1]], "heightfloor") == 264
    )
    upper_line["arg0"] = str(LOWER_DOORWAY_TAG)
    upper_sector = blocks["sector"][upper_sector_index]
    upper_sector["heightfloor"] = "256"
    upper_sector["heightceiling"] = "264"
    upper_sector["texturefloor"] = MANSION_WALL
    upper_sector["textureceiling"] = MANSION_WALL

    doorway = active_controls(blocks, LOWER_DOORWAY_TAG)
    if len(doorway) != 2:
        raise ValueError("No se formaron los dos volumenes del vano 540")
    lower_sector_index = next(
        sector_index
        for _, sector_index in doorway
        if integer(blocks["sector"][sector_index], "heightfloor") == 0
    )
    lower_sector = blocks["sector"][lower_sector_index]
    if integer(lower_sector, "heightceiling") != 264:
        raise ValueError("El pedestal 540 de la base no termina en 264")
    lower_sector["heightceiling"] = "136"

    add_shared_3d_floor_control(
        blocks,
        SECOND_FLOOR_LANDING_TAG,
        128,
        136,
        NEW_CONTROL_SLOT,
    )


def apply_mansion_textures_map01(blocks) -> None:
    """Elimina las superficies temporales de Doom dentro de MAP01."""

    for side in blocks["sidedef"]:
        for field in ("texturetop", "texturemiddle", "texturebottom"):
            if side.get(field) == '"STARTAN3"':
                side[field] = MANSION_WALL
            elif side.get(field) == '"BIGDOOR2"':
                side[field] = MANSION_DOOR

    for sector_index, sector in enumerate(blocks["sector"]):
        if sector_index != WORLD_SECTOR and sector.get("texturefloor") == '"FLOOR0_1"':
            sector["texturefloor"] = MANSION_FLOOR
        if sector.get("texturefloor") == '"CEIL5_2"':
            sector["texturefloor"] = MANSION_CEILING
        if sector.get("textureceiling") == '"CEIL5_2"':
            sector["textureceiling"] = MANSION_FLOOR

    # Losas de piso/techo heredadas: cara inferior de cielorraso y cara
    # superior de madera. Los indices son estables por el hash base estricto.
    for sector_index in (69, 86, 87):
        sector = blocks["sector"][sector_index]
        sector["texturefloor"] = MANSION_CEILING
        sector["textureceiling"] = MANSION_FLOOR

    # Peldaños exteriores y descanso: madera arriba, cielorraso debajo.
    for tag in STAIR_TAGS + (SECOND_FLOOR_LANDING_TAG,):
        for _, sector_index in active_controls(blocks, tag):
            sector = blocks["sector"][sector_index]
            sector["texturefloor"] = MANSION_CEILING
            sector["textureceiling"] = MANSION_FLOOR


def add_room_dividers(blocks) -> None:
    new_sectors: set[int] = set()
    allowed_hosts = set(DIVIDER_HOSTS)
    for rectangle, _, outside_sector in DIVIDER_WALLS:
        sector_index = carve_mixed_rectangle(
            blocks,
            rectangle,
            UPPER_WALL_TAG,
            allowed_hosts | new_sectors,
            outside_sector,
        )
        new_sectors.add(sector_index)
    blocks["thing"].extend(make_horizontal_door(*definition) for definition in DIVIDER_DOORS)


def validate_divider_neighbors(blocks) -> None:
    for rectangle, _, expected_host in DIVIDER_WALLS:
        sector_index = tagged_sector_at(blocks, rectangle, UPPER_WALL_TAG)
        neighbors = set()
        for line in blocks["linedef"]:
            front = integer(line, "sidefront")
            back = integer(line, "sideback")
            if front is None or back is None:
                continue
            front_sector = integer(blocks["sidedef"][front], "sector")
            back_sector = integer(blocks["sidedef"][back], "sector")
            if front_sector == sector_index:
                neighbors.add(back_sector)
            elif back_sector == sector_index:
                neighbors.add(front_sector)
        if WORLD_SECTOR in neighbors or expected_host not in neighbors:
            raise ValueError(
                f"Divisor {sector_index} conectado a {sorted(neighbors)}, "
                f"esperaba anfitrion {expected_host} sin mundo exterior"
            )


def move_east_gate_to_first_floor(blocks) -> None:
    matches = [
        thing
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
    ]
    if len(matches) != 2 or {float(thing["height"]) for thing in matches} != {264.0}:
        raise ValueError("El porton 913 de la base no coincide con 0ac")
    for thing in matches:
        thing["height"] = "136.0"


def tagged_sector_at(blocks, rectangle, tag: int) -> int:
    matches = [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == tag and sector_bounds(blocks, index) == rectangle
    ]
    if len(matches) != 1:
        raise ValueError(f"Rectangulo {rectangle}, tag {tag}: {len(matches)}")
    return matches[0]


def validate_map01_textures(blocks) -> None:
    legacy_sides = []
    for index, side in enumerate(blocks["sidedef"]):
        values = {side.get(field) for field in ("texturetop", "texturemiddle", "texturebottom")}
        if '"STARTAN3"' in values or '"BIGDOOR2"' in values:
            legacy_sides.append(index)
    if legacy_sides:
        raise ValueError(f"Persisten texturas Doom en sidedefs: {legacy_sides[:8]}")

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

    for sector_index in (69, 86, 87):
        sector = blocks["sector"][sector_index]
        if (sector.get("texturefloor"), sector.get("textureceiling")) != (
            MANSION_CEILING,
            MANSION_FLOOR,
        ):
            raise ValueError(f"Losa {sector_index} sin materiales de mansion")


def validate_map01_architecture(blocks) -> None:
    for sector_index in REOPENED_REAR_SECTORS + ANNEX_INTERIOR_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != FLOOR_ROOF_TAG:
            raise ValueError(f"Sector interior {sector_index} no pertenece al cuarto")
    for sector_index in SIDE_PERIMETER_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != FULL_HEIGHT_WALL_TAG:
            raise ValueError(f"Perimetro lateral {sector_index} sigue abierto")
    for sector_index in FRONT_FRAME_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != EAST_FACADE_TAG:
            raise ValueError(f"Marco oriental {sector_index} con tag incorrecto")
    if integer(blocks["sector"][LOWER_DOORWAY_SECTOR], "id") != LOWER_DOORWAY_TAG:
        raise ValueError("El vano inferior perdio el tag 540")
    if integer(blocks["sector"][LANDING_SECTOR], "id") != SECOND_FLOOR_LANDING_TAG:
        raise ValueError("El descanso perdio el tag 538")

    expected_controls = {
        SECOND_FLOOR_LANDING_TAG: Counter({(128, 136): 1, (256, 264): 1}),
        EAST_FACADE_TAG: Counter({(0, 264): 1}),
        LOWER_DOORWAY_TAG: Counter({(0, 136): 1, (256, 264): 1}),
    }
    for tag, expected in expected_controls.items():
        actual = control_ranges(blocks, tag)
        if actual != expected:
            raise ValueError(f"Volumenes tag {tag}: {actual}, esperados {expected}")

    for rectangle, _, _ in DIVIDER_WALLS:
        sector_index = tagged_sector_at(blocks, rectangle, UPPER_WALL_TAG)
        validate_closed_sector(blocks, sector_index)
    validate_divider_neighbors(blocks)

    groups = door_group_counts(blocks)
    if groups[SECOND_FLOOR_GATE_GROUP] != 2:
        raise ValueError("El acceso 913 no conserva dos hojas")
    if groups[SOUTH_DIVIDER_DOOR_GROUP] != 1 or groups[NORTH_DIVIDER_DOOR_GROUP] != 1:
        raise ValueError("Las divisiones no contienen una puerta por habitacion")

    gate = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "angle"),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
    }
    expected_gate = {
        (1693.0, -32.0, 136.0, 0, -1, 1),
        (1693.0, 32.0, 136.0, 0, 1, 1),
    }
    if gate != expected_gate:
        raise ValueError(f"Acceso oriental inesperado: {gate}")

    divider_doors = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "angle"),
            integer(thing, "arg0"),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") in (SOUTH_DIVIDER_DOOR_GROUP, NORTH_DIVIDER_DOOR_GROUP)
    }
    expected_dividers = {
        (1544.0, -282.0, 136.0, 90, SOUTH_DIVIDER_DOOR_GROUP, 1, 0),
        (1544.0, 282.0, 136.0, 90, NORTH_DIVIDER_DOOR_GROUP, -1, 0),
    }
    if divider_doors != expected_dividers:
        raise ValueError(f"Puertas divisorias inesperadas: {divider_doors}")

    for sector_index in east_stair_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"Escalera oriental {sector_index} perdio su techo")
    if len(processing_manuals(blocks)) != 1:
        raise ValueError("MAP01 no conserva un manual de procesamiento")
    if integer(processing_manuals(blocks)[0], "type") != PROCESSING_MANUAL_DOOMEDNUM:
        raise ValueError("El manual de procesamiento cambio de clase")


def validate_map01(path: Path, blocks) -> None:
    if map_counts(blocks) != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0ad inesperada: {map_counts(blocks)}")
    validate_map01_architecture(blocks)
    validate_map01_textures(blocks)
    validate_target_sectors(blocks)
    validate_upper_gate(blocks)
    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0ad inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    groups = door_group_counts(blocks)
    if groups[SOUTH_DIVIDER_DOOR_GROUP] != 1 or groups[NORTH_DIVIDER_DOOR_GROUP] != 1:
        return False
    gate_heights = {
        float(thing["height"])
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
    }
    return gate_heights == {136.0}


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
            "MAP01 no coincide con la base aceptada 4.29.0ac: "
            f"{map_counts(blocks)}, {digest}"
        )

    for sector_index in REOPENED_REAR_SECTORS + ANNEX_INTERIOR_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FLOOR_ROOF_TAG)
    for sector_index in SIDE_PERIMETER_SECTORS:
        blocks["sector"][sector_index]["id"] = str(FULL_HEIGHT_WALL_TAG)
    for sector_index in FRONT_FRAME_SECTORS:
        blocks["sector"][sector_index]["id"] = str(EAST_FACADE_TAG)

    retarget_controls_for_tunnel(blocks)
    add_room_dividers(blocks)
    move_east_gate_to_first_floor(blocks)
    apply_mansion_textures_map01(blocks)

    lumps[text_index] = (b"TEXTMAP", render_textmap(header, blocks).encode("utf-8"))
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def digest_json(value) -> str:
    return sha256(
        json.dumps(value, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
    ).hexdigest()


def map02_geometry_digest(blocks) -> str:
    geometry = {
        "vertex": blocks["vertex"],
        "linedef": blocks["linedef"],
        "sidedef": [
            {key: value for key, value in side.items() if not key.startswith("texture")}
            for side in blocks["sidedef"]
        ],
        "sector": [
            {key: value for key, value in sector.items() if not key.startswith("texture")}
            for sector in blocks["sector"]
        ],
    }
    return digest_json(geometry)


def validate_map02_unchanged_content(blocks) -> None:
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

    wall_sectors = range(len(blocks["sector"]) - 8, len(blocks["sector"]))
    for sector_index in wall_sectors:
        if integer(blocks["sector"][sector_index], "heightfloor") != 128:
            raise ValueError(f"Muro diagnostico {sector_index} sin altura 128")
        validate_closed_sector(blocks, sector_index)


def apply_mansion_textures_map02(blocks) -> None:
    for sector in blocks["sector"]:
        if sector.get("texturefloor") == '"CASWRFLR"':
            sector["texturefloor"] = MANSION_FLOOR
    for side in blocks["sidedef"]:
        for field in ("texturetop", "texturemiddle", "texturebottom"):
            if side.get(field) == '"CASWRWAL"':
                side[field] = MANSION_WALL


def validate_map02(path: Path, blocks) -> None:
    if map_counts(blocks) != MAP02_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP02 4.29.0ad inesperada: {map_counts(blocks)}")
    validate_map02_unchanged_content(blocks)
    if any(
        sector.get("texturefloor") == '"CASWRFLR"'
        for sector in blocks["sector"]
    ):
        raise ValueError("MAP02 conserva suelo de alcantarilla")
    if any(
        side.get(field) == '"CASWRWAL"'
        for side in blocks["sidedef"]
        for field in ("texturetop", "texturemiddle", "texturebottom")
    ):
        raise ValueError("MAP02 conserva paredes de alcantarilla")
    if blocks["sector"][WORLD_SECTOR].get("texturefloor") != MANSION_FLOOR:
        raise ValueError("MAP02 no usa piso de mansion")
    validate_references(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP02_UPDATED_SHA256 is not None and digest != MAP02_UPDATED_SHA256:
        raise ValueError(f"Hash MAP02 4.29.0ad inesperado: {digest}")


def map02_is_updated(blocks) -> bool:
    return not any(
        sector.get("texturefloor") == '"CASWRFLR"'
        for sector in blocks["sector"]
    )


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
            "MAP02 no coincide con la base aceptada 4.29.0ac: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_map02_unchanged_content(blocks)
    apply_mansion_textures_map02(blocks)

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
        "MAP01: arquitectura y materiales 4.29.0ad aplicados"
        if changed01
        else "MAP01: arquitectura y materiales 4.29.0ad ya presentes"
    )
    print(
        "MAP02: materiales de mansion 4.29.0ad aplicados"
        if changed02
        else "MAP02: materiales de mansion 4.29.0ad ya presentes"
    )


if __name__ == "__main__":
    main()
