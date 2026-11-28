"""Editable ring, sweep and relief geometry for the native character sculpts."""

from dataclasses import dataclass
from io import BytesIO
from math import cos, sin, pi
import numpy as np
from PIL import Image, ImageDraw
from character_mesh_frames import Surface

MATERIALS = (
    "skin cheek lip brow ivory iris pupil glint hair hairlight cloth seam trim sash "
    "pants leather sole brass fur furshade furcream nose ear horn hooftip rock ember "
    "mark fang claw metal dark"
).split()
COLORS = dict(
    zip(
        MATERIALS,
        [
            (182, 127, 93),
            (162, 98, 76),
            (141, 80, 66),
            (75, 52, 43),
            (215, 196, 162),
            (99, 106, 83),
            (40, 34, 33),
            (241, 217, 173),
            (63, 43, 35),
            (88, 65, 51),
            (184, 172, 145),
            (134, 122, 101),
            (214, 201, 167),
            (113, 48, 39),
            (73, 75, 73),
            (88, 57, 40),
            (56, 45, 40),
            (168, 126, 64),
            (137, 110, 86),
            (93, 77, 65),
            (183, 152, 122),
            (63, 48, 43),
            (151, 109, 91),
            (125, 101, 74),
            (65, 56, 49),
            (84, 62, 58),
            (214, 100, 46),
            (72, 53, 39),
            (217, 194, 151),
            (109, 91, 72),
            (153, 156, 150),
            (42, 43, 43),
        ],
    )
)


def paint(palette, pattern=None):
    """Small painted material tiles with broad value groups and directional brush marks."""
    colors = {**COLORS, **palette}
    tile = 48
    atlas = Image.new("RGB", (tile * 8, tile * 4))
    for i, material in enumerate(MATERIALS):
        tint = np.asarray(colors[material], dtype=float)
        rng = np.random.default_rng(731 + i)

        def color(k):
            return tuple(np.clip(tint * k, 0, 255).astype(int))

        img = Image.new("RGB", (tile, tile), color(1))
        draw = ImageDraw.Draw(img)
        if material not in ("eye", "iris", "pupil", "glint", "ivory", "fang"):
            amount = (
                75 if material in ("fur", "furshade", "hair", "rock", "pants", "cloth", "leather") else 28
            )
            for _ in range(amount):
                x, y = rng.integers(-4, tile, 2)
                k = rng.choice([0.92, 0.96, 1.03, 1.07])
                draw.line((x, y, x + rng.integers(-2, 3), y + rng.integers(3, 10)), fill=color(k), width=2)
        if material == "fur" and pattern == "jaguar":
            for x, y in [(5, 8), (23, 4), (38, 16), (16, 27), (40, 39), (3, 42)]:
                draw.arc((x - 4, y - 3, x + 4, y + 3), 10, 285, fill=color(0.42), width=2)
                draw.point((x, y), fill=color(0.65))
        if material == "hair" and pattern == "combed":
            # Each patch of highlight is carried along the UV flow of a lock.
            for x in range(tile):
                phase = 2 * pi * x / (tile - 1)
                value = 1 + 0.115 * cos(12 * phase + 0.55 * sin(3 * phase)) + 0.047 * cos(7 * phase - 0.4)
                draw.line((x, 0, x, tile - 1), fill=color(value))
        # The native sector light can be uniform. Paint broad form shadows into
        # each material ramp so cheeks, ribs and folded cloth still read there.
        values = np.linspace(1.23, 0.43, tile)[:, None, None]
        pixels = np.asarray(img, dtype=float) * values
        pixels[:, :, 2] += np.linspace(-2, 5, tile)[:, None]
        atlas.paste(Image.fromarray(np.uint8(np.clip(pixels, 0, 255))), ((i % 8) * tile, (i // 8) * tile))
    buffer = BytesIO()
    atlas.save(buffer, "PNG")
    return buffer.getvalue()


@dataclass
class Piece:
    joint: str
    vertices: np.ndarray
    triangles: np.ndarray
    uv: np.ndarray


class Sculpt:
    def __init__(self):
        self.parts = []

    def rings(self, joint, material, rings):
        points = np.asarray(rings, dtype=float)
        levels, sides = points.shape[:2]
        vertices = []
        uv = []
        faces = []
        mat = MATERIALS.index(material)

        def add(point, u, v):
            vertices.append(point)
            uv.append(((mat % 8 + 0.035 + 0.93 * u) / 8, (mat // 8 + 0.035 + 0.93 * v) / 4))

        for k, ring in enumerate(points):
            for j in range(sides + 1):
                add(ring[j % sides], j / sides, 1 - k / (levels - 1))
        for k in range(levels - 1):
            for j in range(sides):
                a = k * (sides + 1) + j
                b = a + sides + 1
                faces.extend(((a, a + 1, b + 1), (a, b + 1, b)))
        for k, reverse in ((0, True), (levels - 1, False)):
            a = len(vertices)
            add(points[k].mean(0), 0.5, 0.5)
            for j in range(sides):
                lo = k * (sides + 1) + j
                faces.append((a, lo + 1, lo) if reverse else (a, lo, lo + 1))
        self.parts.append(Piece(joint, np.asarray(vertices), np.asarray(faces), np.asarray(uv)))

    def loft(self, joint, mat, rows, n=14, power=1.0, sculpt=None):
        """Rows are height, sagittal center, lateral center, depth and half-width."""
        rings = []
        for z, x, y, rx, ry in rows:
            ring = []
            for j in range(n):
                t = 2 * pi * j / n
                c = cos(t)
                s = sin(t)
                xyz = (x + rx * np.sign(c) * abs(c) ** power, y + ry * np.sign(s) * abs(s) ** power, z)
                ring.append(sculpt(*xyz, t) if sculpt else xyz)
            rings.append(ring)
        self.rings(joint, mat, rings)

    def sweep(self, joint, mat, rows, n=10):
        """Rows are XYZ center, side radius and radius in the bend plane."""
        rows = np.asarray(rows, dtype=float)
        rings = []
        tangents = (
            rows[np.minimum(np.arange(len(rows)) + 1, len(rows) - 1), :3]
            - rows[np.maximum(np.arange(len(rows)) - 1, 0), :3]
        )
        dominant = np.abs(tangents / np.maximum(np.linalg.norm(tangents, axis=1)[:, None], 1e-9)).mean(0)
        axis = np.eye(3)[np.argmin(dominant)]
        for row, direction in zip(rows, tangents):
            h = direction / max(np.linalg.norm(direction), 1e-9)
            wider = axis - np.dot(axis, h) * h
            wider /= max(np.linalg.norm(wider), 1e-9)
            across = np.cross(h, wider)
            rings.append(
                [
                    row[:3] + wider * row[3] * cos(2 * pi * j / n) + across * row[4] * sin(2 * pi * j / n)
                    for j in range(n)
                ]
            )
        self.rings(joint, mat, rings)

    def oval(self, joint, mat, center, radius, n=12, levels=7):
        x, y, z = center
        a, b, c = radius
        rows = []
        for theta in np.linspace(-pi / 2 + 0.025, pi / 2 - 0.025, levels):
            rows.append((z + c * sin(theta), x, y, a * cos(theta), b * cos(theta)))
        self.loft(joint, mat, rows, n)

    def patch(self, joint, mat, outline, crest):
        # A raised, tapered facet for pinnae, locks, eyelids or decorative metal.
        points = np.asarray([*outline, crest], dtype=float)
        m = len(outline)
        center = np.mean(points[:m], axis=0)
        back = center + (center - np.asarray(crest)) * 0.20
        points = np.vstack([points, back])
        faces = []
        for i in range(m):
            faces.extend([(i, (i + 1) % m, m), ((i + 1) % m, i, m + 1)])
        if np.dot(np.cross(points[1] - points[0], points[m] - points[0]), points[0] - points.mean(0)) < 0:
            faces = [tuple(reversed(f)) for f in faces]
        mat = MATERIALS.index(mat)
        uv = [
            (
                (mat % 8 + 0.5 + 0.4 * cos(i * 2 * pi / m)) / 8,
                (mat // 8 + 0.5 + 0.4 * sin(i * 2 * pi / m)) / 4,
            )
            for i in range(m)
        ]
        uv.extend([((mat % 8 + 0.5) / 8, (mat // 8 + 0.5) / 4)] * 2)
        self.parts.append(Piece(joint, points, np.asarray(faces), np.asarray(uv)))


def shaded_uv(part):
    xyz = part.vertices
    tri = part.triangles
    normals = np.cross(xyz[tri[:, 1]] - xyz[tri[:, 0]], xyz[tri[:, 2]] - xyz[tri[:, 0]])
    normals /= np.maximum(np.linalg.norm(normals, axis=1, keepdims=True), 1e-9)
    unique, inverse = np.unique(np.round(xyz, 5), axis=0, return_inverse=True)
    smooth = np.zeros_like(unique)
    for corner in range(3):
        np.add.at(smooth, inverse[tri[:, corner]], normals)
    normal = smooth[inverse]
    normal /= np.maximum(np.linalg.norm(normal, axis=1, keepdims=True), 1e-9)
    # Same warm three-quarter key as the painted folkloric figures. The original
    # longitudinal coordinate keeps brush marks ordered along fabrics and fur.
    uvs = part.uv.copy()
    tile_y = np.floor(uvs[:, 1] * 4)
    light = np.clip(0.52 + normal @ np.array([0.24, -0.34, 0.49]), 0.045, 0.96)
    uvs[:, 1] = (tile_y + 0.045 + 0.91 * (1 - light)) / 4
    return uvs


def surfaces(pieces, shader, transform):
    """Keep native surface limits and each joint's animated coordinates."""
    result = []
    positions = []
    faces = []
    uv = []
    count = 0

    def flush():
        result.append(Surface(np.concatenate(positions, axis=1), np.vstack(faces), np.vstack(uv), shader))

    for part in pieces:
        if count + len(part.vertices) > 3900:
            flush()
            positions = []
            faces = []
            uv = []
            count = 0
        poses = transform(part)
        positions.append(poses)
        faces.append(part.triangles + count)
        uv.append(shaded_uv(part))
        count += len(part.vertices)
    if positions:
        flush()
    return result
