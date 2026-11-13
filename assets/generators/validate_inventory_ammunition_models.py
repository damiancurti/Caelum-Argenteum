"""Check the seven installed ammunition models and their unchanged owned textures."""
from pathlib import Path
import hashlib
import json
import math
import re
import struct

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors = []
    try:
        directory = root / 'assets/source/art/inventory_models_647/ammunition'
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
        expected = [item['class'] for item in config['variants'].values()]
        definition = (root / 'src/caelum/data/inventory_ammunition.modeldef').read_text()
        if len(expected) != 7 or len(set(expected)) != 7 or re.findall(r'\bModel\s+(\w+)\s*\{', definition) != expected:
            errors.append('Expected seven distinct explicit production bindings')
        include = '#include "caelum/data/inventory_ammunition.modeldef"'
        if (root / 'src/MODELDEF').read_text(encoding='utf-8').count(include) != 1:
            errors.append('Expected one production include')
        for name, record in report['variants'].items():
            blob = (root / 'src' / config['model_path'] / (name + '.md3')).read_bytes()
            header = struct.unpack_from('<4sI64s9I', blob)
            if header[:2] != (b'IDP3', 15) or header[4] != 1 or header[6] != len(record['surfaces']) or header[11] != len(blob):
                errors.append('Invalid MD3 header: ' + name)
            offset = header[10]
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
                offset += fields[-1]
            if offset != len(blob):
                errors.append('Invalid MD3 container end: ' + name)
    except (OSError, KeyError, ValueError, struct.error) as exc:
        errors.append(str(exc))
    return ['Inventory ammunition: ' + error for error in errors]


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
