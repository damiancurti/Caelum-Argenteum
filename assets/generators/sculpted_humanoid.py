"""Original figure, hands and plane-built head in native forward-X coordinates.

The hip, knee, ankle, elbow and neck heights follow the witch/Salamanca figure.
Player wrists and soles use the shared animation and equipment attachment space.
"""

from math import cos, sin, pi, exp, sqrt
import numpy as np
from sculpted_character_art import Sculpt


def hand(m, side, x, y, z, size=1.0, material="skin"):
    joint = "hand" + str(side)

    def pt(a, b, c):
        return (x + a * size, y + side * b * size, z + c * size)

    m.oval(joint, material, pt(0, 0, 0), (3.6 * size, 2.25 * size, 4.7 * size), 12, 8)
    for i, (a, length) in enumerate(((2.15, 5.6), (0.7, 6.2), (-0.85, 5.6), (-2.25, 4.4))):
        nodes = [
            (*pt(a, 0, -1.7), 1.08 * size, 1.08 * size),
            (*pt(a + 0.15, 0.1, -4.3), 0.92 * size, 1.02 * size),
            (*pt(a + 0.45, -0.7, -length - 0.8), 0.83 * size, 0.82 * size),
            (*pt(a + 0.65, -1.40, -length - 1.4), 0.43 * size, 0.62 * size),
        ]
        m.sweep(joint, material, nodes, 8)
    m.sweep(
        joint,
        material,
        [
            (*pt(2.1, -0.2, 2.5), 1.6 * size, 1.6 * size),
            (*pt(3.9, -0.9, 0.15), 1.35 * size, 1.35 * size),
            (*pt(4.5, -1.7, -2.3), 0.95 * size, 1.0 * size),
            (*pt(4.15, -2.15, -3.25), 0.55 * size, 0.65 * size),
        ],
        9,
    )


def figure(family, female, monster=False):
    pieces = {n: Sculpt() for n in ("shirt", "trousers", "belt", "boots", "gloves", "hands")}
    shirt = pieces["shirt"]
    legs = pieces["trousers"]
    boots = pieces["boots"]
    belt = pieces["belt"]
    shoulder = (19.1 if female else 22.6) * {"bear": 1.16, "goblin": 1.07, "zupay": 1.28, "puma": 0.96}.get(
        family, 1
    )
    waist = (12.4 if female else 15.7) * {"bear": 1.19, "goblin": 1.14, "zupay": 1.21}.get(family, 1)
    hip = (19.4 if female else 16.8) * {"bear": 1.10, "goblin": 1.06, "zupay": 1.17}.get(family, 1)
    pec = (12.5 if female else 13.4) * ({"bear": 1.13, "zupay": 1.23}.get(family, 1))
    cloth = "skin" if monster else "cloth"
    torso_rows = [
        (92, 0, 0, 9.7, hip * 0.92),
        (98, -0.5, 0, 11, hip),
        (105, -0.4, 0, 9.6, waist * 1.02),
        (111, 0.1, 0, 9.8, waist),
        (118, 0, 0, 11.2, (waist + shoulder) * 0.51),
        (124, 0.2, 0, pec, shoulder * 0.92),
        (130, -0.3, 0, pec * 0.97, shoulder),
        (134, -1, 0, 10.5, shoulder * 0.94),
        (138, -1, 0, 8.2, shoulder * 0.70),
        (142, -1, 0, 6.3, 8.0),
    ]

    def torso_plane(x, y, z, t):
        front = max(0, cos(t)) ** 2

        def ridge(h, spread):
            return exp(-(((z - h) / spread) ** 2))

        relief = (
            2.3 * ridge(128, 5.6) * exp(-(((abs(y) - 8) / 7.1) ** 2))
            - 1.3 * exp(-((y / 1.65) ** 2)) * ridge(126, 12)
            + 1.10 * exp(-(((abs(y) - 3.6) / 3.8) ** 2)) * sum(ridge(h, 2.6) for h in (109, 115, 121))
            - 0.8 * exp(-(((abs(y) - 8) / 3.0) ** 2)) * ridge(113, 9)
        )
        return x + front * relief * (1 if monster else 0.45), y, z

    dense = []
    for a, b in zip(torso_rows, torso_rows[1:]):
        dense.extend([a, tuple((v + w) / 2 for v, w in zip(a, b))])
    shirt.loft("torso", cloth, [*dense, torso_rows[-1]], 32, power=0.85, sculpt=torso_plane)
    if not monster:
        for sign in (-1, 1):
            shirt.patch(
                "torso",
                "trim",
                [
                    (7, sign * 2.8, 142),
                    (3, sign * 8.6, 140),
                    (8.5, sign * 10, 135.4),
                    (12.2, sign * 4.4, 128),
                    (11.2, sign * 2, 135),
                ],
                (10.7, sign * 5.7, 136.8),
            )
        shirt.sweep(
            "torso",
            "seam",
            [
                (8.9, 0, 138, 0.58, 0.55),
                (12.9, 0, 129, 0.65, 0.55),
                (13.3, 0, 124, 0.62, 0.55),
                (10.9, 0, 117, 0.58, 0.45),
                (10.3, 0, 108, 0.48, 0.44),
            ],
            7,
        )
        for z, x in [(130, 12.3), (125, 13.25), (120, 12.2), (114.7, 10.65)]:
            shirt.oval("torso", "brass", (x, 0, z), (0.45, 0.78, 0.78), 8, 5)
        shirt.sweep(
            "torso",
            "seam",
            [(-9.1, -14, 133, 0.5, 0.4), (-12.4, 0, 129, 0.55, 0.45), (-9.1, 14, 133, 0.5, 0.4)],
            7,
        )
    for side in (-1, 1):
        upper = "upper" + str(side)
        fore = "fore" + str(side)
        thigh = "thigh" + str(side)
        shin = "shin" + str(side)
        sy = shoulder * 0.85
        ey = 26 if female else 27.4
        wy = 28.1
        radius = (6.6 if female else 8.2) * ({"bear": 1.18, "zupay": 1.32}.get(family, 1))
        if monster:
            shirt.loft(
                "arm" + str(side),
                cloth,
                [
                    (88, 5, side * wy, 3.5, 3.2),
                    (94, 4.5, side * wy, 3.8, 3.5),
                    (100, 3.6, side * wy, radius * 0.62, radius * 0.57),
                    (106, 2, side * ey, radius * 0.74, radius * 0.64),
                    (111, -0.5, side * ey, radius * 0.59, radius * 0.56),
                    (116, 0.5, side * (ey - 0.5), radius * 0.72, radius * 0.68),
                    (123, 1.4, side * (sy + 3), radius * 0.90, radius * 0.81),
                    (128, -0.6, side * (sy + 2), radius * 0.95, radius * 0.98),
                    (132, -1.8, side * sy, radius * 0.88, radius * 0.9),
                    (135, -1.8, side * (sy - 1), radius * 0.4, radius * 0.55),
                ],
                16,
            )
        else:
            shirt.sweep(
                upper,
                cloth,
                [
                    (-1, side * sy, 133, radius * 0.68, radius * 0.70),
                    (0, side * (sy + 1.7), 129, radius, radius * 1.08),
                    (1.4, side * (sy + 4), 121, radius * 0.88, radius * 0.93),
                    (1.2, side * ey, 113, radius * 0.68, radius * 0.77),
                    (0.5, side * ey, 109, radius * 0.62, radius * 0.68),
                ],
                14,
            )
            shirt.sweep(
                fore,
                cloth,
                [
                    (0.8, side * ey, 112, radius * 0.64, radius * 0.70),
                    (1.7, side * (ey + 0.4), 107, radius * 0.79, radius * 0.84),
                    (3.7, side * wy, 98, radius * 0.62, radius * 0.66),
                    (5.0, side * wy, 88.4, 3.3, 3.8),
                ],
                14,
            )
        if not monster:
            shirt.loft(
                fore,
                "trim",
                [
                    (87.8, 5, side * wy, 3.8, 3.6),
                    (89, 5, side * wy, 4.15, 4.05),
                    (93, 4.6, side * wy, 4.3, 4.1),
                ],
                12,
            )
        hand(pieces["hands"], side, 5.25, side * wy, 83.8, 1 if not female else 0.92)
        hand(pieces["gloves"], side, 5.25, side * wy, 83.8, 1.05 if not female else 0.97, "leather")
        pieces["gloves"].loft(
            "hand" + str(side),
            "sole",
            [(85.4, 5, side * wy, 3.9, 3.25), (89.5, 5, side * wy, 4.1, 3.65)],
            12,
        )
        cy = 13 if female else 12.4
        mat = "skin" if monster else "pants"
        if monster:
            legs.loft(
                "leg" + str(side),
                mat,
                [
                    (14, -0.5, side * cy, 4.2, 4.1),
                    (23, -1.0, side * cy, 4.7, 4.5),
                    (34, -2, side * cy, 6.5, 5.8),
                    (42, -1.7, side * cy, 7.4, 6.2),
                    (48, 0.7, side * cy, 6.25, 5.8),
                    (54, 2.5, side * cy, 6.4, 6.1),
                    (61, 1.4, side * (cy - 0.5), 8.1, 7.0),
                    (71, -0.2, side * (cy - 1.6), 9.9, 8.55),
                    (83, -0.6, side * (cy - 3), 11.4, hip * 0.57),
                    (93, -0.3, side * hip * 0.48, 10.7, hip * 0.53),
                    (99, 0, side * hip * 0.45, 9.2, hip * 0.51),
                ],
                16,
            )
        else:
            legs.loft(
                thigh,
                mat,
                [
                    (49, 2, side * cy, 6.9, 6.3),
                    (54, 2.2, side * cy, 7.8, 7.4),
                    (62, -0.2, side * (cy - 0.5), 8.6, 7.9),
                    (73, -0.8, side * (cy - 1.7), 10.9, 9.25),
                    (84, -0.7, side * (cy - 3.0), 12.1, hip * 0.58),
                    (94, -0.3, side * hip * 0.48, 10.8, hip * 0.53),
                    (99, 0, side * hip * 0.45, 9.4, hip * 0.51),
                ],
                16,
                power=0.92,
            )
            legs.loft(
                shin,
                mat,
                [
                    (17, -0.5, side * cy, 4.7, 4.1),
                    (26, -0.5, side * cy, 5.9, 5.2),
                    (35, -1.9, side * cy, 7.8, 6.5),
                    (44, -1.4, side * cy, 8.1, 6.8),
                    (49, 1.5, side * cy, 7.05, 6.3),
                    (54, 2, side * cy, 7.0, 6.5),
                ],
                14,
            )
        if not monster:
            boots.loft(
                shin,
                "leather",
                [
                    (5, 1, side * cy, 6.4, 5.0),
                    (10, -0.8, side * cy, 5.7, 5),
                    (19, -0.6, side * cy, 5.3, 4.9),
                    (28, -1.35, side * cy, 6.9, 6.1),
                    (34, -1.7, side * cy, 7.9, 6.65),
                ],
                14,
            )
            boots.loft(
                shin, "sole", [(31.5, -1.7, side * cy, 8, 6.8), (34.9, -1.7, side * cy, 8.3, 6.85)], 14
            )
            boots.loft(
                "foot" + str(side),
                "leather",
                [
                    (2, 5.6, side * cy, 12.3, 5.7),
                    (4.4, 5.8, side * cy, 12.9, 5.9),
                    (6.5, 5.4, side * cy, 12.1, 5.65),
                    (9.5, 1.4, side * cy, 8.4, 5.2),
                    (12.8, -0.2, side * cy, 5.6, 4.9),
                ],
                14,
                power=0.77,
            )
            boots.loft(
                "foot" + str(side),
                "sole",
                [(0.2, 5.7, side * cy, 12.8, 6.05), (2.4, 5.7, side * cy, 13, 6.15)],
                14,
                power=0.76,
            )
        else:
            for toe in (-1, 1):
                boots.loft(
                    "foot" + str(side),
                    "hooftip",
                    [
                        (0.3, 5.5, side * cy + toe * 3.55, 9.3, 3.7),
                        (3.7, 5, side * cy + toe * 3.4, 9, 4),
                        (10, 1.5, side * cy + toe * 2.8, 6.7, 3.7),
                        (16, -0.3, side * cy + toe * 1.5, 4.5, 3.1),
                        (20, -0.3, side * cy, 3.5, 2.8),
                    ],
                    12,
                    power=0.77,
                )
    belt.loft(
        "pelvis",
        "sash",
        [
            (94, -0.3, 0, 11.4, hip * 1.02),
            (96, -0.3, 0, 12, hip * 1.04),
            (100, -0.1, 0, 11.45, hip * 1.02),
            (103, 0, 0, 10.5, hip * 0.96),
        ],
        20,
        power=0.83,
    )
    belt.loft(
        "pelvis",
        "leather",
        [(97.1, -0.1, 0, 12.1, hip * 1.05), (100, -0.1, 0, 11.9, hip * 1.04)],
        20,
        power=0.83,
    )
    belt.oval("pelvis", "brass", (11.9, 1.1, 98.6), (0.9, 2.95, 2.25), 10, 6)
    return pieces


def head(family, female, variant=0):
    m = Sculpt()
    j = "head"
    goblin = family == "goblin"
    demon = family in ("mandinga", "zupay")
    width = (9.15 if not female else 8.55) * (1.14 if goblin else 1) * [1, 0.94, 1.06, 0.985][variant]
    jaw = (0.77 if not female else 0.65) * [1, 0.89, 1.07, 0.94][variant]
    m.loft(
        j,
        "skin",
        [
            (137.2, -0.7, 0, 5.7, 5.8),
            (141, -0.9, 0, 6.4, 6.3),
            (146, -0.7, 0, 5.4, 5.5),
            (151, 0, 0, 6.1, 6.4),
        ],
        16,
    )
    rows = [
        (145, 4, 0, 3.9, width * 0.42),
        (147, 2.4, 0, 7.2, width * jaw),
        (150, 1, 0, 8.8, width * 0.90),
        (153, 0.6, 0, 9.6, width),
        (155.7, 0.35, 0, 10.1, width * 1.04),
        (158.3, -0.5, 0, 9.7, width * 1.015),
        (161.1, -0.45, 0, 10.3, width),
        (165, -1.15, 0, 10.0, width * 0.98),
        (168, -1.75, 0, 8.0, width * 0.8),
        (170.1, -2, 0, 3.0, width * 0.33),
    ]

    def feature(y, z):
        return (
            1.25 * exp(-(((abs(y) - 5.7) / 2.8) ** 2) - ((z - 154.9) / 2.15) ** 2)
            - 1.05 * exp(-(((abs(y) - 4.5) / 2.5) ** 2) - ((z - 158) / 1.25) ** 2)
            + 0.62 * exp(-(((abs(y) - 4.3) / 3.1) ** 2) - ((z - 160.2) / 1.4) ** 2)
        )

    def front(y, z):
        zz, x, _, rx, ry = [np.interp(z, [r[0] for r in rows], [r[k] for r in rows]) for k in range(5)]
        c = sqrt(max(0.015, 1 - min(0.99, abs(y) / ry) ** (2 / 0.86)))
        return x + rx * c**0.86 + c * c * feature(y, z)

    fine = []
    for a, b in zip(rows, rows[1:]):
        fine.extend([a, tuple((v + w) / 2 for v, w in zip(a, b))])
    m.loft(
        j,
        "skin",
        [*fine, rows[-1]],
        40,
        power=0.86,
        sculpt=lambda x, y, z, t: (x + max(0, cos(t)) ** 2 * feature(y, z), y, z),
    )
    for s in (-1, 1):
        ey = 4.52 * s * (width / 9)
        z = 157.85 + (0.3 if female else 0) + (0.35 if variant == 1 else 0)

        # Tapered eye apertures sit against the orbital plane. The lid forms the silhouette.
        def on(d, h, depth=0.32):
            y = ey + s * d
            return front(y, z + h) + depth, y, z + h

        inner = on(-2.34, -0.06)
        outer = on(2.30, 0.17)
        m.patch(
            j,
            "dark",
            [
                on(-2.42, -0.04),
                on(-0.72, 1.03),
                on(0.85, 1.03),
                on(2.5, 0.20),
                on(0.55, -0.72),
                on(-0.9, -0.60),
            ],
            on(0, 0.12, 0.54),
        )
        m.patch(
            j,
            "ivory",
            [
                inner,
                on(-0.65, 0.77, 0.57),
                on(0.8, 0.74, 0.57),
                outer,
                on(0.46, -0.50, 0.56),
                on(-0.83, -0.43, 0.53),
            ],
            on(0, 0.12, 0.86),
        )
        for mat, ry, rz, depth in (("iris", 0.94, 0.76, 1.06), ("pupil", 0.49, 0.60, 1.16)):
            ring = [on(ry * cos(t), 0.10 + rz * sin(t), depth) for t in np.arange(12) * pi / 6]
            m.patch(j, mat, ring, on(0, 0.12, depth + 0.12))
        m.sweep(
            j,
            "brow",
            [
                (*on(-2.47, 1.33, 0.58), 0.45, 0.45),
                (*on(-0.35, 1.82, 0.54), 0.58, 0.72),
                (*on(1.20, 1.94, 0.45), 0.49, 0.53),
                (*on(2.67, 1.44, 0.31), 0.20, 0.24),
            ],
            9,
        )
        m.sweep(
            j,
            "cheek",
            [
                (*on(-1.2, -1.16, 0.21), 0.11, 0.17),
                (*on(0.52, -1.42, 0.28), 0.19, 0.23),
                (*on(2.07, -0.93, 0.21), 0.12, 0.12),
            ],
            7,
        )
        if goblin or demon:
            m.patch(
                j,
                "skin",
                [
                    (0, s * (width - 0.5), 160),
                    (-4, s * (width + 1.5), 161.5),
                    (-7, s * (width + 8), 164.1),
                    (-4, s * (width + 5.4), 157),
                    (-1, s * (width + 0.7), 153.5),
                ],
                (1.4, s * (width + 2), 158.2),
            )
            m.patch(
                j,
                "ear",
                [
                    (0.6, s * (width + 0.3), 159),
                    (-5.5, s * (width + 6.1), 162),
                    (-1.8, s * (width + 2.7), 155.7),
                ],
                (0.9, s * (width + 2.2), 158),
            )
        else:
            m.oval(j, "skin", (-0.4, s * width, 155.5), (2.3, 1.72, 3.35), 11, 7)
            m.oval(j, "ear", (0, s * (width + 1.38), 155.65), (1.04, 0.43, 1.9), 9, 6)
    breadth = (3.45 if goblin else 2.25) * [1, 0.86, 1.13, 0.99][variant]
    m.loft(
        j,
        "skin",
        [
            (152.3, 9.6, 0, 1.15, breadth * 0.63),
            (153.0, 11.0, 0, 2.18, breadth),
            (154.05, 11.28, 0, 2.3, breadth * 0.9),
            (155.55, 10, 0, 1.88, breadth * 0.61),
            (158.6, 8.9, 0, 1.4, breadth * 0.55),
            (160.3, 8.4, 0, 0.85, breadth * 0.66),
        ],
        12,
    )
    for s in (-1, 1):
        m.oval(j, "lip", (11.9, s * breadth * 0.65, 152.9), (0.55, 0.53, 0.25), 8, 5)
    m.sweep(
        j,
        "lip",
        [
            (9.48, -2.85, 150, 0.18, 0.18),
            (10.14, -1.2, 150.22, 0.34, 0.3),
            (10.35, 0, 150.04, 0.39, 0.31),
            (10.14, 1.2, 150.22, 0.34, 0.30),
            (9.48, 2.85, 150, 0.18, 0.18),
        ],
        8,
    )
    m.sweep(
        j,
        "cheek",
        [
            (9.28, -2.6, 149.77, 0.16, 0.17),
            (10.12, -1.15, 149.6, 0.28, 0.31),
            (10.22, 0, 149.54, 0.25, 0.31),
            (10.12, 1.15, 149.6, 0.28, 0.31),
            (9.28, 2.6, 149.77, 0.16, 0.17),
        ],
        8,
    )
    return m
