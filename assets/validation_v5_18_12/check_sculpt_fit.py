"""Check modular scalp clearance on every face, and sleeve axes on the seven female bodies."""

from pathlib import Path
import sys
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/generators"))
from generate_player_families import FAMILIES, hair
from sculpted_humanoid import head, figure


def sections(piece):
    """Intersect real triangles with horizontal sightlines through the skull."""
    tris = piece.vertices[piece.triangles]
    result = []
    for z in (155.3, 158.4, 161.3, 163.3, 165.4, 167.2, 169.1, 169.9):
        xys = []
        for angle in np.arange(48) * 2 * np.pi / 48:
            # The low front hairline and ear openings intentionally expose skin.
            if (z < 159 and np.cos(angle) > -0.65) or (159 <= z < 163 and np.cos(angle) > 0.0):
                continue
            d = np.array([np.cos(angle), np.sin(angle)])
            normal = np.array([-d[1], d[0]])
            # Barycentric interpolation on the plane perpendicular to the ray.
            # Either winding is valid for a surface viewed from the inside.
            offset = tris - np.array([-1.0, 0.0, z])
            sides = offset[:, :, :2] @ normal
            levels = offset[:, :, 2]
            ax, bx, cx = sides.T
            ay, by, cy = levels.T
            denominator = (bx - ax) * (cy - ay) - (cx - ax) * (by - ay)
            use = np.abs(denominator) > 1e-9
            den = np.where(use, denominator, 1.0)
            b = (ay * (cx - ax) - ax * (cy - ay)) / den
            c = (ax * (by - ay) - ay * (bx - ax)) / den
            a = 1 - b - c
            use &= (a >= -1e-8) & (b >= -1e-8) & (c >= -1e-8)
            distances = offset[:, :, :2] @ d
            hit = (distances * np.column_stack((a, b, c))).sum(axis=1)
            candidates = hit[use & (hit > 0)]
            if not len(candidates):
                raise AssertionError(f"Open mesh at height {z} and angle {angle}")
            xys.append(candidates.max())
        result.extend(xys)
    return np.array(result)


def main():
    clearance = []
    for i in range(6):
        family = FAMILIES[i // 2]
        skulls = [sections(head(family, bool(i % 2), face).parts[1]) for face in range(4)]
        for style in range(4):
            cap = sections(hair(i, style).parts[0])
            for skull in skulls:
                clearance.append(float(np.min(cap - skull)))
    if min(clearance) <= 0.1:
        raise AssertionError(f"Skull intersects a hairstyle: {min(clearance)}")
    for family in FAMILIES:
        sleeves = [p for p in figure(family, True)["shirt"].parts if p.joint.startswith("arm")]
        assert len(sleeves) == 2
        for sleeve in sleeves:
            # Loft rows have one duplicated UV seam, then two end-cap centres.
            vertices = sleeve.vertices[:-2].reshape(-1, 21, 3)[:, :-1]
            center = vertices.mean(axis=1)
            gradient = np.diff(center[:, 1]) / np.diff(center[:, 2])
            assert np.ptp(gradient) < 0.015, (family, gradient)
    print(
        f"96 fitted face/hairstyle pairs; minimum radial clearance {min(clearance):.3f}. "
        "Both sleeve axes passed on all seven female figures."
    )


if __name__ == "__main__":
    main()
