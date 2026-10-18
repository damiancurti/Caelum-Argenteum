"""Preserve #325 native evidence and gate the final production matrix."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
required={
    'issue325-final01':set('cloud clearnegative safety bag bed effect0 effect1 effect2 effect3 effect4 effect5 attack regeneration forecast danger0 danger1 death0 death1 save load ruloreset mapstation mapfurniture'.split()),
    'issue325-final02':set('legacy cloud jump-ascent jump-descent jump-immobilized'.split())}
records=[]
for source in sorted((ROOT/'build').glob('issue325-*')):
    if not source.is_dir() or not (source/'production.pk3').exists():continue
    target=HERE/'evidence'/source.name;target.mkdir(parents=True,exist_ok=True)
    for fixture in ['quick.pk3','jump.pk3']:
        if not (source/fixture).exists():continue
        with zipfile.ZipFile(source/fixture) as z:
            for name in z.namelist():
                if name.endswith('.zs') or name in ('ZSCRIPT','MAPINFO','CVARINFO','LANGUAGE'):
                    p=target/(fixture+'.sources')/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
    for p in sorted(source.iterdir()):
        if p.suffix=='.txt':
            raw=p.read_bytes();text=raw.decode('utf-8','replace')
            (target/(p.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
            record={'directory':source.name,'label':p.stem,'sha256':sha(raw),
                'passes':len(re.findall(r'^CA282 PASS ',text,re.M)),
                'failures':len(re.findall(r'^CA282 FAIL ',text,re.M)),
                'final':p.stem in required.get(source.name,set())}
            if record['final']:
                run=json.loads((source/(p.stem+'-run.json')).read_text(encoding='utf-8-sig'))
                manifest=json.loads((source/'manifest.json').read_text())
                assert run['exit_code']==0 and run['runtime_sha256'].lower()==manifest['runtime_sha256'],record
                fixture='jump.pk3' if p.stem.startswith('jump-') else 'quick.pk3'
                assert run['fixture_sha256'].lower()==sha((source/fixture).read_bytes()),record
                done=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',text)
                assert done and tuple(map(int,done[-1]))==(record['passes'],0) and record['failures']==0,record
                assert not re.search(r'Script error|VM execution aborted|DIED WITH FATAL ERROR',text),record
            records.append(record)
        elif p.suffix in ('.json','.cfg','.png'):(target/p.name).write_bytes(p.read_bytes())
        elif p.suffix=='.zds':(target/(p.name+'.sha256')).write_text(sha(p.read_bytes())+'\n')
final=[r for r in records if r['final']]
assert {(r['directory'],r['label']) for r in final}=={(folder,label) for folder,labels in required.items() for label in labels}
with zipfile.ZipFile(ROOT/'build/issue325-final01/production.pk3') as matrix,zipfile.ZipFile(ROOT/'build/issue325-final02/production.pk3') as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(matrix.namelist())==set(tested.namelist())==set(normal.namelist())==set(expected)
    assert all(tested.read(n)==normal.read(n)==p.read_bytes() for n,p in expected.items())
    changed={n for n in expected if matrix.read(n)!=tested.read(n)}
    assert changed=={'LANGUAGE','localization/INDEX.md','localization/index.json','caelum/world/CaelumRestSafety.zs'},changed
    assert matrix.read('LANGUAGE').replace(b'est? activa','está activa'.encode())==tested.read('LANGUAGE')
    name='caelum/world/CaelumRestSafety.zs'
    assert matrix.read(name).replace(b'peri?dico','periódico'.encode())==tested.read(name)
result={'issue':325,'release':'5.4.40','runs':records,'final_runs':len(final),
    'final_passes':sum(r['passes'] for r in final),'normal_package_members':len(expected),
    'matrix_to_final_only_text_and_localization_index':sorted(changed),
    'normal_equals_tested_source':True,'author_acceptance':'CA325-01 accepted 2026-10-18; explicit rest approval; no reported qualifications'}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='runs'}))
