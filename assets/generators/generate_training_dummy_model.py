#!/usr/bin/env python3
"""Generate the original #98 mannequin from its editable design and UV palette.

Requires Pillow 12.1.0. No downloaded geometry, textures or game data.
The runtime OBJ is itself an editable mesh; DESIGN.json retains every part.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

from generate_environment_models import Mesh, add, subtract, multiply, normalize, cross

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/training_dummy/DESIGN.json"
BEGIN = "// BEGIN GENERATED TRAINING DUMMY"
END = "// END GENERATED TRAINING DUMMY"


class AtlasMesh(Mesh):
    def __init__(self, design: dict):
        super().__init__("ca_training_dummy")
        self.design = design

    def add_polygon(self, material, points, uvs):
        x, y, w, h = self.design["tiles"][material]["rect"]
        aw, ah = self.design["atlas_size"]
        # Keep bilinear samples inside each tile, including mip boundaries.
        inset = 4
        mapped = [((x + inset + u * (w - 2 * inset)) / aw,
                   1 - (y + inset + (1 - v) * (h - 2 * inset)) / ah)
                  for u, v in uvs]
        runtime = self.design["runtime"]
        super().add_polygon(runtime["directory"] + "/" + runtime["atlas"], points, mapped)

    def add_ellipsoid(self, material, center, radii, seed, rings=4, segments=10, irregularity=0):
        # Continuous spherical UVs avoid a separate leather seam on every polygon.
        def vertex(r, s):
            latitude = -math.pi/2 + math.pi*r/rings
            longitude = math.tau*s/segments
            return tuple(center[i] + radii[i]*n for i, n in enumerate(
                (math.cos(latitude)*math.cos(longitude), math.sin(latitude),
                 math.cos(latitude)*math.sin(longitude))))
        for r in range(rings):
            for s in range(segments):
                grid = [(r, s), (r, s+1), (r+1, s+1), (r+1, s)]
                if r == 0:
                    grid = [grid[0], grid[2], grid[3]]
                elif r == rings-1:
                    grid = grid[:3]
                grid.reverse()
                self.add_polygon(material, [vertex(a, b) for a, b in grid],
                                 [(b/segments, a/rings) for a, b in grid])

    def add_frustum(self, material, start, end, start_radius, end_radius, sides=8):
        axis = normalize(subtract(end, start))
        reference = (1, 0, 0) if abs(axis[0]) <= .85 else (0, 1, 0)
        one = normalize(cross(axis, reference))
        two = normalize(cross(axis, one))
        def radial(i):
            a = math.tau*i/sides
            return add(multiply(one, math.cos(a)), multiply(two, math.sin(a)))
        def cap_uv(i):
            a = math.tau*i/sides
            return (.5+.48*math.cos(a), .5+.48*math.sin(a))
        for i in range(sides):
            a, b = radial(i), radial(i+1)
            low_a, low_b = add(start, multiply(a, start_radius)), add(start, multiply(b, start_radius))
            high_a, high_b = add(end, multiply(a, end_radius)), add(end, multiply(b, end_radius))
            self.add_polygon(material, [low_a, low_b, high_b, high_a],
                             [(i/sides, 0), ((i+1)/sides, 0), ((i+1)/sides, 1), (i/sides, 1)])
            self.add_polygon(material, [start, low_b, low_a], [(.5, .5), cap_uv(i+1), cap_uv(i)])
            self.add_polygon(material, [end, high_a, high_b], [(.5, .5), cap_uv(i), cap_uv(i+1)])

    def write(self, path):
        lines = ["# Original Caelum Argenteum training mannequin, issue #98.",
                 "# Editable source: assets/training_dummy/DESIGN.json",
                 "# OBJ axes: X width, Y height, positive Z front.",
                 f"o {self.object_name}"]
        lines += [f"v {x:.6f} {y:.6f} {z:.6f}" for x, y, z in self.vertices]
        lines += [f"vt {u:.6f} {v:.6f}" for u, v in self.uvs]
        lines += ["s 1", f"usemtl {self.faces[0][0]}"]
        lines += ["f " + " ".join(f"{i}/{i}" for i in face) for _, face in self.faces]
        path.write_bytes(("\n".join(lines) + "\n").encode("utf-8"))


def texture(design, path):
    rng = random.Random(design["seed"])
    atlas = Image.new("RGB", tuple(design["atlas_size"]))
    for name, tile in design["tiles"].items():
        ox, oy, width, height = tile["rect"]
        base = tile["color"]
        image = Image.new("RGB", (width, height))
        pixels = image.load()
        for y in range(height):
            for x in range(width):
                grain = rng.randrange(-8, 9)
                if name == "wood":
                    grain += int(9 * math.sin(x * .24 + math.sin(y * .026) * 2))
                    grain += int(4 * math.sin(x * 1.4 + y * .02))
                elif name == "leather":
                    grain += int(4 * math.sin(x * .13) * math.cos(y * .21))
                elif name in ("iron", "brass"):
                    grain += int(7 * math.sin(y * .15))
                if name != "target":
                    # Painted diffuse relief remains readable in sector-only light.
                    u, v = x / width, y / height
                    grain += int(31 * math.cos(4*math.pi*(u-.19)))
                    grain += int(16 * math.sin(math.pi*v) - 23 * v*v)
                pixels[x, y] = tuple(max(0, min(255, c + grain)) for c in base)
        draw = ImageDraw.Draw(image)
        if name == "target":
            for radius, color in design["target_rings"]:
                r = (width - 8) * .5 * radius
                draw.ellipse((width / 2-r, height / 2-r, width / 2+r, height / 2+r), fill=tuple(color))
            # Restrained abrasions retain the old concentric target's readability.
            for _ in range(95):
                x, y = rng.randrange(8, width-8), rng.randrange(8, height-8)
                old = image.getpixel((x, y))
                draw.line((x, y, x+1, y+2), fill=tuple(max(0, c-17) for c in old))
        elif name == "leather":
            for p in range(10, width-10, 7):
                draw.line((p, 22, p+2, 22), fill=(130, 92, 60))
                draw.line((p, height-23, p+2, height-23), fill=(115, 74, 48))
            for _ in range(60):
                x, y = rng.randrange(10, width-10), rng.randrange(25, height-25)
                old = image.getpixel((x, y))
                draw.line((x, y, x+2, y+1), fill=tuple(min(255, c+15) for c in old))
        atlas.paste(image, (ox, oy))
    atlas.save(path, optimize=False, compress_level=9)


def target(mesh, center, radius):
    x, y, z = center
    sides = 24
    mesh.add_frustum("brass", (x, y, z-.55), (x, y, z+.2), radius, radius, sides)
    points = [(x + radius*.92*math.cos(math.tau*i/sides),
               y + radius*.92*math.sin(math.tau*i/sides), z+.22) for i in range(sides)]
    for i in range(sides):
        j = (i+1) % sides
        a, b = math.tau*i/sides, math.tau*j/sides
        mesh.add_polygon("target", [(x, y, z+.22), points[i], points[j]],
                         [(.5, .5), (.5+.5*math.cos(a), .5+.5*math.sin(a)),
                          (.5+.5*math.cos(b), .5+.5*math.sin(b))])


def generate(runtime_root):
    design = json.loads(SOURCE.read_text(encoding="utf-8"))
    spec = design["runtime"]
    output = runtime_root / spec["directory"]
    output.mkdir(parents=True, exist_ok=True)
    mesh = AtlasMesh(design)
    for material, start, end, r1, r2, sides in design["frustums"]:
        mesh.add_frustum(material, tuple(start), tuple(end), r1, r2, sides)
    for material, center, radii in design["ellipsoids"]:
        mesh.add_ellipsoid(material, center, radii, 0, rings=6, segments=12, irregularity=0)
    for sign in (-1, 1):
        for material, center, radii in design["symmetric_ellipsoids"]:
            mesh.add_ellipsoid(material, (center[0]*sign, *center[1:]), radii,
                               0, rings=4, segments=10, irregularity=0)
        for material, start, end, r1, r2, sides in design["symmetric_frustums"]:
            mesh.add_frustum(material, (start[0]*sign, *start[1:]),
                             (end[0]*sign, *end[1:]), r1, r2, sides)
    for panel in design["targets"]:
        target(mesh, panel["center"], panel["radius"])
    for center in design["rivets"]:
        mesh.add_ellipsoid("brass", center, (.42, .42, .42), 0, rings=3, segments=6, irregularity=0)
    mesh.write(output / spec["mesh"])
    texture(design, output / spec["atlas"])
    blocks = [BEGIN]
    for actor in spec["actors"]:
        blocks += [f"Model {actor}", "{", f'    Path "{spec["directory"]}"',
                   f'    Model 0 "{spec["mesh"]}"',
                   "    Scale " + " ".join(str(n) for n in spec["scale"]),
                   f'    AngleOffset {spec["angle_offset"]}',
                   "    CorrectPixelStretch", "    DontCullBackFaces",
                   f'    FrameIndex {spec["sprite"]} {spec["frame"]} 0 0', "}"]
    blocks += [END]
    modeldef = runtime_root / "MODELDEF"
    current = modeldef.read_text(encoding="utf-8")
    block = "\n".join(blocks)
    if BEGIN in current:
        first, rest = current.split(BEGIN, 1)
        _, last = rest.split(END, 1)
        current = first + block + last
    else:
        current = current.rstrip() + "\n\n" + block + "\n"
    modeldef.write_bytes(current.encode("utf-8"))
    report = {
        "issue": 98,
        "vertices": len(mesh.vertices),
        "triangles": sum(len(face)-2 for _, face in mesh.faces),
        "material_surfaces": 1,
        "bounds_obj": [[min(v[i] for v in mesh.vertices), max(v[i] for v in mesh.vertices)] for i in range(3)],
        "max_horizontal_radius": max(math.hypot(v[0], v[2]) for v in mesh.vertices),
        "atlas_size": design["atlas_size"],
        "sha256": {name: hashlib.sha256((output / name).read_bytes()).hexdigest()
                   for name in (spec["mesh"], spec["atlas"])}
    }
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-root", type=Path, default=ROOT / "src")
    generate(parser.parse_args().runtime_root)
