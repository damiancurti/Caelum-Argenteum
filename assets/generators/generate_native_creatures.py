"""Sculpt the three creature bodies and bake their existing native action poses."""

from dataclasses import replace
from math import cos, sin, pi
import hashlib
import json
import numpy as np

from character_mesh_frames import ROOT, encode
from sculpted_character_art import Sculpt, paint, surfaces
from sculpted_humanoid import figure, head

SRC = ROOT / "src"
MODELS = SRC / "models/caelum/creatures"
ART = ROOT / "assets/source/art/native_creatures_902"
DESIGN = {
    "mandinga": (
        "CaelumMandinga",
        212,
        "miida miidb miwka miwkb mirna mirnb mirnc mirnd mndga mndgb mndgc mndgd mndge mndgf mndgg mndgh mndgi mndgj mndgk mndgl mdbra mdbrb mdbrc mdbrd slmda",
    ),
    "zupay": (
        "CaelumZupayColossus",
        363,
        "zuida zuidb zuwka zuwkb zurna zurnb zurnc zurnd zupya zupyb zupyc zupyd zupye zupyf zupyg zupyh zupyi zupyj zupyk zupyl zupym zupyn zupyo zupyp zupyq zupyr zubra zubrb zubrc zubrd slzua",
    ),
    "rat": (
        "CaelumGiantRat",
        93,
        "ratga ratgb ratgc ratgd ratge ratgf ratgg ratgh ratgi ratgj ratgk ratgl ratgm slrta",
    ),
}


def demon_clothing(kind):
    """Cloth is skinned to the same torso, arms and legs used by each action."""
    king = kind == "zupay"
    m = Sculpt()
    width = 1.23 if king else 1.0

    def coat(rows, material, joint="torso", folds=0.45):
        def fabric(x, y, z, t):
            pleat = folds * (0.58 * sin(8 * t + 0.04 * z) + 0.42 * cos(5 * t - 0.05 * z))
            return x + pleat * cos(t), y + pleat * sin(t), z

        m.loft(
            joint,
            material,
            [(z, x, 0, rx, ry * width) for z, x, rx, ry in rows],
            32,
            power=0.86,
            sculpt=fabric,
        )

    # Cut to fit the chest and the back. The bottom edge projects beyond
    # the hips so the coat reads as fabric when the legs take a step.
    torso = np.array(
        [
            (82, -1, 15, 21),
            (85, -1, 14.8, 20.5),
            (96, -0.4, 13.7, 18.7),
            (104, -0.3, 12.7, 17.0),
            (116, -0.2, 14.0, 19.4),
            (126, 0.1, 18.4, 22.9),
            (133, -0.8, 16.3, 23),
            (137, -0.8, 13.4, 19.1),
            (141, -0.8, 8.4, 9.3),
        ]
    )
    coat(torso if king else torso[2:], "cloth")
    if not king:
        m.loft(
            "pelvis",
            "pants",
            [(83, -0.2, 0, 12.9, 16.8), (90, -0.5, 0, 14, 19.7), (100, -0.3, 0, 13.4, 18.8)],
            24,
            power=0.88,
        )
    for sign in (-1, 1):
        m.loft(
            "arm" + str(sign),
            "skin",
            [
                (87.4, 5.2, sign * 28.1, 3.5, 3.3),
                (94, 4.5, sign * 27.9, 4.1, 3.9),
                (99, 4.0, sign * 27.8, 4.8, 4.4),
            ],
            16,
        )
        sy = 19.4 * width
        m.loft(
            "arm" + str(sign),
            "cloth",
            [
                (95, 4.5, sign * 27.9, 4.8, 4.6),
                (102, 3.1, sign * 27.9, 6.7, 6.3),
                (110, 0.2, sign * 27.5, 6.6, 6.5),
                (116, 0.3, sign * 26.4, 8, 7.6),
                (125, -0.2, sign * (sy + 2.2), 9.9, 10.1),
                (130, -1.0, sign * sy, 10, 10.1),
                (134, -1.25, sign * (sy - 0.6), 8.3, 8.1),
                (136, -1.6, sign * (sy - 1.9), 4.3, 4.6),
            ],
            20,
        )
        m.loft(
            "arm" + str(sign),
            "trim",
            [
                (94.5, 4.6, sign * 27.9, 5.2, 4.9),
                (96.2, 4.35, sign * 27.9, 5.3, 5.1),
                (98.8, 4.0, sign * 27.8, 5.7, 5.55),
            ],
            16,
        )
        # Gathered trousers end above the split hooves.
        c = 12.4
        lower = [
            (19, -0.7, sign * c, 5.2, 5.0),
            (24, -0.8, sign * c, 5.5, 5.1),
            (33, -2, sign * c, 8.9, 7.9),
            (44, 0.1, sign * c, 10.2, 9.05),
            (55, 2.2, sign * c, 10, 8.9),
        ]
        # Under the tunic the breeches end inside the hem. Hidden upper
        # trousers would otherwise poke through the front during a long stride.
        upper = (
            [(66, 0.4, sign * 11.6, 9.1, 8.4)]
            if king
            else [
                (71, 0.1, sign * 11.0, 12.6, 10.1),
                (86, -0.5, sign * 9.7, 13.8, 10.7),
                (96, -0.3, sign * 8.9, 12.5, 10),
            ]
        )
        m.loft("leg" + str(sign), "pants", lower + upper, 18, power=0.9)
    if not king:
        # Cut the opening out of the actual waistcoat surface. Both the
        # outer leather and its thin lining follow the shirt underneath.
        def vest_point(z, t, lift):
            cx, rx, ry = [np.interp(z, torso[:, 0], torso[:, k]) for k in (1, 2, 3)]
            c, s = cos(t), sin(t)
            return (
                cx + (rx + lift) * np.sign(c) * abs(c) ** 0.86,
                (ry + lift) * np.sign(s) * abs(s) ** 0.86,
                z,
            )

        vest = []
        welt = [[], []]
        for z in np.linspace(96, 140, 25):
            gap = np.interp(z, [96, 112, 122, 132, 140], [0.085, 0.07, 0.16, 0.42, 0.73])
            angles = np.linspace(gap, 2 * pi - gap, 46)
            outer = []
            inner = []
            for t in angles:
                down = max(0, (z - 129) / 11) ** 2 * 4.7 * sin(t) ** 2
                outer.append(vest_point(z - down, t, 1.72))
                inner.append(vest_point(z - down, t, 1.02))
            vest.append([*outer, *reversed(inner)])
            for i, pt in enumerate((outer[0], outer[-1])):
                welt[i].append((*pt, 0.42, 0.39))
        m.rings("torso", "leather", vest)
        for line in welt:
            m.sweep("torso", "trim", line, 7)
        for z in (107, 114, 121):
            for sign in (-1, 1):
                x, y, zz = vest_point(z, sign * 0.245, 1.95)
                m.oval("torso", "brass", (x, y, zz), (0.65, 0.89, 0.89), 10, 6)
        coat([(140, -0.4, 8.4, 8.2), (142, -0.5, 7.8, 7.8), (144, -0.5, 7.8, 7.5)], "sash")
    else:
        # Layered knee-length tunic with a flared hem and embroidered borders.
        coat(
            [
                (59, -1, 20.4, 25.5),
                (62, -1, 20.15, 25.3),
                (71, -1, 20.2, 24.3),
                (83, -0.8, 18.4, 22.2),
                (97, -0.5, 14.6, 19.9),
            ],
            "cloth",
            "skirt",
            1.2,
        )
        coat([(59, -1, 20.8, 25.9), (60.4, -1, 20.65, 25.7), (62.0, -1, 20.56, 25.7)], "trim", "skirt", 1.2)

        # The mantle drapes behind the shoulders with a shorter front. A
        # raised collar and contrasting woven hem are visible from both sides.
        def mantle(t, q):
            c, s = cos(t), sin(t)
            front = max(0.0, c)
            bottom = 76 + 42 * front**1.15 + 12 * abs(s)
            z = 145 + (bottom - 145) * q
            rx = np.interp(q, [0, 0.14, 0.36, 0.65, 1], [8.7, 15.8, 20.6, 22.7, 24.8])
            ry = np.interp(q, [0, 0.14, 0.36, 0.65, 1], [9.7, 24.9, 32.8, 33.8, 35.2])
            fold = q * (1.28 * cos(10 * t + 0.3 * q) + 0.42 * sin(5 * t))
            return -1.6 + (rx + fold) * c, (ry + fold) * s, z

        angles = np.arange(48) * 2 * pi / 48

        def mantle_band(mat, levels, lift):
            rings = []
            for q in levels:
                ring = []
                for t in angles:
                    x, y, z = mantle(t, q)
                    ring.append((x + lift * cos(t), y + lift * sin(t), z))
                rings.append(ring)
            m.rings("torso", mat, rings[::-1])

        mantle_band("seam", [0, 0.14, 0.28, 0.40, 0.58, 0.80, 1], 0)
        mantle_band("trim", [0.885, 0.911], 0.32)
        mantle_band("brass", [0.940, 0.956], 0.34)
        coat([(139, -1, 9.3, 8.3), (141, -1, 9.1, 8.2), (145, -1, 8.7, 8.0)], "trim")
        m.oval("torso", "brass", (14.5, 0, 140), (1.6, 2.45, 2.8), 12, 8)
    coat([(95.8, -0.45, 15.8, 20.4), (98, -0.4, 16, 20.5), (103, -0.3, 15.2, 19.4)], "sash", "pelvis", 0.30)
    m.oval("pelvis", "brass", (15.45, 0, 99.5), (1.2, 3.4, 2.45), 12, 7)
    return m.parts


def demon(kind):
    king = kind == "zupay"
    sections = figure(kind, False, monster=True)
    pieces = [p for section in ("boots", "hands") for p in sections[section].parts]
    mask = head(kind, False, 2 if king else 1)
    m = Sculpt()
    # A swept scalp breaks the uninterrupted brow-to-cranium surface while
    # keeping both horn roots and the silhouette of the ears exposed.
    cap = []
    for rx, ry, q in [(9.8, 9.65, 0), (10.4, 10, 0.34), (8.7, 8.5, 0.69), (5.8, 5.9, 0.92), (1.2, 1.4, 1)]:
        ring = []
        for t in np.arange(24) * pi / 12:
            edge = 157 + 5.9 * cos(t) - 1.4 * cos(3 * t) * max(0, cos(t))
            ring.append((-1.4 + rx * cos(t) - q * 1.5, ry * sin(t), edge + (171.4 - edge) * q))
        cap.append(ring)
    m.rings("head", "hair", cap)
    for k in range(7):
        t = pi * 0.54 + k * pi * 0.92 / 6
        x = -1.2 + 9.5 * cos(t)
        y = 9.7 * sin(t)
        m.sweep(
            "head",
            "hair",
            [
                (x * 0.9, y * 0.86, 164, 2.45, 2.1),
                (x, y, 158, 2.8, 2.35),
                (x - 1.0, y * 0.97, 148 if king else 153, 2.1, 1.8),
                (x - 2.1, y * 0.91, 140 + k % 3 if king else 150 + k % 3, 0.22, 0.28),
            ],
            9,
        )
    for side in (-1, 1):
        s = side
        path = (
            [
                (-1, 8, 165, 3.3),
                (-5, 12, 170, 3.5),
                (-11, 17, 174, 3.3),
                (-18, 20, 172, 2.8),
                (-24, 21, 166, 2.15),
                (-26, 23, 160, 1.45),
                (-21, 26, 158, 0.75),
                (-17, 28, 160, 0.16),
            ]
            if king
            else [
                (1, 7.5, 165, 2.9),
                (-1, 10, 169, 3.0),
                (-5, 12, 172, 2.5),
                (-10, 13, 174, 1.7),
                (-14, 12, 173, 0.9),
                (-17, 10, 170, 0.15),
            ]
        )
        m.sweep("head", "horn", [(x, s * y, z, r, r * 0.83) for x, y, z, r in path], 12)
        for i in range(1, 4):
            x, y, z, r = path[i]
            xx, yy, zz, _ = path[i + 1]
            m.sweep(
                "head",
                "hooftip",
                [
                    (x, s * y, z, r * 1.06, r * 0.9),
                    (
                        x + (xx - x) * 0.19,
                        s * (y + (yy - y) * 0.19),
                        z + (zz - z) * 0.19,
                        r * 1.02,
                        r * 0.87,
                    ),
                ],
                12,
            )
        if king:
            for k in range(3):
                m.sweep(
                    "head",
                    "hair",
                    [
                        (-3 - k * 1.8, s * (8 - k * 0.3), 164, 2.9, 2.55),
                        (-8 - k * 2, s * (10 - k), 155, 2.5, 2.2),
                        (-9 - k * 2, s * (11 - k), 146, 1.8, 1.5),
                        (-10 - k * 1.8, s * (13 - k), 137 + k * 2, 0.15, 0.22),
                    ],
                    9,
                )
        # Sculpted cheek ridges and a pointed chin remain legible under side lighting.
        m.patch(
            "head",
            "cheek",
            [(7.3, s * 7.7, 157), (8.5, s * 6.4, 155), (8.5, s * 5.8, 152.3), (8.0, s * 7.2, 153.5)],
            (9.4, s * 6.9, 154.9),
        )
    for side in (-1, 1):
        m.sweep(
            "head",
            "hair",
            [
                (6.2, side * 6.2, 149.4, 0.8, 0.7),
                (8.9, side * 3.6, 147.4, 1.5, 1.1),
                (8.7, side * 1.1, 145.7, 1.9, 1.3),
            ],
            9,
        )
    m.sweep(
        "head",
        "hair",
        [(7, 0, 147.3, 3.45, 2.3), (7.5, 0, 144.8, 2.85, 2.25), (7.7, 0, 140.5, 0.22, 0.38)],
        10,
    )
    m.sweep(
        "tail",
        "skin",
        [
            (-8, 0, 92, 4.2, 4.1),
            (-22, 1, 82, 3.6, 3.4),
            (-31, 3.2, 65, 3.0, 2.9),
            (-42, 7.3, 62, 2.3, 2.4),
            (-50, 11, 70, 1.8, 1.85),
            (-53, 13, 82, 1.2, 1.45),
        ],
        12,
    )
    m.sweep(
        "tail",
        "hair",
        [
            (-51.2, 12, 77.6, 2.7, 2.4),
            (-54.2, 13, 84, 3.1, 2.6),
            (-52, 13.5, 91, 1.15, 0.94),
            (-49, 13.2, 94, 0.14, 0.18),
        ],
        10,
    )
    if not king:
        # Mandinga's existing machete attack has its blade and grip on the right hand.
        m.sweep(
            "hand-1",
            "leather",
            [(4, -28, 77, 1.8, 1.5), (10, -29, 86, 1.6, 1.4), (12, -29.4, 89, 1.8, 1.5)],
            8,
        )
        m.patch(
            "hand-1",
            "metal",
            [(11, -29.6, 88), (16, -30, 87), (40, -31, 109), (44, -31, 116), (33, -31, 111)],
            (25, -32.1, 101),
        )
    return pieces + demon_clothing(kind) + mask.parts + m.parts


def rodent():
    m = Sculpt()
    # Continuous pear-shaped ribcage. The rump reaches its high point behind the shoulders.
    spine = [
        (-10, 0, 24, 8, 10),
        (-5, 0, 29, 16, 18),
        (5, 0, 32, 20, 22),
        (16, 0, 33, 20.5, 22),
        (27, 0, 31, 17.3, 18.5),
        (37, 0, 29, 13.8, 15),
        (45, 0, 28, 10.1, 11.6),
    ]
    m.sweep("torso", "fur", spine, 20)
    m.sweep(
        "head",
        "fur",
        [
            (33, 0, 29, 10, 10),
            (40, 0, 32, 13.2, 13.5),
            (46, 0, 32.7, 12, 13),
            (54, 0, 29, 9.6, 9.4),
            (62, 0, 27.5, 6.5, 6.6),
            (69, 0, 27.1, 3.2, 3.05),
        ],
        18,
    )
    m.oval("head", "nose", (69, 0, 27.5), (2.9, 3.75, 2.65), 12, 7)
    m.sweep("jaw", "furcream", [(49, 0, 23, 7, 5), (56, 0, 22.2, 7.3, 4.1), (64, 0, 24.1, 3.4, 2.4)], 12)
    for side in (-1, 1):
        s = side
        m.oval("head", "furcream", (59.2, s * 5.1, 26.0), (7, 3.5, 3.4), 12, 7)
        m.oval("head", "pupil", (49.4, s * 10.6, 35.5), (3.2, 1.8, 3.05), 12, 8)
        m.oval("head", "glint", (50.4, s * 12.0, 36.45), (0.75, 0.4, 0.65), 8, 5)
        # Concave ears with a thick continuous rim, open towards the nose.
        rings = []
        for dx, radius in [(0, 0.68), (0.4, 1), (2.2, 0.98), (2.9, 0.77), (0.3, 0.47), (-0.4, 0.06)]:
            rings.append(
                [
                    (
                        40 + dx - 3.6 * sin(t),
                        s * (10 + 6.5 * radius * cos(t) + 3.9 * radius * sin(t)),
                        41 + 9 * radius * sin(t),
                    )
                    for t in np.arange(16) * 2 * pi / 16
                ]
            )
        m.rings("head", "fur", rings[:3])
        m.rings("head", "ear", rings[2:])
        m.sweep(
            "head",
            "fang",
            [
                (66, s * 1.1, 25, 0.84, 0.82),
                (66.6, s * 1.1, 22.9, 0.75, 0.80),
                (65.8, s * 1.1, 21.9, 0.43, 0.62),
            ],
            7,
        )
        for k in range(3):
            m.sweep(
                "head",
                "furcream",
                [
                    (62 + k, s * 6.1, 26 + k * 0.62, 0.36, 0.34),
                    (66 - k, s * (13 + k), 26.6 + k * 1.2, 0.27, 0.26),
                    (65 - k * 1.5, s * (21 + 2 * k), 26.7 + k * 2, 0.09, 0.09),
                ],
                6,
            )
        for rear in (False, True):
            joint = ("thigh" if rear else "upper") + str(s)
            foot = ("foot" if rear else "hand") + str(s)
            x = 3 if rear else 37
            m.oval(
                joint,
                "furshade",
                (x, s * (14 if rear else 9), 22 if rear else 23),
                (13, 8, 16) if rear else (7, 4.5, 9),
                14,
                9,
            )
            m.sweep(
                joint,
                "fur",
                [
                    (x + 1, s * 11, 24, 5.6, 6.3),
                    (x + (7 if rear else -2), s * 13, 15, 4.8, 5.1),
                    (x + (-3 if rear else 1), s * 13, 5, 2.8, 3.3),
                ],
                11,
            )
            ax = x + (-3 if rear else 1)
            m.sweep(
                foot,
                "ear",
                [
                    (ax, s * 13, 5.7, 2.5, 2.4),
                    (ax + 4, s * 14, 2.8, 3.1, 2.1),
                    (ax + 8, s * 14, 2.4, 3.25, 1.36),
                ],
                10,
            )
            for k in range(4):
                m.sweep(
                    foot,
                    "ear",
                    [
                        (ax + 6, s * (11.6 + 1.5 * k), 2.4, 0.8, 0.8),
                        (ax + 10, s * (10.7 + 1.85 * k), 1.45, 0.7, 0.64),
                        (ax + 13 - abs(k - 1.5), s * (10 + 2.05 * k), 1.1, 0.35, 0.4),
                    ],
                    7,
                )
    m.sweep(
        "tail",
        "ear",
        [
            (-6, 0, 23, 4.0, 3.9),
            (-19, 1, 19, 3.8, 3.45),
            (-31, 5, 12, 3.1, 2.85),
            (-42, 12, 7, 2.65, 2.45),
            (-52, 17, 5, 2.2, 2.05),
            (-62, 17.5, 5, 1.62, 1.53),
            (-70, 12.4, 6, 1.04, 1.05),
            (-76, 7, 7, 0.27, 0.35),
        ],
        14,
    )
    return m.parts


def rotation(points, pivot, axis, degrees):
    if abs(degrees) < 0.0001:
        return points
    a, b = {"x": (1, 2), "y": (2, 0), "z": (0, 1)}[axis]
    p = points - np.asarray(pivot)
    q = p.copy()
    c = cos(degrees * pi / 180)
    s = sin(degrees * pi / 180)
    q[:, a] = p[:, a] * c - p[:, b] * s
    q[:, b] = p[:, a] * s + p[:, b] * c
    return q + np.asarray(pivot)


def posed(piece, key, frame):
    rat = key == "rat"
    p = piece.vertices.copy()
    j = piece.joint
    sign = 1 if j.endswith("1") and not j.endswith("-1") else -1
    idx = ord(frame[-1]) - 97
    prefix = frame[:-1]
    walk = prefix in ("miwk", "zuwk", "mirn", "zurn") or prefix == "ratg" and idx in (1, 2)
    death = prefix in ("mndg", "zupy") and 6 <= idx <= 11 or prefix == "ratg" and idx >= 5
    sleep = frame.startswith("sl")
    attack = prefix in ("mndg", "zupy") and (idx in (3, 4) or idx >= 12) or prefix == "ratg" and idx == 3
    pain = prefix in ("mndg", "zupy") and idx == 5 or prefix == "ratg" and idx == 4
    phase = [0.82, -0.82, 0.42, -0.42][idx % 4] if walk else 0
    if j == "skirt":
        # Cloth near each knee shares part of that thigh's stride. The belt stays anchored.
        center = posed(replace(piece, joint="pelvis"), key, frame)
        left = posed(replace(piece, joint="thigh1"), key, frame)
        right = posed(replace(piece, joint="thigh-1"), key, frame)
        across = np.clip(0.5 + p[:, 1:2] / 16, 0, 1)
        sway = np.clip((95 - p[:, 2:3]) / 38, 0, 1) * 0.80
        return center * (1 - sway) + (left * across + right * (1 - across)) * sway
    if not rat and j.startswith(("arm", "leg")):
        # Continuous limbs bend across a short elbow/knee transition.
        lower = j.startswith("leg")
        z = p[:, 2].copy()
        upper = "thigh" if lower else "upper"
        distal = "shin" if lower else "fore"

        a = posed(replace(piece, joint=upper + str(sign)), key, frame)
        b = posed(replace(piece, joint=distal + str(sign)), key, frame)
        weight = np.clip(((56 if lower else 116) - z) / (12 if lower else 11), 0, 1)[:, None]
        return a * (1 - weight) + b * weight
    if rat:
        if j.startswith(("upper", "hand", "thigh", "foot")):
            rear = j.startswith(("thigh", "foot"))
            p = rotation(p, ((3 if rear else 37), sign * 11, 24), "y", phase * sign * (26 if rear else -24))
        if j in ("head", "jaw"):
            p = rotation(p, (38, 0, 28), "y", -17 if attack else 10 if pain or sleep else phase * 4)
            if j == "jaw":
                p = rotation(p, (48, 0, 25), "y", 30 if attack else 0)
        if j == "tail":
            weight = np.clip((-p[:, 0] - 5) / 70, 0, 1)
            p[:, 1] += weight * 12 * (phase if walk else 0.25 * cos(idx))
            if sleep or death:
                p = rotation(p, (-7, 0, 23), "z", 56 if sleep else 24)
    else:
        knee = (2, sign * 12.5, 52)
        hip = (0, sign * 10, 94)
        shoulder = (-1, sign * (24 if key == "zupay" else 19), 132)
        if j.startswith(("shin", "foot")):
            p = rotation(p, knee, "y", -max(0, phase * sign) * 32)
        if j.startswith(("shin", "foot", "thigh")):
            p = rotation(p, hip, "y", phase * sign * 26)
        if j.startswith(("fore", "hand")):
            p = rotation(p, (1, sign * 27, 111), "y", (-23 if attack else -5) - max(0, phase * sign) * 12)
        if j.startswith(("upper", "fore", "hand")):
            swing = -phase * sign * 22
            if attack:
                swing += (-113 if idx == 3 else -34 if idx == 4 else -45 - 16 * (idx - 12)) * (
                    1 if key == "zupay" or sign < 0 else 0.25
                )
            if pain:
                swing += -29
            p = rotation(p, shoulder, "y", swing)
        if j == "head":
            p = rotation(
                p,
                (-1, 0, 142),
                "y",
                (-10 + idx * 5 if prefix in ("mdbr", "zubr") else 9 if pain else phase * 2),
            )
        if j == "tail":
            p = rotation(p, (-8, 0, 92), "z", 10 * sin(idx * 1.7) + (22 if sleep else 0))
    if death or sleep:
        f = 1 if sleep else ((idx - (5 if rat else 6)) / (7 if rat else 5))
        pivot = (12, 0, 20) if rat else (0, 0, 86)
        if not rat and j.startswith(("thigh", "shin", "foot")):
            p = rotation(p, (0, sign * 10, 94), "y", f * (25 if sleep else -13))
        p = rotation(p, pivot, "x", (82 if sleep else 91) * f)
        if not rat:
            p = rotation(p, pivot, "y", f * (19 if sleep else -8))
    return p


def main():
    inventory = {}
    for key, (actor, height, sequence) in DESIGN.items():
        model = rodent() if key == "rat" else demon(key)
        palette = (
            {
                "fur": (111, 91, 76),
                "furshade": (91, 72, 62),
                "furcream": (160, 133, 107),
                "ear": (157, 108, 94),
                "nose": (106, 73, 70),
                "pupil": (31, 25, 22),
            }
            if key == "rat"
            else {
                "skin": (148, 83, 61) if key == "mandinga" else (129, 63, 52),
                "cheek": (137, 72, 56),
                "horn": (108, 89, 68),
                "hooftip": (62, 50, 43),
                "iris": (187, 132, 59),
                "leather": (78, 58, 48),
                "sash": (132, 55, 46) if key == "mandinga" else (154, 99, 51),
                "cloth": (195, 174, 134) if key == "mandinga" else (119, 52, 66),
                "trim": (163, 132, 87) if key == "mandinga" else (191, 155, 91),
                "seam": (109, 88, 62) if key == "mandinga" else (57, 62, 86),
                "pants": (64, 73, 78) if key == "mandinga" else (61, 54, 64),
            }
        )
        texture = paint(palette)
        neutral = np.vstack([part.vertices for part in model])
        scale = height / np.ptp(neutral[:, 2])
        for frame in sequence.split():
            posed_parts = [posed(part, key, frame) for part in model]
            floor = min(p[:, 2].min() for p in posed_parts)
            cursor = iter(posed_parts)

            def transform(part):
                return ((next(cursor) - [0, 0, floor]) * scale)[None]

            directory = MODELS / key
            shader = f"models/caelum/creatures/{key}/{frame}.png"
            geo = encode(key + " " + frame, surfaces(model, shader, transform))
            for ext, blob in ((".md3", geo), (".png", texture)):
                path = directory / (frame + ext)
                path.write_bytes(blob)
                inventory[path.relative_to(ROOT).as_posix()] = hashlib.sha256(blob).hexdigest()
        print(key, len(sequence.split()), flush=True)
    data = {
        "issue": 916,
        "previous_issue": 902,
        "method": "Original articulated three-dimensional ring and sweep sculptures. No sprite or projected concept pixels.",
        "anatomy_reference": "assets/source/art/witch_figures_817",
        "demon_design_references": ["CA-FOLK-018", "CA-FOLK-019"],
        "clothing": {
            "mandinga": "Long-sleeved shirt, open leather waistcoat, sash and gathered trousers.",
            "zupay": "Knee-length tunic, bordered mantle, sash and trousers.",
        },
        "rat_anatomy": "Arched axial body, articulated jaw, concave pinnae, incisors, whiskers, four sets of toes and a tapering tail.",
        "actions": {k: v[2].split() for k, v in DESIGN.items()},
        "sha256": inventory,
    }
    (ART / "PROVENANCE.json").write_bytes((json.dumps(data, indent=2) + "\n").encode())


if __name__ == "__main__":
    main()
