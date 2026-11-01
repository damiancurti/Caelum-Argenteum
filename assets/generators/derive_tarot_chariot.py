"""Center and scale the owned covered cart for the approved Tarot projection."""
from pathlib import Path
import argparse
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'src/models/caelum/vehicles/ca_covered_cart.obj'
OUTPUT = ROOT / 'src/models/caelum/vehicles/ca_tarot_chariot.obj'
MANIFEST = ROOT / 'assets/source/art/tarot_chariot/manifest.json'


def generated():
    raw = SOURCE.read_bytes()
    lines = raw.decode('utf-8').splitlines()
    vertices = [tuple(map(float, line.split()[1:4])) for line in lines if line.startswith('v ')]
    bounds = [(min(v[i] for v in vertices), max(v[i] for v in vertices)) for i in range(3)]
    data = (ROOT / 'src/caelum/data/CaelumMajorArcanaData.zs').read_text(encoding='utf-8')
    width = float(re.search(r'const CHARIOT_WIDTH_MU=([0-9.]+);', data).group(1))
    scale = width / (bounds[0][1] - bounds[0][0])
    center = ((bounds[0][0] + bounds[0][1]) / 2, bounds[1][0], (bounds[2][0] + bounds[2][1]) / 2)
    output = ['# Derived from the original Caelum Argenteum covered cart; issue #440.']
    for line in lines:
        if line.startswith('v '):
            vertex = tuple(map(float, line.split()[1:4]))
            line = 'v ' + ' '.join(f'{(vertex[i] - center[i]) * scale:.9f}' for i in range(3))
        elif line.startswith('o '):
            line = 'o CaelumTarotChariot'
        output.append(line)
    model = ('\n'.join(output) + '\n').encode('utf-8')
    manifest = {
        'issue': 440, 'approved': '2026-11-01',
        'source': SOURCE.relative_to(ROOT).as_posix(),
        'source_sha256': hashlib.sha256(raw).hexdigest(),
        'output': OUTPUT.relative_to(ROOT).as_posix(),
        'output_sha256': hashlib.sha256(model).hexdigest(),
        'provenance': 'Original project geometry and existing owned station/stash materials; no external artwork.',
        'operation': 'Uniform width scaling; center horizontal bounds; align lowest point to ground.',
        'width_map_units': width, 'source_bounds_obj_xyz': bounds, 'scale': scale,
        'dimensions_map_units_width_height_length': [(hi - lo) * scale for lo, hi in bounds],
        'materials_unchanged': sorted({line[7:] for line in lines if line.startswith('usemtl ')}),
        'vertices': len(vertices), 'author_visual_acceptance': False,
    }
    return model, (json.dumps(manifest, indent=2) + '\n').encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    model, manifest = generated()
    for path, content in ((OUTPUT, model), (MANIFEST, manifest)):
        if args.check:
            if not path.exists() or path.read_bytes() != content:
                raise SystemExit(f'Stale generated output: {path}')
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
    print('Tarot chariot geometry and provenance are current.')


if __name__ == '__main__':
    main()
