"""Validate the completed glass model separately from the preserved draft report."""
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
draft=WORK/'draft-579.pk3'
assert digest(draft)==json.loads((HERE/'report.json').read_text())['package_sha256']
sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(sources),'Package membership differs from src'
    for name,path in sources.items():assert archive.read(name)==path.read_bytes(),name
with zipfile.ZipFile(draft) as before,zipfile.ZipFile(package) as after:
    changed=[name for name in after.namelist() if before.read(name)!=after.read(name)]
    assert changed==['caelum/data/CaelumWaterThermalData.zs'],changed
fixture_hash=digest(WORK/'fixture.pk3')
subprocess.run([sys.executable,str(HERE/'prepare.py')],check=True)
assert digest(WORK/'fixture.pk3')==fixture_hash,'Fixture is not deterministic'
variants={digest(WORK/name) for name in ['fixture.pk3','fixture-glass-core.pk3','legacy-current/legacy.pk3']}
labels=('glass01','glass-live01','glass-save01','glass-load01','complete-smoke01',
        'glass-wait01','complete-wait01','complete-legacy01','complete-ui01')
runs=[]
for label in labels:
    log=(WORK/f'{label}.txt').read_text(encoding='utf-8',errors='replace')
    metadata=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert metadata['exit_code']==0 and 'CA409 FAIL' not in log and 'CA409 RESULT' in log,label
    assert not metadata.get('timed_out',False),label
    assert metadata['package_sha256'].lower()==package_hash,label
    assert metadata['addon_sha256'].lower() in variants,label
    for suffix in ('.txt','-run.json'):
        dest=HERE/'native'/(label+suffix);dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(WORK/(label+suffix),dest)
    runs.append({'label':label,'passed':len(re.findall(r'^CA409 PASS ',log,re.M)),
                 'fixture_sha256':metadata['addon_sha256'].lower()})
for name in ('complete-ui01-inventory.png','complete-ui01-task.png'):
    dest=HERE/'visuals'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(WORK/name,dest)
report={'issue':409,'version':'5.7.9','status':'implemented; author gameplay acceptance pending',
        'glass_density_kg_m3':2500,'density_approved':'2026-10-23',
        'package_sha256':package_hash,'source_entries':len(sources),'source_bytes_match':True,
        'delta_from_preserved_draft':changed,'fixture_sha256':fixture_hash,'fixture_deterministic':True,
        'runs':runs,'native_assertions_passed':sum(r['passed'] for r in runs),
        'author_acceptance':False,'draft_evidence':'report.json retains the original 91 assertions and rollback. The final package changes only the approved glass thermal datum; relevant process/thermal/legacy checks were rerun.',
        'fixture_revision_notes':'Initial glass checks precede added manual quality controls and the dated-wait scenario; their fixture hash remains recorded and the production package is unchanged.'}
(HERE/'completion_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f"#409 completion: {report['native_assertions_passed']} assertions; {len(sources)} source entries match.")
