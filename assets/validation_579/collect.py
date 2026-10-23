"""Collect issue #409 evidence, rejecting source/package or fixture drift."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue409'
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

package=WORK/'current/caelum_argenteum_dev.pk3'
package_hash=digest(package)
previous=WORK/'pre-ui-fix.pk3'
previous_hash=digest(previous)
sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(sources),'Package membership differs from src'
    for name,path in sources.items():assert archive.read(name)==path.read_bytes(),name
with zipfile.ZipFile(previous) as before, zipfile.ZipFile(package) as after:
    assert set(before.namelist())==set(after.namelist())
    changed=[name for name in after.namelist() if before.read(name)!=after.read(name)]
    allowed={'LANGUAGE','caelum/hud/CaelumCraftingUI.zs','caelum/hud/CaelumJournalOverlay.zs',
             'localization/INDEX.md','localization/index.json'}
    assert set(changed)<=allowed,changed
fixture_hash=digest(WORK/'fixture.pk3')
subprocess.run([sys.executable,str(HERE/'prepare.py')],check=True)
assert digest(WORK/'fixture.pk3')==fixture_hash,'Fixture is not deterministic'
runs=[]
labels=('final-smoke','final-live','final-wait','final-save','final-load','final-ui2','final-legacy2','old-save01','old-rollback01')
for label in labels:
    log=(WORK/f'{label}.txt').read_text(encoding='utf-8',errors='replace')
    metadata=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert metadata['exit_code']==0 and 'CA409 FAIL' not in log,label
    if label.startswith('final-'):
        expected=package_hash if label in ('final-ui2','final-legacy2') else previous_hash
        assert metadata['package_sha256'].lower()==expected,label
    addon='legacy-current/legacy.pk3' if label=='final-legacy2' else 'legacy.pk3' if label.startswith('old-') else 'fixture.pk3'
    assert metadata['addon_sha256'].lower()==digest(WORK/addon),label
    for suffix in ('.txt','-run.json'):
        dest=HERE/'native'/(label+suffix);dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(WORK/(label+suffix),dest)
    runs.append({'label':label,'passed':len(re.findall(r'^CA409 PASS ',log,re.M)),'failed':0,
                 'package_sha256':metadata['package_sha256'].lower()})
for label in ('compile01','compile02','thermal01','thermal03','final-legacy'):
    dest=HERE/'diagnostics'/f'{label}.txt';dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(WORK/f'{label}.txt',dest)
for name in ('final-ui2-inventory.png','final-ui2-task.png'):
    dest=HERE/'visuals'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(WORK/name,dest)
report={'issue':409,'version':'5.7.9','status':'implementation draft; glass cooling datum unresolved',
        'package_sha256':package_hash,'source_entries':len(sources),'source_bytes_match':True,
        'previous_package_sha256':previous_hash,'presentation_only_delta':changed,
        'reuse_scope':'Native process/wait/save checks reused after an inspected UI-only correction; server logic and thermal data are byte-identical.',
        'fixture_sha256':fixture_hash,'fixture_deterministic':True,'runs':runs,
        'native_assertions_passed':sum(r['passed'] for r in runs),'author_acceptance':False,
        'remaining':['Confirm glass density and complete bottle cooling tests','Author interaction/acceptance','PR review/integration']}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f"#409: {report['native_assertions_passed']} native assertions; {len(sources)} source entries match; glass cooling remains pending.")
