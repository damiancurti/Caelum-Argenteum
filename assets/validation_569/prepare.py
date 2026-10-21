"""Build #380 private fixtures using the accepted room and legacy check definitions."""
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue380'
OUT.mkdir(parents=True, exist_ok=True)
subprocess.run([sys.executable, str(ROOT/'assets/validation_566/prepare.py')], check=True)
with zipfile.ZipFile(ROOT/'build/issue386/checks.pk3') as prior:
    members = {name: prior.read(name) for name in prior.namelist()}
members['checks380.zs'] = (HERE/'checks.zs').read_bytes()
members['checks376.zs'] = (ROOT/'assets/validation_560/checks.zs').read_bytes()
members['ZSCRIPT'] += b'#include "checks380.zs"\n#include "checks376.zs"\n'
members['legacy380.zs'] = (HERE/'legacy.zs').read_bytes()
members['ZSCRIPT'] += b'#include "legacy380.zs"\n'
members['MAPINFO'] = members['MAPINFO'].replace(b'"CA386Checks"', b'"CA386Checks", "CA380Checks", "CA376Checks", "CA380Legacy"')
with zipfile.ZipFile(OUT/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, content in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), content)
legacy={key:members[key] for key in ['checks376.zs','legacy380.zs']}
legacy['ZSCRIPT']=b'version "4.14"\n#include "checks376.zs"\n#include "legacy380.zs"\n'
legacy['MAPINFO']=b'GameInfo { AddEventHandlers = "CA376Checks", "CA380Legacy" }\n'
with zipfile.ZipFile(OUT/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,content in sorted(legacy.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),content)
resume=dict(members)
resume['resume.zs']=(HERE/'resume.zs').read_bytes()
resume['ZSCRIPT']+=b'#include "resume.zs"\n'
resume['MAPINFO']=resume['MAPINFO'].replace(b'"CA380Legacy"',b'"CA380Legacy", "CA380Resume"')
with zipfile.ZipFile(OUT/'resume-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,content in sorted(resume.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),content)
for issue,filename in [(386,'ca386-current.zds'),(386,'ca386-baseline.zds'),(376,'ca376-baseline.zds')]:
    source=ROOT/f'build/issue{issue}'/filename
    if source.exists() and not (OUT/filename).exists(): shutil.copy2(source,OUT/filename)
scripts = {
    'suite':'wait 35; netevent ca380_suite; wait 5; quit',
    'save':'wait 35; netevent ca380_save; wait 5; save ca380-current; wait 5; quit',
    'verify':'wait 35; netevent ca380_verify; wait 5; quit',
    'resume':'wait 35; netevent ca380_resume; save ca380-completed; wait 5; quit',
    'resume-legacy':'wait 5; netevent ca380_legacy_verify; netevent ca380_resume_legacy; wait 5; quit',
    'completed':'wait 5; netevent ca380_completed; wait 5; quit',
    'travel':'wait 35; netevent ca380_verify; changemap THAZARD; wait 35; netevent ca380_verify; changemap TMAINT; wait 35; netevent ca380_verify; changemap CLTHQA; wait 35; netevent ca380_verify; wait 5; quit',
    'upgrade':'wait 5; netevent ca376_verify; save ca380-upgraded; wait 5; quit',
    'legacy-save':'wait 35; netevent ca380_legacy_save; wait 5; save ca380-arrow-baseline; wait 5; quit',
    'legacy-verify':'wait 5; netevent ca380_legacy_verify; wait 5; quit',
    'legacy-upgrade':'wait 5; netevent ca380_legacy_verify; save ca380-arrow-upgraded; wait 5; quit',
    'upgrade-clothing':'wait 5; netevent ca386_verify; save ca380-clothing-upgraded; wait 5; quit',
    'interactive':'exec ../../assets/playtest/default_controls.cfg\nlanguage es; wait 35; changemap CLTHQA; wait 35; netevent ca380_author; wait 5; toggleconsole',
    'world':'wait 35; changemap CLTHQA; wait 35; netevent ca380_author; ca_journal_open false; r_drawplayersprites false; +lookdown; wait 5; -lookdown; wait 35; screenshot kits-world.png; wait 5; quit',
}
for name,script in scripts.items():
    (OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared issue380 native fixtures.')
