"""Check the two exact default-state aliases demonstrated necessary by #785."""
from pathlib import Path
import json
import re


def validate(root):
    root = Path(root)
    resource = 'caelum/data/inventory_inherited_defaults.modeldef'
    errors = []
    content = (root / 'src' / resource).read_text(encoding='utf-8')
    if ('#include "' + resource + '"') not in (root / 'src/MODELDEF').read_text():
        errors.append('Inventory default-state aliases are not included')
    cases = [
        ('CA_LimboMagicImplement', 'CaelumWeaponPickup', 'CSWD', 'inventory_bladed_weapons.modeldef'),
        ('CaelumJavelinAmmo', 'CaelumCarbineAmmo', 'CCAA', 'inventory_ammunition.modeldef'),
    ]
    for child, parent, sprite, source in cases:
        parent_text = (root / 'src/caelum/data' / source).read_text()
        def blocks(text, kind):
            return [body for body in re.findall(r'\bModel\s+' + kind + r'\s*\{([^}]+)\}', text)
                    if re.search(r'\bFrameIndex\s+' + sprite + r'\s+A\s+0\s+0\b', body)]
        direct, inherited = blocks(content, child), blocks(parent_text, parent)
        if len(direct) != 1 or len(inherited) != 1:
            errors.append(f'{child}: expected one exact {sprite} A alias and parent reference')
            continue
        if direct[0].split() != inherited[0].split():
            errors.append(f'{child}: alias differs from the current parent model definition')
        path = re.search(r'\bPath\s+"([^"]+)"', direct[0])
        model = re.search(r'\bModel\s+0\s+"([^"]+)"', direct[0])
        if not path or not model or not (root / 'src' / path[1] / model[1]).is_file():
            errors.append(f'{child}: missing native model resource')
    return errors


if __name__ == '__main__':
    problems = validate(Path(__file__).resolve().parents[2])
    print(json.dumps({'errors': problems}))
    raise SystemExit(bool(problems))
