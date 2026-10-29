"""Preserve selected native evidence and verify the final package against source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410-kitchen'
LABELS=['final-census','final-core','final-formal','final-hub','kitchen-clock-01',
        'kitchen-pickup-03','kitchen-purchase-03','kitchen-seed-01','final-existing-save',
        'ration-core-01','ration-clock-01','ration-travel-01','ration-container-01',
        'old-food-seed01','final-old-save','old-food-rollback01',
        'kitchen-digestion-03','kitchen-digestion-control-03',
        'kitchen-capture-es04','kitchen-capture-en04','final-manual-smoke']

def main():
    target=HERE/'native';target.mkdir(exist_ok=True)
    runs=[]
    for label in LABELS:
        text=(WORK/(label+'.txt')).read_text(encoding='utf-8')
        assert not re.search(r'CA410[FK] FAIL|Script error|VM execution aborted|Fatal:',text),label
        metadata=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert metadata['exit_code']==0 and not metadata.get('timed_out',False),label
        runs.append({'label':label,'executed_passes':len(re.findall(r'^CA410[FK] PASS ',text,re.M)),
                     'runtime_sha256':metadata['package_sha256'].lower()})
        for suffix in ('.txt','-run.json'):shutil.copyfile(WORK/(label+suffix),target/(label+suffix))
    def digestion(label):
        text=(WORK/(label+'.txt')).read_text(encoding='utf-8')
        return tuple(float(v) for v in re.search(r'DIGESTION actual=([-0-9.]+) expected=([0-9.]+)',text).groups())
    actual,expected=digestion('kitchen-digestion-03');control,_=digestion('kitchen-digestion-control-03')
    assert abs(actual-control-expected)<0.00001,(actual,control,expected)
    performance=[]
    for label in ('kitchen-perf-old500','kitchen-perf-new500'):
        performance.append(json.loads((WORK/(label+'.json')).read_text(encoding='utf-8')))
        for suffix in ('.json','.txt'):shutil.copyfile(WORK/(label+suffix),target/(label+suffix))
    captures=HERE/'captures';captures.mkdir(exist_ok=True)
    for source,dest in [('kitchen-gallery-es04.png','gallery-es.png'),('kitchen-inventory-es04.png','inventory-es.png'),
                        ('kitchen-gallery.png','gallery-en.png'),('kitchen-inventory.png','inventory-en.png')]:
        shutil.copyfile(WORK/source,captures/dest)
    package=WORK/'current03/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        names=archive.namelist();assert len(names)==len(set(names))
        for name in names:assert archive.read(name)==(ROOT/'src'/name).read_bytes(),name
        assert set(names)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
        with zipfile.ZipFile(WORK/'current01/caelum_argenteum_dev.pk3') as earlier:
            changed=[name for name in names if archive.read(name)!=earlier.read(name)]
    report={'issue':410,'version':'5.8.17','runtime_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
            'source_matching_members':len(names),'native_passes':sum(r['executed_passes'] for r in runs),
            'native_failures':0,'runs':runs,'performance':performance,'current01_to_current03_changed_members':changed,
            'digestion':{'gross_recovery':actual-control,'approved_recovery':expected,'control_drain':control,'passed':True},
            'author_acceptance':'Pending CA410-INGREDIENTS-01; physical key receipt and art await author'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k not in ('runs','performance')}))

if __name__=='__main__':main()
