"""Collect focused #471 evidence and verify the tested production package."""
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
WORK=ROOT/'build/issue471-ammo'
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

package=WORK/'current/caelum_argenteum_dev.pk3'
package_hash=digest(package)
sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(sources),'Package membership differs from src'
    for name,path in sources.items():assert archive.read(name)==path.read_bytes(),name
fixture_hash=digest(WORK/'fixture.pk3')
baseline_fixture_hash=digest(WORK/'baseline/fixture.pk3')
subprocess.run([sys.executable,str(HERE/'prepare.py')],check=True)
assert digest(WORK/'fixture.pk3')==fixture_hash,'Fixture is not deterministic'
assert digest(WORK/'baseline/fixture.pk3')==baseline_fixture_hash
variants=['fixture.pk3','fixture-initial.pk3','fixture-network-fix.pk3',
          'fixture-travel-fix.pk3','baseline/fixture.pk3','baseline/fixture-original.pk3']
known_fixtures={digest(WORK/name):name for name in variants}
labels=('suite01','station02','upgrade01','resume01','current-save01',
        'current-load01','travel02','live01','ui01','baseline-save01','baseline-rollback01')
runs=[]
for label in labels:
    log=(WORK/f'{label}.txt').read_text(encoding='utf-8',errors='replace')
    metadata=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert metadata['exit_code']==0 and 'CA380 FAIL' not in log and 'CA380 RESULT' in log,label
    assert not metadata.get('timed_out',False),label
    if label.startswith('baseline-'):
        assert metadata['package_sha256'].lower()=='4144ef65ec10a3f35cd9b730a23eb95423497b1ac21eff3d8dd07cf7a6050fad'
    else:assert metadata['package_sha256'].lower()==package_hash,label
    assert metadata['addon_sha256'].lower() in known_fixtures,label
    if label=='travel02':assert 'CA380 PASS native map transition reached destination' in log
    for suffix in ('.txt','-run.json'):
        destination=HERE/'native'/(label+suffix);destination.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(WORK/(label+suffix),destination)
    runs.append({'label':label,'passed':len(re.findall(r'^CA380 PASS ',log,re.M)),
                 'package_sha256':metadata['package_sha256'].lower(),
                 'fixture_sha256':metadata['addon_sha256'].lower()})
for label in ('station01','travel01'):
    destination=HERE/'diagnostics'/f'{label}.txt';destination.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(WORK/f'{label}.txt',destination)
for name in ('ui01-alchemy.png','ui01-ranged.png'):
    destination=HERE/'visuals'/name;destination.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(WORK/name,destination)
report={'issue':471,'version':'5.7.10','scope':'Existing cartridge station migration only',
        'package_sha256':package_hash,'source_entries':len(sources),'source_bytes_match':True,
        'fixture_sha256':fixture_hash,'fixture_deterministic':True,'runs':runs,
        'native_assertions_passed':sum(r['passed'] for r in runs),'author_acceptance':False,
        'fixture_revision_notes':'Production source/package is unchanged across every current run. Fixture-only corrections respect the existing one-second station refresh, bypass the test-map intermission and add manual station switching. Earlier process/save checks retain their original fixture hashes.',
        'remaining':['CA471-AMMO-01 author acceptance','Other #471 recipe/economy definitions','PR review/integration']}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f"#471: {report['native_assertions_passed']} native assertions; {len(sources)} production source entries match.")
