"""Preserve focused #321 evidence without runtime/IWAD/save files."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
OUT=HERE/'evidence'
OUT.mkdir(exist_ok=True)
records=[]
for folder in ('issue321-panel01',):
    source=ROOT/'build'/folder
    target=OUT/folder
    target.mkdir(exist_ok=True)
    with zipfile.ZipFile(source/'quick.pk3') as package:
        (target/'probe.zs').write_bytes(package.read('probe.zs'))
    for p in sorted(source.iterdir()):
        if p.suffix=='.txt':
            raw=p.read_bytes()
            (target/(p.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
            text=raw.decode('utf-8','replace')
            records.append({'directory':folder,'log':p.name,'sha256':hashlib.sha256(raw).hexdigest(),
                'passed':len(re.findall(r'^CA282 PASS ',text,re.M)),
                'failed':len(re.findall(r'^CA282 FAIL ',text,re.M)),
                'done':bool(re.search(r'CA282 DONE passes=\d+ failures=0',text))})
        elif p.suffix in ('.json','.cfg'):
            (target/p.name).write_bytes(p.read_bytes())
        elif p.suffix=='.png' and folder=='issue321-panel01':
            (target/p.name).write_bytes(p.read_bytes())
runtime=ROOT/'build/issue321-panel01/production.pk3'
with zipfile.ZipFile(runtime) as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    expected={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(tested.namelist())==set(normal.namelist())==set(expected)
    assert all(tested.read(n)==normal.read(n)==raw for n,raw in expected.items())
current=[r for r in records if r['directory']=='issue321-panel01']
assert len(current)==5 and all(r['done'] and r['failed']==0 for r in current)
result={'issue':321,'release':'5.4.38','runs':records,
    'final_passes':sum(r['passed'] for r in current),
    'normal_package_members':len(expected),'normal_equals_tested_source':True,
    'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),
    'fixture_sha256':hashlib.sha256((runtime.parent/'quick.pk3').read_bytes()).hexdigest(),
    'saved_game_sha256':hashlib.sha256((runtime.parent/'legend.zds').read_bytes()).hexdigest(),
    'author_acceptance':'pending CA321-02'}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='runs'}))
