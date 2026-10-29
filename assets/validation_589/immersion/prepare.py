"""Prepare bounded native immersion checks; preserve earlier fixture evidence."""
from pathlib import Path
import importlib.util
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WORK=ROOT/'build/issue502/immersion'
WORK.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('water_room',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
room.DATA['volumes'].append({'id':104,'cell':[4,0],'height':192.0,'quality':4})
members={
    'ZSCRIPT':b'version "4.14"\n#include "forecast.zs"\n#include "checks.zs"\n#include "exposure.zs"\n#include "immersion.zs"\n',
    'forecast.zs':(ROOT/'assets/validation_587/checks.zs').read_bytes(),
    'checks.zs':(ROOT/'assets/validation_589/checks.zs').read_bytes().replace(b'PROVISION_REVISION==7',b'PROVISION_REVISION==9'),
    'exposure.zs':(ROOT/'assets/validation_589/exposure/checks.zs').read_bytes().replace(b'PROVISION_REVISION==8',b'PROVISION_REVISION==9').replace(b'wait schema8',b'wait schema9'),
    'immersion.zs':(HERE/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA502ImmersionChecks" }\ncluster 8502 { hub }\nmap CTX502 "Water contamination" { cluster=8502 }\nmap CTX502B "Water return" { cluster=8502 }\n',
}
text=room.room().replace('sector {','sector { user_ca_contamination_class=1;')
for name in ['CTX502','CTX502B']:members['maps/'+name+'.wad']=room.wad(text,name)
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
    'core':'wait 35; netevent ca502_water; wait 3; netevent ca502_water_drycheck; wait 5; quit',
    'wait':'wait 35; netevent ca502_water_wait; wait 5; quit',
    'connected':'wait 70; netevent ca502_water_connected; wait 5; quit',
    'departure':'wait 35; netevent ca502_water_departure; wait 5; quit',
    'save':'wait 35; netevent ca502_water_seed; save ca502-immersion; wait 5; quit',
    'load':'wait 1; netevent ca502_water_load; wait 5; quit',
    'hub':'wait 1; netevent ca502_water_load; changemap CTX502B; wait 35; changemap CTX502; wait 35; netevent ca502_water_load; wait 5; quit',
    'dry':'wait 35; netevent ca502_exposure; wait 5; quit',
    'journey':'wait 35; netevent ca502_exposure_journey; wait 5; quit',
    'manual':'bind F1 "netevent ca502_water_manual"; bind F2 "netevent ca502_water_salt"; bind F3 "netevent ca502_water_clean"; bind F4 "netevent ca502_water_chemical"; bind F5 "netevent ca502_water_dry"; bind F6 toggleconsole; wait 35; netevent ca502_water_manual',
}
for name,script in scripts.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared immersion fixtures.')
