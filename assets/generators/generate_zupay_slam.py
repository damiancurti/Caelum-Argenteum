"""Bake the closed-fist ground attack against its existing 48/32-tic state clock."""

import hashlib
import json
from math import atan2, degrees
from pathlib import Path

import numpy as np
from scipy.interpolate import PchipInterpolator

from character_mesh_frames import ROOT, encode
from generate_native_creatures import demon, rotation
from sculpted_character_art import surfaces

SOURCE = ROOT / "assets/source/art/zupay_slam_920"
FOLDER = "models/caelum/creatures/zupay"
DATA = json.loads((SOURCE / "MOTION.json").read_bytes())


def aim(points, old, new, pivot, target):
    """Swing a rigid segment from its authored direction to the new sagittal direction."""
    angle = degrees(atan2(new[0], new[2]) - atan2(old[0], old[2]))
    return rotation(points, pivot, "y", angle) + target - pivot


def pose(points, joint, values, impact):
    shin, thigh, pitch, reach, rise, hand_pitch, _ = values
    side = -1 if joint.endswith("-1") else 1
    ankle = np.array([-0.3, side * 12.4, 16.0])
    knee = np.array([2.0, side * 12.4, 52.0])
    hip = np.array([0.0, side * 10.0, 94.0])
    k = rotation(knee, ankle, "y", shin)
    h = rotation(hip, knee, "y", -thigh) + k - knee

    def leg(p):
        upper = rotation(p, hip, "y", -thigh) + h - hip
        lower = rotation(p, ankle, "y", shin)
        f = np.clip((p[:, 2:3] - 47) / 11, 0, 1)
        return lower * (1 - f) + upper * f

    if joint.startswith("foot"):
        return points
    if joint.startswith("leg"):
        return leg(points)
    if joint == "skirt":
        pelvis = points + h - hip
        left = rotation(points, hip, "y", -thigh) + h - hip
        blend = np.clip((96 - points[:, 2:3]) / 38.0, 0, 0.82)
        drape = pelvis * (1 - blend) + left * blend
        drape[:, 2] += np.maximum(0, 6 - drape[:, 2]) * 0.93
        return drape
    if joint == "tail":
        lifted = rotation(points, (-8, 0, 92), "y", max(0.0, pitch) * 0.37)
        return lifted + h - hip
    if joint == "pelvis":
        return points + h - hip

    def torso(p):
        return rotation(p, hip, "y", pitch) + h - hip

    if joint == "head":
        a = rotation(points, (-1, 0, 142), "y", -pitch * 0.55)
        return torso(a)
    if joint == "torso":
        return torso(points)
    shoulder = np.array([-1.0, side * 24.0, 132.0])
    elbow = np.array([0.0, side * 27.0, 111.0])
    wrist = np.array([5.25, side * 28.1, 83.8])
    start = torso(shoulder)
    if impact:
        rise = 4.9 - start[2]
    direct = np.array([reach, rise])
    l1 = np.linalg.norm((elbow - shoulder)[[0, 2]])
    l2 = np.linalg.norm((wrist - elbow)[[0, 2]])
    distance = np.clip(np.linalg.norm(direct), abs(l2 - l1) + 0.01, l1 + l2 - 0.02)
    unit = direct / np.linalg.norm(direct)
    target = start + np.array([unit[0] * distance, wrist[1] - shoulder[1], unit[1] * distance])
    projection = (l1 * l1 - l2 * l2 + distance * distance) / (2 * distance)
    bend = (max(0, l1 * l1 - projection * projection)) ** 0.5
    hinge = unit * projection + np.array([unit[1], -unit[0]]) * bend
    middle = start + np.array([hinge[0], elbow[1] - shoulder[1], hinge[1]])
    if joint.startswith("hand"):
        return rotation(points, wrist, "y", hand_pitch) + target - wrist
    upper = aim(points, elbow - shoulder, middle - start, shoulder, start)
    lower = aim(points, wrist - elbow, target - middle, elbow, middle)
    f = np.clip((points[:, 2:3] - 105) / 12.0, 0, 1)
    return upper * f + lower * (1 - f)


def main():
    opened = demon("zupay")
    closed = demon("zupay", closed_hands=True)
    raw = np.vstack([p.vertices for p in opened])
    scale = 363 / np.ptp(raw[:, 2])
    keys = np.array(DATA["keys"])
    tics = DATA["frames"]
    animation = PchipInterpolator(keys[:, 0], keys[:, 1:])(tics)
    tracks = [[] for part in opened]
    stats = []
    for tic, values in zip(tics, animation):
        bones = []
        palms = []
        for a, b in zip(opened, closed, strict=True):
            assert a.joint == b.joint and a.vertices.shape == b.vertices.shape
            p = (
                a.vertices + (b.vertices - a.vertices) * values[-1]
                if a.joint.startswith("hand")
                else a.vertices
            )
            vertices = pose(p, a.joint, values, 48 <= tic <= 53)
            bones.append(vertices)
            if a.joint.startswith("hand"):
                palms.append(vertices)
        floor = min(p[:, 2].min() for p in bones)
        for frames, vertices in zip(tracks, bones):
            frames.append((vertices - [0, 0, floor]) * scale)
        stats.append(
            {
                "tic": tic,
                "grip": round(float(values[-1]), 3),
                "knuckle_floor_gap": round(float((np.vstack(palms)[:, 2].min() - floor) * scale), 3),
            }
        )
    cursor = iter(tracks)
    mesh = encode(
        "Zupay ground slam", surfaces(opened, FOLDER + "/zuida.png", lambda p: np.asarray(next(cursor)))
    )
    (ROOT / "src" / FOLDER / "slam.md3").write_bytes(mesh)
    model = [
        "Model CaelumZupayColossus",
        "{",
        f'    Path "{FOLDER}"',
        '    Model 0 "slam.md3"',
        '    Skin 0 "zuida.png"',
        "    CorrectPixelStretch",
        "    DontCullBackFaces",
        "    NoInterpolation",
    ]
    textures = []
    source = (ROOT / "src/TEXTURES").read_text("utf8")
    import re

    for i, t in enumerate(tics):
        letter = chr(65 + i)
        model.append(f"    FrameIndex ZSLM {letter} 0 {i}")
        old = "D" if t < DATA["prepare_tics"] else "E"
        for line in re.findall(r'^Sprite "ZUPY' + old + r'[1-8]"[^\n]+', source, re.M):
            textures.append(line.replace('"ZUPY' + old, '"ZSLM' + letter, 1))
    model.append("}")
    base = ROOT / "src/caelum/data"
    (base / "zupay_slam.modeldef").write_bytes(("\n".join(model) + "\n").encode())
    (base / "zupay_slam.textures").write_bytes(("\n".join(textures) + "\n").encode())
    # Rendering reads elapsed time from the active state and never changes it.
    timeline = [max(i for i, k in enumerate(tics) if k <= t) for t in range(keys[-1, 0].astype(int) + 1)]
    zs = (
        "class CaelumSlamFrames : Object { static clearscope int Sample(int elapsed) {\n    static const int frameAt[] = {"
        + ",".join(map(str, timeline))
        + "};\n    return frameAt[Clamp(elapsed,0,79)];\n} }\n"
    )
    (base / "CaelumSlamFrames.zs").write_bytes(zs.encode())
    assert stats[tics.index(48)]["knuckle_floor_gap"] < 2.5, stats[tics.index(48)]
    (SOURCE / "PROVENANCE.json").write_bytes(
        (
            json.dumps(
                {
                    "animation": "MOTION.json",
                    "sha256": {"src/" + FOLDER + "/slam.md3": hashlib.sha256(mesh).hexdigest()},
                    "samples": stats,
                },
                indent=2,
            )
            + "\n"
        ).encode()
    )


if __name__ == "__main__":
    main()
