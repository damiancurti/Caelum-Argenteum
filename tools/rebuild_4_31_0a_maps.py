"""Construye la piscina posterior de MAP01 para Caelum Argenteum 4.31.0a.

La revisión parte exclusivamente del MAP01 aceptado en 4.30.0j. Añade una
terraza formal, un borde de piedra elevado, una piscina de 1280 x 1440 MU,
dieciséis peldaños transitables y un volumen de agua 3D nadable de 256 MU.
No modifica la mansión, las rejas, los actores ni los bloques preexistentes.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path
from typing import Iterable

import rebuild_4_30_0c_maps as base


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

MAP01_4300J_SHA256 = (
    "dc5eb73f7b876d5c70b9b2ae7862ac21c617b2c10ef879d508b89c096281a36e"
)
# Se fija después de la primera reconstrucción determinista y se valida tanto
# al reaplicar como al reconstruir desde una copia limpia de 4.30.0j.
MAP01_4310A_SHA256: str | None = (
    "815f2ed0cd6f52fb03e63eaab3f8b8db560fc9b96c4fbe63a87b1e94e7ef8e60"
)

BASE_COUNTS = (1419, 1983, 3544, 618, 322)
UPDATED_COUNTS = (1469, 2049, 3672, 638, 322)

POOL_MARKER = "// Caelum pool 4.31.0a / generated geometry"
POOL_TAG = 940

TERRACE_BOUNDS = (2072.0, -848.0, 3608.0, 848.0)
RIM_BOUNDS = (2168.0, -752.0, 3512.0, 752.0)
POOL_BOUNDS = (2200.0, -720.0, 3480.0, 720.0)
POOL_DEPTH = -256
RIM_HEIGHT = 8
STAIR_Y_MIN = -256.0
STAIR_Y_MAX = 256.0
STAIR_X = tuple(2200.0 + index * 32.0 for index in range(17))
STAIR_FLOORS = tuple(8 - (index + 1) * 16 for index in range(16))
CONTROL_BOUNDS = (30064.0, 29232.0, 30112.0, 29280.0)


def expected_indexes() -> dict[str, tuple[int, ...]]:
    """Índices canónicos de todos los bloques añadidos."""
    terrace_sector = BASE_COUNTS[3]
    rim_sector = terrace_sector + 1
    basin_sector = rim_sector + 1
    stair_sectors = tuple(basin_sector + 1 + index for index in range(16))
    control_sector = stair_sectors[-1] + 1
    first_line = BASE_COUNTS[1]
    return {
        "terrace": (terrace_sector,),
        "rim": (rim_sector,),
        "basin": (basin_sector,),
        "stairs": stair_sectors,
        "control": (control_sector,),
        "physical_lines": tuple(range(first_line, first_line + 62)),
        "control_lines": tuple(range(first_line + 62, first_line + 66)),
    }


def number(value: float | int) -> str:
    """Devuelve un número UDMF estable y legible."""
    if float(value).is_integer():
        return f"{int(value)}.0"
    return f"{float(value):.6f}".rstrip("0").rstrip(".")


def render_block(kind: str, properties: Iterable[tuple[str, str]]) -> str:
    lines = [kind, "{"]
    lines.extend(f"    {key} = {value};" for key, value in properties)
    lines.append("}")
    return "\n".join(lines)


def vertex_block(point: tuple[float, float]) -> str:
    return render_block(
        "vertex", (("x", number(point[0])), ("y", number(point[1])))
    )


def sector_block(
    floor: int,
    floor_texture: str,
    *,
    light: int = 176,
    sector_id: int | None = None,
    ceiling: int = 30000,
    ceiling_texture: str = "F_SKY1",
    extra: Iterable[tuple[str, str]] = (),
) -> str:
    properties: list[tuple[str, str]] = [
        ("heightfloor", str(floor)),
        ("heightceiling", str(ceiling)),
        ("texturefloor", f'"{floor_texture}"'),
        ("textureceiling", f'"{ceiling_texture}"'),
        ("lightlevel", str(light)),
    ]
    if sector_id is not None:
        properties.append(("id", str(sector_id)))
    properties.extend(extra)
    return render_block("sector", properties)


def sidedef_block(sector: int, texture: str, *, middle: str = "-") -> str:
    return render_block(
        "sidedef",
        (
            ("offsetx", "0"),
            ("offsety", "0"),
            ("texturetop", f'"{texture}"'),
            ("texturebottom", f'"{texture}"'),
            ("texturemiddle", f'"{middle}"'),
            ("sector", str(sector)),
        ),
    )


def pool_additions(
    by_kind: dict[str, list[base.MapBlock]],
) -> tuple[str, dict[str, tuple[int, ...]]]:
    """Genera los bloques y devuelve los índices estructurales esperados."""
    existing_points = {
        (float(vertex.properties["x"]), float(vertex.properties["y"]))
        for vertex in by_kind["vertex"]
    }
    vertex_blocks: list[str] = []
    point_indexes: dict[tuple[float, float], int] = {}

    def add_point(point: tuple[float, float]) -> int:
        if point in existing_points:
            raise ValueError(f"La piscina colisiona con un vértice existente: {point}")
        if point not in point_indexes:
            point_indexes[point] = BASE_COUNTS[0] + len(vertex_blocks)
            vertex_blocks.append(vertex_block(point))
        return point_indexes[point]

    terrace_loop = (
        (TERRACE_BOUNDS[0], TERRACE_BOUNDS[1]),
        (TERRACE_BOUNDS[0], TERRACE_BOUNDS[3]),
        (TERRACE_BOUNDS[2], TERRACE_BOUNDS[3]),
        (TERRACE_BOUNDS[2], TERRACE_BOUNDS[1]),
    )
    rim_loop = (
        (RIM_BOUNDS[0], RIM_BOUNDS[1]),
        (RIM_BOUNDS[0], RIM_BOUNDS[3]),
        (RIM_BOUNDS[2], RIM_BOUNDS[3]),
        (RIM_BOUNDS[2], RIM_BOUNDS[1]),
    )
    pool_corners = (
        (POOL_BOUNDS[0], POOL_BOUNDS[1]),
        (POOL_BOUNDS[0], POOL_BOUNDS[3]),
        (POOL_BOUNDS[2], POOL_BOUNDS[3]),
        (POOL_BOUNDS[2], POOL_BOUNDS[1]),
    )
    control_loop = (
        (CONTROL_BOUNDS[0], CONTROL_BOUNDS[1]),
        (CONTROL_BOUNDS[0], CONTROL_BOUNDS[3]),
        (CONTROL_BOUNDS[2], CONTROL_BOUNDS[3]),
        (CONTROL_BOUNDS[2], CONTROL_BOUNDS[1]),
    )

    # El orden fijo también fija el hash final del WAD.
    for point in terrace_loop + rim_loop + pool_corners:
        add_point(point)
    for x in STAIR_X:
        add_point((x, STAIR_Y_MIN))
        add_point((x, STAIR_Y_MAX))
    for point in control_loop:
        add_point(point)

    indexes = expected_indexes()
    terrace_sector = indexes["terrace"][0]
    rim_sector = indexes["rim"][0]
    basin_sector = indexes["basin"][0]
    stair_sectors = indexes["stairs"]
    control_sector = indexes["control"][0]

    sector_blocks = [
        sector_block(0, "CMTB02", light=180),
        sector_block(RIM_HEIGHT, "CMST03", light=184),
        sector_block(
            POOL_DEPTH, "CMST02", light=164, sector_id=POOL_TAG
        ),
    ]
    sector_blocks.extend(
        sector_block(floor, "CMST02", light=168, sector_id=POOL_TAG)
        for floor in STAIR_FLOORS
    )
    sector_blocks.append(
        sector_block(
            POOL_DEPTH,
            "CAPOOL01",
            light=144,
            ceiling=0,
            ceiling_texture="CAPOOL01",
            extra=(
                ("lightcolor", "0xB8E7F0"),
                ("fadecolor", "0x0B4052"),
                ("fogdensity", "64"),
            ),
        )
    )

    sidedef_blocks: list[str] = []
    linedef_blocks: list[str] = []
    physical_line_indexes: list[int] = []
    control_line_indexes: list[int] = []

    def add_side(sector: int, texture: str, *, middle: str = "-") -> int:
        index = BASE_COUNTS[2] + len(sidedef_blocks)
        sidedef_blocks.append(sidedef_block(sector, texture, middle=middle))
        return index

    def add_two_sided(
        start: tuple[float, float],
        end: tuple[float, float],
        front: int,
        back: int,
        texture: str,
    ) -> int:
        line_index = BASE_COUNTS[1] + len(linedef_blocks)
        front_side = add_side(front, texture)
        back_side = add_side(back, texture)
        linedef_blocks.append(
            render_block(
                "linedef",
                (
                    ("v1", str(add_point(start))),
                    ("v2", str(add_point(end))),
                    ("twosided", "true"),
                    ("sidefront", str(front_side)),
                    ("sideback", str(back_side)),
                ),
            )
        )
        physical_line_indexes.append(line_index)
        return line_index

    def add_loop(
        points: tuple[tuple[float, float], ...],
        front: int,
        back: int,
        texture: str,
    ) -> None:
        for index, start in enumerate(points):
            add_two_sided(
                start,
                points[(index + 1) % len(points)],
                front,
                back,
                texture,
            )

    add_loop(terrace_loop, terrace_sector, 0, "CMST03")
    add_loop(rim_loop, rim_sector, terrace_sector, "CMST03")

    # El perímetro se divide en el acceso central y los tres lados del vaso.
    west_x, south_y, east_x, north_y = POOL_BOUNDS
    add_two_sided(
        (west_x, south_y),
        (west_x, STAIR_Y_MIN),
        basin_sector,
        rim_sector,
        "CMPW01",
    )
    add_two_sided(
        (west_x, STAIR_Y_MIN),
        (west_x, STAIR_Y_MAX),
        stair_sectors[0],
        rim_sector,
        "CMPW01",
    )
    add_two_sided(
        (west_x, STAIR_Y_MAX),
        (west_x, north_y),
        basin_sector,
        rim_sector,
        "CMPW01",
    )
    add_two_sided(
        (west_x, north_y),
        (east_x, north_y),
        basin_sector,
        rim_sector,
        "CMPW01",
    )
    add_two_sided(
        (east_x, north_y),
        (east_x, south_y),
        basin_sector,
        rim_sector,
        "CMPW01",
    )
    add_two_sided(
        (east_x, south_y),
        (west_x, south_y),
        basin_sector,
        rim_sector,
        "CMPW01",
    )

    # Cada peldaño es un rectángulo de 32 x 512 MU y baja 16 MU.
    for index, stair_sector in enumerate(stair_sectors):
        x0, x1 = STAIR_X[index], STAIR_X[index + 1]
        add_two_sided(
            (x0, STAIR_Y_MIN),
            (x1, STAIR_Y_MIN),
            basin_sector,
            stair_sector,
            "CMSP03",
        )
        add_two_sided(
            (x1, STAIR_Y_MAX),
            (x0, STAIR_Y_MAX),
            basin_sector,
            stair_sector,
            "CMSP03",
        )

    for index, x in enumerate(STAIR_X[1:]):
        east_sector = (
            stair_sectors[index + 1]
            if index + 1 < len(stair_sectors)
            else basin_sector
        )
        add_two_sided(
            (x, STAIR_Y_MIN),
            (x, STAIR_Y_MAX),
            east_sector,
            stair_sectors[index],
            "CMSP03",
        )

    # Sector de control externo: su techo forma la superficie a z=0 y el
    # tipo 2 de Sector_Set3DFloor aporta el volumen nadable a todos los
    # sectores con tag 940.
    for index, start in enumerate(control_loop):
        end = control_loop[(index + 1) % len(control_loop)]
        line_index = BASE_COUNTS[1] + len(linedef_blocks)
        side = add_side(control_sector, "CMPW01", middle="CMPW01")
        properties: list[tuple[str, str]] = [
            ("v1", str(add_point(start))),
            ("v2", str(add_point(end))),
            ("sidefront", str(side)),
        ]
        if index == 0:
            properties.extend(
                (
                    ("special", "160"),
                    ("arg0", str(POOL_TAG)),
                    ("arg1", "2"),
                    ("arg2", "4"),
                    ("arg3", "176"),
                    ("arg4", "0"),
                )
            )
        linedef_blocks.append(render_block("linedef", properties))
        control_line_indexes.append(line_index)

    if len(vertex_blocks) != UPDATED_COUNTS[0] - BASE_COUNTS[0]:
        raise ValueError(f"Cantidad de vértices nuevos inesperada: {len(vertex_blocks)}")
    if len(linedef_blocks) != UPDATED_COUNTS[1] - BASE_COUNTS[1]:
        raise ValueError(f"Cantidad de linedefs nuevas inesperada: {len(linedef_blocks)}")
    if len(sidedef_blocks) != UPDATED_COUNTS[2] - BASE_COUNTS[2]:
        raise ValueError(f"Cantidad de sidedefs nuevas inesperada: {len(sidedef_blocks)}")
    if len(sector_blocks) != UPDATED_COUNTS[3] - BASE_COUNTS[3]:
        raise ValueError(f"Cantidad de sectores nuevos inesperada: {len(sector_blocks)}")

    additions = "\n\n".join(
        (
            POOL_MARKER,
            "\n\n".join(vertex_blocks),
            "\n\n".join(linedef_blocks),
            "\n\n".join(sidedef_blocks),
            "\n\n".join(sector_blocks),
        )
    )
    if tuple(physical_line_indexes) != indexes["physical_lines"]:
        raise ValueError("Los índices de geometría física no son canónicos")
    if tuple(control_line_indexes) != indexes["control_lines"]:
        raise ValueError("Los índices del control de agua no son canónicos")
    return additions, indexes


def validate_pool(
    text: str,
    by_kind: dict[str, list[base.MapBlock]],
    indexes: dict[str, tuple[int, ...]],
) -> None:
    base.validate_references(by_kind, UPDATED_COUNTS, ())
    if text.count(POOL_MARKER) != 1:
        raise ValueError("La marca de la piscina debe aparecer exactamente una vez")

    sectors = by_kind["sector"]
    terrace = sectors[indexes["terrace"][0]]
    rim = sectors[indexes["rim"][0]]
    basin = sectors[indexes["basin"][0]]
    stairs = [sectors[index] for index in indexes["stairs"]]
    control = sectors[indexes["control"][0]]

    if int(terrace.properties["heightfloor"]) != 0:
        raise ValueError("La terraza no está a cota cero")
    if terrace.properties["texturefloor"] != '"CMTB02"':
        raise ValueError("La terraza no usa CMTB02")
    if int(rim.properties["heightfloor"]) != RIM_HEIGHT:
        raise ValueError("El borde de piedra no está elevado 8 MU")
    if rim.properties["texturefloor"] != '"CMST03"':
        raise ValueError("El borde no usa CMST03")
    if int(basin.properties["heightfloor"]) != POOL_DEPTH:
        raise ValueError("El vaso principal no tiene 256 MU de profundidad")

    actual_stair_floors = tuple(
        int(sector.properties["heightfloor"]) for sector in stairs
    )
    if actual_stair_floors != STAIR_FLOORS:
        raise ValueError(
            f"Cotas de la escalinata inesperadas: {actual_stair_floors}"
        )

    water_sectors = [basin, *stairs]
    if any(int(sector.properties.get("id", "-1")) != POOL_TAG for sector in water_sectors):
        raise ValueError("Todos los sectores del vaso deben compartir el tag 940")
    if int(control.properties["heightfloor"]) != POOL_DEPTH:
        raise ValueError("La base del control de agua no coincide con el vaso")
    if int(control.properties["heightceiling"]) != 0:
        raise ValueError("La superficie del control de agua no está en z=0")
    if control.properties["textureceiling"] != '"CAPOOL01"':
        raise ValueError("El agua no usa CAPOOL01")

    special_lines = [
        line
        for line in by_kind["linedef"]
        if line.properties.get("special") == "160"
        and line.properties.get("arg0") == str(POOL_TAG)
    ]
    if len(special_lines) != 1:
        raise ValueError(f"Controles de agua tag 940 inesperados: {len(special_lines)}")
    water_line = special_lines[0]
    expected_args = {"arg1": "2", "arg2": "4", "arg3": "176", "arg4": "0"}
    if any(water_line.properties.get(key) != value for key, value in expected_args.items()):
        raise ValueError("El control Sector_Set3DFloor no es nadable/translúcido")

    vertices = [
        (float(vertex.properties["x"]), float(vertex.properties["y"]))
        for vertex in by_kind["vertex"]
    ]
    physical_points: set[tuple[float, float]] = set()
    for line_index in indexes["physical_lines"]:
        line = by_kind["linedef"][line_index]
        physical_points.add(vertices[base.integer(line, "v1")])
        physical_points.add(vertices[base.integer(line, "v2")])
    xs = [point[0] for point in physical_points]
    ys = [point[1] for point in physical_points]
    if (min(xs), min(ys), max(xs), max(ys)) != TERRACE_BOUNDS:
        raise ValueError("La terraza posterior no conserva sus dimensiones")


def build_pool(path: Path = MAP01) -> bool:
    original = path.read_bytes()
    digest = sha256(original).hexdigest()
    signature, lumps = base.read_wad(path)
    text_indexes = [index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"]
    if len(text_indexes) != 1:
        raise ValueError(f"MAP01 debe contener un único TEXTMAP: {text_indexes}")
    text_index = text_indexes[0]
    text = lumps[text_index][1].decode("utf-8")
    _, by_kind = base.parse_textmap(text)

    if MAP01_4310A_SHA256 is not None and digest == MAP01_4310A_SHA256:
        indexes = expected_indexes()
        validate_pool(text, by_kind, indexes)
        return False
    if digest != MAP01_4300J_SHA256:
        raise ValueError("MAP01 no coincide con la base 4.30.0j: " + digest)
    base.validate_references(by_kind, BASE_COUNTS, ())
    if POOL_MARKER in text:
        raise ValueError("La base declara una piscina sin corresponder al hash final")

    additions, indexes = pool_additions(by_kind)
    updated_text = text.rstrip() + "\n\n" + additions + "\n"
    _, updated_by_kind = base.parse_textmap(updated_text)
    validate_pool(updated_text, updated_by_kind, indexes)

    # Garantía fuerte: todos los bloques anteriores conservan su texto exacto.
    for kind, count in zip(base.MAP_KINDS, BASE_COUNTS):
        before = [block.raw for block in by_kind[kind]]
        after = [block.raw for block in updated_by_kind[kind][:count]]
        if before != after:
            raise ValueError(f"La piscina alteró bloques existentes de tipo {kind}")

    lumps[text_index] = (b"TEXTMAP", updated_text.encode("utf-8"))
    updated_wad = base.render_wad(signature, lumps)
    updated_digest = sha256(updated_wad).hexdigest()
    if MAP01_4310A_SHA256 is not None and updated_digest != MAP01_4310A_SHA256:
        raise ValueError(f"Hash MAP01 4.31.0a inesperado: {updated_digest}")
    base.write_atomic(path, updated_wad)
    return True


def main() -> None:
    changed = build_pool()
    digest = sha256(MAP01.read_bytes()).hexdigest()
    if changed:
        print("MAP01: piscina posterior 4.31.0a construida")
    else:
        print("MAP01: piscina posterior 4.31.0a ya presente")
    print(f"MAP01 SHA-256: {digest}")


if __name__ == "__main__":
    main()
