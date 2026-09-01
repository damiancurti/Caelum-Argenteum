"""Retira las cortinas inferiores restantes y alinea la puerta en 4.29.0av.

MAP01 parte exclusivamente del candidato determinista 4.29.0au. La apertura
anterior retiro los perfiles solidos del anexo, pero la revision visual revelo
38 paredes heredadas hechas con texturas medias 3D: 36 rodeaban los dos vuelos
interiores y dos continuaban hacia el exterior. No eran sectores solidos y,
por tanto, no participaban en la auditoria de perfiles que habia pasado 0au.

Este incremento elimina exclusivamente esas cortinas CMIN01 ancladas en
z=0..128. Los peldaños, las caras inferiores necesarias y todos los perfiles
desde z=128 permanecen intactos. Las hojas 807 se trasladan de x=1413 a
x=1693, bajo la puerta 913 y sobre el eje del descanso oriental. MAP02 no
cambia.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0au_maps as previous


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
    "fb9c487be494c70ec309b68a180ab781f631185aa0f82aa817a0f0760f4a0ec0"
)
MAP01_THINGS_SHA256: str | None = (
    "2cec812d5b5b182f5949540e9da72e453fc5de08c815c60b3995f314039c2e2f"
)
MAP01_VERTEX_SHA256 = (
    "a8b43ccee04ff2902b706c4664ef7e854300c34a7f01f12dce270b9bc206d351"
)
MAP01_SECTOR_SHA256 = (
    "e30459ea923f0ae30698caa4d356746cff3373ae73d477dd4909aa591943a6b0"
)

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

AO = previous.previous.previous.ar.ap.ao
MANSION_WALL = previous.MANSION_WALL
EMPTY_TEXTURE = previous.EMPTY_TEXTURE

REAR_DOOR_GROUP = previous.previous.REAR_DOOR_GROUP
REAR_DOOR_OLD_X = 1413.0
REAR_DOOR_NEW_X = 1693.0


def normalized_segment(x0: float, y0: float, x1: float, y1: float):
    return tuple(sorted(((float(x0), float(y0)), (float(x1), float(y1)))))


# Las primeras 36 lineas forman cuatro L alrededor de los vuelos. Las ultimas
# dos son sus prolongaciones exteriores norte/sur, tambien visibles en la
# revision anterior. La lista explicita impide afectar otras texturas medias
# que pertenecen a la casa conservada.
GROUND_CURTAIN_SEGMENTS = tuple(
    normalized_segment(*segment)
    for segment in (
        (1209, 96, 1305, 96),
        (1201, 96, 1209, 96),
        (1209, -96, 1305, -96),
        (1201, -96, 1209, -96),
        (1305, -320, 1305, -96),
        (1305, 96, 1305, 320),
        (1306, -383, 1306, -328),
        (1305, -383, 1305, -328),
        (1305, -328, 1305, -320),
        (1306, -328, 1306, -320),
        (1306, -320, 1306, -295),
        (1306, -295, 1306, -287),
        (1306, -287, 1306, -272),
        (1544, -383, 1544, -343),
        (1544, -343, 1544, -336),
        (1544, -336, 1544, -328),
        (1544, -328, 1544, -320),
        (1544, -320, 1544, -295),
        (1544, -295, 1544, -287),
        (1544, -287, 1544, -272),
        (1544, -272, 1689, -272),
        (1305, 328, 1305, 383),
        (1305, 320, 1305, 328),
        (1306, 320, 1306, 328),
        (1306, 328, 1306, 383),
        (1306, 295, 1306, 320),
        (1306, 287, 1306, 295),
        (1306, 272, 1306, 287),
        (1544, 343, 1544, 383),
        (1544, 336, 1544, 343),
        (1544, 328, 1544, 336),
        (1544, 320, 1544, 328),
        (1544, 295, 1544, 320),
        (1544, 287, 1544, 295),
        (1544, 272, 1544, 287),
        (1544, 272, 1689, 272),
        (1305, 391, 1305, 640),
        (1305, -640, 1305, -391),
    )
)

EXPECTED_CURTAIN_COUNT = 38
EXPECTED_CLEARED_SIDE_COUNT = 76


def line_segment(blocks, line):
    first = blocks["vertex"][AO.integer(line, "v1")]
    second = blocks["vertex"][AO.integer(line, "v2")]
    return normalized_segment(
        float(first["x"]),
        float(first["y"]),
        float(second["x"]),
        float(second["y"]),
    )


def curtain_line_indices(blocks) -> tuple[int, ...]:
    by_segment: dict[tuple, list[int]] = {
        segment: [] for segment in GROUND_CURTAIN_SEGMENTS
    }
    for index, line in enumerate(blocks["linedef"]):
        segment = line_segment(blocks, line)
        if segment in by_segment:
            by_segment[segment].append(index)

    failures = {
        segment: matches
        for segment, matches in by_segment.items()
        if len(matches) != 1
    }
    if failures:
        raise ValueError(f"Cortinas no univocas: {failures}")
    return tuple(by_segment[segment][0] for segment in GROUND_CURTAIN_SEGMENTS)


def rear_door_things(blocks) -> list[OrderedDict]:
    return sorted(
        (
            thing
            for thing in blocks["thing"]
            if AO.integer(thing, "type") == 18025
            and AO.integer(thing, "arg0") == REAR_DOOR_GROUP
        ),
        key=lambda thing: float(thing["y"]),
    )


def expected_rear_door_things() -> list[OrderedDict]:
    expected = []
    for source in previous.previous.REAR_DOOR_THINGS:
        thing = OrderedDict(source)
        thing["x"] = f"{REAR_DOOR_NEW_X:.1f}"
        expected.append(thing)
    return expected


def remove_ground_curtains(blocks) -> None:
    """Elimina solo las 38 cortinas CMIN01 de planta baja auditadas."""

    cleared_sides = 0
    for line_index in curtain_line_indices(blocks):
        line = blocks["linedef"][line_index]
        if line.get("twosided") != "true":
            raise ValueError(f"Cortina {line_index} sin dos lados")
        if line.get("dontpegbottom") != "true":
            raise ValueError(f"Cortina {line_index} sin anclaje inferior")
        if line.get("midtex3d") != "true":
            raise ValueError(f"Cortina {line_index} no es midtex3d")

        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            sector = blocks["sector"][AO.integer(side, "sector")]
            if AO.integer(sector, "heightfloor") != 0:
                raise ValueError(f"Host elevado en cortina {line_index}")
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Material inesperado en cortina {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
            cleared_sides += 1
        line.pop("midtex3d")

    if len(GROUND_CURTAIN_SEGMENTS) != EXPECTED_CURTAIN_COUNT:
        raise ValueError("Cantidad declarada de cortinas inesperada")
    if cleared_sides != EXPECTED_CLEARED_SIDE_COUNT:
        raise ValueError(f"Lados retirados inesperados: {cleared_sides}")


def align_rear_door(blocks) -> None:
    """Alinea 807 con el descanso oriental y la puerta superior 913."""

    doors = rear_door_things(blocks)
    if doors != list(previous.previous.REAR_DOOR_THINGS):
        raise ValueError(f"Hojas 807 de base inesperadas: {doors}")
    for door in doors:
        if float(door["x"]) != REAR_DOOR_OLD_X:
            raise ValueError("La puerta 807 no parte de x=1413")
        door["x"] = f"{REAR_DOOR_NEW_X:.1f}"


def validate_ground_curtains_removed(blocks) -> None:
    cleared_sides = 0
    for line_index in curtain_line_indices(blocks):
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") == "true":
            raise ValueError(f"Persiste cortina 3D en linea {line_index}")
        if line.get("dontpegbottom") != "true":
            raise ValueError(f"Cambio el anclaje de linea {line_index}")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != EMPTY_TEXTURE:
                raise ValueError(f"Persiste paño visible en linea {line_index}")
            cleared_sides += 1
    if cleared_sides != EXPECTED_CLEARED_SIDE_COUNT:
        raise ValueError(f"Lados abiertos inesperados: {cleared_sides}")


def validate_rear_door(blocks) -> None:
    doors = rear_door_things(blocks)
    if doors != expected_rear_door_things():
        raise ValueError(f"Puerta 807 desalineada: {doors}")

    upper_doors = sorted(
        (
            thing
            for thing in blocks["thing"]
            if AO.integer(thing, "type") == 18025
            and AO.integer(thing, "arg0") == 913
        ),
        key=lambda thing: float(thing["y"]),
    )
    if len(upper_doors) != 2:
        raise ValueError("La puerta superior 913 no conserva dos hojas")
    for lower, upper in zip(doors, upper_doors):
        if (lower["x"], lower["y"]) != (upper["x"], upper["y"]):
            raise ValueError("807 no comparte el eje horizontal con 913")
        if float(lower["height"]) != 0 or float(upper["height"]) != 136:
            raise ValueError("Alturas inesperadas en puertas 807/913")


def validate_preserved_architecture(blocks) -> None:
    previous.validate_open_perimeter(blocks)
    previous.validate_expected_profiles(blocks)
    previous.previous.previous.ar.validate_open_ground_floor(blocks)
    previous.previous.previous.validate_undivided_rear_room(blocks)
    previous.previous.previous.ar.ap.validate_roof_cells(blocks)
    previous.previous.previous.ar.ap.validate_wall_cells(blocks)
    previous.previous.previous.ar.ap.validate_no_coincident_lines(blocks)
    previous.previous.previous.ar.validate_preserved_architecture(blocks)
    previous.previous.validate_exterior_grass(blocks)

    stair_digest = AO.digest_json(
        [blocks["sector"][index] for index in range(1, 13)]
    )
    if stair_digest != previous.STAIR_SECTOR_DIGEST:
        raise ValueError("Cambio la geometria de las escaleras interiores")
    if AO.digest_json(blocks["vertex"]) != MAP01_VERTEX_SHA256:
        raise ValueError("Cambio un vertice de MAP01")
    if AO.digest_json(blocks["sector"]) != MAP01_SECTOR_SHA256:
        raise ValueError("Cambio un sector o perfil de MAP01")
    if (
        previous.previous.previous.upper_geometry_digest(blocks)
        != previous.previous.previous.UPPER_GEOMETRY_SHA256
    ):
        raise ValueError("Cambio la ocupacion del primer o segundo piso")
    if MAP01_THINGS_SHA256 is not None:
        things_digest = AO.digest_json(blocks["thing"])
        if things_digest != MAP01_THINGS_SHA256:
            raise ValueError(f"Actores MAP01 inesperados: {things_digest}")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = AO.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0av inesperada: {counts}")

    AO._PHYSICAL_CACHE_BLOCKS = None
    previous.previous.previous.ar.validate_closed_sector_contours(blocks)
    validate_ground_curtains_removed(blocks)
    validate_rear_door(blocks)
    validate_preserved_architecture(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0av inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_ground_curtains_removed(blocks)
        validate_rear_door(blocks)
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
            "MAP01 no coincide con la base aceptada 4.29.0au: "
            f"{counts}, {digest}"
        )

    before_vertices = AO.digest_json(blocks["vertex"])
    before_sectors = AO.digest_json(blocks["sector"])
    before_upper = previous.previous.previous.upper_geometry_digest(blocks)
    remove_ground_curtains(blocks)
    align_rear_door(blocks)
    if AO.digest_json(blocks["vertex"]) != before_vertices:
        raise ValueError("La correccion cambio vertices")
    if AO.digest_json(blocks["sector"]) != before_sectors:
        raise ValueError("La correccion cambio sectores")
    if previous.previous.previous.upper_geometry_digest(blocks) != before_upper:
        raise ValueError("La correccion cambio un piso superior")

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
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0au")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: 38 cortinas inferiores retiradas y puerta 807 alineada"
        if changed
        else "MAP01: arquitectura 4.29.0av ya presente"
    )
    print("MAP02: candidato 4.29.0au preservado sin cambios")


if __name__ == "__main__":
    main()
