"""Corrige dos muros norte y retira la U inferior oriental en 4.29.0aw.

MAP01 parte exclusivamente del candidato determinista 4.29.0av. Las dos
capturas norte muestran dos perdidas complementarias: la cortina fina situada
junto a la puerta 804 y los tramos que 0av retiro hasta la escalera, ademas del
cerramiento exterior norte que une el edificio con el vuelo oriental.

Este incremento sustituye esas piezas por volumenes reales de planta baja:
un muro de 24 MU entre la jamba de 804 y la escalera interior y un muro
exterior continuo de 8 MU. Ademas elimina la unica U completa de cortinas
inferiores orientales y las dos hojas 807. La puerta 913, las escaleras y toda
la ocupacion desde z=128 permanecen intactas. MAP02 no cambia.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0av_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1052,
    1448,
    2606,
    441,
    223,
)
MAP01_UPDATED_SHA256: str | None = (
    "e704fa8f8e9419839ae1dc0a5081001bb5ef0c3286f80f3f0b50a61d3e270fb1"
)
MAP01_VERTEX_SHA256: str | None = (
    "4a2e8d6fa1939f79029a04d961d9f419ac68a90893d97bda24a2665b3ef1ebaa"
)
MAP01_LINEDEF_SHA256: str | None = (
    "719c60a830d07758f8f93361a25c5aa2a51b66c1f34ddb615804192cfb775c38"
)
MAP01_SIDEDEF_SHA256: str | None = (
    "84dfbf66a753e1b959017562739cc0b0a3f7bb8dcbc96fa0796be4f17515e82e"
)
MAP01_SECTOR_SHA256: str | None = (
    "23ed59e10cd040eeac1e98a3d9d77aea11d8f28f9f68c7e7c5ef108ddbea42dc"
)
MAP01_THINGS_SHA256: str | None = (
    "148e30c5e523354a65a44d533f67e7aea44068e6bb3249a54333ce5372888a3f"
)

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

AO = previous.AO
MANSION_WALL = previous.MANSION_WALL
EMPTY_TEXTURE = previous.EMPTY_TEXTURE

LOWER_WALL_TAG = 622
LOWER_WALL_RANGE = (0, 128, MANSION_WALL, MANSION_WALL)
LOWER_WALL_CONTROL_SLOT = 500

# La jamba 1097..1113 ya tiene floor=128. Estas cuatro huellas completan el
# muro de 24 MU desde esa jamba hasta la cara occidental del vuelo norte.
DOOR_TO_STAIR_BOUNDS = (1113.0, 72.0, 1306.0, 96.0)
EXPECTED_DOOR_WALL_RECTANGLES = 4
EXPECTED_DOOR_WALL_BOUNDARY_LINES = 14
EXPECTED_DOOR_WALL_BOUNDARY_SIDES = 28

# Las siete huellas ya existen como sectores de 8 MU. Solo reciben el nuevo
# perfil inferior, por lo que no se talla ni se mueve geometria superior.
EXTERIOR_WALL_RECTS = (
    (1201.0, 391.0, 1209.0, 544.0),
    (1201.0, 383.0, 1209.0, 391.0),
    (1209.0, 383.0, 1305.0, 391.0),
    (1305.0, 383.0, 1306.0, 391.0),
    (1306.0, 383.0, 1689.0, 391.0),
    (1689.0, 320.0, 1697.0, 328.0),
    (1689.0, 328.0, 1697.0, 391.0),
)

EASTERN_U_SEGMENTS = tuple(
    previous.normalized_segment(*segment)
    for segment in (
        (1697, 272, 1816, 272),
        (1816, 272, 1969, 272),
        (1969, -272, 1969, 272),
        (1816, -272, 1969, -272),
        (1697, -272, 1816, -272),
    )
)
EXPECTED_U_LINE_COUNT = 5
EXPECTED_U_SIDE_COUNT = 10

REMOVED_REAR_DOOR_GROUP = 807
PRESERVED_UPPER_DOOR_GROUP = 913
EXPECTED_UPPER_GEOMETRY_SHA256 = (
    "cde1b9a7074268a0643bc6375cb65b8babff3c617847c67c5db66f58bd0420b0"
)
EXPECTED_STAIR_SECTOR_SHA256 = previous.previous.STAIR_SECTOR_DIGEST


def sector_for_exact_bounds(blocks, bounds) -> int:
    """Resuelve una huella fisica unica sin depender de indices historicos."""

    matches = [
        index
        for index in range(len(blocks["sector"]))
        if AO.optional_sector_bounds(blocks, index) == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def lines_for_segments(blocks, segments) -> list[int]:
    """Resuelve una unica linedef por cada segmento normalizado."""

    by_segment = {segment: [] for segment in segments}
    for index, line in enumerate(blocks["linedef"]):
        segment = previous.line_segment(blocks, line)
        if segment in by_segment:
            by_segment[segment].append(index)
    failures = {
        segment: indices
        for segment, indices in by_segment.items()
        if len(indices) != 1
    }
    if failures:
        raise ValueError(f"Segmentos no univocos: {failures}")
    return [by_segment[segment][0] for segment in segments]


def add_lower_wall_control(blocks) -> None:
    """Añade un unico control 3D de muro inferior sin bandas superiores."""

    if AO.active_controls(blocks, LOWER_WALL_TAG):
        raise ValueError(f"El tag {LOWER_WALL_TAG} ya estaba ocupado")
    AO.add_profile_controls(
        blocks,
        {(LOWER_WALL_RANGE,): LOWER_WALL_TAG},
        LOWER_WALL_CONTROL_SLOT,
    )


def add_exterior_wall(blocks) -> list[int]:
    """Cierra el contorno norte con las siete huellas existentes de 8 MU."""

    targets = []
    for bounds in EXTERIOR_WALL_RECTS:
        target = sector_for_exact_bounds(blocks, bounds)
        if LOWER_WALL_TAG in AO.sector_tags(blocks["sector"][target]):
            raise ValueError(f"Muro exterior ya etiquetado en {bounds}")
        AO.add_sector_tag(blocks["sector"][target], LOWER_WALL_TAG)
        targets.append(target)
    return targets


def add_door_to_stair_wall(blocks) -> list[int]:
    """Convierte el antiguo panel norte en un muro solido de 24 MU."""

    rectangles = AO.rectangular_area_rectangles(
        blocks,
        DOOR_TO_STAIR_BOUNDS,
        "muro_puerta_804_escalera",
        EXPECTED_DOOR_WALL_RECTANGLES,
    )
    targets = []
    for rectangle in rectangles:
        bounds = tuple(rectangle[:4])
        host = rectangle[4]
        if AO.optional_sector_bounds(blocks, host) == bounds:
            target = host
        else:
            # carve_from_host reemplaza el ID primario. Se talla con el mismo
            # ID del host y luego se agrega 622 para conservar todos sus pisos.
            primary = AO.integer(blocks["sector"][host], "id")
            if primary is None:
                raise ValueError(f"Host sin ID primario en {bounds}")
            target = AO.carve_from_host(blocks, bounds, host, primary)
        AO.add_sector_tag(blocks["sector"][target], LOWER_WALL_TAG)
        targets.append(target)
    return targets


def clear_door_wall_panels(blocks, target_sectors: set[int]) -> None:
    """Quita la cortina 608 y todas las texturas coplanares del nuevo muro."""

    touched_lines = 0
    touched_sides = 0
    removed_midtex3d = 0
    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            AO.integer(blocks["sidedef"][AO.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(target_sectors):
            continue
        if len(side_names) != 2 or line.get("twosided") != "true":
            raise ValueError("El muro norte contiene un borde no bilateral")
        touched_lines += 1
        for name in side_names:
            side = blocks["sidedef"][AO.integer(line, name)]
            side["texturemiddle"] = EMPTY_TEXTURE
            touched_sides += 1
        if line.get("midtex3d") == "true":
            line.pop("midtex3d")
            removed_midtex3d += 1

    observed = (touched_lines, touched_sides, removed_midtex3d)
    expected = (
        EXPECTED_DOOR_WALL_BOUNDARY_LINES,
        EXPECTED_DOOR_WALL_BOUNDARY_SIDES,
        1,
    )
    if observed != expected:
        raise ValueError(f"Limpieza del muro norte {observed}, esperada {expected}")


def remove_eastern_u_and_lower_door(blocks) -> None:
    """Retira solo la U de cortinas z=0..128 y las dos hojas inferiores 807."""

    cleared_sides = 0
    for line_index in lines_for_segments(blocks, EASTERN_U_SEGMENTS):
        line = blocks["linedef"][line_index]
        if line.get("twosided") != "true":
            raise ValueError(f"Lado de U no bilateral: {line_index}")
        if line.get("dontpegbottom") != "true":
            raise ValueError(f"Lado de U sin anclaje inferior: {line_index}")
        if line.get("midtex3d") != "true":
            raise ValueError(f"Lado de U no es cortina 3D: {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Textura inesperada en U: {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
            cleared_sides += 1
        line.pop("midtex3d")

    doors = [
        thing
        for thing in blocks["thing"]
        if AO.integer(thing, "type") == 18025
        and AO.integer(thing, "arg0") == REMOVED_REAR_DOOR_GROUP
    ]
    if len(doors) != 2:
        raise ValueError(f"Hojas 807 de base inesperadas: {len(doors)}")
    blocks["thing"] = [thing for thing in blocks["thing"] if thing not in doors]

    if cleared_sides != EXPECTED_U_SIDE_COUNT:
        raise ValueError(f"Lados retirados de la U: {cleared_sides}")


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    return previous.previous.previous.previous.ground_barrier_at(blocks, x, y)


def validate_wall_profile(blocks, sector_index: int) -> None:
    profile = AO.complete_sector_profile(blocks, sector_index)
    if not AO.profile_covers(profile, 0, 128):
        raise ValueError(f"Falta muro inferior en sector {sector_index}")


def door_wall_target_sectors(blocks) -> list[int]:
    rectangles = AO.rectangular_area_rectangles(
        blocks,
        DOOR_TO_STAIR_BOUNDS,
        "auditoria_muro_puerta_804_escalera",
        EXPECTED_DOOR_WALL_RECTANGLES,
    )
    return [rectangle[4] for rectangle in rectangles]


def validate_walls(blocks) -> None:
    """Comprueba espesor, continuidad y ausencia de paneles superpuestos."""

    if AO.control_profile(blocks, LOWER_WALL_TAG) != (LOWER_WALL_RANGE,):
        raise ValueError(f"Perfil de muro {LOWER_WALL_TAG} inesperado")

    exterior_targets = []
    for bounds in EXTERIOR_WALL_RECTS:
        target = sector_for_exact_bounds(blocks, bounds)
        exterior_targets.append(target)
        if LOWER_WALL_TAG not in AO.sector_tags(blocks["sector"][target]):
            raise ValueError(f"Falta muro exterior en {bounds}")
        validate_wall_profile(blocks, target)

    door_targets = door_wall_target_sectors(blocks)
    for target in door_targets:
        if LOWER_WALL_TAG not in AO.sector_tags(blocks["sector"][target]):
            raise ValueError(f"Falta muro puerta-escalera en sector {target}")
        validate_wall_profile(blocks, target)

    touched_lines = 0
    touched_sides = 0
    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            AO.integer(blocks["sidedef"][AO.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(door_targets):
            continue
        touched_lines += 1
        if line.get("midtex3d") == "true":
            raise ValueError("Persiste una cortina coplanar en el muro norte")
        for name in side_names:
            side = blocks["sidedef"][AO.integer(line, name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError("Persiste una textura media en el muro norte")
            touched_sides += 1

    observed = (touched_lines, touched_sides)
    expected = (
        EXPECTED_DOOR_WALL_BOUNDARY_LINES,
        EXPECTED_DOOR_WALL_BOUNDARY_SIDES,
    )
    if observed != expected:
        raise ValueError(f"Bordes del muro norte {observed}, esperados {expected}")

    # La jamba conserva su propio volumen y el nuevo muro no invade el vuelo.
    for x, y in ((1098, 84), (1114, 84), (1205, 84), (1305.5, 84)):
        AO._PHYSICAL_CACHE_BLOCKS = None
        if not ground_barrier_at(blocks, x, y):
            raise ValueError(f"Muro norte abierto en ({x:g}, {y:g})")
    for x, y in ((1096, 84), (1307, 84)):
        AO._PHYSICAL_CACHE_BLOCKS = None
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"Muro norte excede su limite en ({x:g}, {y:g})")


def validate_eastern_u_and_door_removed(blocks) -> None:
    cleared_sides = 0
    line_indices = lines_for_segments(blocks, EASTERN_U_SEGMENTS)
    if len(line_indices) != EXPECTED_U_LINE_COUNT:
        raise ValueError(f"Lados de U inesperados: {len(line_indices)}")
    for line_index in line_indices:
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") == "true":
            raise ValueError(f"Persiste cortina de U en linea {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError(f"Persiste paño de U en linea {line_index}")
            cleared_sides += 1
    if cleared_sides != EXPECTED_U_SIDE_COUNT:
        raise ValueError(f"Lados abiertos de U inesperados: {cleared_sides}")

    if any(
        AO.integer(thing, "type") == 18025
        and AO.integer(thing, "arg0") == REMOVED_REAR_DOOR_GROUP
        for thing in blocks["thing"]
    ):
        raise ValueError("Persisten hojas de la puerta inferior 807")

    upper_doors = sorted(
        (
            thing
            for thing in blocks["thing"]
            if AO.integer(thing, "type") == 18025
            and AO.integer(thing, "arg0") == PRESERVED_UPPER_DOOR_GROUP
        ),
        key=lambda thing: float(thing["y"]),
    )
    if len(upper_doors) != 2:
        raise ValueError("La puerta superior 913 no conserva dos hojas")
    if [
        (float(door["x"]), float(door["y"]), float(door["height"]))
        for door in upper_doors
    ] != [(1693.0, -32.0, 136.0), (1693.0, 32.0, 136.0)]:
        raise ValueError("La puerta superior 913 cambio de posicion")


def validate_preserved_architecture(blocks) -> None:
    """Valida todo lo conservado sin exigir el perimetro abierto de 0av."""

    previous.validate_ground_curtains_removed(blocks)
    previous.previous.previous.previous.ar.ap.validate_roof_cells(blocks)
    previous.previous.previous.previous.ar.ap.validate_wall_cells(blocks)
    previous.previous.previous.previous.ar.ap.validate_no_coincident_lines(blocks)
    previous.previous.previous.previous.ar.validate_preserved_architecture(blocks)
    previous.previous.previous.validate_exterior_grass(blocks)

    stair_digest = AO.digest_json(
        [blocks["sector"][index] for index in range(1, 13)]
    )
    if stair_digest != EXPECTED_STAIR_SECTOR_SHA256:
        raise ValueError("Cambio la geometria de las escaleras")

    upper_digest = previous.previous.previous.previous.upper_geometry_digest(blocks)
    if upper_digest != EXPECTED_UPPER_GEOMETRY_SHA256:
        raise ValueError(f"Cambio la ocupacion de pisos superiores: {upper_digest}")


def validate_component_digests(blocks) -> None:
    expected = (
        ("vertices", AO.digest_json(blocks["vertex"]), MAP01_VERTEX_SHA256),
        ("linedefs", AO.digest_json(blocks["linedef"]), MAP01_LINEDEF_SHA256),
        ("sidedefs", AO.digest_json(blocks["sidedef"]), MAP01_SIDEDEF_SHA256),
        ("sectores", AO.digest_json(blocks["sector"]), MAP01_SECTOR_SHA256),
        ("actores", AO.digest_json(blocks["thing"]), MAP01_THINGS_SHA256),
    )
    for name, observed, reference in expected:
        if reference is not None and observed != reference:
            raise ValueError(f"Digest de {name} inesperado: {observed}")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = AO.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0aw inesperada: {counts}")

    AO._PHYSICAL_CACHE_BLOCKS = None
    previous.previous.previous.previous.ar.validate_closed_sector_contours(blocks)
    validate_walls(blocks)
    validate_eastern_u_and_door_removed(blocks)
    validate_preserved_architecture(blocks)
    validate_component_digests(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0aw inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_walls(blocks)
        validate_eastern_u_and_door_removed(blocks)
    except ValueError:
        return False
    return True


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = AO.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = AO.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    counts = AO.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0av: "
            f"{counts}, {digest}"
        )

    before_upper = previous.previous.previous.previous.upper_geometry_digest(blocks)
    before_stairs = AO.digest_json(
        [blocks["sector"][index] for index in range(1, 13)]
    )
    add_lower_wall_control(blocks)
    add_exterior_wall(blocks)
    door_targets = add_door_to_stair_wall(blocks)
    clear_door_wall_panels(blocks, set(door_targets))
    remove_eastern_u_and_lower_door(blocks)
    AO._PHYSICAL_CACHE_BLOCKS = None

    if previous.previous.previous.previous.upper_geometry_digest(blocks) != before_upper:
        raise ValueError("La correccion cambio un piso superior")
    if AO.digest_json([blocks["sector"][index] for index in range(1, 13)]) != before_stairs:
        raise ValueError("La correccion cambio una escalera")

    lumps[text_index] = (
        b"TEXTMAP",
        AO.render_textmap(header, blocks).encode("utf-8"),
    )
    AO.write_wad(path, signature, lumps)

    _, written_lumps = AO.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = AO.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0av")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: muros norte solidos; U inferior y puerta 807 retiradas"
        if changed
        else "MAP01: arquitectura 4.29.0aw ya presente"
    )
    print("MAP02: candidato 4.29.0av preservado sin cambios")


if __name__ == "__main__":
    main()
