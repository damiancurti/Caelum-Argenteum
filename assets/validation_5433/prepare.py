"""Freeze focused #323 geometry, walking and persistence fixtures."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('quick',HERE.parent/'validation_5422/prepare.py')
quick=importlib.util.module_from_spec(spec);spec.loader.exec_module(quick)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--baseline-runtime',type=Path)
    args=parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):parser.error('Plain lowercase directory required.')
    out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
    source=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text())
    traps=[t for t in source['traps'] if t['type']=='crusher']
    code=['class CA323Data : Object {',f'const COUNT={len(traps)};',f'const AREA={(source["layout"]["crusher_panel_half_width"]*2/32)**2};',f'const CEILING={source["layout"]["ceiling"]};','const WEST_TID=43921;','static int Tid(int n){switch(n){']
    for n,t in enumerate(traps):code.append(f'case {n}:return {t["tid"]};')
    code+=['}return 0;}','}']
    package=quick.seal.shared.package
    if args.baseline_runtime:
        shutil.copyfile(args.baseline_runtime,out/'production.pk3')
        runtime=hashlib.sha256((out/'production.pk3').read_bytes()).hexdigest()
    else:
        runtime=package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    manifest={'runtime_sha256':runtime,'fixture_sha256':package(out/'quick.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "data.zs"\n#include "probe.zs"\n',
        'quick.zs':(HERE.parent/'validation_5422/probe.zs').read_bytes(),
        'data.zs':'\n'.join(code).encode(),'probe.zs':(HERE/'probe.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA323Probe" }\n',
        'CVARINFO':b'server bool ca323_baseline=false;\n'})}
    start=f'wait 70; ca323_baseline {str(bool(args.baseline_runtime)).lower()}; netevent c282_setup; wait 3; netevent c323_setup; wait 3; '
    done='netevent c282_done; wait 5; quit\n'
    walk='netevent c323_place; wait 3; +forward; wait 350; -forward; wait 1; netevent c323_walk_check; wait 5; '
    commands={
        'geometry.cfg':start+'netevent c323_geometry; wait 5; '+done,
        'walk.cfg':start+walk+done,
        'all.cfg':start+''.join(f'netevent c323_release {n}; wait 8; netevent c323_moving; wait 100; netevent c323_finished; wait 1; ' for n in range(len(traps)))+done,
        'before.cfg':start+'netevent c323_place; wait 3; netevent c323_unspent; wait 1; storesavepic false; save before.zds; wait 5; '+done,
        'load-before.cfg':'wait 3; netevent c323_setup; wait 1; netevent c323_unspent; '+walk+done,
        'during.cfg':start+'netevent c323_release 3; wait 5; netevent c323_moving; wait 1; storesavepic false; save during.zds; wait 5; '+done,
        'load-during.cfg':'wait 1; netevent c323_resume; wait 2; netevent c323_moving; wait 100; netevent c323_finished; wait 1; '+done,
        'manual.cfg':start+'netevent c323_manual; wait 5; netevent c282_done;\n'}
    for name,script in commands.items():(out/name).write_text(script,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(manifest))

if __name__=='__main__':main()
