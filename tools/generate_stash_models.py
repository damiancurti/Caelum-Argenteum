#!/usr/bin/env python3
"""Generate the original static stash prototype used by Caelum Argenteum."""

from __future__ import annotations

import argparse
import math
import random
import struct
import zlib
from collections import defaultdict
from pathlib import Path
from typing import Callable, DefaultDict, Iterable, List, Sequence, Tuple


Point = Tuple[float, float, float]
Transform = Callable[[Point], Point]


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    checksum = zlib.crc32(kind)
    checksum = zlib.crc32(payload, checksum) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", checksum)


def write_png(path: Path, width: int, height: int, rows: Sequence[bytes], color_type: int) -> None:
    # El generador usa sólo la biblioteca estándar para que el arte fuente no
    # dependa de Pillow, Blender ni otros programas externos.
    raw = b"".join(b"\x00" + row for row in rows)
    header = struct.pack(">IIBBBBB", width, height, 8, color_type, 0, 0, 0)
    payload = b"\x89PNG\r\n\x1a\n"
    payload += png_chunk(b"IHDR", header)
    payload += png_chunk(b"IDAT", zlib.compress(raw, 9))
    payload += png_chunk(b"IEND", b"")
    path.write_bytes(payload)


def clamp_channel(value: float) -> int:
    return max(0, min(255, int(round(value))))


def make_wood_texture(path: Path, size: int = 256) -> None:
    rng = random.Random(43101)
    knots = [(48, 45, 13), (177, 111, 18), (93, 206, 10), (228, 221, 8)]
    rows: List[bytes] = []
    for y in range(size):
        row = bytearray()
        plank = y // 64
        seam = min(y % 64, 64 - (y % 64))
        for x in range(size):
            wave = math.sin(x / 11.0 + math.sin(y / 23.0) * 1.7)
            fine = math.sin(x / 3.8 + y / 31.0)
            noise = rng.uniform(-5.0, 5.0)
            shade = 7.0 * wave + 3.0 * fine + noise + plank * 1.5
            if seam <= 2:
                shade -= 28.0
            for knot_x, knot_y, radius in knots:
                distance = math.hypot(x - knot_x, y - knot_y)
                ring = abs(distance - radius)
                if distance < radius * 1.8:
                    shade -= max(0.0, 17.0 - ring * 2.5)
                    shade += 5.0 * math.sin(distance * 1.7)
            row.extend((
                clamp_channel(82 + shade),
                clamp_channel(48 + shade * 0.62),
                clamp_channel(27 + shade * 0.35),
            ))
        rows.append(bytes(row))
    write_png(path, size, size, rows, 2)


def make_metal_texture(path: Path, size: int = 128) -> None:
    rng = random.Random(43102)
    rows: List[bytes] = []
    for y in range(size):
        row = bytearray()
        for x in range(size):
            brushed = 6.0 * math.sin(x / 2.7) + 3.0 * math.sin(y / 17.0)
            noise = rng.uniform(-9.0, 9.0)
            rust = max(0.0, 1.0 - math.hypot(x - 92, y - 35) / 34.0)
            base = 47.0 + brushed + noise
            row.extend((
                clamp_channel(base + rust * 31.0),
                clamp_channel(base + 3.0 + rust * 8.0),
                clamp_channel(base + 5.0 - rust * 7.0),
            ))
        rows.append(bytes(row))
    write_png(path, size, size, rows, 2)


def make_lock_texture(path: Path, size: int = 128) -> None:
    rng = random.Random(43104)
    rows: List[bytes] = []
    for y in range(size):
        row = bytearray()
        for x in range(size):
            edge_light = 13.0 * max(0.0, math.sin((x + y) / 18.0))
            noise = rng.uniform(-7.0, 7.0)
            oxidation = max(0.0, 1.0 - math.hypot(x - 31, y - 89) / 38.0)
            base = 93.0 + edge_light + noise
            row.extend((
                clamp_channel(base + oxidation * 10.0),
                clamp_channel(base + 5.0 + oxidation * 4.0),
                clamp_channel(base + 8.0 - oxidation * 5.0),
            ))
        rows.append(bytes(row))
    write_png(path, size, size, rows, 2)


def make_inside_texture(path: Path, size: int = 128) -> None:
    rng = random.Random(43103)
    rows: List[bytes] = []
    for y in range(size):
        row = bytearray()
        for x in range(size):
            noise = rng.uniform(-4.0, 4.0)
            weave = 3.0 if ((x // 4 + y // 4) % 2) == 0 else -2.0
            row.extend((
                clamp_channel(29 + weave + noise),
                clamp_channel(16 + weave * 0.45 + noise),
                clamp_channel(14 + noise),
            ))
        rows.append(bytes(row))
    write_png(path, size, size, rows, 2)


def make_transparent_sprite(path: Path) -> None:
    write_png(path, 1, 1, [bytes((0, 0, 0, 0))], 6)


class Mesh:
    def __init__(self) -> None:
        self.vertices: List[Point] = []
        self.uvs: List[Tuple[float, float]] = []
        self.faces: DefaultDict[str, List[Tuple[int, ...]]] = defaultdict(list)

    def add_polygon(
        self,
        material: str,
        points: Sequence[Point],
        uvs: Sequence[Tuple[float, float]],
        transform: Transform | None = None,
    ) -> None:
        indices: List[int] = []
        for point, uv in zip(points, uvs):
            final_point = transform(point) if transform is not None else point
            self.vertices.append(final_point)
            self.uvs.append(uv)
            indices.append(len(self.vertices))
        self.faces[material].append(tuple(indices))

    def add_quad(
        self,
        material: str,
        points: Sequence[Point],
        transform: Transform | None = None,
    ) -> None:
        self.add_polygon(
            material,
            points,
            ((0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)),
            transform,
        )

    def add_triangle(
        self,
        material: str,
        points: Sequence[Point],
        transform: Transform | None = None,
    ) -> None:
        self.add_polygon(
            material,
            points,
            ((0.5, 0.5), (0.0, 0.0), (1.0, 0.0)),
            transform,
        )

    def add_box(
        self,
        material: str,
        center: Point,
        size: Point,
        transform: Transform | None = None,
    ) -> None:
        cx, cy, cz = center
        sx, sy, sz = size
        x0, x1 = cx - sx / 2.0, cx + sx / 2.0
        y0, y1 = cy - sy / 2.0, cy + sy / 2.0
        z0, z1 = cz - sz / 2.0, cz + sz / 2.0
        self.add_quad(material, ((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)), transform)
        self.add_quad(material, ((x1, y0, z0), (x0, y0, z0), (x0, y1, z0), (x1, y1, z0)), transform)
        self.add_quad(material, ((x1, y0, z1), (x1, y0, z0), (x1, y1, z0), (x1, y1, z1)), transform)
        self.add_quad(material, ((x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0)), transform)
        self.add_quad(material, ((x0, y1, z1), (x1, y1, z1), (x1, y1, z0), (x0, y1, z0)), transform)
        self.add_quad(material, ((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)), transform)

    def add_cylinder_z(
        self,
        material: str,
        center: Point,
        radius: float,
        depth: float,
        sides: int = 8,
    ) -> None:
        cx, cy, cz = center
        front = cz + depth / 2.0
        back = cz - depth / 2.0
        for index in range(sides):
            a0 = 2.0 * math.pi * index / sides
            a1 = 2.0 * math.pi * (index + 1) / sides
            p0 = (cx + radius * math.cos(a0), cy + radius * math.sin(a0), front)
            p1 = (cx + radius * math.cos(a1), cy + radius * math.sin(a1), front)
            p2 = (cx + radius * math.cos(a1), cy + radius * math.sin(a1), back)
            p3 = (cx + radius * math.cos(a0), cy + radius * math.sin(a0), back)
            self.add_quad(material, (p0, p1, p2, p3))
            self.add_triangle(material, ((cx, cy, front), p1, p0))
            self.add_triangle(material, ((cx, cy, back), p3, p2))

    def write(self, path: Path) -> None:
        lines = [
            "# Modelo original generado para Caelum Argenteum.",
            "# Ejes OBJ: X ancho, Y altura, Z profundidad.",
            "o CaelumStashChest",
        ]
        lines.extend(f"v {x:.6f} {y:.6f} {z:.6f}" for x, y, z in self.vertices)
        lines.extend(f"vt {u:.6f} {v:.6f}" for u, v in self.uvs)
        lines.append("s off")
        for material, faces in self.faces.items():
            lines.append(f"usemtl {material}")
            for face in faces:
                references = " ".join(f"{index}/{index}" for index in face)
                lines.append(f"f {references}")
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")


WOOD = "models/caelum/props/stash/ca_stash_wood.png"
METAL = "models/caelum/props/stash/ca_stash_metal.png"
INSIDE = "models/caelum/props/stash/ca_stash_inside.png"
LOCK = "models/caelum/props/stash/ca_stash_lock.png"


def lid_transform(opened: bool) -> Transform | None:
    if not opened:
        return None
    pivot_y = 24.0
    pivot_z = -18.0
    angle = math.radians(-105.0)
    cosine = math.cos(angle)
    sine = math.sin(angle)

    def transform(point: Point) -> Point:
        x, y, z = point
        relative_y = y - pivot_y
        relative_z = z - pivot_z
        return (
            x,
            pivot_y + cosine * relative_y - sine * relative_z,
            pivot_z + sine * relative_y + cosine * relative_z,
        )

    return transform


def add_barrel_lid(mesh: Mesh, opened: bool) -> None:
    transform = lid_transform(opened)
    segments = 10
    radius = 18.0
    base_y = 24.0
    width = 64.0
    for index in range(segments):
        a0 = math.pi * index / segments
        a1 = math.pi * (index + 1) / segments
        y0, z0 = base_y + radius * math.sin(a0), radius * math.cos(a0)
        y1, z1 = base_y + radius * math.sin(a1), radius * math.cos(a1)
        mesh.add_quad(
            WOOD,
            ((-width / 2.0, y0, z0), (width / 2.0, y0, z0),
             (width / 2.0, y1, z1), (-width / 2.0, y1, z1)),
            transform,
        )

        for end_x, reverse in ((-width / 2.0, False), (width / 2.0, True)):
            first = (end_x, y0, z0)
            second = (end_x, y1, z1)
            points = ((end_x, base_y, 0.0), second, first) if reverse else ((end_x, base_y, 0.0), first, second)
            mesh.add_triangle(WOOD, points, transform)

    # Dos flejes siguen la bóveda y hacen legible la silueta a distancia.
    for strap_x in (-20.0, 20.0):
        strap_half_width = 2.0
        strap_radius = radius + 0.55
        for index in range(segments):
            a0 = math.pi * index / segments
            a1 = math.pi * (index + 1) / segments
            y0 = base_y + strap_radius * math.sin(a0)
            z0 = strap_radius * math.cos(a0)
            y1 = base_y + strap_radius * math.sin(a1)
            z1 = strap_radius * math.cos(a1)
            mesh.add_quad(
                METAL,
                ((strap_x - strap_half_width, y0, z0),
                 (strap_x + strap_half_width, y0, z0),
                 (strap_x + strap_half_width, y1, z1),
                 (strap_x - strap_half_width, y1, z1)),
                transform,
            )

    # La cara interior sólo se revela en el estado abierto.
    if opened:
        mesh.add_box(INSIDE, (0.0, 24.4, 0.0), (56.0, 0.8, 30.0), transform)


def make_chest(opened: bool, locked: bool) -> Mesh:
    mesh = Mesh()
    mesh.add_box(WOOD, (0.0, 12.0, 0.0), (64.0, 24.0, 36.0))

    # Reborde e interior del cajón inferior.
    mesh.add_box(METAL, (0.0, 2.0, 18.7), (64.0, 4.0, 1.4))
    mesh.add_box(METAL, (0.0, 22.0, 18.7), (64.0, 4.0, 1.4))
    mesh.add_box(METAL, (-29.5, 12.0, 18.8), (3.0, 24.0, 1.6))
    mesh.add_box(METAL, (29.5, 12.0, 18.8), (3.0, 24.0, 1.6))
    mesh.add_box(METAL, (0.0, 22.0, -18.7), (64.0, 4.0, 1.4))
    mesh.add_box(WOOD, (0.0, 12.0, 18.65), (43.0, 14.0, 1.2))
    if opened:
        mesh.add_box(INSIDE, (0.0, 24.15, 0.0), (54.0, 0.7, 27.0))

    # Flejes laterales y bisagras traseras.
    for x in (-20.0, 20.0):
        mesh.add_box(METAL, (x, 12.0, 18.95), (4.0, 24.0, 2.0))
        mesh.add_box(METAL, (x, 24.0, -18.7), (10.0, 4.0, 2.0))
    for x in (-28.0, 28.0):
        for y in (3.5, 20.5):
            mesh.add_cylinder_z(METAL, (x, y, 20.0), 1.0, 1.8)

    add_barrel_lid(mesh, opened)

    # Placa central; el candado adicional sólo existe en la variante cerrada.
    mesh.add_box(METAL, (0.0, 15.0, 19.4), (10.0, 12.0, 2.8))
    mesh.add_cylinder_z(METAL, (0.0, 15.0, 21.0), 1.1, 1.4)
    if locked:
        mesh.add_box(LOCK, (0.0, 10.5, 22.0), (14.0, 11.0, 4.0))
        mesh.add_box(LOCK, (-5.0, 18.0, 21.7), (2.6, 9.0, 3.2))
        mesh.add_box(LOCK, (5.0, 18.0, 21.7), (2.6, 9.0, 3.2))
        mesh.add_box(LOCK, (0.0, 22.5, 21.7), (12.6, 2.6, 3.2))
    return mesh


def generate(project_root: Path) -> None:
    model_dir = project_root / "models" / "caelum" / "props" / "stash"
    sprite_dir = project_root / "sprites"
    model_dir.mkdir(parents=True, exist_ok=True)
    sprite_dir.mkdir(parents=True, exist_ok=True)

    make_wood_texture(model_dir / "ca_stash_wood.png")
    make_metal_texture(model_dir / "ca_stash_metal.png")
    make_lock_texture(model_dir / "ca_stash_lock.png")
    make_inside_texture(model_dir / "ca_stash_inside.png")
    make_chest(opened=False, locked=False).write(model_dir / "ca_stash_closed.obj")
    make_chest(opened=True, locked=False).write(model_dir / "ca_stash_open.obj")
    make_chest(opened=False, locked=True).write(model_dir / "ca_stash_locked.obj")

    for frame in ("A", "B", "C"):
        make_transparent_sprite(sprite_dir / f"CAHC{frame}0.png")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Root that contains the runtime models/ and sprites/ directories.",
    )
    arguments = parser.parse_args()
    generate(arguments.project_root.resolve())


if __name__ == "__main__":
    main()
