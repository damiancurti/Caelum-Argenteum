"""Build deterministic isolated #163 packages and preserve the pre-change runtime."""
from pathlib import Path
import hashlib
import json
import subprocess
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue163'
BASE='dc757efe'

def test_map():
    text='namespace="ZDoom";\n'
    points=((0,0),(0,8192),(8192,8192),(8192,0),(4000,1800),(4032,1800),(4032,2300),(4000,2300))
    for x,y in points:text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(8):
        end=(i+1)%4 if i<4 else 4+(i-3)%4
        text+=f'sidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
    text+='sector { heightfloor=0; heightceiling=256; texturefloor="CMST02"; textureceiling="CMST01"; lightlevel=128; }\n'
    text+='thing { x=2048; y=2048; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }\n'
    lumps=[('CA163',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
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
            'maps/CA163.wad':wad,'maps/CA163B.wad':wad,
            'CVARINFO':b'server int ca163_stage=0;\n',
            'MAPINFO':f'cluster 463 {{ hub }}\nmap CA163 "Bolas validation" {{ cluster=463 }}\nmap CA163B "Bolas hub" {{ cluster=463 }}\nGameInfo {{ AddEventHandlers="CA163{name.title()}" }}\n'.encode()}
        if name=='inputs':
            members['MAPINFO']=members['MAPINFO'].replace(b'AddEventHandlers="CA163Inputs"',b'AddEventHandlers="CA163Inputs", "CA163LoadObserver"')
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
    (OUT/'checks.cfg').write_text('unbindall; wait 90; save ca163-checks; wait 5; quit\n',encoding='utf-8')
    scripts={
        'crafting':'wait 100; quit',
        'regression':'wait 100; quit',
        'visuals':'wait 100; ca163_stage 7; wait 15; screenshot bolas-ready.png; +altattack; wait 40; screenshot bolas-spin.png; +attack; wait 3; screenshot bolas-release.png; wait 5; screenshot bolas-recover.png; -attack; -altattack; wait 10; screenshot bolas-bound.png; wait 200; screenshot bolas-dropped.png; ca163_stage 11; wait 10; screenshot bolas-inventory.png; wait 5; quit',
         'npcs':'wait 260; quit',
        'travel':'unbindall; wait 190; quit',
        'escape':'unbindall; wait 100; ca163_stage 1; +forward; +attack; +reload; wait 20; -attack; -forward; ca163_stage 2; wait 20; -reload; wait 5; ca163_stage 3; +reload; wait 18; save ca163-cutting; wait 5; -reload; wait 90; ca163_stage 4; wait 10; quit',
        'escape-reload':'wait 5; ca163_stage 9; -attack; -forward; -reload; wait 100; quit',
        'legacy-create':'wait 65; save ca163-legacy; wait 5; quit',
        'legacy-reload':'wait 30; ca163_stage 12; wait 35; save ca163-migrated; wait 5; quit',
        'legacy-again':'wait 30; ca163_stage 13; wait 35; quit',

        'inputs':'unbindall; wait 100; screenshot bolas-ready.png; ca163_stage 1; +altattack; wait 35; ca163_stage 2; wait 70; screenshot bolas-spin.png; save ca163-prepared; wait 5; ca163_stage 3; -altattack; wait 10; +altattack; wait 10; ca163_stage 4; +attack; wait 3; screenshot bolas-release.png; wait 4; screenshot bolas-recover.png; -attack; -altattack; wait 80; +altattack; wait 40; ca163_stage 5; +attack; wait 5; -attack; -altattack; wait 30; screenshot bolas-bound.png; save ca163-attached; wait 190; ca163_stage 6; wait 20; screenshot bolas-dropped.png; wait 5; quit',
        'prepared-reload':'-altattack; wait 5; ca163_stage 9; wait 10; -altattack; wait 5; quit',
        'attached-reload':'wait 5; ca163_stage 10; wait 200; quit',
        'preview':'wait 100; ca163_stage 7; -altattack; wait 10; screenshot bolas-author.png',
    }
    for name,commands in scripts.items():
        (OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Prepared #163 native packages:',manifest)

if __name__=='__main__':main()
