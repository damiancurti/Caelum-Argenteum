from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent;out=here.parents[1]/'build/issue502-hygiene';out.mkdir(parents=True,exist_ok=True)
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':(here/'checks.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA502HChecks" }\n'}
with zipfile.ZipFile(out/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={'core':'wait 70; netevent ca502h_core; wait 5; quit','save':'wait 70; netevent ca502h_seed; save ca502h-session; wait 5; quit','load':'wait 1; netevent ca502h_load; wait 5; quit','live':'wait 70; netevent ca502h_live_begin; wait 160; netevent ca502h_live_end; wait 5; quit','forecast':'wait 70; netevent ca502h_forecast; wait 5; quit','manual':'wait 70; netevent ca502h_manual; bind F1 "netevent ca502h_manual"; bind F6 toggleconsole'}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared hygiene checks.')

(out/'legacy').mkdir(exist_ok=True)
with zipfile.ZipFile(out/'legacy/checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,blob in sorted({'ZSCRIPT':members['ZSCRIPT'],'checks.zs':(here/'legacy.zs').read_bytes(),'MAPINFO':members['MAPINFO']}.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
extra={'old-save':'wait 70; netevent ca502h_old_seed; save ca502h-legacy; wait 5; quit','old-load':'wait 1; netevent ca502h_old_verify; wait 5; quit','legacy':'wait 1; netevent ca502h_legacy; wait 5; quit','hub':'wait 1; changemap CAH001; wait 70; netevent ca502h_hub; changemap CAH000; wait 70; netevent ca502h_hub; wait 5; quit'}
for name,script in extra.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
