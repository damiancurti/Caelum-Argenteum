"""Abre por completo el perimetro posterior inferior en V4.29.0au.

MAP01 parte exclusivamente del candidato determinista 4.29.0at. Ese
incremento devolvio las hojas de la puerta 807 y cerro dos empalmes exteriores,
pero la revision visual confirma que la planta baja debe quedar provisionalmente
sin los muros norte, este y sur del anexo ni esos dos empalmes.

Este incremento retira solo el volumen z=0..128 y las texturas medias de esos
cerramientos. Conserva la puerta 807, ambas escaleras y todos los perfiles desde
z=128 en adelante. El intento anterior de restaurar el pasto no se modifica;
esa correccion queda aplazada. MAP02 permanece byte-identico a 4.29.0at.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0at_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1045,
    1438,
    2590,
    437,
    225,
)
MAP01_UPDATED_SHA256: str | None = (
    "835e1f113fa24b8b646f2dfccd712f603d1de91d8434c72b48a1b1367560fb74"
)
MAP01_THINGS_SHA256 = previous.MAP01_THINGS_SHA256

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

MANSION_WALL = previous.previous.ar.ap.ao.MANSION_WALL
EMPTY_TEXTURE = '"-"'

# Cada tupla resuelve un sector fisico por sus limites y sustituye solamente
# el perfil que aportaba pared a la planta baja.
GROUND_WALL_TAG_REPLACEMENTS = (
    ((1306.0, -391.0, 1689.0, -383.0), 549, 581),
    ((1306.0, 383.0, 1689.0, 391.0), 549, 581),
    ((1209.0, -391.0, 1305.0, -383.0), 549, 581),
    ((1305.0, -391.0, 1306.0, -383.0), 549, 581),
    ((1209.0, 383.0, 1305.0, 391.0), 549, 581),
    ((1305.0, 383.0, 1306.0, 391.0), 549, 581),
    ((1689.0, -391.0, 1697.0, -328.0), 549, 581),
    ((1689.0, 328.0, 1697.0, 391.0), 549, 581),
    ((1689.0, -295.0, 1697.0, 295.0), 549, 581),
    ((1689.0, -328.0, 1697.0, -320.0), 573, 572),
    ((1689.0, 320.0, 1697.0, 328.0), 573, 572),
    ((1689.0, -320.0, 1697.0, -295.0), 601, 572),
    ((1689.0, 295.0, 1697.0, 320.0), 601, 572),
    ((1201.0, -391.0, 1209.0, -383.0), 544, 620),
    ((1201.0, 383.0, 1209.0, 391.0), 544, 620),
    ((1201.0, -544.0, 1209.0, -391.0), 516, 511),
    ((1201.0, 391.0, 1209.0, 544.0), 516, 511),
)

# El tramo central del muro este usa un perfil unico. Elevar su control
# inferior conserva exactamente su acabado 128..136 sin crear un tag nuevo.
EAST_CENTER_BOUNDS = (1689.0, -64.0, 1697.0, 64.0)
EAST_CENTER_TAG = 551
EAST_CENTER_CONTROL_BASE = (0, 136, MANSION_WALL, MANSION_WALL)
EAST_CENTER_CONTROL_OPEN = (128, 136, MANSION_WALL, MANSION_WALL)

GROUND_WALL_BOUNDS = tuple(
    bounds for bounds, _, _ in GROUND_WALL_TAG_REPLACEMENTS
) + (EAST_CENTER_BOUNDS,)

EXPECTED_TARGET_LINE_COUNT = 102
EXPECTED_CLEARED_SIDE_COUNT = 204
EXPECTED_REMOVED_MIDTEX3D_COUNT = 8
STAIR_SECTOR_DIGEST = (
    "5862699c73c2511c4db249c483b6a198b82ab8b3ea7ca467d52df6442fc04b76"
)


def sector_for_exact_bounds(blocks, bounds) -> int:
    matches = [
        index
        for index in range(len(blocks["sector"]))
        if previous.previous.ar.ap.ao.optional_sector_bounds(blocks, index)
        == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def set_sector_tags(sector, tags: tuple[int, ...]) -> None:
    """Reemplaza ID y moreids sin alterar el orden de los perfiles."""

    if not tags:
        sector.pop("id", None)
        sector.pop("moreids", None)
        return
    sector["id"] = str(tags[0])
    if len(tags) > 1:
        sector["moreids"] = '"' + " ".join(map(str, tags[1:])) + '"'
    else:
        sector.pop("moreids", None)


def replace_sector_tag(blocks, sector_index: int, old_tag: int, new_tag: int) -> None:
    ao = previous.previous.ar.ap.ao
    sector = blocks["sector"][sector_index]
    tags = list(ao.sector_tags(sector))
    if tags.count(old_tag) != 1 or new_tag in tags:
        raise ValueError(
            f"Tags inesperados en sector {sector_index}: {tuple(tags)}"
        )
    tags[tags.index(old_tag)] = new_tag
    set_sector_tags(sector, tuple(dict.fromkeys(tags)))


def target_sector_indices(blocks) -> set[int]:
    return {
        sector_for_exact_bounds(blocks, bounds)
        for bounds in GROUND_WALL_BOUNDS
    }


def upper_profile(profile, minimum: int = 128):
    """Recorta un perfil para comparar materiales y volumen superiores."""

    return tuple(
        (max(floor, minimum), ceiling, floor_texture, ceiling_texture)
        for floor, ceiling, floor_texture, ceiling_texture in profile
        if ceiling > minimum
    )


def target_upper_profiles(blocks):
    ao = previous.previous.ar.ap.ao
    return {
        bounds: upper_profile(
            ao.complete_sector_profile(
                blocks,
                sector_for_exact_bounds(blocks, bounds),
            )
        )
        for bounds in GROUND_WALL_BOUNDS
    }


def east_center_lower_control(blocks) -> int:
    ao = previous.previous.ar.ap.ao
    matches = []
    for _, sector_index in ao.active_controls(blocks, EAST_CENTER_TAG):
        sector = blocks["sector"][sector_index]
        profile = (
            ao.integer(sector, "heightfloor"),
            ao.integer(sector, "heightceiling"),
            sector.get("texturefloor", ao.MANSION_CEILING),
            sector.get("textureceiling", ao.MANSION_FLOOR),
        )
        if profile in (EAST_CENTER_CONTROL_BASE, EAST_CENTER_CONTROL_OPEN):
            matches.append(sector_index)
    if len(matches) != 1:
        raise ValueError(f"Control inferior {EAST_CENTER_TAG}: {matches}")
    return matches[0]


def open_ground_floor_walls(blocks) -> None:
    """Retira perfiles y cortinas que cerraban exclusivamente z=0..128."""

    ao = previous.previous.ar.ap.ao
    before_upper = target_upper_profiles(blocks)

    for bounds, old_tag, new_tag in GROUND_WALL_TAG_REPLACEMENTS:
        replace_sector_tag(
            blocks,
            sector_for_exact_bounds(blocks, bounds),
            old_tag,
            new_tag,
        )

    control_index = east_center_lower_control(blocks)
    control = blocks["sector"][control_index]
    if ao.integer(control, "heightfloor") != 0:
        raise ValueError("El control central este no parte de z=0")
    control["heightfloor"] = "128"

    target_sectors = target_sector_indices(blocks)
    touched_lines = 0
    cleared_sides = 0
    removed_midtex3d = 0
    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            ao.integer(blocks["sidedef"][ao.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(target_sectors):
            continue
        if len(side_names) != 2:
            raise ValueError("El cerramiento objetivo contiene una linea de un lado")
        touched_lines += 1
        for name in side_names:
            side = blocks["sidedef"][ao.integer(line, name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(
                    f"Textura media inesperada en linea objetivo: {side}"
                )
            side["texturemiddle"] = EMPTY_TEXTURE
            cleared_sides += 1
        if line.get("midtex3d") == "true":
            line.pop("midtex3d")
            removed_midtex3d += 1

    observed = (touched_lines, cleared_sides, removed_midtex3d)
    expected = (
        EXPECTED_TARGET_LINE_COUNT,
        EXPECTED_CLEARED_SIDE_COUNT,
        EXPECTED_REMOVED_MIDTEX3D_COUNT,
    )
    if observed != expected:
        raise ValueError(f"Limpieza de paredes {observed}, esperada {expected}")

    ao._PHYSICAL_CACHE_BLOCKS = None
    if target_upper_profiles(blocks) != before_upper:
        raise ValueError("La apertura cambio materiales o perfiles desde z=128")


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    return previous.previous.ground_barrier_at(blocks, x, y)


def validate_open_perimeter(blocks) -> None:
    ao = previous.previous.ar.ap.ao
    target_sectors = target_sector_indices(blocks)

    for bounds in GROUND_WALL_BOUNDS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        if sector_index not in target_sectors:
            raise ValueError(f"Sector objetivo perdido en {bounds}")
        for x, y in previous.previous.ar.ap.audit_cells(blocks, bounds):
            if ground_barrier_at(blocks, x, y):
                raise ValueError(f"Persiste pared inferior en ({x:g}, {y:g})")

    target_lines = 0
    cleared_sides = 0
    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            ao.integer(blocks["sidedef"][ao.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(target_sectors):
            continue
        target_lines += 1
        if line.get("midtex3d") == "true":
            raise ValueError("Persiste una pared midtex3d en planta baja")
        for name in side_names:
            side = blocks["sidedef"][ao.integer(line, name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError("Persiste una textura media en pared retirada")
            cleared_sides += 1

    if target_lines != EXPECTED_TARGET_LINE_COUNT:
        raise ValueError(f"Lineas objetivo inesperadas: {target_lines}")
    if cleared_sides != EXPECTED_CLEARED_SIDE_COUNT:
        raise ValueError(f"Lados abiertos inesperados: {cleared_sides}")


def validate_expected_profiles(blocks) -> None:
    ao = previous.previous.ar.ap.ao
    for bounds, _, expected_tag in GROUND_WALL_TAG_REPLACEMENTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if expected_tag not in ao.sector_tags(sector):
            raise ValueError(f"Falta perfil abierto {expected_tag} en {bounds}")
        if ao.profile_covers(
            ao.complete_sector_profile(blocks, sector_index),
            0,
            128,
        ):
            raise ValueError(f"El perfil {expected_tag} sigue cerrando {bounds}")

    control = blocks["sector"][east_center_lower_control(blocks)]
    if ao.integer(control, "heightfloor") != 128:
        raise ValueError("El control central este sigue cerrando planta baja")


def validate_preserved_architecture(blocks) -> None:
    ao = previous.previous.ar.ap.ao
    previous.validate_rear_door(blocks)
    previous.previous.ar.validate_open_ground_floor(blocks)
    previous.previous.validate_undivided_rear_room(blocks)
    previous.previous.ar.ap.validate_roof_cells(blocks)
    previous.previous.ar.ap.validate_wall_cells(blocks)
    previous.previous.ar.ap.validate_no_coincident_lines(blocks)
    previous.previous.ar.validate_preserved_architecture(blocks)
    previous.validate_exterior_grass(blocks)

    if ao.digest_json([blocks["sector"][index] for index in range(1, 13)]) != STAIR_SECTOR_DIGEST:
        raise ValueError("Cambio la geometria de las escaleras")
    if previous.previous.upper_geometry_digest(blocks) != previous.previous.UPPER_GEOMETRY_SHA256:
        raise ValueError("Cambio la ocupacion de los pisos primero o segundo")
    if ao.digest_json(blocks["thing"]) != MAP01_THINGS_SHA256:
        raise ValueError("Cambio la puerta 807 u otro actor de MAP01")


def validate_map01(path: Path, blocks) -> None:
    ao = previous.previous.ar.ap.ao
    if MAP01_UPDATED_COUNTS is not None:
        counts = ao.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0au inesperada: {counts}")

    ao._PHYSICAL_CACHE_BLOCKS = None
    previous.previous.ar.validate_closed_sector_contours(blocks)
    validate_open_perimeter(blocks)
    validate_expected_profiles(blocks)
    validate_preserved_architecture(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0au inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    ao = previous.previous.ar.ap.ao
    try:
        control = blocks["sector"][east_center_lower_control(blocks)]
        if ao.integer(control, "heightfloor") != 128:
            return False
        for bounds, old_tag, new_tag in GROUND_WALL_TAG_REPLACEMENTS:
            tags = ao.sector_tags(
                blocks["sector"][sector_for_exact_bounds(blocks, bounds)]
            )
            if new_tag not in tags or old_tag in tags:
                return False
        validate_open_perimeter(blocks)
    except ValueError:
        return False
    return True


def rebuild_map01(path: Path = MAP01) -> bool:
    ao = previous.previous.ar.ap.ao
    signature, lumps = ao.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = ao.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    counts = ao.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0at: "
            f"{counts}, {digest}"
        )

    before_upper = target_upper_profiles(blocks)
    before_upper_digest = previous.previous.upper_geometry_digest(blocks)
    open_ground_floor_walls(blocks)
    if target_upper_profiles(blocks) != before_upper:
        raise ValueError("La apertura altero perfiles superiores")
    if previous.previous.upper_geometry_digest(blocks) != before_upper_digest:
        raise ValueError("La apertura altero la ocupacion superior")

    lumps[text_index] = (
        b"TEXTMAP",
        ao.render_textmap(header, blocks).encode("utf-8"),
    )
    ao.write_wad(path, signature, lumps)

    _, written_lumps = ao.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = ao.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0at")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: muros perimetrales inferiores retirados en 4.29.0au"
        if changed
        else "MAP01: arquitectura 4.29.0au ya presente"
    )
    print("MAP02: candidato 4.29.0at preservado sin cambios")


if __name__ == "__main__":
    main()
