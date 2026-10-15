"""Freeze #282 runtime and native inventory-command fixtures."""
from pathlib import Path
import argparse
import importlib.util
import json
import hashlib
import shutil

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('seal',HERE.parent/'validation_5421/prepare.py')
seal=importlib.util.module_from_spec(spec);spec.loader.exec_module(seal)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    p.add_argument('--legacy-runtime',type=Path,help='Frozen accepted 5.4.21 PK3 for a genuine previous-runtime save.')
    a=p.parse_args()
    if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    manifest={'runtime_sha256':seal.shared.package(out/'production.pk3',{
        q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()}),
        'fixture_sha256':seal.shared.package(out/'quick.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n','probe.zs':(HERE/'probe.zs').read_bytes(),
            'maps/MAP99.wad':seal.wad(),'maps/MAP98.wad':seal.wad(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA282Probe" }\ncluster 99 { hub }\nmap MAP99 "Quick-use fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Quick-use hub" { cluster=99 nointermission sky1="SKY1",0 }\n'})}
    start='wait 100; netevent c282_setup; wait 35; '
    done='netevent c282_done; wait 35; quit\n'
    scripts={'probe.cfg':start+'netevent c282_checks; '+done,
             'input.cfg':start+'netevent c282_input; wait 35; invnext; wait 35; netevent c282_next; wait 35; invprev; wait 35; netevent c282_prev; wait 35; invuse; wait 35; netevent c282_used; wait 35; netevent c282_single; wait 35; invnext; wait 5; invprev; wait 5; netevent c282_single_check; wait 5; invuse; wait 5; invuse; wait 5; invuse; wait 5; invnext; invprev; wait 5; netevent c282_empty_check; '+done,
             'transfers.cfg':start+'netevent c282_transfers; '+done,
             'preview.cfg':start+'netevent c282_input; bind f6 invprev; bind f7 invnext; bind f8 invuse; con_notifytime 0; wait 35; screenshot quick-hud.png; wait 35; '+done,
             'save.cfg':start+'netevent c282_input; wait 35; save quick.zds; wait 35; '+done,
             'load.cfg':'wait 35; netevent c282_loaded; '+done,
             'travel.cfg':'wait 35; changemap MAP98; wait 35; netevent c282_loaded; wait 35; changemap MAP99; wait 35; netevent c282_loaded; wait 35; '+done,
             'legacy-load.cfg':'wait 35; netevent c282_legacy; '+done,
             'water.cfg':start+'netevent c282_manual; wait 35; invprev; wait 10; invprev; wait 10; screenshot quick-water.png; wait 35; '+done,
             'unbound.cfg':start+'netevent c282_input; unbindall; wait 35; screenshot quick-unbound.png; wait 35; '+done,
             'manual.cfg':start+'language es; use_mouse true; bind f6 invprev; bind f7 invnext; bind f8 invuse; con_notifytime 0; netevent c282_manual; netevent c282_done;\n'}
    for name,code in scripts.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    # GZDoom requires the old map-containing archive basename on save load.
    (out/'migration').mkdir()
    shutil.copyfile(out/'quick.pk3',out/'migration/legacy.pk3')
    if a.legacy_runtime:
        shutil.copyfile(a.legacy_runtime,out/'legacy-runtime.pk3')
        manifest['legacy_runtime_sha256']=hashlib.sha256((out/'legacy-runtime.pk3').read_bytes()).hexdigest()
        manifest['legacy_fixture_sha256']=seal.shared.package(out/'legacy.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n','probe.zs':(HERE/'legacy.zs').read_bytes(),
            'maps/MAP99.wad':seal.wad(),'maps/MAP98.wad':seal.wad(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA282Probe" }\ncluster 99 { hub }\nmap MAP99 "Quick-use fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Quick-use hub" { cluster=99 nointermission sky1="SKY1",0 }\n'})
        (out/'legacy-save.cfg').write_text('wait 100; netevent c282_seed; wait 35; save legacy.zds; wait 35; netevent c282_done; wait 35; quit\n',encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
