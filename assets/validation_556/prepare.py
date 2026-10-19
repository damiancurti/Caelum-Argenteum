"""Freeze #314 owned fixture geometry, native probe and runtime independently."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('seal',HERE.parent/'validation_5421/prepare.py')
seal=importlib.util.module_from_spec(spec);spec.loader.exec_module(seal)


def geometry(scene):
    text=['namespace="ZDoom";']
    sectors=[];vertices=[];sides=[];lines=[]
    def sector(kind=0,tag=0,roof=False,bottom=0,top=None,water=False):
        index=len(sectors)
        texture='C314ICE' if kind==1 else 'C314LAVA' if kind==2 else 'CMGR03'
        ceiling='CMST01' if roof else 'F_SKY1'
        properties='user_ca_water_temperature_defined=1; user_ca_water_temperature_c=7;' if water else ''
        sectors.append(f'sector {{ id={tag}; heightfloor={bottom}; heightceiling={scene["ceiling"] if top is None else top}; texturefloor="{texture}"; textureceiling="{ceiling}"; lightlevel=224; user_ca_thermal_surface={kind}; {properties} }}')
        return index
    def polygon(points,front,back=None,special=''):
        first=len(vertices)
        vertices.extend(f'vertex {{ x={x}; y={y}; }}' for x,y in points)
        for i in range(4):
            sf=len(sides);middle='CACVROCK' if back is None else '-'
            sides.append(f'sidedef {{ sector={front}; texturemiddle="{middle}"; texturetop="CACVROCK"; texturebottom="CACVROCK"; }}')
            extra=''
            if back is not None:
                sb=len(sides);sides.append(f'sidedef {{ sector={back}; texturemiddle="-"; texturetop="CACVROCK"; texturebottom="CACVROCK"; }}')
                extra=f'sideback={sb}; twosided=true;'
            lines.append(f'linedef {{ v1={first+i}; v2={first+(i+1)%4}; sidefront={sf}; {extra} {special if i==0 else ""} }}')
    def box(x,y,half):return [(x-half,y-half),(x-half,y+half),(x+half,y+half),(x+half,y-half)]
    sector(scene.get('base_kind',0));x1,y1,x2,y2=scene['outer'];polygon([(x1,y1),(x1,y2),(x2,y2),(x2,y1)],0)
    controls=[]
    for i,zone in enumerate(scene['zones']):
        x,y,_=zone['position'];tag=3140+i
        index=sector(zone['kind'],tag,zone.get('roof',False))
        polygon(box(x,y,scene['zone_half_size']),index,0)
        if zone.get('water'):controls.append((tag,0,32,0,True))
        if zone.get('platform'):controls.append((tag,48,64,zone['platform'],False))
    for i,(tag,bottom,top,kind,water) in enumerate(controls):
        index=sector(kind,0,True,bottom,top,water)
        polygon(box(-1400+i*200,1600,32),index,special=f'special=160; arg0={tag}; arg1={2 if water else 1}; arg3={128 if water else 255};')
    x,y,z=scene['spawn'];text+=sectors+vertices+sides+lines
    text.append(f'thing {{ x={x}; y={y}; height={z}; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }}')
    text.append('thing { x=0; y=0; type=31401; arg0=1; arg1=5; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
    data=b'';directory=b''
    for name,content in [('TTSURF',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(content),name.encode());data+=content
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    p.add_argument('--runtime',type=Path);p.add_argument('--baseline-probe',action='store_true');a=p.parse_args()
    if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory):p.error('Plain directory name required.')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    scene=json.loads((HERE/'scene.json').read_text())
    source={q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()}
    if a.runtime:
        with zipfile.ZipFile(a.runtime) as archive:source={n:archive.read(n) for n in archive.namelist()}
    package=seal.shared.package
    manifest={'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'runtime_sha256':package(out/'production.pk3',source),
        'source_hashes':{n:hashlib.sha256(b).hexdigest() for n,b in source.items()}}
    points=''.join(f'case {i}:return ({x},{y},{z});' for i,zone in enumerate(scene['zones']) for x,y,z in [zone['position']])
    perf=scene['performance'];x,y,z=perf['origin'];cols=perf['columns'];spacing=perf['spacing']
    data=f'class CA314Data:Object {{ const POPULATION={perf["population"]}; static clearscope vector3 BodyPosition(int i) {{ return ({x}+(i%{cols})*{spacing},{y}+(i/{cols})*{spacing},{z}); }} static clearscope vector3 Position(int i) {{ switch(i) {{{points}}} return (0,0,0); }} }}'
    neutral=dict(scene,zones=[])
    fixture={'ZSCRIPT':b'version "4.14"\n#include "data.zs"\n#include "probe.zs"\n#include "perf.zs"\n',
        'perf.zs':(HERE/'perf.zs').read_bytes(),
        'data.zs':data.encode(),'probe.zs':(HERE/('baseline.zs' if a.baseline_probe else 'probe.zs')).read_bytes(),'maps/TTSURF.wad':geometry(scene),
        'maps/TTSNONE.wad':geometry(neutral),
        'maps/TTSPERF.wad':geometry(dict(neutral,base_kind=2)),
        'maps/TTSURF2.wad':geometry(scene),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA314Probe" }\nDoomEdNums { 31401="CaelumClimateRegion" }\ncluster 99 { hub }\nmap TTSURF "Thermal surface fixture" { cluster=99 nointermission sky1="CMLMSKY",0 }\nmap TTSURF2 "Surface hub fixture" { cluster=99 nointermission sky1="CMLMSKY",0 }\nmap TTSNONE "Neutral hub fixture" { cluster=99 nointermission sky1="CMLMSKY",0 }\n',
        'TEXTURES':b'Texture C314ICE,256,256 { Patch "models/caelum/world/environment/rock_granite.png",0,0 { Blend "9bd6ed",0.8 } }\nTexture C314LAVA,256,256 { Patch "models/caelum/world/environment/rock_granite.png",0,0 { Blend "ef570e",0.8 } }\n'}
    fixture['MAPINFO']=fixture['MAPINFO'].replace(b'AddEventHandlers="CA314Probe"',b'AddEventHandlers="CA314Probe","CA314Performance"')+b'\nmap TTSPERF "Contact population fixture" { sky1="CMLMSKY",0 }\n'
    fixture['LANGUAGE']='''[enu default]
C314_ICE="Ice: -40 C";
C314_LAVA="Lava: 1000 C";
C314_NONE="No dry thermal-floor contact";
C314_KEYS="F6 Ice | F7 Lava | F8 Neutral | F9 Water | F10 Reset";
[es]
C314_ICE="Hielo: -40 C";
C314_LAVA="Lava: 1000 C";
C314_NONE="Sin contacto termico seco";
C314_KEYS="F6 Hielo | F7 Lava | F8 Neutro | F9 Agua | F10 Restablecer";
'''.encode()
    manifest['fixture_sha256']=package(out/'quick.pk3',fixture)
    start='wait 100; netevent c314_setup; wait 70; '
    done='netevent c314_done; wait 5; quit\n'
    scripts={'smoke.cfg':start+''.join(f'netevent c314_move {i}; wait 3; netevent c314_geometry {i}; ' for i in range(8))+done,
        'solver.cfg':start+'netevent c314_solver; netevent c314_damage; '+done,
        'npc.cfg':start+'netevent c314_npc; wait 70; netevent c314_npccheck 0; netevent c314_npcmove 7; wait 70; netevent c314_npccheck 2; netevent c314_npcmove 0; wait 3; netevent c314_npccheck 0; '+done,
        'crouch.cfg':start+'netevent c314_move 1; +crouch; wait 35; netevent c314_geometry 1; -crouch; wait 15; +jump; wait 3; netevent c314_contact 0; -jump; wait 70; netevent c314_geometry 1; '+done,
        'save.cfg':start+'netevent c314_move 1; wait 35; netevent c314_mark; save contact.zds; '+done,
        'load.cfg':'wait 2; netevent c314_restored 1; '+done,
        'old-load.cfg':'wait 2; netevent c314_restored 1; '+done,
        'hub.cfg':start+'netevent c314_npc; wait 35; netevent c314_npcmove 7; netevent c314_move 2; wait 35; changemap TTSNONE; wait 35; netevent c314_hub 0; changemap TTSURF; wait 3; netevent c314_hub 0; '+done,
        'perf.cfg':start+'netevent c314_perf 1; wait 425; '+done,
        'reference.cfg':start+'netevent c314_perf 0; wait 425; '+done,
        'visual.cfg':start+'netevent c314_manual; con_notifytime 0; netevent c314_move 1; wait 5; screenshot ice.png; netevent c314_move 2; wait 5; screenshot lava.png; language es; wait 5; screenshot lava-es.png; '+done,
        'manual.cfg':start+'netevent c314_manual; language es; use_mouse true; bind f6 "netevent c314_move 1"; bind f7 "netevent c314_move 2"; bind f8 "netevent c314_move 0"; bind f9 "netevent c314_move 3"; bind f10 "netevent c314_reset"; con_notifytime 0; netevent c314_done;\n'}
    for name,code in scripts.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    manifest['script_hashes']={q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in out.glob('*.cfg')}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k!='source_hashes' and k!='script_hashes'}))


if __name__=='__main__':main()
