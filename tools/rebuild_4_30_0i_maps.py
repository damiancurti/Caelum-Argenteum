"""Ajusta los tres tramos de reja observados sobre MAP01 4.30.0h.

La revision mantiene la altura corregida y toda la topologia del mapa. Solo
cambia que linedefs bilaterales reciben la textura intermedia de la reja:

* abre 96 MU del balcon del primer piso en y=-383;
* traslada la reja de la escalera oriental desde x=1697, y=-128..64 hacia
  x=1689, y=-320..-64;
* completa el borde occidental en x=-569, y=-92..92.
"""

from __future__ import annotations

from collections import Counter
from hashlib import sha256
from pathlib import Path
import re

import rebuild_4_30_0c_maps as base
import rebuild_4_30_0g_maps as railings_4300g
import rebuild_4_30_0h_maps as railings_4300h


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

MAP01_4300H_SHA256 = (
    "aef653d161697746883ddd5d74c71ac1bac35ba01191e3325b28c3e7f1a8c578"
)
MAP01_4300I_SHA256 = (
    "dc5eb73f7b876d5c70b9b2ae7862ac21c617b2c10ef879d508b89c096281a36e"
)

# Eje, coordenada real de la linedef, intervalos inclusivos y altura del piso.
# Las tres correcciones se expresan contra las linedefs existentes, sin crear
# vertices, lados, sectores ni geometria nueva.
RAILING_PATHS = (
    # Primer piso, z=136. El acceso sur queda abierto entre x=1209 y x=1305.
    ("y", 632.0, ((-561.0, 1305.0),), 136),
    ("x", -561.0, ((-632.0, -100.0), (100.0, 632.0)), 136),
    ("x", 1305.0, ((-632.0, -383.0), (383.0, 632.0)), 136),
    ("y", 383.0, ((1305.0, 1961.0),), 136),
    ("x", 1961.0, ((-383.0, 383.0),), 136),
    ("y", -383.0, ((1305.0, 1961.0),), 136),
    ("y", -632.0, ((-561.0, 1305.0),), 136),

    # Segundo piso, z=264. El borde occidental se cierra en x=-569. En la
    # escalera oriental se deja libre y=-64..64 y se protege el borde sur.
    ("x", -569.0, ((-92.0, 92.0),), 264),
    ("x", -557.0, ((-92.0, -84.0), (84.0, 92.0)), 264),
    ("y", 92.0, ((-557.0, -465.0),), 264),
    ("x", -465.0, ((-536.0, -92.0), (92.0, 536.0)), 264),
    ("y", 536.0, ((-465.0, 1201.0),), 264),
    ("x", 1209.0, ((320.0, 536.0),), 264),
    ("y", 320.0, ((1209.0, 1697.0),), 264),
    ("x", 1697.0, ((64.0, 320.0),), 264),
    ("x", 1689.0, ((-320.0, -64.0),), 264),
    ("y", -320.0, ((1201.0, 1689.0),), 264),
    ("x", 1201.0, ((-536.0, -304.0),), 264),
    ("y", -536.0, ((-465.0, 1201.0),), 264),
    ("y", -92.0, ((-557.0, -465.0),), 264),
    ("y", -84.0, ((-565.0, -557.0),), 264),
)

EXPECTED_RAILING_LINES = {136: 41, 264: 82}
EXPECTED_RAILING_LENGTH = {136: 7364.0, 264: 6476.0}
EXPECTED_REMOVED_LINES = {740, 804, 805, 834}
EXPECTED_ADDED_LINES = {273, 279, 760, 778, 779, 923, 924, 1014, 1836}


def railing_targets(
    by_kind: dict[str, list[base.MapBlock]],
) -> dict[int, int]:
    points = railings_4300g.vertices(by_kind)
    targets: dict[int, int] = {}
    lengths: Counter[int] = Counter()

    for axis, coordinate, intervals, walk_height in RAILING_PATHS:
        for line in by_kind["linedef"]:
            interval = railings_4300g.line_axis_interval(
                line, points, axis, coordinate
            )
            if interval is None:
                continue
            low, high = interval
            if not any(
                low >= start and high <= end for start, end in intervals
            ):
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


def remove_property(raw: str, key: str) -> str:
    pattern = re.compile(
        rf"(?m)^[ \t]*{re.escape(key)}\s*=\s*.*?;[ \t]*\n?"
    )
    return pattern.sub("", raw, count=1)


def build_adjusted_text(
    text: str,
    blocks: list[base.MapBlock],
    by_kind: dict[str, list[base.MapBlock]],
    previous_targets: dict[int, int],
    targets: dict[int, int],
) -> str:
    replacements: dict[tuple[str, int], str] = {}

    for line_index in previous_targets.keys() - targets.keys():
        line = by_kind["linedef"][line_index]
        line_raw = remove_property(line.raw, "dontpegbottom")
        line_raw = remove_property(line_raw, "midtex3d")
        line_raw = remove_property(line_raw, "comment")
        replacements[("linedef", line_index)] = line_raw
        for side_name in ("sidefront", "sideback"):
            side_index = base.integer(line, side_name)
            side = by_kind["sidedef"][side_index]
            side_raw = railings_4300g.set_property(
                side.raw, "texturemiddle", '"-"'
            )
            side_raw = remove_property(side_raw, "offsety_mid")
            replacements[("sidedef", side_index)] = side_raw

    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        line_raw = railings_4300g.set_property(
            line.raw, "dontpegbottom", "true"
        )
        line_raw = railings_4300g.set_property(line_raw, "midtex3d", "true")
        existing_comment = line.properties.get("comment", "")
        railing_comment = existing_comment if line_index in previous_targets else (
            f'"Caelum railing 4.30.0i / base z={walk_height}"'
        )
        line_raw = railings_4300g.set_property(
            line_raw,
            "comment",
            railing_comment,
        )
        replacements[("linedef", line_index)] = line_raw

        y_offset = railings_4300h.expected_texture_offset(
            line, by_kind, walk_height
        )
        for side_name in ("sidefront", "sideback"):
            side_index = base.integer(line, side_name)
            side = by_kind["sidedef"][side_index]
            side_raw = railings_4300g.set_property(
                side.raw, "texturemiddle", railings_4300g.RAILING_TEXTURE
            )
            side_raw = railings_4300g.set_property(
                side_raw,
                "offsety_mid",
                railings_4300h.format_udmf_number(y_offset),
            )
            replacements[("sidedef", side_index)] = side_raw

    output = text
    for block in reversed(blocks):
        replacement = replacements.get((block.kind, block.index))
        if replacement is not None:
            output = output[: block.start] + replacement + output[block.end :]
    return output


def validate_adjusted_railings(
    by_kind: dict[str, list[base.MapBlock]],
    targets: dict[int, int],
) -> None:
    base.validate_references(by_kind, railings_4300g.MAP01_COUNTS, ())
    marked = {
        line.index
        for line in by_kind["linedef"]
        if line.properties.get("comment", "").startswith('"Caelum railing')
    }
    if marked != set(targets):
        raise ValueError("Existen rejas fuera del trazado 4.30.0i")

    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        if line.properties.get("midtex3d") != "true":
            raise ValueError(f"Linedef {line_index} no tiene midtex3d")
        if line.properties.get("dontpegbottom") != "true":
            raise ValueError(f"Linedef {line_index} no ancla desde abajo")
        expected_offset = railings_4300h.expected_texture_offset(
            line, by_kind, walk_height
        )
        floor_reference = railings_4300g.line_floor_reference(line, by_kind)
        for side_name in ("sidefront", "sideback"):
            side = by_kind["sidedef"][base.integer(line, side_name)]
            if side.properties.get("texturemiddle") != railings_4300g.RAILING_TEXTURE:
                raise ValueError(f"Sidedef {side.index} no usa CMRLBAL")
            actual_offset = float(side.properties.get("offsety_mid", "0"))
            if abs(actual_offset - expected_offset) > railings_4300h.OFFSET_TOLERANCE:
                raise ValueError(
                    f"Sidedef {side.index} tiene offset vertical incorrecto"
                )
            actual_bottom = floor_reference + (
                actual_offset / railings_4300h.RAILING_TEXTURE_Y_SCALE
            )
            if abs(actual_bottom - walk_height) > railings_4300h.OFFSET_TOLERANCE:
                raise ValueError(
                    f"Sidedef {side.index} queda en z={actual_bottom:g}, "
                    f"no en z={walk_height}"
                )


def adjust_railings(path: Path = MAP01) -> bool:
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

    if MAP01_4300I_SHA256 is not None and original_digest == MAP01_4300I_SHA256:
        validate_adjusted_railings(by_kind, targets)
        return False
    if original_digest != MAP01_4300H_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base 4.30.0h: " + original_digest
        )

    previous_targets = railings_4300g.railing_targets(by_kind)
    removed = set(previous_targets) - set(targets)
    added = set(targets) - set(previous_targets)
    if removed != EXPECTED_REMOVED_LINES:
        raise ValueError(f"Linedefs retiradas inesperadas: {sorted(removed)}")
    if added != EXPECTED_ADDED_LINES:
        raise ValueError(f"Linedefs agregadas inesperadas: {sorted(added)}")

    adjusted_text = build_adjusted_text(
        text, blocks, by_kind, previous_targets, targets
    )
    adjusted_blocks, adjusted_by_kind = base.parse_textmap(adjusted_text)
    adjusted_targets = railing_targets(adjusted_by_kind)
    validate_adjusted_railings(adjusted_by_kind, adjusted_targets)

    for kind in ("vertex", "sector", "thing"):
        before = [block.raw for block in by_kind[kind]]
        after = [block.raw for block in adjusted_by_kind[kind]]
        if before != after:
            raise ValueError(f"La correccion altero bloques {kind}")

    lumps[text_index] = (b"TEXTMAP", adjusted_text.encode("utf-8"))
    adjusted_wad = base.render_wad(signature, lumps)
    adjusted_digest = sha256(adjusted_wad).hexdigest()
    if MAP01_4300I_SHA256 is not None and adjusted_digest != MAP01_4300I_SHA256:
        raise ValueError(f"Hash MAP01 4.30.0i inesperado: {adjusted_digest}")

    base.write_atomic(path, adjusted_wad)
    return True


def main() -> None:
    changed = adjust_railings()
    digest = sha256(MAP01.read_bytes()).hexdigest()
    if changed:
        print("MAP01: tres tramos de reja 4.30.0i corregidos")
    else:
        print("MAP01: trazado de rejas 4.30.0i ya presente")
    print(f"MAP01 SHA-256: {digest}")


if __name__ == "__main__":
    main()
