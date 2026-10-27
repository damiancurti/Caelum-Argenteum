"""Verify repeated kitchen exports and preserve prior ingredient/meal output bytes."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]

def digest(paths):
    return {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in paths}

def run(script, *args):
    subprocess.run([sys.executable, str(ROOT / 'assets/generators' / script), *args],
                   check=True, cwd=ROOT, stdout=subprocess.DEVNULL)

def generated():
    paths = list((ROOT / 'src/models/caelum/props/kitchen').glob('*'))
    paths += list((ROOT / 'src/graphics/caelum/icons/kitchen_stations').glob('*'))
    paths += [ROOT / 'src/graphics/caelum/icons/kitchen/dough.png']
    paths += [ROOT / 'src/caelum/data' / name for name in (
        'CaelumKitchenFurnitureData.zs', 'kitchen_stations.modeldef',
        'kitchen_stations.textures', 'kitchen_dough.textures')]
    paths += [ROOT / 'assets/art_source/kitchen_stations/MANIFEST.json',
              ROOT / 'assets/art_source/kitchen_dough/EXPORT.json',
              ROOT / 'assets/art_source/kitchen_dough/contact-sheet.png']
    return paths

prior = [p for folder in ('kitchen', 'meals')
         for p in (ROOT / 'src/graphics/caelum/icons' / folder).glob('*.png')
         if p.name != 'dough.png']
prior += [ROOT / 'src/caelum/data' / name for name in (
    'kitchen_ingredients.textures', 'cooked_meals.textures')]
before = digest(prior)
run('pack_kitchen_ingredients.py')
run('pack_kitchen_ingredients.py', '--meals')
assert digest(prior) == before, 'Previously accepted exports changed.'
run('pack_kitchen_ingredients.py', '--dough')
run('generate_kitchen_stations.py')
first = digest(generated())
run('pack_kitchen_ingredients.py', '--dough')
run('generate_kitchen_stations.py')
assert digest(generated()) == first, 'Kitchen export is not deterministic.'
report = {'previous_outputs_unchanged': len(before), 'repeat_outputs_equal': len(first),
          'sha256': first}
(ROOT / 'assets/validation_5819/exports.json').write_text(
    json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(f'Unchanged accepted outputs: {len(before)}; deterministic new outputs: {len(first)}')
