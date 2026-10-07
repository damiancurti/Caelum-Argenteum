"""Summarize recorded simulation, callback, nested CPU and native render evidence.

This does not equate callbacks with GPU/present time or diagnostic deltas with
additive causal shares. Percentages use the sum of measured exclusive scopes.
"""
import hashlib
import json
import math
from pathlib import Path
import re
import statistics

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue121'
LABELS=['baseline-b','instrument-a','instrument-b','baseline-c',
        'formation100-e','formation1-a','formation1-b','formation100-f','shared-a','shared-b','events-a',
        'guard-check-a','guards-a','cannon-a','formation-retry-a','shared-guards-a','combined-a','combined-b','formation-retry-b',
        'formation-all-a','formation-all-b']

def quantile(values,p):
    if not values:return None
    values=sorted(values);at=(len(values)-1)*p;lo=math.floor(at);hi=math.ceil(at)
    return values[lo]+(values[hi]-values[lo])*(at-lo)

def stats(values):
    if not values:return {'n':0}
    return {'n':len(values),'mean':statistics.mean(values),'median':statistics.median(values),
            'p95':quantile(values,.95),'min':min(values),'max':max(values)}

def rows(text,kind):
    result=[]
    for line in text.splitlines():
        if not line.startswith('CA121 '+kind+' '):continue
        result.append({key:float(value) if '.' in value else int(value)
            for key,value in re.findall(r'(\w+)=(-?\d+(?:\.\d+)?)',line)})
    return result

def window(data,start,end):
    sim=[r for r in data['sim'] if start<=r['tic']<=end]
    if not sim or sim[0]['tic']!=start or sim[-1]['tic']!=end:return None
    span=sim[-1]['ms']-sim[0]['ms']
    intervals=[(b['ms']-a['ms'])/(b['tic']-a['tic']) for a,b in zip(sim,sim[1:])]
    frames=[r for r in data['frames'] if start<=r['tic']<=end]
    frame_intervals=[b['ms']-a['ms'] for a,b in zip(frames,frames[1:])]
    sampled=[r['tic'] for r in data['counts'] if start<=r['tic']<end]
    categories={}
    for key in sorted({r['id'] for r in data['costs']}):
        by_tic={r['tic']:r for r in data['costs'] if r['id']==key}
        categories[str(key)]={metric:stats([by_tic.get(t,{}).get(metric,0) for t in sampled])
                             for metric in ['calls','inclusive','exclusive']}
    total=sum(c['exclusive'].get('mean',0) for c in categories.values())
    for c in categories.values():
        c['percent_of_measured_exclusive']=100*c['exclusive'].get('mean',0)/total if total else None
        calls=c['calls'].get('mean',0)
        c['inclusive_ms_per_call']=c['inclusive'].get('mean',0)/calls if calls else None
    count_rows=[r for r in data['counts'] if start<=r['tic']<end]
    native_los_by_parent={}
    for key in [10,11,16]:
        c=categories.get(str(key))
        if c:native_los_by_parent[str(key)]=c['inclusive']['mean']-c['exclusive']['mean']
    rare={}
    for key in sorted({r['id'] for r in data['rare']}):
        events=[r['ms'] for r in data['rare'] if r['id']==key and start<=r['tic']<end]
        rare[str(key)]={'calls':len(events),'ms_per_call':stats(events),'calls_per_tic':len(events)/(end-start),'inclusive_ms_per_tic':sum(events)/(end-start)}
    return {'tics':[start,end],'elapsed_ms':span,'simulation_tics_per_second':1000*(end-start)/span,
            'wall_ms_per_tic':span/(end-start),'35_tic_window_ms_per_tic':stats(intervals),
            'frame_callback_interval_ms':stats(frame_intervals),
            'callback_fps':1000*(len(frames)-1)/(frames[-1]['ms']-frames[0]['ms']) if len(frames)>1 else None,
            'tics_between_callbacks':stats([b['tic']-a['tic'] for a,b in zip(frames,frames[1:])]),
            'start_scene':sim[0],'end_scene':sim[-1],'sampled_tics':len(sampled),
            'measured_exclusive_ms_per_sampled_tic':total,'categories':categories,
            'derived_native_los_ms_by_parent':native_los_by_parent,'every_call_rare_scopes':rare,
            'frequencies':{k:stats([r[k] for r in count_rows]) for k in ['candidates','sight','decisions','commands']}}

def read(label):
    path=HERE/f'{label}.txt'
    if not path.exists():path=WORK/f'{label}.txt'
    if not path.exists():return None
    text=path.read_text(encoding='utf-8-sig')
    data={k:rows(text,v) for k,v in [('sim','SIM'),('frames','FRAME'),('costs','COST'),('counts','COUNT'),('motion','MOTION'),('formation','FORMATION'),('settings','SETTINGS'),('rare','RARE')]}
    assert not re.search(r'Script error,|VM execution aborted|CA121 unbalanced|CA121 GUARD_MISMATCH',text),label
    data['log_sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
    data['guard_verification_rows']=rows(text,'GUARD_VERIFIED')
    data['formation_initialization']=rows(text,'FORMATION_INIT')
    data['formation_camera']=rows(text,'CAMERA')
    data['windows']={}
    for name,start,end in [('early',35,700),('congested',700,1750),('later',1750,3500),('common',35,2100),('formation',35,1715),('formation_late',700,1715)]:
        w=window(data,start,end)
        if w:data['windows'][name]=w
    probes={}
    for phase,identifier,ms in re.findall(r'CA116 PROBE_(REQUEST|PLAY|ACK|FRAME) id=(\d+) ms=([\d.]+)',text):
        probes.setdefault(identifier,{})[phase]=float(ms)
    data['synthetic_probes']=[dict(id=key,**p,request_to_frame_ms=p['FRAME']-p['REQUEST']) for key,p in probes.items() if 'FRAME' in p and 'REQUEST' in p]
    profile=[]
    for total,average,calls,name in re.findall(r'^\s*([\d.]+)\s+([\d.]+|Inf)\s+(\d+)\s+(\w+)\s*$',text,re.M):
        profile.append({'class':name,'total_ms':float(total),'calls':int(calls)})
    data['native_thinker_samples']=profile
    bench=HERE/f'{label}-benchmarks.txt'
    if not bench.exists():bench=WORK/f'{label}-benchmarks.txt'
    if bench.exists():
        b=bench.read_text(encoding='utf-8-sig')
        totals=[dict((k,float(v)) for k,v in re.findall(r'(\w+)=([\d.]+)',line)) for line in b.splitlines() if line.startswith('All=')]
        data['native_render_cpu']={key:stats([r[key] for r in totals]) for key in ['All','Render','Setup','Finish','Drawcalls']}
        data['native_render_blocks']=len(re.findall(r'^Map MAP06:',b,re.M))
    return data

def compare(a,b,window_name):
    wa=a['windows'].get(window_name);wb=b['windows'].get(window_name)
    if not wa or not wb:return None
    lo,hi=wa['tics'];sa=[r for r in a['sim'] if lo<=r['tic']<=hi];sb=[r for r in b['sim'] if lo<=r['tic']<=hi]
    clean=lambda r:{k:v for k,v in r.items() if k!='ms'}
    differences=[{'tic':ra['tic'],'a':clean(ra),'b':clean(rb)} for ra,rb in zip(sa,sb) if clean(ra)!=clean(rb)]
    return {'window':window_name,'a_tps':wa['simulation_tics_per_second'],'b_tps':wb['simulation_tics_per_second'],
            'throughput_percent':100*(wb['simulation_tics_per_second']/wa['simulation_tics_per_second']-1),
            'scene_rows':[len(sa),len(sb)],'scene_differences':differences,
            'comparable_behavior':not differences and len(sa)==len(sb)}

def main():
    runs={label:data for label in LABELS if (data:=read(label))}
    pairs={}
    for a,b,w in [('baseline-b','instrument-a','common'),('baseline-c','instrument-b','common'),
                  ('baseline-b','instrument-a','later'),('formation1-a','formation100-e','formation'),
                  ('formation1-b','formation100-f','formation'),('instrument-a','shared-a','common'),
                  ('instrument-b','shared-b','common'),('baseline-c','events-a','common'),
                  ('instrument-a','guards-a','common'),('instrument-a','cannon-a','common'),
                  ('shared-a','shared-guards-a','common'),('shared-guards-a','combined-a','common'),
                  ('instrument-a','combined-a','common'),('instrument-b','combined-b','common'),
                  ('instrument-a','combined-a','later'),('instrument-a','combined-b','later'),
                  ('formation100-e','formation-retry-a','formation'),('formation100-f','formation-retry-b','formation'),
                  ('formation-retry-a','formation-all-a','formation'),('formation-retry-b','formation-all-b','formation')]:
        if a in runs and b in runs:pairs[a+'__'+b+'__'+w]=compare(runs[a],runs[b],w)
    published={label:{**{k:v for k,v in data.items() if k not in ['frames','costs','counts','rare']},
                      'raw_log':label+'.txt','raw_series_in_log':['FRAME','COST','COUNT','RARE']}
               for label,data in runs.items()}
    output={'issue':121,'baseline_release':'5.0.4','runtime_changes':'Two production release-label strings only; gameplay interventions remain in isolated diagnostic copies.',
            'sampling':'Every 37th simulation tic, coprime with 4/8/35-tic gameplay cadences; costs include probe overhead.',
            'denominator':'Sum of exclusive measured scopes per sampled tic, not total process CPU or wall time.',
            'limitations':['Native thinker rows are individual sampled tics.','Render CPU timers overlap worker activity and do not isolate GPU execution.',
                          'Overlay callbacks are not physical presentation or input latency.','Diagnostic formation and shared perception change workloads; deltas are not additive causal shares.'],
            'runs':published,'comparisons':pairs}
    (HERE/'RESULTS.json').write_text(json.dumps(output,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    for label,data in runs.items():
        print(label,{k:round(w['simulation_tics_per_second'],3) for k,w in data['windows'].items()})

if __name__=='__main__':main()
