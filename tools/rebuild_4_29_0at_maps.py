"""Restaura la puerta y cierra las juntas inferiores en V4.29.0at.

MAP01 parte exclusivamente del candidato determinista 4.29.0as. Ese
incremento abrio correctamente los cuatro sectores que rodeaban la puerta
807, pero retiro tambien sus dos hojas. Este incremento devuelve las hojas
sin reinstalar ninguno de los muros interiores de planta baja.

La captura de revision expone ademas las dos juntas escalonadas de 8 MU entre
el edificio antiguo y la ampliacion. Sus componentes conservaban muro solo en
z=128..256, por lo que la planta baja quedaba abierta y el volumen superior
parecia flotar. Se aislan ambos componentes y se agrega exclusivamente el
volumen z=0..128. Los pisos primero y segundo mantienen exactamente sus
perfiles anteriores. Los dos suelos exteriores bajo esas juntas recuperan
CMGR01A; sus losas z=128..136 siguen usando madera. MAP02 permanece
byte-identico a 4.29.0as.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0as_maps as previous


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
    "13e931502f0385e5115c32189f603ad32fefe92d2f10d4ab1d3819ad732f1d90"
)
MAP01_THINGS_SHA256: str | None = previous.ar.MAP01_THINGS_SHA256

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

REAR_DOOR_GROUP = previous.REMOVED_REAR_DOOR_GROUP
REAR_DOOR_INSERT_INDEX = 198

GROUND_JOIN_TAG = previous.ar.ap.ao.FULL_HEIGHT_WALL_TAG
GROUND_JOIN_PROFILE: previous.ar.ap.ao.Profile = (
    (0, 256, previous.ar.ap.ao.MANSION_WALL, previous.ar.ap.ao.MANSION_WALL),
)
GROUND_JOIN_RECTS = (
    (1201.0, -544.0, 1209.0, -391.0),
    (1201.0, 391.0, 1209.0, 544.0),
)
GROUND_JOIN_HOST = 56

EXTERIOR_GROUND_RECTS = (
    (761.0, -640.0, 1305.0, -391.0),
    (761.0, 391.0, 1305.0, 640.0),
)
EXTERIOR_UPPER_SLAB_PROFILE: previous.ar.ap.ao.Profile = (
    previous.ar.ap.ao.GROUND_FLOOR_RANGE,
)

REAR_DOOR_THINGS = (
    OrderedDict(
        (
            ("x", "1413.0"),
            ("y", "-32.0"),
            ("height", "0.0"),
            ("angle", "0"),
            ("type", "18025"),
            ("arg0", "807"),
            ("arg1", "-1"),
            ("arg2", "1"),
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
    ),
    OrderedDict(
        (
            ("x", "1413.0"),
            ("y", "32.0"),
            ("height", "0.0"),
            ("angle", "0"),
            ("type", "18025"),
            ("arg0", "807"),
            ("arg1", "1"),
            ("arg2", "1"),
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
    ),
)


def sector_for_exact_bounds(blocks, bounds) -> int:
    matches = [
        index
        for index in range(len(blocks["sector"]))
        if previous.ar.ap.ao.optional_sector_bounds(blocks, index) == bounds
    ]
    if len(matches) != 1:
        raise ValueError(f"Sector para {bounds}: {matches}")
    return matches[0]


def rear_door_things(blocks) -> list[OrderedDict]:
    return sorted(
        (
            thing
            for thing in blocks["thing"]
            if previous.ar.ap.ao.integer(thing, "type") == 18025
            and previous.ar.ap.ao.integer(thing, "arg0") == REAR_DOOR_GROUP
        ),
        key=lambda thing: float(thing["y"]),
    )


def restore_rear_door(blocks) -> None:
    """Devuelve las hojas 807 sin recrear sus paños ni jambas inferiores."""

    doors = rear_door_things(blocks)
    if doors:
        raise ValueError(f"La base ya contiene hojas 807: {len(doors)}")
    if len(blocks["thing"]) != previous.MAP01_UPDATED_COUNTS[-1]:
        raise ValueError("Cantidad de actores inesperada antes de restaurar 807")
    blocks["thing"][REAR_DOOR_INSERT_INDEX:REAR_DOOR_INSERT_INDEX] = [
        OrderedDict(thing) for thing in REAR_DOOR_THINGS
    ]


def close_ground_floor_joins(blocks) -> None:
    """Cierra solo z=0..128 en las dos juntas exteriores escalonadas."""

    if (
        previous.ar.ap.ao.control_profile(blocks, GROUND_JOIN_TAG)
        != GROUND_JOIN_PROFILE
    ):
        raise ValueError(f"Perfil preexistente {GROUND_JOIN_TAG} inesperado")

    for bounds in GROUND_JOIN_RECTS:
        x0, y0, x1, y1 = bounds
        host = previous.ar.ap.ao.physical_sector_at(
            blocks,
            (x0 + x1) * 0.5,
            (y0 + y1) * 0.5,
        )
        if host != GROUND_JOIN_HOST:
            raise ValueError(f"Anfitrion inesperado en {bounds}: {host}")
        target = previous.ar.ap.ao.carve_from_host(
            blocks,
            bounds,
            host,
            GROUND_JOIN_TAG,
        )
        blocks["sector"][target].pop("moreids", None)
    previous.ar.ap.ao._PHYSICAL_CACHE_BLOCKS = None


def restore_exterior_grass(blocks) -> None:
    """Restaura el suelo base; no cambia la losa de madera z=128..136."""

    for bounds in EXTERIOR_GROUND_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if sector.get("texturefloor") != previous.ar.ap.ao.MANSION_FLOOR:
            raise ValueError(f"Piso exterior inesperado en {bounds}")
        if (
            previous.ar.ap.ao.complete_sector_profile(blocks, sector_index)
            != EXTERIOR_UPPER_SLAB_PROFILE
        ):
            raise ValueError(f"Losa superior inesperada en {bounds}")
        sector["texturefloor"] = previous.ar.ap.ao.MANSION_GRASS


def validate_rear_door(blocks) -> None:
    doors = rear_door_things(blocks)
    if doors != list(REAR_DOOR_THINGS):
        raise ValueError(f"Hojas 807 inesperadas: {doors}")

    for bounds in (*previous.RAISED_WALL_RECTS, *previous.RAISED_JAMB_RECTS):
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        profile = previous.ar.ap.ao.complete_sector_profile(blocks, sector_index)
        if previous.ar.ap.ao.integer(sector, "heightfloor") != 0:
            raise ValueError(f"El muro inferior 807 volvio a elevarse en {bounds}")
        if previous.ar.ap.ao.profile_covers(profile, 0, 128):
            raise ValueError(f"El muro inferior 807 volvio a cerrarse en {bounds}")
        if not previous.ar.ap.ao.profile_covers(profile, 128, 136):
            raise ValueError(f"Falta el piso preservado sobre 807 en {bounds}")
        if not previous.ar.ap.ao.profile_covers(profile, 256, 264):
            raise ValueError(f"Falta la cubierta preservada sobre 807 en {bounds}")


def validate_ground_floor_joins(blocks) -> None:
    if (
        previous.ar.ap.ao.control_profile(blocks, GROUND_JOIN_TAG)
        != GROUND_JOIN_PROFILE
    ):
        raise ValueError(f"Perfil de junta {GROUND_JOIN_TAG} inesperado")

    for bounds in GROUND_JOIN_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        tags = set(previous.ar.ap.ao.sector_tags(sector))
        if tags != {GROUND_JOIN_TAG}:
            raise ValueError(f"Tags de junta inesperados en {bounds}: {tags}")
        profile = previous.ar.ap.ao.complete_sector_profile(blocks, sector_index)
        if profile != GROUND_JOIN_PROFILE:
            raise ValueError(f"Perfil completo de junta inesperado en {bounds}")
        x0, y0, x1, y1 = bounds
        for x, y in previous.ar.ap.audit_cells(blocks, bounds):
            if not previous.ground_barrier_at(blocks, x, y):
                raise ValueError(f"Junta inferior abierta en ({x:g}, {y:g})")


def validate_exterior_grass(blocks) -> None:
    for bounds in EXTERIOR_GROUND_RECTS:
        sector_index = sector_for_exact_bounds(blocks, bounds)
        sector = blocks["sector"][sector_index]
        if sector.get("texturefloor") != previous.ar.ap.ao.MANSION_GRASS:
            raise ValueError(f"El suelo exterior no usa CMGR01A en {bounds}")
        if (
            previous.ar.ap.ao.complete_sector_profile(blocks, sector_index)
            != EXTERIOR_UPPER_SLAB_PROFILE
        ):
            raise ValueError(f"Cambio la losa superior de madera en {bounds}")


def validate_preserved_architecture(blocks) -> None:
    previous.ar.validate_open_ground_floor(blocks)
    previous.validate_undivided_rear_room(blocks)
    previous.validate_ground_perimeter(blocks)
    previous.ar.ap.validate_roof_cells(blocks)
    previous.ar.ap.validate_wall_cells(blocks)
    previous.ar.ap.validate_no_coincident_lines(blocks)
    previous.ar.validate_preserved_architecture(blocks)


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = previous.ar.ap.ao.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0at inesperada: {counts}")

    previous.ar.ap.ao._PHYSICAL_CACHE_BLOCKS = None
    previous.ar.validate_closed_sector_contours(blocks)
    validate_rear_door(blocks)
    validate_ground_floor_joins(blocks)
    validate_exterior_grass(blocks)
    validate_preserved_architecture(blocks)

    if previous.upper_geometry_digest(blocks) != previous.UPPER_GEOMETRY_SHA256:
        raise ValueError("Cambio la ocupacion de los pisos primero o segundo")
    if MAP01_THINGS_SHA256 is not None:
        things_digest = previous.ar.ap.ao.digest_json(blocks["thing"])
        if things_digest != MAP01_THINGS_SHA256:
            raise ValueError(f"Actores MAP01 inesperados: {things_digest}")

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0at inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    if rear_door_things(blocks) != list(REAR_DOOR_THINGS):
        return False
    if previous.ar.ap.ao.control_profile(blocks, GROUND_JOIN_TAG) != GROUND_JOIN_PROFILE:
        return False
    for bounds in GROUND_JOIN_RECTS:
        matches = [
            index
            for index in range(len(blocks["sector"]))
            if previous.ar.ap.ao.optional_sector_bounds(blocks, index) == bounds
        ]
        if len(matches) != 1:
            return False
        if (
            previous.ar.ap.ao.complete_sector_profile(blocks, matches[0])
            != GROUND_JOIN_PROFILE
        ):
            return False
    return all(
        blocks["sector"][sector_for_exact_bounds(blocks, bounds)].get(
            "texturefloor"
        )
        == previous.ar.ap.ao.MANSION_GRASS
        for bounds in EXTERIOR_GROUND_RECTS
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = previous.ar.ap.ao.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = previous.ar.ap.ao.parse_textmap(
        lumps[text_index][1].decode("utf-8")
    )

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    counts = previous.ar.ap.ao.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0as: "
            f"{counts}, {digest}"
        )

    before_upper = previous.upper_geometry_digest(blocks)
    restore_rear_door(blocks)
    close_ground_floor_joins(blocks)
    restore_exterior_grass(blocks)
    if previous.upper_geometry_digest(blocks) != before_upper:
        raise ValueError("La correccion modifico un piso superior")

    lumps[text_index] = (
        b"TEXTMAP",
        previous.ar.ap.ao.render_textmap(header, blocks).encode("utf-8"),
    )
    previous.ar.ap.ao.write_wad(path, signature, lumps)

    _, written_lumps = previous.ar.ap.ao.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = previous.ar.ap.ao.parse_textmap(
        written_text.decode("utf-8")
    )
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0as")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: puerta 807, juntas inferiores y pasto restaurados en 4.29.0at"
        if changed
        else "MAP01: arquitectura 4.29.0at ya presente"
    )
    print("MAP02: candidato 4.29.0as preservado sin cambios")


if __name__ == "__main__":
    main()
