"""Reconstruye MAP01 y MAP02 para el candidato V4.29.0ae.

MAP01 parte exclusivamente de 4.29.0ad. Retira los dos tabiques con puertas
que cortaban la habitacion trasera, recupera los balcones laterales simetricos
y cierra debajo de ellos la ampliacion de planta baja. Sobre el eje oriental
levanta una unica habitacion rectangular en el segundo piso, alineada con la
geometria existente y abierta hacia el descanso de las escaleras.

MAP02 conserva byte por byte actores y geometria; restaura las superficies de
alcantarilla que 4.29.0ad habia sustituido por materiales de mansion.
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
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import carve_rectangle, validate_closed_sector
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
from rebuild_4_29_0ac_maps import (
    LOCAL_DIAGNOSTIC_TYPES,
    PERCEPTION_OBSERVERS,
    PHYSICS_MONITOR_DOOMEDNUM,
    add_one_sided_line,
    map02_mass_field_count,
    perception_observers,
)
from rebuild_4_29_0ad_maps import (
    EAST_FACADE_TAG,
    LOWER_DOORWAY_TAG,
    SECOND_FLOOR_GATE_GROUP,
    control_ranges,
    digest_json,
    map02_geometry_digest,
    validate_map01_textures,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = (696, 942, 1798, 226, 225)
MAP01_BASE_SHA256 = (
    "7bc0519a11adf058848a7986e456cd0ea8a97457f7e6ec963310a1ed3dbbc3a2"
)
MAP01_UPDATED_COUNTS = (756, 1017, 1904, 252, 223)
MAP01_UPDATED_SHA256 = (
    "d0e50dea403b8b1291a4b5ba513d6c3bd014735804e73f3687b1077ba75bf107"
)

MAP02_BASE_COUNTS = (112, 110, 212, 9, 16508)
MAP02_BASE_SHA256 = (
    "2f4568f60512ff3656476f32c506ac2547f6b4949b58b20d2f9b6de8c5fc0b54"
)
MAP02_UPDATED_COUNTS = MAP02_BASE_COUNTS
MAP02_UPDATED_SHA256 = (
    "88956e5074fe4e0ae097cfb539b67a4e0a3b6f33407bddcfcdfb7b73ce8180a9"
)

WORLD_SECTOR = 0
FLOOR_ROOF_TAG = 510
UPPER_WALL_TAG = 511
OPEN_FLOOR_TAG = 514
SECOND_FLOOR_LANDING_TAG = 538

# Cada tag nuevo se limita a una funcion espacial para que el techo del
# segundo piso no aparezca sobre el resto de la mansion.
GROUND_WALL_TAG = 541
SECOND_FLOOR_ROOM_TAG = 542
SECOND_FLOOR_STAIR_ROOM_TAG = 543
STACKED_SIDE_WALL_TAG = 544
SECOND_FLOOR_WEST_WALL_TAG = 545
SECOND_FLOOR_ROOF_ONLY_TAG = 546

MANSION_WALL = '"CMIN01"'
MANSION_FLOOR = '"CMWD01"'
MANSION_CEILING = '"CMCL01"'
SEWER_WALL = '"CASWRWAL"'
SEWER_FLOOR = '"CASWRFLR"'

REMOVED_DIVIDER_GROUPS = (914, 915)
REMOVED_DIVIDER_SECTORS = (222, 223, 224, 225)

# La pared superior se retrae a Y=+-295. Entre esa pared y el borde exterior
# queda un balcon de 96 MU; el volumen inferior permanece dentro del cuarto.
STACKED_SIDE_WALL_SECTORS = (177, 178, 179, 180)
FIRST_FLOOR_RETURN_WALL_SECTORS = (181, 182)
BALCONY_SECTORS = (183, 184, 185, 186)
GROUND_OUTER_WALL_SECTORS = (156, 158, 167, 168, 169, 170, 187, 188)

# El recinto nuevo ocupa el rectangulo estructural X=1306..1697,
# Y=-295..295. El muro occidental usa tramos separados porque cruza los doce
# sectores de la escalera interior sin modificar sus alturas transitables.
SECOND_FLOOR_INTERIOR_SECTORS = (
    65,
    66,
    67,
    68,
    171,
    172,
    176,
    *REMOVED_DIVIDER_SECTORS,
)
SECOND_FLOOR_OPEN_COLUMNS = (70, 71)
EAST_STAIR_SECTORS = tuple(range(25, 37))
WEST_WALL_SEGMENTS = (
    ((1306.0, -287.0, 1314.0, -272.0), 65),
    ((1306.0, -272.0, 1314.0, -240.0), 25),
    ((1306.0, -240.0, 1314.0, -208.0), 26),
    ((1306.0, -208.0, 1314.0, -176.0), 27),
    ((1306.0, -176.0, 1314.0, -144.0), 28),
    ((1306.0, -144.0, 1314.0, -112.0), 29),
    ((1306.0, -112.0, 1314.0, -80.0), 30),
    ((1306.0, -80.0, 1314.0, 80.0), 176),
    ((1306.0, 80.0, 1314.0, 112.0), 31),
    ((1306.0, 112.0, 1314.0, 144.0), 32),
    ((1306.0, 144.0, 1314.0, 176.0), 33),
    ((1306.0, 176.0, 1314.0, 208.0), 34),
    ((1306.0, 208.0, 1314.0, 240.0), 35),
    ((1306.0, 240.0, 1314.0, 272.0), 36),
    ((1306.0, 272.0, 1314.0, 287.0), 65),
)

CONTROL_ORIGIN_X = 31500.0
CONTROL_ORIGIN_Y = 30880.0

MAP02_THINGS_SHA256 = (
    "bd57fb8ee5b72739b03ab195bef787125a90c9cde287e8a530cbf70b08681317"
)
MAP02_GEOMETRY_SHA256 = (
    "229e75fd05b0cfde98f87729cb13ade5000733ca1065ac04da58d0bbb1b22774"
)
SEWER_WALL_SIDE_INDICES = (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
    28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
)


def add_control(
    blocks,
    tag: int,
    floor_height: int,
    ceiling_height: int,
    slot: int,
    floor_texture: str,
    ceiling_texture: str,
) -> int:
    """Anade un volumen 3D remoto sin reutilizar tags de otras plantas."""

    if floor_height >= ceiling_height:
        raise ValueError(f"Control invalido {tag}: {floor_height}..{ceiling_height}")
    sector_index = len(blocks["sector"])
    blocks["sector"].append(
        OrderedDict(
            (
                ("heightfloor", str(floor_height)),
                ("heightceiling", str(ceiling_height)),
                ("texturefloor", floor_texture),
                ("textureceiling", ceiling_texture),
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


def add_ae_controls(blocks) -> None:
    definitions = (
        (GROUND_WALL_TAG, 0, 128, MANSION_WALL, MANSION_WALL),
        (SECOND_FLOOR_ROOM_TAG, 128, 136, MANSION_CEILING, MANSION_FLOOR),
        (SECOND_FLOOR_ROOM_TAG, 256, 264, MANSION_CEILING, MANSION_FLOOR),
        (SECOND_FLOOR_ROOM_TAG, 392, 400, MANSION_CEILING, MANSION_FLOOR),
        (SECOND_FLOOR_STAIR_ROOM_TAG, 256, 264, MANSION_CEILING, MANSION_FLOOR),
        (SECOND_FLOOR_STAIR_ROOM_TAG, 392, 400, MANSION_CEILING, MANSION_FLOOR),
        (STACKED_SIDE_WALL_TAG, 128, 256, MANSION_WALL, MANSION_WALL),
        (STACKED_SIDE_WALL_TAG, 264, 392, MANSION_WALL, MANSION_WALL),
        (SECOND_FLOOR_WEST_WALL_TAG, 264, 392, MANSION_WALL, MANSION_WALL),
        (SECOND_FLOOR_ROOF_ONLY_TAG, 392, 400, MANSION_CEILING, MANSION_FLOOR),
        (EAST_FACADE_TAG, 264, 392, MANSION_WALL, MANSION_WALL),
    )
    for slot, definition in enumerate(definitions):
        add_control(blocks, *definition[:3], slot, *definition[3:])


def remove_rejected_dividers(blocks) -> None:
    blocks["thing"] = [
        thing
        for thing in blocks["thing"]
        if not (
            integer(thing, "type") == 18025
            and integer(thing, "arg0") in REMOVED_DIVIDER_GROUPS
        )
    ]
    for sector_index in REMOVED_DIVIDER_SECTORS:
        blocks["sector"][sector_index]["id"] = str(SECOND_FLOOR_ROOM_TAG)


def rebuild_rear_wings(blocks) -> None:
    for sector_index in GROUND_OUTER_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(GROUND_WALL_TAG)
    for sector_index in BALCONY_SECTORS:
        blocks["sector"][sector_index]["id"] = str(OPEN_FLOOR_TAG)
    for sector_index in FIRST_FLOOR_RETURN_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(UPPER_WALL_TAG)
    for sector_index in STACKED_SIDE_WALL_SECTORS:
        blocks["sector"][sector_index]["id"] = str(STACKED_SIDE_WALL_TAG)


def add_second_floor_room(blocks) -> None:
    # Resolverlos antes de tallar la franja occidental: el tallado conserva
    # los indices, pero retrae ocho MU sus limites rectangulares.
    stair_sectors = tuple(east_stair_indices(blocks))
    if stair_sectors != EAST_STAIR_SECTORS:
        raise ValueError(f"Tramos orientales inesperados: {stair_sectors}")

    for rectangle, host_sector in WEST_WALL_SEGMENTS:
        sector_index = carve_rectangle(
            blocks,
            rectangle,
            host_sector,
            SECOND_FLOOR_WEST_WALL_TAG,
        )
        blocks["sector"][sector_index]["texturefloor"] = MANSION_FLOOR

    for sector_index in SECOND_FLOOR_INTERIOR_SECTORS:
        blocks["sector"][sector_index]["id"] = str(SECOND_FLOOR_ROOM_TAG)
    for sector_index in stair_sectors:
        blocks["sector"][sector_index]["id"] = str(SECOND_FLOOR_STAIR_ROOM_TAG)
    for sector_index in SECOND_FLOOR_OPEN_COLUMNS:
        blocks["sector"][sector_index]["id"] = str(SECOND_FLOOR_ROOF_ONLY_TAG)
    add_ae_controls(blocks)


def tagged_sector_at(blocks, rectangle, tag: int) -> int:
    matches = [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == tag
        and sector_bounds(blocks, index) == rectangle
    ]
    if len(matches) != 1:
        raise ValueError(f"Rectangulo {rectangle}, tag {tag}: {len(matches)}")
    return matches[0]


def validate_map01_architecture(blocks) -> None:
    groups = door_group_counts(blocks)
    if any(groups[group] for group in REMOVED_DIVIDER_GROUPS):
        raise ValueError("Persisten las puertas divisorias rechazadas")
    if groups[SECOND_FLOOR_GATE_GROUP] != 2:
        raise ValueError("El acceso inferior 913 no conserva sus dos hojas")

    for sector_index in GROUND_OUTER_WALL_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != GROUND_WALL_TAG:
            raise ValueError(f"Muro inferior {sector_index} no cierra la habitacion")
    for sector_index in BALCONY_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != OPEN_FLOOR_TAG:
            raise ValueError(f"Balcon lateral {sector_index} no queda descubierto")
    for sector_index in FIRST_FLOOR_RETURN_WALL_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != UPPER_WALL_TAG:
            raise ValueError(f"Retorno superior {sector_index} inesperado")
    for sector_index in STACKED_SIDE_WALL_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != STACKED_SIDE_WALL_TAG:
            raise ValueError(f"Pared lateral apilada {sector_index} inesperada")
    for sector_index in SECOND_FLOOR_INTERIOR_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != SECOND_FLOOR_ROOM_TAG:
            raise ValueError(f"Interior del segundo piso {sector_index} sin techo")
    for sector_index in EAST_STAIR_SECTORS:
        if integer(blocks["sector"][sector_index], "id") != SECOND_FLOOR_STAIR_ROOM_TAG:
            raise ValueError(f"Columna de escalera {sector_index} sin techo superior")
    for sector_index in SECOND_FLOOR_OPEN_COLUMNS:
        if integer(blocks["sector"][sector_index], "id") != SECOND_FLOOR_ROOF_ONLY_TAG:
            raise ValueError(f"Columna interior {sector_index} sin techo superior")

    for rectangle, _ in WEST_WALL_SEGMENTS:
        validate_closed_sector(
            blocks,
            tagged_sector_at(blocks, rectangle, SECOND_FLOOR_WEST_WALL_TAG),
        )

    expected_controls = {
        GROUND_WALL_TAG: Counter({(0, 128): 1}),
        SECOND_FLOOR_ROOM_TAG: Counter({(128, 136): 1, (256, 264): 1, (392, 400): 1}),
        SECOND_FLOOR_STAIR_ROOM_TAG: Counter({(256, 264): 1, (392, 400): 1}),
        STACKED_SIDE_WALL_TAG: Counter({(128, 256): 1, (264, 392): 1}),
        SECOND_FLOOR_WEST_WALL_TAG: Counter({(264, 392): 1}),
        SECOND_FLOOR_ROOF_ONLY_TAG: Counter({(392, 400): 1}),
        EAST_FACADE_TAG: Counter({(0, 264): 1, (264, 392): 1}),
        LOWER_DOORWAY_TAG: Counter({(0, 136): 1, (256, 264): 1}),
        SECOND_FLOOR_LANDING_TAG: Counter({(128, 136): 1, (256, 264): 1}),
    }
    for tag, expected in expected_controls.items():
        actual = control_ranges(blocks, tag)
        if actual != expected:
            raise ValueError(f"Volumenes tag {tag}: {actual}, esperados {expected}")

    gate = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "arg1"),
        )
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == SECOND_FLOOR_GATE_GROUP
    }
    if gate != {(1693.0, -32.0, 136.0, -1), (1693.0, 32.0, 136.0, 1)}:
        raise ValueError(f"Acceso 913 inesperado: {gate}")

    if len(processing_manuals(blocks)) != 1:
        raise ValueError("MAP01 no conserva un manual de procesamiento")
    if integer(processing_manuals(blocks)[0], "type") != PROCESSING_MANUAL_DOOMEDNUM:
        raise ValueError("El manual de procesamiento cambio de clase")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None and map_counts(blocks) != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0ae inesperada: {map_counts(blocks)}")
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
        raise ValueError(f"Hash MAP01 4.29.0ae inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    groups = door_group_counts(blocks)
    return (
        not groups[914]
        and not groups[915]
        and control_ranges(blocks, SECOND_FLOOR_ROOM_TAG)
        == Counter({(128, 136): 1, (256, 264): 1, (392, 400): 1})
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

    remove_rejected_dividers(blocks)
    rebuild_rear_wings(blocks)
    add_second_floor_room(blocks)

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


def restore_sewer_textures(blocks) -> None:
    if blocks["sector"][WORLD_SECTOR].get("texturefloor") != MANSION_FLOOR:
        raise ValueError("MAP02 no parte del suelo de mansion de 4.29.0ad")
    blocks["sector"][WORLD_SECTOR]["texturefloor"] = SEWER_FLOOR
    for side_index in SEWER_WALL_SIDE_INDICES:
        side = blocks["sidedef"][side_index]
        if side.get("texturemiddle") != MANSION_WALL:
            raise ValueError(f"Sidedef {side_index} no parte de la pared de mansion")
        side["texturemiddle"] = SEWER_WALL


def validate_map02(path: Path, blocks) -> None:
    if map_counts(blocks) != MAP02_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP02 4.29.0ae inesperada: {map_counts(blocks)}")
    validate_map02_content(blocks)
    if blocks["sector"][WORLD_SECTOR].get("texturefloor") != SEWER_FLOOR:
        raise ValueError("MAP02 no usa suelo de alcantarilla")
    if any(
        blocks["sidedef"][index].get("texturemiddle") != SEWER_WALL
        for index in SEWER_WALL_SIDE_INDICES
    ):
        raise ValueError("MAP02 no usa todas sus paredes de alcantarilla")
    validate_references(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if digest != MAP02_UPDATED_SHA256:
        raise ValueError(f"Hash MAP02 4.29.0ae inesperado: {digest}")


def map02_is_updated(blocks) -> bool:
    return blocks["sector"][WORLD_SECTOR].get("texturefloor") == SEWER_FLOOR


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
    restore_sewer_textures(blocks)

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
        "MAP01: alas, balcones y segundo piso 4.29.0ae aplicados"
        if changed01
        else "MAP01: arquitectura 4.29.0ae ya presente"
    )
    print(
        "MAP02: materiales de alcantarilla 4.29.0ae restaurados"
        if changed02
        else "MAP02: materiales de alcantarilla 4.29.0ae ya presentes"
    )


if __name__ == "__main__":
    main()
