"""Añade el manual tutorial de procesamiento a MAP01 para V4.29.0aa.

La entrada autorizada es exclusivamente MAP01 de 4.29.0z. El manual se
coloca a la izquierda de la hilera principal de estaciones y no modifica la
geometría aceptada de la mansión. El proceso es determinista e idempotente.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0w_maps import map_counts
from rebuild_4_29_0z_maps import (
    UPDATED_COUNTS as BASE_COUNTS,
    UPDATED_SHA256 as BASE_SHA256,
    validate_updated_map as validate_0z_map,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

UPDATED_COUNTS = (544, 730, 1430, 159, 221)
UPDATED_SHA256 = "b0d92e3c3ba0a17f59aa160796817aac221a5585c815ac41290eb5eab8d4d9ae"

PROCESSING_MANUAL_DOOMEDNUM = 18106
PROCESSING_MANUAL_POSITION = (-364.0, 800.0)


def make_processing_manual() -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("x", f"{PROCESSING_MANUAL_POSITION[0]:.1f}"),
            ("y", f"{PROCESSING_MANUAL_POSITION[1]:.1f}"),
            ("height", "0.0"),
            ("angle", "270"),
            ("type", str(PROCESSING_MANUAL_DOOMEDNUM)),
            ("skill1", "true"),
            ("skill2", "true"),
            ("skill3", "true"),
            ("skill4", "true"),
            ("skill5", "true"),
            ("single", "true"),
            ("coop", "true"),
            ("dm", "true"),
        )
    )


def processing_manuals(blocks):
    return [
        thing
        for thing in blocks["thing"]
        if integer(thing, "type") == PROCESSING_MANUAL_DOOMEDNUM
    ]


def validate_updated_map(path: Path, blocks) -> None:
    if map_counts(blocks) != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0aa inesperada: {map_counts(blocks)}")
    manuals = processing_manuals(blocks)
    if len(manuals) != 1:
        raise ValueError(f"Manuales de procesamiento: {len(manuals)}, esperado 1")
    manual = manuals[0]
    position = (float(manual["x"]), float(manual["y"]))
    if position != PROCESSING_MANUAL_POSITION:
        raise ValueError(f"Posición inesperada del manual: {position}")
    digest = sha256(path.read_bytes()).hexdigest()
    if digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0aa inesperado: {digest}")


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if processing_manuals(blocks):
        validate_updated_map(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0z: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_0z_map(path, blocks)

    blocks["thing"].append(make_processing_manual())
    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(
        data for name, data in written_lumps if name == b"TEXTMAP"
    )
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_updated_map(path, written_blocks)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: manual de procesamiento 4.29.0aa añadido"
        if changed
        else "MAP01: manual de procesamiento 4.29.0aa ya presente"
    )
