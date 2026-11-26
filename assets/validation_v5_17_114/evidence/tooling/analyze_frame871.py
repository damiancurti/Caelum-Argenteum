"""Separate native thinker snapshots, renderer snapshots, tic grouping and presents."""
from pathlib import Path
from collections import Counter
import json,re,subprocess,sys,statistics
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
label=sys.argv[1];out=ROOT/f'build/issue871-{label}'
raw=(ROOT/f'build/issue871-{label}-run.log').read_bytes()
text=raw.decode('utf-16' if raw[:2]==b'\xff\xfe' else 'utf-8',errors='replace')
directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());directory.relative_to(ROOT)
run=json.loads((directory/'results.json').read_text());assert run['passed']
with (out/'queue-analysis.log').open('wb') as log:
    subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=ROOT,stdout=log,stderr=log,check=True)
engine=(directory/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
engine=re.sub('\x1c.','',engine)
ticks=[(int(i),float(ms)) for i,ms in re.findall(r'CA871 TICK_TIME i=(\d+) ms=([\d.]+)',engine)]
frames=[(int(i),int(tic),float(ms)) for i,tic,ms in re.findall(r'CA871 FRAME_TIME i=(\d+) tic=(\d+) ms=([\d.]+)',engine)]
assert len(ticks)==701 and len(frames)>2
assert [i for i,_ in ticks]==list(range(len(ticks)))
assert [i for i,_,_ in frames]==list(range(len(frames)))
assert all(ticks[i][1]<ticks[i+1][1] for i in range(len(ticks)-1))
intervals=[]
for before,after in zip(frames,frames[1:]):
    if before[2]>=ticks[0][1] and after[2]<=ticks[-1][1]:
        intervals.append(dict(start_ms=before[2],end_ms=after[2],elapsed_ms=after[2]-before[2],label_tics=after[1]-before[1],observed_tick_callbacks=sum(before[2]<ms<=after[2] for _,ms in ticks)))
assert intervals
samples=[]
for match in re.finditer(r'CA871_THINK_(\d+)\n(.*?)(?=CA871_THINK_|\Z)',engine,re.S):
    rows=[dict(ms=float(ms),average_ms=float(avg),calls=int(n),name=name) for ms,avg,n,name in re.findall(r'^\s*([\d.]+)\s+([\d.]+)\s+(\d+)\s+(\S+)\s*$',match[2],re.M)]
    assert rows;samples.append(dict(index=int(match[1]),rows=rows,total_ms=sum(r['ms'] for r in rows)))
means=[]
if samples:
    assert len(samples) in (5,35)
    for name in {r['name'] for s in samples for r in s['rows']}:
        values=[sum(r['ms'] for r in s['rows'] if r['name']==name) for s in samples]
        calls=[sum(r['calls'] for r in s['rows'] if r['name']==name) for s in samples]
        means.append(dict(name=name,mean_ms=statistics.mean(values),min_ms=min(values),max_ms=max(values),calls_range=[min(calls),max(calls)]))
    means.sort(key=lambda r:r['mean_ms'],reverse=True)
bench=directory/'peer0/benchmarks.txt';bench_text=bench.read_text(encoding='utf-8') if bench.exists() else ''
bench_all=[float(v) for v in re.findall(r'^All=([\d.]+),',bench_text,re.M)]
marks=[dict(tic=int(tic),ms=float(ms)) for tic,ms in re.findall(r'CA871 NATIVE_MARK tic=(\d+) ms=([\d.]+)',engine)]
phase_coverage=dict(sorted(Counter(mark['tic']%35 for mark in marks).items()))
if len(samples)==35:assert len(marks)==35 and phase_coverage==dict.fromkeys(range(35),1)
report=dict(issue=871,label=label,directory=directory.relative_to(ROOT).as_posix(),runtime_sha256=run['runtime_sha256'],census=run['peers'][0]['census'],states=run['peers'][0]['states'],simulation=run['peers'][0]['simulation'],presentation=json.loads((directory/'presentation.json').read_text())['peers'][0],
    grouping=dict(frame_samples=len(frames),complete_intervals=len(intervals),tic_histogram=dict(Counter(v['observed_tick_callbacks'] for v in intervals)),mean_observed_tics=statistics.mean(v['observed_tick_callbacks'] for v in intervals),labels_match_counts=all(v['label_tics']==v['observed_tick_callbacks'] for v in intervals),intervals=intervals),thinker_samples=samples,thinker_means=means,renderer_all_snapshots_ms=bench_all,
    native_marks=marks,native_marker_phase_coverage_mod35=phase_coverage,
    qualification='Actual complete intervals use engine monotonic timestamps; callback labels are also retained. Native thinker profiles are separate instrumented single-tic snapshots, not a window mean. Their count and phase coverage are recorded explicitly. Native bench entries are later renderer CPU-scope snapshots; main/worker/nested phases overlap and do not establish GPU duration. Statistics, debugfile and timers add diagnostic overhead. Compare separately with grouping-only and uninstrumented controls.')
(out/'analysis.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(label=label,queue_presents=report['presentation']['mean_present_fps'],grouping={k:v for k,v in report['grouping'].items() if k!='intervals'},thinker_top=means[:8],renderer_all_snapshots_ms=bench_all),indent=2))
