"""Final contact-heat runtime: matched 1000-attacker onset and peaceful controls."""
from pathlib import Path
import argparse
import subprocess
import sys

p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2]
plans=[('army1000-base','army1000-final-01',['--phase','1','--site','4','--warmup','70','--window','175']),
       ('army1000-base','army1000-final-02',['--phase','1','--site','4','--warmup','70','--window','175']),
       ('army1000-profile-deep','army1000-final-profile',['--phase','1','--site','4','--warmup','70','--window','175']),
       ('base','city-final-front',['--site','1','--pitch','0']),
       ('base','city-final-down',['--site','1','--pitch','75']),
       ('army1000-base','army1000-skip-01',['--phase','3','--site','4','--warmup','70','--window','175'])]
for variant,label,extra in plans:
    subprocess.run([sys.executable,str(Path(__file__).with_name('run.py')),'--directory',a.directory,
                    '--variant',variant,'--label',label,'--global-presentmon']+extra,cwd=root,check=True)
