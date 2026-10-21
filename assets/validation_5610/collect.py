"""Collect final #383 evidence and retain failed diagnostics separately."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue383'
def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def redact(value):
    if isinstance(value,list):return [redact(v) for v in value]
    if isinstance(value,dict):return {k:redact(v) for k,v in value.items()}
    if not isinstance(value,str):return value
    value=value.replace(str(ROOT),'<repo>').replace(ROOT.as_posix(),'<repo>')
    value=value.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe','<engine>')
    value=re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD','<iwad>',value,flags=re.I)
    return re.sub(r'C:\\Users\\[^\\\s]+','<user>',value,flags=re.I)
def clean(text):return '\n'.join(line.rstrip() for line in redact(text).splitlines()).rstrip()+'\n'
def main():
    (HERE/'native').mkdir(exist_ok=True)
    labels=['suite-final-02','regression-final-02','save-final-02','reload-final-02','travel-final-02',
        'city-final-01','legacy-city-01','upgrade-final-01','upgraded-reload-final-01','rollback-final-01',
        'ui-es-final-01','ui-en-final-01','perf-final-01']
    runs=[]
    for label in labels:
        path=WORK/(label+'.txt');log=path.read_text(encoding='utf-8',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0 and not record.get('timed_out'),label
        assert not re.search(r'CA(?:383|377) FAIL|Script error|VM execution aborted|failures=[1-9]',log),label
        assert sha(WORK/record['runtime']/'caelum_argenteum_dev.pk3')==record['package_sha256'].lower(),label
        addon='legacy-checks.pk3' if record['runtime']=='baseline' else 'checks.pk3'
        assert sha(WORK/addon)==record['addon_sha256'].lower(),label
        (HERE/'native'/(label+'.txt')).write_text(clean(log),encoding='utf-8',newline='\n')
        runs.append(dict(label=label,record=redact(record),passes=len(re.findall(r'CA(?:383|377) PASS ',log)),raw_log_sha256=sha(path)))
    package=WORK/'current/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        names=archive.namelist()
        for name in names:
            assert archive.read(name).replace(b'\r\n',b'\n')==(ROOT/'src'/name).read_bytes().replace(b'\r\n',b'\n'),name
        assert set(names)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    files=[ROOT/'src/caelum/data/CaelumShopCatalogue.zs',*sorted((ROOT/'src/graphics/caelum/shop_signs').glob('CASG*.png'))]
    before={str(p.relative_to(ROOT)):sha(p) for p in files}
    subprocess.run(['python',str(ROOT/'assets/generators/generate_shop_catalogue.py')],check=True)
    subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(ROOT/'assets/generators/generate_shop_signs.ps1')],check=True)
    assert before=={str(p.relative_to(ROOT)):sha(p) for p in files}
    for i in range(6):
        name=f'src/graphics/caelum/shop_signs/CASG{i:02}.png'
        assert subprocess.check_output(['git','show','c492a1bc:'+name],cwd=ROOT)==(ROOT/name).read_bytes()
    validation=json.loads(subprocess.check_output(['python','validate_project.py'],cwd=ROOT,text=True,encoding='utf-8'))
    assert not validation['errors']
    (HERE/'project-validation.json').write_text(json.dumps(validation,indent=2)+'\n',encoding='utf-8')
    for name in ['library-es.png','library-en.png']:shutil.copy2(WORK/name,HERE/name)
    diagnostics=[]
    for label in ['smoke-initial-01','suite-initial-01','suite-initial-02','travel-final-01']:
        path=WORK/(label+'.txt');record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        (HERE/'native'/('diagnostic-'+label+'.txt')).write_text(clean(path.read_text(encoding='utf-8',errors='replace')),encoding='utf-8')
        diagnostics.append(dict(label=label,record=redact(record),raw_log_sha256=sha(path),counts_as_passing=False))
    perf=(WORK/'perf-final-01.txt').read_text(encoding='utf-8',errors='replace')
    frames=[float(x) for x in re.findall(r'CA383 FRAME ([\d.]+)',perf)]
    ordered=sorted(frames)
    assert len(frames)>100 and 'CA383 FRAMES_END' in perf
    def percentile(q):return ordered[math.ceil(q*(len(ordered)-1))]
    performance=dict(frames=len(frames),mean_fps=1000/(sum(frames)/len(frames)),p50_ms=percentile(.5),p95_ms=percentile(.95),p99_ms=percentile(.99),max_ms=max(frames),
        scope='Ten-second isolated open-library RenderOverlay frame intervals, not OS presentation or large-map acceptance',
        setup=re.search(r'CA383 PERF seed_ms=.*',perf)[0])
    report=dict(issue=383,version='5.6.10',base_commit='c492a1bc',package_sha256=sha(package),source_member_count=len(names),
        runs=runs,native_runs=len(runs),passes=sum(r['passes'] for r in runs),failures=0,diagnostics=diagnostics,
        generator_hashes=before,performance=performance,saves={p.name:sha(p) for p in WORK.glob('ca383-*.zds')},
        author_acceptance='CA383-01 pending',limitations=['Stock replenishment is #385.','Worn/preview/first-person clothing is #387.'])
    (HERE/'report.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['native_runs','passes','failures','package_sha256','performance']}))
if __name__=='__main__':main()
