"""Prepare a private #412 occupancy guard fixture using accepted tent geometry."""
from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1];WORK=ROOT/'build/issue412'
WORK.mkdir(parents=True,exist_ok=True)
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);obj=importlib.util.module_from_spec(spec);spec.loader.exec_module(obj);return obj
placement=module('placement',ROOT/'assets/validation_588/prepare.py')
water=module('water',ROOT/'assets/validation_580/prepare.py')
text=placement.room().replace('texturefloor="CMST01"','texturefloor="CMGR01A"',1)
members={'ZSCRIPT':b'version "4.14"\n#include "deploy.zs"\n#include "checks.zs"\n',
 'deploy.zs':(ROOT/'assets/validation_588/deploy/checks.zs').read_bytes(),
 'checks.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA412Checks"}\ncluster 8419 {hub}\nmap MAP01 "Tent rest guard" {cluster=8419}\nmap CDEP411 "Camp return" {cluster=8419}\n',
 'maps/MAP01.wad':water.wad(text,'MAP01'),'maps/CDEP411.wad':water.wad(text,'CDEP411')}
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as out:
 for name,blob in sorted(members.items()):out.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
(WORK/'core.cfg').write_text('wait 35; netevent ca412_guard; wait 5; quit\n',encoding='utf-8')
print('Prepared #412 private occupancy checks.')
