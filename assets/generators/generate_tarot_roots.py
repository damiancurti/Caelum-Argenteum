"""Build deterministic thorned roots using the project's owned bark material."""
from pathlib import Path
import argparse
import hashlib
import json
import math
from generate_environment_models import Mesh

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / 'src/models/caelum/world/environment/ca_tarot_roots.obj'
MANIFEST = ROOT / 'assets/source/art/tarot_roots/manifest.json'
BARK = 'models/caelum/world/environment/bark_plains.png'


def generated():
    mesh = Mesh('CaelumTarotRoots')
    # Normalized radius and height follow the actual target's collision body.
    for strand in range(5):
        phase = strand * math.tau / 5
        previous = None
        for step in range(19):
            t = step / 18
            angle = phase + t * math.tau * (0.9 if strand % 2 else -0.9)
            radius = 1.03 + (1 - t) ** 5 * 0.7
            point = (radius * math.cos(angle), t * 0.83, radius * math.sin(angle))
            thickness = 0.075 * (1 - 0.65 * t)
            if previous is not None:
                mesh.add_frustum(BARK, previous, point, thickness + 0.003,
                                 thickness, sides=6, cap_start=False, cap_end=False)
            if step % 3 == 1:
                tip = (point[0] + 0.32 * math.cos(angle + 0.4),
                       point[1] + 0.055, point[2] + 0.32 * math.sin(angle + 0.4))
                mesh.add_frustum(BARK, point, tip, thickness * 1.2, 0.001,
                                 sides=5, cap_start=False, cap_end=True)
            previous = point
    lines = ['# Original project thorned-root geometry for issue #440.',
             '# OBJ axes: X width, Y height, Z depth; normalized target dimensions.',
             'o CaelumTarotRoots']
    lines += [f'v {x:.9f} {y:.9f} {z:.9f}' for x, y, z in mesh.vertices]
    lines += [f'vt {u:.6f} {v:.6f}' for u, v in mesh.uvs]
    lines += ['s 1', f'usemtl {BARK}']
    lines += ['f ' + ' '.join(f'{i}/{i}' for i in face) for _, face in mesh.faces]
    model = ('\n'.join(lines) + '\n').encode('utf-8')
    manifest = {
        'issue': 440, 'release': '5.13.3',
        'provenance': 'Original deterministic geometry; unchanged owned environment bark texture.',
        'generator': Path(__file__).relative_to(ROOT).as_posix(),
        'geometry_helper': 'assets/generators/generate_environment_models.py:Mesh',
        'material': 'src/' + BARK,
        'material_sha256': hashlib.sha256((ROOT / 'src' / BARK).read_bytes()).hexdigest(),
        'output': OUTPUT.relative_to(ROOT).as_posix(),
        'output_sha256': hashlib.sha256(model).hexdigest(),
        'vertices': len(mesh.vertices), 'faces': len(mesh.faces),
        'visual_only': 'Five intertwined thorned stems; dimensions follow the victim. No collision or damage comes from the model.',
        'author_visual_acceptance': False,
    }
    return model, (json.dumps(manifest, indent=2) + '\n').encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    for path, content in zip((OUTPUT, MANIFEST), generated()):
        if args.check:
            if not path.exists() or path.read_bytes() != content:
                raise SystemExit(f'Stale generated output: {path}')
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
    print('Tarot roots geometry and provenance are current.')


if __name__ == '__main__':
    main()
