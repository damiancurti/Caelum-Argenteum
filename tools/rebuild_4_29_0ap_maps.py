"""Corrige el cerramiento oriental de MAP01 para V4.29.0ap.

La entrada autorizada es exclusivamente el MAP01 validado de 4.29.0ao. Las
dos paredes transversales aprobadas se conservan. Se añaden dos paredes de
8 MU pegadas al lado interior de los vuelos exteriores, desde y=+-320 hasta
el vano central y=+-64 del porton 913. La cubierta z=256..264 deja de depender
de perfiles heredados fragmentarios: ocupa exactamente x=1209..1697,
y=-328..328, mas el descanso central y los dos ultimos peldaños ya existentes.
Los balcones laterales y el resto de los peldaños permanecen fuera de esa losa.

MAP02 permanece byte-identico al candidato 4.29.0ao.
"""

from __future__ import annotations

from collections import defaultdict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ao_maps as ao


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = ao.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = ao.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1029,
    1424,
    2578,
    431,
    227,
)
MAP01_UPDATED_SHA256: str | None = (
    "d7c54872c3de2f7bf4dc1800bded68909cf3484ddb6e82fb00812cf203ec46d7"
)

MAP02_UPDATED_COUNTS = ao.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = ao.MAP02_UPDATED_SHA256

# La losa incluye el remate de las paredes transversales. El descanso y los
# dos ultimos peldaños conservan sus propios controles 538 y 537. El cuerpo
# interior se etiqueta sobre los sectores existentes; solo las dos franjas
# exteriores se vuelven a tallar para recortar perfiles que cruzan el borde.
EXACT_ROOF = (1209.0, -328.0, 1697.0, 328.0)
ROOF_INTERIOR = (1209.0, -320.0, 1689.0, 320.0)
ROOF_CLEANUP_STRIPS = (
    (1209.0, -391.0, 1689.0, -328.0),
    (1209.0, 328.0, 1689.0, 391.0),
)
LANDING_ROOF = (1697.0, -64.0, 1825.0, 64.0)
TOP_STEPS = (
    (1697.0, -96.0, 1816.0, -64.0),
    (1697.0, 64.0, 1816.0, 96.0),
)
ROOF_AUDIT_BOUNDS = (1209.0, -391.0, 1969.0, 391.0)

# Cada pared nace en la cara interior de la transversal correspondiente y
# termina en un borde del vano de 128 MU. No ocupa ningun peldaño.
STAIR_RUN_WALLS = (
    (1689.0, -320.0, 1697.0, -64.0),
    (1689.0, 64.0, 1697.0, 320.0),
)
STAIR_RUN_WALL_TAILS = (
    (1689.0, -320.0, 1697.0, -295.0),
    (1689.0, 295.0, 1697.0, 320.0),
)
FRONT_HOST_SECTOR = 83
FRONT_HOST_BOUNDS = (1689.0, -295.0, 1697.0, 295.0)
CENTRAL_GATE = (1689.0, -64.0, 1697.0, 64.0)

# Este perfil de 0ao extendia la cubierta por sectores completos en el anexo.
# Los muros occidentales 542/544 pertenecen al edificio previo y no se alteran.
LEGACY_ROOF_TAGS = (ao.FIRST_FLOOR_ONLY_TAG,)

EXACT_ROOF_PROFILE_TAG_START = 580
EXACT_ROOF_PROFILE_TAG_END = 600
STAIR_RUN_WALL_PROFILE_TAG_START = 600
STAIR_RUN_WALL_PROFILE_TAG_END = 620

EXPECTED_ROOF_CLEANUP_RECTANGLES: int | None = 20
EXPECTED_STAIR_RUN_WALL_RECTANGLES: int | None = 2
MAP01_THINGS_SHA256 = (
    "b715d40e8f43f3aa796be2bcaf736fe6f143fec2594c2ceea255b9cc15e2b385"
)


def entry_for_control(blocks, sector_index: int) -> ao.ProfileEntry:
    sector = blocks["sector"][sector_index]
    return (
        ao.integer(sector, "heightfloor"),
        ao.integer(sector, "heightceiling"),
        sector.get("texturefloor", ao.MANSION_CEILING),
        sector.get("textureceiling", ao.MANSION_FLOOR),
    )


def disable_legacy_roof_controls(blocks) -> None:
    """Desactiva solo la losa 256..264 de los perfiles amplios de 0ao."""

    for tag in LEGACY_ROOF_TAGS:
        matches = 0
        for line, sector_index in list(ao.active_controls(blocks, tag)):
            if entry_for_control(blocks, sector_index) != ao.SECOND_FLOOR_RANGE:
                continue
            line["special"] = "0"
            for argument in ("arg0", "arg1", "arg2", "arg3", "arg4"):
                line.pop(argument, None)
            matches += 1
        if matches != 1:
            raise ValueError(
                f"Controles de cubierta heredados para tag {tag}: {matches}"
            )


def remove_roof_range(profile: ao.Profile) -> ao.Profile:
    return tuple(entry for entry in profile if entry != ao.SECOND_FLOOR_RANGE)


def replace_profiled_rectangles(
    blocks,
    rectangles: list[ao.RoomRectangle],
) -> list[int]:
    """Sustituye el perfil completo y descarta IDs heredados del anfitrion."""

    profile_tags: dict[ao.Profile, int] = {}
    prepared = []
    for rectangle in rectangles:
        *bounds, _, _ = rectangle
        x0, y0, x1, y1 = bounds
        host = ao.smallest_sector_at_point(
            blocks,
            (x0 + x1) * 0.5,
            (y0 + y1) * 0.5,
            [
                ao.optional_sector_bounds(blocks, index)
                for index in range(len(blocks["sector"]))
            ],
            {},
        )
        profile = remove_roof_range(ao.complete_sector_profile(blocks, host))
        if profile not in profile_tags:
            tag = EXACT_ROOF_PROFILE_TAG_START + 1 + len(profile_tags)
            if tag >= EXACT_ROOF_PROFILE_TAG_END:
                raise ValueError("Se agoto el rango de perfiles de recorte")
            profile_tags[profile] = tag
        prepared.append((tuple(bounds), host, profile_tags[profile]))

    targets = []
    for bounds, host, tag in prepared:
        target = ao.carve_from_host(blocks, bounds, host, tag)
        blocks["sector"][target].pop("moreids", None)
        targets.append(target)
    ao.add_profile_controls(blocks, profile_tags, 401)
    return targets


def point_in_open_rectangle(
    x: float,
    y: float,
    rectangle: tuple[float, float, float, float],
) -> bool:
    x0, y0, x1, y1 = rectangle
    return x0 < x < x1 and y0 < y < y1


def interior_sector_indices(blocks) -> set[int]:
    """Obtiene cada sector fisico visible dentro del cuerpo de la cubierta."""

    x0, y0, x1, y1 = ROOF_INTERIOR
    x_coordinates = {x0, x1}
    y_coordinates = {y0, y1}
    for vertex in blocks["vertex"]:
        x = float(vertex["x"])
        y = float(vertex["y"])
        if x0 <= x <= x1:
            x_coordinates.add(x)
        if y0 <= y <= y1:
            y_coordinates.add(y)

    ao._PHYSICAL_CACHE_BLOCKS = None
    result = set()
    for cell_y0, cell_y1 in zip(
        sorted(y_coordinates), sorted(y_coordinates)[1:]
    ):
        for cell_x0, cell_x1 in zip(
            sorted(x_coordinates), sorted(x_coordinates)[1:]
        ):
            x = (cell_x0 + cell_x1) * 0.5
            y = (cell_y0 + cell_y1) * 0.5
            if point_in_open_rectangle(x, y, ROOF_INTERIOR):
                result.add(ao.physical_sector_at(blocks, x, y))
    return result


def split_at_crossing_lines(
    blocks,
    rectangles: list[ao.RoomRectangle],
) -> list[ao.RoomRectangle]:
    """Evita que una linea larga cruce una celda tras dividir sus extremos."""

    result = []
    bounds_cache = [
        ao.optional_sector_bounds(blocks, index)
        for index in range(len(blocks["sector"]))
    ]
    edges_cache = {}
    for rectangle in rectangles:
        x0, y0, x1, y1, _, kind = rectangle
        x_coordinates = {x0, x1}
        y_coordinates = {y0, y1}
        for line in blocks["linedef"]:
            first, second = ao.line_positions(blocks, line)
            if first[0] == second[0]:
                x = first[0]
                overlap = min(y1, max(first[1], second[1])) - max(
                    y0, min(first[1], second[1])
                )
                if x0 < x < x1 and overlap > 0:
                    x_coordinates.add(x)
            elif first[1] == second[1]:
                y = first[1]
                overlap = min(x1, max(first[0], second[0])) - max(
                    x0, min(first[0], second[0])
                )
                if y0 < y < y1 and overlap > 0:
                    y_coordinates.add(y)

        for cell_y0, cell_y1 in zip(
            sorted(y_coordinates), sorted(y_coordinates)[1:]
        ):
            for cell_x0, cell_x1 in zip(
                sorted(x_coordinates), sorted(x_coordinates)[1:]
            ):
                center_x = (cell_x0 + cell_x1) * 0.5
                center_y = (cell_y0 + cell_y1) * 0.5
                host = ao.smallest_sector_at_point(
                    blocks,
                    center_x,
                    center_y,
                    bounds_cache,
                    edges_cache,
                )
                cell = (
                    cell_x0,
                    cell_y0,
                    cell_x1,
                    cell_y1,
                    host,
                    kind,
                )
                if ao.rectangle_has_internal_lines(blocks, cell[:4]):
                    raise ValueError(f"Celda de recorte con linea interior: {cell}")
                result.append(cell)
    return result


def add_exact_roof(blocks) -> list[int]:
    """Añade una losa continua y recorta todo lo que cruza su borde."""

    ao.add_control(
        blocks,
        EXACT_ROOF_PROFILE_TAG_START,
        ao.SECOND_FLOOR_RANGE,
        400,
    )
    for sector_index in interior_sector_indices(blocks):
        ao.add_sector_tag(
            blocks["sector"][sector_index],
            EXACT_ROOF_PROFILE_TAG_START,
        )

    rectangles = []
    for index, strip in enumerate(ROOF_CLEANUP_STRIPS):
        strip_rectangles = ao.rectangular_area_rectangles(
            blocks,
            strip,
            f"recorte_cubierta_{index}",
        )
        # Solo se talla el anfitrión que recibió el nuevo tag 580. Las piezas
        # que nunca cruzaron el límite ya estaban abiertas y deben conservar
        # su topología original.
        strip_rectangles = [
            rectangle
            for rectangle in strip_rectangles
            if EXACT_ROOF_PROFILE_TAG_START
            in ao.sector_tags(blocks["sector"][rectangle[4]])
        ]
        rectangles.extend(split_at_crossing_lines(blocks, strip_rectangles))
    if (
        EXPECTED_ROOF_CLEANUP_RECTANGLES is not None
        and len(rectangles) != EXPECTED_ROOF_CLEANUP_RECTANGLES
    ):
        raise ValueError(
            f"Recortes de cubierta: {len(rectangles)}, "
            f"esperados {EXPECTED_ROOF_CLEANUP_RECTANGLES}"
        )
    return replace_profiled_rectangles(blocks, rectangles)


def add_stair_run_walls(blocks) -> list[int]:
    """Completa ambos muros hasta el vano central sin cortar las escaleras."""

    if ao.optional_sector_bounds(blocks, FRONT_HOST_SECTOR) != FRONT_HOST_BOUNDS:
        raise ValueError("El sector frontal heredado cambio de contorno")
    if ao.complete_sector_profile(blocks, FRONT_HOST_SECTOR) != (
        (0, 128, ao.MANSION_WALL, ao.MANSION_WALL),
        ao.GROUND_FLOOR_RANGE,
    ):
        raise ValueError("El sector frontal heredado cambio de perfil")

    front_additions = (
        ao.STAIR_SIDE_WALL_RANGE,
        ao.SECOND_FLOOR_RANGE,
    )
    ao.add_profile_controls(
        blocks,
        {front_additions: STAIR_RUN_WALL_PROFILE_TAG_START},
        420,
    )
    ao.add_sector_tag(
        blocks["sector"][FRONT_HOST_SECTOR],
        STAIR_RUN_WALL_PROFILE_TAG_START,
    )

    rectangles = []
    for index, bounds in enumerate(STAIR_RUN_WALL_TAILS):
        rectangles.extend(
            ao.rectangular_area_rectangles(
                blocks,
                bounds,
                f"pared_lateral_escalera_{index}",
            )
        )
    if (
        EXPECTED_STAIR_RUN_WALL_RECTANGLES is not None
        and len(rectangles) != EXPECTED_STAIR_RUN_WALL_RECTANGLES
    ):
        raise ValueError(
            f"Subdivisiones laterales: {len(rectangles)}, "
            f"esperadas {EXPECTED_STAIR_RUN_WALL_RECTANGLES}"
        )

    desired_profiles = set()
    prepared = []
    bounds_cache = [
        ao.optional_sector_bounds(blocks, index)
        for index in range(len(blocks["sector"]))
    ]
    for rectangle in rectangles:
        x0, y0, x1, y1, _, _ = rectangle
        host = ao.smallest_sector_at_point(
            blocks,
            (x0 + x1) * 0.5,
            (y0 + y1) * 0.5,
            bounds_cache,
            {},
        )
        profile = ao.complete_sector_profile(blocks, host)
        for addition in front_additions:
            profile = ao.add_range(profile, addition)
        desired_profiles.add(profile)
        prepared.append((rectangle[:4], host, profile))
    if len(desired_profiles) != 1:
        raise ValueError(f"Perfiles laterales incompatibles: {desired_profiles}")

    tail_profile = next(iter(desired_profiles))
    tail_tag = STAIR_RUN_WALL_PROFILE_TAG_START + 1
    ao.add_profile_controls(blocks, {tail_profile: tail_tag}, 422)
    targets = []
    for bounds, host, _ in prepared:
        target = ao.carve_from_host(blocks, bounds, host, tail_tag)
        target_sector = blocks["sector"][target]
        target_sector.pop("moreids", None)
        targets.append(target)
    return targets


def audit_cells(blocks, bounds):
    """Recorre las celdas inducidas por toda la topologia dentro de un area."""

    x0, y0, x1, y1 = bounds
    xs = {x0, x1}
    ys = {y0, y1}
    for vertex in blocks["vertex"]:
        x = float(vertex["x"])
        y = float(vertex["y"])
        if x0 <= x <= x1:
            xs.add(x)
        if y0 <= y <= y1:
            ys.add(y)
    for cell_y0, cell_y1 in zip(sorted(ys), sorted(ys)[1:]):
        if cell_y1 <= y0 or cell_y0 >= y1:
            continue
        for cell_x0, cell_x1 in zip(sorted(xs), sorted(xs)[1:]):
            if cell_x1 <= x0 or cell_x0 >= x1:
                continue
            yield (
                (cell_x0 + cell_x1) * 0.5,
                (cell_y0 + cell_y1) * 0.5,
            )


def has_range(blocks, x: float, y: float, floor: int, ceiling: int) -> bool:
    return ao.profile_covers(ao.physical_profile_at(blocks, x, y), floor, ceiling)


def validate_roof_cells(blocks) -> None:
    """Exige cubierta exactamente en su huella y nunca fuera de ella."""

    for x, y in audit_cells(blocks, ROOF_AUDIT_BOUNDS):
        expected = any(
            point_in_open_rectangle(x, y, rectangle)
            for rectangle in (EXACT_ROOF, LANDING_ROOF, *TOP_STEPS)
        )
        actual = has_range(blocks, x, y, 256, 264)
        if actual != expected:
            state = "falta" if expected else "sobresale"
            raise ValueError(f"La cubierta {state} en ({x:g}, {y:g})")


def validate_wall_cells(blocks) -> None:
    """Exige las dos paredes completas, el vano libre y peldaños abiertos."""

    for wall_index, bounds in enumerate(STAIR_RUN_WALLS):
        for x, y in audit_cells(blocks, bounds):
            if not has_range(blocks, x, y, 136, 256):
                raise ValueError(
                    f"Falta pared lateral {wall_index} en ({x:g}, {y:g})"
                )
    for x, y in audit_cells(blocks, CENTRAL_GATE):
        if has_range(blocks, x, y, 136, 256):
            raise ValueError(f"La pared cerro el porton en ({x:g}, {y:g})")
    for x, y in ((1750.0, -304.0), (1750.0, 304.0)):
        if not has_range(blocks, x, y, 136, 152):
            raise ValueError(f"Falta el primer peldaño en ({x:g}, {y:g})")
        if has_range(blocks, x, y, 152, 256):
            raise ValueError(f"La pared invadio el peldaño en ({x:g}, {y:g})")


def validate_no_coincident_lines(blocks) -> None:
    by_edge = defaultdict(list)
    for index, line in enumerate(blocks["linedef"]):
        by_edge[tuple(sorted(ao.line_positions(blocks, line)))].append(index)
    duplicates = {edge: indices for edge, indices in by_edge.items() if len(indices) > 1}
    if duplicates:
        edge, indices = next(iter(duplicates.items()))
        raise ValueError(f"Lineas coincidentes en {edge}: {indices}")


def validate_preserved_architecture(blocks) -> None:
    """Comprueba puertas, techo inclinado, actores y superficies aceptadas."""

    groups = ao.door_group_counts(blocks)
    for group in (ao.SECOND_FLOOR_GATE_GROUP, ao.NEW_DIVIDER_GROUP, ao.UPPER_ROOM_DOOR_GROUP):
        if groups[group] != 2:
            raise ValueError(f"El grupo de puerta {group} no conserva dos hojas")
    if ao.digest_json(blocks["thing"]) != MAP01_THINGS_SHA256:
        raise ValueError("MAP01 altero actores o argumentos")
    if any(ao.integer(thing, "type") == 18026 for thing in blocks["thing"]):
        raise ValueError("Persisten paneles WALLSPRITE")

    for tag in (ao.ROOF_SOUTH_TAG, ao.ROOF_NORTH_TAG):
        if ao.control_profile(blocks, tag) != (ao.SECOND_FLOOR_ROOF_RANGE,):
            raise ValueError(f"El techo inclinado {tag} cambio de perfil")
    ridge_bottom, ridge_top = ao.roof_heights_at(blocks, 0.0, ao.ROOF_RIDGE_Y)
    if abs(ridge_bottom - ao.ROOF_RIDGE_BOTTOM) > 1e-6:
        raise ValueError("Cambio la altura inferior del caballete")
    if abs(ridge_top - ao.ROOF_RIDGE_TOP) > 1e-6:
        raise ValueError("Cambio la altura superior del caballete")

    ao.validate_map01_surface_set(blocks)
    ao.validate_upper_gate(blocks)
    ao.validate_references(blocks)
    ao.validate_connections(blocks)
    ao.validate_dividers(blocks)


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None and ao.map_counts(blocks) != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP01 4.29.0ap inesperada: {ao.map_counts(blocks)}")
    ao._PHYSICAL_CACHE_BLOCKS = None
    validate_roof_cells(blocks)
    validate_wall_cells(blocks)
    validate_no_coincident_lines(blocks)
    validate_preserved_architecture(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0ap inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    return (
        ao.control_profile(blocks, EXACT_ROOF_PROFILE_TAG_START)
        == (ao.SECOND_FLOOR_RANGE,)
        and ao.control_profile(blocks, STAIR_RUN_WALL_PROFILE_TAG_START)
        == tuple(sorted((ao.STAIR_SIDE_WALL_RANGE, ao.SECOND_FLOOR_RANGE)))
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = ao.read_wad(path)
    text_index = next(index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = ao.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if ao.map_counts(blocks) != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0ao: "
            f"{ao.map_counts(blocks)}, {digest}"
        )

    disable_legacy_roof_controls(blocks)
    add_exact_roof(blocks)
    add_stair_run_walls(blocks)
    ao._PHYSICAL_CACHE_BLOCKS = None

    lumps[text_index] = (b"TEXTMAP", ao.render_textmap(header, blocks).encode("utf-8"))
    ao.write_wad(path, signature, lumps)

    _, written_lumps = ao.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = ao.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    signature, lumps = ao.read_wad(path)
    if signature not in (b"PWAD", b"IWAD"):
        raise ValueError(f"Firma MAP02 invalida: {signature!r}")
    text = next(data for name, data in lumps if name == b"TEXTMAP")
    _, blocks = ao.parse_textmap(text.decode("utf-8"))
    ao.validate_map02(path, blocks)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: paredes laterales y cubierta exacta añadidas en 4.29.0ap"
        if changed
        else "MAP01: arquitectura 4.29.0ap ya presente"
    )
    print("MAP02: candidato 4.29.0ao preservado sin cambios")


if __name__ == "__main__":
    main()
