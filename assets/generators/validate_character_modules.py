"""Check installed modular character exports without requiring Blender."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors = []
    try:
        directory = root/'assets/source/art/character_modules_458'
        config = json.loads((directory/'MODULES.json').read_text(encoding='utf-8'))
        report = json.loads((directory/'EXPORT.json').read_text(encoding='utf-8'))
        sources = {'source': root/config['source_blend'], 'config': directory/'MODULES.json',
                   'design': root/config['source_design'], 'baseline': root/config['baseline_model'],
                   'generator': root/'assets/generators/export_character_modules.py'}
        for name, path in sources.items():
            if hashlib.sha256(path.read_bytes()).hexdigest() != report[name+'_sha256']:
                errors.append('Character modules: stale source '+name)
        for name, checksum in report['sha256'].items():
            if name == 'MODELDEF':
                continue  # Isolated preview registration, never a production include.
            path = root/'src'/name
            if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                errors.append('Character modules: missing or stale runtime '+name)
        for name, group in report['modules'].items():
            path = root/'src'/config['module_path']/(name+'.md3')
            blob = path.read_bytes()
            header = struct.unpack_from('<4sI64s9I', blob)
            surface = struct.unpack_from('<4s64s10I', blob, header[10])
            if header[:2] != (b'IDP3', 15) or header[6] != 1 or header[11] != len(blob):
                errors.append('Character modules: invalid native container '+name)
            if (surface[3], surface[5], surface[6]) != (report['frames'], group['vertices'], group['triangles']):
                errors.append('Character modules: mismatched native counts '+name)
        binding = '#include "caelum/data/domingo_modules.modeldef"'
        if (root/'src/MODELDEF').read_text(encoding='utf-8').count(binding) != 1:
            errors.append('Character modules: expected one production model include')
        if '#include "caelum/data/CaelumDomingoModules.zs"' not in (root/'src/ZSCRIPT').read_text(encoding='utf-8'):
            errors.append('Character modules: missing native selection helper')
        if report['baseline_mismatches']:
            errors.append('Character modules: accepted source equivalence failed')
    except (OSError, KeyError, ValueError, struct.error) as exc:
        errors.append('Character modules: '+str(exc))
    return errors


if __name__ == '__main__':
    result = validate()
    print(json.dumps({'errors': result}))
    raise SystemExit(bool(result))
