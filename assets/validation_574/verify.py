"""Run the focused final native suite sequentially against the frozen package."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue470'


def main():
    subprocess.run([sys.executable,str(HERE/'prepare.py')],cwd=ROOT,check=True)
    originals=OUT/'original-saves.json'
    if not originals.exists():
        names=['ca470-legacy.zds','ca470-city-legacy.zds','ca470-task.zds']
        originals.write_text(json.dumps({n:hashlib.sha256((OUT/n).read_bytes()).hexdigest() for n in names},indent=2)+'\n',encoding='utf-8')
    (OUT/'task-current-save.cfg').write_text((OUT/'task-save.cfg').read_text().replace('save ca470-task;','save ca470-task-current;'),encoding='utf-8')
    plans=[
        ('network','network',[]),('crafting','crafting',[]),
        ('upgrade-mansion','upgrade',['-Addon','upgrade/legacy-checks.pk3','-LoadGame','ca470-legacy.zds']),
        ('upgrade-city','placement',['-Addon','upgrade/legacy-checks.pk3','-LoadGame','ca470-city-legacy.zds']),
        ('upgrade-load','placement',['-Addon','upgrade/legacy-checks.pk3','-LoadGame','ca470-upgraded.zds']),
        ('travel','travel',['-StartMap','MAP01']),
        ('blocked-save','blocked-save',['-StartMap','MAP01']),
        ('blocked-load','blocked-load',['-LoadGame','ca470-blocked.zds']),
        ('removed-save','removed',['-StartMap','MAP01']),
        ('removed-load','removed-load',['-LoadGame','ca470-removed.zds']),
        ('task-upgrade','task-load',['-Addon','upgrade/legacy-checks.pk3','-LoadGame','ca470-task.zds']),
        ('manual-mansion','manual-smoke',['-StartMap','MAP01','-Visible']),
        ('manual-city','manual-smoke',['-StartMap','MAP03','-Visible']),
        ('task-current-save','task-current-save',[]),
        ('task-current-load','task-load',['-LoadGame','ca470-task-current.zds']),
    ]
    for label,script,extra in plans:
        subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(HERE/'run_native.ps1'),
            '-Label','verified-'+label,'-Script',script,'-Checks',*extra],cwd=ROOT,check=True)
        if label.startswith('manual-'):
            site=label.removeprefix('manual-')
            for kind in ('view','menu'):shutil.copy2(OUT/f'station-{kind}.png',OUT/f'{site}-{kind}.png')


if __name__=='__main__':main()
