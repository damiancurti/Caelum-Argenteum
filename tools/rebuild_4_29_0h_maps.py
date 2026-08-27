"""Normaliza la orientación de las habitaciones centrales de MAP01.

V4.29.0g creó contornos cerrados, pero varios sidedefs quedaron asignados al
lado geométrico opuesto de sus líneas. GZDoom podía interpretar el sector 510
fuera de la habitación y, por tanto, no dibujar su losa 3D 128--136. Este
script no agrega superficies: vuelve canónicos los cuatro lados del contorno
exterior y los cuatro del interior de cada módulo.
"""

from __future__ import annotations

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
ROOMS = (
    (192.0, 192.0, 544.0, 544.0),
    (192.0, -544.0, 544.0, -192.0),
)


def sector_id(blocks, side_index: int) -> int:
    sector_index = integer(blocks["sidedef"][side_index], "sector")
    return integer(blocks["sector"][sector_index], "id")


def canonical_edges(box, inset: float):
    minimum_x, minimum_y, maximum_x, maximum_y = box
    bl = (minimum_x + inset, minimum_y + inset)
    tl = (minimum_x + inset, maximum_y - inset)
    tr = (maximum_x - inset, maximum_y - inset)
    br = (maximum_x - inset, minimum_y + inset)
    # Sentido horario: el sector frontal queda siempre a la derecha.
    return ((bl, tl), (tl, tr), (tr, br), (br, bl))


def normalize_edge(blocks, positions, start, end, front_id, back_id) -> bool:
    expected = {start, end}
    matches = []
    for index, line in enumerate(blocks["linedef"]):
        current = {
            positions[integer(line, "v1")],
            positions[integer(line, "v2")],
        }
        if current == expected:
            matches.append((index, line))
    if len(matches) != 1:
        raise ValueError(
            f"Arista {start}->{end}: se esperaba una línea y se hallaron "
            f"{len(matches)}"
        )

    _, line = matches[0]
    if "sideback" not in line:
        raise ValueError(f"La arista {start}->{end} no es bilateral")

    sides = (integer(line, "sidefront"), integer(line, "sideback"))
    front_matches = [side for side in sides if sector_id(blocks, side) == front_id]
    back_matches = [side for side in sides if sector_id(blocks, side) == back_id]
    if len(front_matches) != 1 or len(back_matches) != 1:
        raise ValueError(
            f"Arista {start}->{end}: sectores {front_id}/{back_id} inválidos"
        )

    vertex_lookup = {position: index for index, position in enumerate(positions)}
    desired = (
        vertex_lookup[start],
        vertex_lookup[end],
        front_matches[0],
        back_matches[0],
    )
    current = (
        integer(line, "v1"),
        integer(line, "v2"),
        integer(line, "sidefront"),
        integer(line, "sideback"),
    )
    if current == desired:
        return False
    line["v1"] = str(desired[0])
    line["v2"] = str(desired[1])
    line["sidefront"] = str(desired[2])
    line["sideback"] = str(desired[3])
    line["twosided"] = "true"
    return True


def rebuild_map01() -> int:
    signature, lumps = read_wad(MAP01)
    text_index = next(i for i, (name, _) in enumerate(lumps) if name == b"TEXTMAP")
    header, blocks = parse_textmap(lumps[text_index][1].decode("utf-8"))
    if tuple(len(blocks[key]) for key in ("vertex", "linedef", "sidedef", "sector")) != (
        382,
        473,
        916,
        99,
    ):
        raise ValueError("MAP01 no coincide con la base estructural 4.29.0g")

    positions = [
        (float(vertex["x"]), float(vertex["y"]))
        for vertex in blocks["vertex"]
    ]
    changed = 0
    for box in ROOMS:
        for start, end in canonical_edges(box, 0.0):
            changed += normalize_edge(blocks, positions, start, end, 511, 100)
        for start, end in canonical_edges(box, 8.0):
            changed += normalize_edge(blocks, positions, start, end, 510, 511)

    # Deben existir exactamente dos controles inferiores y superiores del
    # interior, y un único control de pared, todos heredados y sin duplicar.
    controls = [
        line for line in blocks["linedef"]
        if integer(line, "special") == 160
        and integer(line, "arg0") in (510, 511)
    ]
    if [integer(line, "arg0") for line in controls].count(510) != 2:
        raise ValueError("Los controles de losa 510 no son exactamente dos")
    if [integer(line, "arg0") for line in controls].count(511) != 1:
        raise ValueError("El control de pared 511 no es único")

    if changed:
        rebuilt = render_textmap(header, blocks).encode("utf-8")
        lumps[text_index] = (b"TEXTMAP", rebuilt)
        write_wad(MAP01, signature, lumps)
    return changed


def main() -> None:
    changed = rebuild_map01()
    print(f"MAP01: {changed} aristas normalizadas")


if __name__ == "__main__":
    main()
