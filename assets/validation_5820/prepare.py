"""Prepare private kitchen fixture checks; never package diagnostic maps in src."""
from pathlib import Path
import importlib.util
import sys
import zipfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking';WORK.mkdir(parents=True,exist_ok=True)
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value
room=module('placement',ROOT/'assets/validation_588/prepare.py').room()
wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
source=(ROOT/'assets/validation_5814/checks.zs').read_bytes()+b'\n'+(ROOT/'assets/validation_5820/checks.zs').read_bytes()
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':source,
         'MAPINFO':b'GameInfo { AddEventHandlers="CA410FixtureChecks" }\ncluster 8520 {hub}\nmap MAP01 "Kitchen fixtures" {cluster=8520}\nmap CFIX410 "Away" {cluster=8520}\n',
         'maps/MAP01.wad':wad(room,'MAP01'),'maps/CFIX410.wad':wad(room,'CFIX410')}
for campaign in (False,True):
    with zipfile.ZipFile(WORK/('fixtures-campaign.pk3' if campaign else 'fixtures-checks.pk3'),'w',zipfile.ZIP_STORED) as archive:
        for name,data in sorted(members.items()):
            if campaign and name.startswith('maps/'):continue
            if campaign and name=='MAPINFO':data=b'GameInfo { AddEventHandlers="CA410FixtureChecks" }\n'
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for mode in ('core','resume','mansion'):
    commands=f'wait 35; netevent ca410k_{mode}; '
    if mode=='core':commands+='save ca410k-ready; '
    if mode=='mansion':commands+='wait 35; screenshot kitchen-fixtures.png; netevent ca410k_sprites; wait 35; screenshot kitchen-fixtures-sprites.png; '
    (WORK/f'fixtures-{mode}.cfg').write_text(commands+'wait 5; quit\n',encoding='utf-8')
(WORK/'fixtures-hub.cfg').write_text('wait 35; netevent ca410k_core; changemap CFIX410; wait 35; netevent ca410k_away; changemap MAP01; wait 35; netevent ca410k_resume; wait 5; quit\n',encoding='utf-8')
print('Prepared kitchen fixture scenarios.')

# Reuse the unchanged house acceptance fixture for the affected source lookup.
house=(ROOT/'assets/validation_5811/checks.zs').read_bytes()
legacy=(ROOT/'assets/validation_5811/legacy.zs').read_bytes()
with zipfile.ZipFile(WORK/'fixtures-house.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in {'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
                      'legacy.zs':legacy,'checks.zs':house,
                      'MAPINFO':b'GameInfo { AddEventHandlers="CA410BChecks" }\n'}.items():
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(WORK/'fixtures-house.cfg').write_text('wait 70; netevent ca410b_house; wait 5; quit\n',encoding='utf-8')
