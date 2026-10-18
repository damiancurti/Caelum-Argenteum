"""Freeze issue #320 attack tests and an optional pre-change runtime."""
from pathlib import Path
import argparse
import importlib.util
import io
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('quick', HERE.parent/'validation_5422/prepare.py')
quick = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quick)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--ref', help='Read the baseline src tree from this Git revision.')
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Plain lowercase directory required.')
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    package = quick.seal.shared.package
    if args.ref:
        raw = subprocess.check_output(['git', 'archive', '--format=zip', args.ref, 'src'], cwd=ROOT)
        with zipfile.ZipFile(io.BytesIO(raw)) as archive:
            members = {n[4:]: archive.read(n) for n in archive.namelist() if not n.endswith('/')}
    else:
        members = {f.relative_to(ROOT/'src').as_posix(): f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}
    manifest = {'runtime_sha256': package(out/'production.pk3', members),
        'fixture_sha256': package(out/'quick.pk3', {
            'ZSCRIPT': b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n',
            'quick.zs': (HERE.parent/'validation_5422/probe.zs').read_bytes(),
            'probe.zs': (HERE/'probe.zs').read_bytes(),
            'maps/MAP99.wad': quick.seal.wad(),
            'CVARINFO': b'server bool ca320_baseline = false;\n',
            'MAPINFO': b'GameInfo { AddEventHandlers="CA320Probe" }\nmap MAP99 "Projectile aim fixture" { nointermission sky1="SKY1",0 }\n'})}
    start = 'wait 100; netevent c282_setup; wait 35; '
    done = 'netevent c282_done; wait 10; quit\n'
    commands = {
        'matrix.cfg': start+f'ca320_baseline {str(bool(args.ref)).lower()}; netevent c320_matrix; wait 10; '+done,
        'native.cfg': start+'netevent c320_native; wait 700; netevent c320_native_done; wait 10; '+done,
        'dense.cfg': start+'netevent c320_dense; wait 700; netevent c320_native_done; wait 10; '+done,
        'save.cfg': start+'netevent c320_save; wait 5; storesavepic false; save aim.zds; wait 10; '+done,
        'load.cfg': 'wait 35; netevent c320_load; wait 10; '+done,
        'manual.cfg': start+'netevent c320_manual; wait 10; netevent c282_done;\n'}
    for name, code in commands.items():
        (out/name).write_text(code, encoding='utf-8', newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(manifest))

if __name__ == '__main__':
    main()
