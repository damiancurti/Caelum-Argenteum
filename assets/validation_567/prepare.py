"""Reuse #386's private room/checkpoint definitions for #387 visual checks."""
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue387'
OUT.mkdir(parents=True, exist_ok=True)
subprocess.run([sys.executable, str(ROOT/'assets/validation_566/prepare.py')], check=True)
with zipfile.ZipFile(ROOT/'build/issue386/checks.pk3') as prior:
    members = {name: prior.read(name) for name in prior.namelist()}
members['ZSCRIPT'] += b'#include "visuals.zs"\n'
members['visuals.zs'] = (HERE/'checks.zs').read_bytes()
members['MAPINFO'] = members['MAPINFO'].replace(b'"CA386Checks"', b'"CA386Checks", "CA387Checks"')
with zipfile.ZipFile(OUT/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, content in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), content)
for filename in ['ca386-current.zds', 'ca386-baseline.zds']:
    old_save = ROOT/'build/issue386'/filename
    if old_save.exists():
        shutil.copy2(old_save, OUT/old_save.name)
scripts = {
    'suite': 'wait 35; netevent ca387_suite; wait 5; netevent ca387_settle; wait 5; quit',
    'save': 'wait 35; netevent ca387_save; wait 35; netevent ca387_verify; save ca387-current; wait 5; quit',
    'verify': 'wait 35; netevent ca387_verify; wait 5; quit',
    'travel': 'wait 35; changemap THAZARD; wait 35; netevent ca387_verify; changemap CLTHQA; wait 35; netevent ca387_verify; changemap TMAINT; wait 35; netevent ca387_verify; wait 5; quit',
    'upgrade': 'wait 35; netevent ca386_verify; netevent ca387_legacy; save ca387-upgraded; wait 5; quit',
    'upgrade-verify': 'wait 35; netevent ca386_verify; netevent ca387_legacy; wait 5; quit',
    'baseline-upgrade': 'wait 35; netevent ca386_upgrade; wait 5; quit',
    'ui-es': 'wait 35; changemap CLTHQA; wait 35; netevent ca386_author; ca_journal_open true; ca_journal_page 0; language es; wait 35; screenshot clothing-es.png; wait 5; quit',
    'world': 'wait 35; changemap CLTHQA; wait 35; netevent ca386_author; netevent ca387_gallery; netevent ca387_camera; ca_journal_open false; wait 35; screenshot clothing-world.png; wait 5; quit',
    'interactive': 'exec ../../assets/playtest/default_controls.cfg\nlanguage es; wait 35; changemap CLTHQA; wait 35; netevent ca386_author; netevent ca387_gallery; ca_journal_open true; ca_journal_page 0; wait 5; toggleconsole',
}
for name, script in scripts.items():
    (OUT/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
print('Prepared issue387 fixtures; #386 sources reused without copying tracked definitions.')
