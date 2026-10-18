"""Run one frozen house-door fixture at a time, preserving native autosaves."""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
args=parser.parse_args()
assert args.directory.startswith('issue334-') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory)
folder=ROOT/'build'/args.directory
runner=ROOT/'assets/validation_5422/run_native.ps1'

def run(label,mapname='MAP03',save=None):
    command=['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(runner),'-Directory',args.directory,'-Label',label,'-Script',label+'.cfg','-Map',mapname]
    if save:command+=['-LoadGame',save]
    subprocess.run(command,cwd=ROOT,check=True)

for label in ('normal1','normal3','vehicle4-1','vehicle4-0','vehicle3-1','vehicle3-0'):
    run(label,'MAP03' if label.startswith('normal') else 'TCOAST')
    snapshot=folder/'private-saves'/label;snapshot.mkdir(parents=True,exist_ok=False)
    for path in folder.glob('*.zds'):shutil.copyfile(path,snapshot/path.name)
    if label=='normal1':
        found=set()
        for path in snapshot.glob('*.zds'):
            with zipfile.ZipFile(path) as z:mapname=json.loads(z.read('info.json'))['Current Map']
            if mapname not in ('CAH000','MAP03'):continue
            side='inside' if mapname=='CAH000' else 'outside';found.add(side)
            shutil.copyfile(path,folder/(side+'.zds'))
            (folder/('load-'+side+'.cfg')).write_text(f'wait 70; netevent c334_loaded {int(mapname=="MAP03")}; wait 5; netevent c282_done; wait 5; quit\n',encoding='utf-8')
        assert found=={'inside','outside'},found
for side in ('inside','outside'):run('load-'+side,save=side+'.zds')
