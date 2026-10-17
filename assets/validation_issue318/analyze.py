"""Separate native simulation, callback intervals, instrumented costs and ETW frames."""
from pathlib import Path
import argparse
import collections
import json
import re
import statistics
import csv

ROOT=Path(__file__).resolve().parents[2]

def quantile(xs,q):
    if not xs:return None
    xs=sorted(xs);at=(len(xs)-1)*q;lo=int(at);return xs[lo]+(xs[min(lo+1,len(xs)-1)]-xs[lo])*(at-lo)

def stats(xs):
    if not xs:return {}
    return {'n':len(xs),'mean':statistics.mean(xs),'median':statistics.median(xs),'p95':quantile(xs,.95),'p99':quantile(xs,.99),'max':max(xs)}

def analyze(folder):
    output=[]
    for recordpath in sorted(folder.glob('*/*-run.json')):
        rec=json.loads(recordpath.read_text());label=rec['options']['label'];path=recordpath.with_name(label+'.txt')
        if not path.exists():
            output.append({'label':label,'variant':rec['options']['variant'],'options':rec['options'],'pid':rec['pid'],
                           'completed':False,'failure':'Missing native log','exit_code':rec.get('exit_code'),
                           'callback_interval_ms':{},'native_tic_interval_ms':{}})
            continue
        text=path.read_text(encoding='utf-8',errors='replace')
        start=re.search(r'CA318 START tic=(\d+) start=([\d.]+) warmup=(\d+) window=(\d+)',text)
        if not start:
            functional=bool(rec['options'].get('script'))
            output.append({'label':label,'variant':rec['options']['variant'],'options':rec['options'],'pid':rec['pid'],
                           'completed':functional and bool(re.search(r'CA318 DONE failures=0',text)) and 'CA318 FAIL' not in text and rec.get('exit_code')==0,
                           'kind':'functional' if functional else 'incomplete performance',
                           'native_results':[line for line in text.splitlines() if line.startswith('CA318')],
                           'failure':None if functional else 'No measurement start marker; inspect preserved raw log',
                           'exit_code':rec.get('exit_code'),'callback_interval_ms':{},'native_tic_interval_ms':{}})
            continue
        first=int(start[1])+int(start[3]);last=first+int(start[4])
        ticks=[(int(t),float(ms)) for t,ms in re.findall(r'CA318 TICK tic=(\d+) ms=([\d.]+)',text)]
        window=[(t,ms) for t,ms in ticks if first<t<last]
        frames=[float(dt) for t,ms,dt in re.findall(r'CA318 FRAME tic=(\d+) ms=([\d.]+) interval=([\d.]+)',text) if first<int(t)<last]
        results={'label':label,'variant':rec['options']['variant'],'options':rec['options'],'pid':rec['pid'],
                 'completed':bool(re.search(r'CA318 DONE failures=0',text)) and 'CA318 FAIL' not in text and rec.get('exit_code')==0 and not rec.get('engine_error') and not rec.get('watchdog_timeout'),
                 'callback_interval_ms':stats(frames),'native_tic_interval_ms':stats([b[1]-a[1] for a,b in zip(window,window[1:])]),
                 'whole_run_max_tic_interval_ms':max([b[1]-a[1] for a,b in zip(ticks,ticks[1:])],default=None),
                 'census':[l for l in text.splitlines() if l.startswith('CA318 CENSUS')],
                 'camera':[l for l in text.splitlines() if l.startswith('CA318 CAMERA')]}
        results['expected_interior_tics']=int(start[4])-1
        results['observed_interior_tics']=len(window)
        results['interior_wall_ms']=window[-1][1]-window[0][1] if len(window)>1 else None
        results['measurement_window_complete']=bool(re.search(r'CA318 DONE failures=0',text)) and 'CA318 FAIL' not in text and len(window)==int(start[4])-1
        results['profile_scope']='Completed measurement window' if results['measurement_window_complete'] else 'Partial failed run; not a completed-window mean'
        results['breaths']=[l for l in text.splitlines() if l.startswith('CA318 BREATHS')]
        results['skip']=[l for l in text.splitlines() if l.startswith('CA318 SKIP') or l.startswith('CA318 FAIL')]
        results['watchdog_timeout']=rec.get('watchdog_timeout',False)
        if len(window)>1:results['tics_per_second']=(window[-1][0]-window[0][0])*1000/(window[-1][1]-window[0][1])
        if frames:results['callbacks_per_second']=1000/statistics.mean(frames)
        sums=collections.defaultdict(lambda:[0.,0.,0]);sample_tics=set()
        for t,i,c,inc,own in re.findall(r'CA318 COST tic=(\d+) id=(\d+) calls=(\d+) inclusive=([\d.]+) exclusive=([\d.]+)',text):
            if first<int(t)<last and int(t)%17==0:
                sample_tics.add(int(t));s=sums[int(i)];s[0]+=float(inc);s[1]+=float(own);s[2]+=int(c)
        manifest=json.loads((recordpath.parent/'manifest.json').read_text())
        names={m['id']:m['class']+'.'+m['method'] for m in manifest.get('methods',[])}
        always={m['id'] for m in manifest.get('methods',[]) if m['always']}
        results['bursts']=[{'tic':int(t),'name':names[int(i)],'calls':int(c),'inclusive_ms':float(inc),'exclusive_ms':float(own)}
                          for t,i,c,inc,own in re.findall(r'CA318 COST tic=(\d+) id=(\d+) calls=(\d+) inclusive=([\d.]+) exclusive=([\d.]+)',text)
                          if int(i) in always and float(inc)>.05]
        results['profile_sample_tics']=len(sample_tics)
        results['profile']=[{'name':names[i],'inclusive_ms_per_sample_tic':v[0]/len(sample_tics),'exclusive_ms_per_sample_tic':v[1]/len(sample_tics),'calls_per_sample_tic':v[2]/len(sample_tics)} for i,v in sorted(sums.items(),key=lambda kv:-kv[1][1])] if sample_tics else []
        output.append(results)
    return output

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',default='issue318-audit-02');a=p.parse_args()
    out=ROOT/'build'/a.directory;results=analyze(out)
    etw=[]
    collectors=set((ROOT/'build').glob('issue318-audit-*/presentmon-global.csv'))
    collectors.update((ROOT/'build').glob('issue318-flat-*/presentmon-global.csv'))
    if (out/'presentmon-global.csv').exists():collectors.add(out/'presentmon-global.csv')
    for path in sorted(collectors):
        try:
            with path.open(encoding='utf-8-sig',newline='') as stream:etw.extend(csv.DictReader(stream))
        except PermissionError:continue
    for r in results:
        record=json.loads((out/r['variant']/(r['label']+'-run.json')).read_text())
        begin=record.get('CA318 WINDOW');end=record.get('CA318 DONE')
        if not begin or not end or not r.get('measurement_window_complete'):continue
        lower=begin['qpc_seen_ms']+300;upper=end['qpc_seen_ms']-500
        local=out/r['variant']/(r['label']+'.csv')
        rows=etw
        if local.exists():
            with local.open(encoding='utf-8-sig',newline='') as stream:rows=list(csv.DictReader(stream))
        matched=[x for x in rows if int(x['ProcessID'])==r['pid'] and lower<float(x['CPUStartQPCTimeInMs'])<upper]
        if not matched:continue
        metrics={}
        for name in ('MsBetweenPresents','MsBetweenDisplayChange','MsCPUBusy','MsCPUWait','MsGPUBusy','MsGPUWait','MsUntilDisplayed'):
            metrics[name]=stats([float(x[name]) for x in matched if x[name] not in ('NA','')])
        if not metrics['MsBetweenPresents']:continue
        metrics['application_present_fps']=1000/metrics['MsBetweenPresents']['mean']
        metrics['sample_count']=len(matched)
        metrics['short_sample_warning']=len(matched)<30
        if metrics['MsBetweenDisplayChange']:metrics['display_change_fps']=1000/metrics['MsBetweenDisplayChange']['mean']
        metrics['qpc_bounds_ms']=[lower,upper]
        metrics['synchronization']='Host log detection; 200ms polling; trim 300ms at start and 500ms at end. No exact per-tic correlation claimed.'
        metrics['present_modes']=dict(collections.Counter(x['PresentMode'] for x in matched))
        r['presentmon']=metrics
    (out/'analysis.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
    for r in results:print(r['label'],round(r.get('tics_per_second',0),2),'tics/s',round(r['presentmon']['application_present_fps'],2) if 'presentmon' in r else 'unavailable','ETW-present FPS',round(r.get('callbacks_per_second',0),2),'callbacks/s',round(r['callback_interval_ms'].get('p99',0),2),'p99 ms')

if __name__=='__main__':main()
