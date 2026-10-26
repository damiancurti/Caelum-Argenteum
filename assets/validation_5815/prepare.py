"""Prepare private native bag-clearance checks; do not rewrite a running fixture."""
from pathlib import Path
import importlib.util
import subprocess
import re
import sys
import zipfile
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue412-bags'
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    obj=importlib.util.module_from_spec(spec);spec.loader.exec_module(obj);return obj
def main():
    active=subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True)
    if active.stdout.strip():raise RuntimeError('Close GZDoom before regenerating fixtures.')
    WORK.mkdir(parents=True,exist_ok=True)
    placement=module('placement',ROOT/'assets/validation_588/prepare.py')
    wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
    room=placement.room().replace('texturefloor="CMST01"','texturefloor="CMGR01A"',1)
    members={'ZSCRIPT':b'version "4.14"\n#include "deploy.zs"\n#include "guard.zs"\n#include "checks.zs"\n',
        'deploy.zs':(ROOT/'assets/validation_588/deploy/checks.zs').read_bytes(),
        'guard.zs':(ROOT/'assets/validation_5810/checks.zs').read_bytes(),
        'checks.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo {AddEventHandlers="CA412BagChecks","CA412Checks"}\ncluster 8515 {hub}\nmap MAP01 "Tent clearance" {cluster=8515}\nmap CDEP411 "Rest checks" {cluster=8515}\n',
        'maps/MAP01.wad':wad(room,'MAP01'),'maps/CDEP411.wad':wad(room,'CDEP411')}
    model=re.search(r'Model CaelumRestBag\s*\{[^}]*\}',(ROOT/'src/MODELDEF').read_text(encoding='utf-8')).group()
    members['MODELDEF']=model.replace('Model CaelumRestBag','Model CA412PreviewBag').encode()
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as out:
        for name,data in sorted(members.items()):out.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    start='wait 35; netevent ca412b_setup; +crouch; wait 16; netevent ca412b_inside; -crouch; wait 8; '
    commands={
        'core':'wait 35; netevent ca412b_setup; +crouch; wait 16; netevent ca412b_inside; wait 3; netevent ca412b_core; -crouch; wait 3; quit',
        'rest':start+'netevent ca412b_rest; wait 70; netevent ca412b_follow; wait 3; quit',
        'fast':start+'netevent ca412b_rest; wait 2; netevent ca412b_fast; wait 2; netevent ca412b_follow; wait 3; quit',
        'seed':start+'netevent ca412b_rest; wait 35; save ca412b-ready; wait 3; quit',
        'load':'wait 35; netevent ca412b_follow; wait 3; quit',
        'guard':'wait 35; netevent ca412_guard; wait 3; quit',
        'capture':start+'netevent ca412b_rest; wait 35; netevent ca412b_preview; wait 5; screenshot tent-bag.png; wait 3; quit',
        'manual':start+'bind F1 "netevent ca412b_inside"; bind F2 "netevent ca412b_rest"; bind F3 "netevent ca412b_cancel"; bind F4 "netevent ca412b_read; toggleconsole";',
    }
    for name,text in commands.items():(WORK/(name+'.cfg')).write_text(text+'\n',encoding='utf-8')
    with zipfile.ZipFile(WORK/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as out:
        for name,data in sorted({'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n',
            'legacy.zs':(HERE/'legacy.zs').read_bytes(),'MAPINFO':b'GameInfo {AddEventHandlers="CA412BagLegacy"}\nmap CDEP411 "Legacy bag rest" {}\n',
            'maps/CDEP411.wad':wad(room,'CDEP411')}.items()):out.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    for mode in ('seed','check'):
        (WORK/('old-'+mode+'.cfg')).write_text('wait 70; netevent ca412b_old_'+mode+'; '+('save ca412b-old; ' if mode=='seed' else '')+'wait 3; quit\n',encoding='utf-8')
    for expected in (0,1):
        (WORK/f'compare{expected}.cfg').write_text(f'wait 35; netevent ca412b_fit_setup; +crouch; wait 16; netevent ca412b_fit {expected}; wait 3; quit\n',encoding='utf-8')
if __name__=='__main__':main()
