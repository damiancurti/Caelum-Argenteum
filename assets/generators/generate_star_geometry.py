"""Derive Tarot volume adapters from existing owned furniture dimensions."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def generate():
    def read(name):
        return json.loads((ROOT / 'assets/art_source' / name / 'DATA.json').read_text(encoding='utf-8'))

    basic = read('basic_rest_furniture')
    wardrobe = read('wardrobe')
    cupboard = read('kitchen_fixtures')['cupboard']
    values = {
        'BASIC_CHAIR_VOLUME': basic['chair']['width'] * basic['chair']['depth'] * basic['chair']['height'],
        'BASIC_BED_VOLUME': basic['bed']['width'] * basic['bed']['depth'] * basic['bed']['height'],
        'WARDROBE_VOLUME': wardrobe['width_m'] * wardrobe['depth_m'] * wardrobe['height_m'],
        'CUPBOARD_VOLUME': cupboard['width_m'] * cupboard['depth_m'] * cupboard['height_m'],
    }
    lines = ['// #440: volúmenes exteriores derivados de las dimensiones de #410.',
             'class CaelumStarData : Object', '{', '    const REVISION=2;']
    lines += [f'    const {key}={value:.12f};' for key, value in values.items()]
    lines += ['}', '']
    (ROOT / 'src/caelum/data/CaelumStarData.zs').write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    print(json.dumps(values))


if __name__ == '__main__':
    generate()
