"""Export alternate death takes from the original bestiary hierarchies and materials."""

import hashlib
import importlib
import json
import re
from pathlib import Path

import numpy as np

from generate_beast_men_models import prepared_design, surface_materials
from generate_nahuelito_model import md3
from generate_native_creatures import ROOT, rotation

ART = ROOT / "assets/source/art/articulated_deaths_921"
DATA = json.loads((ART / "MOTION.json").read_bytes())


def joint_pose(name, point, design, row, index):
    """Rotate each authored bone in local space, applying its parent's movement last."""
    recoil, fold, drop, settle = DATA["phases"][index]
    species = row["name"]
    fore, hind, roll, bow, twist = row["angles"]
    bone = name
    p = point
    while bone is not None:
        pivot = np.array(design["parts"][bone]["pivot"])
        side = -1 if "left" in bone else 1
        stagger = fold if side < 0 else settle
        if species == "luzmala":
            if "flame" in bone or "wisp" in bone:
                p = rotation(p, pivot, "x", side * (30 * recoil + 58 * drop))
                p = rotation(p, pivot, "y", 36 * settle)
            if bone == "pelvis":
                p = (p - pivot) * np.array(
                    [1 + 0.18 * fold - 0.58 * settle, 1 + 0.12 * fold - 0.65 * settle, 1 - 0.91 * drop]
                ) + pivot
        elif species == "umita":
            if "lock_" in bone:
                length = np.clip(np.abs(p[:, 2] - pivot[2]) / 24, 0, 1)
                angle = (28 * recoil - 62 * settle) * (-1 if pivot[1] < 0 else 1)
                q = rotation(p, pivot, "x", angle)
                p += (q - p) * length[:, None]
            if bone == "head":
                p = rotation(p, pivot, "y", 25 * recoil + 78 * drop)
                p = rotation(p, pivot, "z", 32 * settle)
        else:
            front = bone.startswith("fore_") or "_front_" in bone
            back = bone.startswith("hind_") or "_hind_" in bone
            if front or back:
                angle = (fore if front else hind) * (0.68 * fold + 0.32 * stagger)
                if bone.endswith("_thigh") or (species == "huayrapuca" and bone.endswith("_upper")):
                    p = rotation(p, pivot, "y", angle)
                    p = rotation(p, pivot, "x", side * (12 * drop + 6 * stagger))
                elif bone.endswith(("_shin", "_shank")):
                    p = rotation(p, pivot, "y", -angle * (1.72 if front else 1.55))
                elif bone.endswith("_foot"):
                    p = rotation(p, pivot, "y", angle * 0.38)
            if bone in ("left_wing", "right_wing"):
                p = rotation(p, pivot, "x", side * (-16 * recoil - (116 if side > 0 else 68) * drop))
                p = rotation(p, pivot, "z", side * 33 * settle)
            if bone in ("tail", "serpent_tail"):
                p = rotation(p, pivot, "z", twist * (drop - 0.42 * recoil))
                p = rotation(p, pivot, "y", -17 * settle)
            if re.fullmatch(r"h\d_head", bone):
                slot = int(bone[1])
                p = rotation(p, pivot, "y", (18 + slot * 4) * (fold * 0.6 + settle * 0.4))
                p = rotation(p, pivot, "z", (3 - slot) * 7 * drop)
            if bone == "head":
                p = rotation(p, pivot, "y", bow * (0.22 * recoil + 0.78 * drop))
                p = rotation(p, pivot, "z", twist * 0.55 * settle)
            if bone == "torso":
                p = rotation(p, pivot, "y", 10 * fold - 6 * settle)
            if bone == "pelvis":
                p = rotation(p, pivot, "x", roll * drop)
        bone = design["parts"][bone]["parent"]
    return p


def rigged(row):
    module = importlib.import_module("generate_" + row["generator"])
    name = row["name"]
    config = json.loads((module.SOURCE / "ANIMATION.json").read_bytes())
    item = config["species"][name]
    design = json.loads((ROOT / item["design"]).read_bytes())
    mesh = module.geometry(prepared_design(design))
    surface_materials(mesh, design)
    raw = np.array(mesh.vertices)
    scale = design["preview"]["height_map_units"] / np.ptp(raw[:, 2])
    owners = np.array(mesh.parts)
    frames = []
    for i, (_, _, drop, settle) in enumerate(DATA["phases"]):
        out = raw.copy()
        for joint in set(mesh.parts):
            chosen = owners == joint
            out[chosen] = joint_pose(joint, raw[chosen].copy(), design, row, i)
        # A hovering head or flame starts at its standing offset and loses altitude.
        if name not in ("umita", "luzmala"):
            # Once the shoulder or haunch takes the weight, projecting low toes and
            # tails to its plane keeps the torso from balancing on a single extremity.
            body = np.isin(owners, ["pelvis", "torso", "trunk"])
            contact = np.percentile(out[body, 2], 2)
            compression = np.maximum(0, contact - out[:, 2]) * settle
            out[:, 1] += np.where(raw[:, 1] < 0, -1, 1) * compression * 0.47
            out[:, 2] += compression * 0.97
        out[:, 2] -= np.min(out[:, 2])
        out *= scale
        out[:, 2] += design["preview"].get("model_offset", [0, 0, 0])[2] * (1 - drop)
        frames.append(out.tolist())
    mesh.faces = [(design["materials"][mat]["native_batch"], tri) for mat, tri in mesh.faces]
    shaders = {k: module.MODEL_PATH + "/" + Path(path).name for k, path in item["textures"].items()}
    return mesh, frames, shaders, module


def aquatic(row):
    import generate_nahuelito_combat_model as module

    config = json.loads((module.SOURCE / "ANIMATION.json").read_bytes())
    design = json.loads((ROOT / config["source_design"]).read_bytes())
    mesh = module.geometry(design)
    frames = []
    for recoil, fold, drop, settle in DATA["phases"]:
        control = dict(
            neck_pitch=13 * recoil + 93 * drop,
            neck_yaw=26 * settle,
            tail_yaw=-33 * settle,
            flipper_pitch=14 * recoil + 22 * drop,
            jaw_open=12 * fold - 9 * settle,
            body_roll=3 * drop,
        )
        points = np.array(
            [
                module.deform(p, j, control, design, config["deformation_rig"])
                for p, j in zip(mesh.vertices, mesh.parts)
            ]
        )
        hull = np.array([part == "body" and -50 < p[0] < 35 for part, p in zip(mesh.parts, mesh.vertices)])
        waterline = np.percentile(points[hull, 2], 4)
        compression = np.maximum(0, waterline - points[:, 2]) * settle
        points[:, 1] += np.sign(points[:, 1]) * compression * 0.48
        points[:, 2] += compression * 0.97
        points[:, 2] -= points[:, 2].min()
        frames.append(points.tolist())
    return (
        mesh,
        frames,
        {
            k: module.MODEL_PATH + "/" + v
            for k, v in dict(hide="skin.png", iris="iris.png", dark="dark.png").items()
        },
        module,
    )


def main():
    blocks = []
    records = {}
    for row in DATA["species"]:
        name = row["name"]
        mesh, frames, shaders, module = aquatic(row) if name == "nahuelito" else rigged(row)
        blob, _, _ = md3(mesh, frames, shaders)
        output = ROOT / "src" / module.MODEL_PATH / (name + "_fall.md3")
        output.write_bytes(blob)
        actor = "CaelumBestiary" + row["id"]
        source = (ROOT / "src" / module.DEFINITION).read_text()
        block = re.search(r"Model " + actor + r"\s*\{([^{}]*)\}", source)[1]
        directives = [
            line
            for line in block.splitlines()
            if line.lstrip().startswith(("Path ", "Scale ", "CorrectPixelStretch", "DontCullBackFaces"))
        ]
        blocks.extend(
            [
                "Model " + actor,
                "{",
                *directives,
                '    Model 0 "' + output.name + '"',
                *[f"    FrameIndex MNDG {letter} 0 {i}" for i, letter in enumerate("GHIJKL")],
                "}",
                "",
            ]
        )
        records[actor] = {
            "source": module.SOURCE.relative_to(ROOT).as_posix(),
            "model": output.relative_to(ROOT).as_posix(),
            "sha256": hashlib.sha256(blob).hexdigest(),
            "heights": [round(np.ptp(np.array(f)[:, 2]), 3) for f in frames],
        }
    (ROOT / "src/caelum/data/bestiary_deaths.modeldef").write_bytes(("\n".join(blocks) + "\n").encode())
    (ART / "PROVENANCE.json").write_bytes((json.dumps(records, indent=2) + "\n").encode())


if __name__ == "__main__":
    main()
