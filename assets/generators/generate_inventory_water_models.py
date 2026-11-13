"""Export five reference-led water models and a normalized existing canteen."""
from pathlib import Path
import argparse
import json
import zipfile
from PIL import Image

try:
    from .generate_inventory_consumable_models import ROOT, digest, output_files
except ImportError:
    from generate_inventory_consumable_models import ROOT, digest, output_files

SOURCE = ROOT / 'assets/source/art/inventory_models_647/water'


def water_files():
    files = output_files(SOURCE, 'inventory_water.modeldef')
    config = json.loads((SOURCE / 'DESIGN.json').read_text(encoding='utf-8'))
    manifest = json.loads(files['manifest.json'])
    manifest['wrapper_sha256'] = digest(Path(__file__).read_bytes())
    manifest['reused_variants'] = []
    definition = 'caelum/data/inventory_water.modeldef'
    for item in config['reused_variants']:
        for name, checksum in item['source_sha256'].items():
            if digest((ROOT / name).read_bytes()) != checksum:
                raise ValueError('Existing canteen source changed: ' + name)
        lines = (ROOT / item['obj']).read_text(encoding='utf-8').splitlines()
        points = [tuple(map(float, line.split()[1:])) for line in lines if line.startswith('v ')]
        bottom = min(point[1] for point in points)
        height = max(point[1] for point in points) - bottom
        alpha = Image.open(ROOT / item['icon']).convert('RGBA').getchannel('A')
        bounds = alpha.point(lambda value: 255 if value >= 128 else 0).getbbox()
        target_height = bounds[3] - bounds[1]
        factor = target_height / height
        normalized = []
        for line in lines:
            if line.startswith('v '):
                x, y, z = map(float, line.split()[1:])
                line = f'v {x*factor:.6f} {(y-bottom)*factor:.6f} {z*factor:.6f}'
            normalized.append(line)
        name = item['key'] + '.obj'
        files[config['model_path'] + '/' + name] = ('\n'.join(normalized) + '\n').encode()
        files[definition] += (f'Model {item["class"]} {{ Path "{config["model_path"]}" Model 0 "{name}" Scale 1 1 1 CorrectPixelStretch DontCullBackFaces FrameIndex {item["sprite"]} A 0 0 }}\n').encode()
        manifest['reused_variants'].append({**item, 'vertices': len(points),
            'faces': sum(line.startswith('f ') for line in lines), 'normalization_scale': factor,
            'source_floor_art_pixels': bottom, 'source_opaque_bounds': bounds,
            'model_height_art_pixels': target_height,
            'topology_uv_texture_unchanged': True})
    manifest['sha256'] = {name: digest(blob) for name, blob in files.items() if name != 'manifest.json'}
    files['manifest.json'] = (json.dumps(manifest, indent=2) + '\n').encode()
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--install', action='store_true')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    files = water_files()
    for name, blob in files.items():
        paths = [args.output / name]
        if args.install and not name.startswith('editable/'):
            paths.append(SOURCE / 'EXPORT.json' if name == 'manifest.json' else ROOT / 'src' / name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes() != blob:
                    raise ValueError('Stale water export: ' + str(path))
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output / 'preview.pk3', 'w') as package:
            for name, blob in sorted(files.items()):
                if name == 'manifest.json' or name.startswith('editable/'):
                    continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name, (2026, 11, 13, 0, 0, 0)), blob)
    report = json.loads(files['manifest.json'])
    print(json.dumps({'new_meshes': {key: item['triangles'] for key, item in report['variants'].items()},
                      'reused_meshes': [item['key'] for item in report['reused_variants']]}))


if __name__ == '__main__':
    main()
