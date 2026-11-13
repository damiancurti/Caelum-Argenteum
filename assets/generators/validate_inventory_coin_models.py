"""Check the owned coin model installation without art-editing dependencies."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors = []
    try:
        directory = root / 'assets/source/art/inventory_models_647'
        config_path = directory / 'COINS.json'
        config = json.loads(config_path.read_text(encoding='utf-8'))
        report = json.loads((directory / 'COINS_EXPORT.json').read_text(encoding='utf-8'))
        sources = {'config': config_path, 'generator': root / 'assets/generators/generate_inventory_coin_models.py'}
        for name, path in sources.items():
            if hashlib.sha256(path.read_bytes()).hexdigest() != report[name + '_sha256']:
                errors.append('Inventory coins: stale source ' + name)
        for item in config['variants'].values():
            if hashlib.sha256((root / item['image']).read_bytes()).hexdigest() != item['source_sha256']:
                errors.append('Inventory coins: changed accepted face ' + item['image'])
        for name, checksum in report['sha256'].items():
            path = root / 'src' / name
            if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                errors.append('Inventory coins: missing or stale runtime ' + name)
        definition = (root / 'src/caelum/data/inventory_coins.modeldef').read_text(encoding='utf-8')
        actual = re.findall(r'\bModel\s+(\w+)\s*\{', definition)
        expected = [item['class'] + suffix for item in config['variants'].values()
                    for suffix in config['denomination_suffixes']]
        if actual != expected or len(set(actual)) != len(expected):
            errors.append('Inventory coins: incomplete explicit denomination bindings')
        include = '#include "caelum/data/inventory_coins.modeldef"'
        if (root / 'src/MODELDEF').read_text(encoding='utf-8').count(include) != 1:
            errors.append('Inventory coins: expected one production include')
    except (OSError, KeyError, ValueError) as exc:
        errors.append('Inventory coins: ' + str(exc))
    return errors


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
