"""Summarize nested per-tic diagnostic costs without treating overhead as speedup."""
from pathlib import Path
import argparse,json,re

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile',type=Path,required=True);parser.add_argument('--run',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();manifest=json.loads((args.profile/'manifest.json').read_text());native=json.loads((args.run/'results.json').read_text())
    assert native['passed'];log=(args.run/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
    assert 'CA838 COMPLETE errors=0 depth=0' in log
    metrics={m['id']:m for m in manifest['metrics']};rows={int(t):{'tic':int(t),'wall_ms':float(ms),'scopes':{}} for t,ms in re.findall(r'CA838 WALL tic=(\d+) ms=([\d.]+)',log)}
    assert sorted(rows)==list(range(3599,4299))
    for t,m,inc,exc,mx,calls in re.findall(r'CA838 SCOPE tic=(\d+) metric=(\d+) inclusive=([\d.]+) exclusive=([\d.]+) maximum=([\d.]+) calls=(\d+)',log):
        record={'inclusive_ms':float(inc),'exclusive_ms':float(exc),'maximum_ms':float(mx),'calls':int(calls)}
        assert record['inclusive_ms']+0.000001>=record['exclusive_ms']
        rows[int(t)]['scopes'][int(m)]=record
    totals=[]
    for key,meta in metrics.items():
        samples=[r['scopes'].get(key,{'inclusive_ms':0,'exclusive_ms':0,'maximum_ms':0,'calls':0}) for r in rows.values()]
        totals.append({**meta,'inclusive_ms':sum(v['inclusive_ms'] for v in samples),'exclusive_ms':sum(v['exclusive_ms'] for v in samples),'calls':sum(v['calls'] for v in samples),'max_call_ms':max(v['maximum_ms'] for v in samples),'max_tic_exclusive_ms':max(v['exclusive_ms'] for v in samples)})
    totals.sort(key=lambda v:v['exclusive_ms'],reverse=True)
    for row in rows.values():
        row['scoped_exclusive_ms']=sum(v['exclusive_ms'] for v in row['scopes'].values())
        row['residual_ms']=row['wall_ms']-row['scoped_exclusive_ms']
    worst=[]
    for row in sorted(rows.values(),key=lambda v:v['wall_ms'],reverse=True)[:12]:
        top=sorted(row['scopes'].items(),key=lambda q:q[1]['exclusive_ms'],reverse=True)[:5]
        worst.append({k:row[k] for k in ('tic','wall_ms','scoped_exclusive_ms','residual_ms')}|{'largest_scopes':[{'class':metrics[key]['class'],'method':metrics[key]['method'],**values} for key,values in top]})
    summary={'issue':838,'runtime_sha256':native['runtime_sha256'],'overlay_sha256':manifest['overlay_sha256'],'native_passed':True,'balanced_stack':True,'tics':len(rows),'metrics':totals,'wall_total_ms':sum(r['wall_ms'] for r in rows.values()),'scoped_exclusive_total_ms':sum(r['scoped_exclusive_ms'] for r in rows.values()),'worst_tics':worst,'rows':list(rows.values()),'qualification':manifest['qualification']}
    args.output.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in summary.items() if k not in ('rows','worst_tics','metrics')}))
    print(json.dumps({'top_metrics':totals[:10],'worst_tics':worst[:5]},indent=2))

if __name__=='__main__':main()
