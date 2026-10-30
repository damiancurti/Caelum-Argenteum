"""Compare the shared climate path with the exact accepted surface implementation."""
from pathlib import Path
import subprocess
import zipfile
import argparse
p=argparse.ArgumentParser();p.add_argument("--full",action="store_true");args=p.parse_args()

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue432'
OUT.mkdir(parents=True,exist_ok=True)
name='caelum/survival/CaelumContaminationSurface.zs'
old=subprocess.check_output(['git','show','d1ae50345:src/'+name],cwd=ROOT).decode('utf-8')
old=old[:old.index('// La espera usa copias')].replace('class CaelumContaminationTile :','class CA432LegacyTile :',1)
files={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
    'legacy.zs':old.encode(),'checks.zs':(Path(__file__).parent/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA432Checks" }\n',name:(ROOT/'src'/name).read_bytes()}
for extra in ('caelum/actors/CaelumCombatActor.zs','caelum/actors/CaelumVisualPerception.zs'):
    files[extra]=(ROOT/'src'/extra).read_bytes()
if args.full:
    files={key:value for key,value in files.items() if not key.startswith('caelum/')}
with zipfile.ZipFile(OUT/('checks-full.pk3' if args.full else 'checks.pk3'),'w',zipfile.ZIP_STORED) as archive:
    for path,data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(path,(2000,1,1,0,0,0)),data)
print('Prepared exact-reference native surface comparison.')
