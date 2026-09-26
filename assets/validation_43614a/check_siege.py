"""Focused #18 regression: exclusive model states, resources and determinism."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot():
    paths = list((ROOT / 'src/models/caelum/siege').glob('*.obj'))
    for prefix in ('CSGN', 'CRAM', 'CAGT', 'CAGR', 'CAGA'):
        paths.extend((ROOT / 'src/sprites').glob(prefix + '*.png'))
    paths += [ROOT / 'src/MODELDEF', ROOT / 'src/caelum/world/CaelumSiegeAssets.zs']
    return {str(p.relative_to(ROOT)).replace('\\', '/'): digest(p) for p in sorted(paths)}


before = snapshot()
for run in range(2):
    subprocess.run([sys.executable, str(ROOT / 'assets/generators/generate_siege_models.py')],
                   cwd=ROOT, check=True)
    assert snapshot() == before, f'Generator changed committed outputs on run {run + 1}'

modeldef = (ROOT / 'src/MODELDEF').read_text(encoding='utf-8')
block = modeldef.split('// --- BEGIN GENERATED CAELUM SIEGE MODELS ---')[1]
bindings = {}
for actor, body in re.findall(r'Model\s+(\w+)\s*\{([^}]+)\}', block):
    models = re.findall(r'\bModel\s+(\d+)\s+"([^"]+)"', body)
    frames = re.findall(r'FrameIndex\s+(\w+)\s+(\w)\s+(\d+)\s+(\d+)', body)
    assert len(models) == len(frames) == 1, f'{actor}: overlapping model slots'
    assert models[0][0] == frames[0][2] == '0'
    key = actor + ':' + frames[0][0] + ':' + frames[0][1]
    assert key not in bindings, f'Duplicate state {key}'
    bindings[key] = models[0][1]
assert len(bindings) == len(set(bindings.values())) == 16

meshes = {}
for model in bindings.values():
    path = ROOT / 'src/models/caelum/siege' / model
    text = path.read_text(encoding='utf-8')
    vertices = [tuple(map(float, line.split()[1:])) for line in text.splitlines() if line.startswith('v ')]
    uvs = [line for line in text.splitlines() if line.startswith('vt ')]
    faces = [line for line in text.splitlines() if line.startswith('f ')]
    for face in faces:
        for pair in face.split()[1:]:
            v, uv = map(int, pair.split('/'))
            assert 1 <= v <= len(vertices) and 1 <= uv <= len(uvs), model
    for material in re.findall(r'^usemtl (.+)$', text, re.M):
        assert (ROOT / 'src' / material).is_file(), material
    meshes[model] = {'vertices': len(vertices), 'faces': len(faces),
                     'min': [min(v[i] for v in vertices) for i in range(3)],
                     'max': [max(v[i] for v in vertices) for i in range(3)]}

report = {'result': 'PASS', 'deterministic_runs': 2,
          'exclusive_states': len(bindings), 'hashes': before, 'meshes': meshes}
(Path(__file__).parent / 'STATIC.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print('PASS: 16 exclusive states, valid OBJ/material references, two byte-identical regenerations.')
