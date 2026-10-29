"""Retain executed native assertions, compatibility evidence and package identity."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue412-bags'
LABELS=['final-core','final-fast','final-guard','final-seed','final-load',
        'old-seed','final-upgrade','original-rollback','final-capture',
        'original-repro','final-repro']
def main():
    native=HERE/'native';native.mkdir(exist_ok=True);runs=[]
    for label in LABELS:
        text=(WORK/(label+'.txt')).read_text(encoding='utf-8')
        assert not re.search(r'CA412B FAIL|CA411D FAIL|Script error|VM execution aborted|Fatal:',text),label
        passes=len(re.findall(r'^CA(?:412B|411D) PASS ',text,re.M));assert passes,label
        metadata=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert metadata['exit_code']==0 and not metadata.get('timed_out',False),label
        runs.append({'label':label,'executed_passes':passes,'runtime_sha256':metadata['package_sha256'].lower()})
        for suffix in ('.txt','-run.json'):shutil.copyfile(WORK/(label+suffix),native/(label+suffix))
    performance=[]
    for label in ('perf-old','perf-final'):
        performance.append(json.loads((WORK/(label+'.json')).read_text()))
        for suffix in ('.json','.txt'):shutil.copyfile(WORK/(label+suffix),native/(label+suffix))
    package=WORK/'final02/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        members=archive.namelist();assert len(members)==len(set(members))
        for name in members:assert archive.read(name)==(ROOT/'src'/name).read_bytes(),name
        assert set(members)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    vertices=[tuple(map(float,line.split()[1:])) for line in (ROOT/'src/models/caelum/props/rest/ca_rest_bag_open.obj').read_text().splitlines() if line.startswith('v ')]
    bounds=[(min(v[i] for v in vertices),max(v[i] for v in vertices)) for i in range(3)]
    assert bounds==[(-20,20.4),(0,8),(-44,44)]
    report={'issue':412,'version':'5.8.15','runtime_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
        'source_matching_members':len(members),'native_passes':sum(r['executed_passes'] for r in runs),
        'native_failures':0,'runs':runs,'performance':performance,'model_obj_bounds':bounds,
        'author_acceptance':'pending CA412-BAG-01','cooperative_admission_and_clock':'not implemented'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    static=json.loads((WORK/'static-final.json').read_text(encoding='utf-16' if (WORK/'static-final.json').read_bytes().startswith(b'\xff\xfe') else 'utf-8-sig'))
    assert not static['errors'];(HERE/'static.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
    captures=HERE/'captures';captures.mkdir(exist_ok=True);shutil.copyfile(WORK/'tent-bag.png',captures/'two-bag-envelopes-roof-hidden.png')
    print(json.dumps({k:v for k,v in report.items() if k not in ('runs','performance')}))
if __name__=='__main__':main()
