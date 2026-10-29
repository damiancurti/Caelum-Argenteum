"""Prepare isolated native cooking and persistent proofing scenarios."""
from pathlib import Path
import importlib.util
import zipfile
import sys
sys.dont_write_bytecode = True
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking'
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
room=module('placement',ROOT/'assets/validation_588/prepare.py').room()
wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
source=(ROOT/'assets/validation_5814/checks.zs').read_bytes()+b'\n'+(ROOT/'assets/validation_5819/checks.zs').read_bytes()
members={
    'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs':source,
    'MAPINFO':b'GameInfo { AddEventHandlers="CA410CookingChecks" }\ncluster 8519 {hub}\nmap MAP01 "Kitchen process checks" {cluster=8519}\nmap CFOD410 "Proofing away" {cluster=8519}\n',
    'maps/MAP01.wad':wad(room,'MAP01'), 'maps/CFOD410.wad':wad(room,'CFOD410')}
with zipfile.ZipFile(WORK/'process-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
with zipfile.ZipFile(WORK/'process-campaign.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):
        if name.startswith('maps/'):continue
        if name=='MAPINFO':data=b'GameInfo { AddEventHandlers="CA410CookingChecks" }\n'
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for mode in ('core','seed','resume','guards','taskseed','taskresume','library','mansion'):
    commands=f'wait 35; netevent ca410c_{mode}; '
    if mode=='seed':commands+='save ca410c-ready; '
    if mode=='taskseed':commands+='save ca410c-cooking; '
    if mode=='mansion':commands+='wait 5; screenshot kitchen-mansion.png; '
    (WORK/f'process-{mode}.cfg').write_text(commands+'wait 5; quit\n',encoding='utf-8')
(WORK/'process-hub.cfg').write_text('wait 35; netevent ca410c_seed; changemap CFOD410; wait 35; netevent ca410c_away; changemap MAP01; wait 35; netevent ca410c_resume 1; wait 5; quit\n',encoding='utf-8')
(WORK/'process-fast.cfg').write_text('wait 35; netevent ca410c_fast; wait 800; netevent ca410c_fastdone; wait 5; quit\n',encoding='utf-8')
(WORK/'process-view.cfg').write_text('wait 35; netevent ca410c_view; wait 5; screenshot kitchen-cooking-menu.png; wait 5; quit\n',encoding='utf-8')
(WORK/'process-menu.cfg').write_text('wait 35; netevent ca410c_menustart; wait 40; netevent ca410c_menudone; wait 5; screenshot kitchen-proofing-menu.png; wait 5; quit\n',encoding='utf-8')
print('Prepared isolated cooking/proofing fixtures.')
