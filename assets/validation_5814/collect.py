"""Collect executed assertions and retain native evidence without altering logs."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue410-lots'
LABELS = ['final-core', 'final-clock', 'final-travel-commit', 'final-hub',
          'final-seed', 'final-load', 'final-upgrade', 'oldseed06b',
          'rollback06b', 'final-capture-es2', 'final-capture-en']

def main():
    target=HERE/'native'; target.mkdir(exist_ok=True)
    runs=[]
    for label in LABELS:
        log=WORK/(label+'.txt')
        text=log.read_text(encoding='utf-8')
        assert not re.search(r'CA410F FAIL|Script error|VM execution aborted|Fatal:', text),label
        passes=len(re.findall(r'^CA410F PASS ',text,re.M)); assert passes,label
        metadata=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert metadata['exit_code']==0 and not metadata.get('timed_out',False),label
        runs.append({'label':label,'executed_passes':passes,'package_sha256':metadata['package_sha256'].lower()})
        for suffix in ('.txt','-run.json'):
            shutil.copyfile(WORK/(label+suffix),target/(label+suffix))
    performance=[]
    for label in ('perf-old500','perf-final500'):
        result=json.loads((WORK/(label+'.json')).read_text())
        performance.append(result)
        for suffix in ('.json','.txt'):
            shutil.copyfile(WORK/(label+suffix),target/(label+suffix))
    package=WORK/'final01/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        members=archive.namelist()
        assert len(members)==len(set(members))
        for name in members:
            assert archive.read(name)==(ROOT/'src'/name).read_bytes(),name
        assert set(members)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    report={'issue':410,'version':'5.8.14','runtime_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
            'source_matching_members':len(members),'native_passes':sum(r['executed_passes'] for r in runs),
            'native_failures':0,'runs':runs,'performance':performance,'author_acceptance':'pending CA410-FOOD-01'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    shutil.copyfile(WORK/'static-final.json',HERE/'static.json')
    print(json.dumps({k:v for k,v in report.items() if k not in ('runs','performance')}))

if __name__=='__main__':
    main()
