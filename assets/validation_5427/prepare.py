"""Freeze normal escort movement and a genuine previous-version save control."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):
        parser.error('A plain directory name is required.')
    spec = importlib.util.spec_from_file_location('seal_fixture', HERE.parent / 'validation_5421/prepare.py')
    shared = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(shared)
    out = ROOT / 'build' / args.directory
    out.mkdir(exist_ok=False)
    old = out.with_name(out.name + '-legacy')
    old.mkdir(exist_ok=False)
    previous = ROOT / 'build/issue305-02/production.pk3'
    assert hashlib.sha256(previous.read_bytes()).hexdigest() == '7c27a0f1d81ed0b146bd04b3d759f9028d76e3ab5ad9f4660d51c5d592255a85'
    manifest = {'runtime_sha256': shared.shared.package(out / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes() for p in (ROOT / 'src').rglob('*') if p.is_file()})}
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "escort.zs"\n',
        'escort.zs': (HERE / 'escort.zs').read_bytes(),
        'maps/MAP99.wad': shared.wad(), 'maps/MAP98.wad': shared.wad(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA307Probe" }\ncluster 99 { hub }\nmap MAP99 "Escort fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Escort hub" { cluster=99 nointermission sky1="SKY1",0 }\n'
    }
    manifest['fixture_sha256'] = shared.shared.package(out / 'escort.pk3', members)
    shutil.copyfile(previous, old / 'production.pk3')
    shutil.copyfile(out / 'escort.pk3', old / 'escort.pk3')
    start = 'wait 100; netevent c307_setup; '
    done = 'netevent c307_done; wait 35; quit\n'
    scripts = {
        'motion.cfg': start + 'netevent c307_motion; wait 6100; ' + done,
        'baseline.cfg': start + 'netevent c307_baseline; wait 800; ' + done,
        'combined.cfg': start + 'netevent c307_combined; wait 800; ' + done,
        'walking.cfg': start + 'netevent c307_walkseed; wait 5; netevent c307_walkstart; wait 40; netevent c307_walkrecord; wait 5; netevent c307_followstart; wait 40; netevent c307_followrecord; ' + done,
        'contracts.cfg': start + 'netevent c307_contracts; wait 5; netevent c307_contractcheck; wait 100; netevent c307_wallcheck; ' + done,
        'seed.cfg': start + 'netevent c307_seed; wait 5; netevent c307_activate; storesavepic false; save escort.zds; wait 5; ' + done,
        'load.cfg': 'wait 5; netevent c307_loaded; storesavepic false; save repeated.zds; wait 5; ' + done,
        'repeat.cfg': 'wait 5; netevent c307_loaded; ' + done,
        'migration.cfg': 'wait 5; netevent c307_loaded; storesavepic false; save migrated.zds; wait 5; ' + done,
        'travel.cfg': 'wait 5; netevent c307_loaded; changemap MAP98; wait 20; changemap MAP99; wait 5; netevent c307_loaded; ' + done,
    }
    for folder in (out, old):
        for name, content in scripts.items():
            (folder / name).write_text(content, encoding='utf-8', newline='\n')
    manifest['legacy_runtime_sha256'] = hashlib.sha256(previous.read_bytes()).hexdigest()
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(manifest))


if __name__ == '__main__':
    main()
