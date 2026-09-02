"""Reconstruye las divisiones finales de planta baja para 4.29.0bc.

MAP01 parte exclusivamente del candidato determinista 4.29.0aw. El parche
reproduce el perimetro grueso solicitado despues de 0bb, devuelve la puerta
doble 807 a x=1413 y añade las divisiones simetricas indicadas por coordenadas.
Todos los muros nuevos son volumenes 3D de 8 MU limitados a z=0..128; las
ocupaciones del primer y segundo piso se conservan. MAP02 no cambia.
"""

from __future__ import annotations

from collections import Counter, OrderedDict
from hashlib import sha256
from pathlib import Path

import rebuild_4_29_0ap_maps as ap
import rebuild_4_29_0ar_maps as ar
import rebuild_4_29_0at_maps as historical
import rebuild_4_29_0aw_maps as previous


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"
MAP02 = ROOT / "src/maps/MAP02.wad"

MAP01_BASE_COUNTS = previous.MAP01_UPDATED_COUNTS
MAP01_BASE_SHA256 = previous.MAP01_UPDATED_SHA256
MAP01_UPDATED_COUNTS: tuple[int, int, int, int, int] | None = (
    1299,
    1815,
    3252,
    578,
    231,
)
MAP01_UPDATED_SHA256: str | None = (
    "0c97275c4bd9bd7ca78bf46a89238b03cc9404504d5ed769dd12a59e115fc17d"
)
MAP01_VERTEX_SHA256: str | None = (
    "3140e3497676f1abb99f28c5a08483dd82722a6215060875d8f316138c79ecbd"
)
MAP01_LINEDEF_SHA256: str | None = (
    "afd2786a8b4d8b1e5348f12933daa67133a682a8bf55387354092d8275f74f58"
)
MAP01_SIDEDEF_SHA256: str | None = (
    "facd1cdbff42edfa8dc04da1011c7b1504ff26bff0820bc1af17f670156e68a1"
)
MAP01_SECTOR_SHA256: str | None = (
    "3da3a54fab5b4eef6f6b646c5553d8b637375860c262a1cc2de2ccf6b5214e32"
)
MAP01_THINGS_SHA256: str | None = (
    "6fdd07b1dd6eb8a89583dcf2f5f6bcb7d30bc66694e0c6bdd9424924e474e82c"
)

MAP02_UPDATED_COUNTS = previous.MAP02_UPDATED_COUNTS
MAP02_UPDATED_SHA256 = previous.MAP02_UPDATED_SHA256

AO = previous.AO
MANSION_WALL = previous.MANSION_WALL
EMPTY_TEXTURE = previous.EMPTY_TEXTURE
LOWER_WALL_RANGE = (0, 128, MANSION_WALL, MANSION_WALL)
PROFILE_TAG_START = 630
PROFILE_TAG_END = 700
CONTROL_SLOT = 800

# El perfil 622 de 0aw contenia una L norte provisional. Solo se conservan
# los cuatro paños gruesos entre la puerta 804 y el arranque de la escalera.
PRESERVED_622_BOUNDS = {
    (1113.0, 72.0, 1201.0, 96.0),
    (1201.0, 72.0, 1209.0, 96.0),
    (1209.0, 72.0, 1305.0, 96.0),
    (1305.0, 72.0, 1306.0, 96.0),
}
EXPECTED_REMOVED_622_SECTORS = 7

# Cada entrada es nombre, limites y cantidad de rectangulos anfitriones
# esperada. Los limites no se superponen: comparten solamente sus bordes.
WALL_AREAS = (
    ("perimetro_retorno_sur", (1305.0, -640.0, 1314.0, -391.0), 1),
    ("perimetro_retorno_norte", (1305.0, 391.0, 1314.0, 640.0), 1),
    ("perimetro_sur", (1305.0, -391.0, 1969.0, -383.0), 5),
    ("perimetro_norte", (1305.0, 383.0, 1969.0, 391.0), 5),
    ("perimetro_este", (1961.0, -383.0, 1969.0, 383.0), 3),
    ("base_escalera_sur", (1113.0, -96.0, 1306.0, -72.0), 4),
    ("lateral_fondo_sur_1", (1306.0, -383.0, 1314.0, -368.0), 1),
    ("lateral_fondo_sur_2", (1306.0, -304.0, 1314.0, -96.0), 9),
    ("lateral_fondo_norte_1", (1306.0, 96.0, 1314.0, 304.0), 9),
    ("lateral_fondo_norte_2", (1306.0, 368.0, 1314.0, 383.0), 1),
    ("puerta_fondo_sur", (1425.0, -272.0, 1433.0, -80.0), 1),
    ("puerta_fondo_norte", (1425.0, 80.0, 1433.0, 272.0), 1),
    ("jamba_fondo_sur", (1401.0, -80.0, 1425.0, -64.0), 1),
    ("jamba_fondo_norte", (1401.0, 64.0, 1425.0, 80.0), 1),
    ("ala_oeste_sur_exterior", (32.0, -640.0, 40.0, -488.0), 4),
    ("ala_oeste_sur_interior", (32.0, -424.0, 40.0, -272.0), 4),
    ("ala_este_sur_exterior", (696.0, -640.0, 704.0, -488.0), 4),
    ("ala_este_sur_interior", (696.0, -424.0, 704.0, -272.0), 4),
    ("ala_oeste_norte_interior", (32.0, 272.0, 40.0, 424.0), 4),
    ("ala_oeste_norte_exterior", (32.0, 488.0, 40.0, 640.0), 4),
    ("ala_este_norte_interior", (696.0, 272.0, 704.0, 424.0), 4),
    ("ala_este_norte_exterior", (696.0, 488.0, 704.0, 640.0), 4),
    ("escalera_oeste_sur_izquierda", (-32.0, -272.0, -24.0, -96.0), 5),
    ("escalera_oeste_sur_derecha", (95.0, -272.0, 103.0, -96.0), 5),
    ("escalera_este_sur_izquierda", (633.0, -272.0, 641.0, -96.0), 5),
    ("escalera_este_sur_derecha", (760.0, -272.0, 768.0, -96.0), 5),
    ("escalera_oeste_norte_izquierda", (-32.0, 96.0, -24.0, 272.0), 5),
    ("escalera_oeste_norte_derecha", (95.0, 96.0, 103.0, 272.0), 5),
    ("escalera_este_norte_izquierda", (633.0, 96.0, 641.0, 272.0), 5),
    ("escalera_este_norte_derecha", (760.0, 96.0, 768.0, 272.0), 5),
)

# Se eliminan las cortinas coplanares que 0bb retiro y los ocho tramos
# interiores que ahora quedan sustituidos por laterales solidos de escalera.
def normalized_segment(x0: float, y0: float, x1: float, y1: float):
    return tuple(sorted(((float(x0), float(y0)), (float(x1), float(y1)))))


CURTAIN_SEGMENTS = tuple(
    normalized_segment(x0, y0, x1, y1)
    for x, spans in (
        (-25.0, ((96, 192), (192, 200), (200, 383), (383, 391),
                  (-96, -192), (-192, -200), (-200, -383), (-383, -391))),
        (96.0, ((96, 192), (192, 200), (200, 383), (383, 391),
                (-96, -192), (-192, -200), (-200, -383), (-383, -391))),
        (640.0, ((96, 192), (192, 200), (200, 383), (383, 391),
                 (-96, -192), (-192, -200), (-200, -383), (-383, -391))),
        (761.0, ((96, 192), (192, 200), (200, 383), (383, 391),
                 (-96, -192), (-192, -200), (-200, -383), (-383, -391))),
    )
    for y0, y1 in spans
    for x0, x1 in ((x, x),)
)
EXPECTED_CURTAIN_LINES = 32

CENTRAL_DOOR_GROUP = 807
NEW_DOOR_SPECS = (
    # x, y, grupo, desplazamiento de apertura
    (1310.0, -336.0, 916, -1),
    (1310.0, 336.0, 917, 1),
    (36.0, -456.0, 918, -1),
    (700.0, -456.0, 919, -1),
    (36.0, 456.0, 920, 1),
    (700.0, 456.0, 921, 1),
)


def remove_sector_tag(sector: OrderedDict, tag: int) -> None:
    """Retira un ID UDMF sin alterar los demas perfiles del sector."""

    tags = [value for value in AO.sector_tags(sector) if value != tag]
    primary = AO.integer(sector, "id")
    if primary == tag:
        if tags:
            sector["id"] = str(tags.pop(0))
        else:
            sector.pop("id", None)
    additional = [value for value in tags if value != AO.integer(sector, "id")]
    if additional:
        sector["moreids"] = '"' + " ".join(map(str, additional)) + '"'
    else:
        sector.pop("moreids", None)


def remove_provisional_north_wall(blocks) -> None:
    """Retira solo la L inferior de 0aw y conserva el muro de la escalera."""

    removed = 0
    for index, sector in enumerate(blocks["sector"]):
        if previous.LOWER_WALL_TAG not in AO.sector_tags(sector):
            continue
        bounds = AO.optional_sector_bounds(blocks, index)
        if bounds in PRESERVED_622_BOUNDS:
            continue
        remove_sector_tag(sector, previous.LOWER_WALL_TAG)
        removed += 1
    if removed != EXPECTED_REMOVED_622_SECTORS:
        raise ValueError(
            f"Sectores retirados de la L norte: {removed}, "
            f"esperados {EXPECTED_REMOVED_622_SECTORS}"
        )


def lines_for_segments(blocks, segments) -> list[int]:
    """Resuelve una linedef unica por cada segmento normalizado."""

    by_segment = {segment: [] for segment in segments}
    for index, line in enumerate(blocks["linedef"]):
        first = blocks["vertex"][AO.integer(line, "v1")]
        second = blocks["vertex"][AO.integer(line, "v2")]
        segment = normalized_segment(
            float(first["x"]),
            float(first["y"]),
            float(second["x"]),
            float(second["y"]),
        )
        if segment in by_segment:
            by_segment[segment].append(index)
    failures = {
        segment: indices
        for segment, indices in by_segment.items()
        if len(indices) != 1
    }
    if failures:
        raise ValueError(f"Cortinas no univocas: {failures}")
    return [by_segment[segment][0] for segment in segments]


def clear_replaced_curtains(blocks) -> None:
    """Quita los paneles finos que quedan dentro de los muros nuevos."""

    line_indices = lines_for_segments(blocks, CURTAIN_SEGMENTS)
    if len(line_indices) != EXPECTED_CURTAIN_LINES:
        raise ValueError(f"Cantidad de cortinas inesperada: {len(line_indices)}")
    cleared_sides = 0
    for line_index in line_indices:
        line = blocks["linedef"][line_index]
        if line.get("midtex3d") != "true":
            raise ValueError(f"La linea {line_index} no era una cortina 3D")
        for side_name in ("sidefront", "sideback"):
            side = blocks["sidedef"][AO.integer(line, side_name)]
            if side.get("texturemiddle") != MANSION_WALL:
                raise ValueError(f"Textura inesperada en cortina {line_index}")
            side["texturemiddle"] = EMPTY_TEXTURE
            cleared_sides += 1
        line.pop("midtex3d")
    if cleared_sides != EXPECTED_CURTAIN_LINES * 2:
        raise ValueError(f"Lados limpiados inesperados: {cleared_sides}")


def wall_rectangles(blocks):
    rectangles = []
    for name, bounds, expected_count in WALL_AREAS:
        rectangles.extend(
            AO.rectangular_area_rectangles(
                blocks,
                bounds,
                name,
                expected_count,
            )
        )
    return rectangles


def upper_sample_signature(blocks):
    """Muestrea la ocupacion superior en todos los paños que se tallaran."""

    bands = ((128, 136), (136, 256), (256, 264), (264, 392), (392, 400))
    samples = []
    AO._PHYSICAL_CACHE_BLOCKS = None
    for name, (x0, y0, x1, y1), _ in WALL_AREAS:
        for fx, fy in ((0.25, 0.25), (0.5, 0.5), (0.75, 0.75)):
            x = x0 + (x1 - x0) * fx
            y = y0 + (y1 - y0) * fy
            sector_index = AO.physical_sector_at(blocks, x, y)
            sector = blocks["sector"][sector_index]
            base_floor = AO.integer(sector, "heightfloor")
            profile = AO.complete_sector_profile(blocks, sector_index)
            occupancy = tuple(
                (base_floor is not None and base_floor >= ceiling)
                or AO.profile_covers(profile, floor, ceiling)
                for floor, ceiling in bands
            )
            samples.append((name, fx, fy, occupancy))
    return tuple(samples)


def build_walls(blocks) -> list[int]:
    """Talla todos los paños con perfiles completos y agrega z=0..128."""

    rectangles = wall_rectangles(blocks)
    expected_total = sum(spec[2] for spec in WALL_AREAS)
    if len(rectangles) != expected_total:
        raise ValueError(
            f"Subdivisiones de muros: {len(rectangles)}, esperadas {expected_total}"
        )
    _, targets = AO.carve_profiled_rectangles(
        blocks,
        rectangles,
        (LOWER_WALL_RANGE,),
        PROFILE_TAG_START,
        PROFILE_TAG_END,
        CONTROL_SLOT,
    )
    return targets


def remove_degenerate_duplicate_lines(blocks) -> None:
    """Retira bordes neutros duplicados al tallar sobre sectores superpuestos."""

    by_edge: dict[tuple, list[int]] = {}
    for index, line in enumerate(blocks["linedef"]):
        first = blocks["vertex"][AO.integer(line, "v1")]
        second = blocks["vertex"][AO.integer(line, "v2")]
        edge = tuple(sorted((
            (float(first["x"]), float(first["y"])),
            (float(second["x"]), float(second["y"])),
        )))
        by_edge.setdefault(edge, []).append(index)

    removed = set()
    for edge, indices in by_edge.items():
        if len(indices) == 1:
            continue
        neutral = []
        for index in indices:
            line = blocks["linedef"][index]
            if "sidefront" not in line or "sideback" not in line:
                continue
            front = AO.integer(
                blocks["sidedef"][AO.integer(line, "sidefront")],
                "sector",
            )
            back = AO.integer(
                blocks["sidedef"][AO.integer(line, "sideback")],
                "sector",
            )
            if front == back:
                neutral.append(index)
        if len(indices) != 2 or len(neutral) != 1:
            raise ValueError(f"Borde duplicado no neutral en {edge}: {indices}")
        removed.add(neutral[0])

    blocks["linedef"] = [
        line for index, line in enumerate(blocks["linedef"])
        if index not in removed
    ]

    # Cada linedef posee sus sidedefs en exclusiva. Al retirar una linea se
    # compacta la tabla y se remapean todas las referencias para no dejar
    # entradas huerfanas que GZDoom o el constructor rechacen.
    used_sides = sorted({
        AO.integer(line, side_name)
        for line in blocks["linedef"]
        for side_name in ("sidefront", "sideback")
        if side_name in line
    })
    side_mapping = {
        old_index: new_index for new_index, old_index in enumerate(used_sides)
    }
    for line in blocks["linedef"]:
        for side_name in ("sidefront", "sideback"):
            if side_name in line:
                line[side_name] = str(side_mapping[AO.integer(line, side_name)])
    blocks["sidedef"] = [blocks["sidedef"][index] for index in used_sides]


def make_single_door(x: float, y: float, group: int, direction: int):
    door = OrderedDict(historical.REAR_DOOR_THINGS[0])
    door["x"] = f"{x:.1f}"
    door["y"] = f"{y:.1f}"
    door["height"] = "0.0"
    door["angle"] = "0"
    door["arg0"] = str(group)
    door["arg1"] = str(direction)
    door["arg2"] = "1"
    door["arg3"] = "0"
    return door


def add_ground_doors(blocks) -> None:
    """Restaura 807 y agrega seis puertas simples con grupos independientes."""

    reserved_groups = {CENTRAL_DOOR_GROUP} | {spec[2] for spec in NEW_DOOR_SPECS}
    existing = [
        thing
        for thing in blocks["thing"]
        if AO.integer(thing, "type") == 18025
        and AO.integer(thing, "arg0") in reserved_groups
    ]
    if existing:
        raise ValueError(f"La base ya contiene puertas reservadas: {len(existing)}")
    blocks["thing"].extend(
        OrderedDict(thing) for thing in historical.REAR_DOOR_THINGS
    )
    blocks["thing"].extend(
        make_single_door(x, y, group, direction)
        for x, y, group, direction in NEW_DOOR_SPECS
    )


def ground_barrier_at(blocks, x: float, y: float) -> bool:
    sector_index = AO.physical_sector_at(blocks, x, y)
    sector = blocks["sector"][sector_index]
    base_floor = AO.integer(sector, "heightfloor")
    if base_floor is not None and base_floor >= 128:
        return True
    return AO.profile_covers(AO.complete_sector_profile(blocks, sector_index), 0, 128)


def validate_curtains(blocks) -> None:
    # El tallado puede subdividir una cortina ya limpiada. Se audita por
    # cobertura geometrica, no por el numero historico de linedef.
    for target in CURTAIN_SEGMENTS:
        (x0, y0), (x1, y1) = target
        if x0 != x1:
            raise ValueError(f"Cortina no vertical inesperada: {target}")
        low, high = sorted((y0, y1))
        intervals = []
        for line_index, line in enumerate(blocks["linedef"]):
            first = blocks["vertex"][AO.integer(line, "v1")]
            second = blocks["vertex"][AO.integer(line, "v2")]
            lx0, ly0 = float(first["x"]), float(first["y"])
            lx1, ly1 = float(second["x"]), float(second["y"])
            if lx0 != x0 or lx1 != x0:
                continue
            line_low, line_high = sorted((ly0, ly1))
            if line_low < low or line_high > high:
                continue
            intervals.append((line_low, line_high, line_index))

        intervals.sort()
        cursor = low
        for line_low, line_high, line_index in intervals:
            if line_low != cursor or line_high <= line_low:
                raise ValueError(f"Cobertura ambigua de cortina {target}: {intervals}")
            line = blocks["linedef"][line_index]
            if line.get("midtex3d") == "true":
                raise ValueError(f"Persiste una cortina fina en linea {line_index}")
            for side_name in ("sidefront", "sideback"):
                if side_name not in line:
                    continue
                side = blocks["sidedef"][AO.integer(line, side_name)]
                if side.get("texturemiddle") != EMPTY_TEXTURE:
                    raise ValueError(f"Persiste textura fina en linea {line_index}")
            cursor = line_high
        if cursor != high:
            raise ValueError(f"Cobertura incompleta de cortina {target}: {intervals}")


def validate_walls(blocks) -> None:
    """Comprueba continuidad de muros, seis huecos y la antigua puerta este."""

    AO._PHYSICAL_CACHE_BLOCKS = None
    for name, (x0, y0, x1, y1), _ in WALL_AREAS:
        for fx, fy in ((0.25, 0.25), (0.5, 0.5), (0.75, 0.75)):
            x = x0 + (x1 - x0) * fx
            y = y0 + (y1 - y0) * fy
            if not ground_barrier_at(blocks, x, y):
                raise ValueError(f"Muro {name} abierto en ({x:g}, {y:g})")

    # Los huecos quedan libres de volumen; la colision pertenece a cada hoja.
    for x, y in ((1413, 0), (1310, -336), (1310, 336),
                 (36, -456), (700, -456), (36, 456), (700, 456)):
        if ground_barrier_at(blocks, x, y):
            raise ValueError(f"El muro cerro la puerta en ({x:g}, {y:g})")
    if not ground_barrier_at(blocks, 1965, 0):
        raise ValueError("La antigua puerta oriental no quedo cerrada")

    # El piso dentro del perimetro conserva madera y no vuelve a ser pasto.
    for x, y in ((1500, 0), (1900, 0), (1500, -300), (1500, 300)):
        sector_index = AO.physical_sector_at(blocks, x, y)
        if blocks["sector"][sector_index].get("texturefloor") != '"CMWD01"':
            raise ValueError(f"Piso interior inesperado en ({x}, {y})")


def validate_doors(blocks) -> None:
    groups = Counter(
        AO.integer(thing, "arg0")
        for thing in blocks["thing"]
        if AO.integer(thing, "type") == 18025
    )
    if groups[CENTRAL_DOOR_GROUP] != 2:
        raise ValueError("La puerta doble 807 no conserva dos hojas")
    for _, _, group, _ in NEW_DOOR_SPECS:
        if groups[group] != 1:
            raise ValueError(f"La puerta simple {group} no conserva una hoja")

    central = sorted(
        (
            (float(thing["x"]), float(thing["y"]), AO.integer(thing, "angle"))
            for thing in blocks["thing"]
            if AO.integer(thing, "type") == 18025
            and AO.integer(thing, "arg0") == CENTRAL_DOOR_GROUP
        ),
        key=lambda item: item[1],
    )
    if central != [(1413.0, -32.0, 0), (1413.0, 32.0, 0)]:
        raise ValueError(f"Puerta 807 desalineada: {central}")
    if any(
        AO.integer(thing, "type") == 18025
        and float(thing["height"]) == 0.0
        and float(thing["x"]) > 1900.0
        for thing in blocks["thing"]
    ):
        raise ValueError("Persiste una puerta inferior en el muro oriental")


def validate_references(blocks) -> None:
    vertex_count = len(blocks["vertex"])
    side_count = len(blocks["sidedef"])
    sector_count = len(blocks["sector"])
    for index, line in enumerate(blocks["linedef"]):
        for field in ("v1", "v2"):
            value = AO.integer(line, field)
            if value is None or not 0 <= value < vertex_count:
                raise ValueError(f"Referencia {field} invalida en linea {index}")
        for field in ("sidefront", "sideback"):
            value = AO.integer(line, field)
            if value is not None and not 0 <= value < side_count:
                raise ValueError(f"Referencia {field} invalida en linea {index}")
    for index, side in enumerate(blocks["sidedef"]):
        sector = AO.integer(side, "sector")
        if sector is None or not 0 <= sector < sector_count:
            raise ValueError(f"Sector invalido en sidedef {index}")


def validate_component_digests(blocks) -> None:
    expected = (
        ("vertices", AO.digest_json(blocks["vertex"]), MAP01_VERTEX_SHA256),
        ("linedefs", AO.digest_json(blocks["linedef"]), MAP01_LINEDEF_SHA256),
        ("sidedefs", AO.digest_json(blocks["sidedef"]), MAP01_SIDEDEF_SHA256),
        ("sectores", AO.digest_json(blocks["sector"]), MAP01_SECTOR_SHA256),
        ("actores", AO.digest_json(blocks["thing"]), MAP01_THINGS_SHA256),
    )
    for name, observed, reference in expected:
        if reference is not None and observed != reference:
            raise ValueError(f"Digest de {name} inesperado: {observed}")


def validate_map01(path: Path, blocks) -> None:
    if MAP01_UPDATED_COUNTS is not None:
        counts = AO.map_counts(blocks)
        if counts != MAP01_UPDATED_COUNTS:
            raise ValueError(f"Estructura MAP01 4.29.0bc inesperada: {counts}")
    validate_curtains(blocks)
    validate_walls(blocks)
    validate_doors(blocks)
    validate_references(blocks)
    ar.validate_closed_sector_contours(blocks)
    ap.validate_no_coincident_lines(blocks)
    validate_component_digests(blocks)
    digest = sha256(path.read_bytes()).hexdigest()
    if MAP01_UPDATED_SHA256 is not None and digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.29.0bc inesperado: {digest}")


def map01_is_updated(blocks) -> bool:
    try:
        validate_curtains(blocks)
        validate_walls(blocks)
        validate_doors(blocks)
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

    digest = sha256(path.read_bytes()).hexdigest()
    counts = AO.map_counts(blocks)
    if counts != MAP01_BASE_COUNTS or digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con la base aceptada 4.29.0aw: "
            f"{counts}, {digest}"
        )

    before_upper = upper_sample_signature(blocks)
    remove_provisional_north_wall(blocks)
    clear_replaced_curtains(blocks)
    build_walls(blocks)
    remove_degenerate_duplicate_lines(blocks)
    add_ground_doors(blocks)
    AO._PHYSICAL_CACHE_BLOCKS = None
    if upper_sample_signature(blocks) != before_upper:
        raise ValueError("La correccion cambio la ocupacion de un piso superior")

    lumps[text_index] = (
        b"TEXTMAP",
        AO.render_textmap(header, blocks).encode("utf-8"),
    )
    AO.write_wad(path, signature, lumps)

    _, written_lumps = AO.read_wad(path)
    written_text = next(data for name, data in written_lumps if name == b"TEXTMAP")
    _, written_blocks = AO.parse_textmap(written_text.decode("utf-8"))
    validate_map01(path, written_blocks)
    return True


def validate_map02(path: Path = MAP02) -> None:
    if sha256(path.read_bytes()).hexdigest() != MAP02_UPDATED_SHA256:
        raise ValueError("MAP02 dejo de ser byte-identico a 4.29.0aw")
    previous.validate_map02(path)


def main() -> None:
    changed = rebuild_map01()
    validate_map02()
    print(
        "MAP01: perimetro, seis accesos simples y puerta 807 reconstruidos"
        if changed
        else "MAP01: arquitectura 4.29.0bc ya presente"
    )
    print("MAP02: candidato 4.29.0aw preservado sin cambios")


if __name__ == "__main__":
    main()
