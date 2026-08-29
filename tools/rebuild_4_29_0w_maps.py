"""Cierra los ocho huecos laterales y sostiene la marquesina de MAP01.

La entrada autorizada es exclusivamente MAP01 de 4.29.0v. El cambio separa
ocho superficies de 96 x 191 MU de los sectores de planta baja y les asigna
la losa completa del tag 510. También crea dos columnas de 8 x 8 MU bajo los
extremos de la marquesina occidental mediante el volumen vertical del tag 511.
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
from rebuild_4_29_0v_maps import (
    door_group_counts,
    sector_bounds,
    validate_upper_gate,
    validate_updated_map as validate_0v_map,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

BASE_SHA256 = "cd285dcebe7b92245ec42851ef988fe35849e0be7d0d1f618682b117dbb4c70d"
BASE_COUNTS = (516, 690, 1350, 146, 220)
UPDATED_SHA256 = "ca5de22d992de6e67032760738c3dfa4da336a9b916a406a0cfea481e1afd29d"
UPDATED_COUNTS = (536, 718, 1406, 156, 220)

FLOOR_ROOF_TAG = 510
WALL_TAG = 511
OPEN_FLOOR_TAG = 514
ROOF_ONLY_TAG = 515
CANOPY_SECTOR = 109

# nombre, rectángulo y sector anfitrión de 4.29.0v. Las superficies ocupan
# exactamente los ocho huecos señalados junto a las cuatro escaleras.
SLAB_CLOSURES = (
    ("noroeste_exterior", (-121.0, 200.0, -25.0, 391.0), 37),
    ("noroeste_interior", (96.0, 200.0, 192.0, 391.0), 41),
    ("noreste_interior", (544.0, 200.0, 640.0, 391.0), 41),
    ("noreste_exterior", (761.0, 200.0, 857.0, 391.0), 53),
    ("sudoeste_exterior", (-121.0, -391.0, -25.0, -200.0), 45),
    ("sudoeste_interior", (96.0, -391.0, 192.0, -200.0), 49),
    ("sudeste_interior", (544.0, -391.0, 640.0, -200.0), 49),
    ("sudeste_exterior", (761.0, -391.0, 857.0, -200.0), 57),
)

# Las columnas quedan centradas a 8 MU de los bordes exteriores de la
# marquesina. No invaden el vano útil de 128 MU del portón.
CANOPY_PILLARS = (
    ("columna_sur", (-565.0, -92.0, -557.0, -84.0)),
    ("columna_norte", (-565.0, 84.0, -557.0, 92.0)),
)


def map_counts(blocks) -> tuple[int, int, int, int, int]:
    return tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )


def tagged_sector_at(blocks, rectangle, tag: int) -> int:
    matches = [
        index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") == tag
        and sector_bounds(blocks, index) == rectangle
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Rectángulo {rectangle} con tag {tag}: {len(matches)} coincidencias"
        )
    return matches[0]


def validate_target_sectors(blocks) -> None:
    for name, rectangle, _ in SLAB_CLOSURES:
        index = tagged_sector_at(blocks, rectangle, FLOOR_ROOF_TAG)
        validate_closed_sector(blocks, index)
        if rectangle[2] - rectangle[0] != 96.0:
            raise ValueError(f"{name} perdió el ancho de 96 MU")
        if rectangle[3] - rectangle[1] != 191.0:
            raise ValueError(f"{name} perdió el largo de 191 MU")

    for name, rectangle in CANOPY_PILLARS:
        index = tagged_sector_at(blocks, rectangle, WALL_TAG)
        validate_closed_sector(blocks, index)
        if rectangle[2] - rectangle[0] != 8.0:
            raise ValueError(f"{name} perdió el ancho de 8 MU")
        if rectangle[3] - rectangle[1] != 8.0:
            raise ValueError(f"{name} perdió el fondo de 8 MU")


def validate_updated_map(path: Path, blocks) -> None:
    counts = map_counts(blocks)
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0w inesperada: {counts}")

    identifiers = Counter(
        integer(sector, "id") for sector in blocks["sector"]
    )
    expected = {
        FLOOR_ROOF_TAG: 71,
        WALL_TAG: 13,
        OPEN_FLOOR_TAG: 1,
        ROOF_ONLY_TAG: 24,
    }
    for tag, amount in expected.items():
        if identifiers[tag] != amount:
            raise ValueError(
                f"Sectores con tag {tag}: {identifiers[tag]}, esperados {amount}"
            )

    validate_target_sectors(blocks)

    # Los veinticuatro tramos reales de escalera siguen abiertos.
    for sector_index in range(1, 25):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La escalera {sector_index} perdió el tag 515")

    groups = door_group_counts(blocks)
    if groups[912] != 2:
        raise ValueError("El portón superior no conserva sus dos hojas")
    validate_upper_gate(blocks)

    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if UPDATED_SHA256 and digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0w inesperado: {digest}")


def is_updated(blocks) -> bool:
    if map_counts(blocks) != UPDATED_COUNTS:
        return False
    try:
        validate_target_sectors(blocks)
    except ValueError:
        return False
    return True


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
    counts = map_counts(blocks)
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0v: {counts}, {digest}"
        )
    validate_0v_map(path, blocks)

    for _, rectangle, host_sector in SLAB_CLOSURES:
        carve_rectangle(
            blocks,
            rectangle,
            host_sector,
            FLOOR_ROOF_TAG,
        )

    for _, rectangle in CANOPY_PILLARS:
        carve_rectangle(
            blocks,
            rectangle,
            CANOPY_SECTOR,
            WALL_TAG,
        )

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
        "MAP01: ocho cierres y columnas 4.29.0w aplicados"
        if changed
        else "MAP01: corrección 4.29.0w ya presente"
    )
