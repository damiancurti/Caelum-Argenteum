"""Export #387 source artwork with Pillow 11.3.0; never paint or replace sources."""
from pathlib import Path
import hashlib
import json

from PIL import Image, ImageDraw, __version__

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/art_source/clothing"
OUTPUT = ROOT / "src/graphics/caelum/icons/clothing"
MANIFEST = SOURCE / "manifest.json"
SIZE = 128
MARGIN = 4


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if __version__ != "11.3.0":
        raise SystemExit("Use Pillow 11.3.0 for deterministic clothing exports.")
    catalogue = json.loads(MANIFEST.read_text(encoding="utf-8"))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    textures = ["// #387: sprites propios; el pivote apoya la imagen sobre el suelo."]
    exports = []
    sheet = Image.new("RGB", (5 * 160, 5 * 160), (65, 76, 88))
    drawing = ImageDraw.Draw(sheet)
    for index, row in enumerate(catalogue["sources"]):
        source = ROOT / row["source"]
        original = Image.open(source).convert("RGBA")
        alpha = original.getchannel("A")
        if alpha.getextrema()[0] != 0:
            raise ValueError(f"Missing transparent background: {source}")
        bounds = alpha.getbbox()
        if bounds is None:
            raise ValueError(f"Empty artwork: {source}")
        cropped = original.crop(bounds)
        factor = (SIZE - 2 * MARGIN) / max(cropped.size)
        scaled = cropped.convert("RGBa").resize(
            (max(1, round(cropped.width * factor)), max(1, round(cropped.height * factor))),
            Image.Resampling.LANCZOS,
        ).convert("RGBA")
        icon = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        icon.alpha_composite(scaled, ((SIZE - scaled.width) // 2, (SIZE - scaled.height) // 2))
        filename = f"ca_clothing_{index:02d}.png"
        output = OUTPUT / filename
        icon.save(output, compress_level=9, optimize=False)
        bottom = icon.getchannel("A").getbbox()[3]
        textures.append(f'Sprite "WC{index:02d}A0", {SIZE}, {SIZE} {{ Offset {SIZE//2}, {bottom} Patch "graphics/caelum/icons/clothing/{filename}", 0, 0 }}')
        x, y = index % 5 * 160, index // 5 * 160
        sheet.paste(icon, (x + 16, y + 4), icon)
        drawing.text((x + 12, y + 140), f"{index:02d}  {row['id']}", fill=(255, 245, 220))
        exports.append({"type": index, "id": row["id"], "source": row["source"],
                        "source_sha256": digest(source), "output": output.relative_to(ROOT).as_posix(),
                        "output_sha256": digest(output), "source_size": list(original.size),
                        "source_alpha_bounds": list(bounds), "sprite": f"WC{index:02d}A0", "pivot": [SIZE//2, bottom]})
    (ROOT / "src/caelum/data/clothing_sprites.textures").write_text("\n".join(textures) + "\n", encoding="utf-8", newline="\n")
    (SOURCE / "exports.json").write_text(json.dumps({"issue": 387, "pillow": __version__, "exports": exports}, indent=2) + "\n", encoding="utf-8", newline="\n")
    sheet.save(SOURCE / "contact-sheet.png", compress_level=9, optimize=False)
    print(f"Exported {len(exports)} clothing sprites and the review contact sheet.")


if __name__ == "__main__":
    main()
