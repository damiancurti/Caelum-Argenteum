"""Sustituye los últimos paneles finos de la mansión por muros de 8 MU.

MAP01 parte exclusivamente del candidato 4.30.0a. La operación convierte los
31 ``midtex3d`` CMIN01 que aún delimitaban la mansión principal en volúmenes
reales de planta baja (z=0..128). Las aberturas, puertas, suministros de prueba,
primer y segundo piso permanecen intactos. El edificio aislado occidental y
MAP02 no se modifican.
"""

from __future__ import annotations

from collections import OrderedDict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ap_maps as ap
import rebuild_4_29_0ar_maps as ar
import rebuild_4_29_0bc_maps as architecture
import rebuild_4_30_0a_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"
AO = previous.AO

MANSION_WALL = '"CMIN01"'
EMPTY_TEXTURE = '"-"'
LOWER_WALL_RANGE = (0, 128, MANSION_WALL, MANSION_WALL)
PROFILE_TAG_START = 930
PROFILE_TAG_END = 980
CONTROL_SLOT = 950

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1419,
    1983,
    3544,
    635,
    322,
)
MAP01_UPDATED_SHA256: str | None = (
    "ebc4c8aa654bdfc7c3ccd4eb60a8aa9bc4a745f85715189325612cf7bdec6f90"
)
MAP01_THINGS_SHA256 = previous.MAP01_THINGS_SHA256
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256


def normalized_segment(x0: float, y0: float, x1: float, y1: float):
    return tuple(sorted(((float(x0), float(y0)), (float(x1), float(y1)))))


# Segmentos exactos presentes en 4.30.0a. La lista explícita evita convertir
# por accidente el acceso SW1EXIT del edificio de pruebas situado al oeste.
TARGET_SEGMENTS = tuple(
    normalized_segment(*segment)
    for segment in (
        (-569, 96, -569, 640),
        (-569, 640, -25, 640),
        (-32, 96, -25, 96),
        (-465, 96, -377, 96),
        (96, 640, 640, 640),
        (633, 96, 640, 96),
        (103, 96, 288, 96),
        (-569, -640, -25, -640),
        (-569, -640, -569, -96),
        (-569, -96, -473, -96),
        (-217, -96, -32, -96),
        (96, -640, 640, -640),
        (96, -96, 103, -96),
        (448, -96, 633, -96),
        (761, 640, 1305, 640),
        (768, 96, 953, 96),
        (761, -640, 1305, -640),
        (761, -96, 768, -96),
        (1113, -96, 1201, -96),
        (-473, -96, -465, -96),
        (-465, -96, -377, -96),
        (-473, 96, -465, 96),
        (-569, 96, -473, 96),
        (-32, -96, -25, -96),
        (103, -96, 288, -96),
        (633, -96, 640, -96),
        (768, -96, 953, -96),
        (-217, 96, -32, 96),
        (96, 96, 103, 96),
        (448, 96, 633, 96),
        (761, 96, 768, 96),
    )
)


def line_segment(blocks, line) -> tuple[tuple[float, float], tuple[float, float]]:
    first = blocks["vertex"][AO.integer(line, "v1")]
    second = blocks["vertex"][AO.integer(line, "v2")]
    return normalized_segment(
        float(first["x"]), float(first["y"]),
        float(second["x"]), float(second["y"]),
    )


def target_line_indices(blocks) -> list[int]:
    by_segment = {segment: [] for segment in TARGET_SEGMENTS}
    for index, line in enumerate(blocks["linedef"]):
        segment = line_segment(blocks, line)
        if segment in by_segment:
            by_segment[segment].append(index)
    failures = {
        segment: indices
        for segment, indices in by_segment.items()
        if len(indices) != 1
    }
    if failures:
        raise ValueError(f"Paneles base no unívocos: {failures}")
    return [by_segment[segment][0] for segment in TARGET_SEGMENTS]


def thin_wall_box(segment):
    (x0, y0), (x1, y1) = segment
    if x0 == x1:
        # La fachada oeste crece hacia el interior de la mansión.
        if x0 != -569.0:
            raise ValueError(f"Panel vertical inesperado: {segment}")
        return (x0, y0, x0 + 8.0, y1)
    if y0 != y1:
        raise ValueError(f"Panel diagonal inesperado: {segment}")
    if y0 == 640.0:
        return (x0, y0 - 8.0, x1, y0)
    if y0 == -640.0:
        return (x0, y0, x1, y0 + 8.0)
    if abs(y0) == 96.0:
        return (x0, y0 - 4.0, x1, y0 + 4.0)
    raise ValueError(f"Panel horizontal inesperado: {segment}")


def merge_wall_boxes(boxes):
    """Devuelve la unión rectangular sin solapamientos."""

    xs = sorted({value for box in boxes for value in (box[0], box[2])})
    ys = sorted({value for box in boxes for value in (box[1], box[3])})
    rows = []
    for y0, y1 in zip(ys, ys[1:]):
        cells = []
        for x0, x1 in zip(xs, xs[1:]):
            cx = (x0 + x1) * 0.5
            cy = (y0 + y1) * 0.5
            if any(
                bx0 < cx < bx1 and by0 < cy < by1
                for bx0, by0, bx1, by1 in boxes
            ):
                cells.append((x0, x1))
        if not cells:
            continue
        start, end = cells[0]
        for x0, x1 in cells[1:]:
            if x0 == end:
                end = x1
            else:
                rows.append((start, y0, end, y1))
                start, end = x0, x1
        rows.append((start, y0, end, y1))

    columns: dict[tuple[float, float], list[tuple[float, float, float, float]]] = {}
    for rectangle in rows:
        columns.setdefault((rectangle[0], rectangle[2]), []).append(rectangle)
    merged = []
    for rectangles in columns.values():
        rectangles.sort(key=lambda rectangle: rectangle[1])
        current = list(rectangles[0])
        for rectangle in rectangles[1:]:
            if rectangle[1] == current[3]:
                current[3] = rectangle[3]
            else:
                merged.append(tuple(current))
                current = list(rectangle)
        merged.append(tuple(current))
    return sorted(merged)


WALL_BOXES = tuple(thin_wall_box(segment) for segment in TARGET_SEGMENTS)
WALL_AREAS = tuple(merge_wall_boxes(WALL_BOXES))


def clear_thin_walls(blocks) -> None:
    for line_index in target_line_indices(blocks):
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") != "true":
            raise ValueError(f"La línea {line_index} no era un panel 3D")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Textura base inesperada en línea {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
        line.pop("midtex3d")


def profiled_wall_rectangles(blocks):
    rectangles = []
    for index, bounds in enumerate(WALL_AREAS):
        rectangles.extend(
            AO.rectangular_area_rectangles(
                blocks, bounds, f"muro_fino_{index}"
            )
        )
    return rectangles


def upper_signature(blocks):
    AO._PHYSICAL_CACHE_BLOCKS = None
    signature = []
    for index, (x0, y0, x1, y1) in enumerate(WALL_AREAS):
        # Los factores no caen sobre la línea central histórica ni sobre sus
        # cortes de 7/8 MU; physical_sector_at sólo es unívoco en el interior.
        for fx, fy in ((0.23, 0.23), (0.51, 0.51), (0.77, 0.77)):
            x = x0 + (x1 - x0) * fx
            y = y0 + (y1 - y0) * fy
            sector_index = AO.physical_sector_at(blocks, x, y)
            profile = AO.complete_sector_profile(blocks, sector_index)
            upper = tuple(entry for entry in profile if entry[1] > 128)
            signature.append((index, fx, fy, upper))
    return tuple(signature)


def build_thick_walls(blocks) -> None:
    rectangles = profiled_wall_rectangles(blocks)
    AO.carve_profiled_rectangles(
        blocks,
        rectangles,
        (LOWER_WALL_RANGE,),
        PROFILE_TAG_START,
        PROFILE_TAG_END,
        CONTROL_SLOT,
    )


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    sector_index = AO.physical_sector_at(blocks, x, y)
    sector = blocks["sector"][sector_index]
    base_floor = AO.integer(sector, "heightfloor")
    return (base_floor is not None and base_floor >= 128) or AO.profile_covers(
        AO.complete_sector_profile(blocks, sector_index), 0, 128
    )


def validate_thick_walls(blocks) -> None:
    AO._PHYSICAL_CACHE_BLOCKS = None
    for index, (x0, y0, x1, y1) in enumerate(WALL_AREAS):
        for fx, fy in ((0.23, 0.23), (0.51, 0.51), (0.77, 0.77)):
            x = x0 + (x1 - x0) * fx
            y = y0 + (y1 - y0) * fy
            if not ground_barrier_at(blocks, x, y):
                raise ValueError(f"Muro {index} abierto en ({x:g}, {y:g})")

    # Ningún panel del edificio principal debe seguir siendo una superficie
    # sin espesor. Los siete del edificio occidental se conservan a propósito.
    remaining_main = []
    remaining_west = []
    for index, line in enumerate(blocks["linedef"]):
        if line.get("midtex3d") != "true":
            continue
        textures = {
            blocks["sidedef"][AO.integer(line, side_name)].get("texturemiddle")
            for side_name in ("sidefront", "sideback")
            if side_name in line
        }
        if MANSION_WALL not in textures:
            continue
        segment = line_segment(blocks, line)
        minimum_x = min(segment[0][0], segment[1][0])
        if minimum_x > -1000.0:
            remaining_main.append((index, segment))
        else:
            remaining_west.append((index, segment))
    if remaining_main:
        raise ValueError(f"Persisten paneles finos en la mansión: {remaining_main}")
    if len(remaining_west) != 7:
        raise ValueError(
            f"El edificio occidental cambió sus paneles: {len(remaining_west)}"
        )


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = AO.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.30.0b inesperada: {counts}")
    validate_thick_walls(blocks)
    previous.validate_test_pickups(blocks)
    # El tallado subdivide los antiguos sectores 19/22, por lo que sus índices
    # y contornos dejan de ser una identidad estable. La propiedad observable
    # que debe conservarse es el piso interior de madera en ambos puntos.
    AO._PHYSICAL_CACHE_BLOCKS = None
    for x, y in ((1249.0, -597.0), (1262.0, 623.0)):
        sector_index = AO.physical_sector_at(blocks, x, y)
        if blocks["sector"][sector_index].get("texturefloor") != '"CMWD01"':
            raise ValueError(f"Piso interior alterado en ({x:g}, {y:g})")
    architecture.validate_walls(blocks)
    architecture.validate_doors(blocks)
    architecture.validate_references(blocks)
    ar.validate_closed_sector_contours(blocks)
    ap.validate_no_coincident_lines(blocks)
    if AO.digest_json(blocks["thing"]) != MAP01_THINGS_SHA256:
        raise ValueError("Los actores de MAP01 cambiaron")
    if MAP01_UPDATED_SHA256 is not None:
        digest = sha256(path.read_bytes()).hexdigest()
        if digest != MAP01_UPDATED_SHA256:
            raise ValueError(f"Hash MAP01 4.30.0b inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_thick_walls(blocks)
    except ValueError:
        return False
    return True


def rebuild_map01(path: Path = MAP01) -> bool:
    signature, lumps = AO.read_wad(path)
    text_index = next(
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    )
    header, blocks = AO.parse_textmap(lumps[text_index][1].decode("utf-8"))

    if map01_is_updated(blocks):
        validate_map01(path, blocks)
        return False

    counts = AO.map_counts(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.30.0a: "
            f"{counts}, {digest}"
        )
    previous.validate_map01(path, blocks)

    before_upper = upper_signature(blocks)
    clear_thin_walls(blocks)
    build_thick_walls(blocks)
    architecture.remove_degenerate_duplicate_lines(blocks)
    AO._PHYSICAL_CACHE_BLOCKS = None
    if upper_signature(blocks) != before_upper:
        raise ValueError("El engrosado alteró el primer o segundo piso")

    lumps[text_index] = (
        b"TEXTMAP",
        AO.render_textmap(header, blocks).encode("utf-8"),
    )
    AO.write_wad(path, signature, lumps)

    _, written_lumps = AO.read_wad(path)
    written_text = next(
        data for name, data in written_lumps if name == b"TEXTMAP"
    )
    _, written_blocks = AO.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejó de ser byte-idéntico a 4.30.0a")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: 31 paneles de planta baja convertidos en muros de 8 MU"
        if changed
        else "MAP01: muros gruesos 4.30.0b ya presentes"
    )
    print("MAP02: preservado sin cambios")


if __name__ == "__main__":
    main()
