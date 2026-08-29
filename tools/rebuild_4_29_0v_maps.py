"""Corrige la losa superior y añade el portón occidental de MAP01.

La entrada autorizada es exclusivamente MAP01 de 4.29.0u. El cambio
convierte en losa completa las ocho juntas y los cuatro descansos que habían
quedado sólo con cubierta, sin cerrar los veinticuatro sectores reales de las
escaleras. También instala dos hojas correderas de 64 MU en el vano occidental
del piso superior, con un grupo independiente del acceso de planta baja.
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
    make_door,
    validate_connections,
    validate_dividers,
    validate_landings,
    validate_references,
)
from rebuild_4_29_0u_maps import validate_closed_sector


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

BASE_SHA256 = "cd5db426b51570a2a4715223cd0a6bb8afb9373192b67d64fe7263371bcf7d9b"
BASE_COUNTS = (516, 690, 1350, 146, 218)
UPDATED_SHA256 = "cd285dcebe7b92245ec42851ef988fe35849e0be7d0d1f618682b117dbb4c70d"
UPDATED_COUNTS = (516, 690, 1350, 146, 220)

FLOOR_ROOF_TAG = 510
ROOF_ONLY_TAG = 515
UPPER_GATE_GROUP = 912

# Son los doce sectores nuevos que las capturas de prueba mostraron sin losa.
# Los sectores 1..24 de las escaleras no figuran aquí y siguen abiertos.
SLAB_REPAIR_RECTANGLES = (
    (-25.0, 96.0, -24.0, 192.0),
    (95.0, 96.0, 96.0, 192.0),
    (640.0, 96.0, 641.0, 192.0),
    (760.0, 96.0, 761.0, 192.0),
    (-25.0, -192.0, -24.0, -96.0),
    (95.0, -192.0, 96.0, -96.0),
    (640.0, -192.0, 641.0, -96.0),
    (760.0, -192.0, 761.0, -96.0),
    (-24.0, 272.0, 95.0, 391.0),
    (641.0, 272.0, 760.0, 391.0),
    (-24.0, -391.0, 95.0, -272.0),
    (641.0, -391.0, 760.0, -272.0),
)

UPPER_GATE = (
    (-469.0, -32.0, UPPER_GATE_GROUP, -1),
    (-469.0, 32.0, UPPER_GATE_GROUP, 1),
)


def line_sector_indices(blocks, line) -> set[int]:
    return {
        integer(blocks["sidedef"][integer(line, side_name)], "sector")
        for side_name in ("sidefront", "sideback")
        if side_name in line
    }


def sector_bounds(blocks, sector_index: int) -> tuple[float, float, float, float]:
    points: set[tuple[float, float]] = set()
    for line in blocks["linedef"]:
        if sector_index not in line_sector_indices(blocks, line):
            continue
        for vertex_name in ("v1", "v2"):
            vertex = blocks["vertex"][integer(line, vertex_name)]
            points.add((float(vertex["x"]), float(vertex["y"])))
    if not points:
        raise ValueError(f"El sector {sector_index} no tiene contorno")
    x_values = [point[0] for point in points]
    y_values = [point[1] for point in points]
    return min(x_values), min(y_values), max(x_values), max(y_values)


def door_group_counts(blocks) -> Counter[int]:
    return Counter(
        integer(thing, "arg0")
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
    )


def repaired_sector_indices(blocks) -> list[int]:
    by_bounds = {
        sector_bounds(blocks, index): index
        for index, sector in enumerate(blocks["sector"])
        if integer(sector, "id") in (FLOOR_ROOF_TAG, ROOF_ONLY_TAG)
    }
    missing = [bounds for bounds in SLAB_REPAIR_RECTANGLES if bounds not in by_bounds]
    if missing:
        raise ValueError(f"No se encontraron las celdas de losa: {missing}")
    return [by_bounds[bounds] for bounds in SLAB_REPAIR_RECTANGLES]


def validate_upper_gate(blocks) -> None:
    matches = [
        thing
        for thing in blocks["thing"]
        if integer(thing, "type") == 18025
        and integer(thing, "arg0") == UPPER_GATE_GROUP
    ]
    if len(matches) != 2:
        raise ValueError(f"El portón 912 tiene {len(matches)} hojas, no 2")

    actual = {
        (
            float(thing["x"]),
            float(thing["y"]),
            float(thing["height"]),
            integer(thing, "angle"),
            integer(thing, "arg1"),
            integer(thing, "arg2"),
        )
        for thing in matches
    }
    expected = {
        (-469.0, -32.0, 136.0, 0, -1, 1),
        (-469.0, 32.0, 136.0, 0, 1, 1),
    }
    if actual != expected:
        raise ValueError(f"Configuración inesperada del portón 912: {actual}")


def validate_updated_map(path: Path, blocks) -> None:
    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    if counts != UPDATED_COUNTS:
        raise ValueError(f"Estructura 4.29.0v inesperada: {counts}")

    identifiers = [integer(sector, "id") for sector in blocks["sector"]]
    expected_targets = {510: 63, 511: 11, 514: 1, 515: 24}
    for tag, expected in expected_targets.items():
        if identifiers.count(tag) != expected:
            raise ValueError(
                f"Sectores objetivo del tag {tag}: {identifiers.count(tag)}, "
                f"esperados {expected}"
            )

    for sector_index in repaired_sector_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != FLOOR_ROOF_TAG:
            raise ValueError(f"La celda {sector_index} no recibió losa completa")
        validate_closed_sector(blocks, sector_index)

    # Las escaleras verdaderas conservan sólo el techo y no se cierran.
    for sector_index in range(1, 25):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La escalera {sector_index} perdió su hueco abierto")

    groups = door_group_counts(blocks)
    for group in (902, 905, 906, 907, 908, 909, 910, 911):
        if groups[group] != (2 if group in (910, 911) else 1):
            raise ValueError(f"Cantidad inesperada de hojas para la puerta {group}")
    if groups[UPPER_GATE_GROUP] != 2:
        raise ValueError("El portón superior no conserva sus dos hojas")
    validate_upper_gate(blocks)

    validate_references(blocks)
    validate_connections(blocks)
    validate_dividers(blocks)
    validate_landings(blocks)

    digest = sha256(path.read_bytes()).hexdigest()
    if UPDATED_SHA256 and digest != UPDATED_SHA256:
        raise ValueError(f"Hash 4.29.0v inesperado: {digest}")


def is_updated(blocks) -> bool:
    groups = door_group_counts(blocks)
    repairs = repaired_sector_indices(blocks)
    return (
        groups[UPPER_GATE_GROUP] == 2
        and all(
            integer(blocks["sector"][index], "id") == FLOOR_ROOF_TAG
            for index in repairs
        )
    )


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    if is_updated(blocks):
        validate_updated_map(path, blocks)
        return False

    counts = tuple(
        len(blocks[key])
        for key in ("vertex", "linedef", "sidedef", "sector", "thing")
    )
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != BASE_COUNTS or digest != BASE_SHA256:
        raise ValueError(
            f"MAP01 no coincide con la base aceptada 4.29.0u: {counts}, {digest}"
        )

    for sector_index in repaired_sector_indices(blocks):
        if integer(blocks["sector"][sector_index], "id") != ROOF_ONLY_TAG:
            raise ValueError(f"La celda {sector_index} no conserva el tag 515 de 0u")
        blocks["sector"][sector_index]["id"] = str(FLOOR_ROOF_TAG)

    blocks["thing"].extend(
        make_door(x, y, group, direction)
        for x, y, group, direction in UPPER_GATE
    )

    lumps[text_index] = (
        b"TEXTMAP",
        render_textmap(header, blocks).encode("utf-8"),
    )
    write_wad(path, signature, lumps)

    _, written_lumps = read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = parse_textmap(written_text.decode("utf-8"))
    validate_updated_map(path, written_blocks)
    return True


if __name__ == "__main__":
    changed = rebuild_map01()
    print(
        "MAP01: portón superior y losas 4.29.0v aplicados"
        if changed
        else "MAP01: portón superior y losas 4.29.0v ya presentes"
    )
