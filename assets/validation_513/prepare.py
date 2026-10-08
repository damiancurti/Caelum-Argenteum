"""Build isolated, deterministic #133 engine probes; never package fixtures."""
from pathlib import Path
import hashlib
import json
import subprocess
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue133'


def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256((OUT/name).read_bytes()).hexdigest()


def test_map():
    text='namespace="ZDoom";\n'
    for x,y in ((0,0),(0,8192),(8192,8192),(8192,0)):
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(4):
        text+=f'sidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
    text+='sector { heightfloor=0; heightceiling=256; texturefloor="CMST02"; textureceiling="CMST01"; lightlevel=224; }\n'
    text+='thing { x=2048; y=4096; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }\n'
    lumps=[('CA133',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    payload=b'';directory=b''
    for name,data in lumps:
        directory+=struct.pack('<ii8s',12+len(payload),len(data),name.encode().ljust(8,b'\0'));payload+=data
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(payload))+payload+directory


if __name__=='__main__':
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Wait for the native engine before replacing packages.')
    OUT.mkdir(exist_ok=True)
    manifest={'production':package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
    for name in ('checks','routes','trade','carbine','factories','visual','furniture','obstruction'):
        members={'ZSCRIPT':f'version "4.14"\n#include "{name}.zs"\n'.encode(),name+'.zs':(HERE/(name+'.zs')).read_bytes(),'MAPINFO':f'GameInfo {{ AddEventHandlers = "CA133{name.title()}" }}\n'.encode()}
        if name=='carbine':
            members['maps/CA133.wad']=test_map()
            members['MAPINFO']+=b'map CA133 "Isolated carbine validation" { levelnum=133 sky1="SKY1" }\n'
        if name=='visual':members['CVARINFO']=b'server int ca133_view=0; server int ca133_angle=0; server int ca133_pose=0;\n'
        if name=='trade':members['MAPINFO']=b'GameInfo { AddEventHandlers="CA133Trade", "CA133TradePersistence" }\n'
        manifest[name]=package(name+'.pk3',members)
    (OUT/'checks.cfg').write_text('wait 1420; quit\n',encoding='utf-8')
    (OUT/'routes.cfg').write_text('wait 26300; quit\n',encoding='utf-8')
    (OUT/'trade.cfg').write_text('wait 120; quit\n',encoding='utf-8')
    (OUT/'carbine.cfg').write_text('wait 2530; quit\n',encoding='utf-8')
    (OUT/'furniture.cfg').write_text('wait 1800; quit\n',encoding='utf-8')
    (OUT/'obstruction.cfg').write_text('wait 1760; quit\n',encoding='utf-8')
    (OUT/'visual.cfg').write_text('bind space +use; bind f8 chase; bind f9 toggleconsole; wait 31500; quit\n',encoding='utf-8')
    (OUT/'visual-interactive.cfg').write_text('bind space +use; bind f8 chase; bind f9 toggleconsole\n',encoding='utf-8')
    (OUT/'fixture-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
