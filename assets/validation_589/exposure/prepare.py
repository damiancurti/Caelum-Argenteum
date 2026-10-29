"""Prepare isolated exposure fixtures without replacing accepted author packages."""
from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WORK=ROOT/'build/issue502/exposure'
WORK.mkdir(exist_ok=True)
spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
with zipfile.ZipFile(ROOT/'build/issue502/checks.pk3') as archive:
    members={n:archive.read(n) for n in archive.namelist()}
members['ZSCRIPT']+=b'#include "exposure.zs"\n'
members['exposure.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA502Checks',b'CA502ExposureChecks')
text=room.room().replace('sector {','sector { user_ca_contamination_class=1;')
members['maps/CTX502.wad']=room.wad(text,'CTX502')
members['maps/CTX502B.wad']=room.wad(text,'CTX502B')
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
(WORK/'core.cfg').write_text('wait 35; netevent ca502_exposure; wait 5; quit\n',encoding='utf-8')
for name in ['wait','wait_equipped','journey','classify']:
    (WORK/(name+'.cfg')).write_text(f'wait 35; netevent ca502_exposure_{name}; wait 5; quit\n',encoding='utf-8')
scripts={
    'save':'wait 35; netevent ca502_exposure_seed; save ca502-exposure-v2; wait 5; quit',
    'load':'wait 1; netevent ca502_exposure_loaded; wait 5; quit',
    'hub':'wait 1; netevent ca502_exposure_loaded; changemap CTX502B; wait 35; changemap CTX502; wait 35; netevent ca502_exposure_loaded; wait 5; quit',
    'manual':'bind F1 "netevent ca502_exposure_manual"; bind F2 "netevent ca502_exposure_wait"; bind F3 "netevent ca502_exposure_wait_equipped"; bind F4 "netevent ca502_exposure_journey"; bind F6 toggleconsole; wait 35; netevent ca502_exposure_manual',
    'capture':'wait 35; netevent ca502_exposure_manual; ca_journal_page 2; ca_journal_open true; wait 5; screenshot exposure-journal.png; wait 5; quit',
    'capture_full':'wait 35; netevent ca502_exposure_journal; ca_journal_page 2; ca_journal_open true; wait 5; screenshot exposure-journal-full.png; wait 5; quit',
}
for name,script in scripts.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared separate exposure fixtures.')
