"""Summarize sampled inclusive storage categories without adding nested costs."""
from pathlib import Path
import argparse,json,re
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args();a.directory=a.directory.resolve()
manifest=json.loads((ROOT/'build/issue849-storage01/manifest.json').read_text())
text=(a.directory/'peer0/engine.log').read_text(errors='replace');complete=re.search(r'CA849 STORAGE_COMPLETE mismatches=(\d+)',text);assert complete and int(complete[1])==0
parsed=[(int(t),int(m),float(v),float(x),int(n)) for t,m,v,x,n in re.findall(r'CA849 STORAGE tic=(\d+) metric=(\d+) total=([\d.]+) maximum=([\d.]+) calls=(\d+)',text)]
rows=[]
for metric in manifest['metrics']:
    cells=[r for r in parsed if r[1]==metric['id']];calls=sum(r[4] for r in cells);ms=sum(r[2] for r in cells)
    rows.append(dict(**metric,calls=calls,total_ms=ms,ms_per_sampled_tic=ms/len(manifest['sample_tics']),microseconds_per_call=ms*1000/calls if calls else None,max_call_ms=max((r[3] for r in cells),default=0)))
report=dict(issue=849,directory=a.directory.relative_to(ROOT).as_posix(),sampled_tics=len(manifest['sample_tics']),warm_pointer_mismatches=0,rows=rows,qualification=manifest['qualification'])
(ROOT/'build/issue849-storage-analysis.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(report,indent=2))
