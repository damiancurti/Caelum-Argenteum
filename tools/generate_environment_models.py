#!/usr/bin/env python3
"""Genera objetos ambientales argentinos originales para Caelum Argenteum."""

from __future__ import annotations

import argparse
import math
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple

from PIL import Image, ImageDraw, ImageEnhance, ImageOps


Point = Tuple[float, float, float]
UV = Tuple[float, float]
MODEL_DIRECTORY = "models/caelum/world/environment"


def add(a: Point, b: Point) -> Point:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def subtract(a: Point, b: Point) -> Point:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def multiply(a: Point, scalar: float) -> Point:
    return (a[0] * scalar, a[1] * scalar, a[2] * scalar)


def length(a: Point) -> float:
    return math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2])


def normalize(a: Point) -> Point:
    magnitude = length(a)
    if magnitude <= 0.000001:
        return (0.0, 1.0, 0.0)
    return multiply(a, 1.0 / magnitude)


def cross(a: Point, b: Point) -> Point:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def dot(a: Point, b: Point) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


class Mesh:
    def __init__(self, object_name: str) -> None:
        self.object_name = object_name
        self.vertices: List[Point] = []
        self.uvs: List[UV] = []
        self.faces: List[Tuple[str, Tuple[int, ...]]] = []

    def add_polygon(
        self,
        material: str,
        points: Sequence[Point],
        uvs: Sequence[UV],
    ) -> None:
        indices: List[int] = []
        for point, uv in zip(points, uvs):
            self.vertices.append(point)
            self.uvs.append(uv)
            indices.append(len(self.vertices))
        self.faces.append((material, tuple(indices)))

    def add_triangle(self, material: str, points: Sequence[Point]) -> None:
        self.add_polygon(
            material,
            points,
            ((0.5, 1.0), (0.0, 0.0), (1.0, 0.0)),
        )

    def add_quad(self, material: str, points: Sequence[Point]) -> None:
        self.add_polygon(
            material,
            points,
            ((0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)),
        )

    def add_frustum(
        self,
        material: str,
        start: Point,
        end: Point,
        start_radius: float,
        end_radius: float,
        sides: int = 8,
        cap_start: bool = True,
        cap_end: bool = True,
        phase: float = 0.0,
    ) -> None:
        axis = normalize(subtract(end, start))
        reference = (1.0, 0.0, 0.0)
        if abs(dot(axis, reference)) > 0.85:
            reference = (0.0, 1.0, 0.0)
        basis_one = normalize(cross(axis, reference))
        basis_two = normalize(cross(axis, basis_one))

        start_ring: List[Point] = []
        end_ring: List[Point] = []
        for index in range(sides):
            angle = phase + math.tau * index / sides
            radial = add(
                multiply(basis_one, math.cos(angle)),
                multiply(basis_two, math.sin(angle)),
            )
            start_ring.append(add(start, multiply(radial, start_radius)))
            end_ring.append(add(end, multiply(radial, end_radius)))

        for index in range(sides):
            following = (index + 1) % sides
            self.add_quad(
                material,
                (
                    start_ring[index],
                    start_ring[following],
                    end_ring[following],
                    end_ring[index],
                ),
            )
            if cap_start:
                self.add_triangle(
                    material,
                    (start, start_ring[following], start_ring[index]),
                )
            if cap_end:
                self.add_triangle(
                    material,
                    (end, end_ring[index], end_ring[following]),
                )

    def add_ellipsoid(
        self,
        material: str,
        center: Point,
        radii: Point,
        seed: int,
        rings: int = 4,
        segments: int = 8,
        irregularity: float = 0.12,
    ) -> None:
        rng = random.Random(seed)
        cx, cy, cz = center
        rx, ry, rz = radii
        ring_points: List[List[Point]] = []
        for ring in range(1, rings):
            latitude = -math.pi / 2.0 + math.pi * ring / rings
            vertical = math.sin(latitude)
            horizontal = math.cos(latitude)
            points: List[Point] = []
            for segment in range(segments):
                angle = math.tau * segment / segments
                variation = 1.0 + rng.uniform(-irregularity, irregularity)
                points.append((
                    cx + rx * horizontal * math.cos(angle) * variation,
                    cy + ry * vertical * (1.0 + rng.uniform(-irregularity, irregularity)),
                    cz + rz * horizontal * math.sin(angle) * variation,
                ))
            ring_points.append(points)

        bottom = (cx, cy - ry, cz)
        top = (cx, cy + ry, cz)
        for segment in range(segments):
            following = (segment + 1) % segments
            self.add_triangle(
                material,
                (bottom, ring_points[0][following], ring_points[0][segment]),
            )
            for ring in range(len(ring_points) - 1):
                self.add_quad(
                    material,
                    (
                        ring_points[ring][segment],
                        ring_points[ring][following],
                        ring_points[ring + 1][following],
                        ring_points[ring + 1][segment],
                    ),
                )
            self.add_triangle(
                material,
                (top, ring_points[-1][segment], ring_points[-1][following]),
            )

    def write(self, path: Path) -> None:
        lines = [
            "# Modelo original generado para Caelum Argenteum.",
            "# Ejes OBJ: X ancho, Y altura, Z profundidad.",
            f"o {self.object_name}",
        ]
        lines.extend(
            f"v {x:.6f} {y:.6f} {z:.6f}" for x, y, z in self.vertices
        )
        lines.extend(f"vt {u:.6f} {v:.6f}" for u, v in self.uvs)
        lines.append("s 1")
        active_material = ""
        for material, face in self.faces:
            if material != active_material:
                lines.append(f"usemtl {material}")
                active_material = material
            references = " ".join(f"{index}/{index}" for index in face)
            lines.append(f"f {references}")
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")


@dataclass(frozen=True)
class RockSpec:
    file_stem: str
    frame: str
    style: str
    seed: int
    width: float
    height: float
    depth: float
    texture: str


@dataclass(frozen=True)
class TreeSpec:
    file_stem: str
    frame: str
    species: str
    biome: str
    style: str
    seed: int
    height: float
    crown_radius: float
    trunk_radius: float
    bark: str
    foliage: str
    lean_x: float = 0.0
    lean_z: float = 0.0


ROCKS: Tuple[RockSpec, ...] = (
    RockSpec("ca_rock_granite", "A", "boulder", 431101, 58, 42, 52, "rock_granite.png"),
    RockSpec("ca_rock_sandstone", "B", "shelves", 431102, 92, 38, 66, "rock_sandstone.png"),
    RockSpec("ca_rock_basalt", "C", "columns", 431103, 64, 86, 58, "rock_basalt.png"),
    RockSpec("ca_rock_quartz", "D", "crystals", 431104, 72, 70, 64, "rock_quartz.png"),
    RockSpec("ca_rock_coastal", "E", "coastal", 431105, 104, 34, 78, "rock_coastal.png"),
)


TREES: Tuple[TreeSpec, ...] = (
    TreeSpec("ca_tree_desert_cardon", "A", "cardón", "desert", "cardon", 431201, 220, 42, 15, "cactus_desert.png", "cactus_desert.png"),
    TreeSpec("ca_tree_desert_churqui", "B", "churqui", "desert", "sparse", 431202, 118, 45, 7, "bark_desert.png", "foliage_desert.png", 8, -3),
    TreeSpec("ca_tree_desert_chanar", "C", "chañar", "desert", "multistem", 431203, 138, 52, 8, "bark_desert.png", "foliage_desert.png", -4, 5),
    TreeSpec("ca_tree_jungle_lapacho", "D", "lapacho", "jungle", "round", 431204, 238, 82, 13, "bark_jungle.png", "foliage_jungle_lapacho.png"),
    TreeSpec("ca_tree_jungle_palo_rosa", "E", "palo rosa", "jungle", "high", 431205, 310, 68, 14, "bark_jungle.png", "foliage_jungle.png", 5, 0),
    TreeSpec("ca_tree_jungle_timbo", "F", "timbó", "jungle", "umbrella", 431206, 210, 116, 22, "bark_jungle.png", "foliage_jungle.png"),
    TreeSpec("ca_tree_tundra_lenga", "G", "lenga", "tundra", "windswept", 431207, 178, 68, 11, "bark_tundra.png", "foliage_tundra.png", 28, 2),
    TreeSpec("ca_tree_tundra_nire", "H", "ñire", "tundra", "multistem", 431208, 112, 58, 7, "bark_tundra.png", "foliage_tundra.png", 12, 0),
    TreeSpec("ca_tree_tundra_guindo", "I", "guindo", "tundra", "conifer", 431209, 206, 57, 10, "bark_tundra.png", "foliage_tundra.png"),
    TreeSpec("ca_tree_mountain_pehuen", "J", "pehuén", "mountain", "araucaria", 431210, 286, 82, 12, "bark_mountain.png", "foliage_mountain.png"),
    TreeSpec("ca_tree_mountain_cypress", "K", "ciprés de la cordillera", "mountain", "cypress", 431211, 226, 48, 10, "bark_mountain.png", "foliage_mountain.png", -5, 2),
    TreeSpec("ca_tree_mountain_coihue", "L", "coihue", "mountain", "column", 431212, 254, 74, 14, "bark_mountain.png", "foliage_mountain.png"),
    TreeSpec("ca_tree_plains_ombu", "M", "ombú", "plains", "ombu", 431213, 196, 124, 24, "bark_plains.png", "foliage_plains.png"),
    TreeSpec("ca_tree_plains_tala", "N", "tala", "plains", "gnarled", 431214, 148, 64, 10, "bark_plains.png", "foliage_plains.png", 7, -4),
    TreeSpec("ca_tree_plains_espinillo", "O", "espinillo", "plains", "umbrella", 431215, 106, 58, 7, "bark_plains.png", "foliage_plains_espinillo.png"),
    TreeSpec("ca_tree_coast_coronillo", "P", "coronillo", "coast", "windswept", 431216, 142, 66, 10, "bark_coast.png", "foliage_coast.png", 24, -6),
    TreeSpec("ca_tree_coast_willow", "Q", "sauce criollo", "coast", "willow", 431217, 178, 76, 11, "bark_coast.png", "foliage_coast.png", 12, 3),
    TreeSpec("ca_tree_coast_ceibo", "R", "ceibo", "coast", "multistem", 431218, 158, 78, 10, "bark_coast.png", "foliage_coast_ceibo.png", -6, 4),
    TreeSpec("ca_tree_city_jacaranda", "S", "jacarandá", "city", "round", 431219, 196, 78, 11, "bark_city.png", "foliage_city_jacaranda.png"),
    TreeSpec("ca_tree_city_tipa", "T", "tipa", "city", "umbrella", 431220, 226, 104, 15, "bark_city.png", "foliage_city_tipa.png", 4, 0),
    TreeSpec("ca_tree_city_plane", "U", "plátano", "city", "high", 431221, 244, 78, 14, "bark_city.png", "foliage_city_green.png", -3, 2),
)


ROCK_CROPS: Dict[str, Tuple[int, int, int, int]] = {
    "rock_granite.png": (5, 5, 250, 310),
    "rock_sandstone.png": (255, 5, 499, 310),
    "rock_basalt.png": (505, 5, 749, 310),
    "rock_quartz.png": (755, 5, 999, 310),
    "rock_coastal.png": (1005, 5, 1249, 310),
}

BARK_CROPS: Dict[str, Tuple[int, int, int, int]] = {
    "bark_desert.png": (5, 318, 177, 719),
    "bark_jungle.png": (183, 318, 351, 719),
    "bark_tundra.png": (357, 318, 531, 719),
    "bark_mountain.png": (537, 318, 707, 719),
    "bark_plains.png": (713, 318, 885, 719),
    "bark_coast.png": (891, 318, 1061, 719),
    "bark_city.png": (1067, 318, 1249, 719),
}

FOLIAGE_CROPS: Dict[str, Tuple[int, int, int, int]] = {
    "foliage_desert.png": (5, 725, 177, 1248),
    "foliage_jungle.png": (183, 725, 351, 1248),
    "foliage_tundra.png": (357, 725, 531, 1248),
    "foliage_mountain.png": (537, 725, 707, 1248),
    "foliage_plains.png": (713, 725, 885, 1248),
    "foliage_coast.png": (891, 725, 1061, 1248),
    "foliage_city.png": (1067, 725, 1249, 1005),
}


def mirrored_tile(source: Image.Image, crop: Tuple[int, int, int, int]) -> Image.Image:
    quarter = ImageOps.fit(
        source.crop(crop).convert("RGB"),
        (128, 128),
        Image.Resampling.LANCZOS,
    )
    quarter = ImageEnhance.Contrast(quarter).enhance(0.88)
    quarter = ImageEnhance.Color(quarter).enhance(0.92)
    result = Image.new("RGB", (256, 256))
    result.paste(quarter, (0, 0))
    result.paste(ImageOps.mirror(quarter), (128, 0))
    result.paste(ImageOps.flip(quarter), (0, 128))
    result.paste(ImageOps.mirror(ImageOps.flip(quarter)), (128, 128))
    return result


def add_flower_accents(
    base: Image.Image,
    colors: Sequence[Tuple[int, int, int]],
    seed: int,
    amount: int,
) -> Image.Image:
    quarter = base.crop((0, 0, 128, 128)).copy()
    draw = ImageDraw.Draw(quarter, "RGBA")
    rng = random.Random(seed)
    for _ in range(amount):
        x = rng.randint(5, 122)
        y = rng.randint(5, 122)
        radius = rng.randint(1, 3)
        color = colors[rng.randrange(len(colors))]
        draw.ellipse(
            (x - radius, y - radius, x + radius, y + radius),
            fill=(*color, rng.randint(150, 225)),
        )
    result = Image.new("RGB", (256, 256))
    result.paste(quarter, (0, 0))
    result.paste(ImageOps.mirror(quarter), (128, 0))
    result.paste(ImageOps.flip(quarter), (0, 128))
    result.paste(ImageOps.mirror(ImageOps.flip(quarter)), (128, 128))
    return result


def make_cactus_texture(base: Image.Image) -> Image.Image:
    quarter = base.crop((0, 0, 128, 128)).convert("RGB")
    pixels = quarter.load()
    for y in range(128):
        for x in range(128):
            red, green, blue = pixels[x, y]
            luminance = (red + green + blue) / 3.0
            rib = 16.0 * math.cos(math.tau * x / 21.0)
            pixels[x, y] = (
                max(18, min(92, int(39 + luminance * 0.18 + rib * 0.25))),
                max(55, min(142, int(82 + luminance * 0.25 + rib))),
                max(28, min(103, int(49 + luminance * 0.17 + rib * 0.35))),
            )
    result = Image.new("RGB", (256, 256))
    result.paste(quarter, (0, 0))
    result.paste(ImageOps.mirror(quarter), (128, 0))
    result.paste(ImageOps.flip(quarter), (0, 128))
    result.paste(ImageOps.mirror(ImageOps.flip(quarter)), (128, 128))
    return result


def generate_textures(source_path: Path, model_dir: Path) -> None:
    source = Image.open(source_path)
    generated: Dict[str, Image.Image] = {}
    for name, crop in {**ROCK_CROPS, **BARK_CROPS, **FOLIAGE_CROPS}.items():
        generated[name] = mirrored_tile(source, crop)

    generated["cactus_desert.png"] = make_cactus_texture(
        generated["foliage_desert.png"]
    )
    generated["foliage_jungle_lapacho.png"] = add_flower_accents(
        generated["foliage_jungle.png"],
        ((204, 88, 137), (224, 143, 178)),
        431301,
        58,
    )
    generated["foliage_plains_espinillo.png"] = add_flower_accents(
        generated["foliage_plains.png"],
        ((226, 176, 38), (244, 207, 79)),
        431302,
        70,
    )
    generated["foliage_coast_ceibo.png"] = add_flower_accents(
        generated["foliage_coast.png"],
        ((177, 32, 32), (226, 58, 38)),
        431303,
        64,
    )
    generated["foliage_city_jacaranda.png"] = add_flower_accents(
        generated["foliage_city.png"],
        ((119, 76, 170), (164, 114, 205)),
        431304,
        78,
    )
    generated["foliage_city_tipa.png"] = add_flower_accents(
        generated["foliage_plains.png"],
        ((218, 169, 38), (242, 207, 90)),
        431305,
        54,
    )
    generated["foliage_city_green.png"] = ImageEnhance.Color(
        generated["foliage_jungle.png"]
    ).enhance(0.72)

    model_dir.mkdir(parents=True, exist_ok=True)
    for name, texture in generated.items():
        texture.save(model_dir / name, optimize=True)


def material(name: str) -> str:
    return f"{MODEL_DIRECTORY}/{name}"


def add_trunk_path(
    mesh: Mesh,
    bark: str,
    points: Sequence[Point],
    base_radius: float,
    top_radius: float,
    sides: int = 8,
) -> None:
    for index in range(len(points) - 1):
        ratio = index / max(1, len(points) - 2)
        next_ratio = (index + 1) / max(1, len(points) - 2)
        mesh.add_frustum(
            bark,
            points[index],
            points[index + 1],
            base_radius + (top_radius - base_radius) * ratio,
            base_radius + (top_radius - base_radius) * next_ratio,
            sides,
            index == 0,
            index == len(points) - 2,
            phase=0.12 * index,
        )


def trunk_position(spec: TreeSpec, height_ratio: float) -> Point:
    return (
        spec.lean_x * height_ratio * height_ratio,
        spec.height * height_ratio,
        spec.lean_z * height_ratio * height_ratio,
    )


def add_branch(
    mesh: Mesh,
    bark: str,
    origin: Point,
    endpoint: Point,
    radius: float,
    sides: int = 6,
) -> None:
    middle = (
        (origin[0] + endpoint[0]) * 0.48,
        origin[1] + (endpoint[1] - origin[1]) * 0.38 + length(subtract(endpoint, origin)) * 0.08,
        (origin[2] + endpoint[2]) * 0.48,
    )
    add_trunk_path(mesh, bark, (origin, middle, endpoint), radius, radius * 0.35, sides)


def build_deciduous_tree(mesh: Mesh, spec: TreeSpec) -> None:
    rng = random.Random(spec.seed)
    bark = material(spec.bark)
    foliage = material(spec.foliage)
    style = spec.style
    trunk_top_ratio = 0.70 if style not in ("high", "column") else 0.80
    trunk_points = (
        (0.0, 0.0, 0.0),
        trunk_position(spec, 0.28),
        trunk_position(spec, 0.52),
        trunk_position(spec, trunk_top_ratio),
    )
    add_trunk_path(
        mesh,
        bark,
        trunk_points,
        spec.trunk_radius,
        max(2.0, spec.trunk_radius * 0.38),
        9,
    )

    if style == "ombu":
        for index in range(8):
            angle = math.tau * index / 8
            root = (
                math.cos(angle) * spec.trunk_radius * 2.4,
                0.0,
                math.sin(angle) * spec.trunk_radius * 2.4,
            )
            mesh.add_frustum(
                bark,
                root,
                (0.0, spec.height * 0.17, 0.0),
                spec.trunk_radius * 0.25,
                spec.trunk_radius * 0.62,
                6,
            )

    branch_count = {
        "sparse": 6,
        "round": 10,
        "high": 8,
        "umbrella": 12,
        "windswept": 9,
        "column": 9,
        "ombu": 14,
        "gnarled": 8,
    }.get(style, 8)
    canopy_centers: List[Point] = []
    wind_direction = 1.0 if spec.lean_x >= 0.0 else -1.0
    for index in range(branch_count):
        level = 0.42 + rng.uniform(0.0, 0.24)
        if style == "high":
            level = 0.58 + rng.uniform(0.0, 0.12)
        origin = trunk_position(spec, level)
        angle = math.tau * index / branch_count + rng.uniform(-0.28, 0.28)
        horizontal = spec.crown_radius * rng.uniform(0.48, 0.90)
        if style == "column":
            horizontal *= 0.55
        if style == "windswept":
            angle = rng.uniform(-1.10, 1.10)
            horizontal *= 0.85 + 0.35 * max(0.0, math.cos(angle))
        endpoint = (
            origin[0] + math.cos(angle) * horizontal
                + (spec.crown_radius * 0.28 * wind_direction if style == "windswept" else 0.0),
            spec.height * rng.uniform(0.68, 0.91),
            origin[2] + math.sin(angle) * horizontal,
        )
        add_branch(
            mesh,
            bark,
            origin,
            endpoint,
            max(1.5, spec.trunk_radius * rng.uniform(0.18, 0.31)),
        )
        canopy_centers.append(endpoint)

    canopy_centers.append(trunk_position(spec, 0.86))
    if style in ("round", "ombu", "umbrella"):
        canopy_centers.append((
            spec.lean_x * 0.55,
            spec.height * 0.78,
            spec.lean_z * 0.55,
        ))

    for index, center in enumerate(canopy_centers):
        radius_factor = rng.uniform(0.30, 0.48)
        if style == "sparse":
            radius_factor *= 0.70
        radius_x = spec.crown_radius * radius_factor
        radius_z = radius_x * rng.uniform(0.72, 1.05)
        radius_y = radius_x * (0.38 if style in ("umbrella", "ombu") else 0.62)
        if style == "column":
            radius_y *= 1.40
        mesh.add_ellipsoid(
            foliage,
            (center[0], center[1] + radius_y * 0.15, center[2]),
            (radius_x, radius_y, radius_z),
            spec.seed + 100 + index,
            rings=4,
            segments=8,
            irregularity=0.16,
        )


def build_multistem_tree(mesh: Mesh, spec: TreeSpec) -> None:
    rng = random.Random(spec.seed)
    bark = material(spec.bark)
    foliage = material(spec.foliage)
    stem_count = 4 if spec.biome in ("tundra", "coast") else 3
    endpoints: List[Point] = []
    for stem in range(stem_count):
        angle = math.tau * stem / stem_count + rng.uniform(-0.35, 0.35)
        base = (
            math.cos(angle) * spec.trunk_radius * 0.45,
            0.0,
            math.sin(angle) * spec.trunk_radius * 0.45,
        )
        top = (
            spec.lean_x + math.cos(angle) * spec.crown_radius * rng.uniform(0.25, 0.48),
            spec.height * rng.uniform(0.68, 0.90),
            spec.lean_z + math.sin(angle) * spec.crown_radius * rng.uniform(0.25, 0.48),
        )
        middle = (
            top[0] * 0.38,
            top[1] * 0.46,
            top[2] * 0.38,
        )
        add_trunk_path(
            mesh,
            bark,
            (base, middle, top),
            spec.trunk_radius * 0.72,
            spec.trunk_radius * 0.22,
            7,
        )
        endpoints.append(top)
        for branch in range(2):
            branch_angle = angle + (branch * 2 - 1) * 0.9
            branch_end = (
                top[0] + math.cos(branch_angle) * spec.crown_radius * 0.34,
                top[1] + spec.height * rng.uniform(-0.02, 0.10),
                top[2] + math.sin(branch_angle) * spec.crown_radius * 0.34,
            )
            add_branch(mesh, bark, middle, branch_end, spec.trunk_radius * 0.18)
            endpoints.append(branch_end)

    for index, center in enumerate(endpoints):
        radius = spec.crown_radius * rng.uniform(0.30, 0.43)
        mesh.add_ellipsoid(
            foliage,
            center,
            (radius, radius * 0.62, radius * 0.88),
            spec.seed + 200 + index,
            irregularity=0.18,
        )


def build_conifer(mesh: Mesh, spec: TreeSpec) -> None:
    bark = material(spec.bark)
    foliage = material(spec.foliage)
    top = (spec.lean_x, spec.height, spec.lean_z)
    add_trunk_path(
        mesh,
        bark,
        ((0.0, 0.0, 0.0), (spec.lean_x * 0.45, spec.height * 0.55, spec.lean_z * 0.45), top),
        spec.trunk_radius,
        spec.trunk_radius * 0.23,
        9,
    )
    layers = 8 if spec.style == "conifer" else 10
    for layer in range(layers):
        ratio = 0.24 + 0.068 * layer
        center = trunk_position(spec, ratio)
        radius = spec.crown_radius * (1.0 - layer / (layers + 1.5))
        if spec.style == "cypress":
            radius *= 0.66
        lower = (center[0], center[1] - spec.height * 0.035, center[2])
        upper = (center[0], center[1] + spec.height * 0.10, center[2])
        mesh.add_frustum(
            foliage,
            lower,
            upper,
            radius,
            max(1.0, radius * 0.08),
            10,
            True,
            True,
            phase=0.18 * layer,
        )


def build_araucaria(mesh: Mesh, spec: TreeSpec) -> None:
    bark = material(spec.bark)
    foliage = material(spec.foliage)
    add_trunk_path(
        mesh,
        bark,
        ((0.0, 0.0, 0.0), (0.0, spec.height * 0.60, 0.0), (0.0, spec.height, 0.0)),
        spec.trunk_radius,
        spec.trunk_radius * 0.24,
        10,
    )
    whorls = 6
    for whorl in range(whorls):
        level = 0.42 + whorl * 0.085
        radius = spec.crown_radius * (1.0 - whorl * 0.10)
        branch_count = 6
        for branch in range(branch_count):
            angle = math.tau * branch / branch_count + whorl * 0.28
            origin = (0.0, spec.height * level, 0.0)
            endpoint = (
                math.cos(angle) * radius,
                spec.height * (level + 0.025),
                math.sin(angle) * radius,
            )
            add_branch(
                mesh,
                bark,
                origin,
                endpoint,
                max(1.3, spec.trunk_radius * 0.17),
                6,
            )
            for tuft in range(2):
                factor = 0.62 + tuft * 0.30
                center = multiply(endpoint, factor)
                center = (
                    center[0],
                    origin[1] + (endpoint[1] - origin[1]) * factor,
                    center[2],
                )
                mesh.add_ellipsoid(
                    foliage,
                    center,
                    (13.0, 7.0, 13.0),
                    spec.seed + whorl * 20 + branch * 2 + tuft,
                    rings=3,
                    segments=7,
                    irregularity=0.10,
                )


def build_cardon(mesh: Mesh, spec: TreeSpec) -> None:
    cactus = material(spec.bark)
    mesh.add_frustum(
        cactus,
        (0.0, 0.0, 0.0),
        (0.0, spec.height, 0.0),
        spec.trunk_radius,
        spec.trunk_radius * 0.72,
        12,
    )
    arms = (
        (-1.0, 0.37, 0.08, 0.27),
        (1.0, 0.52, -0.14, 0.31),
        (-0.72, 0.66, -0.42, 0.20),
    )
    for index, (side, level, depth, arm_height) in enumerate(arms):
        origin = (0.0, spec.height * level, 0.0)
        elbow = (
            side * spec.crown_radius * (0.55 + index * 0.08),
            spec.height * level,
            depth * spec.crown_radius,
        )
        top = (
            elbow[0],
            spec.height * (level + arm_height),
            elbow[2],
        )
        mesh.add_frustum(
            cactus,
            origin,
            elbow,
            spec.trunk_radius * 0.48,
            spec.trunk_radius * 0.42,
            10,
        )
        mesh.add_frustum(
            cactus,
            elbow,
            top,
            spec.trunk_radius * 0.44,
            spec.trunk_radius * 0.31,
            10,
        )


def build_willow(mesh: Mesh, spec: TreeSpec) -> None:
    build_deciduous_tree(mesh, spec)
    bark = material(spec.bark)
    foliage = material(spec.foliage)
    rng = random.Random(spec.seed + 900)
    for index in range(12):
        angle = math.tau * index / 12 + rng.uniform(-0.2, 0.2)
        start = (
            spec.lean_x + math.cos(angle) * spec.crown_radius * 0.38,
            spec.height * rng.uniform(0.67, 0.83),
            spec.lean_z + math.sin(angle) * spec.crown_radius * 0.38,
        )
        end = (
            start[0] + math.cos(angle) * spec.crown_radius * 0.18,
            spec.height * rng.uniform(0.22, 0.45),
            start[2] + math.sin(angle) * spec.crown_radius * 0.18,
        )
        mesh.add_frustum(bark, start, end, 1.2, 0.35, 5)
        center = (
            (start[0] + end[0]) * 0.5,
            (start[1] + end[1]) * 0.5,
            (start[2] + end[2]) * 0.5,
        )
        mesh.add_ellipsoid(
            foliage,
            center,
            (9.0, abs(start[1] - end[1]) * 0.46, 7.0),
            spec.seed + 600 + index,
            rings=3,
            segments=6,
            irregularity=0.08,
        )


def build_tree(spec: TreeSpec, output: Path) -> Tuple[int, int]:
    mesh = Mesh(spec.file_stem)
    if spec.style == "cardon":
        build_cardon(mesh, spec)
    elif spec.style == "multistem":
        build_multistem_tree(mesh, spec)
    elif spec.style in ("conifer", "cypress"):
        build_conifer(mesh, spec)
    elif spec.style == "araucaria":
        build_araucaria(mesh, spec)
    elif spec.style == "willow":
        build_willow(mesh, spec)
    else:
        build_deciduous_tree(mesh, spec)
    mesh.write(output)
    return len(mesh.vertices), len(mesh.faces)


def add_irregular_rock(
    mesh: Mesh,
    material_name: str,
    center: Point,
    size: Point,
    seed: int,
    segments: int = 9,
) -> None:
    rng = random.Random(seed)
    cx, cy, cz = center
    width, height, depth = size
    rings: List[List[Point]] = []
    for level, radius_factor in ((0.0, 0.84), (0.32, 1.0), (0.68, 0.74)):
        ring: List[Point] = []
        for segment in range(segments):
            angle = math.tau * segment / segments
            variation = rng.uniform(0.82, 1.18)
            ring.append((
                cx + math.cos(angle) * width * 0.5 * radius_factor * variation,
                cy + height * level + rng.uniform(-0.035, 0.035) * height,
                cz + math.sin(angle) * depth * 0.5 * radius_factor * variation,
            ))
        rings.append(ring)
    bottom = (cx, cy, cz)
    top = (
        cx + rng.uniform(-0.13, 0.13) * width,
        cy + height,
        cz + rng.uniform(-0.13, 0.13) * depth,
    )
    for segment in range(segments):
        following = (segment + 1) % segments
        mesh.add_triangle(
            material_name,
            (bottom, rings[0][segment], rings[0][following]),
        )
        for ring in range(len(rings) - 1):
            mesh.add_quad(
                material_name,
                (
                    rings[ring][segment],
                    rings[ring + 1][segment],
                    rings[ring + 1][following],
                    rings[ring][following],
                ),
            )
        mesh.add_triangle(
            material_name,
            (top, rings[-1][following], rings[-1][segment]),
        )


def build_rock(spec: RockSpec, output: Path) -> Tuple[int, int]:
    mesh = Mesh(spec.file_stem)
    rock_material = material(spec.texture)
    if spec.style == "boulder":
        add_irregular_rock(
            mesh,
            rock_material,
            (0.0, 0.0, 0.0),
            (spec.width, spec.height, spec.depth),
            spec.seed,
            10,
        )
    elif spec.style == "shelves":
        add_irregular_rock(mesh, rock_material, (0.0, 0.0, 0.0), (92, 22, 66), spec.seed, 10)
        add_irregular_rock(mesh, rock_material, (-13.0, 17.0, 3.0), (67, 21, 53), spec.seed + 1, 9)
    elif spec.style == "columns":
        columns = ((-16, 0, 17, 66), (3, 4, 20, 82), (20, -3, 15, 58), (-2, 17, 14, 52))
        for index, (x, z, radius, height) in enumerate(columns):
            mesh.add_frustum(
                rock_material,
                (x, 0.0, z),
                (x + (index % 2) * 2.0, height, z),
                radius,
                radius * 0.82,
                6,
                True,
                True,
                phase=0.12 * index,
            )
    elif spec.style == "crystals":
        add_irregular_rock(mesh, rock_material, (0.0, 0.0, 0.0), (72, 28, 64), spec.seed, 9)
        crystals = ((-19, 0, 7, 48, -4), (1, 4, 10, 67, 3), (18, -8, 7, 43, 7), (22, 13, 5, 34, -2), (-4, -19, 6, 39, 5))
        for index, (x, z, radius, height, lean) in enumerate(crystals):
            mesh.add_frustum(
                rock_material,
                (x, 12.0, z),
                (x + lean, height, z + lean * 0.35),
                radius,
                0.8,
                6,
                True,
                True,
                phase=index * 0.18,
            )
    else:
        add_irregular_rock(mesh, rock_material, (-18.0, 0.0, 5.0), (78, 30, 64), spec.seed, 10)
        add_irregular_rock(mesh, rock_material, (29.0, 0.0, -7.0), (55, 24, 48), spec.seed + 1, 9)
        add_irregular_rock(mesh, rock_material, (4.0, 9.0, 9.0), (61, 25, 51), spec.seed + 2, 9)
    mesh.write(output)
    return len(mesh.vertices), len(mesh.faces)


def make_transparent_sprite(path: Path) -> None:
    Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(path, optimize=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=Path("assets/source/world/ca_environment_atlas_master.png"),
    )
    parser.add_argument(
        "--runtime-root",
        type=Path,
        default=Path("src"),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    model_dir = args.runtime_root / MODEL_DIRECTORY
    sprite_dir = args.runtime_root / "sprites"
    model_dir.mkdir(parents=True, exist_ok=True)
    sprite_dir.mkdir(parents=True, exist_ok=True)

    generate_textures(args.source, model_dir)
    results: List[Tuple[str, int, int]] = []
    for spec in ROCKS:
        vertices, faces = build_rock(spec, model_dir / f"{spec.file_stem}.obj")
        make_transparent_sprite(sprite_dir / f"CARK{spec.frame}0.png")
        results.append((spec.file_stem, vertices, faces))
    for spec in TREES:
        vertices, faces = build_tree(spec, model_dir / f"{spec.file_stem}.obj")
        make_transparent_sprite(sprite_dir / f"CAVT{spec.frame}0.png")
        results.append((spec.file_stem, vertices, faces))

    for name, vertices, faces in results:
        print(f"{name}: {vertices} vertices, {faces} faces")
    print(f"Generated {len(ROCKS)} rocks and {len(TREES)} vegetation models.")


if __name__ == "__main__":
    main()
