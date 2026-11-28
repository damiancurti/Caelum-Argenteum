"""Local skeletal motion for Mandinga, Zupay and the giant rat."""

from pathlib import Path
import json
import numpy as np

DATA = json.loads(
    (
        Path(__file__).resolve().parents[2] / "assets/source/art/articulated_deaths_921/MOTION.json"
    ).read_bytes()
)


def fall(points, joint, key, index, rotation):
    """Work from fingers and feet toward the spine, preserving the attachment pivots."""
    p = points.copy()
    side = -1 if joint.endswith("-1") else 1
    if key == "rat":
        brace, fold, drop, settle = DATA["rat_phases"][index]
        rear = joint.startswith(("thigh", "foot"))
        if rear or joint.startswith(("upper", "hand")):
            shoulder = (3 if rear else 37, side * 11, 24)
            angle = (55 if rear else -67) * (0.8 * fold + 0.2 * (settle if side > 0 else drop))
            p = rotation(p, shoulder, "y", angle)
            p = rotation(p, shoulder, "x", side * (18 * brace + 27 * drop))
        if joint in ("head", "jaw"):
            if joint == "jaw":
                p = rotation(p, (48, 0, 25), "y", 12 * fold - 8 * settle)
            p = rotation(p, (38, 0, 28), "y", 26 * drop - 12 * brace)
            p = rotation(p, (38, 0, 28), "z", -31 * settle)
        if joint == "tail":
            flex = np.clip((-p[:, 0] - 6) / 70, 0, 1)
            q = rotation(p, (-7, 0, 23), "z", 69 * settle - 32 * brace)
            p += (q - p) * flex[:, None]
            p[:, 2] += 8 * np.sin(np.pi * flex) * (brace - settle)
        anchor = (16, 0, 23)
        p = rotation(p, anchor, "y", 10 * brace - 8 * drop)
        p = rotation(p, anchor, "x", -64 * drop + 7 * settle)
        if joint in ("head", "jaw"):
            p = rotation(p, (37, 0, 24), "y", 25 * settle)
        elif joint.startswith(("thigh", "upper", "hand", "foot")):
            weight = np.clip((30 - points[:, 2]) / 19, 0, 1)
            p[:, 2] += (16 if side > 0 else -17) * weight * settle
        elif joint == "tail":
            weight = np.clip((-points[:, 0] - 3) / 47, 0, 1)
            p[:, 2] += (8 - p[:, 2]) * weight * settle
        return p
    brace, fold, drop, settle = DATA["phases"][index]
    king = key == "zupay"
    hip = np.array([0, side * 10, 94])
    knee = np.array([2, side * 12.5, 52])
    shoulder = np.array([-1, side * (24 if king else 19), 132])
    elbow = np.array([1, side * 27, 111])
    spine = (0, 0, 96)

    def transform(bone):
        q = p.copy()
        if bone in ("shin", "foot"):
            q = rotation(q, knee, "y", 84 * fold - 61 * settle + (14 if side == 1 else 0) * drop)
        if bone in ("thigh", "shin", "foot"):
            q = rotation(q, hip, "y", -(51 if king else 39) * fold + 32 * settle)
            q = rotation(q, hip, "x", side * (8 * fold + 14 * settle))
        if bone in ("upper", "fore", "hand"):
            if bone != "upper":
                q = rotation(q, elbow, "y", -46 * brace - 27 * fold + (17 if side < 0 else -12) * settle)
            reach = (102 if side > 0 else 74) if king else (66 if side < 0 else 126)
            q = rotation(q, shoulder, "y", -reach * (0.63 * fold + 0.37 * drop) + 17 * settle)
            q = rotation(q, shoulder, "x", side * (16 * brace + 20 * settle))
        if bone == "head":
            q = rotation(q, (-1, 0, 142), "y", 19 * fold - 29 * settle)
            q = rotation(q, (-1, 0, 142), "z", (42 if king else -54) * settle)
        if bone in ("head", "torso", "upper", "fore", "hand"):
            q = rotation(q, spine, "y", (31 if king else 23) * fold - 14 * settle)
            q = rotation(q, spine, "z", (14 if king else -23) * drop)
        if bone == "tail":
            q = rotation(q, (-8, 0, 92), "z", 47 * drop - 24 * brace)
            q = rotation(q, (-8, 0, 92), "y", 46 * settle)
        return q

    def mix(a, b, w):
        return transform(a) * (1 - w) + transform(b) * w

    if joint.startswith("arm"):
        q = mix("upper", "fore", np.clip((116 - p[:, 2:3]) / 11, 0, 1))
    elif joint.startswith("leg"):
        q = mix("thigh", "shin", np.clip((56 - p[:, 2:3]) / 12, 0, 1))
    elif joint == "skirt":
        q = mix("pelvis", "thigh", np.clip((96 - p[:, 2:3]) / 43, 0, 0.79))
    else:
        q = transform(joint.rstrip("-1"))
    pivot = (0, 0, 88)
    q = rotation(q, pivot, "y", (-9 if king else -13) * brace + (71 if king else 81) * drop)
    q = rotation(q, pivot, "x", (-27 if king else 36) * settle)
    # Let the weight travel from the bracing hands to cheek, cloak and hip.
    # Distal parts keep their volume, while fabric follows the limb above it.
    if joint.startswith(("leg", "foot", "thigh", "shin")):
        weight = np.clip((95 - p[:, 2]) / 73, 0, 1)
        lift = ([10, 39] if king else [30, -34])[int(side > 0)]
        q[:, 2] += weight * lift * settle
    elif joint.startswith(("arm", "fore", "upper", "hand")):
        weight = 1 if joint.startswith("hand") else np.clip((133 - p[:, 2]) / 49, 0, 1)
        lift = ([18, 29] if king else [36, 15])[int(side > 0)]
        q[:, 2] += weight * lift * settle
    elif joint == "tail":
        tip = np.clip((-p[:, 0] - 8) / 42, 0, 1)
        q[:, 2] += (72 - q[:, 2]) * tip * settle
    elif joint == "head":
        q = rotation(q, (49, 0, 95), "y", 27 * settle)
    elif joint == "skirt":
        q[:, 2] += np.maximum(0, 67 - q[:, 2]) * 0.97 * settle
    return q
