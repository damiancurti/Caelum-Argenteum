"""Collect frozen #385 native evidence without counting diagnostic failures."""
from pathlib import Path
import hashlib
import importlib.util
import json
import math
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue385'
spec=importlib.util.spec_from_file_location('prior_evidence',ROOT/'assets/validation_5610/collect.py')
prior=importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
sha,redact,clean=prior.sha,prior.redact,prior.clean

def main():
    (HERE/'native').mkdir(exist_ok=True)
    labels=['suite-final-01','regression-final-01','active-final-01','paused-final-01',
        'save-final-01','reload-final-01','travel-final-01','resume-final-01',
        'completed-reload-final-01','legacy-final-01','upgrade-final-02',
        'upgraded-reload-final-02','rollback-final-01','perf-final-01']
    runs=[]
    for label in labels:
        path=WORK/(label+'.txt');log=path.read_text(encoding='utf-8',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0 and not record.get('timed_out'),label
        assert not re.search(r'CA(?:385|383|377) FAIL|Script error|VM execution aborted|failures=[1-9]|failed=[1-9]|This savegame needs|DIED WITH FATAL ERROR|Cannot find savegame',log),label
        assert re.search(r'CA(?:385|383|377) (?:RESULT|LEGACY)',log),label
        assert sha(WORK/record['runtime']/'caelum_argenteum_dev.pk3')==record['package_sha256'].lower(),label
        addon='legacy-checks.pk3' if record['runtime']=='baseline' else 'checks.pk3'
        assert sha(WORK/addon)==record['addon_sha256'].lower(),label
        (HERE/'native'/(label+'.txt')).write_text(clean(log),encoding='utf-8',newline='\n')
        runs.append(dict(label=label,record=redact(record),passes=len(re.findall(r'CA(?:385|383|377) PASS ',log)),raw_log_sha256=sha(path)))
    package=WORK/'current/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        names=archive.namelist()
        for name in names:
            assert archive.read(name).replace(b'\r\n',b'\n')==(ROOT/'src'/name).read_bytes().replace(b'\r\n',b'\n'),name
        assert set(names)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    generated=ROOT/'src/caelum/data/CaelumShopCatalogue.zs';before=sha(generated)
    subprocess.run(['python',str(ROOT/'assets/generators/generate_shop_catalogue.py')],check=True)
    assert before==sha(generated)
    validation=json.loads(subprocess.check_output(['python','validate_project.py'],cwd=ROOT,text=True,encoding='utf-8'))
    assert not validation['errors']
    (HERE/'project-validation.json').write_text(json.dumps(validation,indent=2)+'\n',encoding='utf-8')
    diagnostics=[]
    for label in ['smoke-initial-01','suite-initial-01','suite-initial-02','suite-initial-03','suite-initial-04','upgrade-final-01','upgraded-reload-final-01']:
        path=WORK/(label+'.txt');record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        (HERE/'native'/('diagnostic-'+label+'.txt')).write_text(clean(path.read_text(encoding='utf-8',errors='replace')),encoding='utf-8')
        diagnostics.append(dict(label=label,record=redact(record),raw_log_sha256=sha(path),counts_as_passing=False))
    perf=(WORK/'perf-final-01.txt').read_text(encoding='utf-8',errors='replace')
    frames=[float(x) for x in re.findall(r'CA383 FRAME ([\d.]+)',perf)]
    ordered=sorted(frames);assert len(frames)>100 and 'CA383 FRAMES_END' in perf
    def percentile(q):return ordered[math.ceil(q*(len(ordered)-1))]
    performance=dict(frames=len(frames),mean_fps=1000/(sum(frames)/len(frames)),p50_ms=percentile(.5),p95_ms=percentile(.95),p99_ms=percentile(.99),max_ms=max(frames),
        scope='Ten-second isolated library RenderOverlay intervals; not OS presentation or city/mansion acceptance',
        setup=re.search(r'CA385 PERF products=.*',perf)[0])
    report=dict(issue=385,version='5.6.11',base_commit='e38871f5',package_sha256=sha(package),source_member_count=len(names),
        runs=runs,native_runs=len(runs),passes=sum(r['passes'] for r in runs),failures=0,diagnostics=diagnostics,
        generator_sha256=before,performance=performance,saves={p.name:sha(p) for p in WORK.glob('ca385-*.zds')},
        author_acceptance='CA385-01 pending',limitations=['Single-player calendar authority only.','Render callbacks do not prove OS frame presentation.','Worn/preview/first-person clothing is #387.'])
    (HERE/'report.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['native_runs','passes','failures','package_sha256','performance']}))
if __name__=='__main__':main()
