"""Check the installed consumable art sources, native meshes and explicit bindings."""
from pathlib import Path
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors = []
    try:
        directory = root / 'assets/source/art/inventory_models_647/consumables'
        config = json.loads((directory / 'DESIGN.json').read_text(encoding='utf-8'))
        report = json.loads((directory / 'EXPORT.json').read_text(encoding='utf-8'))
        sources = {directory / name: checksum for name, checksum in report['source_sha256'].items()}
        sources[root / 'assets/generators/generate_inventory_consumable_models.py'] = report['generator_sha256']
        sources.update({root / 'assets/generators' / name: checksum for name, checksum in report['shared_generator_sha256'].items()})
        sources.update({root / item['icon']: item['icon_sha256'] for item in config['variants'].values()})
        for path, checksum in sources.items():
            if hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                errors.append('Inventory consumables: stale source ' + str(path.relative_to(root)))
        for name, checksum in report['sha256'].items():
            if name.startswith('editable/'):
                continue  # Regenerable OBJ authoring export, not a runtime resource.
            path = root / 'src' / name
            if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                errors.append('Inventory consumables: missing or stale runtime ' + name)
        definition = (root / 'src/caelum/data/inventory_consumables.modeldef').read_text(encoding='utf-8')
        actual = re.findall(r'\bModel\s+(\w+)\s*\{', definition)
        expected = [item['class'] for item in config['variants'].values()]
        if actual != expected or len(set(actual)) != len(expected):
            errors.append('Inventory consumables: explicit class coverage differs')
        for name, record in report['variants'].items():
            blob = (root / 'src' / config['model_path'] / (name + '.md3')).read_bytes()
            header = struct.unpack_from('<4sI64s9I', blob)
            if header[:2] != (b'IDP3', 15) or header[4] != 1 or header[6] != len(record['surfaces']) or header[11] != len(blob):
                errors.append('Inventory consumables: invalid native header ' + name)
            offset = header[10]
            for surface in record['surfaces']:
                fields = struct.unpack_from('<4s64s10I', blob, offset)
                if fields[3] != 1 or fields[5:7] != (surface['vertices'], surface['triangles']):
                    errors.append('Inventory consumables: invalid surface counts ' + name)
                offset += fields[-1]
            if offset != len(blob):
                errors.append('Inventory consumables: invalid container end ' + name)
        include = '#include "caelum/data/inventory_consumables.modeldef"'
        if (root / 'src/MODELDEF').read_text(encoding='utf-8').count(include) != 1:
            errors.append('Inventory consumables: expected one production include')
    except (OSError, KeyError, ValueError, struct.error) as exc:
        errors.append('Inventory consumables: ' + str(exc))
    return errors


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
