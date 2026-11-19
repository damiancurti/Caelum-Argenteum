"""Summarize sampled combat tick regions, retaining every raw sample."""
from pathlib import Path
import argparse,json,re,statistics
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--profile',type=Path,required=True);parser.add_argument('--run',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();manifest=json.loads((args.profile/'manifest.json').read_text());run=json.loads((args.run/'results.json').read_text());assert run['passed']
log=(args.run/'peer0/engine.log').read_text(encoding='utf-8',errors='replace');assert 'CA842 COMPLETE' in log
rows=[dict(tic=int(t),metric=int(m),total_ms=float(total),maximum_ms=float(maximum),calls=int(calls)) for t,m,total,maximum,calls in re.findall(r'CA842 REGION tic=(\d+) metric=(\d+) total=([\d.]+) maximum=([\d.]+) calls=(\d+)',log)]
totals=[]
for key,name in manifest['metrics'].items():
    samples=[r for r in rows if r['metric']==int(key)]
    expected=list(range(3599,4299,manifest['period']));assert [r['tic'] for r in samples]==expected,(key,len(samples))
    total=sum(r['total_ms'] for r in samples);calls=sum(r['calls'] for r in samples)
    totals.append(dict(id=int(key),name=name,sampled_tics=len(samples),total_ms=total,mean_sampled_tic_ms=total/len(samples),max_sampled_tic_ms=max(r['total_ms'] for r in samples),max_call_ms=max(r['maximum_ms'] for r in samples),calls=calls,mean_call_us=1000*total/calls))
totals.sort(key=lambda r:r['total_ms'],reverse=True)
result={'manifest':manifest,'native_passed':True,'state':run['peers'][0]['states'],'census':run['peers'][0]['census'],'metrics':totals,'samples':rows}
args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'metrics':totals,'state':result['state'],'census':result['census']},indent=2))
