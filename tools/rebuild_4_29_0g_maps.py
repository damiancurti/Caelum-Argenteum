"""Reconstruye las dos habitaciones centrales simples de MAP01 para V4.29.0g.

La geometría defectuosa de V4.29.0c–f se elimina como un bloque completo. Cada
habitación se vuelve a crear siguiendo las dimensiones y los sectores de las
habitaciones sanas de los extremos: un único interior de 336x336 MU rodeado
por una pared continua de 8 MU. Esta etapa no crea puertas ni divisores.
"""

from __future__ import annotations

from collections import OrderedDict
from pathlib import Path

from rebuild_4_29_0f_maps import (
    integer,
    parse_textmap,
    read_wad,
    render_textmap,
    write_wad,
)


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
CENTRAL_ROOMS = (
    (192.0, 192.0, 544.0, 544.0),
    (192.0, -544.0, 544.0, -192.0),
)


def point_in_box(point: tuple[float, float], box: tuple[float, ...]) -> bool:
    x, y = point
    minimum_x, minimum_y, maximum_x, maximum_y = box
    return minimum_x <= x <= maximum_x and minimum_y <= y <= maximum_y


def remove_old_central_geometry(
    blocks: dict[str, list[OrderedDict[str, str]]],
) -> tuple[int, int]:
    vertices = blocks["vertex"]
    lines = blocks["linedef"]
    sides = blocks["sidedef"]
    sectors = blocks["sector"]
    positions = [
        (float(vertex["x"]), float(vertex["y"])) for vertex in vertices
    ]

    removed_lines = {
        index
        for index, line in enumerate(lines)
        if any(
            point_in_box(positions[integer(line, "v1")], box)
            and point_in_box(positions[integer(line, "v2")], box)
            for box in CENTRAL_ROOMS
        )
    }
    if len(removed_lines) != 60:
        raise ValueError(
            "MAP01 no conserva las 60 líneas centrales defectuosas esperadas: "
            f"se encontraron {len(removed_lines)}"
        )

    removed_sides = {
        integer(lines[index], side_name)
        for index in removed_lines
        for side_name in ("sidefront", "sideback")
        if side_name in lines[index]
    }
    used_sides_elsewhere = {
        integer(line, side_name)
        for index, line in enumerate(lines)
        if index not in removed_lines
        for side_name in ("sidefront", "sideback")
        if side_name in line
    }
    if removed_sides & used_sides_elsewhere:
        raise ValueError("La geometría central comparte sidedefs con otras habitaciones")

    kept_line_indices = [
        index for index in range(len(lines)) if index not in removed_lines
    ]
    kept_side_indices = [
        index for index in range(len(sides)) if index not in removed_sides
    ]
    side_map = {old: new for new, old in enumerate(kept_side_indices)}

    rebuilt_lines: list[OrderedDict[str, str]] = []
    for old_index in kept_line_indices:
        line = lines[old_index]
        line["sidefront"] = str(side_map[integer(line, "sidefront")])
        if "sideback" in line:
            line["sideback"] = str(side_map[integer(line, "sideback")])
        rebuilt_lines.append(line)
    blocks["linedef"] = rebuilt_lines
    blocks["sidedef"] = [sides[index] for index in kept_side_indices]

    used_vertices = {
        integer(line, vertex_name)
        for line in blocks["linedef"]
        for vertex_name in ("v1", "v2")
    }
    kept_vertex_indices = [
        index for index in range(len(vertices)) if index in used_vertices
    ]
    vertex_map = {old: new for new, old in enumerate(kept_vertex_indices)}
    for line in blocks["linedef"]:
        line["v1"] = str(vertex_map[integer(line, "v1")])
        line["v2"] = str(vertex_map[integer(line, "v2")])
    blocks["vertex"] = [vertices[index] for index in kept_vertex_indices]

    used_sectors = {integer(side, "sector") for side in blocks["sidedef"]}
    kept_sector_indices = [
        index for index in range(len(sectors)) if index in used_sectors
    ]
    removed_sector_count = len(sectors) - len(kept_sector_indices)
    if removed_sector_count != 3:
        raise ValueError(
            "La retirada central debía eliminar exactamente tres sectores "
            f"huérfanos; eliminó {removed_sector_count}"
        )
    sector_map = {old: new for new, old in enumerate(kept_sector_indices)}
    for side in blocks["sidedef"]:
        side["sector"] = str(sector_map[integer(side, "sector")])
    blocks["sector"] = [sectors[index] for index in kept_sector_indices]

    return len(removed_lines), removed_sector_count


def make_vertex(x: float, y: float) -> OrderedDict[str, str]:
    return OrderedDict((('x', f'{x:.1f}'), ('y', f'{y:.1f}')))


def make_side(sector: int) -> OrderedDict[str, str]:
    return OrderedDict(
        (
            ("offsetx", "0"),
            ("offsety", "0"),
            ("texturetop", '"CMIN01"'),
            ("texturebottom", '"CMIN01"'),
            ("texturemiddle", '"CMIN01"'),
            ("sector", str(sector)),
        )
    )


def add_two_sided_line(
    blocks: dict[str, list[OrderedDict[str, str]]],
    start: int,
    end: int,
    front_sector: int,
    back_sector: int,
) -> None:
    front = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(front_sector))
    back = len(blocks["sidedef"])
    blocks["sidedef"].append(make_side(back_sector))
    blocks["linedef"].append(
        OrderedDict(
            (
                ("v1", str(start)),
                ("v2", str(end)),
                ("sidefront", str(front)),
                ("sideback", str(back)),
                ("twosided", "true"),
            )
        )
    )


def add_simple_room(
    blocks: dict[str, list[OrderedDict[str, str]]],
    box: tuple[float, float, float, float],
    surrounding_sector: int,
) -> None:
    minimum_x, minimum_y, maximum_x, maximum_y = box
    inner_minimum_x = minimum_x + 8.0
    inner_minimum_y = minimum_y + 8.0
    inner_maximum_x = maximum_x - 8.0
    inner_maximum_y = maximum_y - 8.0

    template = OrderedDict(
        (
            ("heightfloor", "0"),
            ("heightceiling", "30000"),
            ("texturefloor", '"FLOOR0_1"'),
            ("textureceiling", '"F_SKY1"'),
            ("lightlevel", "176"),
        )
    )
    interior_sector = len(blocks["sector"])
    interior = OrderedDict(template)
    interior["id"] = "510"
    blocks["sector"].append(interior)
    wall_sector = len(blocks["sector"])
    wall = OrderedDict(template)
    wall["id"] = "511"
    blocks["sector"].append(wall)

    outer_start = len(blocks["vertex"])
    blocks["vertex"].extend(
        (
            make_vertex(minimum_x, minimum_y),
            make_vertex(maximum_x, minimum_y),
            make_vertex(maximum_x, maximum_y),
            make_vertex(minimum_x, maximum_y),
        )
    )
    inner_start = len(blocks["vertex"])
    blocks["vertex"].extend(
        (
            make_vertex(inner_minimum_x, inner_minimum_y),
            make_vertex(inner_maximum_x, inner_minimum_y),
            make_vertex(inner_maximum_x, inner_maximum_y),
            make_vertex(inner_minimum_x, inner_maximum_y),
        )
    )

    # Contorno exterior: la cara frontal mira hacia el anillo de pared.
    add_two_sided_line(
        blocks, outer_start, outer_start + 1, wall_sector, surrounding_sector
    )
    add_two_sided_line(
        blocks, outer_start + 2, outer_start + 1, wall_sector, surrounding_sector
    )
    add_two_sided_line(
        blocks, outer_start + 2, outer_start + 3, wall_sector, surrounding_sector
    )
    add_two_sided_line(
        blocks, outer_start, outer_start + 3, wall_sector, surrounding_sector
    )

    # Contorno interior: una sola habitación, sin umbrales ni divisores.
    add_two_sided_line(
        blocks, inner_start, inner_start + 1, interior_sector, wall_sector
    )
    add_two_sided_line(
        blocks, inner_start + 1, inner_start + 2, interior_sector, wall_sector
    )
    add_two_sided_line(
        blocks, inner_start + 2, inner_start + 3, interior_sector, wall_sector
    )
    add_two_sided_line(
        blocks, inner_start + 3, inner_start, interior_sector, wall_sector
    )


def find_surrounding_sector(
    blocks: dict[str, list[OrderedDict[str, str]]],
    box: tuple[float, float, float, float],
) -> int:
    positions = [
        (float(vertex["x"]), float(vertex["y"])) for vertex in blocks["vertex"]
    ]
    minimum_x, minimum_y, maximum_x, maximum_y = box
    candidates: dict[int, int] = {}
    for line in blocks["linedef"]:
        start = positions[integer(line, "v1")]
        end = positions[integer(line, "v2")]
        if not (
            minimum_x - 96.0 <= start[0] <= maximum_x + 96.0
            and minimum_y - 96.0 <= start[1] <= maximum_y + 96.0
            and minimum_x - 96.0 <= end[0] <= maximum_x + 96.0
            and minimum_y - 96.0 <= end[1] <= maximum_y + 96.0
        ):
            continue
        for side_name in ("sidefront", "sideback"):
            if side_name not in line:
                continue
            sector = integer(
                blocks["sidedef"][integer(line, side_name)], "sector"
            )
            properties = blocks["sector"][sector]
            if (integer(properties, "id") == 100
                and integer(properties, "heightfloor") == 0):
                candidates[sector] = candidates.get(sector, 0) + 1
    if not candidates:
        raise ValueError(
            f"No se pudo identificar el sector base para {box}"
        )
    # El volumen de la habitación toca muchas más líneas que sus umbrales
    # exteriores de 24 MU. Elegir el candidato con más incidencias evita
    # depender de índices de sector heredados.
    ordered = sorted(candidates.items(), key=lambda item: item[1], reverse=True)
    if len(ordered) > 1 and ordered[0][1] == ordered[1][1]:
        raise ValueError(f"Sectores base ambiguos para {box}: {ordered}")
    return ordered[0][0]


def rebuild_map01() -> bool:
    signature, lumps = read_wad(MAP01)
    text_index = next(i for i, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))

    # Idempotencia: la versión nueva tiene dos contornos de ocho líneas y
    # carece de cualquier vértice central intermedio en X=364/372.
    positions = {
        (float(vertex["x"]), float(vertex["y"])) for vertex in blocks["vertex"]
    }
    if (364.0, 336.0) not in positions and (372.0, 336.0) not in positions:
        # Migración de la primera salida 0g: normaliza la orientación de la
        # arista superior exterior para que su frente permanezca en el anillo.
        corrected = 0
        vertex_positions = [
            (float(vertex["x"]), float(vertex["y"]))
            for vertex in blocks["vertex"]
        ]
        for box in CENTRAL_ROOMS:
            minimum_x, _, maximum_x, maximum_y = box
            for line in blocks["linedef"]:
                start = vertex_positions[integer(line, "v1")]
                end = vertex_positions[integer(line, "v2")]
                if start != (minimum_x, maximum_y) or end != (maximum_x, maximum_y):
                    continue
                front_sector = integer(
                    blocks["sidedef"][integer(line, "sidefront")], "sector"
                )
                back_sector = integer(
                    blocks["sidedef"][integer(line, "sideback")], "sector"
                )
                if (integer(blocks["sector"][front_sector], "id") == 511
                    and integer(blocks["sector"][back_sector], "id") == 100):
                    line["v1"], line["v2"] = line["v2"], line["v1"]
                    corrected += 1
        if corrected == 0:
            return False
        if corrected != 2:
            raise ValueError(
                f"Se esperaban dos aristas superiores para corregir; {corrected}"
            )
        rebuilt = render_textmap(header, blocks).encode("utf-8")
        lumps[text_index] = (b"TEXTMAP", rebuilt)
        write_wad(MAP01, signature, lumps)
        return True

    surrounding = [find_surrounding_sector(blocks, box) for box in CENTRAL_ROOMS]
    remove_old_central_geometry(blocks)
    for box, surrounding_sector in zip(CENTRAL_ROOMS, surrounding):
        add_simple_room(blocks, box, surrounding_sector)

    if (len(blocks["vertex"]), len(blocks["linedef"]), len(blocks["sidedef"]), len(blocks["sector"])) != (
        382,
        473,
        916,
        99,
    ):
        raise ValueError(
            "La reconstrucción no produjo la topología V4.29.0g esperada: "
            f"{len(blocks['vertex'])}/"
            f"{len(blocks['linedef'])}/"
            f"{len(blocks['sidedef'])}/"
            f"{len(blocks['sector'])}"
        )

    rebuilt = render_textmap(header, blocks).encode("utf-8")
    lumps[text_index] = (b"TEXTMAP", rebuilt)
    write_wad(MAP01, signature, lumps)
    return True


def main() -> None:
    changed = rebuild_map01()
    print(f"MAP01: {'reconstruido' if changed else 'ya estaba actualizado'}")


if __name__ == "__main__":
    main()
