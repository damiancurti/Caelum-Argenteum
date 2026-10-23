"""Run the focused final native suite sequentially on one frozen #487 package."""
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
CASES=[
    ('network02','network','CARESRC',''),
    ('mansion-es02','es','MAP01',''),
    ('city-en02','enu','MAP03',''),
    ('old-upgrade02','upgrade','','ca486-original.zds'),
    ('reload02','placement','','ca487-current.zds'),
    ('removed-save02','removed-save','MAP01',''),
    ('removed-load02','removed-load','','ca487-removed.zds'),
    ('blocked-save02','blocked-save','MAP03',''),
    ('blocked-load02','blocked-load','','ca487-blocked.zds'),
    ('collision03','collision','MAP03',''),
    ('views02','views','MAP03',''),
]
if __name__=='__main__':
    subprocess.run(['python',str(HERE/'prepare.py')],cwd=ROOT,check=True)
    for label,script,start,load in CASES:
        args=['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(HERE/'run_native.ps1'),'-Label',label,'-Checks','-Script',script]
        args+=['-LoadGame',load] if load else ['-StartMap',start]
        print(f'Running {label}',flush=True)
        subprocess.run(args,cwd=ROOT,check=True)
