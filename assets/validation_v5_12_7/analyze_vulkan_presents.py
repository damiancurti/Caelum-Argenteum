"""Validate bounded native QueuePresent traces and summarize matched scene windows.

These are application presentation requests, not monitor scanout or proof that
the compositor displayed every frame. Never substitute ZScript callback gaps.
"""
import argparse,csv,hashlib,io,json,math,re,statistics
from pathlib import Path


def summarize(values):
    ordered=sorted(values)
    def percentile(p):return ordered[max(0,math.ceil(len(ordered)*p)-1)]
    return dict(samples=len(values),mean_ms=statistics.fmean(values),p50_ms=percentile(.5),
                p95_ms=percentile(.95),p99_ms=percentile(.99),max_ms=max(values))


def inspect(path,pid,begin,end):
    text=path.read_text(encoding='ascii');lines=text.splitlines()
    match=re.fullmatch(r'# complete rows=(\d+)',lines[-1]) if lines else None
    if not match:raise ValueError('Trace lacks a normal completion record')
    rows=list(csv.DictReader(io.StringIO('\n'.join(lines[:-1]))))
    if len(rows)!=int(match[1]):raise ValueError('Trace row count differs from completion record')
    for row in rows:
        row['entry']=float(row['EntryQPCms']);row['returned']=float(row['ReturnQPCms'])
        if int(row['PID'])!=pid or not math.isfinite(row['entry']) or not math.isfinite(row['returned']) or row['returned']<row['entry']:
            raise ValueError('Foreign PID or invalid timestamp')
    if any(b['entry']<=a['entry'] for a,b in zip(rows,rows[1:])):raise ValueError('Nonmonotonic or multiple simultaneous presentation stream')
    selected=[r for r in rows if begin+2000<=r['entry']<=end-500]
    if len(selected)<2:raise ValueError('Scene has too few actual presents')
    if len({r['Swapchain'] for r in selected})!=1:raise ValueError('Multiple swapchains in the scene window')
    if any(int(r['Result']) not in (0,1000001003) for r in selected):raise ValueError('Unsuccessful presentation in the scene window')
    gaps=[b['entry']-a['entry'] for a,b in zip(selected,selected[1:])]
    intervals=summarize(gaps)
    return dict(pid=pid,trace_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),rows=len(rows),scene_presents=len(selected),
                mean_present_fps=1000/intervals['mean_ms'],present_intervals=intervals,
                native_call_duration=summarize([r['returned']-r['entry'] for r in selected]))


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('directory',type=Path);args=parser.parse_args()
    run=json.loads((args.directory/'results.json').read_text())
    if not run['passed']:raise ValueError('Native scene did not pass')
    reports=[]
    for p in run['peers']:
        reports.append(inspect(args.directory/f"peer{p['slot']}"/'presents.csv',p['pid'],p['window']['BEGIN']['qpc_ms'],p['window']['END']['qpc_ms']))
    result=dict(issue=435,map=run['map'],siege=run['siege'],ground=run['ground'],peers=reports,
                qualification='Actual vkQueuePresentKHR calls on one shared Windows machine; no display-scanout, Internet-latency or author acceptance claim.')
    (args.directory/'presentation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result,indent=2))

if __name__=='__main__':main()
