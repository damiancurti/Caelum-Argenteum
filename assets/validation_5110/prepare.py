"""Build isolated SI/growth fixtures and reuse the recorded native runner."""
from pathlib import Path
import hashlib
import argparse
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue154'


def room():
    text='namespace="ZDoom";\n'
    for x,y in ((-30000,-30000),(-30000,30000),(30000,30000),(30000,-30000)):
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(4):
        text+=f'sidedef {{ sector=0; texturemiddle="CMST01"; }}\n'
        text+=f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
    text+='sector { heightfloor=0; heightceiling=4096; texturefloor="CMST02"; textureceiling="CMST01"; lightlevel=224; }\n'
    text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }\n'
    payload=b'';directory=b''
    for name,data in [('CA154',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(payload),len(data),name.encode().ljust(8,b'\0'))
        payload+=data
    return struct.pack('<4sii',b'PWAD',3,12+len(payload))+payload+directory


def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--production',action='store_true')
    args=parser.parse_args()
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish the current native run first.')
    OUT.mkdir(exist_ok=True)
    if args.production:
        package(OUT/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes()
                                    for p in (ROOT/'src').rglob('*') if p.is_file()})
    for kind in ('baseline','checks','movement','projectiles','persistence','thermal','hazards','launchers','hub','traversal'):
        source=HERE/(kind+'.zs')
        if not source.exists():continue
        package(OUT/(kind+'-addon.pk3'),{
            'maps/CA154.wad':room(),
            'MAPINFO':('map CA154 "SI validation" {}\nGameInfo { AddEventHandlers="CA154'+kind.title()+'" }\n').encode(),
            'ZSCRIPT':b'version "4.14"\n#include "fixture.zs"\n',
            'fixture.zs':source.read_bytes(),
            'CVARINFO':b'server int ca154_stage=0;\n'})
    for p in HERE.glob('*.cfg'):(OUT/p.name).write_bytes(p.read_bytes())
    runner=(ROOT/'assets/validation_519/run_native.ps1').read_text(encoding='utf-8')
    runner=runner.replace('issue152','issue154').replace("'CA152'","'CA154'")
    (HERE/'run_native.ps1').write_text(runner,encoding='utf-8',newline='\n')
    print('Prepared #154 isolated room, fixtures and native runner.')


if __name__=='__main__':main()
