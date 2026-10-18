"""Run fixed reference-city views sequentially after prepare_city_example.py.

Use --directory for one prepared city. No campaign or external map is modified.
The normal run guard retains an already open GZDoom and refuses overlap.
"""
from pathlib import Path
import argparse
import json
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True)
p.add_argument('--kind',choices=['bigcity','hgc'],required=True)
a=p.parse_args()
for case in json.loads((HERE/'city_cases.json').read_text())['cases']:
    if case['kind']!=a.kind:continue
    commands='ca318_fixed true; '+'; '.join(f'ca318_{key} {case[key]}' for key in ('x','y','yaw'))
    subprocess.run([sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant','original',
        '--map','OPENCITY' if a.kind=='bigcity' else 'MAP01','--label',case['label'],
        '--pitch',str(case['pitch']),'--commands',commands,'--postwait','210','--global-presentmon'],cwd=ROOT,check=True)
