"""Archive #323 native runs without distributing packages, saves or IWADs."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
records=[]
for folder in ('issue323-before','issue323-before02','issue323-final02','issue323-recovery03'):
    source=ROOT/'build'/folder
    target=HERE/'evidence'/folder
    target.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(source/'quick.pk3') as package:
        for name in ('probe.zs','data.zs'):(target/name).write_bytes(package.read(name))
    for p in sorted(source.iterdir()):
        if p.suffix=='.txt':
            raw=p.read_bytes();(target/(p.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
            text=raw.decode('utf-8','replace')
            records.append({'directory':folder,'log':p.name,'sha256':hashlib.sha256(raw).hexdigest(),
                'passed':len(re.findall(r'^CA282 PASS ',text,re.M)),
                'failed':len(re.findall(r'^CA282 FAIL ',text,re.M)),
                'done':bool(re.search(r'CA282 DONE passes=\d+ failures=0',text)),
                'measurements':re.findall(r'^CA323 (?:GEOMETRY|MOVED) .*',text,re.M)})
        elif p.suffix in ('.json','.cfg'):(target/p.name).write_bytes(p.read_bytes())
runtime=ROOT/'build/issue323-final02/production.pk3'
with zipfile.ZipFile(runtime) as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal,zipfile.ZipFile(ROOT/'build/issue323-recovery03/production.pk3') as recovery:
    expected={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(tested.namelist())==set(normal.namelist())==set(recovery.namelist())==set(expected)
    assert all(tested.read(n)==normal.read(n)==raw for n,raw in expected.items())
    assert [n for n in tested.namelist() if tested.read(n)!=recovery.read(n)]==['maps/MAP02.wad']
    assert recovery.read('maps/MAP02.wad')==(ROOT/'assets/map02_maze/legacy_5432/MAP02.wad').read_bytes()
current=[r for r in records if r['directory']=='issue323-final02']
baseline=[r for r in records if r['directory']=='issue323-before02']
recovery=[r for r in records if r['directory']=='issue323-recovery03']
assert len(current)==7 and len(baseline)==4 and len(recovery)==2
assert all(r['done'] and r['failed']==0 for r in current+baseline+recovery)
result={'issue':323,'release':'5.4.33','runs':records,
    'current_passes':sum(r['passed'] for r in current),
    'baseline_passes':sum(r['passed'] for r in baseline),
    'recovery_passes':sum(r['passed'] for r in recovery),
    'normal_package_members':len(expected),'normal_equals_tested_source':True,
    'recovery_only_changes_exact_old_map':True,
    'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),
    'fixture_sha256':hashlib.sha256((runtime.parent/'quick.pk3').read_bytes()).hexdigest(),
    'baseline_ref':'6502e4c0','author_acceptance':'pending CA323-01'}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in result.items() if k!='runs'}))
