"""Summarize native wall-clock simulation and render callbacks without calling them displayed FPS."""
from pathlib import Path
import argparse
import json
import re
import statistics

def rows(text,prefix):
    return [dict((k,float(v)) for k,v in re.findall(r'(\w+)=(-?[\d.]+)',line))
            for line in text.splitlines() if line.startswith(prefix)]

def percentile(values,fraction):
    if not values:return None
    values=sorted(values);i=(len(values)-1)*fraction;lo=int(i);hi=min(lo+1,len(values)-1)
    return values[lo]+(values[hi]-values[lo])*(i-lo)

def summary(path,manifest):
    text=path.read_text(encoding='utf-8-sig',errors='replace')
    start=rows(text,'CA304 START');done=rows(text,'CA304 DONE')
    if not start:return {'valid':False,'reason':'no study start'}
    first=start[0]['tic']+manifest['settings']['warmup_tics']
    config=path.with_suffix('.ini')
    settings=config.read_text(encoding='utf-8-sig',errors='replace') if config.exists() else ''
    window=re.search(r'^ca304_window=(\d+)',settings,re.M)
    duration=int(window.group(1)) if window and int(window.group(1))>0 else manifest['settings']['observation_tics']
    last=first+duration
    sim=[r for r in rows(text,'CA304 SIM') if first<=r['tic']<=last]
    frames=[r['interval'] for r in rows(text,'CA304 FRAME ')]
    result={'valid':bool(done and done[-1]['failures']==0),'start':start[0],
            'render_control':'CA304 RENDER_CONTROL' in text,'samples':len(sim),
            'observation_tic_bounds':[first,last]}
    metadata=path.with_name(path.stem+'-run.json')
    if metadata.exists():result['run']=json.loads(metadata.read_text(encoding='utf-8-sig'))
    if len(sim)>1:
        result['simulation_tics_per_wall_second']=(sim[-1]['tic']-sim[0]['tic'])*1000/(sim[-1]['ms']-sim[0]['ms'])
        result['observation_wall_seconds']=(sim[-1]['ms']-sim[0]['ms'])/1000
        result['population']={key:[min(r[key] for r in sim),max(r[key] for r in sim)] for key in ('alive','total','remaining','defenders','corpses','archived','projectiles')}
        intervals=[(b['ms']-a['ms'])/(b['tic']-a['tic']) for a,b in zip(sim,sim[1:])]
        result['wall_ms_per_tic_over_35_tic_windows']={str(p):percentile(intervals,p) for p in (.5,.95,.99)}
        # Report a common late combat interval separately from army deployment.
        late=[r for r in sim if 6000<=r['tic']<=7400]
        if len(late)>1:
            result['late_combat']={'tic_bounds':[late[0]['tic'],late[-1]['tic']],
                'tics_per_wall_second':(late[-1]['tic']-late[0]['tic'])*1000/(late[-1]['ms']-late[0]['ms']),
                'population_ranges':{key:[min(r[key] for r in late),max(r[key] for r in late)]
                    for key in ('alive','defenders','corpses','archived','projectiles')}}
    if frames:
        result['render_callbacks']={'count':len(frames),'per_second':len(frames)*1000/sum(frames),
            'interval_ms':{str(p):percentile(frames,p) for p in (.5,.95,.99)},
            'qualification':'RenderOverlay callbacks, NOT displayed FPS, GPU time or PresentMon intervals.'}
    costs=[r for r in rows(text,'CA121 COST') if first<=r['tic']<=last]
    if costs:
        n=len(set(r['tic'] for r in costs));result['profile_sampled_tics']=n
        result['profile']={str(int(key)):{'calls':sum(r['calls'] for r in costs if r['id']==key),
            **{kind+'_ms_per_sampled_tic':sum(r[kind] for r in costs if r['id']==key)/n for kind in ('inclusive','exclusive')}}
            for key in sorted(set(r['id'] for r in costs))}
    detail=[r for r in rows(text,'CA304 DETAIL') if first<=r['tic']<=last]
    if detail:
        result['detail_ranges']={key:[min(r[key] for r in detail),max(r[key] for r in detail)]
                                 for key in detail[0] if key!='tic'}
    deaths=rows(text,'CA304 DEATH_TOTAL')
    if deaths:result['last_death_counters']=deaths[-1]
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();manifest=json.loads((a.directory/'manifest.json').read_text())
    result={'manifest':manifest,'runs':{f.stem:summary(f,manifest) for f in sorted(a.directory.glob('*.txt'))
            if f.with_name(f.stem+'-run.json').exists() or f.read_text(encoding='utf-8-sig',errors='replace').find('CA304 START')>=0}}
    a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    for name,r in result['runs'].items():
        print(name,r['valid'],round(r.get('simulation_tics_per_wall_second',0),3),round(r.get('render_callbacks',{}).get('per_second',0),3),r.get('population',{}))

if __name__=='__main__':main()
