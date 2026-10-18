"""Reuse the accepted native quick-item fixture for isolated issue #319 checks."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('quick', HERE.parent/'validation_5422/prepare.py')
quick = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quick)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Plain lowercase directory name required')
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    package = quick.seal.shared.package
    manifest = {'runtime_sha256': package(out/'production.pk3', {
        p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}),
        'fixture_sha256': package(out/'quick.pk3', {
            'ZSCRIPT': b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n',
            'quick.zs': (HERE.parent/'validation_5422/probe.zs').read_bytes(),
            'probe.zs': (HERE/'probe.zs').read_bytes(),
            'maps/MAP99.wad': quick.seal.wad(), 'maps/MAP98.wad': quick.seal.wad(),
            'MAPINFO': b'GameInfo { AddEventHandlers="CA319Probe" }\ncluster 99 { hub }\nmap MAP99 "Sleeping bag test" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Bag hub test" { cluster=99 nointermission sky1="SKY1",0 }\n'})}
    start = 'wait 100; netevent c319_seed; wait 35; '
    done = 'netevent c282_done; wait 35; quit\n'
    scripts = {
        'input.cfg': start+'invnext; wait 35; netevent c319_next; wait 35; invprev; wait 35; netevent c319_prev; wait 35; screenshot quick-bag.png; netevent c319_open; wait 35; invuse; wait 35; invuse; wait 35; netevent c319_opened; wait 35; screenshot quick-dialogue.png; netevent c319_close; wait 35; netevent c319_storage; netevent c319_block; wait 35; netevent c319_rest; wait 35; netevent c319_drop; '+done,
        'save.cfg': start+'storesavepic false; save bag.zds; wait 35; netevent c319_identity; '+done,
        'load.cfg': 'wait 35; netevent c319_identity; changemap MAP98; wait 70; netevent c319_identity; changemap MAP99; wait 70; netevent c319_identity; '+done,
        'manual.cfg': 'wait 100; language es; use_mouse true; bind f6 invprev; bind f7 invnext; bind f8 invuse; con_notifytime 0; netevent c319_manual; netevent c282_done;\n'}
    for name, commands in scripts.items():
        (out/name).write_text(commands, encoding='utf-8', newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(manifest))

if __name__ == '__main__':
    main()

