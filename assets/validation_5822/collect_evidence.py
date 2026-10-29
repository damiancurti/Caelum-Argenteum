"""Collect only executed passing checks against the final mansion package."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-cooking'
package=WORK/'final22c/caelum_argenteum_dev.pk3'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(files)
    for name,path in files.items(): assert archive.read(name)==path.read_bytes(),name
    with zipfile.ZipFile(WORK/'final22/caelum_argenteum_dev.pk3') as previous:
        assert set(previous.namelist())==set(files)
        differences=[name for name in files if previous.read(name)!=archive.read(name)]
        assert differences==['caelum/data/CaelumMansionBathroomData.zs'],differences
    previous_hash=digest(WORK/'final22/caelum_argenteum_dev.pk3')
    unchanged=[]
    with zipfile.ZipFile(WORK/'legacy21/caelum_argenteum_dev.pk3') as old:
        for name in old.namelist():
            if name.startswith(('maps/','models/','sprites/','graphics/')) or name.startswith('caelum/data/domestic_bathrooms.'):
                assert old.read(name)==archive.read(name),name
                unchanged.append(name)
report={'issue':410,'version':'5.8.22','runtime_sha256':digest(package),
        'source_matching_members':len(files),'unchanged_map_art_members':len(unchanged),
        'native_passes':0,'native_failures':0,'runs':[],
        'previous_package':{'sha256':previous_hash,'differences':differences,'scope':'Only six fixture angles; all approaches/postures, retained layouts and captures rechecked.'},
        'author_check':'CA410-MANSION-BATH-01','author_acceptance':'pending'}
labels=['bath-final-shared','bath-final-access','bath-final-hub','bath-finalc-manual',
        'bath-finalc-layout','bath-finalc-access','bath-finalc-capture2','bath-final-oldload','bath-final-seed','bath-final-resume',
        'bath-oldseed21','bath-rollback21']
(HERE/'native').mkdir(exist_ok=True)
for label in labels:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    count=len(re.findall(r'^CA410F PASS ',log,re.M))
    assert count and 'CA410F RESULT' in log,label
    assert not re.search(r'CA410F FAIL|Script error|VM execution aborted|Fatal:|failed=[1-9]',log),label
    assert run.get('exit_code')==0 and not run.get('timed_out'),label
    if label.startswith('bath-finalc-'):assert run['package_sha256'].lower()==report['runtime_sha256'],label
    elif label.startswith('bath-final-'):assert run['package_sha256'].lower()==previous_hash,label
    report['native_passes']+=count
    report['runs'].append({'label':label,'executed_passes':count,'runtime_sha256':run['package_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
static_path=WORK/'static-5822.json'
raw=static_path.read_bytes()
static=json.loads(raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8-sig'))
assert not static['errors'],static['errors']
report['static_errors']=0
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
generated=ROOT/'src/caelum/data/CaelumMansionBathroomData.zs'
before=generated.read_bytes()
subprocess.run(['python',str(ROOT/'assets/generators/generate_mansion_bathrooms.py')],check=True,capture_output=True)
assert before==generated.read_bytes()
report['deterministic_outputs']={generated.relative_to(ROOT).as_posix():digest(generated)}
(HERE/'captures').mkdir(exist_ok=True)
for name in [f'finald-mansion-bath-{i}-{pose}.png' for i in range(4) for pose in (0,1,2)]:
    assert (WORK/name).is_file(),name
    shutil.copy2(WORK/name,HERE/'captures'/name)
report['performance']=[]
for label in ('bath-perf-old','bath-perf-finalc'):
    timing=json.loads((WORK/(label+'.json')).read_text())
    if label.endswith('finalc'):assert timing['runtime_sha256']==report['runtime_sha256']
    report['performance'].append(timing)
    for suffix in ('.json','.txt'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ('runs','performance')}))
