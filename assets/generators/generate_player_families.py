"""Sculpt fourteen original modular player forms and bake their existing animation slots."""

import hashlib
import json
from functools import lru_cache
from io import BytesIO
from math import cos, sin, pi
import re
import numpy as np
from PIL import Image

from character_mesh_frames import ROOT, Surface, animate, encode, rigid_track
from sculpted_character_art import Sculpt, paint, surfaces
from sculpted_humanoid import figure, head

SRC = ROOT / "src"
OUT = SRC / "models/caelum/players"
REL = "models/caelum/players/"
CAT = json.loads((ROOT / "assets/generators/appearance_catalog.json").read_bytes())
FAMILIES = ("human", "caelith", "goblin", "wolf", "bear", "puma", "jaguar")


def shade(color, rgb):
    return tuple(np.uint8(np.clip(np.asarray(color) * rgb, 0, 255)))


def coat_palette(family, color):
    ratio = {"bear": 0.66, "wolf": 0.67, "puma": 0.76, "jaguar": 0.66}.get(family, 0.73)
    return {
        "fur": color,
        "furshade": shade(color, ratio),
        "furcream": tuple(np.uint8(np.array(color) * 0.46 + [116, 107, 91])),
        "skin": color,
        "lip": shade(color, 0.66),
        "cheek": shade(color, 0.88),
        "ear": shade(color, [0.93, 0.79, 0.78]),
        "nose": (61, 48, 43),
        "iris": (158, 139, 84),
    }


def animal_head(family, female):
    m = Sculpt()
    j = "head"
    canine = family == "wolf"
    bear = family == "bear"
    width = {"wolf": 9.8, "bear": 12.1, "puma": 9.7, "jaguar": 11.2}[family] * (0.95 if female else 1.0)
    length = {"wolf": 19.7, "bear": 17.4, "puma": 14.6, "jaguar": 15.4}[family]
    m.loft(
        j,
        "fur",
        [
            (137.5, -1, 0, 6.4, 7.0),
            (141, -1, 0, 7.1, 8.5),
            (146, -1, 0, 8.3, width * 0.92),
            (152, -1, 0, 8.9, width * 0.96),
        ],
        18,
    )
    m.loft(
        j,
        "fur",
        [
            (146, 3, 0, 6.7, width * 0.55),
            (149.5, 2, 0, 9.4, width * 0.84),
            (154.2, 0.8, 0, 10.7, width),
            (159, -0.3, 0, 11.3, width * 1.03),
            (163.5, -1.2, 0, 10.25, width * 0.98),
            (166.5, -1.8, 0, 8.0, width * 0.80),
            (168, -2.2, 0, 3.7, width * 0.43),
        ],
        20,
    )
    if family == "jaguar":
        # Place rosettes in skull coordinates, preserving their shape in profile.
        levels = [
            (146, 3, 6.7, 0.55),
            (149.5, 2, 9.4, 0.84),
            (154.2, 0.8, 10.7, 1),
            (159, -0.3, 11.3, 1.03),
            (163.5, -1.2, 10.25, 0.98),
            (166.5, -1.8, 8, 0.80),
            (168, -2.2, 3.7, 0.43),
        ]

        def coat(t, z):
            _, cx, rx, ry = [np.interp(z, [v[0] for v in levels], [v[k] for v in levels]) for k in range(4)]
            return (cx + (rx + 0.12) * cos(t), (width * ry + 0.15) * sin(t), z)

        for row, (z0, count) in enumerate(((153.3, 12), (157.0, 14), (161.8, 14), (165, 10))):
            for i in range(count):
                t = (i + 0.45 * (row % 2)) * 2 * pi / count
                if cos(t) > 0.67 and z0 < 160:
                    continue
                for angle, span in ((0.15, 2.32), (3.25, 1.55)):
                    arc = []
                    for a in np.linspace(angle, angle + span, 5):
                        angle_t = t + (0.095 + 0.019 * (i % 2)) * cos(a)
                        z = z0 + (1.11 + 0.20 * (i % 3)) * sin(a)
                        arc.append((*coat(angle_t, z), 0.35, 0.32))
                    m.sweep(j, "mark", arc, 6)
    m.sweep(
        j,
        "fur",
        [
            (5, 0, 157, width * 0.65, 5.5),
            (9, 0, 155.9, width * 0.59, 4.6),
            (length - 4, 0, 154.3, width * (0.42 if canine else 0.53), 3.8),
            (length - 0.9, 0, 153.9, 3.35, 2.45),
        ],
        14,
    )
    m.sweep(
        j,
        "furcream",
        [
            (4.8, 0, 149.6, width * 0.56, 3.1),
            (10, 0, 148.95, width * 0.49, 2.6),
            (length - 1.2, 0, 150.55, 3.1, 1.7),
        ],
        13,
    )
    m.sweep(
        j,
        "lip",
        [
            (9, 0, 149.8, width * 0.51, 0.88),
            (length - 3.6, 0, 150.1, 3.9, 0.92),
            (length - 0.9, 0, 151.0, 2.7, 0.52),
        ],
        12,
    )
    for side in (-1, 1):
        s = side
        m.oval(j, "furcream", (length - 4, s * 2.75, 152.2), (4.2, 3.4, 2.45), 12, 8)
        if not bear:
            for n in range(3):
                m.oval(
                    j,
                    "mark",
                    (length - 3.6 + n * 0.63, s * (5.43 - n * 0.20), 152.75 - n * 0.35),
                    (0.34, 0.3, 0.27),
                    7,
                    4,
                )

        # Eyes follow the actual elliptical skull in both frontal and side views.
        # A narrow lid rim and the bridge of the muzzle cover the orbital edges.
        def orbit(t, h, lift=0.12):
            levels = ((154.2, 0.8, 10.7, 1.0), (159, -0.3, 11.3, 1.03), (163.5, -1.2, 10.25, 0.98))
            z = 158.4 + h
            _, cx, rx, ry = [np.interp(z, [v[0] for v in levels], [v[k] for v in levels]) for k in range(4)]
            angle = 0.675 + t
            return cx + (rx + lift) * cos(angle), s * (width * ry + lift) * sin(angle), z

        contour = [
            (-0.215, -0.22),
            (-0.12, 0.61),
            (0.025, 0.90),
            (0.18, 0.70),
            (0.225, 0.29),
            (0.13, -0.40),
            (-0.025, -0.69),
            (-0.14, -0.54),
        ]
        for mat, scale, offset in (("dark", 1.15, 0.19), ("iris", 0.83, 0.41)):
            m.patch(
                j,
                mat,
                [orbit(t * scale, h * scale, offset) for t, h in contour],
                orbit(0, 0.05, offset + 0.18),
            )
        m.patch(
            j,
            "pupil",
            [orbit(0.064 * cos(a), 0.04 + 0.63 * sin(a), 0.68) for a in np.arange(12) * pi / 6],
            orbit(0, 0.04, 0.71),
        )
        m.sweep(
            j,
            "furshade",
            [
                (*orbit(-0.235, -0.22, 0.17), 0.26, 0.25),
                (*orbit(-0.10, 0.95, 0.27), 0.43, 0.39),
                (*orbit(0.085, 1.20, 0.28), 0.56, 0.52),
                (*orbit(0.25, 0.62, 0.14), 0.28, 0.26),
            ],
            8,
        )
        m.sweep(
            j,
            "furcream",
            [
                (*orbit(-0.17, -0.65, 0.16), 0.18, 0.18),
                (*orbit(0.01, -0.96, 0.24), 0.28, 0.25),
                (*orbit(0.19, -0.51, 0.12), 0.19, 0.16),
            ],
            7,
        )
        if canine:
            m.patch(
                j,
                "furshade",
                [(1, s * 4.8, 165), (-3, s * 7.6, 177.6), (-5.0, s * 11.2, 166.5), (-2.5, s * 10, 162.2)],
                (1.4, s * 7.9, 167.1),
            )
            m.patch(
                j,
                "ear",
                [(1.4, s * 5.9, 165.8), (-2.3, s * 7.9, 174.3), (-2.1, s * 9.7, 166.2)],
                (0.9, s * 7.9, 167.6),
            )
        else:
            er = 4 if bear else 3.7 if family == "puma" else 3.45
            ex = -4.1
            ey = width * 0.77
            ez = 166.4
            rings = []
            for x, scale in [
                (ex - 1, 0.70),
                (ex, 1),
                (ex + 1.45, 0.93),
                (ex + 1.9, 0.76),
                (ex + 0.6, 0.43),
                (ex + 0.2, 0.06),
            ]:
                rings.append(
                    [
                        (
                            x - 0.65 * sin(t),
                            s
                            * (
                                ey
                                + er
                                * scale
                                * cos(t)
                                * (1 - 0.32 * max(0, sin(t)) if family == "puma" else 1)
                                + 0.6 * sin(t)
                            ),
                            ez + er * (1.62 if family == "puma" else 1.13) * scale * sin(t),
                        )
                        for t in np.arange(14) * 2 * pi / 14
                    ]
                )
            m.rings(j, "furshade", rings[:3])
            m.rings(j, "ear", rings[2:])
        if canine or bear:
            for k in range(3):
                m.patch(
                    j,
                    "furshade" if k == 1 else "fur",
                    [
                        (-2, s * (width - 2), 158 - k * 2),
                        (2, s * (width - 0.5), 156 - k * 2),
                        (-5 - k, s * (width + 2 - k * 0.4), 148 - k * 1.5),
                        (-6, s * (width - 0.9), 153 - k * 2),
                    ],
                    (-2, s * (width + 1), 155 - k * 2),
                )
    m.loft(
        j,
        "nose",
        [
            (152.1, length - 0.25, 0, 1.35, 1.4),
            (153.0, length + 0.15, 0, 2.15, 3.25),
            (155.1, length + 0.1, 0, 2.0, 3.55),
            (155.8, length - 0.2, 0, 1.45, 2.25),
        ],
        12,
        power=0.75,
    )
    return m


def hair(index, style):
    m = Sculpt()
    j = "head"
    female = bool(index % 2)
    goblin = index // 2 == 2
    width = (9.15 if not female else 8.55) * (1.14 if goblin else 1)
    rings = []
    # The scalp follows the cranium; the swept hairline opens around the face
    # and drops behind the ears before rising into an asymmetrical crown.
    for k, (rx, ry, top) in enumerate(
        [
            (9.8, width * 1.07, 0),
            (10.5, width * 1.09, 0.26),
            (9.8, width * 1.01, 0.59),
            (7.0, width * 0.77, 0.86),
            (2.2, width * 0.30, 1),
        ]
    ):
        ring = []
        for t in np.arange(24) * 2 * pi / 24:
            line = 157.8 + 5.0 * cos(t) + 0.8 * sin(2 * t + style)
            z = line * (1 - top) + (171.2 + (1.4 if style == 1 else 0)) * top
            ring.append((-1.15 + rx * cos(t) - top * 0.85, ry * sin(t) + sin(style) * top * 0.65, z))
        rings.append(ring)
    m.rings(j, "hair", rings)
    for n in range(6):
        t = n * pi / 3 + 0.24
        end = 158 + 4.7 * cos(t)
        m.sweep(
            j,
            "hairlight",
            [
                (-2 + 4.9 * cos(t - 0.38), width * 0.52 * sin(t - 0.38), 170.3, 0.5, 0.61),
                (-1 + 8.6 * cos(t - 0.19), width * 0.9 * sin(t - 0.19), 167.6, 0.71, 0.72),
                (-1.0 + 9.85 * cos(t), width * 1.05 * sin(t), end + 1, 0.18, 0.3),
            ],
            7,
        )
    if female and style in (0, 2):
        # Temple locks frame the cheek in front view, then turn over the shoulders.
        for side in (-1, 1):
            m.sweep(
                j,
                "hair",
                [
                    (3.0, side * (width - 0.6), 165.2, 2.2, 1.9),
                    (4.0, side * (width + 0.15), 160.9, 2.6, 1.85),
                    (4.35, side * (width + 0.5), 155, 2.1, 1.75),
                    (3.4, side * (width + 1.05), 150, 2.2, 1.76),
                    (2.15, side * (width + 1.3), 144.3, 1.68, 1.56),
                    (3.65, side * (width + 0.18), 140.8, 0.4, 0.5),
                ],
                10,
            )
    if style in (1, 2, 3) or female:
        length = 13 if style == 0 else 12 if style == 1 else 21 if style == 2 else 10
        if not female:
            length *= 0.62
        for k in range(7):
            t = pi * 0.52 + k * pi * 0.96 / 6
            x = -1 + 9.8 * cos(t)
            y = width * 1.0 * sin(t)
            off = abs(sin(t))
            m.sweep(
                j,
                "hairlight" if k % 3 == 0 else "hair",
                [
                    (x * 0.86, y * 0.91, 164.3, 2.55, 2.35),
                    (x, y, 158.3, 2.6, 2.7),
                    (x - 0.5, y * (1 + 0.07 * off), 155 - length * 0.32, 2.2, 2.35),
                    (x - 1.5, y * 0.9, 156 - length, 1.12, 0.86),
                    (x - 0.6, y * 0.88, 154.5 - length, 0.22, 0.20),
                ],
                9,
            )
    if style == 3:
        m.oval(j, "hair", (-12, 0, 154.8), (4.2, 4.7, 5.1), 12, 8)
        for k in range(5):
            m.oval(
                j,
                "hairlight" if k % 2 else "hair",
                (-13 + 0.45 * k, (-1) ** k * 1.05, 151.9 - k * 2.7),
                (2.35 - k * 0.20, 2.8 - k * 0.22, 2.7 - k * 0.18),
                10,
                6,
            )
    return m


@lru_cache(maxsize=None)
def socket(joint):
    basis = np.vstack([np.zeros(3), np.eye(3)])
    frames = rigid_track(basis, joint)
    return frames[:, 0], frames[:, 1:] - frames[:, :1]


def follow(points, joint):
    offset, basis = socket(joint)
    return np.einsum("vi,fij->fvj", points, basis) + offset[:, None]


def main():
    output = {}

    def emit(name, blob):
        path = OUT / name
        path.write_bytes(blob)
        output[path.relative_to(ROOT).as_posix()] = hashlib.sha256(blob).hexdigest()

    heights = [
        int(v)
        for v in re.search(
            r"heights\[\] = \{([^}]+)", (SRC / "caelum/character/CaelumAppearanceRegistry.zs").read_text()
        )[1].split(",")
    ]
    for i in range(14):
        family = FAMILIES[i // 2]
        female = bool(i % 2)
        factor = heights[2 * i] / 170

        def fit(part):
            coords = part.vertices.copy()
            if family == "goblin":
                # Pombero's compact leg-to-trunk ratio and broad ribcage.
                z = coords[:, 2]
                compression = np.interp(z, [0, 52, 96, 140, 170], [0, 47, 88, 138, 170]) - z
                socket_weight = np.clip((25 - np.abs(coords[:, 1])) / 8, 0, 1)
                coords[:, 2] += compression * socket_weight
                coords[:, 0] *= 1 + 0.075 * socket_weight
            if part.joint == "head":
                # Cranial mass, muzzle angle and the broad lateral ear are especially
                # important to the Pombero silhouette. Keep the neck in its collar.
                if family == "goblin":
                    z = coords[:, 2].copy()
                    w = np.clip((z - 142) / 10, 0, 1)
                    coords[:, 1] *= 1 + w * 0.26
                    coords[:, 0] *= 1 + w * (0.21 if female else 0.25)
                    coords[:, 0] += w * 1.4
                elif family in ("human", "caelith") and female:
                    w = np.clip((159 - coords[:, 2]) / 10, 0, 1) * np.clip((coords[:, 2] - 144) / 5, 0, 1)
                    coords[:, 1] *= 1 - w * 0.08
            return coords * factor

        def body_motion(part):
            coords = fit(part)
            if part.joint.startswith("hand"):
                return follow(coords, "left_hand" if part.joint == "hand1" else "right_hand")
            return animate(coords)

        def head_motion(part):
            return follow(fit(part), "face")

        parts = figure(family, female)
        cloth = {
            "human": (165, 149, 119),
            "caelith": (165, 165, 144),
            "goblin": (160, 139, 104),
            "wolf": (155, 151, 132),
            "bear": (152, 136, 112),
            "puma": (173, 157, 129),
            "jaguar": (162, 145, 122),
        }[family]
        material = {
            "cloth": cloth,
            "pants": (69, 66, 61),
            "sash": (115, 52, 42),
            "trim": shade(cloth, 1.13),
            "seam": shade(cloth, 0.71),
        }
        emit(f"b{i}.png", paint(material))
        for slot, m in parts.items():
            shader = REL + ("hskin0.png" if slot == "hands" else f"b{i}.png")
            emit(f"b{i}_{slot}.md3", encode(f"{family} {slot}", surfaces(m.parts, shader, body_motion)))
        for variant in range(4 if i < 6 else 1):
            if i < 6:
                m = head(family, female, variant)
                if family == "caelith":
                    for s in (-1, 1):
                        m.patch(
                            "head",
                            "skin",
                            [
                                (0, s * 8.1, 161),
                                (-3, s * 13.8, 164),
                                (-6.5, s * 19.3, 168),
                                (-4.2, s * 13.5, 158.7),
                                (-1, s * 8.85, 154.8),
                            ],
                            (1, s * 12.4, 160.3),
                        )
                        m.patch(
                            "head",
                            "ear",
                            [(0.5, s * 9.3, 160), (-4.6, s * 16.7, 165), (-1.6, s * 12.3, 158.7)],
                            (0.7, s * 11.6, 160.7),
                        )
            else:
                m = animal_head(family, female)
            key = f"head{i}_{variant}"
            emit(key + ".md3", encode(key, surfaces(m.parts, REL + key + "_0.png", head_motion)))
            for tone in range(3):
                if i >= 6:
                    col = shade(CAT["world_fur_hand_tones"][(i - 6) // 2], CAT["fur_multipliers"][tone])
                    palette = coat_palette(family, col)
                else:
                    col = CAT["caelith_tones" if family == "caelith" else "skin_tones"][tone]
                    palette = {
                        "skin": col,
                        "cheek": shade(col, [0.95, 0.84, 0.82]),
                        "ear": shade(col, [0.97, 0.78, 0.76]),
                        "lip": shade(col, [0.84, 0.69, 0.72]),
                        "brow": shade(col, 0.43),
                    }
                emit(f"{key}_{tone}.png", paint(palette))
        if i < 6:
            for style in range(4):
                key = f"hair{i}_{style}"
                emit(
                    key + ".md3",
                    encode(key, surfaces(hair(i, style).parts, REL + key + "_0.png", head_motion)),
                )
                for number, color in enumerate(CAT["hair_colors"]):
                    col = color["rgb"]
                    emit(f"{key}_{number}.png", paint({"hair": col, "hairlight": shade(col, 1.13)}))
        print(i, family, flush=True)
    tones = (
        CAT["skin_tones"]
        + CAT["caelith_tones"]
        + [shade(col, m) for col in CAT["world_fur_hand_tones"] for m in CAT["fur_multipliers"]]
    )
    for i, col in enumerate(tones):
        emit(f"hskin{i}.png", paint({"skin": col}))
    # Preserve the hidden sprite bridge relied on by the modular renderer.
    blank = Surface(np.zeros((1, 3, 3)), np.array([[0, 1, 2]]), np.zeros((3, 2)), REL + "invisible.png")
    emit("conceal.md3", encode("head sprite bridge", [blank]))
    transparent = BytesIO()
    Image.new("RGBA", (2, 2)).save(transparent, "PNG")
    emit("invisible.png", transparent.getvalue())
    data = {
        "issue": 917,
        "previous_issue": 903,
        "references": {
            "humanoid": "assets/source/art/witch_figures_817",
            "goblin_only": "assets/source/art/pombero_455",
            "identity_and_outfits": "assets/source/art/modular_proposals_736/REVIEW.json",
        },
        "geometry": "Original modular three-dimensional sculpts. Faces use geometry for head planes, eye openings, nose, mouth, ears and hair. No projected images.",
        "motion": "33 existing player poses, retargeted to the retained Domingo reference motion and hand sockets.",
        "generator": "assets/generators/generate_player_families.py",
        "sha256": output,
    }
    (ROOT / "assets/source/art/player_families_903/PROVENANCE.json").write_bytes(
        (json.dumps(data, indent=2) + "\n").encode()
    )


if __name__ == "__main__":
    main()
