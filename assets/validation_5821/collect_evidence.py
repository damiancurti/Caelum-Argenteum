"""Collect executed native assertions and verify the packaged source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking'
HERE=Path(__file__).resolve().parent
runtime=sys.argv[1] if len(sys.argv)>1 else 'final21b'
package=WORK/runtime/'caelum_argenteum_dev.pk3'
labels=['camp-final-core','camp-final-hub','camp-final-seed','camp-final-resume',
        'camp-interrupt01','camp-guards01','camp-fast01','camp-input04',
        'camp-stove-seed20','camp-stove-old03','camp-stove-rollback20','camp-stove-core03']
if runtime=='final21b':labels+=['camp-finalb-hub']
files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(files)
    for name,path in files.items():assert archive.read(name)==path.read_bytes(),name
    allowed={'LANGUAGE','localization/INDEX.md','localization/index.json',
             'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs',
             'caelum/world/CaelumCampTent.zs'}
    differences={}
    for earlier in ('camp01','camp03','final21'):
        with zipfile.ZipFile(WORK/earlier/'caelum_argenteum_dev.pk3') as old:
            assert set(old.namelist())==set(files)
            changed=[name for name in files if old.read(name)!=archive.read(name)]
            assert set(changed)<=allowed,(earlier,changed)
            differences[earlier]=changed
report={'issue':411,'version':'5.8.21','runtime':runtime,
        'runtime_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
        'source_matching_members':len(files),'native_passes':0,'native_failures':0,
        'earlier_probe_differences':differences,'runs':[],
        'author_check':'CA411-COOKING-01','author_acceptance':'pending'}
(HERE/'native').mkdir(exist_ok=True)
for label in labels:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    count=len(re.findall(r'^CA41[01][BFMKC] PASS ',log,re.M))
    assert count and not re.search(r'^CA41[01][BFMKC] FAIL |Script error|VM execution aborted|Fatal:|fail(?:ed|ures)=[1-9]',log,re.M),label
    if label=='camp-input04':
        assert 'Captured camp-input-audit.png' in log and 'real menu keyboard starts selected fish cooking' in log
    else:assert run.get('exit_code')==0,label
    report['native_passes']+=count
    report['runs'].append({'label':label,'executed_passes':count,'runtime_sha256':run['package_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
blob=(WORK/'static21.json').read_bytes()
static=json.loads(blob.decode('utf-16' if blob.startswith((b'\xff\xfe',b'\xfe\xff')) else 'utf-8-sig'))
assert not static['errors'],static['errors'];report['static_errors']=[]
(HERE/'captures').mkdir(exist_ok=True)
shutil.copy2(WORK/'camp-input-audit.png',HERE/'captures/camp-progress-es.png')
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({key:report[key] for key in ('runtime_sha256','source_matching_members','native_passes','native_failures')}))
