"""Private native campfire checks; reuse the accepted placement fixture."""
from pathlib import Path
import importlib.util
import sys
import subprocess
import zipfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue411-fire'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

def main():
    active=subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True)
    if active.stdout.strip():raise RuntimeError('Close GZDoom before regenerating its fixture archive.')
    WORK.mkdir(parents=True, exist_ok=True)
    placement = module('placement', ROOT/'assets/validation_588/prepare.py')
    wad = module('water', ROOT/'assets/validation_580/prepare.py')
    room = placement.room().replace('texturefloor="CMST01"', 'texturefloor="CMGR01A"', 1)
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs': (HERE/'checks.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA411FireChecks" }\ncluster 8513 {hub}\nmap MAP01 "Campfire checks" {cluster=8513}\nmap CFIR411 "Camp return" {cluster=8513}\n',
        'maps/MAP01.wad': wad.wad(room, 'MAP01'),
        'maps/CFIR411.wad': wad.wad(room, 'CFIR411'),
    }
    with zipfile.ZipFile(WORK/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), data)
    scripts = {
        'core': 'wait 35; netevent ca411f_core; wait 5; quit',
        'seed': 'wait 35; netevent ca411f_seed; save ca411f-ready; wait 5; quit',
        'load': 'wait 5; netevent ca411f_load; wait 5; quit',
        'hub': 'wait 5; netevent ca411f_load; changemap CFIR411; wait 35; netevent ca411f_away; changemap MAP01; wait 35; netevent ca411f_return; wait 5; quit',
        'taskseed': 'wait 35; netevent ca411f_taskseed; save ca411f-task; wait 5; quit',
        'taskload': 'wait 5; netevent ca411f_taskload; wait 5; quit',
        'pot': 'wait 35; netevent ca411f_pot; wait 5; quit',
        'potseed': 'wait 35; netevent ca411f_potseed; save ca411f-pot; wait 5; quit',
        'potload': 'wait 5; netevent ca411f_potload; wait 5; quit',
        'capture': 'wait 35; netevent ca411f_potseed; wait 35; netevent ca411f_camera; wait 5; screenshot fire-world.png; netevent ca411f_visual_lit; wait 10; screenshot fire-lit.png; netevent ca411f_menu; wait 10; screenshot fire-menu.png; wait 5; quit',
        'wait': 'wait 35; netevent ca411f_wait; wait 5; quit',
        'ui': 'wait 35; netevent ca411f_ui_start; wait 5; netevent ca_camp_fire_action 1; wait 5; netevent ca411f_ui_complete; wait 5; quit',
        'manual': 'exec ../../assets/playtest/default_controls.cfg; wait 35; netevent ca411f_manual; bind F1 "netevent ca411f_ui_start"; bind F2 "netevent ca411f_read; toggleconsole"; bind F3 "netevent ca411f_minute"; bind F4 "netevent ca411f_boiled"',
    }
    for name, script in scripts.items():
        (WORK/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
    with zipfile.ZipFile(WORK/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,data in sorted({'ZSCRIPT':b'version \"4.14\"\n#include \"legacy.zs\"\n','legacy.zs':(HERE/'legacy.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers=\"CA411FireLegacy\" }\n'}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    (WORK/'old-seed.cfg').write_text('wait 35; netevent ca411f_old_seed; save ca411f-old; wait 5; quit\n',encoding='utf-8')
    (WORK/'old-check.cfg').write_text('wait 70; netevent ca411f_old_check; wait 35; quit\n',encoding='utf-8')

if __name__ == '__main__':
    main()
