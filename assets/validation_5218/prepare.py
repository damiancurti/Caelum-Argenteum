"""Build isolated #209 map/fixtures; never package test geometry in src."""
from pathlib import Path
import hashlib
import json
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue209'

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def room():
    text='namespace="ZDoom";\n'
    for x,y in [(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]:
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    text+='sector { heightfloor=0; heightceiling=256; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }\n'
    for i in range(4):
        text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
        text+=f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
    text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }\n'
    lumps=[('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    data=b'';directory=b''
    for name,payload in lumps:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode())
        data+=payload
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(data))+data+directory

def main():
    running=subprocess.check_output(['powershell','-NoProfile','-Command',
        'Get-CimInstance Win32_Process -Filter "Name=\'gzdoom.exe\'" | Select-Object -ExpandProperty ProcessId'],text=True)
    if running.strip():raise SystemExit('Finish the current engine run before packaging.')
    WORK.mkdir(exist_ok=True)
    baseline=WORK/'baseline.pk3'
    if not baseline.exists():
        subprocess.run(['git','archive','--format=zip',f'--output={baseline}','fca87921:src'],check=True,cwd=ROOT)
    manifest={'baseline':hashlib.sha256(baseline.read_bytes()).hexdigest()}
    manifest['production']=package(WORK/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    manifest['fixture']=package(WORK/'fixture.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "checks/fixture.zs"\n',
        'checks/fixture.zs':(HERE/'fixture.zs').read_bytes(),
        'maps/MAP99.wad':room(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA209Fixture" PlayerClasses="CA209Player" }\nmap MAP99 "Appearance fixture" { next="MAP99" sky1="SKY1", 0 }\n'})
    for p in HERE.glob('*.cfg'):(WORK/p.name).write_bytes(p.read_bytes())
    (WORK/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
    print('Prepared #209 production, baseline and isolated fixture.')

if __name__=='__main__':main()
