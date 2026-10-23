"""Register owned painted mate sources without repainting or generating geometry."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "assets/art_source/mate_sprites"
DATA = json.loads((ART / "PROMPTS.json").read_text(encoding="utf-8"))["registration"]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    inputs = [Path(__file__), ART / "PROMPTS.json"]
    outputs, records, textures = [], [], []
    sheet = Image.new("RGBA", (600, 324), (29, 27, 29, 255))
    draw = ImageDraw.Draw(sheet)
    for index, key in enumerate(("gourd", "silver", "gold")):
        source_path = ART / f"{key}-source.png"
        inputs.append(source_path)
        source = Image.open(source_path).convert("RGBA")
        bounds = source.getbbox()
        assert bounds and source.getchannel("A").getextrema() == (0, 255)
        cutout = source.crop(bounds)
        cutout.thumbnail(tuple(DATA["fit"]), Image.Resampling.LANCZOS)
        icon = Image.new("RGBA", tuple(DATA["canvas"]))
        icon.alpha_composite(cutout, ((icon.width - cutout.width) // 2, DATA["bottom"] - cutout.height))
        output = ROOT / f"src/graphics/caelum/icons/mate/{key}.png"
        icon.save(output)
        outputs.append(output)
        scale = DATA["world_texture_scale"]
        textures.append(f'Sprite CMA{index}A0, 128, 128 {{ XScale {scale} YScale {scale} Offset 64, 120 Patch "graphics/caelum/icons/mate/{key}.png", 0, 0 }}')
        records.append({"key": key, "source_bounds": bounds, "icon_bounds": icon.getbbox()})
        sheet.alpha_composite(icon, (index * 200 + 36, 4))
        draw.text((index * 200 + 12, 138), key + " / 128 px", fill="white")
        # Preview actual UI sizes; nearest enlargement exposes the resulting pixels.
        small = icon.resize((20, 20), Image.Resampling.LANCZOS)
        sheet.alpha_composite(small, (index * 200 + 90, 160))
        sheet.alpha_composite(small.resize((100, 100), Image.Resampling.NEAREST), (index * 200 + 50, 190))
        draw.text((index * 200 + 12, 300), "20 px / enlarged 5x", fill="white")
    textures.append('Sprite M104A0, 128, 128 { Offset 64, 120 Patch "graphics/caelum/icons/mate/dry_gourd.png", 0, 0 }')
    texture_path = ROOT / "src/caelum/data/mate.textures"
    texture_path.write_text("\n".join(textures) + "\n", encoding="utf-8", newline="\n")
    model_path = ROOT / "src/caelum/data/mate.modeldef"
    model_path.write_text('// Mate vessels use painted billboards; retained legacy meshes are unbound.\nModel CaelumMaterialPickup { Path "models/caelum/world/mate" Model 0 "dry_gourd.obj" Scale 4 4 4 FrameIndex M104 A 0 0 }\n', encoding="utf-8", newline="\n")
    contact_path = ART / "contact-sheet.png"
    sheet.save(contact_path)
    outputs += [texture_path, model_path, contact_path]
    manifest = {"issue": 472, "exporter": "Pillow " + Image.__version__, "registration": DATA,
                "inputs": {p.relative_to(ROOT).as_posix(): digest(p) for p in inputs},
                "outputs": {p.relative_to(ROOT).as_posix(): digest(p) for p in outputs}, "assets": records}
    (ART / "MANIFEST.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    print("Registered three painted mate sprites, world bindings and inventory review sheet")


if __name__ == "__main__":
    main()
