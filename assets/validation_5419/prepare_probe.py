"""Freeze an isolated native API probe before Redemption gameplay integration."""
from pathlib import Path
import argparse,importlib.util,json,shutil,zipfile,hashlib
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True);p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--maps',type=Path,required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False);shutil.copyfile(a.runtime,out/'production.pk3')
with zipfile.ZipFile(a.maps) as z:entries={'maps/MAP99.wad':z.read('maps/MAP99.wad')}
entries.update({'ZSCRIPT':b'version "4.14"\n#include "resurrection_probe.zs"\n',
    'resurrection_probe.zs':(HERE/'resurrection_probe.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA250ResurrectionProbe" }\nmap MAP99 "Native resurrection API probe" { sky1="SKY1",0 }\n'})
manifest={'runtime_sha256':hashlib.sha256(a.runtime.read_bytes()).hexdigest(),
    'fixture_sha256':room.package(out/'redemption.pk3',entries),
    'reused_map_fixture_sha256':hashlib.sha256(a.maps.read_bytes()).hexdigest(),
    'scope':'Native API feasibility only; runtime_sha256 identifies the tested build. Not full Redemption gameplay acceptance.'}
(out/'probe.cfg').write_bytes(b'wait 100; netevent c250_setup; wait 2; netevent c250_kill_npc; wait 40; netevent c250_raise_npc; wait 2; netevent c250_kill_player; wait 40; netevent c250_raise_player; wait 5; netevent c250_done; wait 2; quit\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
