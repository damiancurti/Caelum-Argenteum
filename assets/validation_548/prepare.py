"""Freeze #240 runtime and native dialogue/input/persistence fixtures."""
from pathlib import Path
import argparse, importlib.util, json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room209',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'socialization.pk3',{'ZSCRIPT':b'version "4.14"\n#include "socialization.zs"\n','socialization.zs':(HERE/'socialization.zs').read_bytes(),'maps/MAP01.wad':room.room(),'maps/MAP99.wad':room.room(),'maps/MAP98.wad':room.room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA240Probe" }\ncluster 99 { hub }\nmap MAP01 "Socialization conversation fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP99 "Socialization fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Socialization hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='bind f +user1; wait 100; netevent c240_setup; wait 10; '
on='+user1; wait 35; -user1; wait 3; netevent c240_on; '
done='netevent c240_done; wait 2; quit\n'
scripts={
 'contract.cfg':setup+'netevent c240_contract; netevent c240_setup; '+on+'+user1; wait 3; -user1; netevent c240_off; '+done,
 'dialogue.cfg':setup+on+'netevent c240_open 1; wait 15; netevent c240_ronnie 2; wait 35; netevent c240_drain; event c240_stop; wait 8; netevent c240_off; netevent c240_ronnie 2; event c240_reply 0; wait 12; netevent c240_ronnie_won; event c240_close; wait 6; netevent c240_ronnie 1; '+done,
 'caella.cfg':setup+on+'netevent c240_open 2; wait 10; event c240_reply 0; wait 10; netevent c240_caella 100; netevent c240_low; wait 5; netevent c240_off; netevent c240_caella 100; event c240_reply 0; wait 10; netevent c240_caella_won; netevent c240_reroll; '+done,
 'save.cfg':setup+on+'netevent c240_open 1; wait 15; event c240_stop; wait 5; netevent c240_ronnie 2; save socialization.zds; wait 5; '+done,
 'load.cfg':'wait 35; netevent c240_loaded; netevent c240_ronnie 2; event c240_reply 0; wait 10; netevent c240_ronnie_won; '+done,
 'hub.cfg':setup+on+'changemap MAP98; wait 8; netevent c240_on; changemap MAP99; wait 8; netevent c240_on; '+done,
 'new-page.cfg':setup+on+'netevent c240_open 2; wait 10; event c240_stop; wait 5; netevent c240_off; netevent c240_caella 100; event c240_reply 0; wait 10; netevent c240_caella 83; '+done,
 'save-active.cfg':setup+on+'save active.zds; wait 5; '+done,
 'load-active.cfg':'wait 10; netevent c240_loaded_active; wait 35; netevent c240_payment; '+done,
 'return.cfg':'wait 20; netevent c240_return; '+done,
 'compile.cfg':'wait 60; '+done,
}
manual='language es; bind f +user1; bind f6 "event c240_manual 1"; bind f7 "event c240_manual 2"; bind f8 "netevent c240_low"; wait 100; event c240_manual 1; '
scripts['manual.cfg']=manual+'\n'
scripts['preview.cfg']=manual+'wait 25; screenshot socialization-ready.png; wait 3; quit\n'
for name,content in scripts.items():(out/name).write_bytes(content.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
