"""Collect immutable #405 native results, source identities and presentation samples."""
from pathlib import Path
import hashlib,json,re,shutil,statistics,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue405'
FINAL=['final-suite','final-trade','final-use','final-cut','final-save','final-travel','final-upgrade','final-mapupgrade','final-mapreload','final-map03','final-map03-reload2','final-gallery','final-closeups','perf-baseline','perf-current']
EXPLORATORY=['compile-01','compile-02','compile-03','compile-04','suite-01','travel-01','mapupgrade-01','mapupgrade-02','final-map03-reload','legacy-01','rollback-01','upgrade-load-01']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    native=HERE/'native';native.mkdir(exist_ok=True)
    runs=[];passed=0
    for label in FINAL+EXPLORATORY:
        log=WORK/f'{label}.txt';meta=WORK/f'{label}-run.json'
        if not log.exists() or not meta.exists():continue
        text=log.read_text(encoding='utf-8',errors='replace')
        record=json.loads(meta.read_text(encoding='utf-8-sig'))
        checks=re.findall(r'CA405 RESULT passed=(\d+) failed=(\d+)',text)
        count=int(checks[-1][0]) if checks else 0
        if label in FINAL:
            assert record['exit_code']==0 and not record.get('timed_out'),label
            assert not re.search(r'CA405 FAIL|Script error|VM execution aborted|failed=[1-9]',text),label
            assert checks or 'CA405 LEGACY' in text,label
            passed+=count
        frames=[float(n) for n in re.findall(r'CA405 FRAME ([\d.]+)',text)]
        timing=None
        if frames:
            ordered=sorted(frames)
            timing=dict(callbacks=len(frames),mean_fps=1000/statistics.mean(frames),
                p95_ms=ordered[int(.95*(len(frames)-1))],p99_ms=ordered[int(.99*(len(frames)-1))],worst_ms=max(frames))
            marks=re.findall(r'CA405 PERF (BEGIN|END) tic=(\d+) ms=([\d.]+)',text)
            if len(marks)==2:timing['simulation_tics_per_second']=(int(marks[1][1])-int(marks[0][1]))*1000/(float(marks[1][2])-float(marks[0][2]))
        shutil.copy2(log,native/log.name)
        runs.append(dict(label=label,selected=label in FINAL,passed=count,record=record,presentation=timing,log_sha256=digest(log)))
    package=WORK/'current/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as z:
        mismatches=[]
        for p in (ROOT/'src').rglob('*'):
            if p.is_file():
                name=p.relative_to(ROOT/'src').as_posix()
                if z.read(name)!=p.read_bytes():mismatches.append(name)
        assert not mismatches,mismatches
        members=len(z.namelist())
    for name in ['gallery-front.png','gallery-side.png','hive-close.png','marcela-close.png']:
        shutil.copy2(WORK/name,HERE/name)
    validation=subprocess.run([sys.executable,'validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',check=True)
    (HERE/'project-validation.json').write_text(validation.stdout,encoding='utf-8')
    report=dict(issue=405,version='5.7.2',base='b425c0aa',package_sha256=digest(package),
        package_members=members,source_byte_match=True,selected_runs=len(FINAL),selected_passed=passed,runs=runs,
        author_acceptance='CA405-01 pending',performance_limit='Application frame callbacks; not OS presentation or mansion/sewer/siege acceptance.')
    (HERE/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['selected_runs','selected_passed','package_members','package_sha256','source_byte_match']}))
    for run in runs:
        if run['presentation']:print(run['label'],json.dumps(run['presentation']))
if __name__=='__main__':main()

