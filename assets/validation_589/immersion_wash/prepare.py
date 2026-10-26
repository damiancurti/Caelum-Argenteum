"""Extend retained water fixtures without rewriting their original evidence."""
from pathlib import Path
import importlib.util
import zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'build/issue502/immersion_wash'
OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('water',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
room.DATA['volumes'] += [{'id':104,'cell':[4,0],'height':192.0,'quality':4},
    {'id':105,'cell':[5,0],'height':32.0,'quality':0}]
with zipfile.ZipFile(ROOT/'build/issue502/immersion/checks.pk3') as base:
    members={name:base.read(name) for name in base.namelist()}
members['ZSCRIPT'] += b'#include "wash.zs"\n'
members['wash.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA502ImmersionChecks',b'CA502WashChecks')
text=room.room().replace('sector {','sector { user_ca_contamination_class=1;')
for name in ['CTX502','CTX502B']:members['maps/'+name+'.wad']=room.wad(text,name)
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
 'core':'wait 35; netevent ca502_wash; wait 5; quit',
 'wait':'wait 35; netevent ca502_wash_wait; wait 5; quit',
 'regression':'wait 35; netevent ca502_water; wait 3; netevent ca502_water_drycheck; wait 5; quit',
 'save':'wait 35; netevent ca502_wash_seed; save ca502-wash; wait 5; quit',
 'load':'wait 1; netevent ca502_wash_load; wait 5; quit',
 'hub':'wait 1; netevent ca502_wash_load; changemap CTX502B; wait 35; netevent ca502_wash_hub; changemap CTX502; wait 35; netevent ca502_wash_hub; wait 5; quit',
 'manual':'bind F1 "netevent ca502_wash_manual"; bind F2 "netevent ca502_wash_partial"; bind F3 "netevent ca502_wash_dry"; bind F4 "netevent ca502_wash_salt"; bind F5 "netevent ca502_water_manual"; bind F6 toggleconsole; wait 35; netevent ca502_wash_manual'
}
for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared clean-immersion fixture.')
