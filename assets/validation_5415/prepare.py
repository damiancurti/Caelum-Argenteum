"""Freeze the #260 runtime and its isolated native-input movement fixture."""
from pathlib import Path
import argparse
import importlib.util
import json
import struct
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('room', HERE.parent/'validation_5110/prepare.py')
room = importlib.util.module_from_spec(spec)
spec.loader.exec_module(room)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory', required=True)
p.add_argument('--runtime', type=Path)
p.add_argument('--save', type=Path)
p.add_argument('--compatibility', action='store_true')
p.add_argument('--impulse', action='store_true')
a = p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):
    p.error('Plain directory name required.')
out = ROOT/'build'/a.directory
if a.runtime and not a.runtime.is_file():p.error('Input runtime must exist.')
if a.save and not a.save.is_file():p.error('Input save must exist.')
out.mkdir(exist_ok=False)
def water_room():
    source=room.room()
    count,offset=struct.unpack_from('<ii',source,4)
    for i in range(count):
        pos,size,name=struct.unpack_from('<ii8s',source,offset+16*i)
        if name.rstrip(b'\0')==b'TEXTMAP': text=source[pos:pos+size].decode()
    text=text.replace('sector { heightfloor=0;', 'sector { id=99; heightfloor=0;')
    for x,y in [(31000,0),(31000,32),(31032,32),(31032,0)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
    text+='sector { heightfloor=-8; heightceiling=1024; texturefloor="FWATER1"; textureceiling="FWATER1"; lightlevel=160; }\n'
    for i in range(4):
        text+='sidedef { sector=1; texturemiddle="STARTAN3"; }\n'
        action='special=160; arg0=99; arg1=2; arg3=192;' if i==0 else ''
        text+=f'linedef {{ v1={4+i}; v2={4+(i+1)%4}; sidefront={4+i}; blocking=true; {action} }}\n'
    data=b'';directory=b''
    for name,payload in [('CA260W',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest = {'runtime_sha256': room.package(out/'production.pk3', {
    q.relative_to(ROOT/'src').as_posix(): q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()})}
if a.runtime:
    import hashlib
    shutil.copyfile(a.runtime,out/'production.pk3')
    manifest['runtime_sha256']=hashlib.sha256(a.runtime.read_bytes()).hexdigest()
if a.save:shutil.copyfile(a.save,out/'input.zds')
manifest['fixture_sha256'] = room.package(out/'movement.pk3', {
    'ZSCRIPT': b'version "4.14"\n#include "movement.zs"\n'+(b'#include "impulse.zs"\n' if a.impulse else b''),
    'movement.zs': (HERE/('compatibility.zs' if a.compatibility else 'movement.zs')).read_bytes(),
    **({'impulse.zs':(HERE/'impulse.zs').read_bytes()} if a.impulse else {}),
    'maps/CA154.wad': room.room(),
    'maps/CA260W.wad':water_room(),
    'MAPINFO': ('map CA154 "Mass acceleration audit" {}\nmap CA260W "Water acceleration audit" {}\nGameInfo { PlayerClasses="'+('CA260ImpulsePlayer' if a.impulse else 'CA260Player')+'" AddEventHandlers="'+('CA260ImpulseProbe' if a.impulse else 'CA260Probe')+'" }\n').encode()})
for q in HERE.glob('*.cfg'):
    (out/q.name).write_bytes(q.read_bytes())
cases=[(50,0,0,'forward',False),(100,0,0,'forward',False),(200,0,0,'forward',False),
       (50,50,0,'forward',False),(100,0,0,'forward',True),(100,0,0,'moveright',False),
       (100,0,0,'moveright',True),(100,0,1,'forward',False)]
steps=['cl_run false','wait 100']
for mass,load,mode,key,run in cases:
    steps += [f'netevent c260_setup {mass} {load} {mode}','wait 5']
    if run:steps+=['+speed']
    steps += [f'+{key}','wait 270','netevent c260_check','wait 2',f'-{key}']
    if run:steps+=['-speed']
    steps+=['wait 100','netevent c260_stopped','wait 2']
steps += ['netevent c260_done','wait 35','quit']
(out/'contract.cfg').write_bytes(('; '.join(steps)+'\n').encode())
(out/'water.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100 0 2; wait 5; +forward; wait 270; netevent c260_check; wait 2; -forward; wait 100; netevent c260_stopped; wait 2; netevent c260_done; wait 35; quit\n')
(out/'interactions.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100; wait 5; +forward; wait 20; netevent c260_dynamic; wait 4; netevent c260_dynamic_check; netevent c260_push; wait 10; netevent c260_push_check; netevent c260_airborne; wait 10; netevent c260_airborne_check; -forward; wait 100; netevent c260_setup 100; wait 5; +forward; wait 40; netevent c260_revision; wait 2; netevent c260_snapshot; wait 5; save ramp.zds; wait 35; netevent c260_inventory; wait 2; -forward; netevent c260_done; wait 35; quit\n')
(out/'load.cfg').write_bytes(b'wait 10; +forward; wait 35; -forward; wait 100; netevent c260_stopped; wait 2; netevent c260_done; wait 35; quit\n')
(out/'legacy.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup; wait 5; +forward; wait 40; save legacy.zds; wait 35; -forward; netevent c260_done; wait 35; quit\n')
(out/'compatibility.cfg').write_bytes(b'wait 10; +forward; wait 20; save migrated.zds; wait 35; -forward; netevent c260_done; wait 35; quit\n')
(out/'manual.cfg').write_bytes(b'language es; cl_run false; con_notifytime 0; use_mouse true; bind f6 "netevent c260_setup 50"; bind f7 "netevent c260_setup 100"; bind f8 "netevent c260_setup 200"; wait 100; netevent c260_setup 100; wait 5; netevent c260_done;\n')
(out/'extended.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 50 50; wait 5; +forward; wait 270; netevent c260_check; wait 2; -forward; wait 100; netevent c260_stopped; wait 2; netevent c260_setup 100; +crouch; wait 35; +forward; wait 270; netevent c260_check; wait 2; -forward; -crouch; wait 100; netevent c260_stopped; wait 2; netevent c260_setup 100; wait 5; +forward; +moveright; +speed; wait 270; netevent c260_check; wait 2; -forward; -moveright; -speed; wait 100; netevent c260_stopped; wait 2; netevent c260_done; wait 35; quit\n')
(out/'manifest.json').write_bytes((json.dumps(manifest, indent=2)+'\n').encode())
if a.impulse:
    from impulse_cases import generate
    generate(out)
print(json.dumps(manifest))
