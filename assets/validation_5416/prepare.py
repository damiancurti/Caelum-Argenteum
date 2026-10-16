"""Freeze #247 and produce isolated native-input scenarios; never overwrite evidence."""
from pathlib import Path
import argparse, importlib.util, json, struct
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5110/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
def water_room():
    data=room.room();count,offset=struct.unpack_from('<ii',data,4)
    for i in range(count):
        pos,size,name=struct.unpack_from('<ii8s',data,offset+16*i)
        if name.rstrip(b'\0')==b'TEXTMAP':text=data[pos:pos+size].decode()
    text=text.replace('sector { heightfloor=0;','sector { id=99; heightfloor=0;')
    for x,y in [(31000,0),(31000,32),(31032,32),(31032,0)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
    text+='sector { heightfloor=-8; heightceiling=1024; texturefloor="FWATER1"; textureceiling="FWATER1"; lightlevel=160; }\n'
    for i in range(4):
        text+='sidedef { sector=1; texturemiddle="STARTAN3"; }\n'
        action='special=160; arg0=99; arg1=2; arg3=192;' if i==0 else ''
        text+=f'linedef {{ v1={4+i}; v2={4+(i+1)%4}; sidefront={4+i}; blocking=true; {action} }}\n'
    data=b'';directory=b''
    for name,payload in [('CA247W',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest={'runtime_sha256':room.package(out/'production.pk3',{q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()})}
manifest['fixture_sha256']=room.package(out/'formation.pk3',{'ZSCRIPT':b'version "4.14"\n#include "formation.zs"\n','formation.zs':(HERE/'formation.zs').read_bytes(),'maps/CA154.wad':room.room(),'maps/CA247H.wad':room.room(),'maps/CA247W.wad':water_room(),'MAPINFO':b'GameInfo { PlayerClasses="CA247Player" AddEventHandlers="CA247Probe" }\ncluster 99 { hub }\nmap CA154 "Formation Breaker audit" { cluster=99 }\nmap CA247H "Formation Breaker hub" { cluster=99 }\nmap CA247W "Formation water audit" { cluster=99 }\n'})
setup='cl_run false; wait 100; netevent c247_setup; wait 16; '
gesture='+forward; wait 2; -forward; wait 3; +forward; wait 4; '
done='-forward; -moveright; -crouch; wait 50; netevent c247_clean; netevent c247_done; wait 35; quit\n'
scripts={
 'contract.cfg':setup+gesture+'-forward; wait 35; netevent c247_check 35; '+done,
 'crouch.cfg':setup+'+crouch; wait 35; '+gesture+'-forward; wait 35; netevent c247_check 35; '+done,
 'steer.cfg':setup+gesture+'netevent c247_turn; -forward; +moveright; wait 3; -moveright; +forward; wait 2; -forward; wait 3; +forward; wait 35; netevent c247_check 35; '+done,
 'scaled.cfg':setup+'netevent c247_setup 0 200; wait 16; '+gesture+'-forward; wait 75; netevent c247_check 70; '+done,
 'expiry.cfg':setup+gesture+'netevent c247_expiry; -forward; wait 35; netevent c247_check 35; '+done,
 'wall.cfg':setup+'netevent c247_wall; wait 2; '+gesture+'wait 20; netevent c247_blocked; '+done,
 'body.cfg':setup+'netevent c247_body; wait 2; '+gesture+'wait 20; netevent c247_blocked; '+done,
 'ordinary.cfg':setup+'netevent c247_setup 1; wait 16; '+gesture+'netevent c247_normal; '+done,
 'flight.cfg':setup+'netevent c247_setup 2; wait 16; '+gesture+'netevent c247_normal; '+done,
 'water.cfg':setup+gesture+'netevent c247_water; netevent c247_normal; '+done,
 'defense.cfg':setup+'netevent c247_defense; '+done,
 'save.cfg':setup+gesture+'save dash.zds; '+done,
 'save_prep.cfg':setup+'netevent c247_setup 1; wait 16; +user4; wait 35; -user4; netevent c247_partial; wait 2; save preparing.zds; '+done,
 'load_prep.cfg':'wait 75; netevent c247_released; '+done,
 'load.cfg':'wait 40; netevent c247_loaded; '+done,
 'cast.cfg':setup+'netevent c247_setup 1; wait 16; +user4; wait 35; -user4; netevent c247_partial; wait 2; +user4; wait 2; -user4; netevent c247_cancel; netevent c247_setup 1; wait 16; +user4; wait 107; -user4; netevent c247_released; '+done,
 'manual.cfg':'language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c247_manual"; bind f7 "netevent c247_manual_wall"; bind c chase; cl_run false; wait 100; netevent c247_manual; wait 5; netevent c247_done;\n',
 'preview.cfg':setup+'netevent c247_camera; '+gesture+'wait 14; netevent c247_trail; screenshot trail.png; '+done,
 'low.cfg':setup+'+crouch; wait 35; netevent c247_roof; wait 2; '+gesture+'netevent c247_denied; '+done,
 'prediction.cfg':setup+gesture+'netevent c247_prediction; '+done,
 'renew.cfg':setup+'netevent c247_renew; '+done,
 'death.cfg':setup+gesture+'netevent c247_dead; wait 3; netevent c247_death_check; '+done,
 'hub.cfg':setup+gesture+'changemap CA247H; wait 3; netevent c247_hub; changemap CA154; wait 3; netevent c247_hub; '+done,
 'diagonal.cfg':setup+'+moveright; wait 20; '+gesture+'-forward; -moveright; wait 40; netevent c247_check 35; '+done,
}
for i in range(1,4):scripts[f'interrupt{i}.cfg']=setup+gesture+f'netevent c247_interrupt {i}; wait 3; netevent c247_stopped; '+done
scripts['jump.cfg']=setup+gesture+'+jump; wait 3; -jump; netevent c247_stopped; '+done
for name,text in scripts.items():(out/name).write_bytes(text.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
