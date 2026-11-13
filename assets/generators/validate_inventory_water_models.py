"""Verify water-drop art and preservation of the existing dining canteen."""
from pathlib import Path
import hashlib
import json
try:
    from .validate_inventory_consumable_models import validate as validate_shared
except ImportError:
    from validate_inventory_consumable_models import validate as validate_shared

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors = validate_shared(root, 'water', 'inventory_water.modeldef')
    try:
        source = root / 'assets/source/art/inventory_models_647/water'
        config = json.loads((source / 'DESIGN.json').read_text(encoding='utf-8'))
        report = json.loads((source / 'EXPORT.json').read_text(encoding='utf-8'))
        wrapper = root / 'assets/generators/generate_inventory_water_models.py'
        if hashlib.sha256(wrapper.read_bytes()).hexdigest() != report['wrapper_sha256']:
            errors.append('Inventory water: stale wrapper source')
        for item in report['reused_variants']:
            for name, checksum in item['source_sha256'].items():
                if hashlib.sha256((root / name).read_bytes()).hexdigest() != checksum:
                    errors.append('Inventory water: changed reused source ' + name)
            original = (root / item['obj']).read_text(encoding='utf-8').splitlines()
            target = (root / 'src' / config['model_path'] / (item['key'] + '.obj')).read_text(encoding='utf-8').splitlines()
            if [line for line in original if not line.startswith('v ')] != [line for line in target if not line.startswith('v ')]:
                errors.append('Inventory water: reused topology, UVs or texture changed')
    except (OSError, KeyError, ValueError) as exc:
        errors.append('Inventory water: ' + str(exc))
    return errors


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
