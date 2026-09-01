"""Corrige la topologia oriental y abre la sala inferior en V4.29.0ar.

MAP01 parte exclusivamente del candidato validado 4.29.0ap. El sector 29
conservaba cuatro contornos abiertos heredados: dos bordes internos estaban
asignados al mundo y dos fragmentos sin area arrastraban la losa z=256..264
fuera de su huella. GZDoom podia triangular esos contornos como planos que se
extendian hasta el horizonte, con una franja de piso flotante y superficies de
textura ausente. Este incremento repara las adyacencias exactas y elimina solo
las cuatro lineas internas que no separaban sectores fisicos distintos.

La pared x=1201..1209 y su puerta doble 914 dejan de subdividir la gran sala de
planta baja. Se retira exclusivamente el volumen z=0..128; las paredes de la
planta superior y la losa z=256..264 se conservan. El perimetro exterior de la
ampliacion permanece cerrado. MAP02 queda byte-identico a 4.29.0ap.
"""

from __future__ import annotations

from collections import Counter, defaultdict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ap_maps as ap


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = ap.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = ap.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1045,
    1436,
    2586,
    435,
    225,
)
MAP01_UPDATED_SHA256: str | None = (
    "35e52122f54ce9490005e2de8e574afd02fc9dcf4a0f40fb0374e16f37bd79ce"
)

MAP02_UPDATED_COUNTS = ap.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = ap.MAP02_UPDATED_SHA256

WORLD_SECTOR = 0
LEAKING_HOST_SECTOR = 29
REMOVED_GROUND_DOOR_GROUP = ap.ao.NEW_DIVIDER_GROUP

# Perfiles exclusivos del antiguo divisor inferior. El primer perfil conserva
# el muro z=128..256; el segundo deja el paso abierto en ambos pisos inferiores.
OPENED_DIVIDER_UPPER_WALL_TAG = 620
OPENED_DIVIDER_OPEN_TAG = 621
OPENED_DIVIDER_UPPER_WALL_PROFILE: ap.ao.Profile = (
    (128, 256, ap.ao.MANSION_WALL, ap.ao.MANSION_WALL),
    ap.ao.SECOND_FLOOR_RANGE,
)
OPENED_DIVIDER_OPEN_PROFILE: ap.ao.Profile = (
    ap.ao.GROUND_FLOOR_RANGE,
    ap.ao.SECOND_FLOOR_RANGE,
)

# Las cuatro piezas de cada lista cubren exactamente x=1201..1209 sin tocar el
# vano central ya abierto. Se identifican por contorno, no por indice mutable.
DIVIDER_UPPER_WALL_RECTS = (
    (1201.0, -383.0, 1209.0, -192.0),
    (1201.0, 192.0, 1209.0, 383.0),
)
DIVIDER_OPEN_RECTS = (
    (1201.0, -192.0, 1209.0, -96.0),
    (1201.0, -96.0, 1209.0, -64.0),
    (1201.0, 64.0, 1209.0, 96.0),
    (1201.0, 96.0, 1209.0, 192.0),
)

# Estos dos bordes cerraban los contornos interiores. Su lado mundial era la
# causa del corte abierto que el node builder prolongaba fuera del edificio.
WORLD_TO_HOST_EDGES = (
    ((1425.0, -272.0), (1433.0, -272.0)),
    ((1425.0, 272.0), (1433.0, 272.0)),
)

# Las cuatro fronteras exteriores ya separaban un muro real del mundo, pero su
# lado externo seguia apuntando al sector anfitrion abierto.
HOST_TO_WORLD_EDGES = (
    ((1544.0, -391.0), (1689.0, -391.0)),
    ((1689.0, -391.0), (1697.0, -391.0)),
    ((1544.0, 391.0), (1689.0, 391.0)),
    ((1689.0, 391.0), (1697.0, 391.0)),
)

# No separan dos areas distintas: dos son cortes verticales dentro de los muros
# y dos atraviesan el mismo muro frontal. Al retirarlas desaparecen los cuatro
# componentes de area cero que proyectaban la losa 580 fuera de EXACT_ROOF.
REMOVED_PHANTOM_EDGES = (
    ((1544.0, -391.0), (1544.0, -383.0)),
    ((1544.0, 383.0), (1544.0, 391.0)),
    ((1689.0, -272.0), (1697.0, -272.0)),
    ((1689.0, 272.0), (1697.0, 272.0)),
)

GROUND_PERIMETER_RECTS = (
    (1201.0, -391.0, 1697.0, -383.0),
    (1201.0, 383.0, 1697.0, 391.0),
    (1689.0, -391.0, 1697.0, 391.0),
)

# Son las dos uniones de esquina del perimetro exterior, no parte del divisor
# interior. Conservan el perfil 0..256 para no abrir dos huecos de 8x8 MU.
PRESERVED_GROUND_CORNERS = (
    (1201.0, -391.0, 1209.0, -383.0),
    (1201.0, 383.0, 1209.0, 391.0),
)

DIVIDER_PORTAL_X = 1201.0
DIVIDER_PORTAL_Y_RANGE = (-383.0, 383.0)

MAP01_THINGS_SHA256: str | None = (
    "0ab8bec0d6b9fd591d17ef7aafc1417b8fdd1f927129ca46feadd6df89d4a46d"
)


def normalized_edge(first, second):
    return tuple(sorted((tuple(first), tuple(second))))


def line_indices_for_edge(blocks, first, second) -> list[int]:
    target = normalized_edge(first, second)
    return [
        index
        for index, line in enumerate(blocks["linedef"])
        if normalized_edge(*ap.ao.line_positions(blocks, line)) == target
    ]


def unique_line_for_edge(blocks, first, second) -> tuple[int, dict]:
    matches = line_indices_for_edge(blocks, first, second)
    if len(matches) != 1:
        raise ValueError(f"Borde {first} -> {second}: {matches}")
    index = matches[0]
    return index, blocks["linedef"][index]


def line_side_sectors(blocks, line) -> dict[str, int]:
    return {
        side_name: ap.ao.integer(
            blocks["sidedef"][ap.ao.integer(line, side_name)], "sector"
        )
        for side_name in ("sidefront", "sideback")
        if side_name in line
    }


def replace_unique_sector_side(
    blocks,
    line,
    old_sector: int,
    new_sector: int,
) -> None:
    matches = [
        side_name
        for side_name, sector in line_side_sectors(blocks, line).items()
        if sector == old_sector
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Lado sector {old_sector} ambiguo: {line_side_sectors(blocks, line)}"
        )
    side_index = ap.ao.integer(line, matches[0])
    blocks["sidedef"][side_index]["sector"] = str(new_sector)


def compact_sidedefs(blocks) -> None:
    """Elimina sidedefs huerfanos sin renumerar sectores fisicos."""

    used = sorted(
        {
            ap.ao.integer(line, side_name)
            for line in blocks["linedef"]
            for side_name in ("sidefront", "sideback")
            if side_name in line
        }
    )
    remap = {old: new for new, old in enumerate(used)}
    blocks["sidedef"] = [blocks["sidedef"][index] for index in used]
    for line in blocks["linedef"]:
        for side_name in ("sidefront", "sideback"):
            if side_name in line:
                line[side_name] = str(remap[ap.ao.integer(line, side_name)])


def repair_open_contours(blocks) -> None:
    """Repara las ocho adyacencias responsables de los planos infinitos."""

    for first, second in WORLD_TO_HOST_EDGES:
        _, line = unique_line_for_edge(blocks, first, second)
        if set(line_side_sectors(blocks, line).values()) != {
            WORLD_SECTOR,
            33 if first[1] < 0 else 34,
        }:
            raise ValueError(
                f"Contorno interior inesperado {first}->{second}: "
                f"{line_side_sectors(blocks, line)}"
            )
        replace_unique_sector_side(
            blocks,
            line,
            WORLD_SECTOR,
            LEAKING_HOST_SECTOR,
        )

    for first, second in HOST_TO_WORLD_EDGES:
        _, line = unique_line_for_edge(blocks, first, second)
        replace_unique_sector_side(
            blocks,
            line,
            LEAKING_HOST_SECTOR,
            WORLD_SECTOR,
        )

    removed = set()
    for first, second in REMOVED_PHANTOM_EDGES:
        index, line = unique_line_for_edge(blocks, first, second)
        sectors = set(line_side_sectors(blocks, line).values())
        if sectors != {WORLD_SECTOR, LEAKING_HOST_SECTOR}:
            raise ValueError(
                f"Linea fantasma inesperada {first}->{second}: {sectors}"
            )
        removed.add(index)
    blocks["linedef"] = [
        line
        for index, line in enumerate(blocks["linedef"])
        if index not in removed
    ]
    compact_sidedefs(blocks)


def sector_for_exact_bounds(blocks, bounds) -> int:
    matches = [
        index
        for index in range(len(blocks["sector"]))
        if ap.ao.optional_sector_bounds(blocks, index) == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def assign_single_tag(sector, tag: int) -> None:
    sector["id"] = str(tag)
    sector.pop("moreids", None)


def open_ground_floor_divider(blocks) -> None:
    """Abre PB, conserva muro superior y losa, y retira la puerta 914."""

    doors = [
        thing
        for thing in blocks["thing"]
        if ap.ao.integer(thing, "type") == 18025
        and ap.ao.integer(thing, "arg0") == REMOVED_GROUND_DOOR_GROUP
    ]
    if len(doors) != 2:
        raise ValueError(f"Hojas del divisor 914: {len(doors)}")
    blocks["thing"] = [thing for thing in blocks["thing"] if thing not in doors]

    for bounds in DIVIDER_UPPER_WALL_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        assign_single_tag(
            blocks["sector"][sector_index],
            OPENED_DIVIDER_UPPER_WALL_TAG,
        )
    for bounds in DIVIDER_OPEN_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        assign_single_tag(blocks["sector"][sector_index], OPENED_DIVIDER_OPEN_TAG)

    ap.ao.add_profile_controls(
        blocks,
        {
            OPENED_DIVIDER_UPPER_WALL_PROFILE: OPENED_DIVIDER_UPPER_WALL_TAG,
            OPENED_DIVIDER_OPEN_PROFILE: OPENED_DIVIDER_OPEN_TAG,
        },
        440,
    )

    # Las fronteras talladas usan CMIN01 como textura media por defecto. Sin
    # la puerta 914 esa textura quedaria como una cortina opaca aunque ya no
    # exista volumen solido, por lo que se limpia todo el portal continuo.
    covered = 0.0
    low, high = DIVIDER_PORTAL_Y_RANGE
    for line in blocks["linedef"]:
        first, second = ap.ao.line_positions(blocks, line)
        if first[0] != DIVIDER_PORTAL_X or second[0] != DIVIDER_PORTAL_X:
            continue
        segment_low = min(first[1], second[1])
        segment_high = max(first[1], second[1])
        if segment_low < low or segment_high > high or segment_low == segment_high:
            continue
        for side_name in ("sidefront", "sideback"):
            if side_name not in line:
                continue
            side = blocks["sidedef"][ap.ao.integer(line, side_name)]
            side["texturemiddle"] = '"-"'
        covered += segment_high - segment_low
    if covered != high - low:
        raise ValueError(
            f"Cobertura del portal inferior: {covered:g}, esperada {high-low:g}"
        )


def validate_closed_sector_contours(blocks) -> None:
    """Exige flujo dirigido balanceado para cada contorno de cada sector."""

    incoming: dict[int, Counter[int]] = defaultdict(Counter)
    outgoing: dict[int, Counter[int]] = defaultdict(Counter)
    for line in blocks["linedef"]:
        first = ap.ao.integer(line, "v1")
        second = ap.ao.integer(line, "v2")
        if "sidefront" in line:
            sector = ap.ao.integer(
                blocks["sidedef"][ap.ao.integer(line, "sidefront")],
                "sector",
            )
            outgoing[sector][first] += 1
            incoming[sector][second] += 1
        if "sideback" in line:
            sector = ap.ao.integer(
                blocks["sidedef"][ap.ao.integer(line, "sideback")],
                "sector",
            )
            outgoing[sector][second] += 1
            incoming[sector][first] += 1

    failures = []
    for sector in sorted(set(incoming) | set(outgoing)):
        for vertex in sorted(set(incoming[sector]) | set(outgoing[sector])):
            if incoming[sector][vertex] == outgoing[sector][vertex]:
                continue
            position = ap.ao.vertex_position(blocks, vertex)
            failures.append(
                (
                    sector,
                    position,
                    incoming[sector][vertex],
                    outgoing[sector][vertex],
                )
            )
    if failures:
        raise ValueError(f"Contornos de sector abiertos: {failures[:12]}")


def validate_open_ground_floor(blocks) -> None:
    if any(
        ap.ao.integer(thing, "type") == 18025
        and ap.ao.integer(thing, "arg0") == REMOVED_GROUND_DOOR_GROUP
        for thing in blocks["thing"]
    ):
        raise ValueError("Persisten hojas del divisor inferior 914")

    for bounds in (*DIVIDER_UPPER_WALL_RECTS, *DIVIDER_OPEN_RECTS):
        x0, y0, x1, y1 = bounds
        x = (x0 + x1) * 0.5
        y = (y0 + y1) * 0.5
        profile = ap.ao.physical_profile_at(blocks, x, y)
        if ap.ao.profile_covers(profile, 0, 128):
            raise ValueError(f"El divisor inferior sigue cerrado en ({x:g},{y:g})")
        if not ap.ao.profile_covers(profile, 256, 264):
            raise ValueError(f"Falta losa superior en ({x:g},{y:g})")

    for bounds in DIVIDER_UPPER_WALL_RECTS:
        x0, y0, x1, y1 = bounds
        profile = ap.ao.physical_profile_at(
            blocks,
            (x0 + x1) * 0.5,
            (y0 + y1) * 0.5,
        )
        if not ap.ao.profile_covers(profile, 128, 256):
            raise ValueError(f"Falta muro superior preservado en {bounds}")

    for bounds in DIVIDER_OPEN_RECTS:
        x0, y0, x1, y1 = bounds
        profile = ap.ao.physical_profile_at(
            blocks,
            (x0 + x1) * 0.5,
            (y0 + y1) * 0.5,
        )
        if not ap.ao.profile_covers(profile, 128, 136):
            raise ValueError(f"Falta piso del primer nivel en {bounds}")
        if ap.ao.profile_covers(profile, 136, 256):
            raise ValueError(f"El divisor superior sigue cerrado en {bounds}")

    covered = 0.0
    low, high = DIVIDER_PORTAL_Y_RANGE
    for line in blocks["linedef"]:
        first, second = ap.ao.line_positions(blocks, line)
        if first[0] != DIVIDER_PORTAL_X or second[0] != DIVIDER_PORTAL_X:
            continue
        segment_low = min(first[1], second[1])
        segment_high = max(first[1], second[1])
        if segment_low < low or segment_high > high or segment_low == segment_high:
            continue
        for side_name in ("sidefront", "sideback"):
            if side_name not in line:
                continue
            side = blocks["sidedef"][ap.ao.integer(line, side_name)]
            if side.get("texturemiddle") != '"-"':
                raise ValueError(
                    f"Persiste textura media en {first}->{second}, {side_name}"
                )
        covered += segment_high - segment_low
    if covered != high - low:
        raise ValueError("El portal inferior no cubre y=-383..383")


def validate_ground_perimeter(blocks) -> None:
    """Demuestra que el hueco visual no deja una abertura exterior real."""

    for bounds in GROUND_PERIMETER_RECTS:
        for x, y in ap.audit_cells(blocks, bounds):
            profile = ap.ao.physical_profile_at(blocks, x, y)
            if not ap.ao.profile_covers(profile, 0, 128):
                raise ValueError(f"Perimetro inferior abierto en ({x:g},{y:g})")


def validate_preserved_architecture(blocks) -> None:
    groups = ap.ao.door_group_counts(blocks)
    for group in (ap.ao.SECOND_FLOOR_GATE_GROUP, ap.ao.UPPER_ROOM_DOOR_GROUP):
        if groups[group] != 2:
            raise ValueError(f"El grupo de puerta {group} no conserva dos hojas")
    if groups[REMOVED_GROUND_DOOR_GROUP] != 0:
        raise ValueError("El grupo 914 no fue retirado")
    if any(ap.ao.integer(thing, "type") == 18026 for thing in blocks["thing"]):
        raise ValueError("Persisten paneles WALLSPRITE")

    for tag in (ap.ao.ROOF_SOUTH_TAG, ap.ao.ROOF_NORTH_TAG):
        if ap.ao.control_profile(blocks, tag) != (ap.ao.SECOND_FLOOR_ROOF_RANGE,):
            raise ValueError(f"El techo inclinado {tag} cambio de perfil")
    ridge_bottom, ridge_top = ap.ao.roof_heights_at(
        blocks,
        0.0,
        ap.ao.ROOF_RIDGE_Y,
    )
    if abs(ridge_bottom - ap.ao.ROOF_RIDGE_BOTTOM) > 1e-6:
        raise ValueError("Cambio la altura inferior del caballete")
    if abs(ridge_top - ap.ao.ROOF_RIDGE_TOP) > 1e-6:
        raise ValueError("Cambio la altura superior del caballete")

    ap.ao.validate_map01_surface_set(blocks)
    ap.ao.validate_upper_gate(blocks)
    ap.ao.validate_references(blocks)
    ap.ao.validate_connections(blocks)


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = ap.ao.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0ar inesperada: {counts}")

    ap.ao._PHYSICAL_CACHE_BLOCKS = None
    validate_closed_sector_contours(blocks)
    validate_open_ground_floor(blocks)
    validate_ground_perimeter(blocks)
    ap.validate_roof_cells(blocks)
    ap.validate_wall_cells(blocks)
    ap.validate_no_coincident_lines(blocks)
    validate_preserved_architecture(blocks)

    if MAP01_THINGS_SHA256 is not None:
        things_digest = ap.ao.digest_json(blocks["thing"])
        if things_digest != MAP01_THINGS_SHA256:
            raise ValueError(f"Actores MAP01 inesperados: {things_digest}")
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0ar inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    return (
        ap.ao.control_profile(blocks, OPENED_DIVIDER_UPPER_WALL_TAG)
        == tuple(sorted(OPENED_DIVIDER_UPPER_WALL_PROFILE))
        and ap.ao.control_profile(blocks, OPENED_DIVIDER_OPEN_TAG)
        == OPENED_DIVIDER_OPEN_PROFILE
        and not any(
            ap.ao.integer(thing, "type") == 18025
            and ap.ao.integer(thing, "arg0") == REMOVED_GROUND_DOOR_GROUP
            for thing in blocks["thing"]
        )
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = ap.ao.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = ap.ao.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    counts = ap.ao.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0ap: "
            f"{counts}, {digest}"
        )

    repair_open_contours(blocks)
    open_ground_floor_divider(blocks)
    ap.ao._PHYSICAL_CACHE_BLOCKS = None

    lumps[text_index] = (
        b"TEXTMAP",
        ap.ao.render_textmap(header, blocks).encode("utf-8"),
    )
    ap.ao.write_wad(path, signature, lumps)

    _, written_lumps = ap.ao.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = ap.ao.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0ap")
    ap.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: contornos reparados y sala inferior abierta en 4.29.0ar"
        if changed
        else "MAP01: arquitectura 4.29.0ar ya presente"
    )
    print("MAP02: candidato 4.29.0ap preservado sin cambios")


if __name__ == "__main__":
    main()
