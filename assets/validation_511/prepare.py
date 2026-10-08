"""Deterministic isolated #131 native fixtures; no test data is packaged in src."""
from pathlib import Path
import hashlib
import io
import json
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue131'
BASE='524baaf0da4e385c81c54823ff5938921538652b'
if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish native runs before replacing packages.')
OUT.mkdir(exist_ok=True)


def package(name,members):
    path=OUT/name
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


manifest={'baseline_commit':BASE}
manifest['production']=package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
if not (OUT/'baseline.pk3').exists():
    raw=subprocess.check_output(['git','archive','--format=zip',BASE,'src'],cwd=ROOT)
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        package('baseline.pk3',{n.removeprefix('src/'):z.read(n) for n in z.namelist() if not n.endswith('/')})
manifest['baseline']=hashlib.sha256((OUT/'baseline.pk3').read_bytes()).hexdigest()
text='namespace="ZDoom";\nsector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }\n'
for i,(x,y) in enumerate([(-2048,-2048),(-2048,2048),(2048,2048),(2048,-2048)]):
    text+=f'vertex {{ x={x}; y={y}; }}\nsidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
text+='thing { x=512; y=512; angle=0; type=2; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
body=bytearray();directory=bytearray()
for key,data in [('QA131A',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory
for name,handler in [('checks','CA131Checks'),('visual','CA131Visual'),('viewed','CA131Viewed')]:
    if not (HERE/f'{name}.zs').exists():continue
    members={'maps/QA131A.wad':wad,'MAPINFO':f'map QA131A "Thermal HUD verification" {{ }}\nGameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
        'ZSCRIPT':f'version "4.14"\n#include "{name}.zs"\n'.encode(),f'{name}.zs':(HERE/f'{name}.zs').read_bytes(),
        'CVARINFO':b'server int ca131_case=0;\n'}
    manifest[name]=package(name+'.pk3',members)
(OUT/'checks.cfg').write_text('wait 60; quit\n',encoding='utf-8')
(OUT/'visual.cfg').write_text('wait 80; screenshot "ca131-normal.png"; wait 5; quit\n',encoding='utf-8')
exec((HERE/'prepare_saves.py').read_text(),globals())
(OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps(manifest,indent=2))
