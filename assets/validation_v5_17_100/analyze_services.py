"""Summarize inclusive service samples without adding nested timings together."""
from pathlib import Path
import argparse,json,re
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--profile',type=Path,required=True);p.add_argument('--run',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
manifest=json.loads((a.profile/'manifest.json').read_text());run=json.loads((a.run/'results.json').read_text());assert run['passed']
log=(a.run/'peer0/engine.log').read_text(encoding='utf-8',errors='replace');assert 'CA844 SERVICES_COMPLETE' in log
rows=[dict(tic=int(t),metric=int(m),total_ms=float(v),maximum_ms=float(x),calls=int(n)) for t,m,v,x,n in re.findall(r'CA844 SERVICE tic=(\d+) metric=(\d+) total=([\d.]+) maximum=([\d.]+) calls=(\d+)',log)]
expected=list(range(3599,4299,manifest['period']));summary=[]
for spec in manifest['metrics']:
    samples=[r for r in rows if r['metric']==spec['id']];assert all(r['tic'] in expected for r in samples)
    total=sum(r['total_ms'] for r in samples);calls=sum(r['calls'] for r in samples)
    summary.append(dict(spec,mean_sampled_tic_ms=total/len(expected),max_sampled_tic_ms=max((r['total_ms'] for r in samples),default=0),calls=calls,mean_call_us=1000*total/calls if calls else 0))
summary.sort(key=lambda r:r['mean_sampled_tic_ms'],reverse=True)
result=dict(manifest=manifest,native_passed=True,metrics=summary,samples=rows,state=run['peers'][0]['states'],census=run['peers'][0]['census'])
a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(summary,indent=2))
