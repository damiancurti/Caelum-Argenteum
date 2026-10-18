"""Run isolated house-hub checks serially and stop on the first failure."""
from pathlib import Path
import argparse
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory', required=True)
p.add_argument('--cases', default='smoke,fresh,save,reload,return,deploy,portals')
a = p.parse_args()
for case in a.cases.split(','):
    command = [sys.executable, str(HERE/'run.py'), '--directory', a.directory,
               '--variant', 'current', '--label', case+'-01', '--fixture', 'checks.pk3',
               '--script', f'build/{a.directory}/current/{case}.cfg',
               '--global-presentmon', '--timeout', '300']
    if case in ('reload', 'return'):
        command += ['--load', 'house-state.zds' if case=='reload' else 'city-state.zds']
    subprocess.run(command, cwd=ROOT, check=True)
