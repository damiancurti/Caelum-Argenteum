"""Restaura las cuatro puertas laterales aprobadas de MAP01 para V4.29.0t.

La geometría aceptada de 4.29.0s ya contiene los cuatro portales entre las
habitaciones centrales y las extremas. Este paso no toca esa geometría: vuelve
a insertar exactamente las hojas 906--909 que el autor confirmó necesarias,
antes de las entradas frontales 910/911, y recupera el WAD 4.29.0r validado.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0q_maps import CONNECTION_DOORS, make_door
from rebuild_4_29_0r_maps import validate_map


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "518783a90217ca6999cda5981a95af8e624bf178a74e0c93d466ac1f1fc9ffc4"
BASE_COUNTS = (468, 587, 1144, 101, 214)
UPDATED_SHA256 = "9c307fb31ac88a29d6ff8e6fb851776e43dfdff3207ed90a38b4d0e8bef4f346"
UPDATED_COUNTS = (468, 587, 1144, 101, 218)
RESTORED_GROUPS = (906, 907, 908, 909)


def door_groups(blocks) -> list[int]:
    return [
        integer(thing, "arg0")
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
    ]


def validate_restored_map(path: Path, blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0t inesperada: {counts}")

    groups = door_groups(blocks)
    for group in RESTORED_GROUPS:
        if groups.count(group) != 1:
            raise ValueError(
                f"Puerta restaurada {group}: {groups.count(group)}, esperada 1"
            )

    validate_map(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if digest != UPDATED_SHA256:
        raise ValueError(
            "MAP01 es estructuralmente válido pero no recuperó el WAD "
            f"aceptado: {digest}"
        )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    groups = door_groups(blocks)
    if all(groups.count(group) == 1 for group in RESTORED_GROUPS):
        validate_restored_map(path, blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0s: {counts}, {digest}"
        )
    if any(group in groups for group in RESTORED_GROUPS):
        raise ValueError("MAP01 contiene sólo una parte de las puertas 906--909")

    insertion_index = next(
        index
        for index, thing in enumerate(blocks["thing"])
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") in (910, 911)
    )
    restored = [
        make_door(x, y, group, direction)
        for x, y, group, direction in CONNECTION_DOORS
    ]
    blocks["thing"][insertion_index:insertion_index] = restored

    validate_map(blocks)
    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)

    # Releer impide que la validación del hash use una representación previa
    # distinta de los bytes que realmente recibirá GZDoom.
    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_restored_map(path, written_blocks)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: puertas laterales 906--909 restauradas"
        if changed
        else "MAP01: puertas laterales 906--909 ya presentes"
    )
