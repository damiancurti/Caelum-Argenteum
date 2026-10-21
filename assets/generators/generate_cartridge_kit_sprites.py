"""Deterministically register #380 kit artwork; no painting or source changes."""
from pathlib import Path
import hashlib
import json
from PIL import Image, __version__

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/art_source/cartridge_kits"
OUTPUT = ROOT / "src/graphics/caelum/icons/materials"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if __version__ != "11.3.0":
        raise SystemExit("Use Pillow 11.3.0 for deterministic exports.")
    catalogue = json.loads((SOURCE / "manifest.json").read_text(encoding="utf-8"))
    textures = ["// #380: kits preparados, pivotes apoyados sobre el suelo."]
    exports = []
    for row in catalogue["sources"]:
        source = ROOT / row["source"]
        original = Image.open(source).convert("RGBA")
        alpha = original.getchannel("A")
        bounds = alpha.getbbox()
        if alpha.getextrema()[0] != 0 or bounds is None:
            raise ValueError(f"Missing transparent artwork: {source}")
        cropped = original.crop(bounds)
        factor = 120 / max(cropped.size)
        scaled = cropped.convert("RGBa").resize(
            (max(1, round(cropped.width * factor)), max(1, round(cropped.height * factor))),
            Image.Resampling.LANCZOS,
        ).convert("RGBA")
        icon = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
        icon.alpha_composite(scaled, ((128-scaled.width)//2, (128-scaled.height)//2))
        output = OUTPUT / f"ca_material_{row['id']}.png"
        icon.save(output, compress_level=9, optimize=False)
        bottom = icon.getchannel("A").getbbox()[3]
        sprite = f"M{row['material_type']:03d}A0"
        textures.append(f'Sprite "{sprite}", 128, 128 {{ Offset 64, {bottom} Patch "{output.relative_to(ROOT / "src").as_posix()}", 0, 0 }}')
        exports.append({"id": row["id"], "source": row["source"],
            "source_sha256": digest(source), "output": output.relative_to(ROOT).as_posix(),
            "output_sha256": digest(output), "source_size": list(original.size),
            "source_alpha_bounds": list(bounds), "sprite": sprite, "pivot": [64, bottom]})
    (ROOT / "src/caelum/data/cartridge_kits.textures").write_text("\n".join(textures)+"\n", encoding="utf-8", newline="\n")
    (SOURCE / "exports.json").write_text(json.dumps({"issue":380,"pillow":__version__,"exports":exports},indent=2)+"\n",encoding="utf-8",newline="\n")
    print(f"Exported {len(exports)} kit sprites.")


if __name__ == "__main__":
    main()
