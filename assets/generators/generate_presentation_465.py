"""Extend retained bitmap fonts and index existing credit notices deterministically."""
from pathlib import Path
import argparse
import hashlib
import json
import math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
FAMILIES = {'caelumtext': ('DejaVuSerif-Bold.ttf', 18),
            'caelumdisplay': ('DejaVuSerif-Bold.ttf', 26),
            'caelumsmall': ('DejaVuSerif-Bold.ttf', 14),
            'caelummono': ('DejaVuSansMono-Bold.ttf', 16),
            'alternativebigfont': ('DejaVuSerif-Bold.ttf', 24),
            'alternativesmallfont': ('DejaVuSerif-Bold.ttf', 20),
            'newconsolefont': ('DejaVuSansMono-Bold.ttf', 18),
            'smallfont': ('DejaVuSerif-Bold.ttf', 16)}
GLYPHS = [0x129, 0x2013, 0x2014, 0x2019, 0x201c, 0x201d]


def sha(blob):
    return hashlib.sha256(blob).hexdigest()


def generate(root=ROOT):
    from io import BytesIO
    result = {}
    font_root = root / 'src/fonts'
    aliases = {}
    for directory in sorted(font_root.iterdir()):
        if directory.is_dir():
            for family in FAMILIES:
                if (directory / '0041.png').read_bytes() == (font_root / family / '0041.png').read_bytes():
                    aliases[directory.name] = family
                    break
            if directory.name not in aliases:
                raise ValueError(f'Unrecognized existing font: {directory}')
    for family, (filename, size) in FAMILIES.items():
        font = ImageFont.truetype(str(root / 'assets/source/ui/typography_465' / filename), size)
        directory = font_root / family
        height = Image.open(directory / '0041.png').height
        # Recovered baseline, outline and fill match the retained A/i glyphs exactly.
        for character in 'Ai':
            original = Image.open(directory / f'{ord(character):04x}.png').convert('RGBA')
            probe = Image.new('RGBA', original.size)
            ImageDraw.Draw(probe).text((6-font.getbbox(character)[0], 4), character,
                font=font, fill='white', stroke_width=2, stroke_fill=(18, 20, 24, 230))
            if probe.tobytes() != original.tobytes():
                raise ValueError(f'Font renderer differs from retained {family}/{character}')
        for code in GLYPHS:
            character = chr(code)
            left, _, right, _ = font.getbbox(character)
            width = math.ceil((right-left+10)/2)*2
            bitmap = Image.new('RGBA', (width, height))
            ImageDraw.Draw(bitmap).text((6-left, 4), character, font=font,
                fill='white', stroke_width=2, stroke_fill=(18, 20, 24, 230))
            buffer = BytesIO(); bitmap.save(buffer, format='PNG', optimize=False)
            for alias, owner in aliases.items():
                if owner == family:
                    result[f'src/fonts/{alias}/{code:04x}.png'] = buffer.getvalue()
    result['src/licenses/CAELUM_RIGHTS.md'] = (root / 'LICENSE.md').read_bytes().replace(b'\r\n', b'\n')
    paths = ['licenses/CAELUM_RIGHTS.md'] + ['licenses/'+p.name for p in sorted((root/'src/licenses').iterdir())
        if p.is_file() and p.name != 'CAELUM_RIGHTS.md']
    rows = '\n'.join(f'            case {i}: return {json.dumps(path)};' for i, path in enumerate(paths))
    data = ('// Generado desde los avisos conservados; no concede derechos nuevos.\n'
        'class CaelumCreditsData : Object ui\n{\n'
        f'    const COUNT={len(paths)};\n'
        '    static String Path(int index)\n    {\n        switch(index)\n        {\n'+rows+
        '\n        }\n        return "";\n    }\n}\n')
    result['src/caelum/ui/CaelumCreditsData.zs'] = data.encode('utf-8')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    output = generate()
    for name, blob in output.items():
        path = ROOT/name
        if args.check:
            if not path.exists() or path.read_bytes() != blob:
                raise SystemExit('Stale generated presentation: '+name)
        else:
            path.parent.mkdir(parents=True, exist_ok=True); path.write_bytes(blob)
    print(f'{len(output)} presentation outputs '+('verified' if args.check else 'written'))


if __name__ == '__main__':
    main()
