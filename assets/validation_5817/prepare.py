"""Prepare private ingredient checks and the unchanged ration regression fixture."""
from pathlib import Path
import importlib.util
import subprocess
import sys
import zipfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue410-kitchen'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

def main():
    active = subprocess.run(['powershell', '-NoProfile', '-Command', '(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'], capture_output=True, text=True)
    if active.stdout.strip():
        raise RuntimeError('Close GZDoom before generating native fixtures.')
    WORK.mkdir(parents=True, exist_ok=True)
    room = module('placement', ROOT/'assets/validation_588/prepare.py').room()
    wad = module('water', ROOT/'assets/validation_580/prepare.py').wad
    for kitchen in (False, True):
        source = (ROOT/'assets/validation_5814/checks.zs').read_bytes()
        if kitchen:
            source += b'\n' + (HERE/'checks.zs').read_bytes()
        handler = 'CA410KitchenChecks' if kitchen else 'CA410FoodChecks'
        members = {
            'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
            'checks.zs': source,
            'MAPINFO': (f'GameInfo {{ AddEventHandlers="{handler}" }}\ncluster 8514 {{hub}}\nmap MAP01 "Food checks" {{cluster=8514}}\nmap CFOD410 "Food return" {{cluster=8514}}\n').encode(),
            'maps/MAP01.wad': wad(room, 'MAP01'),
            'maps/CFOD410.wad': wad(room, 'CFOD410'),
        }
        if kitchen:
            members['MENUDEF']=b'ListMenu CaelumLiveMenu { Class CA410KitchenMenu }\n'
        with zipfile.ZipFile(WORK/('checks.pk3' if kitchen else 'ration-checks.pk3'), 'w', zipfile.ZIP_STORED) as archive:
            for name, data in sorted(members.items()):
                archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), data)
    for prefix, modes in [('k', ('core', 'transfer', 'clock', 'market', 'seed', 'load', 'pickup', 'purchase', 'formal', 'census')), ('f', ('core', 'clock', 'travel', 'container', 'seed', 'load'))]:
        for mode in modes:
            commands = f'wait 35; netevent ca410{prefix}_{mode}; '
            if mode == 'seed':
                commands += f'save ca410{prefix}-ready; '
            (WORK/(prefix+'-'+mode+'.cfg')).write_text(commands+'wait 5; quit\n', encoding='utf-8')
    (WORK/'digestion.cfg').write_text('wait 35; netevent ca410k_digest; wait 360; netevent ca410k_digested; wait 5; quit\n',encoding='utf-8')
    (WORK/'digestion-control.cfg').write_text('wait 35; netevent ca410k_digestcontrol; wait 360; netevent ca410k_digested; wait 5; quit\n',encoding='utf-8')
    (WORK/'hub.cfg').write_text('wait 35; netevent ca410k_transfer; changemap CFOD410; wait 35; netevent ca410f_away; changemap MAP01; wait 35; netevent ca410k_hubreturn; wait 5; quit\n',encoding='utf-8')
    controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
    manual=controls+'; bind F1 "netevent ca410k_manual"; bind F2 "netevent ca410k_read; toggleconsole"; bind F3 "netevent ca410k_eat"; bind F4 "netevent ca410k_age"; bind F5 "netevent ca410k_view"; wait 35; netevent ca410k_manual; wait 5; echo CA410K INPUT ready'
    (WORK/'manual.cfg').write_text(manual+'\n',encoding='utf-8')
    (WORK/'capture.cfg').write_text(manual+'; wait 5; screenshot kitchen-gallery.png; netevent ca410k_view; ca_journal_page 0; ca_journal_open true; wait 5; screenshot kitchen-inventory.png; ca_journal_open false; wait 5; quit\n',encoding='utf-8')
    (WORK/'manual-smoke.cfg').write_text(manual+'; netevent ca410k_eat; wait 5; netevent ca410k_age; wait 5; quit\n',encoding='utf-8')

if __name__ == '__main__':
    main()
