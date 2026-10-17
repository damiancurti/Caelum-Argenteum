"""Run contact heat and genuine legacy-save checks sequentially, retaining failures."""
from pathlib import Path
import argparse
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True)
a=p.parse_args()
work=ROOT/'build'/a.directory
def run(label,script,mode='current',save=None):
    command=[sys.executable,str(Path(__file__).with_name('run.py')),'--directory',a.directory,
             '--variant',mode,'--label',label,'--map','MAP99','--fixture','contact.pk3',
             '--script',str(work/(script+'.cfg')),'--global-presentmon']
    if save:command+=['--load',str(work/mode/save)]
    subprocess.run(command,cwd=ROOT,check=True)

run('contact-01','contact')
run('status-01','status')
run('queue-01','queue')
run('player-01','player')
run('save-01','save')
run('load-01','load',save='contact.zds')
run('reload-01','load',save='repeated.zds')
run('consume-01','consume',save='contact.zds')
run('hub-01','hub',save='contact.zds')
run('legacy-01','legacy','legacy')
assert not (work/'current'/'legacy.zds').exists()
shutil.copyfile(work/'legacy'/'legacy.zds',work/'current'/'legacy.zds')
run('upgrade-01','upgrade',save='legacy.zds')
run('upgrade-repeat-01','upgrade',save='upgraded.zds')
