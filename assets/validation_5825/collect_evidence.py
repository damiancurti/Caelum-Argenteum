"""Verify final water-furniture package, native checks, preservation and artifacts."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-cooking'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final25c/caelum_argenteum_dev.pk3'
previous=WORK/'legacy24/caelum_argenteum_dev.pk3'
files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
report={'version':'5.8.25','issue':410,'runtime_sha256':digest(package),'previous_runtime_sha256':digest(previous),
        'native_passes':0,'native_failures':0,'runs':[],'author_check':'CA410-WATER-FURNITURE-01','author_acceptance':'pending'}
with zipfile.ZipFile(package) as archive,zipfile.ZipFile(previous) as old:
    assert set(archive.namelist())==set(files)
    for name,p in files.items():assert archive.read(name)==p.read_bytes(),name
    report['source_matching_members']=len(files)
    retained=0
    for name in old.namelist():
        if name.startswith(('maps/','models/','sprites/','graphics/')):
            assert old.read(name)==archive.read(name),name
            retained+=1
    report['preserved_existing_map_art_members']=retained
labels=['water-delivery-'+mode for mode in ('core','mansion','bath','seed','hub','view0','view1','inventory','resume','migrate','spanish')]
labels+=['water-oldseed24','water-rollback24']
(HERE/'native').mkdir(exist_ok=True)
for label in labels:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA410WF FAIL|Script error|VM execution aborted|Fatal:|failed=[1-9]',log),label
    assert 'CA410WF RESULT' in log,label
    count=len(re.findall(r'^CA410WF PASS ',log,re.M))
    sha=run['package_sha256'].lower()
    assert sha in (report['runtime_sha256'],report['previous_runtime_sha256']),label
    report['native_passes']+=count
    report['runs'].append({'label':label,'executed_passes':count,'runtime_sha256':sha,'addon_sha256':run['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
raw=(WORK/'static-5825-final.json').read_bytes()
static=json.loads(raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8-sig'))
assert not static['errors'];report['static_errors']=0
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
report['performance']=[]
for label in ('water-perf-base','water-perf-final'):
    row=json.loads((WORK/(label+'.json')).read_text());report['performance'].append(row)
    for suffix in ('.json','.txt'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
(HERE/'captures').mkdir(exist_ok=True)
report['capture_sha256']={}
for name in ('water-furniture-view0.png','water-furniture-view1.png','water-furniture-inventory.png'):
    shutil.copy2(WORK/name,HERE/'captures'/name);report['capture_sha256'][name]=digest(WORK/name)
report['save_sha256']={name:digest(WORK/name) for name in ('water-furniture-progress.zds','water-furniture-legacy24.zds')}
report['generator_manifest_sha256']=digest(ROOT/'assets/art_source/water_furniture/MANIFEST.json')
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ('runs','performance','capture_sha256')}))
