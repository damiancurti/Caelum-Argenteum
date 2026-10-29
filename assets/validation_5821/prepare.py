"""Reuse accepted private room/helpers for focused camp-cooking integration."""
from pathlib import Path
import importlib.util
import sys
import zipfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking';WORK.mkdir(parents=True,exist_ok=True)
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
room=module('placement',ROOT/'assets/validation_588/prepare.py').room()
wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
source=b'\n'.join((ROOT/f'assets/validation_{version}/checks.zs').read_bytes() for version in ('5814','5819','5821'))
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':source,
         'MAPINFO':b'GameInfo { AddEventHandlers="CA411CookingChecks" }\ncluster 8521 {hub}\nmap MAP01 "Camp cooking" {cluster=8521}\nmap CCMP411 "Away" {cluster=8521}\n',
         'maps/MAP01.wad':wad(room,'MAP01'),'maps/CCMP411.wad':wad(room,'CCMP411')}
with zipfile.ZipFile(WORK/'camp-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for mode in ('core','interrupt','seed','resume','guards'):
    commands=f'wait {1 if mode=="resume" else 35}; netevent ca411c_{mode}; '
    if mode=='seed':commands+='save ca411c-progress; '
    (WORK/f'camp-{mode}.cfg').write_text(commands+'wait 5; quit\n',encoding='utf-8')
(WORK/'camp-fast.cfg').write_text('wait 35; netevent ca411c_fast; wait 800; netevent ca411c_fastdone; wait 5; quit\n',encoding='utf-8')
for mode,arg in [('menu',0),('progress',1)]:
    (WORK/f'camp-{mode}.cfg').write_text(f'wait 35; netevent ca411c_view {arg}; wait 35; screenshot camp-{mode}.png; wait 5; quit\n',encoding='utf-8')
controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
(WORK/'camp-input.cfg').write_text(controls+'; wait 35; netevent ca411c_input\n',encoding='utf-8')
(WORK/'camp-input-timed.cfg').write_text(controls+'; wait 35; netevent ca411c_input; wait 2100; netevent ca411c_audit; wait 35; screenshot camp-input-audit.png; wait 5; quit\n',encoding='utf-8')
for name,command in [('fish','ca411c_input'),('puchero','ca411c_view 0'),('paused','ca411c_view 1')]:
    (WORK/f'camp-author-{name}.cfg').write_text(controls+'; wait 35; netevent '+command+'; wait 5; echo CA411C INPUT ready\n',encoding='utf-8')
(WORK/'camp-hub.cfg').write_text('wait 35; netevent ca411c_hubseed; changemap CCMP411; wait 35; netevent ca410c_away; changemap MAP01; wait 35; netevent ca411c_hubreturn; wait 5; quit\n',encoding='utf-8')
print('Prepared camp cooking native checks.')
