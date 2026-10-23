"""Deterministically register painted #479 sources; never repaint accepted art."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/art_source/support_sprites'
DATA = json.loads((ART / 'REGISTRATION.json').read_text(encoding='utf-8'))
OUT = ROOT / 'src/graphics/caelum'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def registered(source, size, anchor=None):
    image = source.copy()
    if anchor is None:
        image.thumbnail((112, 112), Image.Resampling.LANCZOS)
        point = ((size[0] - image.width) // 2, (size[1] - image.height) // 2)
    else:
        height, fraction, grip = anchor
        image = image.resize((round(image.width * height / image.height), height), Image.Resampling.LANCZOS)
        point = (round(grip[0] - image.width * fraction[0]), round(grip[1] - image.height * fraction[1]))
        assert point[0] >= 0 and point[1] >= 0
        assert point[0] + image.width <= size[0] and point[1] + image.height <= size[1]
    canvas = Image.new('RGBA', size)
    canvas.alpha_composite(image, point)
    return canvas


def main():
    generated, inputs, records = [], [Path(__file__), ART / 'REGISTRATION.json', ART / 'PROMPTS.json', ART / 'ORB_EDIT.json'], []
    contact = Image.new('RGBA', (6 * 160, 3 * 158), (26, 25, 28, 255))
    draw = ImageDraw.Draw(contact)
    for key, spec in DATA['new_implements'].items():
        path = ART / spec.get('source', key + '-source.png')
        inputs.append(path)
        atlas = Image.open(path).convert('RGBA')
        assert atlas.width == atlas.height * 3, 'Expected three square cells'
        for tier in range(1, 4):
            cell = atlas.crop(((tier - 1) * atlas.height, 0, tier * atlas.height, atlas.height))
            # Ignore nearly invisible source speckles without painting a background.
            alpha = cell.getchannel('A').point(lambda value: value if value >= DATA['alpha_floor'] else 0)
            cell.putalpha(alpha)
            bounds = cell.getbbox()
            assert bounds is not None and bounds[0] > 0 and bounds[2] < atlas.height
            cutout = cell.crop(bounds)
            icon = registered(cutout, (128, 128))
            fp = registered(cutout, (320, 200), (spec['first_person_height'], spec['grip_fraction'], spec.get('grip', [235, 158])))
            for folder, image in [('icons', icon), ('first_person', fp)]:
                output = OUT / folder / 'support_sprites' / f'{key}_t{tier}.png'
                output.parent.mkdir(parents=True, exist_ok=True)
                image.save(output)
                generated.append(output)
            records.append({'key': key, 'tier': tier, 'source_cell_bounds': bounds,
                            'icon_alpha_bounds': icon.getbbox(), 'first_person_alpha_bounds': fp.getbbox()})

    textures = []
    for index, key in enumerate(DATA['frame_order']):
        for tier in range(1, 4):
            letter = chr(65 + index * 3 + tier - 1)
            if key in ('book', 'statuette'):
                suffix = '' if tier == 1 else f'_t{tier}'
                icon = f'graphics/caelum/icons/ca_{key}{suffix}.png'
                stem = '15' if key == 'book' else '13'
                fp = f'sprites/caelum/first_person/v1/{key}/F{stem}{tier}A0.png'
                inputs += [ROOT / 'src' / icon, ROOT / 'src' / fp]
            else:
                icon = f'graphics/caelum/icons/support_sprites/{key}_t{tier}.png'
                fp = f'graphics/caelum/first_person/support_sprites/{key}_t{tier}.png'
            textures.append(f'Sprite "S479{letter}0", 128, 128 {{ Offset 64, 120 Patch "{icon}", 0, 0 }}')
            grip = DATA['new_implements'].get(key, {}).get('grip', [235, 158])
            textures.append(f'Sprite "H479{letter}0", 320, 200 {{ NoTrim Offset {grip[0]}, {grip[1]} Patch "{fp}", 0, 0 }}')
            contact.alpha_composite(Image.open(ROOT / 'src' / icon).convert('RGBA'), (index * 160 + 16, (tier - 1) * 158))
            draw.text((index * 160 + 8, (tier - 1) * 158 + 134), f'{key} T{tier}', fill='white')
    for material, key in ((89, 'censer'), (90, 'scepter'), (91, 'orb')):
        textures.append(f'Sprite "M{material:03}A0", 128, 128 {{ Offset 64, 120 Patch "graphics/caelum/icons/support_sprites/{key}_t1.png", 0, 0 }}')
    # Reuse the Book's exact palm modules; never repaint hands or the other weapons.
    grip = DATA['new_implements']['orb']['grip']
    states = ['// Generado por pack_support_sprites.py; palma original del Libro.',
              'class CaelumOrbHandFrames : Actor { States (Actor, Weapon, Overlay) {']
    for variant in range(-1, 37):
        path = ('sprites/caelum/first_person/v1/hands/FH02A0.png' if variant < 0
                else f'graphics/caelum/appearance/hands/{variant}/FH02.png')
        inputs.append(ROOT / 'src' / path)
        sprite = f'O{variant + 1:03d}'
        textures.append(f'Sprite "{sprite}A0", 320, 200 {{ NoTrim Offset {grip[0]}, {grip[1]} Patch "{path}", 0, 0 }}')
        label = 'Fallback' if variant < 0 else f'Hand{variant}'
        states.append(f'{label}: {sprite} A -1; Stop;')
    states.append('} }')
    hand_frames = ROOT / 'src/caelum/data/orb_hand_frames.zs'
    hand_frames.write_text('\n'.join(states) + '\n', encoding='utf-8', newline='\n')
    generated.append(hand_frames)
    texture_path = ROOT / 'src/caelum/data/support_sprites.textures'
    texture_path.write_text('\n'.join(textures) + '\n', encoding='utf-8', newline='\n')
    contact_path = ART / 'inventory-contact.png'
    contact.save(contact_path)
    generated += [texture_path, contact_path]
    reference_paths = [ROOT / 'src/graphics/caelum/icons/ca_staff.png', ROOT / 'src/graphics/caelum/icons/ca_statuette.png', ART / 'orb-source.png']
    manifest = {'issue': 479, 'stage': 'painted sprite correction; author review pending',
                'source_tool': 'built-in image_gen.imagegen',
                'processing': 'Three-cell extraction, alpha floor, Lanczos downscale and fixed registration only.',
                'records': records,
                'inputs': {p.relative_to(ROOT).as_posix(): digest(p) for p in sorted(set(inputs + reference_paths))},
                'outputs': {p.relative_to(ROOT).as_posix(): digest(p) for p in sorted(generated)}}
    (ART / 'MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(f'Packed {len(records)} new painted variants; accepted Book/Statuette sources reused unchanged.')


if __name__ == '__main__':
    main()
