"""Freeze #242 runtime and isolated native resource/input/save checks."""
from pathlib import Path
import argparse,importlib.util,json,struct
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
def module(path,name):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
shared=module(HERE.parent/'validation_541/prepare.py','package541')
room=module(HERE.parent/'validation_5218/prepare.py','room5218')
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--directory',required=True);args=parser.parse_args()
if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):parser.error('Plain directory name required.')
out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
def water_room():
 source=room.room();count,offset=struct.unpack_from('<ii',source,4)
 for i in range(count):
  pos,size,name=struct.unpack_from('<ii8s',source,offset+16*i)
  if name.rstrip(b'\0')==b'TEXTMAP':text=source[pos:pos+size].decode()
 text=text.replace('sector { heightfloor=0;','sector { id=99; heightfloor=0;')
 for x,y in [(4096,0),(4096,32),(4128,32),(4128,0)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
 text+='sector { heightfloor=-8; heightceiling=192; texturefloor="FWATER1"; textureceiling="FWATER1"; lightlevel=160; }\n'
 for i in range(4):
  text+='sidedef { sector=1; texturemiddle="STARTAN3"; }\n'
  action='special=160; arg0=99; arg1=2; arg3=192;' if i==0 else ''
  text+=f'linedef {{ v1={4+i}; v2={4+(i+1)%4}; sidefront={4+i}; blocking=true; {action} }}\n'
 data=b'';directory=b''
 for name,payload in [('MAP97',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
  directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
 return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest={'runtime_sha256':shared.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=shared.package(out/'breathing.pk3',{'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "breathing.zs"\n','equipment.zs':(HERE.parent/'validation_541/session.zs').read_text(encoding='utf-8').replace('    int Kind()','    virtual int Kind()').encode(),'breathing.zs':(HERE/'breathing.zs').read_bytes(),'maps/MAP99.wad':room.room(),'maps/MAP98.wad':room.room(),'maps/MAP97.wad':water_room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA242Probe" }\ncluster 99 { hub }\nmap MAP99 "Breathing fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Breathing fixture hub" { cluster=99 sky1="SKY1",0 }\nmap MAP97 "Breathing water fixture" { cluster=99 sky1="SKY1",0 }\n'})
steps=['wait 100','netevent c242_setup','wait 100','+user1','wait 35','-user1','wait 2','netevent c242_on']
for mode in [1,0]:
 if not mode:steps+=['+user1','wait 35','-user1','wait 2','netevent c242_off']
 for weapon in [4,5,6,7,8,9,10,11]:
  attack='altattack' if weapon==9 else 'attack'
  steps += [f'netevent c242_equipment {weapon}','wait 80','netevent c242_snapshot',f'+{attack}','wait 4',f'-{attack}','wait 90',f'netevent c242_action {mode}']
 steps += ['netevent c242_snapshot','+speed','+forward','wait 20','-forward','-speed','wait 5',f'netevent c242_action {mode}']
 steps += ['netevent c242_snapshot','+jump','wait 2','-jump','wait 60',f'netevent c242_action {mode}']
 steps += ['netevent c242_equipment 12','wait 80','netevent c242_snapshot','+zoom','wait 2','-zoom','wait 35','+zoom','wait 2','-zoom','wait 5',f'netevent c242_action {mode}']
steps+=['netevent c242_done','wait 2','quit']
(out/'contract.cfg').write_text('; '.join(steps)+'\n',encoding='utf-8')
start='wait 100; netevent c242_setup; wait 100; +user1; wait 35; -user1; wait 2; netevent c242_on; netevent c242_seed_save; '
(out/'save.cfg').write_text(start+'save breathing.zds; wait 5; netevent c242_saved; netevent c242_done; wait 2; quit\n',encoding='utf-8')
(out/'load.cfg').write_text('wait 10; netevent c242_saved; +user1; wait 5; -user1; netevent c242_off; netevent c242_done; wait 2; quit\n',encoding='utf-8')
(out/'hub.cfg').write_text(start+'changemap MAP98; wait 10; netevent c242_saved; changemap MAP99; wait 10; netevent c242_saved; netevent c242_done; wait 2; quit\n',encoding='utf-8')
(out/'water.cfg').write_text(start+'changemap MAP97; wait 5; netevent c242_water_seed; wait 70; netevent c242_water_check; netevent c242_water_exhaust; wait 140; netevent c242_water_fallback; changemap MAP99; wait 120; netevent c242_water_surface; netevent c242_done; wait 2; quit\n',encoding='utf-8')
manual='language es; bind f +user1; bind b +zoom; bind shift +speed; bind space +jump; bind f6 "netevent c242_manual"; bind f7 "changemap MAP97"; bind f8 "netevent c242_low_anima"; bind f9 "netevent c242_empty_air"; bind f10 "changemap MAP99"; wait 100; netevent c242_manual; wait 100; '
(out/'manual.cfg').write_text(manual+'\n',encoding='utf-8')
(out/'preview.cfg').write_text(manual+'+user1; wait 5; -user1; wait 5; screenshot breathing-ready.png; wait 5; quit\n',encoding='utf-8')
(out/'rollback-return.cfg').write_text('wait 10; netevent c242_rollback_return; netevent c242_done; wait 2; quit\n',encoding='utf-8')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
