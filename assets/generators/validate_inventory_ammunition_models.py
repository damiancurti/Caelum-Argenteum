"""Check the seven installed ammunition models and their unchanged owned textures."""
from pathlib import Path
import hashlib
import json
import math
import re
import struct

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT, family='ammunition', expected_count=7, distinct_classes=True):
    errors = []
    try:
        directory = root / 'assets/source/art/inventory_models_647' / family
        config = json.loads((directory / 'DESIGN.json').read_text(encoding='utf-8'))
        report = json.loads((directory / 'EXPORT.json').read_text(encoding='utf-8'))
        sources = {directory / name: checksum for name, checksum in report['source_sha256'].items()}
        sources.update({root / name: checksum for name, checksum in report['external_source_sha256'].items()})
        sources.update({root / 'assets/generators' / name: checksum for name, checksum in report['generator_sha256'].items()})
        for path, checksum in sources.items():
            if hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                errors.append('Stale owned source: ' + str(path.relative_to(root)))
        for name, checksum in report['sha256'].items():
            if name.startswith('editable/'):
                continue
            if hashlib.sha256((root / 'src' / name).read_bytes()).hexdigest() != checksum:
                errors.append('Stale installed resource: ' + name)
        expected = [binding['class'] for item in config['variants'].values()
                    for binding in [item, *item.get('additional_bindings', [])]]
        definition = (root / 'src/caelum/data' / ('inventory_' + family + '.modeldef')).read_text()
        if len(expected) != expected_count or (distinct_classes and len(set(expected)) != expected_count) or re.findall(r'\bModel\s+(\w+)\s*\{', definition) != expected:
            errors.append(f'Expected {expected_count} distinct explicit production bindings')
        expected_pairs = [(binding['class'], binding['sprite']) for item in config['variants'].values()
                          for binding in [item, *item.get('additional_bindings', [])]]
        actual_pairs = [(kind, sprite) for kind, body in re.findall(r'\bModel\s+(\w+)\s*\{([^}]+)\}', definition)
                        for sprite in re.findall(r'\bFrameIndex\s+(\w+)\s+A\s+0\s+0\b', body)]
        if actual_pairs != expected_pairs or len(set(expected_pairs)) != expected_count:
            errors.append('Expected unique exact class/sprite/A bindings')
        include = '#include "caelum/data/inventory_' + family + '.modeldef"'
        if (root / 'src/MODELDEF').read_text(encoding='utf-8').count(include) != 1:
            errors.append('Expected one production include')
        for name, record in report['variants'].items():
            blob = (root / 'src' / config['model_path'] / (name + '.md3')).read_bytes()
            header = struct.unpack_from('<4sI64s9I', blob)
            if header[:2] != (b'IDP3', 15) or header[4] != 1 or header[6] != len(record['surfaces']) or header[11] != len(blob):
                errors.append('Invalid MD3 header: ' + name)
            offset = header[10]
            low = record['native_bounds'][0]['min']
            high = record['native_bounds'][0]['max']
            for surface in record['surfaces']:
                fields = struct.unpack_from('<4s64s10I', blob, offset)
                if fields[3:7] != (1, 1, surface['vertices'], surface['triangles']):
                    errors.append('Invalid surface counts: ' + name)
                settings = config['materials'][surface['material']]
                shader = blob[offset + fields[8]:offset + fields[8] + 64].split(b'\0')[0].decode()
                if shader != settings['texture'] or not (root / 'src' / shader).is_file():
                    errors.append('Invalid owned shader: ' + name)
                left, top, right, bottom = settings['rect_pixels']
                width, height = settings['image_size']
                for index in range(surface['vertices']):
                    u, v = struct.unpack_from('<2f', blob, offset + fields[9] + index * 8)
                    if not (math.isfinite(u) and math.isfinite(v) and left / width - 1e-6 <= u <= right / width + 1e-6 and top / height - 1e-6 <= v <= bottom / height + 1e-6):
                        errors.append('UV leaves its owned material rectangle: ' + name)
                        break
                    point = struct.unpack_from('<3h', blob, offset + fields[10] + index * 8)
                    if any(not low[axis] - 1 / 64 <= point[axis] / 64 <= high[axis] + 1 / 64 for axis in range(3)):
                        errors.append('Quantized vertex leaves its declared bounds: ' + name)
                        break
                for index in range(surface['triangles']):
                    triangle = struct.unpack_from('<3I', blob, offset + fields[7] + index * 12)
                    if len(set(triangle)) != 3 or any(vertex >= surface['vertices'] for vertex in triangle):
                        errors.append('Invalid native triangle indices: ' + name)
                        break
                offset += fields[-1]
            if offset != len(blob):
                errors.append('Invalid MD3 container end: ' + name)
    except (OSError, KeyError, ValueError, struct.error) as exc:
        errors.append(str(exc))
    return ['Inventory ' + family + ': ' + error for error in errors]


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
