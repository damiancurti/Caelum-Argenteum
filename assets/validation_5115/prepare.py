"""Build deterministic isolated #162 packages and preserve the pre-change runtime."""
from pathlib import Path
import hashlib
import json
import subprocess
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue162'
BASE='1fba4157'

def test_map():
    text='namespace="ZDoom";\n'
    points=((0,0),(0,8192),(8192,8192),(8192,0),(4000,1800),(4032,1800),(4032,2300),(4000,2300))
    for x,y in points:text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(8):
        end=(i+1)%4 if i<4 else 4+(i-3)%4
        text+=f'sidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
    text+='sector { heightfloor=0; heightceiling=256; texturefloor="CMST02"; textureceiling="CMST01"; lightlevel=128; }\n'
    text+='thing { x=2048; y=2048; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }\n'
    lumps=[('CA162',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    payload=b'';directory=b''
    for name,data in lumps:
        directory+=struct.pack('<ii8s',12+len(payload),len(data),name.encode().ljust(8,b'\0'));payload+=data
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(payload))+payload+directory

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    wad=test_map()
    manifest={}
    for source in sorted(HERE.glob('*.zs')):
        name=source.stem
        members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':source.read_bytes(),
            'maps/CA162.wad':wad,'maps/CA162B.wad':wad,
            'CVARINFO':b'server int ca162_stage=0;\n',
            'MAPINFO':f'cluster 462 {{ hub }}\nmap CA162 "Utility staff validation" {{ cluster=462 }}\nmap CA162B "Utility staff hub" {{ cluster=462 }}\nGameInfo {{ AddEventHandlers="CA162{name.title()}" }}\n'.encode()}
        manifest[name]=package(OUT/(name+'.pk3'),members)
    # Current source overlays accepted package: unchanged assets stay byte-identical.
    if not (OUT/'baseline.pk3').exists():
        subprocess.run(['git','archive','--format=zip',f'--output={OUT / "baseline.pk3"}',BASE+':src'],cwd=ROOT,check=True)
    with zipfile.ZipFile(OUT/'baseline.pk3') as z:
        baseline={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
    changed={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*')
             if p.is_file() and baseline.get(p.relative_to(ROOT/'src').as_posix())!=p.read_bytes()}
    baseline.update(changed)
    manifest['production']=package(OUT/'production.pk3',baseline)
    (OUT/'compile.cfg').write_text('wait 45; quit\n',encoding='utf-8')
    (OUT/'checks.cfg').write_text('unbindall; wait 90; save ca162-checks; wait 5; quit\n',encoding='utf-8')
    scripts={
        'crafting':'wait 100; quit',
        'demon':'wait 140; quit',
        'checks-reload':'wait 30; ca162_stage 15; wait 30; quit',
        'preview':'wait 100; screenshot preview.png',
        'equip':'wait 40; screenshot equip-40.png; wait 5; screenshot equip-45.png; wait 5; screenshot equip-50.png; wait 5; screenshot equip-55.png; wait 5; screenshot equip-60.png; wait 5; quit',
        'visuals':'wait 25; screenshot equip.png; wait 75; ca162_stage 10; wait 10; screenshot empty-ready.png; +attack; wait 40; screenshot empty-fire.png; -attack; wait 5; screenshot empty-release.png; +altattack; wait 40; screenshot empty-ice.png; -altattack; wait 5; ca162_stage 16; wait 10; screenshot wall-ready.png; +attack; wait 35; screenshot wall-fire.png; -attack; wait 5; screenshot wall-off.png; ca162_stage 14; wait 10; screenshot inventory.png; wait 5; quit',
        'inputs':'unbindall; wait 100; screenshot ready.png; ca162_stage 1; +attack; wait 400; screenshot fire.png; save ca162-firing; wait 5; ca162_stage 2; -attack; wait 10; screenshot released.png; ca162_stage 3; +altattack; wait 400; screenshot ice.png; ca162_stage 4; +attack; wait 70; ca162_stage 5; wait 10; ca162_stage 6; wait 10; ca162_stage 7; wait 10; ca162_stage 8; wait 30; -altattack; ca162_stage 9; wait 80; quit',
        'inputs-reload':'wait 30; -attack; -altattack; ca162_stage 11; wait 30; quit',
        'legacy-create':'wait 65; save ca162-legacy; wait 5; quit',
        'legacy-reload':'wait 30; ca162_stage 12; wait 35; save ca162-migrated; wait 5; quit',
        'legacy-again':'wait 30; ca162_stage 13; wait 35; quit',
        'legacy-rollback':'wait 60; quit',
        'travel':'unbindall; wait 100; +attack; wait 100; +attack; wait 100; +attack; wait 100; -attack; wait 40; quit',
        'lifecycle':'wait 200; quit',
    }
    for name,commands in scripts.items():
        (OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Prepared #162 native packages:',manifest)

if __name__=='__main__':main()
