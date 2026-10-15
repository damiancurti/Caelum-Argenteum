"""Freeze #246 and build a deterministic, tall isolated projectile arena."""
from pathlib import Path
import argparse,importlib.util,json,struct
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
text='namespace="ZDoom";\n'
for x,y in [(-16384,-16384),(-16384,16384),(16384,16384),(16384,-16384),(512,-128),(640,-128),(640,128),(512,128)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
text+='sector { heightfloor=0; heightceiling=4096; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }\n'
for i in range(8):
 end=(i+1)%4 if i<4 else 4+(i+1-4)%4
 text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
 text+=f'linedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
text+='thing { x=0; y=1000; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }\n'
data=b'';directory=b''
for name,payload in [('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
 directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
wad=struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'sun.pk3',{'ZSCRIPT':b'version "4.14"\n#include "sun.zs"\n','sun.zs':(HERE/'sun.zs').read_bytes(),'maps/MAP99.wad':wad,'maps/MAP98.wad':wad,'MAPINFO':b'GameInfo { AddEventHandlers="CA246Probe" }\ncluster 99 { hub }\nmap MAP99 "Arcane Sun fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Arcane Sun hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c246_setup; wait 5; '
done='wait 35; netevent c246_done; wait 35; quit\n'
scripts={
'contract.cfg':setup+'netevent c246_contract; '+done,
'explosion.cfg':setup+'netevent c246_explosion; '+done,
'contact.cfg':setup+'netevent c246_contact; wait 25; netevent c246_passed; wait 15; netevent c246_returned; '+done,
'guided.cfg':setup+'netevent c246_guided; wait 1; netevent c246_turn; wait 1; netevent c246_retarget; wait 3; netevent c246_dead; '+done,
'range.cfg':setup+'netevent c246_range; wait 159; netevent c246_range_before; wait 2; netevent c246_range_after; '+done,
'burn.cfg':setup+'netevent c246_burn; wait 35; netevent c246_burning; wait 105; netevent c246_burn_end; wait 35; netevent c246_burn_stopped; '+done,
'nearwall.cfg':setup+'netevent c246_nearwall; wait 3; netevent c246_finished; '+done,
'casting.cfg':setup+'+user4; wait 35; -user4; netevent c246_partial; wait 2; +user4; wait 2; -user4; netevent c246_cancel; netevent c246_setup; wait 5; +user4; wait 110; -user4; netevent c246_release; '+done,
'flight.cfg':setup+'netevent c246_flight; wait 34; netevent c246_before; wait 1; netevent c246_first; wait 315; netevent c246_terminal; wait 4; netevent c246_children; '+done,
'impacts.cfg':setup+'netevent c246_wall; wait 40; netevent c246_finished; netevent c246_floor; wait 40; netevent c246_finished; netevent c246_ceiling; wait 40; netevent c246_finished; '+done,
'save.cfg':setup+'netevent c246_save; wait 17; save sun.zds; wait 2; '+done,
'load.cfg':'wait 1; netevent c246_loaded; wait 35; netevent c246_clock; changemap MAP98; wait 10; changemap MAP99; wait 1; netevent c246_hub; wait 350; netevent c246_terminal; '+done,
'save_prep.cfg':setup+'+user4; wait 35; -user4; netevent c246_partial; save preparing.zds; wait 2; '+done,
'load_prep.cfg':'wait 75; netevent c246_release; '+done}
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c246_manual"; bind f7 "netevent c246_manual_wall"; wait 100; netevent c246_manual; wait 80; '
scripts['manual.cfg']=manual+'netevent c246_done;\n'
scripts['preview.cfg']=manual+'screenshot inactive.png; +user4; wait 160; -user4; screenshot active.png; wait 350; netevent c246_finished; '+done
for name,text in scripts.items():(out/name).write_bytes(text.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
