#!/usr/bin/env python3
"""Original siege-preview models for issue #18.

Builds deterministic OBJ meshes for the reusable cannon, battering ram and
destructible gate, plus the transparent sprite frames used to bind each visual
state. The meshes reuse the project's muted station/stash materials; this
generator does not invent balance values, mass, damage or reload timing.
"""

from __future__ import annotations

import math
from pathlib import Path
from typing import List, Sequence, Tuple

from PIL import Image

from generate_environment_models import Mesh


Point = Tuple[float, float, float]

# One map unit (MU) is 1/32 of a metre in this project's physics convention.
MAP_UNITS_PER_METER = 32.0

WOOD = "models/caelum/props/stations/ca_station_wood.png"
IRON = "models/caelum/props/stations/ca_station_iron.png"
BRASS = "models/caelum/props/stations/ca_station_brass.png"
CLOTH = "models/caelum/props/stations/ca_station_cloth.png"
STONE = "models/caelum/props/stations/ca_station_stone.png"
INSIDE = "models/caelum/props/stash/ca_stash_inside.png"


def add_box(mesh: Mesh, material: str, center: Point, size: Point) -> None:
    cx, cy, cz = center
    sx, sy, sz = size
    x0, x1 = cx - sx / 2.0, cx + sx / 2.0
    y0, y1 = cy - sy / 2.0, cy + sy / 2.0
    z0, z1 = cz - sz / 2.0, cz + sz / 2.0
    a = (x0, y0, z0)
    b = (x1, y0, z0)
    c = (x1, y1, z0)
    d = (x0, y1, z0)
    e = (x0, y0, z1)
    f = (x1, y0, z1)
    g = (x1, y1, z1)
    h = (x0, y1, z1)
    for face in (
        (a, b, f, e),
        (b, c, g, f),
        (c, d, h, g),
        (d, a, e, h),
        (d, c, b, a),
        (e, f, g, h),
    ):
        mesh.add_quad(material, face)


def rot_y(point: Point, pivot_xz: Point, degrees: float) -> Point:
    x, y, z = point
    px, pz = pivot_xz
    rad = math.radians(degrees)
    c, s = math.cos(rad), math.sin(rad)
    dx, dz = x - px, z - pz
    return (px + dx * c + dz * s, y, pz - dx * s + dz * c)


def add_box_rot_y(
    mesh: Mesh,
    material: str,
    center: Point,
    size: Point,
    degrees: float,
    pivot_xz: Point,
) -> None:
    cx, cy, cz = center
    sx, sy, sz = size
    x0, x1 = cx - sx / 2.0, cx + sx / 2.0
    y0, y1 = cy - sy / 2.0, cy + sy / 2.0
    z0, z1 = cz - sz / 2.0, cz + sz / 2.0
    corners = (
        (x0, y0, z0),
        (x1, y0, z0),
        (x1, y1, z0),
        (x0, y1, z0),
        (x0, y0, z1),
        (x1, y0, z1),
        (x1, y1, z1),
        (x0, y1, z1),
    )
    a, b, c, d, e, f, g, h = (rot_y(p, pivot_xz, degrees) for p in corners)
    for face in (
        (a, b, f, e),
        (b, c, g, f),
        (c, d, h, g),
        (d, a, e, h),
        (d, c, b, a),
        (e, f, g, h),
    ):
        mesh.add_quad(material, face)


def add_wheel(mesh: Mesh, center: Point, radius: float, width: float) -> None:
    cx, cy, cz = center
    mesh.add_frustum(IRON, (cx, cy, cz - width / 2.0), (cx, cy, cz + width / 2.0),
                     radius, radius, 12, True, True, 0.0)
    mesh.add_frustum(WOOD, (cx, cy, cz - width * 0.38), (cx, cy, cz + width * 0.38),
                     radius * 0.84, radius * 0.84, 12, True, True, 0.0)
    mesh.add_frustum(IRON, (cx, cy, cz - width * 0.25), (cx, cy, cz + width * 0.25),
                     radius * 0.18, radius * 0.18, 8, True, True, 0.0)
    for spoke in range(6):
        angle = math.tau * spoke / 6.0
        end = (cx + math.cos(angle) * radius * 0.78, cy + math.sin(angle) * radius * 0.78, cz)
        add_box(mesh, WOOD, end, (radius * 0.22, radius * 0.22, width * 0.42))


def build_cannon_carriage(mesh: Mesh, barrel_offset: float) -> None:
    # Two wooden trail cheeks, an iron axle and two spoked wheels.
    for z in (-18.0, 18.0):
        add_box(mesh, WOOD, (-14.0, 14.0, z), (72.0, 8.0, 6.0))
    add_box(mesh, IRON, (4.0, 18.0, 0.0), (8.0, 6.0, 44.0))
    add_wheel(mesh, (4.0, 18.0, -24.0), 17.0, 8.0)
    add_wheel(mesh, (4.0, 18.0, 24.0), 17.0, 8.0)
    add_box(mesh, IRON, (20.0, 10.0, 0.0), (6.0, 5.0, 30.0))


def build_cannon(mesh: Mesh, barrel_end: Point, muzzle: Point, breech_z: float) -> None:
    build_cannon_carriage(mesh, 0.0)
    # Barrel along X: breech at barrel_end, muzzle at muzzle. Raised/loading
    # states tilt the line by moving the muzzle vertically.
    mesh.add_frustum(IRON, barrel_end, muzzle, 8.0, 5.5, 12, True, True, 0.0)
    mesh.add_frustum(BRASS, muzzle, (muzzle[0] + 3.0, muzzle[1], muzzle[2]),
                     6.2, 7.0, 12, True, True, 0.0)
    add_box(mesh, IRON, (barrel_end[0] - 8.0, barrel_end[1], barrel_end[2]),
            (14.0, 16.0, breech_z))
    # Trunnion caps on each side of the carriage.
    for z in (-15.0, 15.0):
        add_box(mesh, BRASS, (2.0, 26.0, z), (5.0, 9.0, 4.0))


def cannon_state(name: str, muzzle_y: float, recoil: float, breech_open: bool) -> None:
    mesh = Mesh(name)
    muzzle = (58.0 + recoil, muzzle_y, 0.0)
    breech = (-20.0 + recoil, 32.0, 0.0)
    build_cannon(mesh, breech, muzzle, 12.0 if breech_open else 14.0)
    return mesh


def build_ram(mesh: Mesh, log_end: Point, head_center: Point) -> None:
    # Frame rails, cross beams and four wheels.
    for z in (-30.0, 30.0):
        add_box(mesh, WOOD, (-16.0, 16.0, z), (150.0, 8.0, 8.0))
    for x in (-64.0, 64.0):
        add_box(mesh, WOOD, (x, 28.0, 0.0), (8.0, 8.0, 68.0))
    for x in (-48.0, 48.0):
        add_wheel(mesh, (x, 18.0, -38.0), 15.0, 7.0)
        add_wheel(mesh, (x, 18.0, 38.0), 15.0, 7.0)
    # Striking assembly: the moving log and its iron head.
    mesh.add_frustum(WOOD, (-92.0, 44.0, 0.0), log_end, 11.0, 11.0, 10, True, True, 0.0)
    mesh.add_frustum(IRON, log_end, head_center, 11.0, 15.0, 10, True, True, 0.0)
    mesh.add_frustum(BRASS, head_center, (head_center[0] + 3.0, head_center[1], head_center[2]),
                     15.2, 16.0, 10, True, True, 0.0)


def build_gate_frame(mesh: Mesh) -> None:
    # Stone door frame: side jambs, lintel and threshold.
    for z in (-16.0, 16.0):
        add_box(mesh, STONE, (-86.0, 118.0, z), (14.0, 220.0, 12.0))
    add_box(mesh, STONE, (0.0, 228.0, 0.0), (172.0, 16.0, 12.0))
    add_box(mesh, STONE, (0.0, 8.0, 0.0), (172.0, 16.0, 12.0))


def build_gate_intact(mesh: Mesh) -> None:
    build_gate_frame(mesh)
    # Two wooden leaves with a visible central seam and iron rails/pulls.
    for x in (-70.0, -50.0, -30.0, -10.0, 10.0, 30.0, 50.0, 70.0):
        add_box(mesh, WOOD, (x, 116.0, 0.0), (15.0, 208.0, 10.0))
    for y in (32.0, 116.0, 200.0):
        add_box(mesh, IRON, (-40.0, y, 0.0), (76.0, 7.0, 10.0))
        add_box(mesh, IRON, (40.0, y, 0.0), (76.0, 7.0, 10.0))
    add_box(mesh, IRON, (-8.0, 116.0, 8.0), (6.0, 24.0, 4.0))
    add_box(mesh, IRON, (8.0, 116.0, 8.0), (6.0, 24.0, 4.0))


def build_gate_damaged(mesh: Mesh) -> None:
    build_gate_frame(mesh)
    # Two intact outer planks, then a forced central gap.
    for x in (-70.0, -10.0, 10.0, 70.0):
        add_box(mesh, WOOD, (x, 116.0, 0.0), (15.0, 208.0, 10.0))
    for x in (-40.0, 40.0):
        add_box(mesh, WOOD, (x, 116.0, 0.0), (15.0, 140.0, 10.0))
    for y in (32.0, 200.0):
        add_box(mesh, IRON, (-44.0, y, 0.0), (104.0, 7.0, 10.0))
        add_box(mesh, IRON, (44.0, y, 0.0), (104.0, 7.0, 10.0))
    # A fallen plank leaning against the lower gap.
    add_box_rot_y(mesh, WOOD, (0.0, 40.0, 10.0), (15.0, 74.0, 4.0), 18.0, (-80.0, 0.0))


def build_gate_broken(mesh: Mesh) -> None:
    build_gate_frame(mesh)
    # Both halves folded open around their outer hinges.
    for side in (-1.0, 1.0):
        hinge = (side * 86.0, 0.0)
        angle = -42.0 if side < 0 else 42.0
        for offset in (-24.0, 0.0, 24.0):
            add_box_rot_y(mesh, WOOD, (side * (42.0 + offset), 116.0, 0.0),
                          (15.0, 208.0, 10.0), angle, hinge)
        add_box_rot_y(mesh, IRON, (side * 42.0, 116.0, 0.0), (76.0, 7.0, 10.0), angle, hinge)


def make_transparent_sprite(path: Path) -> None:
    Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(path, optimize=True)


def generate() -> None:
    root = Path(__file__).resolve().parents[2]
    model_dir = root / "src/models/caelum/siege"
    sprite_dir = root / "src/sprites"
    model_dir.mkdir(parents=True, exist_ok=True)
    sprite_dir.mkdir(parents=True, exist_ok=True)

    cannon_state("ca_siege_cannon_ready", 32.0, 0.0, False).write(model_dir / "ca_siege_cannon_ready.obj")
    cannon_state("ca_siege_cannon_loading", 38.0, 0.0, True).write(model_dir / "ca_siege_cannon_loading.obj")
    cannon_state("ca_siege_cannon_firing", 32.0, -10.0, False).write(model_dir / "ca_siege_cannon_firing.obj")
    cannon_state("ca_siege_cannon_recovery", 32.0, -4.0, False).write(model_dir / "ca_siege_cannon_recovery.obj")

    ram_ready = Mesh("ca_siege_ram_ready")
    build_ram(ram_ready, (20.0, 44.0, 0.0), (30.0, 44.0, 0.0))
    ram_ready.write(model_dir / "ca_siege_ram_ready.obj")
    ram_strike = Mesh("ca_siege_ram_strike")
    build_ram(ram_strike, (48.0, 44.0, 0.0), (58.0, 44.0, 0.0))
    ram_strike.write(model_dir / "ca_siege_ram_strike.obj")
    ram_recovery = Mesh("ca_siege_ram_recovery")
    build_ram(ram_recovery, (4.0, 44.0, 0.0), (14.0, 44.0, 0.0))
    ram_recovery.write(model_dir / "ca_siege_ram_recovery.obj")

    gate_intact = Mesh("ca_siege_gate_intact")
    build_gate_intact(gate_intact)
    gate_intact.write(model_dir / "ca_siege_gate_intact.obj")
    gate_damaged = Mesh("ca_siege_gate_damaged")
    build_gate_damaged(gate_damaged)
    gate_damaged.write(model_dir / "ca_siege_gate_damaged.obj")
    gate_broken = Mesh("ca_siege_gate_broken")
    build_gate_broken(gate_broken)
    gate_broken.write(model_dir / "ca_siege_gate_broken.obj")

    for prefix, frames in (("CSGN", "ABCD"), ("CRAM", "ABC"), ("CAGT", "ABC")):
        for frame in frames:
            make_transparent_sprite(sprite_dir / f"{prefix}{frame}0.png")

    write_model_definitions(root / "src/MODELDEF")
    print("Generated 10 siege meshes and 10 sprite frames.")


MODEL_BEGIN = "// --- BEGIN GENERATED CAELUM SIEGE MODELS ---"
MODEL_END = "// --- END GENERATED CAELUM SIEGE MODELS ---"


def write_model_definitions(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    if MODEL_BEGIN in text and MODEL_END in text:
        prefix, rest = text.split(MODEL_BEGIN, 1)
        _, suffix = rest.split(MODEL_END, 1)
        suffix = "\n" + suffix.lstrip("\n")
    else:
        prefix, suffix = text, ""
    models = (
        ("CaelumSiegeCannon", "ca_siege_cannon_ready.obj", "ca_siege_cannon_loading.obj",
         "ca_siege_cannon_firing.obj", "ca_siege_cannon_recovery.obj", "CSGN", "ABCD"),
        ("CaelumSiegeRam", "ca_siege_ram_ready.obj", "ca_siege_ram_strike.obj",
         "ca_siege_ram_recovery.obj", None, "CRAM", "ABC"),
        ("CaelumSiegeGate", "ca_siege_gate_intact.obj", "ca_siege_gate_damaged.obj",
         "ca_siege_gate_broken.obj", None, "CAGT", "ABC"),
    )
    lines = [MODEL_BEGIN, "// Reusable siege preview meshes; states only, no mechanics."]
    for actor, m0, m1, m2, m3, sprite_prefix, frames in models:
        lines.append(f"Model {actor}")
        lines.append("{")
        lines.append('    Path "models/caelum/siege"')
        lines.append(f'    Model 0 "{m0}"')
        lines.append(f'    Model 1 "{m1}"')
        lines.append(f'    Model 2 "{m2}"')
        if m3:
            lines.append(f'    Model 3 "{m3}"')
        lines.append("    Scale 1.0 1.0 1.0")
        lines.append("    CorrectPixelStretch")
        lines.append("    DontCullBackFaces")
        for index, frame in enumerate(frames):
            lines.append(f"    FrameIndex {sprite_prefix} {frame} {index} 0")
        lines.append("}")
        lines.append("")
    lines.append(MODEL_END)
    path.write_text(prefix.rstrip("\n") + "\n\n" + "\n".join(lines) + suffix + "\n", encoding="utf-8")


if __name__ == "__main__":
    generate()
