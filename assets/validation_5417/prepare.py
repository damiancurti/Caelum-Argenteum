"""Freeze the #248 runtime and deterministic room/occlusion fixture."""
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
data=b'';directory=b''
for name,payload in [('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
wad=struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'rally.pk3',{'ZSCRIPT':b'version "4.14"\n#include "rally.zs"\n','rally.zs':(HERE/'rally.zs').read_bytes(),'maps/MAP99.wad':wad,'maps/MAP98.wad':wad,'MAPINFO':b'GameInfo { AddEventHandlers="CA248Probe" }\ncluster 99 { hub }\nmap MAP99 "Rally fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Rally hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c248_setup; wait 5; '
done='netevent c248_done; wait 2; quit\n'
scripts={
'advanced.cfg':setup+'netevent c248_advanced; '+done,
'flight.cfg':setup+'netevent c248_flight; wait 5; netevent c248_midflight; wait 30; netevent c248_flight_check; '+done,
'damage.cfg':setup+'netevent c248_damage; '+done,
'contract.cfg':setup+'netevent c248_contract; '+done,
'casting.cfg':setup+'+user4; wait 35; -user4; netevent c248_partial; wait 2; +user4; wait 2; -user4; netevent c248_cancel; netevent c248_setup; wait 5; +user4; wait 110; -user4; netevent c248_release; '+done,
'cadence.cfg':setup+'netevent c248_cadence; wait 34; netevent c248_before; wait 1; netevent c248_first; wait 315; netevent c248_tenth; wait 35; netevent c248_after; '+done,
'save.cfg':setup+'netevent c248_save; wait 17; save rally.zds; wait 2; '+done,
'load.cfg':'wait 1; netevent c248_loaded; wait 35; netevent c248_clock; changemap MAP98; wait 10; netevent c248_hub; changemap MAP99; wait 10; netevent c248_hub; wait 350; netevent c248_expired; netevent c248_dead; '+done,
'save_prep.cfg':setup+'+user4; wait 35; -user4; netevent c248_partial; save preparing.zds; wait 2; '+done,
'load_prep.cfg':'wait 75; netevent c248_release; '+done}
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c248_manual"; bind f7 "netevent c248_position"; bind f10 "netevent c248_occlusion"; bind f8 "netevent c248_incoming"; bind f9 "netevent c248_outgoing"; bind f11 "netevent c248_halfbar"; wait 100; netevent c248_manual; wait 80; '
scripts['manual.cfg']=manual+'netevent c248_done;\n'
scripts['preview.cfg']=manual+'screenshot inactive.png; +user4; wait 150; -user4; netevent c248_manual_check; netevent c248_halfbar; netevent c248_incoming; wait 3; screenshot active.png; wait 350; netevent c248_expired; '+done
for name,text in scripts.items():(out/name).write_bytes(text.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
