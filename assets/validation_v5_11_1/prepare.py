"""Deterministic formation fixture and focused native iteration overlay."""
from pathlib import Path
import importlib.util
import subprocess
import zipfile
import struct
import argparse

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue429'
OUT.mkdir(parents=True, exist_ok=True)
parser=argparse.ArgumentParser()
parser.add_argument('--full',action='store_true',help='Package fixtures only; use the complete development PK3.')
args=parser.parse_args()
spec = importlib.util.spec_from_file_location('accepted_room', ROOT / 'assets/validation_5103/prepare.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
def passage():
    points=[(-1024,-384),(-192,-384),(-192,-32),(192,-32),(192,-384),(1024,-384),
            (1024,384),(192,384),(192,32),(-192,32),(-192,384),(-1024,384)]
    text='namespace="ZDoom";\n'
    text+=''.join(f'vertex{{x={x};y={y};}}\n' for x,y in points)
    text+='sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}\n'
    text+='sidedef{sector=0;texturemiddle="STARTAN3";}\n'
    text+=''.join(f'linedef{{v1={(i+1)%len(points)};v2={i};sidefront=0;blocking=true;}}\n' for i in range(len(points)))
    text+='thing{x=-900;y=300;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}\n'
    lumps=[('MAP01',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    body=bytearray();directory=bytearray()
    for name,data in lumps:
        directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode());body+=data
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory
files = {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n#include "movement.zs"\n',
    'checks.zs': (Path(__file__).parent / 'checks.zs').read_bytes(),
    'movement.zs': (Path(__file__).parent / 'movement.zs').read_bytes(),
    'maps/CA429A.wad': prior.room(),
    'maps/CA429B.wad': passage(),
    'MAPINFO': b'GameInfo { AddEventHandlers="CA429Checks","CA429Movement" }\nmap CA429A "Formation checks" { }\nmap CA429B "Formation passage" { }\n',
}
names = subprocess.check_output(['git','diff','--name-only','--','src'],cwd=ROOT,text=True).splitlines()
names += subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
for name in ([] if args.full else sorted(set(names))):
    if name != 'src/ZSCRIPT':
        files[name[4:]] = (ROOT / name).read_bytes()
if not args.full:
    files['caelum/world/CaelumPortData.zs'] = (ROOT / 'src/caelum/world/CaelumPortData.zs').read_bytes() + b'\n#include "caelum/data/CaelumFormationData.zs"\n#include "caelum/world/CaelumFormation.zs"\n'
with zipfile.ZipFile(OUT / ('checks-full.pk3' if args.full else 'checks.pk3'),'w',zipfile.ZIP_STORED) as archive:
    for name, data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared formation iteration. Final evidence requires a complete package.')
