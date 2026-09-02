"""Retira ocho cortinas finas y corrige dos pisos interiores para 4.29.0bd.

MAP01 parte exclusivamente del candidato aceptado 4.29.0bc. La operacion no
crea ni elimina geometria: limpia los ocho midtextures CMIN01 indicados por
coordenadas y cambia a CMWD01 el piso fisico de los sectores 19 y 22. MAP02,
los actores, el inventario y la ocupacion de los pisos superiores no cambian.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ap_maps as ap
import rebuild_4_29_0ar_maps as ar
import rebuild_4_29_0bc_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

AO = previous.AO
MANSION_WALL = previous.MANSION_WALL
EMPTY_TEXTURE = previous.EMPTY_TEXTURE
WOOD_FLOOR = '"CMWD01"'
GRASS_FLOOR = '"CMGR01A"'

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1299,
    1815,
    3252,
    578,
    231,
)
MAP01_UPDATED_SHA256: str | None = (
    "4073142f4d79d9c97676579d682d9e5c65b2ab630547690bafc090c592f1a067"
)
MAP01_VERTEX_SHA256: str | None = previous.MAP01_VERTEX_SHA256
MAP01_LINEDEF_SHA256: str | None = (
    "b86919de388e46c6f2696c73e568c93b45d1f14df3d8812672045e433a97a7db"
)
MAP01_SIDEDEF_SHA256: str | None = (
    "d685c9529f759a7669d1a66fc46aff41480505b795d838f0b9ab96e4fc7b3ab8"
)
MAP01_SECTOR_SHA256: str | None = (
    "99c55e518ae1ab1afb55b529d97cff4d27ca54a5807a5642a140b68c341ca735"
)
MAP01_THINGS_SHA256: str | None = previous.MAP01_THINGS_SHA256

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256


def normalized_segment(x0: float, y0: float, x1: float, y1: float):
    return previous.normalized_segment(x0, y0, x1, y1)


# Coordenadas exactas de las ocho cortinas que el jugador marco en ambos
# extremos de las alas. Las posiciones informadas caen en cada uno de estos
# segmentos historicos de 96 MU.
CURTAIN_SEGMENTS = tuple(
    normalized_segment(x, y0, x, y1)
    for x, y0, y1 in (
        (-25.0, 544.0, 640.0),
        (96.0, 544.0, 640.0),
        (640.0, 544.0, 640.0),
        (761.0, 544.0, 640.0),
        (-25.0, -640.0, -544.0),
        (96.0, -640.0, -544.0),
        (640.0, -640.0, -544.0),
        (761.0, -640.0, -544.0),
    )
)

# Punto de control, indice historico y limites del sector fisico. Esto impide
# cambiar por accidente otro pasto si la topologia de la base no coincide.
FLOOR_TARGETS = (
    (1249.0, -597.0, 22, (761.0, -640.0, 1305.0, -391.0)),
    (1262.0, 623.0, 19, (761.0, 391.0, 1305.0, 640.0)),
)


def lines_for_segments(blocks) -> list[int]:
    return previous.lines_for_segments(blocks, CURTAIN_SEGMENTS)


def clear_outer_curtains(blocks) -> None:
    """Elimina solo las ocho superficies finas CMIN01 solicitadas."""

    line_indices = lines_for_segments(blocks)
    if len(line_indices) != len(CURTAIN_SEGMENTS):
        raise ValueError(f"Cantidad de cortinas inesperada: {len(line_indices)}")

    for line_index in line_indices:
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") != "true":
            raise ValueError(f"La linea {line_index} no era una cortina 3D")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Textura inesperada en cortina {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
        line.pop("midtex3d")


def set_interior_floors(blocks) -> None:
    """Cambia a madera unicamente los sectores fisicos 19 y 22."""

    AO._PHYSICAL_CACHE_BLOCKS = None
    for x, y, expected_index, expected_bounds in FLOOR_TARGETS:
        sector_index = AO.physical_sector_at(blocks, x, y)
        if sector_index != expected_index:
            raise ValueError(
                f"Sector fisico inesperado en ({x:g}, {y:g}): {sector_index}"
            )
        bounds = AO.optional_sector_bounds(blocks, sector_index)
        if bounds != expected_bounds:
            raise ValueError(
                f"Limites inesperados para sector {sector_index}: {bounds}"
            )
        sector = blocks["sector"][sector_index]
        if sector.get("texturefloor") != GRASS_FLOOR:
            raise ValueError(
                f"Piso base inesperado en sector {sector_index}: "
                f"{sector.get('texturefloor')}"
            )
        sector["texturefloor"] = WOOD_FLOOR


def validate_curtains(blocks) -> None:
    for line_index in lines_for_segments(blocks):
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") == "true":
            raise ValueError(f"Persiste una cortina fina en linea {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError(f"Persiste textura fina en linea {line_index}")


def validate_floors(blocks) -> None:
    AO._PHYSICAL_CACHE_BLOCKS = None
    for x, y, expected_index, expected_bounds in FLOOR_TARGETS:
        sector_index = AO.physical_sector_at(blocks, x, y)
        if sector_index != expected_index:
            raise ValueError(
                f"Sector fisico inesperado en ({x:g}, {y:g}): {sector_index}"
            )
        if AO.optional_sector_bounds(blocks, sector_index) != expected_bounds:
            raise ValueError(f"Cambio topologico en sector {sector_index}")
        if blocks["sector"][sector_index].get("texturefloor") != WOOD_FLOOR:
            raise ValueError(f"El sector {sector_index} no conserva piso de madera")


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
    counts = AO.map_counts(blocks)
    if MAP01_UPDATED_COUNTS is not None and counts != MAP01_UPDATED_COUNTS:
        raise ValueError(f"Estructura MAP01 4.29.0bd inesperada: {counts}")
    validate_curtains(blocks)
    validate_floors(blocks)
    previous.validate_walls(blocks)
    previous.validate_doors(blocks)
    previous.validate_references(blocks)
    ar.validate_closed_sector_contours(blocks)
    ap.validate_no_coincident_lines(blocks)
    validate_component_digests(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0bd inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_curtains(blocks)
        validate_floors(blocks)
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
            "MAP01 no coincide con la base aceptada 4.29.0bc: "
            f"{counts}, {digest}"
        )

    before_upper = previous.upper_sample_signature(blocks)
    clear_outer_curtains(blocks)
    set_interior_floors(blocks)
    AO._PHYSICAL_CACHE_BLOCKS = None
    if previous.upper_sample_signature(blocks) != before_upper:
        raise ValueError("La correccion cambio la ocupacion de un piso superior")

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
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0bc")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: ocho cortinas retiradas y sectores 19/22 con piso interior"
        if changed
        else "MAP01: correccion 4.29.0bd ya presente"
    )
    print("MAP02: candidato aceptado preservado sin cambios")


if __name__ == "__main__":
    main()
