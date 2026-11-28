"""Pose Palomo's owned standing, seated, and lying art across eight viewing angles."""

import hashlib
import json
from pathlib import Path
import re

import numpy as np
from PIL import Image
from scipy.interpolate import LinearNDInterpolator

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "src"


def warp(image, source, target):
    """Inverse-map a triangular control cage; the floor and image corners stay fixed."""
    corners = [(0, 0), (255, 0), (255, 255), (0, 255)]
    lookup = LinearNDInterpolator(np.array(target + corners), np.array(source + corners))
    yy, xx = np.mgrid[:256, :256]
    coords = np.rint(lookup(xx, yy)).astype(int).clip(0, 255)
    return Image.fromarray(np.asarray(image)[coords[:, :, 1], coords[:, :, 0]])


def main():
    textures = (SRC / "TEXTURES").read_text("utf8")
    path = SRC / "sprites/caelum/actors/palomo_fall"
    path.mkdir(exist_ok=True)
    lines = []
    sources = set()
    hashes = {}
    for angle in range(1, 9):

        def frame(stem):
            source = re.search(rf'Sprite "{stem}{angle}".*?Patch "([^"]+)"', textures)[1]
            sources.add("src/" + source)
            return Image.open(SRC / source).convert("RGBA")

        standing, seated, lying = map(frame, ("PALMA", "RSPAA", "RSPAB"))
        mask = np.array(lying)[:, :, 3] > 128
        ys, xs = np.where(mask)
        head = np.mean(xs[ys < ys.min() + 16])
        side = -1 if head < 128 else 1
        upright = [
            (93, 22),
            (160, 22),
            (88, 73),
            (168, 73),
            (83, 137),
            (173, 137),
            (98, 164),
            (159, 164),
            (95, 206),
            (161, 206),
            (91, 245),
            (169, 245),
        ]
        crouch = [
            (93 + side * 9, 44),
            (160 + side * 9, 44),
            (88 + side * 7, 93),
            (168 + side * 7, 93),
            (83 + side * 6, 153),
            (173 + side * 6, 153),
            (92, 183),
            (166, 183),
            (91, 213),
            (168, 213),
            (91, 245),
            (169, 245),
        ]
        seat = [
            (100, 73),
            (152, 73),
            (90, 122),
            (166, 122),
            (83, 169),
            (173, 169),
            (91, 195),
            (165, 195),
            (91, 225),
            (165, 225),
            (89, 245),
            (167, 245),
        ]
        frames = [warp(standing, upright, crouch)]
        for reach, sink in [(8, 1), (35, 14), (58, 37)]:
            bent = []
            for x, y in seat:
                lift = np.clip((202 - y) / 128, 0, 1)
                bent.append(
                    (x + side * reach * lift, y + sink * lift + (x - 128) * (-side) * lift * reach / 130)
                )
            frames.append(warp(seated, seat, bent))
        for i, im in enumerate(frames):
            stem = f"PLDF{chr(65 + i)}{angle}"
            file = path / (stem + ".png")
            im.save(file, optimize=False)
            hashes[file.relative_to(ROOT).as_posix()] = hashlib.sha256(file.read_bytes()).hexdigest()
            lines.append(
                f'Sprite "{stem}", 256, 256 {{ Offset 128, 246 Patch "{file.relative_to(SRC).as_posix()}", 0, 0 }}'
            )
    (SRC / "caelum/data/palomo_fall.textures").write_bytes(("\n".join(lines) + "\n").encode())

    record = dict(
        issue=921,
        source=sorted(sources),
        method="Pose original standing and seated Palomo drawings with a piecewise-affine control cage. End in the existing curled resting art.",
        sha256=hashes,
    )
    (ROOT / "assets/source/art/articulated_deaths_921/PALOMO.json").write_bytes(
        (json.dumps(record, indent=2) + "\n").encode()
    )


if __name__ == "__main__":
    main()
