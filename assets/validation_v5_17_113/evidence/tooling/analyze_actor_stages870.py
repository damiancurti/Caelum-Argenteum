"""Summarize sampled actor stages without adding nested totals to their children."""
from pathlib import Path
import json,re,statistics
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
out=ROOT/'build/issue870-stages01';manifest=json.loads((out/'manifest.json').read_text())
raw=(ROOT/'build/issue870-stages-run01-run.log').read_bytes()
text=raw.decode('utf-16' if raw[:2]==b'\xff\xfe' else 'utf-8',errors='replace')
directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());directory.relative_to(ROOT)
run=json.loads((directory/'results.json').read_text());assert run['passed']
engine=(directory/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
assert engine.count('CA870 STAGES_COMPLETE')==1
rows=[dict(tic=int(t),metric=int(m),total_ms=float(v),maximum_ms=float(x),calls=int(c)) for t,m,v,x,c in re.findall(r'CA870 STAGE tic=(\d+) metric=(\d+) total=([\d.]+) maximum=([\d.]+) calls=(\d+)',engine)]
tics=sorted({r['tic'] for r in rows});assert len(tics)==42 and all(3599<=t<4299 and (t-3599)%17==0 for t in tics)
assert len({(r['tic'],r['metric']) for r in rows})==len(rows)
summary=[]
for m in manifest['metrics']:
    own=[r for r in rows if r['metric']==m['id']]
    values=[sum(r['total_ms'] for r in own if r['tic']==t) for t in tics]
    counts=[sum(r['calls'] for r in own if r['tic']==t) for t in tics]
    summary.append(dict(**m,mean_sampled_tic_ms=statistics.mean(values),maximum_sampled_tic_ms=max(values),calls=sum(counts),calls_per_sample=[min(counts),max(counts)]))
complete={}
for family in range(2):
    complete[manifest['metrics'][family*7]['family']]=all(next((r['calls'] for r in rows if r['tic']==t and r['metric']==family*7+i),0)==next((r['calls'] for r in rows if r['tic']==t and r['metric']==family*7+6),0) for t in tics for i in range(6))
report=dict(issue=870,directory=directory.relative_to(ROOT).as_posix(),runtime_sha256=run['runtime_sha256'],manifest=manifest,sample_tics=tics,complete_common_paths=complete,summary=summary,rows=rows,states=run['peers'][0]['states'],census=run['peers'][0]['census'],qualification='Mean over42 selected tics; instrumented and not a production CPU budget. Common and outer totals are nested; do not add them to their component stages. Stage instrumentation and wrapper lookup/calls have overhead. No gameplay was removed.')
(out/'analysis.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(complete_common_paths=complete,summary=[r for r in summary if r['family']!='other']),indent=2))
