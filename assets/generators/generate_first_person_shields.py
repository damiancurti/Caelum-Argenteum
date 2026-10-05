#!/usr/bin/env python3
"""Register original shield sheets as native textures; never repaint source pixels."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
MARKER = "// #106: generated first-person shield textures."


def generate():
    data = json.loads((ROOT / "assets/first_person_shields/COMPOSITION.json").read_text(encoding="utf-8"))
    textures = [MARKER]
    for item in data["types"]:
        palette = data["palette"]
        rgb = ", ".join(str(v) for v in palette["multiply_rgb"])
        muted = item["sprite"] + "_MUTED"
        textures.extend([
            f'Graphic "{muted}_D", 1536, 1024', "{",
            f'    Patch "{item["runtime"]}", 0, 0 {{ Translation "Desaturate", {palette["desaturate"]} }}', "}",
            f'Graphic "{muted}", 1536, 1024', "{",
            f'    Graphic "{muted}_D", 0, 0 {{ Blend {rgb} }}', "}",
        ])
        for frame, pose in data["poses"].items():
            source_pose = item[pose["source"]]
            scale = pose["scale"]
            anchor = pose["anchor_from_origin"]
            grip = source_pose["grip"]
            # GZDoom TEXTURES requires integer offsets, even with scaled sprites.
            offset = [round(grip[i] - anchor[i] * scale) for i in range(2)]
            textures.extend([
                f'Sprite "{item["sprite"]}{frame}0", {source_pose["width"]}, {source_pose["height"]}',
                "{", "    NoTrim", f"    XScale {scale}", f"    YScale {scale}",
                f"    Offset {offset[0]}, {offset[1]}",
                f'    Graphic "{muted}", {-source_pose["left"]}, 0', "}",
            ])
    for item in data.get("gauntlet_guards", []):
        scale = item["scale"]
        ox, oy = item["offset"]
        textures.extend([
            f'Graphic "{item["sprite"]}_D", 1536, 1024', "{",
            f'    Patch "{item["runtime"]}", 0, 0 {{ Translation "Desaturate", {palette["desaturate"]} }}', "}",
            f'Sprite "{item["sprite"]}A0", 1536, 1024', "{", "    NoTrim",
            f"    XScale {scale}", f"    YScale {scale}", f"    Offset {ox}, {oy}",
            f'    Graphic "{item["sprite"]}_D", 0, 0 {{ Blend {rgb} }}', "}",
        ])
    path = ROOT / "src/TEXTURES"
    original = path.read_text(encoding="utf-8").split(MARKER)[0].rstrip()
    path.write_text(original + "\n\n" + "\n".join(textures) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    generate()
