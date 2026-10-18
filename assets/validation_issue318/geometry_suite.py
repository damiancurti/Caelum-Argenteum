"""Matched conservative-geometry tests and explicitly non-equivalent closure control."""
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
for pitch in (0,75):
    for i,mode in enumerate(('base','safe','safe','base','closed-interiors')):
        args=[sys.executable,str(Path(__file__).with_name('run.py')),'--directory','issue318-geometry-01',
              '--variant','base','--label',f'geometry-{pitch}-{i+1}-{mode}',
              '--site','1','--pitch',str(pitch),'--postwait','210','--global-presentmon']
        if mode!='base':args+=['--addon',f'build/issue318-geometry-01/{mode}.pk3']
        subprocess.run(args,cwd=ROOT,check=True)
