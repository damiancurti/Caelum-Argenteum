"""Build isolated treatment fixtures; production resources remain untouched."""
from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'build/issue502/treatment'
OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
 'checks.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo { AddEventHandlers="CA502TreatmentChecks" }\ncluster 8502 { hub }\nmap CTX502 "Treatment" { cluster=8502 }\nmap CTX502B "Return" { cluster=8502 }\n'}
for name in ['CTX502','CTX502B']:members['maps/'+name+'.wad']=room.wad(room.room(),name)
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
 for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts={
 'rules':'wait 35; netevent ca502_treatment_rules; wait 5; quit',
 'runtime':'wait 35; netevent ca502_treatment_start; wait 370; netevent ca502_treatment_done; wait 5; quit',
 'drink':'wait 35; netevent ca502_treatment_manual; wait 370; netevent ca502_treatment_done; wait 5; quit',
 'save':'wait 35; netevent ca502_treatment_start; wait 70; save ca502-treatment; wait 5; quit',
 'load':'wait 330; netevent ca502_treatment_done; wait 5; quit',
 'hub':'wait 35; netevent ca502_treatment_start; wait 70; changemap CTX502B; wait 330; netevent ca502_treatment_done; wait 5; quit',
 'manual':'bind F1 "netevent ca502_treatment_full"; bind F2 "netevent ca502_treatment_manual"; bind F6 toggleconsole; wait 35; netevent ca502_treatment_full',
}
for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared treatment fixture.')
