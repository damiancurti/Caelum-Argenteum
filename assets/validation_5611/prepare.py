"""Build #385 fixtures on the accepted merchant, library and room definitions."""
from pathlib import Path
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue385'
OUT.mkdir(parents=True,exist_ok=True)
subprocess.run([sys.executable,str(ROOT/'assets/validation_5610/prepare.py')],check=True)
with zipfile.ZipFile(ROOT/'build/issue383/checks.pk3') as prior:
    members={name:prior.read(name) for name in prior.namelist()}
members['checks385.zs']=(HERE/'checks.zs').read_bytes()
members['legacy385.zs']=(HERE/'legacy.zs').read_bytes()
members['ZSCRIPT']+=b'#include "legacy385.zs"\n#include "checks385.zs"\n'
members['MAPINFO']=members['MAPINFO'].replace(b'"CA383Legacy"',b'"CA383Legacy", "CA385Checks", "CA385Legacy"')
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,content in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),content)
(OUT/'upgrade').mkdir(exist_ok=True)
# GZDoom resolves required saved packages by filename, including private fixtures.
(OUT/'upgrade/legacy-checks.pk3').write_bytes((OUT/'checks.pk3').read_bytes())
legacy={name:members[name] for name in ['checks377.zs','legacy385.zs','maps/CLTHQA.wad']}
legacy['ZSCRIPT']=b'version "4.14"\n#include "checks377.zs"\n#include "legacy385.zs"\n'
legacy['MAPINFO']=b'GameInfo { AddEventHandlers = "CA385Legacy" }\nmap CLTHQA "Legacy stock checks" { nointermission cluster = 434 }\n'
with zipfile.ZipFile(OUT/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,content in sorted(legacy.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),content)
scripts={
    'suite':'wait 35; netevent ca385_suite; wait 5; quit',
    'regression':'wait 35; netevent ca377_suite; netevent ca383_suite; wait 5; quit',
    'save':'wait 35; netevent ca385_save; wait 5; save ca385-current; wait 5; quit',
    'verify':'wait 5; netevent ca385_verify; wait 5; quit',
    'travel':'wait 5; netevent ca385_verify; changemap THAZARD; wait 35; changemap CLTHQA; wait 35; netevent ca385_verify; wait 5; quit',
    'resume':'wait 5; netevent ca385_resume; wait 5; save ca385-completed; wait 5; quit',
    'completed':'wait 5; netevent ca385_completed; wait 5; quit',
    'legacy-save':'wait 35; netevent ca385_legacy_save; wait 5; save ca385-legacy; wait 5; quit',
    'rollback':'wait 5; netevent ca385_rollback; wait 5; quit',
    'upgrade':'wait 5; netevent ca385_upgrade; wait 5; save ca385-upgraded; wait 5; quit',
    'upgrade-verify':'wait 5; netevent ca385_upgrade_verify; wait 5; quit',
    'active':'wait 35; netevent ca385_active; wait 100; netevent ca385_active_verify; wait 5; quit',
    'perf':'wait 35; netevent ca385_perf; wait 360; quit',
    'paused':'wait 35; netevent ca385_pause_mark; wait 2; pause; wait 70; pause; wait 2; netevent ca385_pause_verify; wait 5; quit',
    'interactive':'exec ../../assets/playtest/default_controls.cfg\nbind F6 "netevent ca385_day"\nbind E "+use"\nlanguage es; wait 35; netevent ca385_author; give CaelumGoldCoin 1000; wait 5; toggleconsole',
}
for name,commands in scripts.items():(OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8',newline='\n')
print('Prepared #385 isolated fixtures.')
