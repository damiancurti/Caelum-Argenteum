"""Collect the selected executed checks and verify the exact delivered source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking'
HERE=Path(__file__).resolve().parent
LABELS=('fixtures-final-core','fixtures-final-mansion-c','fixtures-resume05',
        'fixtures-hub05','fixtures-house05','fixtures-oldsave05','fixtures-original19','fixtures-locale20b')
package=WORK/'final20b/caelum_argenteum_dev.pk3'
files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(files)
    for name,path in files.items():assert archive.read(name)==path.read_bytes(),name
    with zipfile.ZipFile(WORK/'fixtures05/caelum_argenteum_dev.pk3') as earlier:
        changed=[name for name in files if earlier.read(name)!=archive.read(name)]
expected={'LANGUAGE','caelum/data/CaelumKitchenFixtureData.zs','caelum/data/kitchen_fixtures.textures',
          'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs',
          'models/caelum/props/kitchen_fixtures/locked.obj'}
assert set(changed)<=expected,changed
report={'issue':410,'version':'5.8.20','runtime_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
        'source_matching_members':len(files),'native_passes':0,'native_failures':0,'runs':[],
        'earlier_probe_differences':changed,'author_check':'CA410-FIXTURES-01','author_acceptance':'pending'}
(HERE/'native').mkdir(exist_ok=True)
for label in LABELS:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    passed=len(re.findall(r'^CA410[BFMKC] PASS ',log,re.M))
    assert passed and run['exit_code']==0,label
    assert not re.search(r'^CA410[BFMKC] FAIL |Script error|VM execution aborted|Fatal:|fail(?:ed|ures)=[1-9]',log,re.M),label
    report['native_passes']+=passed
    report['runs'].append({'label':label,'executed_passes':passed,'runtime_sha256':run['package_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
(HERE/'captures').mkdir(exist_ok=True)
for name in ('kitchen-fixtures.png','kitchen-fixtures-sprites.png'):shutil.copy2(WORK/name,HERE/'captures'/name)
blob=(WORK/'static20b.json').read_bytes()
static=json.loads(blob.decode('utf-16' if blob.startswith((b'\xff\xfe',b'\xfe\xff')) else 'utf-8-sig'))
assert not static['errors'],static['errors'];report['static_errors']=static['errors']
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({key:report[key] for key in ('runtime_sha256','source_matching_members','native_passes','native_failures','earlier_probe_differences')}))
