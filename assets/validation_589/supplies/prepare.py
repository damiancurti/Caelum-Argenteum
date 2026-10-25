"""Package native hygiene acquisition tests using the existing isolated room."""
from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'build/issue502/supplies'
OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
 'checks.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo { AddEventHandlers="CA502SuppliesChecks" }\ncluster 8502 { hub }\nmap CTX502 "Hygiene supplies" { cluster=8502 }\nmap CTX502B "Return" { cluster=8502 }\n'}
for name in ['CTX502','CTX502B']:members['maps/'+name+'.wad']=room.wad(room.room(),name)
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
 for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for name,script in {
 'craft':'wait 35; netevent ca502_supplies_craft; wait 5; quit',
 'shop':'wait 35; netevent ca502_supplies_shop; wait 5; quit',
 'transfer':'wait 35; netevent ca502_supplies_transfer; wait 5; quit',
 'save':'wait 35; netevent ca502_supplies_seed; save ca502-supplies-room; wait 5; quit',
 'load':'wait 1; netevent ca502_supplies_load; wait 5; quit',
 'hub':'wait 1; changemap CTX502B; wait 35; changemap CTX502; wait 35; netevent ca502_supplies_load; wait 5; quit',
 'task-save':'wait 35; netevent ca502_supplies_task_seed; save ca502-soap-task-room; wait 5; quit',
 'task-load':'wait 1; netevent ca502_supplies_task_load; wait 5; quit',
 'preview':'wait 35; netevent ca502_supplies_preview; wait 5; screenshot supplies-preview.png; wait 5; quit',
 'icons':'wait 35; netevent ca502_supplies_author; netevent ca502_supplies_inventory; wait 5; ca_journal_page 0; ca_journal_open true; wait 5; screenshot supplies-icons.png; wait 5; quit',
 'manual':'bind F2 "netevent ca502_supplies_trade"; bind F3 "netevent ca502_supplies_bench"; bind F4 "netevent ca502_supplies_inventory; wait 1; ca_journal_page 0; ca_journal_open true"; bind F6 toggleconsole; wait 35; netevent ca502_supplies_author',
}.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared independent hygiene supplies checks.')
