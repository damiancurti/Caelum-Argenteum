"""Reconstruye el perimetro inferior oriental para V4.29.0bb.

MAP01 parte exclusivamente del candidato determinista 4.29.0aw. Este
incremento usa las coordenadas aproximadas informadas durante la prueba para
resolver la topologia real del mapa:

* retira el cerramiento inferior norte añadido por 0aw;
* elimina ocho cortinas finas de planta baja en cada ala lateral;
* construye una U exterior de al menos 8 MU bajo el borde del balcon oriental;
* deja un vano de 128 MU y una puerta doble en el frente este;
* completa el muro sur entre la jamba 805 y la escalera;
* exige piso de madera en todo el interior del nuevo perimetro.

Los peldaños y toda ocupacion desde z=128 permanecen intactos. MAP02 no
cambia. Las restantes cortinas de la mansion se conservan hasta que la nueva
distribucion de planta baja sea aceptada visualmente.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0aw_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1075,
    1484,
    2674,
    455,
    225,
)
MAP01_UPDATED_SHA256: str | None = (
    "08e9463d2591dfdb0ebea30c21c6ce0fc5142128e94f4dbe412e8ae35ec01026"
)
MAP01_VERTEX_SHA256: str | None = (
    "cd95486c64b0d66f2aedbcad856eb0e9545f1e620c3a834f46e3e3a25d317bca"
)
MAP01_LINEDEF_SHA256: str | None = (
    "6595b74121d4265f23b19cb1625c73caab0c206097f1d460e2561c5b2432a9fd"
)
MAP01_SIDEDEF_SHA256: str | None = (
    "32d06fffb9efeadbcb8d16f558e0c611a9bf1413ec99ea267a3976e7b739f60e"
)
MAP01_SECTOR_SHA256: str | None = (
    "9a84f357f533f23480ad066ce2204683cb7089adf4f113b9ff51008c6639625a"
)
MAP01_THINGS_SHA256: str | None = (
    "82002873d65b34913ebed382e90eec9019f0ff7e95807385a440588e7ba5e6c2"
)

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

AO = previous.AO
MANSION_WALL = previous.MANSION_WALL
MANSION_FLOOR = AO.MANSION_FLOOR
EMPTY_TEXTURE = previous.EMPTY_TEXTURE

LOWER_WALL_TAG = previous.LOWER_WALL_TAG
NEW_PERIMETER_TAG = 623
NEW_PERIMETER_RANGE = (0, 128, MANSION_WALL, MANSION_WALL)
NEW_PERIMETER_PROFILE = (NEW_PERIMETER_RANGE,)
NEW_PERIMETER_CONTROL_SLOT = 501

# El perfil 622 sigue sirviendo al muro norte. Solo se retira de estas siete
# huellas, que formaban la L señalada junto al ala norte.
REMOVED_NORTH_RECTS = previous.EXTERIOR_WALL_RECTS

# La U coincide con el borde exterior del balcon z=128: dos retornos hacia las
# alas, dos travesaños y el frente oriental. Los retornos absorben la junta de
# 1 MU preexistente y por eso miden 9 MU; el frente deja un vano de 128 MU.
PERIMETER_RECTS = (
    ("south_return", (1305.0, -640.0, 1314.0, -391.0), 1),
    ("south_wall", (1305.0, -391.0, 1969.0, -383.0), 5),
    ("east_lower", (1961.0, -383.0, 1969.0, -64.0), 2),
    ("east_upper", (1961.0, 64.0, 1969.0, 383.0), 2),
    ("north_wall", (1305.0, 383.0, 1969.0, 391.0), 5),
    ("north_return", (1305.0, 391.0, 1314.0, 640.0), 1),
)
DOORWAY_BOUNDS = (1961.0, -64.0, 1969.0, 64.0)
INTERIOR_FLOOR_BOUNDS = (1314.0, -383.0, 1961.0, 383.0)

# Espejo exacto del muro norte 804 construido por 0aw.
SOUTH_DOOR_TO_STAIR_BOUNDS = (1113.0, -96.0, 1306.0, -72.0)
EXPECTED_SOUTH_STAIR_RECTANGLES = 4

# Cada ala tiene cuatro cortinas junto a las habitaciones y cuatro junto al
# exterior. Los pequeños empalmes de 8 MU se limpian con la misma pared para
# que no quede una tira visible entre sectores.
NORTH_WING_CURTAINS = tuple(
    previous.previous.normalized_segment(*segment)
    for segment in (
        (-25, 200, -25, 383),
        (-25, 383, -25, 391),
        (-25, 544, -25, 640),
        (96, 200, 96, 383),
        (96, 383, 96, 391),
        (96, 544, 96, 640),
        (640, 200, 640, 383),
        (640, 383, 640, 391),
        (640, 544, 640, 640),
        (761, 200, 761, 383),
        (761, 383, 761, 391),
        (761, 544, 761, 640),
    )
)
SOUTH_WING_CURTAINS = tuple(
    previous.previous.normalized_segment(*segment)
    for segment in (
        (-25, -383, -25, -200),
        (-25, -391, -25, -383),
        (-25, -640, -25, -544),
        (96, -383, 96, -200),
        (96, -391, 96, -383),
        (96, -640, 96, -544),
        (640, -383, 640, -200),
        (640, -391, 640, -383),
        (640, -640, 640, -544),
        (761, -383, 761, -200),
        (761, -391, 761, -383),
        (761, -640, 761, -544),
    )
)
WING_CURTAINS = NORTH_WING_CURTAINS + SOUTH_WING_CURTAINS
EXPECTED_WING_CURTAIN_LINES = 24
EXPECTED_WING_CURTAIN_SIDES = 48

GROUND_DOOR_GROUP = 807
UPPER_DOOR_GROUP = previous.PRESERVED_UPPER_DOOR_GROUP
GROUND_DOOR_X = 1965.0
GROUND_DOOR_Y = (-32.0, 32.0)
GROUND_DOOR_INSERT_INDEX = 219

EXPECTED_UPPER_GEOMETRY_SHA256 = previous.EXPECTED_UPPER_GEOMETRY_SHA256
EXPECTED_STAIR_SECTOR_SHA256 = previous.EXPECTED_STAIR_SECTOR_SHA256


def set_sector_tags(sector, tags: tuple[int, ...]) -> None:
    """Reescribe ID y moreids conservando el orden de los perfiles."""

    if not tags:
        sector.pop("id", None)
        sector.pop("moreids", None)
        return
    sector["id"] = str(tags[0])
    if len(tags) > 1:
        sector["moreids"] = '"' + " ".join(map(str, tags[1:])) + '"'
    else:
        sector.pop("moreids", None)


def remove_sector_tag(sector, tag: int) -> None:
    """Retira un perfil concreto sin alterar los restantes."""

    tags = list(AO.sector_tags(sector))
    if tags.count(tag) != 1:
        raise ValueError(f"Tag {tag} inesperado en sector: {tuple(tags)}")
    tags.remove(tag)
    set_sector_tags(sector, tuple(tags))


def sector_for_exact_bounds(blocks, bounds) -> int:
    """Resuelve una huella fisica unica por sus limites."""

    matches = [
        index
        for index in range(len(blocks["sector"]))
        if AO.optional_sector_bounds(blocks, index) == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def lines_for_segments(blocks, segments) -> list[int]:
    """Resuelve una linedef unica para cada segmento normalizado."""

    by_segment = {segment: [] for segment in segments}
    for index, line in enumerate(blocks["linedef"]):
        segment = previous.previous.line_segment(blocks, line)
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


def remove_old_north_wall(blocks) -> None:
    """Abre la L inferior norte de 0aw sin tocar sus perfiles superiores."""

    for bounds in REMOVED_NORTH_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        remove_sector_tag(blocks["sector"][sector_index], LOWER_WALL_TAG)
    AO._PHYSICAL_CACHE_BLOCKS = None


def remove_wing_curtains(blocks) -> None:
    """Elimina las ocho paredes planas de cada ala en planta baja."""

    cleared_sides = 0
    for line_index in lines_for_segments(blocks, WING_CURTAINS):
        line = blocks["linedef"][line_index]
        if line.get("twosided") != "true":
            raise ValueError(f"Cortina de ala unilateral: {line_index}")
        if line.get("midtex3d") != "true":
            raise ValueError(f"Cortina de ala no tridimensional: {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Material inesperado en cortina {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
            cleared_sides += 1
        line.pop("midtex3d")

    if len(WING_CURTAINS) != EXPECTED_WING_CURTAIN_LINES:
        raise ValueError("Cantidad declarada de cortinas de ala inesperada")
    if cleared_sides != EXPECTED_WING_CURTAIN_SIDES:
        raise ValueError(f"Lados de ala limpiados: {cleared_sides}")


def add_wall_control(blocks) -> None:
    """Añade un perfil independiente de pared inferior."""

    if AO.active_controls(blocks, NEW_PERIMETER_TAG):
        raise ValueError(f"El tag {NEW_PERIMETER_TAG} ya estaba ocupado")
    AO.add_profile_controls(
        blocks,
        {NEW_PERIMETER_PROFILE: NEW_PERIMETER_TAG},
        NEW_PERIMETER_CONTROL_SLOT,
    )


def carve_wall_rectangles(
    blocks,
    bounds,
    kind: str,
    expected_count: int,
    wall_tag: int,
) -> list[int]:
    """Talla una franja contra sus anfitriones y conserva todos sus pisos."""

    rectangles = AO.rectangular_area_rectangles(
        blocks,
        bounds,
        kind,
        expected_count,
    )
    targets = []
    grouped_by_host: dict[int, list[tuple]] = {}
    for rectangle in rectangles:
        grouped_by_host.setdefault(rectangle[4], []).append(rectangle)

    # Una linedef de otra capa puede partir visualmente un sector fisico sin
    # dividir su huella. Si todas las celdas de ese anfitrion cubren su huella
    # completa, se etiqueta una sola vez y no se crean bordes coincidentes.
    complete_hosts: set[int] = set()
    for host, hosted_rectangles in grouped_by_host.items():
        host_bounds = AO.optional_sector_bounds(blocks, host)
        if host_bounds is None:
            continue
        host_x0, host_y0, host_x1, host_y1 = host_bounds
        bound_x0, bound_y0, bound_x1, bound_y1 = bounds
        if not (
            bound_x0 <= host_x0
            and bound_y0 <= host_y0
            and host_x1 <= bound_x1
            and host_y1 <= bound_y1
        ):
            continue
        host_area = (host_x1 - host_x0) * (host_y1 - host_y0)
        covered_area = sum(
            (rectangle[2] - rectangle[0])
            * (rectangle[3] - rectangle[1])
            for rectangle in hosted_rectangles
        )
        if covered_area != host_area:
            continue
        AO.add_sector_tag(blocks["sector"][host], wall_tag)
        targets.append(host)
        complete_hosts.add(host)

    for rectangle in rectangles:
        rectangle_bounds = tuple(rectangle[:4])
        host = rectangle[4]
        if host in complete_hosts:
            continue
        if AO.optional_sector_bounds(blocks, host) == rectangle_bounds:
            target = host
        else:
            primary = AO.integer(blocks["sector"][host], "id")
            carve_tag = wall_tag if primary is None else primary
            target = AO.carve_from_host(
                blocks,
                rectangle_bounds,
                host,
                carve_tag,
            )
        AO.add_sector_tag(blocks["sector"][target], wall_tag)
        targets.append(target)
    AO._PHYSICAL_CACHE_BLOCKS = None
    return targets


def clear_wall_boundary_midtextures(blocks, targets: set[int]) -> None:
    """Evita paneles coplanares sobre los volumenes solidos nuevos."""

    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            AO.integer(blocks["sidedef"][AO.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(targets):
            continue
        for side_name in side_names:
            side = blocks["sidedef"][AO.integer(line, side_name)]
            side["texturemiddle"] = EMPTY_TEXTURE
        line.pop("midtex3d", None)


def build_perimeter(blocks) -> set[int]:
    """Construye la U gruesa bajo el borde exterior del balcon."""

    targets: set[int] = set()
    for kind, bounds, expected_count in PERIMETER_RECTS:
        targets.update(
            carve_wall_rectangles(
                blocks,
                bounds,
                f"perimetro_{kind}",
                expected_count,
                NEW_PERIMETER_TAG,
            )
        )
    clear_wall_boundary_midtextures(blocks, targets)
    return targets


def build_south_stair_wall(blocks) -> set[int]:
    """Completa el muro inferior desde la jamba 805 hasta la escalera."""

    targets = set(
        carve_wall_rectangles(
            blocks,
            SOUTH_DOOR_TO_STAIR_BOUNDS,
            "muro_puerta_805_escalera",
            EXPECTED_SOUTH_STAIR_RECTANGLES,
            LOWER_WALL_TAG,
        )
    )
    clear_wall_boundary_midtextures(blocks, targets)
    return targets


def ensure_interior_floor(blocks) -> None:
    """Fija madera en el recinto y en el umbral de la puerta nueva."""

    areas = (
        (INTERIOR_FLOOR_BOUNDS, "piso_interior"),
        (DOORWAY_BOUNDS, "piso_umbral"),
    )
    for bounds, kind in areas:
        rectangles = AO.rectangular_area_rectangles(blocks, bounds, kind)
        for rectangle in rectangles:
            host = rectangle[4]
            blocks["sector"][host]["texturefloor"] = MANSION_FLOOR


def door_things(blocks, group: int) -> list[OrderedDict]:
    return sorted(
        (
            thing
            for thing in blocks["thing"]
            if AO.integer(thing, "type") == 18025
            and AO.integer(thing, "arg0") == group
        ),
        key=lambda thing: float(thing["y"]),
    )


def add_ground_door(blocks) -> None:
    """Añade dos hojas de 64 MU en el vano oriental de planta baja."""

    if door_things(blocks, GROUND_DOOR_GROUP):
        raise ValueError(f"La base ya contiene la puerta {GROUND_DOOR_GROUP}")
    sources = door_things(blocks, UPPER_DOOR_GROUP)
    if len(sources) != 2:
        raise ValueError("La puerta superior 913 no conserva dos hojas")

    doors = []
    for source, y in zip(sources, GROUND_DOOR_Y):
        door = OrderedDict(source)
        door["x"] = f"{GROUND_DOOR_X:.1f}"
        door["y"] = f"{y:.1f}"
        door["height"] = "0.0"
        door["angle"] = "0"
        door["arg0"] = str(GROUND_DOOR_GROUP)
        door["arg2"] = "1"
        door["arg3"] = "0"
        doors.append(door)
    blocks["thing"][GROUND_DOOR_INSERT_INDEX:GROUND_DOOR_INSERT_INDEX] = doors


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    return previous.ground_barrier_at(blocks, x, y)


def validate_old_north_wall_removed(blocks) -> None:
    for bounds in REMOVED_NORTH_RECTS:
        rectangles = AO.rectangular_area_rectangles(
            blocks,
            bounds,
            "auditoria_L_norte_retirada",
        )
        for rectangle in rectangles:
            sector_index = rectangle[4]
            if LOWER_WALL_TAG in AO.sector_tags(blocks["sector"][sector_index]):
                raise ValueError(f"Persiste el muro norte anterior en {bounds}")

    # Estos puntos pertenecen solo a los retornos eliminados, no al nuevo
    # travesaño que necesariamente vuelve a ocupar y=383..391 desde x=1305.
    for x, y in ((1205, 500), (1250, 387), (1693, 350)):
        AO._PHYSICAL_CACHE_BLOCKS = None
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"Persiste la L norte anterior en ({x:g}, {y:g})")


def validate_wing_curtains_removed(blocks) -> None:
    cleared_sides = 0
    for line_index in lines_for_segments(blocks, WING_CURTAINS):
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") == "true":
            raise ValueError(f"Persiste cortina de ala en linea {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError(f"Persiste panel de ala en linea {line_index}")
            cleared_sides += 1
    if cleared_sides != EXPECTED_WING_CURTAIN_SIDES:
        raise ValueError(f"Lados de ala abiertos: {cleared_sides}")


def validate_perimeter(blocks) -> None:
    if AO.control_profile(blocks, NEW_PERIMETER_TAG) != NEW_PERIMETER_PROFILE:
        raise ValueError("Perfil del nuevo perimetro inesperado")

    solid_points = (
        (1309, -520),
        (1309, 520),
        (1400, -387),
        (1750, -387),
        (1950, -387),
        (1400, 387),
        (1750, 387),
        (1950, 387),
        (1965, -300),
        (1965, -100),
        (1965, 100),
        (1965, 300),
    )
    for x, y in solid_points:
        AO._PHYSICAL_CACHE_BLOCKS = None
        if not ground_barrier_at(blocks, x, y):
            raise ValueError(f"Perimetro abierto en ({x:g}, {y:g})")

    open_points = (
        (1325, -410),
        (1325, 410),
        (1500, -370),
        (1500, 370),
        (1950, 0),
        (1980, 0),
    )
    for x, y in open_points:
        AO._PHYSICAL_CACHE_BLOCKS = None
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"Perimetro invade el paso en ({x:g}, {y:g})")

    targets = {
        index
        for index, sector in enumerate(blocks["sector"])
        if NEW_PERIMETER_TAG in AO.sector_tags(sector)
    }
    if not targets:
        raise ValueError("No se encontraron sectores del nuevo perimetro")
    for line in blocks["linedef"]:
        side_names = [
            name for name in ("sidefront", "sideback") if name in line
        ]
        owners = {
            AO.integer(blocks["sidedef"][AO.integer(line, name)], "sector")
            for name in side_names
        }
        if not owners.intersection(targets):
            continue
        if line.get("midtex3d") == "true":
            raise ValueError("Persiste una cortina sobre el nuevo perimetro")
        for side_name in side_names:
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError("Persiste textura media sobre el perimetro")


def validate_south_stair_wall(blocks) -> None:
    rectangles = AO.rectangular_area_rectangles(
        blocks,
        SOUTH_DOOR_TO_STAIR_BOUNDS,
        "auditoria_muro_puerta_805_escalera",
        EXPECTED_SOUTH_STAIR_RECTANGLES,
    )
    targets = {rectangle[4] for rectangle in rectangles}
    for target in targets:
        if LOWER_WALL_TAG not in AO.sector_tags(blocks["sector"][target]):
            raise ValueError(f"Falta muro sur en sector {target}")
        if not AO.profile_covers(
            AO.complete_sector_profile(blocks, target),
            0,
            128,
        ):
            raise ValueError(f"Perfil incompleto en muro sur {target}")

    for x, y in ((1098, -84), (1114, -84), (1205, -84), (1305.5, -84)):
        AO._PHYSICAL_CACHE_BLOCKS = None
        if not ground_barrier_at(blocks, x, y):
            raise ValueError(f"Muro sur abierto en ({x:g}, {y:g})")
    for x, y in ((1096, -84), (1307, -84)):
        AO._PHYSICAL_CACHE_BLOCKS = None
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"Muro sur excede su limite en ({x:g}, {y:g})")


def validate_floor(blocks) -> None:
    for bounds, kind in (
        (INTERIOR_FLOOR_BOUNDS, "auditoria_piso_interior"),
        (DOORWAY_BOUNDS, "auditoria_piso_umbral"),
    ):
        rectangles = AO.rectangular_area_rectangles(blocks, bounds, kind)
        for rectangle in rectangles:
            sector = blocks["sector"][rectangle[4]]
            if sector.get("texturefloor") != MANSION_FLOOR:
                raise ValueError(f"Piso sin madera en {rectangle[:4]}")


def validate_doors(blocks) -> None:
    doors = door_things(blocks, GROUND_DOOR_GROUP)
    observed = [
        (
            float(door["x"]),
            float(door["y"]),
            float(door["height"]),
            AO.integer(door, "arg1"),
        )
        for door in doors
    ]
    expected = [
        (GROUND_DOOR_X, -32.0, 0.0, -1),
        (GROUND_DOOR_X, 32.0, 0.0, 1),
    ]
    if observed != expected:
        raise ValueError(f"Puerta inferior inesperada: {observed}")

    upper = door_things(blocks, UPPER_DOOR_GROUP)
    if [
        (float(door["x"]), float(door["y"]), float(door["height"]))
        for door in upper
    ] != [(1693.0, -32.0, 136.0), (1693.0, 32.0, 136.0)]:
        raise ValueError("La puerta superior 913 cambio")


def validate_preserved_architecture(blocks) -> None:
    previous.previous.validate_ground_curtains_removed(blocks)
    previous.previous.previous.previous.previous.ar.ap.validate_roof_cells(blocks)
    previous.previous.previous.previous.previous.ar.ap.validate_wall_cells(blocks)
    previous.previous.previous.previous.previous.ar.ap.validate_no_coincident_lines(blocks)

    stair_digest = AO.digest_json(
        [blocks["sector"][index] for index in range(1, 13)]
    )
    if stair_digest != EXPECTED_STAIR_SECTOR_SHA256:
        raise ValueError("Cambio la geometria de las escaleras")

    upper_digest = (
        previous.previous.previous.previous.previous.upper_geometry_digest(blocks)
    )
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
            raise ValueError(f"Estructura MAP01 4.29.0bb inesperada: {counts}")

    previous.previous.previous.previous.previous.ar.validate_closed_sector_contours(
        blocks
    )
    validate_old_north_wall_removed(blocks)
    validate_wing_curtains_removed(blocks)
    validate_perimeter(blocks)
    validate_south_stair_wall(blocks)
    validate_floor(blocks)
    validate_doors(blocks)
    validate_preserved_architecture(blocks)
    validate_component_digests(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0bb inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_old_north_wall_removed(blocks)
        validate_wing_curtains_removed(blocks)
        validate_perimeter(blocks)
        validate_south_stair_wall(blocks)
        validate_floor(blocks)
        validate_doors(blocks)
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
            "MAP01 no coincide con la base aceptada 4.29.0aw: "
            f"{counts}, {digest}"
        )

    before_upper = (
        previous.previous.previous.previous.previous.upper_geometry_digest(blocks)
    )
    before_stairs = AO.digest_json(
        [blocks["sector"][index] for index in range(1, 13)]
    )

    remove_old_north_wall(blocks)
    remove_wing_curtains(blocks)
    add_wall_control(blocks)
    build_perimeter(blocks)
    build_south_stair_wall(blocks)
    ensure_interior_floor(blocks)
    add_ground_door(blocks)
    AO._PHYSICAL_CACHE_BLOCKS = None

    if (
        previous.previous.previous.previous.previous.upper_geometry_digest(blocks)
        != before_upper
    ):
        raise ValueError("La reconstruccion cambio un piso superior")
    if AO.digest_json([blocks["sector"][index] for index in range(1, 13)]) != before_stairs:
        raise ValueError("La reconstruccion cambio una escalera")

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
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0aw")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: U gruesa, puerta este, muro sur y alas abiertas"
        if changed
        else "MAP01: arquitectura 4.29.0bb ya presente"
    )
    print("MAP02: candidato 4.29.0aw preservado sin cambios")


if __name__ == "__main__":
    main()
