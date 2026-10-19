"""Freeze #311 inputs, reusing accepted #194 tests without changing their assertions."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
OLD = HERE.parent / 'validation_5211'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as z:
        for name, data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--runtime', type=Path)
    args = parser.parse_args()
    if not args.directory.replace('-', '').replace('_', '').isalnum():
        parser.error('Use a single directory name.')
    out = ROOT / 'build' / args.directory
    out.mkdir(exist_ok=False)
    spec = importlib.util.spec_from_file_location('legacy_map', OLD / 'prepare.py')
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    if args.runtime:
        (out / 'production.pk3').write_bytes(args.runtime.read_bytes())
    else:
        package(out / 'production.pk3', {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
                for p in (ROOT / 'src').rglob('*') if p.is_file()})
    fixtures = {}
    for kind in ('energy', 'combat', 'player', 'motion', 'siege', 'contacts', 'multiple', 'dense', 'migration'):
        names = ['energy']
        if kind != 'energy': names += ['combat']
        if kind not in ('energy', 'combat', 'multiple', 'dense', 'migration'): names += [kind]
        if kind in ('multiple', 'dense'): names += ['motion']
        data = b'\n'.join((OLD / (n + '.zs')).read_bytes() for n in names)
        if kind == 'player':
            # #211 subsequently approved 150% of JumpZ for landing cushioning.
            data = data.replace(b'LastImpactCushionedJoules,360)', b'LastImpactCushionedJoules,160)')
            data = data.replace(b'LastImpactFinalDamage,253)', b'LastImpactFinalDamage,68)')
        handler = 'CA194' + kind.title()
        if kind in ('multiple', 'dense', 'migration'):
            data += b'\n' + (HERE / (kind + '.zs')).read_bytes()
            handler = 'CA311' + kind.title()
        player_class = ' PlayerClasses="CA311Player"' if kind == 'multiple' else ''
        package(out / (kind + '.pk3'), {'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
            'checks.zs': data, 'maps/MAPQA.wad': old.test_map(),
            'MAPINFO': f'GameInfo {{ AddEventHandlers="{handler}"{player_class} }}\n'.encode()})
        fixtures[kind + '.pk3'] = sha(out / (kind + '.pk3'))
    for kind in ('energy', 'combat', 'player', 'motion', 'siege', 'contacts', 'contacts_reload'):
        (out / (kind + '.cfg')).write_bytes((OLD / (kind + '.cfg')).read_bytes())
    scripts = {'multiple.cfg': 'wait 160; quit\n',
        'multi-save.cfg': 'wait 110; save ca311-contact; wait 5; quit\n',
        'multi-load.cfg': 'wait 60; save ca311-restored; wait 5; quit\n',
        'legacy-save.cfg': 'wait 46; netevent c311_checkpoint; storesavepic false; save ca311-legacy; wait 5; quit\n',
        'migration.cfg': 'wait 35; quit\n',
        'upgrade-save.cfg': 'wait 6; storesavepic false; save ca311-upgraded; wait 50; quit\n',
        'separation-save.cfg': 'wait 11; netevent c311_split_checkpoint; storesavepic false; save ca311-separated; wait 6; quit\n',
        'rollback.cfg': 'wait 2; netevent c311_rollback; wait 5; quit\n'}
    for name, data in scripts.items(): (out / name).write_text(data, encoding='utf-8')
    for population in (64, 512):
        for mode in (0, 1):
            (out / f'dense-{population}-{mode}.cfg').write_text(
                f'wait 100; netevent c311_dense {mode} {population}; wait 490; quit\n', encoding='utf-8')
    for mode in (0, 1):
        (out / f'grid-512-{mode}.cfg').write_text(
            f'wait 100; netevent c311_dense {mode} 512 1; wait 490; quit\n', encoding='utf-8')
    with zipfile.ZipFile(out / 'multiple.pk3') as z: preview = {n: z.read(n) for n in z.namelist()}
    preview['checks.zs'] += b'\n' + (HERE / 'preview.zs').read_bytes()
    preview['MAPINFO'] = b'GameInfo { AddEventHandlers="CA311Preview" }\n'
    package(out / 'preview.pk3', preview)
    fixtures['preview.pk3'] = sha(out / 'preview.pk3')
    (out / 'preview.cfg').write_text('wait 100; use_mouse true; language es; netevent c311_setup; '
        'bind f6 "netevent c311_demo 0"; bind f7 "netevent c311_demo 1"; bind f8 "netevent c311_demo 2"; '
        'bind f10 "map MAPQA; exec preview.cfg"; con_notifytime 0;\n', encoding='utf-8')
    (out / 'preview-smoke.cfg').write_text((out / 'preview.cfg').read_text(encoding='utf-8') + 'wait 50; netevent c311_demo 0; wait 70; '
        'netevent c311_demo 1; wait 70; netevent c311_demo 2; wait 80; screenshot preview-smoke.png; wait 5; quit\n', encoding='utf-8')
    manifest = {'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'runtime_sha256': sha(out / 'production.pk3'), 'fixtures': fixtures,
        'reused_sources': {p.name: sha(p) for p in OLD.glob('*.zs')},
        'script_hashes': {p.name: sha(p) for p in out.glob('*.cfg')}}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'directory': str(out), 'runtime_sha256': manifest['runtime_sha256']}))


if __name__ == '__main__': main()
