"""Install a reviewed compiled Barracas map and verify its packaged sources.

Generate the compiled directory with generate_barracas_map.py first. This installs
owned geometry/facades only; the existing Justice generator appends its arena.
The project validator uses validate() read-only, without compiling geometry.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
DIRECTORY = 'assets/barracas_redesign/'
MANIFEST = DIRECTORY + 'INSTALLATION.json'
BASE = DIRECTORY + 'BASE_MAP03.wad'
MODEL = 'src/models/caelum/architecture/barracas/house-960-1216.obj'
INCLUDES = {
    'src/ZSCRIPT': '#include "caelum/world/CaelumBarracasFacades.zs"',
    'src/MAPINFO': 'include "caelum/data/barracas_facades.mapinfo"',
    'src/MODELDEF': '#include "caelum/data/barracas_facades.modeldef"',
}


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def sources(root):
    names = {DIRECTORY + name + '.json' for name in
             ('LAYOUT', 'RUNTIME', 'SIEGE', 'RAM_CREWS', 'FRONTS', 'MARCH', 'DEPLOYMENT', 'RETREAT')}
    for name in list(names):
        names.update(json.loads((root / name).read_text(encoding='utf-8')).get('source_sha256', {}))
    names.update(p.relative_to(root).as_posix() for p in (root / 'assets/generators').glob('generate_barracas_*.py'))
    names.add('assets/generators/install_barracas_map.py')
    names.add('assets/generators/generate_cartography_catalogue.py')
    names.add('generate_battle_routes.py')
    names.update('assets/generators/' + name + '.py' for name in
                 ('generate_coastal_trials', 'compact_open_geometry', 'generate_city_ceilings',
                  'generate_shop_catalogue', 'generate_port_city', 'generate_environment_models'))
    # Text inputs use canonical LF hashes across Git's native checkout endings.
    # Installed WAD/model/runtime assets retain exact byte hashes below.
    return {name: digest((root / name).read_bytes().replace(b'\r\n', b'\n')) for name in sorted(names)}


def validate(root):
    errors = []
    try:
        layout = json.loads((root / (DIRECTORY + 'LAYOUT.json')).read_text(encoding='utf-8'))
        maps = json.loads((root / 'assets/tarot_justice/MAPS.json').read_text(encoding='utf-8'))
        row = next(row for row in maps['maps'] if row['file'] == 'MAP03.wad')
        if not layout['runtime_enabled']:
            if row.get('source_override') == BASE:
                errors.append('Barracas activation flag disagrees with the packaged MAP03 source.')
            return errors
        manifest = json.loads((root / MANIFEST).read_text(encoding='utf-8'))
        if manifest.get('source_hash_mode') != 'text_canonical_lf':
            errors.append('Barracas source hash mode is stale; reinstall the reviewed map.')
        if manifest['source_sha256'] != sources(root):
            errors.append('Barracas installation inputs changed; regenerate and reinstall the reviewed map.')
        for name, expected in manifest['files_sha256'].items():
            if digest((root / name).read_bytes()) != expected:
                errors.append('Stale installed Barracas asset: ' + name)
        for name, line in INCLUDES.items():
            if (root / name).read_text(encoding='utf-8-sig').splitlines().count(line) != 1:
                errors.append('Barracas binding must appear exactly once: ' + name)
        if row.get('source_override') != BASE or row.get('source_sha256') != manifest['files_sha256'][BASE]:
            errors.append('Justice MAP03 source does not match the installed Barracas base.')
    except (OSError, ValueError, KeyError, StopIteration) as error:
        errors.append('Barracas installation: ' + str(error))
    return errors


def install(compiled):
    compiled = compiled.resolve(strict=True)
    compiled.relative_to(ROOT / 'build')
    if not json.loads((ROOT / (DIRECTORY + 'LAYOUT.json')).read_text())['runtime_enabled']:
        raise ValueError('LAYOUT.json has not enabled the approved map.')
    previous = json.loads((ROOT / MANIFEST).read_text()) if (ROOT / MANIFEST).exists() else None
    with zipfile.ZipFile(compiled / 'preview.pk3') as archive:
        expected = {'ZSCRIPT', 'MAPINFO', 'MODELDEF', 'maps/MAP03.wad', 'models/house-960-1216.obj'}
        if set(archive.namelist()) != expected:
            raise ValueError('The compiled map has changed its asset contract; review installation bindings.')
        base = archive.read('maps/MAP03.wad')
        if b'user_ca_tarot_justice' in base:
            raise ValueError('Install the base geometry before appending the Justice arena.')
        code = archive.read('ZSCRIPT').decode('utf-8')
        if not code.startswith('version "4.14.2"\n'):
            raise ValueError('Unexpected facade language version.')
        assets = {
            BASE: base,
            'src/caelum/world/CaelumBarracasFacades.zs': code.split('\n', 1)[1].encode('utf-8') + b'\n',
            'src/caelum/data/barracas_facades.mapinfo': archive.read('MAPINFO'),
            'src/caelum/data/barracas_facades.modeldef': archive.read('MODELDEF').replace(
                b'Path "models"', b'Path "models/caelum/architecture/barracas"') + b'\n',
            MODEL: archive.read('models/house-960-1216.obj'),
        }
    for name in assets:
        path = ROOT / name
        if path.exists() and (previous is None or digest(path.read_bytes()) != previous['files_sha256'].get(name)):
            raise ValueError('Preserve and review unrelated edits before installing: ' + name)
    for name, blob in assets.items():
        path = ROOT / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(blob)
    maps_path = ROOT / 'assets/tarot_justice/MAPS.json'
    maps = json.loads(maps_path.read_text(encoding='utf-8'))
    row = next(row for row in maps['maps'] if row['file'] == 'MAP03.wad')
    row.update(source_override=BASE, source_sha256=digest(base))
    maps_path.write_text(json.dumps(maps, indent=2) + '\n', encoding='utf-8', newline='\n')
    subprocess.run([sys.executable, str(ROOT / 'assets/generators/generate_tarot_justice.py')], cwd=ROOT, check=True)
    subprocess.run([sys.executable, str(ROOT / 'assets/generators/generate_cartography_catalogue.py')], cwd=ROOT, check=True)
    subprocess.run([sys.executable, str(ROOT / 'generate_battle_routes.py')], cwd=ROOT, check=True)
    assets['src/maps/MAP03.wad'] = (ROOT / 'src/maps/MAP03.wad').read_bytes()
    manifest = {'issue': 454, 'geometry_revision': 4,
                'source_hash_mode': 'text_canonical_lf',
                'source_sha256': sources(ROOT),
                'files_sha256': {name: digest(blob) for name, blob in sorted(assets.items())},
                'compatibility': 'Use LegacyMap03Revision3 for existing active/stored-hub original-city saves. Preserve original saves.',
                'acceptance': 'Packaging and native evidence do not imply author acceptance or siege fluency.'}
    (ROOT / MANIFEST).write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8', newline='\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiled', type=Path, help='Generated base-map directory under build/')
    args = parser.parse_args()
    if args.compiled:
        install(args.compiled)
    errors = validate(ROOT)
    print(json.dumps({'issue': 454, 'installed': bool(args.compiled), 'errors': errors}))
    raise SystemExit(bool(errors))


if __name__ == '__main__':
    main()
