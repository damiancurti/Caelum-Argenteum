"""Extiende la cubierta de MAP01 sobre la escalera oriental pendiente.

La entrada autorizada es exclusivamente MAP01 de 4.29.0w. Los doce tramos de
la pareja de escaleras del fondo reciben el volumen de techo controlado por el
tag 515, igual que los veinticuatro tramos ya cubiertos. No se añaden sectores
ni se altera la superficie transitable.
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
from rebuild_4_29_0v_maps import door_group_counts, sector_bounds, validate_upper_gate
from rebuild_4_29_0w_maps import (
    UPDATED_COUNTS,
    map_counts,
    validate_target_sectors,
    validate_updated_map as validate_0w_map,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

BASE_SHA256 = "ca5de22d992de6e67032760738c3dfa4da336a9b916a406a0cfea481e1afd29d"
UPDATED_SHA256 = "1223bafec960be9c14018af07867e6ec2e216975f1c44b0415ff4002973c51de"
ROOF_ONLY_TAG = 515

# Rectángulos exactos de los seis peldaños meridionales y seis septentrionales
# que 4.29.0w dejó sin el techo compartido de las demás escaleras.
EAST_STAIR_BOUNDS = (
    (1306.0, -272.0, 1425.0, -240.0),
    (1306.0, -240.0, 1425.0, -208.0),
    (1306.0, -208.0, 1425.0, -176.0),
    (1306.0, -176.0, 1425.0, -144.0),
    (1306.0, -144.0, 1425.0, -112.0),
    (1306.0, -112.0, 1425.0, -80.0),
    (1306.0, 80.0, 1425.0, 112.0),
    (1306.0, 112.0, 1425.0, 144.0),
    (1306.0, 144.0, 1425.0, 176.0),
    (1306.0, 176.0, 1425.0, 208.0),
    (1306.0, 208.0, 1425.0, 240.0),
    (1306.0, 240.0, 1425.0, 272.0),
)


def east_stair_indices(blocks) -> list[int]:
    indices = []
    for rectangle in EAST_STAIR_BOUNDS:
        matches = [
            index
            for index in range(len(blocks["sector"]))
            if sector_bounds(blocks, index) == rectangle
        ]
        if len(matches) != 1:
            raise ValueError(
                f"Tramo oriental {rectangle}: {len(matches)} coincidencias"
            )
        indices.append(matches[0])
    if len(set(indices)) != len(EAST_STAIR_BOUNDS):
        raise ValueError("Dos rectángulos orientales resolvieron el mismo sector")
    return indices


def validate_updated_map(path: Path, blocks) -> None:
    if map_counts(blocks) != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0y inesperada: {map_counts(blocks)}")

    target_indices = east_stair_indices(blocks)
    for sector_index in target_indices:
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(
                f"La escalera oriental {sector_index} perdió el tag 515"
            )

    identifiers = Counter(integer(sector, "id") for sector in blocks["sector"])
    if identifiers[ROOF_ONLY_TAG] != 36:
        raise ValueError(
            f"Sectores con tag 515: {identifiers[ROOF_ONLY_TAG]}, esperados 36"
        )

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
        raise ValueError(f"Hash 4.29.0y inesperado: {digest}")


def is_updated(blocks) -> bool:
    if map_counts(blocks) != UPDATED_COUNTS:
        return False
    try:
        return all(
            integer(blocks["sector"][index], "id") == ROOF_ONLY_TAG
            for index in east_stair_indices(blocks)
        )
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
    if map_counts(blocks) != UPDATED_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0w: "
            f"{map_counts(blocks)}, {digest}"
        )
    validate_0w_map(path, blocks)

    for sector_index in east_stair_indices(blocks):
        blocks["sector"][sector_index]["id"] = str(ROOF_ONLY_TAG)

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
        "MAP01: cubierta oriental 4.29.0y aplicada"
        if changed
        else "MAP01: cubierta oriental 4.29.0y ya presente"
    )
