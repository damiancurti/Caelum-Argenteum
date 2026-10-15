"""Freeze #239 production and focused critical/noise/input fixtures."""
from pathlib import Path
import argparse,importlib.util,json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room209',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'hunter.pk3',{'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "hunter.zs"\n','equipment.zs':(HERE.parent/'validation_541/session.zs').read_text(encoding='utf-8').replace('    int Kind()','    virtual int Kind()').encode(),'hunter.zs':(HERE/'hunter.zs').read_bytes(),'maps/MAP99.wad':room.room(),'maps/MAP98.wad':room.room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA239Probe" }\ncluster 99 { hub }\nmap MAP99 "Hunter fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Hunter hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c239_setup; wait 5; '
on='+user1; wait 35; -user1; wait 3; netevent c239_on; '
done='netevent c239_done; wait 2; quit\n'
scripts={
 'contract.cfg':setup+'netevent c239_contract; netevent c239_setup; wait 2; '+on+'+user1; wait 3; -user1; netevent c239_off; '+done,
 'damage.cfg':setup+'netevent c239_damage; '+done,
 'melee.cfg':setup+'netevent c239_melee; '+done,
 'noise.cfg':setup+'+forward; wait 20; -forward; wait 2; netevent c239_noise 0; '+on+'+forward; wait 20; -forward; wait 2; netevent c239_noise 1; '+done,
 'save.cfg':setup+on+'netevent c239_save_shot; wait 2; save hunter.zds; wait 5; '+done,
 'load.cfg':'wait 10; netevent c239_loaded; wait 35; netevent c239_payment; netevent c239_load_shot; '+done,
 'hub.cfg':setup+on+'changemap MAP98; wait 8; netevent c239_on; changemap MAP99; wait 8; netevent c239_on; '+done,
 'return.cfg':'wait 20; netevent c239_return; '+done,
}
steps=setup+on
for weapon in [0,1,2,3,5,6,7,8,9]:
    count=12 if weapon in [3,6] else 1;attack='altattack' if weapon==9 else 'attack'
    steps+=f'netevent c239_equipment {weapon}; wait 80; +{attack}; wait 2; -{attack}; wait 90; netevent c239_shots {count}; '
scripts['weapons.cfg']=steps+done
manual='language es; bind f +user1; bind f6 "netevent c239_turn"; bind f7 "netevent c239_weapon"; bind f8 "netevent c239_low"; bind f9 "netevent c239_manual"; con_notifytime 0; wait 100; netevent c239_manual; wait 80; '
scripts['manual.cfg']=manual+'\n'
scripts['preview.cfg']=manual+'+user1; wait 3; -user1; +attack; wait 2; -attack; wait 350; netevent c239_manual_check; screenshot hunter-ready.png; wait 3; '+done
scripts['preview_carbine.cfg']=manual+'netevent c239_weapon; wait 80; +user1; wait 3; -user1; +attack; wait 2; -attack; wait 10; +user1; wait 2; -user1; wait 120; netevent c239_off; netevent c239_manual_check; screenshot hunter-carbine.png; wait 3; '+done
for name,content in scripts.items():(out/name).write_bytes(content.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
