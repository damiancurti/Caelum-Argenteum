"""Native probes use unchanged campaign house geometry, never shipped fixtures."""
from pathlib import Path
import zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
OUT=ROOT/'build/issue410-bath'
OUT.mkdir(parents=True,exist_ok=True)
members={'ZSCRIPT':b'version "4.14.2"\n#include "legacy.zs"\n#include "checks.zs"\n',
         'checks.zs':(HERE/'checks.zs').read_bytes(),
         'legacy.zs':(HERE/'legacy.zs').read_bytes(),
         'MAPINFO':b'GameInfo { AddEventHandlers="CA410BChecks" }\n'}
old_legacy=members['legacy.zs']
members['legacy.zs']=old_legacy.replace(b"if(e.Name=='ca410b_old_seed')",b"if(e.Name=='ca410b_legacy'){let probe=new('CA410BChecks');probe.NetworkProcess(e);return;}\n        if(e.Name=='ca410b_old_seed')")
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
 'core':'wait 70; netevent ca410b_core; wait 5; quit',
 'house':'wait 70; netevent ca410b_house; wait 5; quit',
 'fill':'wait 70; netevent ca410b_fill; wait 5; quit',
 'retry':'wait 70; netevent ca410b_retry; wait 5; quit',
 'save':'wait 70; netevent ca410b_seed; save ca410b-water; wait 5; quit',
 'load':'wait 1; netevent ca410b_verify; netevent ca410b_house; wait 5; quit',
 'hub':'wait 1; netevent ca410b_verify; changemap CAH001; wait 70; netevent ca410b_house; netevent ca410b_verify; changemap CAH000; wait 70; netevent ca410b_house; netevent ca410b_verify; wait 5; quit',
 'capture':'wait 70; netevent ca410b_view; wait 10; screenshot bathroom.png; netevent ca410b_close 0; wait 10; screenshot sink.png; netevent ca410b_close 1; wait 10; screenshot bathtub.png; netevent ca410b_close 2; wait 10; screenshot toilet.png; r_models 0; wait 10; screenshot toilet-sprite.png; wait 5; quit',
 'legacy':'wait 70; netevent ca410b_legacy; wait 5; quit',
 'manual':'wait 70; netevent ca410b_manual; bind F1 "netevent ca410b_close 0"; bind F2 "netevent ca410b_close 1"; bind F3 "netevent ca410b_close 2"; bind F4 "changemap CAH001; wait 70; netevent ca410b_close 0"; bind F5 "changemap CAH000; wait 70; netevent ca410b_close 0"; bind F6 toggleconsole; bind F7 "netevent ca410b_manual"'
}
scripts['manual-smoke']=scripts['manual']+'; wait 5; quit'
for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
(OUT/'legacy').mkdir(exist_ok=True)
with zipfile.ZipFile(OUT/'legacy/checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "legacy.zs"\n','legacy.zs':old_legacy,'MAPINFO':b'GameInfo { AddEventHandlers="CA410BLegacy" }\n'}.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
(OUT/'old-save.cfg').write_text('wait 70; netevent ca410b_old_seed; save ca410b-legacy; wait 5; quit\n',encoding='utf-8')
(OUT/'old-load.cfg').write_text('wait 1; netevent ca410b_old_verify; wait 5; quit\n',encoding='utf-8')
print('Prepared unchanged campaign bathroom probes.')
