"""Freeze the #249 runtime and deterministic Summoning fixture."""
from pathlib import Path
import argparse, importlib.util, json, struct
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
text='namespace="ZDoom";\n'
for x,y in [(-4096,-4096),(-4096,4096),(4096,4096),(4096,-4096),(512,-128),(640,-128),(640,128),(512,128)]:
    text+=f'vertex {{ x={x}; y={y}; }}\n'
text+='sector { heightfloor=0; heightceiling=256; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }\n'
for i in range(8):
    end=(i+1)%4 if i<4 else 4+(i+1-4)%4
    text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
    text+=f'linedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }\n'
def make_wad(source):
    data=b'';directory=b''
    for name,payload in [('MAP99',b''),('TEXTMAP',source.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
wad=make_wad(text)
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'summoning.pk3',{'ZSCRIPT':b'version "4.14"\n#include "summoning.zs"\n','summoning.zs':(HERE/'summoning.zs').read_bytes(),'maps/MAP99.wad':wad,'maps/MAP98.wad':wad,'maps/MAP97.wad':make_wad(text.replace('heightceiling=256','heightceiling=80')),'MAPINFO':b'GameInfo { AddEventHandlers="CA249Probe" }\ncluster 99 { hub }\nmap MAP99 "Summoning fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Summoning hub" { cluster=99 sky1="SKY1",0 }\nmap MAP97 "Summoning low ceiling" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c249_setup; wait 5; '
done='netevent c249_done; wait 2; quit\n'
scripts={
'flight.cfg':setup+'netevent c249_contract; wait 2; netevent c249_flight; wait 50; netevent c249_flight_check; '+done,
'save-prep.cfg':setup+'+user4; wait 35; -user4; netevent c249_partial; save preparation.zds; wait 2; '+done,
'load-prep.cfg':'wait 1; netevent c249_prep_loaded; wait 90; netevent c249_loaded_cast; '+done,
'journey.cfg':setup+'netevent c249_contract; wait 2; netevent c249_journey; '+done,
'pending.cfg':setup+'netevent c249_contract; wait 2; netevent c249_seed; changemap MAP97; wait 40; netevent c249_pending; netevent c249_loaded; save pending.zds; wait 2; '+done,
'pending-load.cfg':'wait 1; netevent c249_pending; netevent c249_loaded; changemap MAP98; wait 10; netevent c249_placed; netevent c249_loaded; changemap MAP97; wait 400; netevent c249_expired; '+done,
'failure.cfg':setup+'+user4; wait 110; -user4; netevent c249_failure; '+done,
'death.cfg':setup+'netevent c249_contract; wait 2; netevent c249_kill_caster; wait 2; netevent c249_expired; '+done,
'placement.cfg':setup+'netevent c249_placement; '+done,
'combat.cfg':setup+'netevent c249_contract; wait 2; netevent c249_follow; wait 175; netevent c249_combat; wait 280; netevent c249_combat_check; netevent c249_damage; wait 2; netevent c249_damage_check; '+done,
'contract.cfg':setup+'netevent c249_contract; wait 2; netevent c249_profile; wait 2; netevent c249_powered; netevent c249_friendly; '+done,
'casting.cfg':setup+'+user4; wait 35; -user4; netevent c249_partial; wait 2; +user4; wait 2; -user4; netevent c249_cancel; netevent c249_setup; wait 5; +user4; wait 110; -user4; netevent c249_cast; wait 350; netevent c249_expired; '+done,
'save.cfg':setup+'netevent c249_contract; wait 2; netevent c249_seed; wait 10; save summon.zds; wait 2; '+done,
'load.cfg':'wait 1; netevent c249_loaded; changemap MAP98; wait 10; netevent c249_loaded; changemap MAP99; wait 10; netevent c249_loaded; wait 350; netevent c249_expired; '+done}
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c249_manual"; bind f7 "netevent c249_ready"; bind f8 "netevent c249_manual_enemies"; bind f9 "netevent c249_transfer; wait 2; changemap MAP98"; bind f10 "netevent c249_long_journey"; wait 100; netevent c249_manual; wait 10; '
scripts['manual.cfg']=manual+'netevent c249_done;\n'
scripts['preview.cfg']=manual+'screenshot inactive.png; +user4; wait 110; -user4; netevent c249_cast; netevent c249_manual_enemies; netevent c249_look; wait 80; screenshot active.png; '+done
for name,text in scripts.items():(out/name).write_bytes(text.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
