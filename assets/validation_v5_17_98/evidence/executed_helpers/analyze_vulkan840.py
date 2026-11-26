"""Correlate private slow Vulkan CPU calls with complete frame boundary intervals."""
from pathlib import Path
import argparse,csv,io,json,math,hashlib,collections
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--run',type=Path,required=True);p.add_argument('--analysis',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
p.add_argument('--all-creation',action='store_true',help='Layer also records all intercepted creation/allocation calls regardless of duration')
a=p.parse_args();native=json.loads((a.run/'results.json').read_text());profile=json.loads(a.analysis.read_text());assert native['passed'] and profile['native_passed']
peer=native['peers'][0];pid=peer['pid']
def read_trace(name):
    path=a.run/'peer0'/name;lines=path.read_text(encoding='ascii').splitlines()
    assert lines[-1].startswith('# complete rows=')
    rows=list(csv.DictReader(io.StringIO('\n'.join(lines[:-1]))));assert len(rows)==int(lines[-1].split('=')[1])
    for r in rows:
        assert int(r['PID'])==pid
        for k in ('EntryQPCms','ReturnQPCms'):r[k]=float(r[k]);assert math.isfinite(r[k])
        assert r['ReturnQPCms']>=r['EntryQPCms']
        r['duration_ms']=r['ReturnQPCms']-r['EntryQPCms']
    return rows,hashlib.sha256(path.read_bytes()).hexdigest()
presents,present_sha=read_trace('presents.csv');api,api_sha=read_trace('presents.csv.api.csv')
frames=[r for r in profile['rows'] if 'frame' in r]
# Every matching present must follow the last overlay callback and precede the
# next PlayerThink. Intersect these inequalities to bound the clock offset.
matches=[]
begin=peer['window']['BEGIN']['qpc_ms'];end=peer['window']['END']['qpc_ms']
for i,r in enumerate(presents):
    if not begin-2000<=r['EntryQPCms']<=begin+2000:continue
    selected=presents[i:i+len(frames)]
    if len(selected)!=len(frames):continue
    low=max(v['EntryQPCms']-f['frame']['next_ms'] for v,f in zip(selected,frames))
    high=min(v['EntryQPCms']-f['frame']['overlay_ms'] for v,f in zip(selected,frames))
    if low<=high:matches.append(dict(start=i,offset_low_ms=low,offset_high_ms=high))
assert len(matches)==1, matches
match=matches[0];lo=match['offset_low_ms'];hi=match['offset_high_ms']
frame_details=[]
for f in frames:
    start=f['tic_end_ms'];stop=f['frame']['underlay_ms']
    certain=[r for r in api if r['EntryQPCms']>=start+hi and r['ReturnQPCms']<=stop+lo]
    possible=[r for r in api if r['ReturnQPCms']>=start+lo and r['EntryQPCms']<=stop+hi]
    frame_details.append(dict(tic=f['tic'],gap_ms=stop-start,certain_calls=certain,possible_calls=possible,certain_total_ms=sum(r['duration_ms'] for r in certain)))
window=[r for r in api if begin+2000<=r['EntryQPCms']<=end-500]
groups=collections.defaultdict(list)
for r in window:groups[r['API']].append(r['duration_ms'])
report=dict(issue=840,native_passed=True,profile=str(a.analysis),run=str(a.run),presents_sha256=present_sha,api_sha256=api_sha,alignment=match,clock_offset_uncertainty_ms=hi-lo,slow_api_calls=len(api),cropped_window_calls=len(window),api_summary={k:dict(count=len(v),total_ms=sum(v),max_ms=max(v)) for k,v in groups.items()},worst_frame_gaps=sorted(frame_details,key=lambda r:r['gap_ms'],reverse=True)[:8],qualification='Selected Vulkan API CPU durations >=1ms only; not GPU execution. Clock offset is bounded by all observed overlay/present/next-tic inequalities, not an assumed exact synchronization. Certain calls fit the gap for every admissible offset; possible calls overlap for at least one. Counts exclude faster calls.')
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
if a.all_creation:
    report['recorded_api_calls']=report.pop('slow_api_calls')
    report['qualification']='Selected Vulkan API CPU durations, not GPU execution. All intercepted creation/allocation calls, plus other selected calls >=1ms. Clock offset bounded by all observed overlay/present/next-tic inequalities. Certain calls fit the gap for every admissible offset; possible calls overlap for at least one.'
    a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='worst_frame_gaps'},indent=2))
for row in report['worst_frame_gaps'][:4]:print(json.dumps(row))
