"""Corrige el anclaje vertical de las rejas de MAP01 4.30.0g.

CMRLBAL usa YScale 2.583333. GZDoom interpreta offsety_mid en texeles cuando
WorldPanning no esta activo, de modo que el offset anterior se dividia por esa
escala. Este parche conserva exactamente las linedefs de 4.30.0g y convierte
la distancia vertical deseada de unidades de mundo a unidades de textura.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

import rebuild_4_30_0c_maps as base
import rebuild_4_30_0g_maps as railings_4300g


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

MAP01_4300G_SHA256 = (
    "ebdc0ebd159d747e82b4dcabc434f65fe66dbd64361f9584f6ba9d55157f75b9"
)
MAP01_4300H_SHA256 = (
    "aef653d161697746883ddd5d74c71ac1bac35ba01191e3325b28c3e7f1a8c578"
)

# Escala declarada para CMRLBAL en TEXTURES. Sin WorldPanning, GZDoom divide
# offsety_mid por este valor antes de sumarlo a la mayor altura de piso.
RAILING_TEXTURE_Y_SCALE = 2.583333
OFFSET_TOLERANCE = 0.001


def expected_texture_offset(
    line: base.MapBlock,
    by_kind: dict[str, list[base.MapBlock]],
    walk_height: int,
) -> float:
    world_offset = walk_height - railings_4300g.line_floor_reference(
        line, by_kind
    )
    return world_offset * RAILING_TEXTURE_Y_SCALE


def format_udmf_number(value: float) -> str:
    rounded = round(value)
    if abs(value - rounded) <= 0.000001:
        return str(rounded)
    return f"{value:.6f}".rstrip("0").rstrip(".")


def build_corrected_text(
    text: str,
    blocks: list[base.MapBlock],
    by_kind: dict[str, list[base.MapBlock]],
    targets: dict[int, int],
) -> str:
    replacements: dict[tuple[str, int], str] = {}

    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        line_raw = railings_4300g.set_property(
            line.raw,
            "comment",
            f'"Caelum railing 4.30.0h / base z={walk_height}"',
        )
        replacements[("linedef", line_index)] = line_raw

        y_offset = expected_texture_offset(line, by_kind, walk_height)
        for side_name in ("sidefront", "sideback"):
            side_index = base.integer(line, side_name)
            side = by_kind["sidedef"][side_index]
            side_raw = railings_4300g.set_property(
                side.raw,
                "offsety_mid",
                format_udmf_number(y_offset),
            )
            replacements[("sidedef", side_index)] = side_raw

    output = text
    for block in reversed(blocks):
        replacement = replacements.get((block.kind, block.index))
        if replacement is not None:
            output = output[: block.start] + replacement + output[block.end :]
    return output


def validate_corrected_railings(
    by_kind: dict[str, list[base.MapBlock]],
    targets: dict[int, int],
) -> None:
    base.validate_references(by_kind, railings_4300g.MAP01_COUNTS, ())
    marked = {
        line.index
        for line in by_kind["linedef"]
        if line.properties.get("comment", "").startswith(
            '"Caelum railing 4.30.0h'
        )
    }
    if marked != set(targets):
        raise ValueError("Existen rejas fuera del trazado 4.30.0g aprobado")

    for line_index, walk_height in targets.items():
        line = by_kind["linedef"][line_index]
        if line.properties.get("midtex3d") != "true":
            raise ValueError(f"Linedef {line_index} no tiene midtex3d")
        if line.properties.get("dontpegbottom") != "true":
            raise ValueError(f"Linedef {line_index} no ancla desde abajo")

        expected_offset = expected_texture_offset(
            line, by_kind, walk_height
        )
        floor_reference = railings_4300g.line_floor_reference(line, by_kind)
        for side_name in ("sidefront", "sideback"):
            side = by_kind["sidedef"][base.integer(line, side_name)]
            if side.properties.get("texturemiddle") != railings_4300g.RAILING_TEXTURE:
                raise ValueError(f"Sidedef {side.index} no usa CMRLBAL")
            actual_offset = float(side.properties.get("offsety_mid", "0"))
            if abs(actual_offset - expected_offset) > OFFSET_TOLERANCE:
                raise ValueError(
                    f"Sidedef {side.index} tiene offset vertical incorrecto"
                )
            actual_bottom = floor_reference + (
                actual_offset / RAILING_TEXTURE_Y_SCALE
            )
            if abs(actual_bottom - walk_height) > OFFSET_TOLERANCE:
                raise ValueError(
                    f"Sidedef {side.index} queda en z={actual_bottom:g}, "
                    f"no en z={walk_height}"
                )


def correct_railing_heights(path: Path = MAP01) -> bool:
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
    targets = railings_4300g.railing_targets(by_kind)

    if MAP01_4300H_SHA256 is not None and original_digest == MAP01_4300H_SHA256:
        validate_corrected_railings(by_kind, targets)
        return False
    if original_digest != MAP01_4300G_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base 4.30.0g: " + original_digest
        )

    corrected_text = build_corrected_text(text, blocks, by_kind, targets)
    corrected_blocks, corrected_by_kind = base.parse_textmap(corrected_text)
    corrected_targets = railings_4300g.railing_targets(corrected_by_kind)
    validate_corrected_railings(corrected_by_kind, corrected_targets)

    for kind in ("vertex", "sector", "thing"):
        before = [block.raw for block in by_kind[kind]]
        after = [block.raw for block in corrected_by_kind[kind]]
        if before != after:
            raise ValueError(f"La correccion altero bloques {kind}")

    lumps[text_index] = (b"TEXTMAP", corrected_text.encode("utf-8"))
    corrected_wad = base.render_wad(signature, lumps)
    corrected_digest = sha256(corrected_wad).hexdigest()
    if MAP01_4300H_SHA256 is not None and corrected_digest != MAP01_4300H_SHA256:
        raise ValueError(f"Hash MAP01 4.30.0h inesperado: {corrected_digest}")

    base.write_atomic(path, corrected_wad)
    return True


def main() -> None:
    changed = correct_railing_heights()
    digest = sha256(MAP01.read_bytes()).hexdigest()
    if changed:
        print("MAP01: alturas de rejas 4.30.0h corregidas")
    else:
        print("MAP01: alturas de rejas 4.30.0h ya presentes")
    print(f"MAP01 SHA-256: {digest}")


if __name__ == "__main__":
    main()
