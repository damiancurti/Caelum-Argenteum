"""Freeze the #363 native User2 reproduction, regression and save fixtures."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('seal', HERE.parent/'validation_5421/prepare.py')
seal = importlib.util.module_from_spec(spec)
spec.loader.exec_module(seal)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--baseline', action='store_true')
    parser.add_argument('--runtime', type=Path)
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Use a plain lowercase directory name.')
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    sources = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes()
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    if args.runtime:
        with zipfile.ZipFile(args.runtime) as archive:
            sources = {n: archive.read(n) for n in archive.namelist()}
    package = seal.shared.package
    manifest = dict(source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                    source_hashes={n: hashlib.sha256(v).hexdigest() for n,v in sources.items()},
                    runtime_sha256=package(out/'production.pk3',sources))
    manifest['fixture_sha256'] = package(out/'quick.pk3', {
        'ZSCRIPT': b'version "4.14"\n#include "probe.zs"\n',
        'probe.zs': (HERE/'probe.zs').read_bytes(),
        'maps/MAP99.wad': seal.wad(), 'maps/MAP98.wad': seal.wad(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA363Probe" }\ncluster 99 { hub }\nmap MAP99 "Unarmed seal fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Seal hub fixture" { cluster=99 nointermission sky1="SKY1",0 }\n'})
    start = 'wait 100; netevent c363_setup; wait 70; '
    finish = 'netevent c363_done; wait 5; quit\n'
    scripts = {}
    for kind in (-1,0,1):
        expected = 0 if args.baseline and kind==-1 else 1
        scripts[f'input-{kind}.cfg'] = start+f'netevent c363_equip {kind}; wait 70; netevent c363_begin; '
        scripts[f'input-{kind}.cfg'] += f'+user2; wait 35; netevent c363_check {expected} 0; '
        if expected:
            scripts[f'input-{kind}.cfg'] += 'netevent c363_cost; wait 10; netevent c363_paid; '
        scripts[f'input-{kind}.cfg'] += f'-user2; wait 5; netevent c363_check {expected} 0; '
        scripts[f'input-{kind}.cfg'] += f'+user2; wait 5; -user2; netevent c363_check {expected} {expected}; '+finish
    for mode in (1,2):
        scripts[f'reject-{mode}.cfg']=start+f'netevent c363_begin {mode}; +user2; wait 35; -user2; netevent c363_check 0 0; '+finish
    scripts['exhaust.cfg']=start+'netevent c363_begin; +user2; wait 10; -user2; netevent c363_check 1 0; netevent c363_empty; wait 5; netevent c363_check 1 1; '+finish
    scripts['cooldown.cfg']=start+'netevent c363_begin; +user2; wait 10; -user2; wait 2; +user2; wait 2; -user2; wait 2; +user2; wait 5; -user2; netevent c363_cooldown; '+finish
    scripts['save.cfg']=start+'save unarmed.zds; wait 3; +attack; wait 6; save punch.zds; -attack; '+finish
    scripts['load.cfg']='wait 35; netevent c363_restored; netevent c363_begin; +user2; wait 10; -user2; netevent c363_check 1 0; '+finish
    scripts['rollback.cfg']='wait 35; netevent c363_restored; '+finish
    scripts['active-save.cfg']=start+'netevent c363_begin; +user2; wait 10; -user2; save channel.zds; netevent c363_check 1 0; '+finish
    scripts['active-load.cfg']='wait 1; netevent c363_restored; netevent c363_check 1 0; +user2; wait 5; -user2; netevent c363_check 1 1; '+finish
    scripts['hub.cfg']='wait 5; changemap MAP98; wait 35; netevent c363_restored 1; changemap MAP99; wait 35; netevent c363_restored 1; '+finish
    scripts['manual.cfg']=start+'netevent c363_manual; language es; use_mouse true; bind x +user2; bind f6 "netevent c363_equip -1"; bind f7 "netevent c363_equip 0"; bind f8 "netevent c363_equip 1"; bind f9 "netevent c363_begin 1"; bind f10 "netevent c363_begin 0"; con_notifytime 0; netevent c363_done;\n'
    for name,code in scripts.items():
        (out/name).write_text(code,encoding='utf-8',newline='\n')
    manifest['script_hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.glob('*.cfg'))}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k not in ('source_hashes','script_hashes')}))


if __name__ == '__main__':
    main()
