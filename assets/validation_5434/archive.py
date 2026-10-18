"""Archive #324 native evidence without packages, private saves or dependencies."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--final-directory',required=True)
    args=parser.parse_args()
    if not re.fullmatch(r'issue324-[a-z0-9_-]+',args.final_directory): parser.error('Expected an issue324 directory')
    records=[]
    for source in sorted((ROOT/'build').glob('issue324-*')):
        if not source.is_dir() or not (source/'manifest.json').exists(): continue
        target=HERE/'evidence'/source.name
        target.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(source/'quick.pk3') as package:
            (target/'probe.zs').write_bytes(package.read('probe.zs'))
        with zipfile.ZipFile(source/'production.pk3') as package:
            for path in ('caelum/world/CaelumAutosaveEvents.zs','caelum/data/CaelumSaveRules.zs'):
                (target/Path(path).name).write_bytes(package.read(path))
        for path in sorted(source.iterdir()):
            if path.name.startswith('author-preview'): continue
            if path.suffix=='.txt':
                raw=path.read_bytes()
                (target/(path.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
                log=raw.decode('utf-8','replace')
                meta=source/(path.stem+'-run.json')
                metadata=json.loads(meta.read_text(encoding='utf-8-sig')) if meta.exists() else {}
                records.append({'directory':source.name,'log':path.name,'sha256':hashlib.sha256(raw).hexdigest(),
                    'exit_code':metadata.get('exit_code'),'passed':len(re.findall(r'^CA282 PASS ',log,re.M)),
                    'failed':len(re.findall(r'^CA282 FAIL ',log,re.M)),
                    'done':bool(re.search(r'CA282 DONE passes=\d+ failures=0',log)),
                    'native_writes':len(re.findall(r'^Game saved\.',log,re.M)),
                    'measurements':re.findall(r'^CA324 (?:LONG|FAST|SAVED).*',log,re.M)})
            elif path.suffix in ('.json','.cfg'):
                (target/path.name).write_bytes(path.read_bytes())
    final=ROOT/'build'/args.final_directory
    current=[r for r in records if r['directory']==args.final_directory]
    expected_labels={'timer','load-timer','pause','menu','console','checkpoint','defer','queued-death',
        'travel','travel-disabled','roundtrip','direct-travel','native','native-paused','cancel-travel',
        'saved-travel','late-travel','late-invalid','consecutive','one-slot','fast','reload','disabled',
        'zero-slots','manual-save','slots','rulo','load-rulo','load-legacy','long','load-long'}
    expected_labels.update(f'travel-delay{i}' for i in range(5))
    assert {Path(r['log']).stem for r in current}==expected_labels
    assert all(r['exit_code']==0 and r['done'] and r['failed']==0 for r in current)
    file_checks=json.loads((final/'files.json').read_text())
    assert {r['label'] for r in file_checks}==expected_labels
    assert all(r['exit']==0 for r in file_checks)
    with zipfile.ZipFile(final/'production.pk3') as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
        expected={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(tested.namelist())==set(normal.namelist())==set(expected)
        assert all(tested.read(name)==normal.read(name)==data for name,data in expected.items())
    result={'issue':324,'release':'5.4.34','baseline_ref':'20857d9c','final_directory':args.final_directory,
        'runtime_sha256':hashlib.sha256((final/'production.pk3').read_bytes()).hexdigest(),
        'fixture_sha256':hashlib.sha256((final/'quick.pk3').read_bytes()).hexdigest(),
        'final_runs':len(current),'final_assertions':sum(r['passed'] for r in current),
        'normal_package_members':len(expected),'normal_equals_tested_source':True,'runs':records,
        'author_acceptance':'pending CA324-01'}
    (HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({key:value for key,value in result.items() if key!='runs'}))

if __name__=='__main__': main()
