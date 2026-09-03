"""Agrega las rejas v2 a los bordes de los balcones de MAP01 4.30.0e.

La geometria transitable permanece intacta. Las lineas de borde existentes
reciben una midtexture 3D de 48 MU compuesta a partir de CMRL02. Las
aberturas de puertas, puentes y escaleras se conservan deliberadamente.
"""

from __future__ import annotations

from collections import Counter
from hashlib import sha256
from pathlib import Path
import re

import rebuild_4_30_0c_maps as base


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

MAP01_BASE_COUNTS = (1419, 1983, 3544, 618, 322)
MAP01_BASE_SHA256 = (
    "b333acc001de94d9d1342f62c92596e7e521ff007da620432e0bbdabbfabddfe"
)
MAP01_PROVISIONAL_SHA256 = (
    "a706b8bf7d3fdd2a64bf15e5d02f1b5b48e9e3f7db985bb1310cf5314f5294c5"
)
MAP01_UPDATED_COUNTS = MAP01_BASE_COUNTS
MAP01_UPDATED_SHA256 = (
    "45b7178613ce3d741660caf75af6572a2405106806021382c6b4c99bb3240867"
)

RAILING_TEXTURE = '"CMRLBAL"'
RAILING_TEXTURE_HEIGHT = 48
RAILING_VISIBLE_HEIGHT = 48

# axis, coordinate, inclusive intervals on the other axis, walkable height.
# Los tramos describen unicamente el contorno exterior. Los huecos son
# accesos reales y no se completan por aproximacion.
RAILING_PATHS = (
    # Balcon del primer piso (superficie caminable z=136).
    ("y", -640.0, ((-569.0, 1305.0),), 136),
    ("y", 640.0, ((-569.0, 1305.0),), 136),
    ("x", -569.0, ((-640.0, -96.0), (96.0, 640.0)), 136),
    ("x", -593.0, ((-64.0, 64.0),), 136),
    ("x", 1314.0, ((-640.0, -391.0), (391.0, 640.0)), 136),
    ("y", -391.0, ((1314.0, 1969.0),), 136),
    ("y", 391.0, ((1314.0, 1969.0),), 136),
    ("x", 1969.0, ((-391.0, 391.0),), 136),

    # Balcon del segundo piso (superficie caminable z=264).
    ("y", -544.0, ((-473.0, 1209.0),), 264),
    ("y", 544.0, ((-473.0, 1209.0),), 264),
    ("x", -473.0, ((-544.0, -96.0), (96.0, 544.0)), 264),
    ("y", -96.0, ((-569.0, -473.0),), 264),
    ("y", 96.0, ((-569.0, -473.0),), 264),
    ("x", -569.0, ((-96.0, 96.0),), 264),
    ("x", 1209.0, ((-544.0, -328.0), (328.0, 544.0)), 264),
    ("y", -328.0, ((1209.0, 1697.0),), 264),
    ("y", 328.0, ((1209.0, 1697.0),), 264),
    ("x", 1697.0, ((-328.0, -128.0), (128.0, 328.0)), 264),
    ("x", 1816.0, ((-96.0, -64.0), (64.0, 96.0)), 264),
    ("y", -64.0, ((1816.0, 1825.0),), 264),
    ("x", 1825.0, ((-64.0, 64.0),), 264),
    ("y", 64.0, ((1816.0, 1825.0),), 264),
)

EXPECTED_RAILING_LINES = {136: 42, 264: 116}
EXPECTED_RAILING_LENGTH = {136: 7546.0, 264: 6662.0}


def number(block: base.MapBlock, key: str) -> float:
    return float(block.properties[key])


def vertices(by_kind: dict[str, list[base.MapBlock]]) -> list[tuple[float, float]]:
    return [
        (number(vertex, "x"), number(vertex, "y"))
        for vertex in by_kind["vertex"]
    ]


def line_axis_interval(
    line: base.MapBlock,
    points: list[tuple[float, float]],
    axis: str,
    coordinate: float,
) -> tuple[float, float] | None:
    first = points[base.integer(line, "v1")]
    second = points[base.integer(line, "v2")]
    if axis == "x":
        if first[0] != coordinate or second[0] != coordinate:
            return None
        return tuple(sorted((first[1], second[1])))
    if first[1] != coordinate or second[1] != coordinate:
        return None
    return tuple(sorted((first[0], second[0])))


def railing_targets(
    by_kind: dict[str, list[base.MapBlock]],
) -> dict[int, int]:
    points = vertices(by_kind)
    targets: dict[int, int] = {}
    lengths: Counter[int] = Counter()

    for axis, coordinate, intervals, walk_height in RAILING_PATHS:
        for line in by_kind["linedef"]:
            interval = line_axis_interval(line, points, axis, coordinate)
            if interval is None:
                continue
            low, high = interval
            if not any(low >= start and high <= end for start, end in intervals):
                continue
            previous = targets.setdefault(line.index, walk_height)
            if previous != walk_height:
                raise ValueError(
                    f"Linedef {line.index} pertenece a dos alturas de reja"
                )
            lengths[walk_height] += high - low

    counts = Counter(targets.values())
    if dict(counts) != EXPECTED_RAILING_LINES:
        raise ValueError(f"Tramos de reja inesperados: {dict(counts)}")
    for height, expected in EXPECTED_RAILING_LENGTH.items():
        if lengths[height] != expected:
            raise ValueError(
                f"Longitud de reja z={height} inesperada: {lengths[height]:g}"
            )

    for line_index in targets:
        line = by_kind["linedef"][line_index]
        if line.properties.get("twosided") != "true" or "sideback" not in line.properties:
            raise ValueError(f"Linedef de reja {line_index} no es bilateral")
        if "special" in line.properties:
            raise ValueError(f"Linedef de reja {line_index} tiene una accion")
    return targets


def set_property(raw: str, key: str, value: str) -> str:
    pattern = re.compile(
        rf"(?m)^(?P<indent>[ \t]*){re.escape(key)}\s*=\s*.*?;[ \t]*$"
    )
    if pattern.search(raw):
        return pattern.sub(
            lambda match: f"{match.group('indent')}{key} = {value};",
            raw,
            count=1,
        )
    closing = raw.rfind("}")
    if closing < 0:
        raise ValueError("Bloque UDMF sin cierre")
    prefix = raw[:closing]
    if not prefix.endswith("\n"):
        prefix += "\n"
    return prefix + f"    {key} = {value};\n" + raw[closing:]


def line_floor_reference(
    line: base.MapBlock,
    by_kind: dict[str, list[base.MapBlock]],
) -> int:
    heights = []
    for side_name in ("sidefront", "sideback"):
        side = by_kind["sidedef"][base.integer(line, side_name)]
        sector = by_kind["sector"][base.integer(side, "sector")]
        heights.append(base.integer(sector, "heightfloor"))
    return max(heights)


def build_repaired_text(
    text: str,
    blocks: list[base.MapBlock],
    by_kind: dict[str, list[base.MapBlock]],
    targets: dict[int, int],
) -> str:
    replacements: dict[tuple[str, int], str] = {}

    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        line_raw = set_property(line.raw, "dontpegbottom", "true")
        line_raw = set_property(line_raw, "midtex3d", "true")
        line_raw = set_property(
            line_raw,
            "comment",
            f'"Caelum railing 4.30.0f / walk z={walk_height}"',
        )
        replacements[("linedef", line_index)] = line_raw

        anchor_bottom = walk_height - (
            RAILING_TEXTURE_HEIGHT - RAILING_VISIBLE_HEIGHT
        )
        y_offset = anchor_bottom - line_floor_reference(line, by_kind)
        for side_name in ("sidefront", "sideback"):
            side_index = base.integer(line, side_name)
            side = by_kind["sidedef"][side_index]
            side_raw = set_property(
                side.raw, "texturemiddle", RAILING_TEXTURE
            )
            side_raw = set_property(
                side_raw, "offsety_mid", str(y_offset)
            )
            replacements[("sidedef", side_index)] = side_raw

    output = text
    for block in reversed(blocks):
        replacement = replacements.get((block.kind, block.index))
        if replacement is not None:
            output = output[: block.start] + replacement + output[block.end :]
    return output


def validate_railings(
    by_kind: dict[str, list[base.MapBlock]],
    targets: dict[int, int],
) -> None:
    base.validate_references(by_kind, MAP01_UPDATED_COUNTS, ())
    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        if line.properties.get("midtex3d") != "true":
            raise ValueError(f"Linedef {line_index} no tiene midtex3d")
        if line.properties.get("dontpegbottom") != "true":
            raise ValueError(f"Linedef {line_index} no ancla desde abajo")
        anchor_bottom = walk_height - (
            RAILING_TEXTURE_HEIGHT - RAILING_VISIBLE_HEIGHT
        )
        expected_offset = anchor_bottom - line_floor_reference(line, by_kind)
        for side_name in ("sidefront", "sideback"):
            side = by_kind["sidedef"][base.integer(line, side_name)]
            if side.properties.get("texturemiddle") != RAILING_TEXTURE:
                raise ValueError(f"Sidedef {side.index} no usa CMRLBAL")
            if base.integer(side, "offsety_mid") != expected_offset:
                raise ValueError(f"Sidedef {side.index} tiene altura incorrecta")


def add_balcony_railings(path: Path = MAP01) -> bool:
    original = path.read_bytes()
    original_digest = sha256(original).hexdigest()
    signature, lumps = base.read_wad(path)
    text_indexes = [
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    ]
    if len(text_indexes) != 1:
        raise ValueError(f"MAP01 debe contener un TEXTMAP: {text_indexes}")
    text_index = text_indexes[0]
    text = lumps[text_index][1].decode("utf-8")
    blocks, by_kind = base.parse_textmap(text)
    targets = railing_targets(by_kind)

    if MAP01_UPDATED_SHA256 is not None and original_digest == MAP01_UPDATED_SHA256:
        validate_railings(by_kind, targets)
        return False
    if original_digest not in (
        MAP01_BASE_SHA256,
        MAP01_PROVISIONAL_SHA256,
    ):
        raise ValueError(
            "MAP01 no coincide con 4.30.0e ni con la previsualización 4.30.0f: "
            f"{original_digest}"
        )

    base.validate_references(by_kind, MAP01_BASE_COUNTS, ())
    repaired_text = build_repaired_text(text, blocks, by_kind, targets)
    repaired_blocks, repaired_by_kind = base.parse_textmap(repaired_text)
    repaired_targets = railing_targets(repaired_by_kind)
    validate_railings(repaired_by_kind, repaired_targets)

    # Things, vertices, sectors y conteos se conservan exactamente.
    for kind in ("vertex", "sector", "thing"):
        before = [block.raw for block in by_kind[kind]]
        after = [block.raw for block in repaired_by_kind[kind]]
        if before != after:
            raise ValueError(f"La reparacion altero bloques {kind}")

    lumps[text_index] = (b"TEXTMAP", repaired_text.encode("utf-8"))
    repaired_wad = base.render_wad(signature, lumps)
    repaired_digest = sha256(repaired_wad).hexdigest()
    if (
        MAP01_UPDATED_SHA256 is not None
        and repaired_digest != MAP01_UPDATED_SHA256
    ):
        raise ValueError(f"Hash MAP01 4.30.0f inesperado: {repaired_digest}")

    base.write_atomic(path, repaired_wad)
    return True


def main() -> None:
    changed = add_balcony_railings()
    digest = sha256(MAP01.read_bytes()).hexdigest()
    if changed:
        print("MAP01: rejas agregadas a ambos pisos")
    else:
        print("MAP01: rejas 4.30.0f ya presentes")
    print(f"MAP01 SHA-256: {digest}")


if __name__ == "__main__":
    main()
