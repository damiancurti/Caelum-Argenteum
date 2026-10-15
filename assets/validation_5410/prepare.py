"""Freeze issue #243 runtime and isolated native acceptance fixtures."""
from pathlib import Path
import argparse, importlib.util, json, struct
ROOT=Path(__file__).resolve().parents[2]; HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room209',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
def test_room():
    source=room.room(); _,count,offset=struct.unpack_from('<4sii',source)
    lumps=[]
    for i in range(count):
        start,size,name=struct.unpack_from('<ii8s',source,offset+i*16)
        payload=source[start:start+size]
        if name.rstrip(b'\0')==b'TEXTMAP':
            text=payload.decode().replace('1024','4096')
            for x,y in [(96,280),(160,280),(160,520),(96,520)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
            for i in range(4):
                text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
                text+=f'linedef {{ v1={4+i}; v2={4+(i+1)%4}; sidefront={4+i}; blocking=true; }}\n'
            payload=text.encode()
        lumps.append((name,payload))
    data=b'';directory=b''
    for name,payload in lumps:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name);data+=payload
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(data))+data+directory
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=room.package(out/'cry.pk3',{'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "cry.zs"\n','equipment.zs':(HERE.parent/'validation_541/session.zs').read_text(encoding='utf-8').replace('    int Kind()','    virtual int Kind()').encode(),'cry.zs':(HERE/'cry.zs').read_bytes(),'maps/MAP99.wad':test_room(),'maps/MAP98.wad':test_room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA243Probe" }\ncluster 99 { hub }\nmap MAP99 "Battle Cry fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Battle Cry hub" { cluster=99 sky1="SKY1",0 }\n'})
setup='wait 100; netevent c243_setup; wait 5; '
done='netevent c243_done; wait 2; quit\n'
scripts={
 'contract.cfg':setup+'netevent c243_contract; netevent c243_mark; wait 35; netevent c243_tick; wait 40; netevent c243_expired; '+done,
 'casting.cfg':setup+'+user4; wait 35; -user4; netevent c243_preparing; wait 2; +user4; wait 2; -user4; netevent c243_cancelled; netevent c243_setup; wait 5; +user4; wait 110; -user4; netevent c243_released; '+done,
 'save.cfg':setup+'netevent c243_save_effect; save cry.zds; wait 5; '+done,
 'load.cfg':'wait 10; netevent c243_loaded_effect; wait 35; netevent c243_saved_clock; changemap MAP98; wait 10; netevent c243_hub; changemap MAP99; wait 10; netevent c243_hub_return; '+done,
 'save_prep.cfg':setup+'+user4; wait 35; -user4; netevent c243_preparing; save preparing.zds; wait 2; '+done,
 'load_prep.cfg':'wait 10; netevent c243_loaded_prep; wait 65; netevent c243_released; '+done,
 'boundaries.cfg':setup+'netevent c243_boundaries; +forward; wait 20; -forward; netevent c243_moved; wait 150; netevent c243_retained; '+done,
 'flight.cfg':setup+'netevent c243_arm 0; wait 80; netevent c243_flight; +attack; wait 2; -attack; wait 210; netevent c243_flight_check; '+done,
 'npcs.cfg':setup+'netevent c243_npcs; '+done,
 'siege.cfg':setup+'netevent c243_siege; '+done,
}
steps=setup
for weapon in [0,1,2,3,5,6,7,8,9]:
    count=12 if weapon in [3,6] else 1;attack='altattack' if weapon==9 else 'attack'
    steps+=f'netevent c243_arm {weapon}; wait 80; '
    for state in ['','netevent c243_block; ','netevent c243_unblock; ']:
        expected=0 if 'block;' in state and 'unblock;' not in state else count
        steps+=state+f'+{attack}; wait 2; -{attack}; wait 90; netevent c243_shots {expected}; '
scripts['weapons.cfg']=steps+done
steps=setup+'netevent c243_arm 4; wait 80; netevent c243_melee_position; '
for weapon in ['','netevent c243_unarmed; wait 80; ']:
    steps+=weapon
    for state in ['netevent c243_unblock; ','netevent c243_block; ','netevent c243_unblock; ']:
        expected=0 if 'unblock' not in state else 1
        steps+=state+f'+attack; wait 2; -attack; wait 90; netevent c243_melee_hits {expected}; '
scripts['melee.cfg']=steps+done
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind b +zoom; bind f6 "netevent c243_manual"; bind f7 "netevent c243_self"; bind f8 "netevent c243_weapon"; bind f9 "netevent c243_next"; wait 100; netevent c243_manual; wait 80; '
scripts['manual.cfg']=manual+'netevent c243_done;\n'
scripts['preview.cfg']=manual+'+user4; wait 115; -user4; netevent c243_manual_check; screenshot intimidated.png; wait 35; netevent c243_manual_walk; netevent c243_dead_caster; '+done
for name,content in scripts.items():(out/name).write_bytes(content.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
