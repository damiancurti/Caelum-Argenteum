"""Measure the shipped death frames of the numbered bestiary actors (issue 921)."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

import numpy as np


def md3_positions(data):
    if data[:8] != b"IDP3\x0f\0\0\0":
        raise ValueError("Expected MD3 version 15")
    surface_count = struct.unpack_from("<I", data, 84)[0]
    offset = struct.unpack_from("<I", data, 100)[0]
    surfaces = []
    for _ in range(surface_count):
        header = struct.unpack_from("<4s64s10I", data, offset)
        frames, vertices, xyz, end = header[3], header[5], header[10], header[11]
        values = np.frombuffer(data, "<i2", frames * vertices * 4, offset + xyz)
        surfaces.append(values.reshape(frames, vertices, 4)[:, :, :3] / 64.0)
        offset += end
    return np.concatenate(surfaces, axis=1)


def rigid_residual(start, pose):
    """RMS distance after fitting the best rigid rotation and translation."""
    first = start - start.mean(axis=0)
    second = pose - pose.mean(axis=0)
    left, _, right = np.linalg.svd(first.T @ second)
    orientation = np.diag([1.0, 1.0, np.sign(np.linalg.det(left @ right))])
    difference = first @ (left @ orientation @ right) - second
    return np.sqrt(np.mean(np.sum(difference**2, axis=1)))


def numbers(values):
    return np.asarray(values).round(6).tolist()


def measure(root, definition, actor, block):
    directory = re.search(r'\bPath\s+"([^"]+)"', block, re.I)[1]
    filename = re.search(r'\bModel\s+0\s+"([^"]+)"', block, re.I)[1]
    model = root / "src" / directory / filename
    mappings = dict(re.findall(r"\bFrameIndex\s+MNDG\s+([G-L])\s+0\s+(\d+)", block, re.I))
    indices = [int(mappings[key]) for key in "GHIJKL"]
    data = model.read_bytes()
    sampled = md3_positions(data)[indices]
    low = sampled.min(axis=1)
    high = sampled.max(axis=1)
    initial_height = high[0, 2] - low[0, 2]
    heights = (high[:, 2] - low[:, 2]) / initial_height
    residuals = [rigid_residual(sampled[0], pose) / initial_height for pose in sampled[1:]]
    centroids = sampled.mean(axis=1)
    return {
        "actor": actor,
        "definition": definition.relative_to(root).as_posix(),
        "model": model.relative_to(root).as_posix(),
        "md3_sha256": hashlib.sha256(data).hexdigest(),
        "vertices_per_pose": sampled.shape[1],
        "frame_indices_G_to_L": indices,
        "height_G_to_L_over_G_height": numbers(heights),
        "bottom_z_change_G_to_L_over_G_height": numbers((low[:, 2] - low[0, 2]) / initial_height),
        "centroid_delta_xyz_G_to_L_over_G_height": numbers((centroids - centroids[0]) / initial_height),
        "rigid_residual_H_to_L_over_G_height": numbers(residuals),
        "mean_rigid_residual_H_to_L_over_G_height": round(float(np.mean(residuals)), 6),
    }


def audit(root):
    source = root / "src/caelum/actors/CaelumBestiaryCombat.zs"
    actors = set(
        re.findall(
            r"\bclass\s+(CaelumBestiary\d+)\s*:\s*CaelumBestiaryCombatActor\b",
            source.read_text("utf-8-sig"),
        )
    )
    rows = {}
    for definition in sorted((root / "src/caelum/data").glob("*_combat.modeldef")):
        blocks = re.findall(
            r"\bModel\s+(CaelumBestiary\d+)\s*\{([^{}]+)\}", definition.read_text("utf-8-sig"), re.I
        )
        for actor, block in blocks:
            if actor in rows:
                raise ValueError(f"Duplicate model definition for {actor}")
            rows[actor] = measure(root, definition, actor, block)
    replacements = root / "src/caelum/data/bestiary_deaths.modeldef"
    if replacements.exists():
        assert '#include "caelum/data/bestiary_deaths.modeldef"' in (root / "src/MODELDEF").read_text()
        for actor, block in re.findall(
            r"\bModel\s+(CaelumBestiary\d+)\s*\{([^{}]+)\}", replacements.read_text(), re.I
        ):
            if actor not in rows:
                raise ValueError("Unknown fallback class: " + actor)
            rows[actor] = measure(root, replacements, actor, block)
    if rows.keys() != actors:
        raise ValueError(
            f"Mismatch between combat classes and model definitions: {sorted(rows.keys() ^ actors)}"
        )
    return {
        "scope": "Numbered CaelumBestiaryCombatActor descendants; 018 and 019 use separate dedicated actors.",
        "method": "All mesh vertices at the six authored MNDG death frames, in model space. Each H-L pose is independently aligned to G with a proper rigid least-squares transform, then RMS residuals and all distances are divided by the vertical extent of G. Smaller residuals indicate more rigid movement. Ground contact, artistic intent, visibility, and rendered interpolation require separate inspection.",
        "actor_count": len(rows),
        "actors": [rows[actor] for actor in sorted(rows)],
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root.resolve())
    args.output.write_bytes((json.dumps(result, indent=2) + "\n").encode("utf-8"))
    print(f"Audited {result['actor_count']} numbered bestiary actors")
