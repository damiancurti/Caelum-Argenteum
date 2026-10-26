"""Pack painted ingredient sources using the authorized deterministic art pipeline."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/art_source/cooking_ingredients'
DESTINATION = ROOT / 'src/graphics/caelum/icons/kitchen'
ASSETS = ('flour', 'beef', 'fish', 'vegetables', 'salt')


def main():
    DESTINATION.mkdir(parents=True, exist_ok=True)
    records = []
    board = Image.new('RGBA', (128 * len(ASSETS), 128), (44, 40, 36, 255))
    for index, name in enumerate(ASSETS):
        path = SOURCE / (name + '.png')
        image = Image.open(path).convert('RGBA')
        # Remove translucent matte fringe, retaining the complete painted source.
        alpha = image.getchannel('A').point(lambda a: 255 if a >= 128 else 0)
        assert alpha.getbbox(), name
        image.putalpha(alpha)
        image = image.crop(alpha.getbbox())
        image.thumbnail((116, 116), Image.Resampling.LANCZOS)
        output = Image.new('RGBA', (128, 128))
        output.alpha_composite(image, ((128 - image.width) // 2, 122 - image.height))
        destination = DESTINATION / (name + '.png')
        output.save(destination, optimize=False)
        board.alpha_composite(output, (128 * index, 0))
        records.append({'name': name, 'source_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                        'runtime': destination.relative_to(ROOT).as_posix(),
                        'runtime_sha256': hashlib.sha256(destination.read_bytes()).hexdigest()})
    board.save(SOURCE / 'contact-sheet.png', optimize=False)
    (SOURCE / 'EXPORT.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
    aliases = '\n'.join(f'Sprite "M{108 + i:03d}A0", 128, 128 {{ Offset 64, 122 Patch "graphics/caelum/icons/kitchen/{name}.png", 0, 0 }}' for i, name in enumerate(ASSETS))
    (ROOT / 'src/caelum/data/kitchen_ingredients.textures').write_text(aliases + '\n', encoding='utf-8')
    print('Packed five 128px ingredient sprites and texture aliases.')


if __name__ == '__main__':
    main()
