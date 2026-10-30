"""Match ETW presents to native windows; calibrate date mode against QPC."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import csv
import hashlib
import json
import statistics
import time
from record_results import archive, ROOT, HERE


def stats(values):
    if not values:
        return None
    values = sorted(values)
    return dict(samples=len(values), mean_ms=statistics.mean(values),
        p95_ms=values[int((len(values)-1)*.95)], p99_ms=values[int((len(values)-1)*.99)], max_ms=values[-1])


def epoch(value):
    return datetime.fromisoformat(value).replace(tzinfo=timezone.utc).timestamp()*1000


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dates',type=Path,required=True)
    parser.add_argument('--qpc',type=Path,required=True)
    args = parser.parse_args()
    with args.dates.open(encoding='utf-8-sig',newline='') as stream:
        dates = list(csv.DictReader(stream))
    with args.qpc.open(encoding='utf-8-sig',newline='') as stream:
        qpc = list(csv.DictReader(stream))
    # Both counters use QueryPerformanceCounter on Windows. Bracket UTC so its
    # calibration uncertainty is explicit rather than assuming CSV local time.
    q0=time.perf_counter()*1000;utc=time.time()*1000;q1=time.perf_counter()*1000
    qpc_to_utc=utc-(q0+q1)/2
    lookup={}
    for row in dates:
        key=(row['ProcessID'],row['MsBetweenPresents'])
        lookup.setdefault(key,[]).append(row)
    offsets=[]
    for row in qpc:
        matched=lookup.get((row['ProcessID'],row['MsBetweenPresents']),[])
        if len(matched)==1:
            offsets.append(float(row['CPUStartQPCTimeInMs'])+qpc_to_utc-epoch(matched[0]['CPUStartDateTime']))
    if len(offsets)<10 or max(offsets)-min(offsets)>1:
        raise SystemExit('Date/QPC alignment lacks sufficient unambiguous matches; do not guess timezone.')
    shift=statistics.median(offsets)
    report={'date_capture':archive(args.dates),'qpc_capture':archive(args.qpc),
        'calibration':dict(utc=datetime.now(timezone.utc).isoformat(),qpc_mid_ms=(q0+q1)/2,
            qpc_bracket_ms=q1-q0,date_to_utc_ms=shift,matches=len(offsets),offset_spread_ms=max(offsets)-min(offsets)),
        'runs':{},'limits':[
            'Process IDs plus bounded host log windows; discard the first two wall seconds and the uncertain ending poll.',
            'Date-mode CSV timestamps are calibrated from matching QPC events, not assumed to be local or UTC.',
            'Application-present intervals are distinct from physical display-change coverage.',
            'Other / Composed: Copy with GPU GDI does not prove Vulkan scene GPU execution time or monitor refresh.',
            'Entrance/reference windows are not whole-map 60-FPS acceptance; the siege has a short frame sample.'
        ]}
    for scene in ('mansion','sewers','city','ground','siege'):
        run=json.loads((ROOT/'build/issue431/performance'/('display-'+scene+'.json')).read_text())
        lower=datetime.fromisoformat(run['window_utc']['BEGIN']['before_utc']).timestamp()*1000+2000
        upper=datetime.fromisoformat(run['window_utc']['END']['after_utc']).timestamp()*1000
        rows=[row for row in dates if int(row['ProcessID'])==run['pid']
            and lower<epoch(row['CPUStartDateTime'])+shift<upper]
        if not rows:
            raise SystemExit('Missing native presentation window: '+scene)
        metrics={key:stats([float(row[key]) for row in rows if row[key] not in ('NA','')])
            for key in ('MsBetweenPresents','MsBetweenDisplayChange','MsCPUBusy','MsCPUWait','MsGPUBusy','MsGPUWait','MsUntilDisplayed')}
        metrics.update(pid=run['pid'],window_utc_ms=[lower,upper],frames=len(rows),
            application_present_fps=1000/metrics['MsBetweenPresents']['mean_ms'],
            display_change_coverage=sum(row['MsBetweenDisplayChange'] not in ('NA','') for row in rows)/len(rows),
            present_modes=sorted(set(row['PresentMode'] for row in rows)),
            runtimes=sorted(set(row['PresentRuntime'] for row in rows)))
        report['runs'][scene]=metrics
    for source in (args.dates,args.qpc):
        meta=source.with_suffix('.json')
        report[source.stem]=json.loads(meta.read_text(encoding='utf-8-sig'))
        report[source.stem]['log']=archive(source.with_suffix('.log'))
    (HERE/'presentation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({name:{'fps':round(row['application_present_fps'],2),
        'interval':row['MsBetweenPresents'],'display_coverage':row['display_change_coverage']}
        for name,row in report['runs'].items()},indent=2))


if __name__=='__main__':
    main()
