"""Freeze the #244 runtime and deterministic isolated native fixtures."""
from pathlib import Path
import argparse,importlib.util,json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'instinct.pk3',{'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "instinct.zs"\n','equipment.zs':(HERE.parent/'validation_541/session.zs').read_text(encoding='utf-8').replace('    int Kind()','    virtual int Kind()').encode(),'instinct.zs':(HERE/'instinct.zs').read_bytes(),'maps/MAP99.wad':room.room(),'maps/MAP98.wad':room.room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA244Probe" }\ncluster 99 { hub }\nmap MAP99 "Survival Instinct fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Instinct hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c244_setup; wait 5; '
done='netevent c244_done; wait 2; quit\n'
scripts={'contract.cfg':setup+'netevent c244_contract; '+done,
'casting.cfg':setup+'+user4; wait 35; -user4; netevent c244_partial; wait 2; +user4; wait 2; -user4; netevent c244_cancel; netevent c244_setup; wait 5; +user4; wait 110; -user4; netevent c244_release; '+done,
'save.cfg':setup+'netevent c244_save; save instinct.zds; wait 5; '+done,
'load.cfg':'wait 10; netevent c244_loaded; wait 35; netevent c244_clock; changemap MAP98; wait 10; netevent c244_hub; changemap MAP99; wait 10; netevent c244_hub; wait 350; netevent c244_expired; netevent c244_dead; '+done,
'save_prep.cfg':setup+'+user4; wait 35; -user4; netevent c244_partial; save preparing.zds; wait 2; '+done,
'load_prep.cfg':'wait 75; netevent c244_release; '+done}
steps=setup
for weapon in [0,1,2,3,5,6,7,8,9]:
 count=12 if weapon in [3,6] else 1;attack='altattack' if weapon==9 else 'attack'
 steps+=f'netevent c244_arm {weapon}; wait 80; '
 for state in ['', 'netevent c244_on; ', 'netevent c244_off; ']:
  steps+=state+f'+{attack}; wait 2; -{attack}; wait 90; netevent c244_shots {count}; '
scripts['weapons.cfg']=steps+done
scripts['combinations.cfg']=setup+'netevent c244_combinations; '+done
scripts['damage.cfg']=setup+'netevent c244_damage; '+done
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c244_manual"; bind f7 "netevent c244_gain"; bind f8 "netevent c244_weapon"; bind f9 "netevent c244_hit"; wait 100; netevent c244_manual; wait 80; '
scripts['manual.cfg']=manual+'netevent c244_done;\n'
scripts['preview.cfg']=manual+'screenshot inactive.png; +user4; wait 115; -user4; netevent c244_manual_check; wait 2; screenshot active.png; netevent c244_weapon; wait 80; netevent c244_manual_check; wait 2; screenshot active-carbine.png; wait 300; netevent c244_expired; '+done
for name,text in scripts.items():(out/name).write_bytes(text.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
