"""Build deterministic #130 packages; all native fixtures remain outside src."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue130'
BASE='45f16371d49c38894e6d256d32d8101d4b06cd4c'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline',action='store_true')
args=parser.parse_args()
active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True)
if 'gzdoom.exe' in active.lower():raise SystemExit('Close native runs before replacing packages.')
OUT.mkdir(exist_ok=True)

def package(name,members):
    path=OUT/name
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

if args.baseline:
    subprocess.run(['git','archive','--format=zip','--output',str(OUT/'baseline-source.zip'),BASE,'src'],check=True,cwd=ROOT)
    with zipfile.ZipFile(OUT/'baseline-source.zip') as z:
        package('baseline.pk3',{n.removeprefix('src/'):z.read(n) for n in z.namelist() if not n.endswith('/')})
members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
manifest={'baseline_commit':BASE,'production_sha256':package('production.pk3',members)}
# Minimal independent UDMF room; native engine builds its nodes.
text='namespace="ZDoom";\nsector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }\n'
for i,(x,y) in enumerate([(-2048,-2048),(-2048,2048),(2048,2048),(2048,-2048)]):
    text+=f'vertex {{ x={x}; y={y}; }}\nsidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
text+='thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
body=bytearray();directory=bytearray()
for key,data in [('QA130A',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory
fixture={'maps/QA130A.wad':wad,'MAPINFO':b'map QA130A "Thermal verification" { }\nGameInfo { AddEventHandlers="CA130Checks" }\n',
         'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes()}
manifest['checks_sha256']=package('checks.pk3',fixture)
live=dict(fixture)
live['MAPINFO']=b'map QA130A "Thermal live integration" { }\nGameInfo { AddEventHandlers="CA130Live" }\n'
live['ZSCRIPT']=b'version "4.14"\n#include "live.zs"\n'
live['live.zs']=(HERE/'live.zs').read_bytes()
manifest['live_sha256']=package('live.pk3',live)
(OUT/'live.cfg').write_text('wait 140; quit\n',encoding='utf-8')
for name,handler,tics in [('effects','CA130Effects',115)]:
    members={'maps/QA130A.wad':wad,'MAPINFO':f'map QA130A "Thermal {name}" {{ }}\nGameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
        'ZSCRIPT':f'version "4.14"\n#include "{name}.zs"\n'.encode(),f'{name}.zs':(HERE/f'{name}.zs').read_bytes()}
    manifest[f'{name}_sha256']=package(f'{name}.pk3',members)
    (OUT/f'{name}.cfg').write_text(f'wait {tics}; quit\n',encoding='utf-8')
(OUT/'effects.cfg').write_text('wait 45; +forward; wait 35; -forward; wait 11; +jump; wait 1; -jump; wait 23; quit\n',encoding='utf-8')
# Independent enclosure fixture: the outer sky sector cannot supply near walls.
geo=['namespace="ZDoom";','sector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="F_SKY1"; lightlevel=208; user_ca_water_temperature_defined=1; user_ca_water_temperature_c=7.0; }']
vertex=side=0
def polygon(points,front,back=None):
    global vertex,side
    first=vertex
    for x,y in points:
        geo.append(f'vertex {{ x={x:.6f}; y={y:.6f}; }}');vertex+=1
    for i in range(len(points)):
        geo.append(f'sidedef {{ sector={front}; texturemiddle="CMST01"; texturetop="CMST01"; texturebottom="CMST01"; }}')
        sf=side;side+=1
        sb=''
        if back is not None:
            geo.append(f'sidedef {{ sector={back}; texturemiddle="-"; texturetop="CMST01"; texturebottom="CMST01"; }}')
            sb=f'sideback={side}; twosided=true;';side+=1
        geo.append(f'linedef {{ v1={first+i}; v2={first+(i+1)%len(points)}; sidefront={sf}; {sb} }}')
polygon([(-16000,-8000),(-16000,8000),(16000,8000),(16000,-8000)],0)
u=[(-128,-128),(-128,128),(128,128),(128,-128),(112,-128),(112,112),(-112,112),(-112,-128)]
ell=[(-128,-128),(-128,128),(128,128),(128,112),(-112,112),(-112,-128)]
for index,(cx,shape,rotation,scale,ceiling) in enumerate([
    (-8000,u,0,1,0),(-4000,ell,0,1,0),(0,u,math.pi/4,1,0),
    (5000,u,0,20,0),(11000,[(-128,-128),(-128,128),(128,128),(128,-128)],0,1,128)],1):
    geo.append(f'sector {{ heightfloor=0; heightceiling={ceiling}; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }}')
    points=[(cx+scale*(x*math.cos(rotation)-y*math.sin(rotation)),scale*(x*math.sin(rotation)+y*math.cos(rotation))) for x,y in shape]
    polygon(points,index,None if ceiling else 0)
# Two vertically separated water temperatures, including water above dry feet.
geo.append('sector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="F_SKY1"; lightlevel=208; id=1302; }')
polygon([(13872,-128),(13872,128),(14128,128),(14128,-128)],6,0)
for index,(bottom,top,temperature) in enumerate([(32,96,7),(96,128,15)],7):
    geo.append(f'sector {{ heightfloor={bottom}; heightceiling={top}; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; user_ca_water_temperature_defined=1; user_ca_water_temperature_c={temperature}; }}')
    previous=len(geo);x=-15000+(index-7)*256
    polygon([(x,6000),(x,6128),(x+128,6128),(x+128,6000)],index)
    for line in range(previous,len(geo)):
        if geo[line].startswith('linedef'):
            geo[line]=geo[line].replace('}', 'special=160; arg0=1302; arg1=2; arg2=0; arg3=160; }')
            break
geo.append('thing { x=-14000; y=-4000; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
body=bytearray();directory=bytearray()
for key,data in [('QA130G',b''),('TEXTMAP','\n'.join(geo).encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
geo_wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory
manifest['geometry_sha256']=package('geometry.pk3',{
    'maps/QA130G.wad':geo_wad,'MAPINFO':b'map QA130G "Thermal geometry" { }\nGameInfo { AddEventHandlers="CA130Geometry" }\n',
    'ZSCRIPT':b'version "4.14"\n#include "geometry.zs"\n','geometry.zs':(HERE/'geometry.zs').read_bytes()})
(OUT/'checks.cfg').write_text('wait 10; quit\n',encoding='utf-8')
performance=(HERE/'performance.zs').read_text(encoding='utf-8')
for label,observe in [('baseline',''),('current',"""
        let actors=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
        while((body=CaelumCombatActor(actors.Next()))!=null)
        {
            if(body.health<=0 || body.ThermalState==null)continue;
            thermalCount++;harmful+=int(body.ThermalState.Severity>0);exposureSum+=body.ThermalState.Exposure;
        }
""")]:
    manifest[f'performance_{label}_sha256']=package(f'performance-{label}.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n',
        'MAPINFO':b'GameInfo { AddEventHandlers="CA130Performance" }\n',
        'performance.zs':performance.replace('// THERMAL_OBSERVATION',observe).encode()})
stress=performance.replace('// THERMAL_OBSERVATION',observe)
stress=stress.replace('if(level.time%35!=0)return;', 'if(level.time==70)\n        {\n            let it=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor npc;\n            while((npc=CaelumCombatActor(it.Next()))!=null)\n                if(npc.ThermalState!=null)npc.ThermalState.Exposure=-100*CaelumThermalRules.ThresholdScale(npc.ThermalState.Toughness);\n        }\n        if(level.time%35!=0)return;')
manifest['stress_sha256']=package('performance-stress.pk3',{'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n','MAPINFO':b'GameInfo { AddEventHandlers="CA130Performance" }\n','performance.zs':stress.encode()})
(OUT/'performance.cfg').write_text('wait 735; quit\n',encoding='utf-8')
persistence=(HERE/'persistence.zs').read_text(encoding='utf-8')
seed='            let thermal=CaelumThermalBody.Get(user,true);\n            thermal.Exposure=7.25;thermal.Acclimation=1.5;thermal.ActivityWatts=12.5;thermal.DamageRemainder=0.3125;\n            thermal.BaseWaterKg[0]=0.003;thermal.BaseWaterKg[1]=0.004;\n            Console.Printf("CA130 SAVE SEEDED");'
check='            let thermal=CaelumThermalBody.Get(user,true);\n            let again=CaelumThermalBody.Get(user,true);\n            Console.Printf("CA130 SAVE THERMAL E=%.9f accl=%.9f activity=%.9f fraction=%.9f water0=%.9f water1=%.9f revision=%d same=%d",\n                thermal.Exposure,thermal.Acclimation,thermal.ActivityWatts,thermal.DamageRemainder,\n                thermal.BaseWaterKg[0],thermal.BaseWaterKg[1],thermal.Revision,thermal==again && thermal==record.ThermalState);\n            if(thermal!=again || thermal.Revision!=1)Console.Printf("CA130 FAIL save authority");'
for label in ['baseline','current']:
    members={'maps/QA130A.wad':wad,'maps/QA130B.wad':wad.replace(b'QA130A',b'QA130B'),
        'MAPINFO':b'map QA130A "Thermal persistence A" { levelnum=1301 cluster=130 next="QA130B" }\nmap QA130B "Thermal persistence B" { levelnum=1302 cluster=130 next="QA130A" }\ncluster 130 { hub }\nGameInfo { AddEventHandlers="CA130Persistence" }\n',
        'ZSCRIPT':b'version "4.14"\n#include "persistence.zs"\n',
        'persistence.zs':persistence.replace('// THERMAL_SEED',seed if label=='current' else '').replace('// THERMAL_CHECK',check if label=='current' else '').encode()}
    manifest[f'persistence_{label}_sha256']=package(f'persistence-{label}.pk3',members)
(OUT/'save-baseline.cfg').write_text('wait 70; save ca130_baseline; wait 5; quit\n',encoding='utf-8')
(OUT/'save-current.cfg').write_text('wait 70; save ca130_current; wait 5; quit\n',encoding='utf-8')
(OUT/'save-upgrade.cfg').write_text('wait 35; save ca130_upgraded; wait 5; quit\n',encoding='utf-8')
(OUT/'save-control.cfg').write_text('wait 35; save ca130_control; wait 5; quit\n',encoding='utf-8')
(OUT/'save-reload.cfg').write_text('wait 35; save ca130_reloaded; wait 5; quit\n',encoding='utf-8')
(OUT/'save-hub.cfg').write_text('wait 5; changemap QA130B; wait 45; changemap QA130A; wait 45; save ca130_hub; wait 5; quit\n',encoding='utf-8')
(OUT/'save-rollback.cfg').write_text('wait 35; save ca130_rollback; wait 5; quit\n',encoding='utf-8')
ui_members={'ZSCRIPT':b'version \"4.14\"\n#include \"persistence.zs\"\n#include \"ui.zs\"\n','persistence.zs':persistence.replace('// THERMAL_SEED',seed).replace('// THERMAL_CHECK',check).encode(),'ui.zs':(HERE/'ui.zs').read_bytes(),'maps/QA130A.wad':wad,'MAPINFO':b'map QA130A \"Thermal UI\" { }\nGameInfo { AddEventHandlers=\"CA130Persistence\",\"CA130UI\" }\n'}
manifest['ui_sha256']=package('ui.pk3',ui_members)
(OUT/'ui.cfg').write_text('wait 80; ca_journal_open 1; ca_journal_page 2; wait 10; screenshot \"thermal-ui.png\"; wait 5; quit\n',encoding='utf-8')
(OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps(manifest,indent=2))
