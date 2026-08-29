"""Añade los tres muros del recinto oriental de escaleras en MAP01.

La entrada autorizada es exclusivamente MAP01 de 4.29.0y. La cubierta de las
dos escaleras orientales ya existe; este incremento talla una U de tres muros
de 8 MU en el sector 65, siguiendo el perímetro señalado visualmente con
munición. Los muros reutilizan el volumen 3D del tag 511 (128--256 MU), por lo
que no alteran el piso de 128--136 MU, los doce peldaños ni el acceso central.
"""

from __future__ import annotations

from collections import Counter
from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0q_maps import (
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import carve_rectangle, validate_closed_sector
from rebuild_4_29_0v_maps import door_group_counts, sector_bounds, validate_upper_gate
from rebuild_4_29_0w_maps import (
    map_counts,
    validate_target_sectors,
)
from rebuild_4_29_0y_maps import (
    UPDATED_COUNTS as BASE_COUNTS,
    UPDATED_SHA256 as BASE_SHA256,
    east_stair_indices,
    validate_updated_map as validate_0y_map,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

UPDATED_COUNTS = (544, 730, 1430, 159, 220)
UPDATED_SHA256 = "700a1f2c5bd7e99b2d36f5e3a033809301e58022836ee34880dd6f94f90dfae4"

WALL_TAG = 511
ROOF_ONLY_TAG = 515
EAST_ANNEX_SECTOR = 65

# La U se apoya en los límites norte y sur del anexo. Su frente queda a
# X=1697, dejando un patio exterior de 272 MU hasta el borde oriental del
# sector. Las tres piezas comparten espesor de 8 MU y no se solapan.
EAST_STAIR_WALLS = (
    ("muro_sur", (1306.0, -391.0, 1689.0, -383.0)),
    ("muro_frontal", (1689.0, -391.0, 1697.0, 391.0)),
    ("muro_norte", (1306.0, 383.0, 1689.0, 391.0)),
)


def tagged_wall_at(blocks, rectangle) -> int:
    matches = [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == WALL_TAG
        and sector_bounds(blocks, index) == rectangle
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Muro oriental {rectangle}: {len(matches)} coincidencias"
        )
    return matches[0]


def validate_wall_geometry(blocks) -> None:
    for name, rectangle in EAST_STAIR_WALLS:
        index = tagged_wall_at(blocks, rectangle)
        validate_closed_sector(blocks, index)
        width = rectangle[2] - rectangle[0]
        depth = rectangle[3] - rectangle[1]
        if min(width, depth) != 8.0:
            raise ValueError(f"{name} perdió su espesor de 8 MU")


def validate_updated_map(path: Path, blocks) -> None:
    if UPDATED_COUNTS is not None and map_counts(blocks) != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0z inesperada: {map_counts(blocks)}")

    validate_wall_geometry(blocks)
    identifiers = Counter(integer(sector, "id") for sector in blocks["sector"])
    if identifiers[WALL_TAG] != 16:
        raise ValueError(
            f"Sectores con tag 511: {identifiers[WALL_TAG]}, esperados 16"
        )
    if identifiers[ROOF_ONLY_TAG] != 36:
        raise ValueError(
            f"Sectores con tag 515: {identifiers[ROOF_ONLY_TAG]}, esperados 36"
        )

    for sector_index in east_stair_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La escalera oriental {sector_index} perdió su techo")

    validate_target_sectors(blocks)
    if door_group_counts(blocks)[912] != 2:
        raise ValueError("El portón superior no conserva sus dos hojas")
    validate_upper_gate(blocks)
    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if UPDATED_SHA256 and digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0z inesperado: {digest}")


def is_updated(blocks) -> bool:
    try:
        validate_wall_geometry(blocks)
        return True
    except ValueError:
        return False


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_updated_map(path, blocks)
        return False

    digest = sha256(path.read_bytes()).hexdigest()
    if map_counts(blocks) != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0y: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_0y_map(path, blocks)

    if sector_bounds(blocks, EAST_ANNEX_SECTOR) != (
        1306.0,
        -391.0,
        1969.0,
        391.0,
    ):
        raise ValueError("El sector anfitrión oriental cambió de límites")

    for _, rectangle in EAST_STAIR_WALLS:
        carve_rectangle(blocks, rectangle, EAST_ANNEX_SECTOR, WALL_TAG)

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
        "MAP01: muros orientales 4.29.0z aplicados"
        if changed
        else "MAP01: muros orientales 4.29.0z ya presentes"
    )
