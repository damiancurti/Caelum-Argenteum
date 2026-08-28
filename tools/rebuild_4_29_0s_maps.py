"""Retira las cuatro hojas laterales redundantes de MAP01 para V4.29.0s.

La geometría aprobada de 4.29.0r ya contiene cuatro portales abiertos entre
las habitaciones centrales y las extremas. Las hojas 906--909 quedaron
embebidas en el espesor de esos muros y no aportan una conexión útil. Este
paso elimina exclusivamente esos cuatro Things y conserva las puertas del
divisor central y las dos entradas frontales dobles.
"""

from __future__ import annotations

from collections import defaultdict
from hashlib import sha256
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)
from rebuild_4_29_0o_maps import vertical_segments
from rebuild_4_29_0q_maps import (
    find_edge_indices,
    validate_closed_sector,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0r_maps import validate_front_entries


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
BASE_SHA256 = "9c307fb31ac88a29d6ff8e6fb851776e43dfdff3207ed90a38b4d0e8bef4f346"
BASE_COUNTS = (468, 587, 1144, 101, 218)
UPDATED_COUNTS = (468, 587, 1144, 101, 214)

REMOVED_GROUPS = (906, 907, 908, 909)
PRESERVED_GROUPS = (902, 905, 910, 911)

REQUIRED_PORTAL_EDGES = (
    ((-129.0, 400.0), (-121.0, 400.0)),
    ((-121.0, 400.0), (-113.0, 400.0)),
    ((849.0, 400.0), (857.0, 400.0)),
    ((857.0, 400.0), (865.0, 400.0)),
    ((-129.0, 464.0), (-121.0, 464.0)),
    ((-121.0, 464.0), (-113.0, 464.0)),
    ((849.0, 464.0), (857.0, 464.0)),
    ((857.0, 464.0), (865.0, 464.0)),
    ((-129.0, -464.0), (-121.0, -464.0)),
    ((-121.0, -464.0), (-113.0, -464.0)),
    ((849.0, -464.0), (857.0, -464.0)),
    ((857.0, -464.0), (865.0, -464.0)),
    ((-129.0, -400.0), (-121.0, -400.0)),
    ((-121.0, -400.0), (-113.0, -400.0)),
    ((849.0, -400.0), (857.0, -400.0)),
    ((857.0, -400.0), (865.0, -400.0)),
)


def door_group_counts(blocks) -> defaultdict[int, int]:
    counts: defaultdict[int, int] = defaultdict(int)
    for thing in blocks["thing"]:
        if integer(thing, "type") == 18025:
            counts[integer(thing, "arg0")] += 1
    return counts


def validate_open_connections(blocks) -> None:
    # El centro de cada portal debe quedar libre de linedefs. Las tapas del
    # espesor de muro se conservan para que los sectores 3D sigan cerrados.
    for x in (-121.0, 857.0):
        for low, high in ((400.0, 464.0), (-464.0, -400.0)):
            for _, line, _ in vertical_segments(blocks, x, low, high):
                first = blocks["vertex"][integer(line, "v1")]
                second = blocks["vertex"][integer(line, "v2")]
                midpoint = (float(first["y"]) + float(second["y"])) * 0.5
                if low < midpoint < high:
                    raise ValueError(
                        f"La abertura X={x:g} conserva una pared interior"
                    )

    for first, second in REQUIRED_PORTAL_EDGES:
        if len(find_edge_indices(blocks, first, second)) != 1:
            raise ValueError(f"Portal lateral incompleto: {first} -> {second}")


def validate_map(blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0s inesperada: {counts}")

    groups = door_group_counts(blocks)
    if any(groups[group] for group in REMOVED_GROUPS):
        raise ValueError("Persisten hojas laterales 906--909")
    expected_preserved = {902: 1, 905: 1, 910: 2, 911: 2}
    for group, expected in expected_preserved.items():
        if groups[group] != expected:
            raise ValueError(
                f"Puertas preservadas {group}: {groups[group]}, esperadas {expected}"
            )

    ids = [integer(sector, "id") for sector in blocks["sector"]]
    if ids.count(510) != 8 or ids.count(511) != 4:
        raise ValueError(
            f"Sectores superiores inesperados: 510={ids.count(510)}, "
            f"511={ids.count(511)}"
        )

    validate_references(blocks)
    for sector_index in range(83, 101):
        if integer(blocks["sector"][sector_index], "id") in (510, 511):
            validate_closed_sector(blocks, sector_index)
    validate_open_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)
    validate_front_entries(blocks)


def is_updated(blocks) -> bool:
    groups = door_group_counts(blocks)
    return not any(groups[group] for group in REMOVED_GROUPS)


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_map(blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0r: {counts}, {digest}"
        )

    groups_before = door_group_counts(blocks)
    if any(groups_before[group] != 1 for group in REMOVED_GROUPS):
        raise ValueError(
            "Las hojas laterales no coinciden con los cuatro grupos esperados"
        )

    kept = []
    removed = []
    for thing in blocks["thing"]:
        if (
            integer(thing, "type") == 18025
            and integer(thing, "arg0") in REMOVED_GROUPS
        ):
            removed.append(thing)
        else:
            kept.append(thing)
    if len(removed) != 4:
        raise ValueError(f"Se iban a retirar {len(removed)} Things, no cuatro")
    blocks["thing"] = kept

    validate_map(blocks)
    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: cuatro hojas laterales redundantes retiradas"
        if changed
        else "MAP01: hojas laterales redundantes ya ausentes"
    )
