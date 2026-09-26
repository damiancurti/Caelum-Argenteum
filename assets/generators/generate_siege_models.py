#!/usr/bin/env python3
"""Original siege-preview models for issue #18.

Builds deterministic OBJ meshes for the reusable cannon, battering ram and
destructible gate, plus the transparent sprite frames used to bind each visual
state. The meshes reuse the project's muted station/stash materials; this
generator does not invent balance values, mass, damage or reload timing.
"""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import List, Sequence, Tuple

from PIL import Image

from generate_environment_models import Mesh, add, subtract, multiply, normalize, cross


Point = Tuple[float, float, float]

# One map unit (MU) is 1/32 of a metre in this project's physics convention.
SPEC = json.loads(Path(__file__).with_name("siege_visuals.json").read_text(encoding="utf-8"))
MAP_UNITS_PER_METER = SPEC["map_units_per_metre"]

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


def add_beam(mesh: Mesh, material: str, start: Point, end: Point,
             width: float, depth: float) -> None:
    axis = normalize(subtract(end, start))
    reference = (0, 0, 1) if abs(axis[2]) < 0.85 else (0, 1, 0)
    a = multiply(normalize(cross(axis, reference)), width / 2)
    b = multiply(normalize(cross(axis, a)), depth / 2)
    rings = [[add(p, add(multiply(a, i), multiply(b, j)))
              for i, j in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
             for p in (start, end)]
    mesh.add_quad(material, tuple(reversed(rings[0])))
    mesh.add_quad(material, rings[1])
    for i in range(4):
        j = (i + 1) % 4
        mesh.add_quad(material, (rings[0][i], rings[0][j], rings[1][j], rings[1][i]))


def add_tube(mesh: Mesh, material: str, start: Point, end: Point,
             outer: float, inner: float, sides: int = 24) -> None:
    # Annular ends and inner walls: never cap a wheel rim or muzzle with a disk.
    axis = normalize(subtract(end, start))
    ref = (0, 1, 0) if abs(axis[1]) < 0.85 else (1, 0, 0)
    a = normalize(cross(axis, ref))
    b = normalize(cross(axis, a))
    def ring(p, radius):
        return [add(p, add(multiply(a, radius * math.cos(math.tau * i / sides)),
                           multiply(b, radius * math.sin(math.tau * i / sides))))
                for i in range(sides)]
    os, oe, ins, ine = ring(start, outer), ring(end, outer), ring(start, inner), ring(end, inner)
    for i in range(sides):
        j = (i + 1) % sides
        for face in ((os[i], os[j], oe[j], oe[i]), (ins[j], ins[i], ine[i], ine[j]),
                     (os[j], os[i], ins[i], ins[j]), (oe[i], oe[j], ine[j], ine[i])):
            mesh.add_quad(material, face)


def add_wheel(mesh: Mesh, center: Point, radius: float, width: float) -> None:
    cx, cy, cz = center
    for material, outer, inner, thickness in (
        (IRON, radius, radius * 0.92, width),
        (WOOD, radius * 0.925, radius * 0.77, width * 0.86),
    ):
        add_tube(mesh, material, (cx, cy, cz - thickness / 2),
                 (cx, cy, cz + thickness / 2), outer, inner)
    for i in range(12):
        angle = math.tau * i / 12
        direction = (math.cos(angle), math.sin(angle), 0)
        add_beam(mesh, WOOD, add(center, multiply(direction, radius * 0.16)),
                 add(center, multiply(direction, radius * 0.82)), radius * 0.10, width * 0.48)
    mesh.add_frustum(WOOD, (cx, cy, cz - width * 0.8), (cx, cy, cz + width * 0.8),
                     radius * 0.23, radius * 0.23, 16)
    for side in (-1, 1):
        mesh.add_frustum(IRON, (cx, cy, cz + side * width * 0.65),
                         (cx, cy, cz + side * width * 0.87), radius * 0.17, radius * 0.17, 16)


def cannon_state(name: str, recoil: float, breech_open: bool) -> Mesh:
    mesh = Mesh(name)
    spec = SPEC['cannon']
    # A rigid field carriage recoils as a whole; no modern sliding recoil cradle.
    for side in (-1, 1):
        add_beam(mesh, IRON, (-50, 6, side * 6), (4, 24, side * 13), 7, 5)
        add_box(mesh, IRON, (2, 26, side * 12), (22, 12, 4))
        add_box(mesh, IRON, (-48, 4, side * 6), (12, 4, 8))
    add_box(mesh, IRON, (-18, 14, 0), (6, 5, 21))
    mesh.add_frustum(IRON, (4, 18, -29), (4, 18, 29), 2.4, 2.4, 12)
    cx, cy, cz = spec['wheel_center']
    for side in (-1, 1):
        add_wheel(mesh, (cx, cy, side * cz), spec['wheel_radius'], spec['wheel_width'])
    breech, muzzle = tuple(spec['breech']), tuple(spec['muzzle'])
    # Stepped steel tube, trunnions and an actual recessed 75 mm bore.
    shoulder = (-4, 32, 0)
    muzzle_base = (muzzle[0] - 4, muzzle[1], 0)
    mesh.add_frustum(IRON, breech, shoulder, 7.8, 7.2, 24, True, False)
    mesh.add_frustum(IRON, shoulder, muzzle_base, 7.2, 3.4, 24, False, False)
    bore = spec['calibre_metres'] * MAP_UNITS_PER_METER / 2
    add_tube(mesh, IRON, muzzle_base, muzzle, 3.7, bore)
    mesh.add_frustum(INSIDE, (muzzle[0] - 12, 32, 0), muzzle, bore, bore, 24, True, False)
    mesh.add_frustum(IRON, (2, 32, -17), (2, 32, 17), 3, 3, 16)
    # Sliding wedge and fixed receiver outline. Open state reveals the recess.
    add_box(mesh, IRON, (-23, 32, 0), (8, 15, 16))
    add_box(mesh, INSIDE, (-27.1, 32, 0), (0.2, 9, 10))
    slide = 11 if breech_open else 0
    add_box(mesh, IRON, (-28, 32, slide), (3, 10, 12))
    add_beam(mesh, IRON, (-30, 32, slide + 5), (-30, 24, slide + 9), 1.5, 1.5)
    add_box(mesh, WOOD, (-30, 24, slide + 11), (2, 2, 6))
    add_beam(mesh, IRON, (-17, 17, 0), (-17, 25, 0), 2, 2)
    mesh.vertices = [(x + recoil, y, z) for x, y, z in mesh.vertices]
    return mesh


def ram_state(name: str, travel: float) -> Mesh:
    mesh = Mesh(name)
    spec = SPEC['ram']
    for z in (-30, 30):
        add_box(mesh, WOOD, (-16, 16, z), (150, 8, 8))
    for x in (-48, 48):
        add_box(mesh, WOOD, (x, 18, 0), (8, 8, 70))
        mesh.add_frustum(IRON, (x, 15, -42), (x, 15, 42), 2, 2, 12)
        for side in (-1, 1):
            add_wheel(mesh, (x, 15, side * 38), 15, 7)
    top = spec['suspension_top_y']
    for x in spec['suspension_x']:
        for side in (-1, 1):
            add_beam(mesh, WOOD, (x, 20, side * 30), (x, top, side * 13), 6, 6)
            add_box(mesh, IRON, (x, 24, side * 29), (7, 8, 7))
        add_box(mesh, WOOD, (x, top, 0), (9, 7, 38))
    for side in (-1, 1):
        add_beam(mesh, WOOD, (-72, 20, side * 30), (12, top - 2, side * 13), 4, 4)
    # Rigid moving assembly; all states preserve the same log length and head.
    moving = Mesh(name + '_moving')
    start, end = tuple(spec['log_start']), tuple(spec['log_end'])
    radius = spec['log_radius']
    moving.add_frustum(WOOD, start, end, radius, radius, 16)
    for x in (-72, -18, 15):
        add_tube(moving, IRON, (x - 2, 44, 0), (x + 2, 44, 0), radius + 0.7, radius)
    moving.add_frustum(IRON, end, (30, 44, 0), radius + 1, 14, 16)
    add_box(moving, IRON, (32, 44, 0), (4, 25, 25))
    for side in (-1, 1):
        for x in (-72, -42, -12):
            add_box(moving, WOOD, (x, 41, side * 16), (4, 4, 17))
    for x in spec['suspension_x']:
        for side in (-1, 1):
            # Paired iron suspension rods stay attached in every displayed pose.
            mesh.add_frustum(IRON, (x, top - 3, side * 9),
                             (x + travel, 49, side * 9), 0.9, 0.9, 8)
    offset = len(mesh.vertices)
    mesh.vertices.extend((x + travel, y, z) for x, y, z in moving.vertices)
    mesh.uvs.extend(moving.uvs)
    mesh.faces.extend((mat, tuple(i + offset for i in face)) for mat, face in moving.faces)
    return mesh


def gate_state(name: str, material: str, state: str) -> Mesh:
    mesh = Mesh(name)
    spec = SPEC['gate']
    width, height = [m * MAP_UNITS_PER_METER for m in spec['opening_metres']]
    half = width / 2
    thickness = spec['wood_thickness_metres'] * MAP_UNITS_PER_METER
    jamb, depth, seam = spec['jamb_width'], spec['frame_depth'], spec['seam']
    for side in (-1, 1):
        add_box(mesh, STONE, (side * (half + jamb / 2), height / 2, 0), (jamb, height, depth))
    add_box(mesh, STONE, (0, height + jamb / 2, 0), (width + 2 * jamb, jamb, depth))
    # Flush sill: the open passage has no raised wooden/stone trip block.
    add_box(mesh, STONE, (0, -1, 0), (width + 2 * jamb, 2, depth))
    for side in (-1, 1):
        leaf = Mesh(name + '_leaf')
        center = side * half / 2
        leaf_width = half - seam
        # Solid panel backing with shallow plank grooves, never a picket fence.
        add_box(leaf, WOOD, (center, height / 2, 0), (leaf_width, height, thickness))
        face = thickness / 2
        for i in range(1, 6):
            x = center - leaf_width / 2 + i * leaf_width / 6
            for front in (-1, 1):
                add_box(leaf, INSIDE, (x, height / 2, front * (face + 0.12)), (0.13, height, 0.08))
        rail_material = WOOD if material == 'wood' else IRON
        for y in (height * 0.16, height * 0.5, height * 0.84):
            for front in (-1, 1):
                add_box(leaf, rail_material, (center, y, front * (face + 0.55)),
                        (leaf_width - 1, 4, 1.1))
                if material != 'wood':
                    for i in range(6):
                        x = center - leaf_width / 2 + (i + 0.5) * leaf_width / 6
                        leaf.add_frustum(IRON, (x, y, front * (face + 1.1)),
                                         (x, y, front * (face + 1.6)), 0.65, 0.45, 8)
        for front in (-1, 1):
            z = front * (face + 0.6)
            add_beam(leaf, rail_material, (center - side * 20, 18, z),
                     (center + side * 20, height - 18, z), 3.2, 1)
        if material == 'armored':
            # Exterior iron cladding; rear construction remains visible.
            clad = spec['outer_cladding_metres'] * MAP_UNITS_PER_METER
            for row in range(3):
                add_box(leaf, IRON, (center, (row + 0.5) * height / 3, face + 2),
                        (leaf_width - 0.3, height / 3 - 0.35, clad))
                for x in (center - 19, center, center + 19):
                    for y in (row * height / 3 + 2, (row + 1) * height / 3 - 2):
                        leaf.add_frustum(IRON, (x, y, face + 2.1), (x, y, face + 2.6), 0.7, 0.5, 8)
        for y in (height * 0.16, height * 0.84):
            leaf.add_frustum(IRON, (side * (half - 1.3), y - 3, 0),
                             (side * (half - 1.3), y + 3, 0), 1.3, 1.3, 12)
        for front in (-1, 1):
            z = front * (face + (3 if material == 'armored' and front == 1 else 1.9))
            x = side * 5
            for y in (43, 52):
                add_box(leaf, IRON, (x, y, z), (3, 2, 3))
            add_box(leaf, IRON, (x, 47.5, z + front * 1.5), (1.5, 10, 1.5))
        if state == 'damaged':
            # Surface scars retain the closed silhouette and leaf dimensions.
            for front in (-1, 1):
                z = front * (face + (2.3 if material == 'armored' and front == 1 else 0.25))
                for dx, y, dy in ((-9, 35, 18), (7, 61, -13), (-3, 75, -20)):
                    add_beam(leaf, INSIDE, (center + dx, y, z),
                             (center + dx + side * 5, y + dy, z), 0.75, 0.08)
        if state == 'broken':
            leaf.vertices = [rot_y(p, (side * half, 0), side * spec['open_degrees'])
                             for p in leaf.vertices]
        offset = len(mesh.vertices)
        mesh.vertices.extend(leaf.vertices)
        mesh.uvs.extend(leaf.uvs)
        mesh.faces.extend((mat, tuple(i + offset for i in face)) for mat, face in leaf.faces)
    return mesh


def make_transparent_sprite(path: Path) -> None:
    Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(path, optimize=True)


def generate() -> None:
    root = Path(__file__).resolve().parents[2]
    model_dir = root / "src/models/caelum/siege"
    sprite_dir = root / "src/sprites"
    model_dir.mkdir(parents=True, exist_ok=True)
    sprite_dir.mkdir(parents=True, exist_ok=True)

    for state, recoil, opened in SPEC['cannon']['states']:
        name = f'ca_siege_cannon_{state}'
        cannon_state(name, recoil, opened).write(model_dir / f'{name}.obj')
    for state, travel in SPEC['ram']['states']:
        name = f'ca_siege_ram_{state}'
        ram_state(name, travel).write(model_dir / f'{name}.obj')
    for variant in SPEC['gate']['variants']:
        for state in ('intact', 'damaged', 'broken'):
            name = f"{variant['stem']}_{state}"
            gate_state(name, variant['material'], state).write(model_dir / f'{name}.obj')
    frames = [('CSGN', 'ABCD'), ('CRAM', 'ABC')]
    frames.extend((variant['sprite'], 'ABC') for variant in SPEC['gate']['variants'])
    for prefix, letters in frames:
        for frame in letters:
            make_transparent_sprite(sprite_dir / f'{prefix}{frame}0.png')
    write_model_definitions(root / 'src/MODELDEF')
    write_gate_gallery(root / 'src/caelum/world/CaelumSiegeAssets.zs')
    print('Generated 16 siege meshes and 16 sprite frames.')


def write_gate_gallery(path: Path) -> None:
    text = path.read_text(encoding='utf-8')
    begin = '        // BEGIN GENERATED SIEGE GATE GALLERY'
    end = '        // END GENERATED SIEGE GATE GALLERY'
    prefix, rest = text.split(begin, 1)
    _, suffix = rest.split(end, 1)
    lines = []
    for variant, x in zip(SPEC['gate']['variants'], SPEC['gallery']['gate_material_x']):
        for state, y in zip(('Intact', 'Damaged', 'Broken'), SPEC['gallery']['gate_state_y']):
            lines.append(f'        SpawnState("{variant["actor"]}", ({x}, {y}, 0), "{state}");')
    path.write_text(prefix + begin + '\n' + '\n'.join(lines) + '\n' + end + suffix, encoding='utf-8')


MODEL_BEGIN = "// --- BEGIN GENERATED CAELUM SIEGE MODELS ---"
MODEL_END = "// --- END GENERATED CAELUM SIEGE MODELS ---"


def write_model_definitions(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    if MODEL_BEGIN in text and MODEL_END in text:
        prefix, rest = text.split(MODEL_BEGIN, 1)
        _, suffix = rest.split(MODEL_END, 1)
        suffix = suffix.strip("\n")
    else:
        prefix, suffix = text, ""
    models = [
        ("CaelumSiegeCannon", "ca_siege_cannon_ready.obj", "ca_siege_cannon_loading.obj",
         "ca_siege_cannon_firing.obj", "ca_siege_cannon_recovery.obj", "CSGN", "ABCD"),
        ("CaelumSiegeRam", "ca_siege_ram_ready.obj", "ca_siege_ram_strike.obj",
         "ca_siege_ram_recovery.obj", None, "CRAM", "ABC"),
    ]
    for variant in SPEC['gate']['variants']:
        stem = variant['stem']
        models.append((variant['actor'], f'{stem}_intact.obj', f'{stem}_damaged.obj',
                       f'{stem}_broken.obj', None, variant['sprite'], 'ABC'))
    lines = [MODEL_BEGIN, "// Reusable siege preview meshes; states only, no mechanics."]
    for actor, m0, m1, m2, m3, sprite_prefix, frames in models:
        # Slots are simultaneous model parts, not alternative visual states.
        # Each frame gets an independent definition containing only slot zero.
        for model, frame in zip((m0, m1, m2, m3), frames):
            lines.extend((f"Model {actor}", "{", '    Path "models/caelum/siege"',
                          f'    Model 0 "{model}"', "    Scale 1.0 1.0 1.0",
                          "    CorrectPixelStretch", "    DontCullBackFaces",
                          f"    FrameIndex {sprite_prefix} {frame} 0 0", "}", ""))
    lines.append(MODEL_END)
    path.write_text(prefix.rstrip("\n") + "\n\n" + "\n".join(lines) + ("\n" + suffix if suffix else "") + "\n", encoding="utf-8")


if __name__ == "__main__":
    generate()
