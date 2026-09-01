"""Abre por completo la sala posterior de planta baja en V4.29.0as.

MAP01 parte exclusivamente del candidato determinista 4.29.0ar. La pared que
seguia visible en la captura no pertenecia al divisor 914 ya retirado: era el
cerramiento historico de la puerta 807. Sus dos paños usaban pisos base a
z=136 y sus jambas pisos base a z=128, por lo que continuaban cerrando la
planta baja aunque los perfiles 3D del incremento anterior estuvieran abiertos.

Este incremento baja exclusivamente esos cuatro pisos anfitriones a z=0,
retira las dos hojas 807 y conserva el piso z=128..136 mediante los perfiles
3D ya existentes. Los pisos primero y segundo no cambian. La sala posterior
queda sin subdivisiones, mientras el contorno norte, este y sur conserva una
pared continua z=0..128. MAP02 permanece byte-identico a 4.29.0ar.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ar_maps as ar


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = ar.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = ar.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1045,
    1436,
    2586,
    435,
    223,
)
MAP01_UPDATED_SHA256: str | None = (
    "8a4e55a4808002ccb0aa5ae3c4c66b94750a68b38874aef939148cfaaae1f1da"
)
MAP01_THINGS_SHA256: str | None = (
    "148e30c5e523354a65a44d533f67e7aea44068e6bb3249a54333ce5372888a3f"
)

MAP02_UPDATED_COUNTS = ar.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = ar.MAP02_UPDATED_SHA256

REMOVED_REAR_DOOR_GROUP = 807
OPEN_FLOOR_TAG = ar.OPENED_DIVIDER_OPEN_TAG

# Los dos paños altos forman la pared a ambos lados de la puerta 807. Al bajar
# su piso base hay que añadir la losa 128..136 que antes era la propia cima del
# sector. El techo 256..264 ya llega por el tag 580 y no se modifica.
RAISED_WALL_RECTS = (
    (1425.0, -272.0, 1433.0, -80.0),
    (1425.0, 80.0, 1433.0, 272.0),
)

# Las jambas ya reciben la losa 128..136 por el tag 546. Solo se baja su piso
# base para abrir el volumen 0..128.
RAISED_JAMB_RECTS = (
    (1401.0, -80.0, 1425.0, -64.0),
    (1401.0, 64.0, 1425.0, 80.0),
)

REAR_ROOM_INTERIOR = (1209.0, -383.0, 1689.0, 383.0)
REAR_ROOM_STAIRS = (
    (1306.0, -272.0, 1425.0, -80.0),
    (1306.0, 80.0, 1425.0, 272.0),
)
WESTERN_OPEN_JOIN = (1201.0, -383.0, 1209.0, 383.0)
GROUND_PERIMETER_RECTS = ar.GROUND_PERIMETER_RECTS

# Bandas cuya ocupacion debe ser identica a 4.29.0ar. La primera compara la
# cima del antiguo piso base con la losa 3D que lo sustituye.
UPPER_AUDIT_BANDS = (
    (128, 136),
    (136, 256),
    (256, 264),
    (264, 392),
    (392, 464),
)
UPPER_GEOMETRY_SHA256: str | None = (
    "cde1b9a7074268a0643bc6375cb65b8babff3c617847c67c5db66f58bd0420b0"
)


def point_in_open_rectangle(x: float, y: float, bounds) -> bool:
    x0, y0, x1, y1 = bounds
    return x0 < x < x1 and y0 < y < y1


def sector_for_exact_bounds(blocks, bounds) -> int:
    matches = [
        index
        for index in range(len(blocks["sector"]))
        if ar.ap.ao.optional_sector_bounds(blocks, index) == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def is_band_solid(blocks, x: float, y: float, floor: int, ceiling: int) -> bool:
    sector_index = ar.ap.ao.physical_sector_at(blocks, x, y)
    sector = blocks["sector"][sector_index]
    base_floor = ar.ap.ao.integer(sector, "heightfloor")
    if base_floor is not None and base_floor >= ceiling:
        return True
    return ar.ap.ao.profile_covers(
        ar.ap.ao.complete_sector_profile(blocks, sector_index),
        floor,
        ceiling,
    )


def upper_geometry_digest(blocks) -> str:
    """Resume la ocupacion de los pisos superiores sin depender del host."""

    samples = []
    for x, y in ar.ap.audit_cells(
        blocks,
        (1201.0, -391.0, 1697.0, 391.0),
    ):
        samples.append(
            (
                x,
                y,
                tuple(
                    is_band_solid(blocks, x, y, floor, ceiling)
                    for floor, ceiling in UPPER_AUDIT_BANDS
                ),
            )
        )
    return ar.ap.ao.digest_json(samples)


def remove_rear_ground_floor_wall(blocks) -> None:
    """Retira la puerta 807 y sustituye sus pisos elevados por una losa."""

    doors = [
        thing
        for thing in blocks["thing"]
        if ar.ap.ao.integer(thing, "type") == 18025
        and ar.ap.ao.integer(thing, "arg0") == REMOVED_REAR_DOOR_GROUP
    ]
    if len(doors) != 2:
        raise ValueError(f"Hojas de la puerta {REMOVED_REAR_DOOR_GROUP}: {len(doors)}")
    blocks["thing"] = [thing for thing in blocks["thing"] if thing not in doors]

    for bounds in RAISED_WALL_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if ar.ap.ao.integer(sector, "heightfloor") != 136:
            raise ValueError(f"Piso de paño inesperado en {bounds}")
        sector["heightfloor"] = "0"
        ar.ap.ao.add_sector_tag(sector, OPEN_FLOOR_TAG)

    for bounds in RAISED_JAMB_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if ar.ap.ao.integer(sector, "heightfloor") != 128:
            raise ValueError(f"Piso de jamba inesperado en {bounds}")
        if not ar.ap.ao.profile_covers(
            ar.ap.ao.complete_sector_profile(blocks, sector_index),
            128,
            136,
        ):
            raise ValueError(f"La jamba {bounds} no conserva su losa superior")
        sector["heightfloor"] = "0"

    ar.ap.ao._PHYSICAL_CACHE_BLOCKS = None


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    sector_index = ar.ap.ao.physical_sector_at(blocks, x, y)
    sector = blocks["sector"][sector_index]
    base_floor = ar.ap.ao.integer(sector, "heightfloor")
    if base_floor is not None and base_floor >= 128:
        return True
    return ar.ap.ao.profile_covers(
        ar.ap.ao.complete_sector_profile(blocks, sector_index),
        0,
        128,
    )


def validate_removed_rear_wall(blocks) -> None:
    if any(
        ar.ap.ao.integer(thing, "type") == 18025
        and ar.ap.ao.integer(thing, "arg0") == REMOVED_REAR_DOOR_GROUP
        for thing in blocks["thing"]
    ):
        raise ValueError(f"Persisten hojas de la puerta {REMOVED_REAR_DOOR_GROUP}")

    for bounds in (*RAISED_WALL_RECTS, *RAISED_JAMB_RECTS):
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if ar.ap.ao.integer(sector, "heightfloor") != 0:
            raise ValueError(f"El cerramiento inferior sigue elevado en {bounds}")
        profile = ar.ap.ao.complete_sector_profile(blocks, sector_index)
        if ar.ap.ao.profile_covers(profile, 0, 128):
            raise ValueError(f"El cerramiento inferior sigue solido en {bounds}")
        if not ar.ap.ao.profile_covers(profile, 128, 136):
            raise ValueError(f"Falta el piso preservado en {bounds}")
        if not ar.ap.ao.profile_covers(profile, 256, 264):
            raise ValueError(f"Falta el segundo piso preservado en {bounds}")


def validate_undivided_rear_room(blocks) -> None:
    """Prohibe barreras de planta baja fuera de las escaleras existentes."""

    for x, y in ar.ap.audit_cells(blocks, REAR_ROOM_INTERIOR):
        if any(point_in_open_rectangle(x, y, stair) for stair in REAR_ROOM_STAIRS):
            continue
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"Subdivision inferior inesperada en ({x:g}, {y:g})")

    for x, y in ar.ap.audit_cells(blocks, WESTERN_OPEN_JOIN):
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"La union occidental sigue cerrada en ({x:g}, {y:g})")


def validate_ground_perimeter(blocks) -> None:
    for bounds in GROUND_PERIMETER_RECTS:
        for x, y in ar.ap.audit_cells(blocks, bounds):
            if not ground_barrier_at(blocks, x, y):
                raise ValueError(f"Perimetro inferior abierto en ({x:g}, {y:g})")


def validate_preserved_architecture(blocks) -> None:
    groups = ar.ap.ao.door_group_counts(blocks)
    for group in (ar.ap.ao.SECOND_FLOOR_GATE_GROUP, ar.ap.ao.UPPER_ROOM_DOOR_GROUP):
        if groups[group] != 2:
            raise ValueError(f"El grupo de puerta {group} no conserva dos hojas")
    for group in (ar.REMOVED_GROUND_DOOR_GROUP, REMOVED_REAR_DOOR_GROUP):
        if groups[group] != 0:
            raise ValueError(f"El grupo retirado {group} conserva hojas")
    if any(ar.ap.ao.integer(thing, "type") == 18026 for thing in blocks["thing"]):
        raise ValueError("Persisten paneles WALLSPRITE")

    for tag in (ar.ap.ao.ROOF_SOUTH_TAG, ar.ap.ao.ROOF_NORTH_TAG):
        if ar.ap.ao.control_profile(blocks, tag) != (ar.ap.ao.SECOND_FLOOR_ROOF_RANGE,):
            raise ValueError(f"El techo inclinado {tag} cambio de perfil")

    ar.ap.ao.validate_map01_surface_set(blocks)
    ar.ap.ao.validate_upper_gate(blocks)
    ar.ap.ao.validate_references(blocks)
    ar.ap.ao.validate_connections(blocks)


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = ar.ap.ao.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0as inesperada: {counts}")

    ar.ap.ao._PHYSICAL_CACHE_BLOCKS = None
    ar.validate_closed_sector_contours(blocks)
    validate_removed_rear_wall(blocks)
    validate_undivided_rear_room(blocks)
    validate_ground_perimeter(blocks)
    ar.ap.validate_roof_cells(blocks)
    ar.ap.validate_wall_cells(blocks)
    ar.ap.validate_no_coincident_lines(blocks)
    validate_preserved_architecture(blocks)

    if UPPER_GEOMETRY_SHA256 is not None:
        digest = upper_geometry_digest(blocks)
        if digest != UPPER_GEOMETRY_SHA256:
            raise ValueError(f"Cambio la ocupacion de los pisos superiores: {digest}")
    if MAP01_THINGS_SHA256 is not None:
        things_digest = ar.ap.ao.digest_json(blocks["thing"])
        if things_digest != MAP01_THINGS_SHA256:
            raise ValueError(f"Actores MAP01 inesperados: {things_digest}")

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0as inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    return (
        not any(
            ar.ap.ao.integer(thing, "type") == 18025
            and ar.ap.ao.integer(thing, "arg0") == REMOVED_REAR_DOOR_GROUP
            for thing in blocks["thing"]
        )
        and all(
            ar.ap.ao.integer(
                blocks["sector"][sector_for_exact_bounds(blocks, bounds)],
                "heightfloor",
            )
            == 0
            for bounds in (*RAISED_WALL_RECTS, *RAISED_JAMB_RECTS)
        )
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = ar.ap.ao.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = ar.ap.ao.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    counts = ar.ap.ao.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0ar: "
            f"{counts}, {digest}"
        )

    before_upper = upper_geometry_digest(blocks)
    remove_rear_ground_floor_wall(blocks)
    if upper_geometry_digest(blocks) != before_upper:
        raise ValueError("La conversion del muro modifico un piso superior")

    lumps[text_index] = (
        b"TEXTMAP",
        ar.ap.ao.render_textmap(header, blocks).encode("utf-8"),
    )
    ar.ap.ao.write_wad(path, signature, lumps)

    _, written_lumps = ar.ap.ao.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = ar.ap.ao.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0ar")
    ar.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: sala posterior inferior abierta y perimetro cerrado en 4.29.0as"
        if changed
        else "MAP01: arquitectura 4.29.0as ya presente"
    )
    print("MAP02: candidato 4.29.0ar preservado sin cambios")


if __name__ == "__main__":
    main()
