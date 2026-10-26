"""Build an immutable, private ration fixture using the accepted room source."""
from pathlib import Path
import importlib.util
import subprocess
import sys
import zipfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue410-lots'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

def main():
    active = subprocess.run(['powershell', '-NoProfile', '-Command', '(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'], capture_output=True, text=True)
    if active.stdout.strip():
        raise RuntimeError('Close GZDoom before regenerating its fixture archive.')
    WORK.mkdir(parents=True, exist_ok=True)
    room = module('placement', ROOT/'assets/validation_588/prepare.py').room()
    wad = module('water', ROOT/'assets/validation_580/prepare.py').wad
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs': (HERE/'checks.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA410FoodChecks" }\ncluster 8514 {hub}\nmap MAP01 "Food checks" {cluster=8514}\nmap CFOD410 "Food return" {cluster=8514}\n',
        'maps/MAP01.wad': wad(room, 'MAP01'),
        'maps/CFOD410.wad': wad(room, 'CFOD410'),
    }
    with zipfile.ZipFile(WORK/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), data)
    for mode in ('core', 'seed', 'load', 'clock', 'travel', 'container'):
        commands = f'wait 35; netevent ca410f_{mode}; '
        if mode == 'seed':
            commands += 'save ca410f-ready; '
        (WORK/(mode+'.cfg')).write_text(commands+'wait 5; quit\n', encoding='utf-8')
    (WORK/'hub.cfg').write_text('wait 35; netevent ca410f_container; changemap CFOD410; wait 35; netevent ca410f_away; changemap MAP01; wait 35; netevent ca410f_return; wait 5; quit\n', encoding='utf-8')
    for new in (False, True):
        source=(HERE/'legacy.zs').read_text(encoding='utf-8')
        if new:
            source=source.replace('// UPGRADE_CHECK', 'Console.Printf("CA410F %s old-save food automatically migrates fresh without changing quantity",food!=null && food.FoodClock!=null && food.FoodLots!=null && food.FoodLots.Units()==7 && food.FoodLots.OldestContamination()<0.1 ? "PASS":"FAIL");')
        folder=WORK/('upgrade' if new else 'legacy')
        folder.mkdir(exist_ok=True)
        with zipfile.ZipFile(folder/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
            for name,data in sorted({'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','legacy.zs':source.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA410FoodLegacy"}\n'}.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    (WORK/'old-seed.cfg').write_text('wait 70; netevent ca410f_old_seed; save ca410f-old; wait 5; quit\n',encoding='utf-8')
    (WORK/'old-check.cfg').write_text('wait 70; netevent ca410f_old_check; wait 5; quit\n',encoding='utf-8')
    manual='exec ../../assets/playtest/default_controls.cfg; wait 35; netevent ca410f_manual; bind F1 "netevent ca410f_manual"; bind F2 "netevent ca410f_read; toggleconsole"; bind F3 "netevent ca410f_eat"; bind F4 "netevent ca410f_day"'
    (WORK/'manual.cfg').write_text(manual+'\n',encoding='utf-8')
    (WORK/'capture.cfg').write_text('wait 70; netevent ca410f_manual; wait 5; ca_journal_page 0; ca_journal_open true; wait 5; screenshot food-lots.png; ca_journal_open false; wait 5; quit\n',encoding='utf-8')

if __name__ == '__main__':
    main()
