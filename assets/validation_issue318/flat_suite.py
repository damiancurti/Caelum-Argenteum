"""Run flat controls sequentially; abort on failure and preserve all evidence."""
from pathlib import Path
import argparse
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
p.add_argument('--part',choices=['combat','controls','sustained'],required=True);a=p.parse_args()
base=f'build/{a.directory}/current'
if a.part=='combat':
    plans=[('current','sprites-01',False,False,175),('current','models-02',True,False,175),
           ('current','models-03',True,False,175),('current','sprites-04',False,False,175)]
elif a.part=='controls':
    plans=[('current','frozen-sprites-01',False,True,350),('current','frozen-models-02',True,True,350),
           ('current','frozen-models-03',True,True,350),('current','frozen-sprites-04',False,True,350),
           ('profile','combat-profile',False,False,175)]
else:
    plans=[('current','sustained-sprites',False,False,1050),('current','sustained-models',True,False,1050),
           ('current','sustained-empty-sprites',False,False,1050),('current','sustained-empty-models',True,False,1050)]
for variant,label,model,freeze,window in plans:
    cmd=[sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant',variant,'--label',label,
         '--map','MAP98','--warmup','35','--window',str(window),'--timeout','240','--postwait','70','--global-presentmon']
    if model:cmd+=['--addon',base+'/domingo.pk3']
    if freeze:cmd+=['--addon2',base+'/freeze.pk3']
    if 'empty' in label:cmd+=['--addon2',base+'/no-inventory.pk3']
    subprocess.run(cmd,cwd=ROOT,check=True)
