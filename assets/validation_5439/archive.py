"""Gate and archive native #339 evidence; keep packages and private saves local."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
sha=lambda b:hashlib.sha256(b).hexdigest()
accepted={
    'issue339-final01':['ascent','descent','fall','push','excess','immobilized','controls','save','load','legacy','travel'],
    'issue339-baseline03':['ascent','descent','fall','push','excess','immobilized','save'],
    'issue339-extra01':['rules'], 'issue339-extra03':['native'], 'issue339-preview01':['smoke']}
records=[]
for source in sorted((ROOT/'build').glob('issue339-*')):
    if not source.is_dir():continue
    target=HERE/'evidence'/source.name;target.mkdir(parents=True,exist_ok=True)
    for name in ['quick.pk3','rules.pk3']:
        if not (source/name).exists():continue
        with zipfile.ZipFile(source/name) as z:
            for n in z.namelist():
                if n.endswith('.zs') or n in ('ZSCRIPT','MAPINFO','LANGUAGE','CVARINFO'):
                    p=target/(name+'.sources')/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(n))
    for p in sorted(source.iterdir()):
        raw=p.read_bytes() if p.suffix in ('.txt','.json','.cfg','.png','.zds') else None
        if p.suffix=='.txt':
            (target/(p.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
            text=raw.decode('utf-8','replace');passes=len(re.findall(r'^CA282 PASS ',text,re.M))
            failures=len(re.findall(r'^CA282 FAIL ',text,re.M))
            record={'directory':source.name,'label':p.stem,'sha256':sha(raw),'passes':passes,'failures':failures,'accepted':p.stem in accepted.get(source.name,[])}
            if record['accepted']:
                run=json.loads((source/(p.stem+'-run.json')).read_text(encoding='utf-8-sig'))
                manifest=json.loads((source/'manifest.json').read_text())
                assert run['exit_code']==0 and run['runtime_sha256'].lower()==manifest['runtime_sha256'],record
                fixture='rules.pk3' if p.stem=='rules' else 'quick.pk3'
                assert run['fixture_sha256'].lower()==sha((source/fixture).read_bytes()),record
                markers=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',text)
                assert markers and tuple(map(int,markers[-1]))==(passes,0) and failures==0,record
                assert not re.search(r'Script error|VM execution aborted|DIED WITH FATAL ERROR',text),record
            records.append(record)
        elif p.suffix in ('.json','.cfg','.png'):(target/p.name).write_bytes(raw)
        elif p.suffix=='.zds':(target/(p.name+'.sha256')).write_text(sha(raw)+'\n')
current=[r for r in records if r['accepted'] and r['directory']!='issue339-baseline03']
baseline=[r for r in records if r['accepted'] and r['directory']=='issue339-baseline03']
assert len(current)==14 and len(baseline)==7
with zipfile.ZipFile(ROOT/'build/issue339-final01/production.pk3') as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(tested.namelist())==set(normal.namelist())==set(expected)
    assert all(tested.read(n)==normal.read(n)==p.read_bytes() for n,p in expected.items())
result={'issue':339,'release':'5.4.39','runs':records,'current_passes':sum(r['passes'] for r in current),
    'baseline_passes':sum(r['passes'] for r in baseline),'normal_package_members':len(expected),
    'normal_equals_tested_source':True,'author_acceptance':'pending CA339-01'}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='runs'}))
