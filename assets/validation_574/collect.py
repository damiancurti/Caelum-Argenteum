"""Collect immutable #470 logs, source hashes and bounded performance evidence."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue470'
FINAL=['verified-'+name for name in ['network','crafting','upgrade-mansion',
    'upgrade-city','upgrade-load','travel','blocked-save','blocked-load',
    'removed-save','removed-load','task-upgrade','manual-mansion','manual-city',
    'task-current-save','task-current-load']]
PERF=['perf-mansion-before','perf-mansion-after','perf-city-before','perf-city-after']


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def distribution(values):
    ordered=sorted(values)
    return {'count':len(values),'mean_ms':sum(values)/len(values),
        'p95_ms':ordered[math.ceil(len(values)*.95)-1],
        'p99_ms':ordered[math.ceil(len(values)*.99)-1],'worst_ms':max(values)}


def main():
    native=HERE/'native';native.mkdir(exist_ok=True)
    package=WORK/'current/caelum_argenteum_dev.pk3'
    package_hash=sha(package)
    runs=[];total=0;performance=[]
    for meta in sorted(WORK.glob('*-run.json')):
        record=json.loads(meta.read_text(encoding='utf-8-sig'))
        label=record['label'];log=WORK/f'{label}.txt'
        if not log.exists():continue
        text=log.read_text(encoding='utf-8',errors='replace')
        passed=len(re.findall(r'CA(?:470|376) PASS ',text))
        failed=len(re.findall(r'CA(?:470|376) FAIL ',text))
        selected=label in FINAL
        if selected:
            assert record['exit_code']==0 and not record.get('timed_out'),label
            assert passed>0 and failed==0,label
            assert not re.search(r'Script error|VM execution aborted|failed=[1-9]|Cannot find savegame|This savegame needs',text),label
            assert record['package_sha256'].lower()==package_hash,label
            total+=passed
        shutil.copy2(log,native/log.name)
        runs.append({**record,'selected':selected,'passed':passed,'failed':failed,'log_sha256':sha(log)})
        if label in PERF:
            assert record['exit_code']==0 and record.get('visible_requested'),label
            frames=list(map(float,re.findall(r'CA470 FRAME ms=([\d.]+)',text)))
            elapsed=float(re.search(r'CA470 PERF elapsed_ms=([\d.]+)',text)[1])
            timing=float(re.search(r'authored_network_1000_ms=([\d.]+)',text)[1])
            performance.append({'label':label,'render_callbacks':distribution(frames),
                'render_callback_fps':len(frames)*1000/sum(frames),
                'simulation_tics_per_second':525000/elapsed,'network_1000_ms':timing,
                'presentation':'Unavailable: Windows denied PresentMon trace access; callbacks are not display/presentation intervals.'})
            pm=WORK/f'{label}-presentmon.txt'
            if pm.exists():shutil.copy2(pm,native/pm.name)
    assert {r['label'] for r in runs if r['selected']}==set(FINAL)
    assert len(performance)==4
    with zipfile.ZipFile(package) as z:
        files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(z.namelist())==set(files)
        for name,p in files.items():assert z.read(name)==p.read_bytes(),name
        members=len(files)
    originals=json.loads((WORK/'original-saves.json').read_text(encoding='utf-8'))
    for name,digest in originals.items():assert sha(WORK/name)==digest,name
    visuals=HERE/'visuals';visuals.mkdir(exist_ok=True)
    for name in ('mansion-view','mansion-menu','city-view','city-menu','hidden-view'):
        shutil.copy2(WORK/f'{name}.png',visuals/f'{name}.png')
    report={'issue':470,'version':'5.7.4','selected_runs':len(FINAL),'passed':total,'failed':0,
        'package_sha256':package_hash,'source_matching_members':members,'runs':runs,
        'original_saves':originals,'performance':performance,
        'author_acceptance':'CA470-01 passed by explicit author confirmation on 2026-10-22.',
        'scope':'Infrastructure only; Alchemy recipes remain #407/#409/#471. #472 drinking needs no station.'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k!='runs'},indent=2))


if __name__=='__main__':main()
