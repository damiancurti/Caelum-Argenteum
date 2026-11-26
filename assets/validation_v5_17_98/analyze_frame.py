"""Summarize PlayerThink-to-PlayerThink intervals and their observed HUD phase."""
from pathlib import Path
import argparse,collections,json,re,statistics
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--profile',type=Path,required=True);parser.add_argument('--run',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();manifest=json.loads((args.profile/'manifest.json').read_text());native=json.loads((args.run/'results.json').read_text());assert native['passed']
log=(args.run/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
assert 'CA840 COMPLETE errors=0 depth=0' in log and 'CA840 UI_COMPLETE depth=0' in log
metrics={m['id']:m for m in manifest['metrics']};ui_metrics={m['id']:m for m in manifest['ui_metrics']}
rows={int(t):{'tic':int(t),'wall_ms':float(ms),'scopes':{},'ui':{}} for t,ms in re.findall(r'CA840 WALL tic=(\d+) ms=([\d.]+)',log)}
assert sorted(rows)==list(range(3599,4299))
for t,m,inc,exc,mx,calls in re.findall(r'CA840 SCOPE tic=(\d+) metric=(\d+) inclusive=([\d.]+) exclusive=([\d.]+) maximum=([\d.]+) calls=(\d+)',log):
    rows[int(t)]['scopes'][int(m)]={'inclusive_ms':float(inc),'exclusive_ms':float(exc),'maximum_ms':float(mx),'calls':int(calls)}
for t,m,ms,calls in re.findall(r'CA840 UI tic=(\d+) metric=(\d+) ms=([\d.]+) calls=(\d+)',log):rows[int(t)]['ui'][int(m)]={'ms':float(ms),'calls':int(calls)}
for t,ms in re.findall(r'CA840 TIC_END tic=(\d+) ms=([\d.]+)',log):rows[int(t)]['tic_end_ms']=float(ms)
for t,count,begin,underlay,overlay,nxt in re.findall(r'CA840 FRAME tic=(\d+) count=(\d+) begin=([\d.]+) underlay=([\d.]+) overlay=([\d.]+) next=([\d.]+)',log):
    begin,underlay,overlay,nxt=map(float,(begin,underlay,overlay,nxt));assert begin>0 and begin<=underlay<=overlay<=nxt
    rows[int(t)]['frame']={'count':int(count),'begin_ms':begin,'underlay_ms':underlay,'overlay_ms':overlay,'next_ms':nxt,'before_underlay_ms':underlay-begin,'hud_envelope_ms':overlay-underlay,'after_overlay_ms':nxt-overlay}
    if 'tic_end_ms' in rows[int(t)]:
        end=rows[int(t)]['tic_end_ms'];assert begin<=end<=underlay
        rows[int(t)]['frame'].update(tic_work_ms=end-begin,between_tic_and_underlay_ms=underlay-end)
    assert abs((nxt-begin)-rows[int(t)]['wall_ms'])<0.0001
totals=[]
for key,meta in metrics.items():
    samples=[r['scopes'].get(key,{'inclusive_ms':0,'exclusive_ms':0,'maximum_ms':0,'calls':0}) for r in rows.values()]
    totals.append({**meta,'inclusive_ms':sum(v['inclusive_ms'] for v in samples),'exclusive_ms':sum(v['exclusive_ms'] for v in samples),'calls':sum(v['calls'] for v in samples),'max_call_ms':max(v['maximum_ms'] for v in samples),'max_tic_exclusive_ms':max(v['exclusive_ms'] for v in samples)})
totals.sort(key=lambda v:v['exclusive_ms'],reverse=True)
ui_totals=[]
for key,meta in ui_metrics.items():
    values=[r['ui'].get(key,{'ms':0,'calls':0}) for r in rows.values()]
    ui_totals.append({**meta,'ms':sum(v['ms'] for v in values),'calls':sum(v['calls'] for v in values),'max_tic_ms':max(v['ms'] for v in values)})
for row in rows.values():
    row['scoped_exclusive_ms']=sum(v['exclusive_ms'] for v in row['scopes'].values())
    row['ui_callback_ms']=sum(v['ms'] for v in row['ui'].values())
    row['residual_ms']=row['wall_ms']-row['scoped_exclusive_ms']-row['ui_callback_ms']
    if 'frame' in row:
        row['frame']['before_underlay_unscoped_ms']=row['frame']['before_underlay_ms']-row['scoped_exclusive_ms']
        if 'tic_work_ms' in row['frame']:row['frame']['tic_work_unscoped_ms']=row['frame']['tic_work_ms']-row['scoped_exclusive_ms']
worst=[{k:v for k,v in row.items() if k not in ('scopes','ui')} for row in sorted(rows.values(),key=lambda r:r['wall_ms'],reverse=True)[:12]]
frames=[r['frame'] for r in rows.values() if 'frame' in r];assert frames
frame_totals={key:sum(r[key] for r in frames) for key in ('before_underlay_unscoped_ms','hud_envelope_ms','after_overlay_ms')}
summary={'issue':840,'runtime_sha256':native['runtime_sha256'],'overlay_sha256':manifest['overlay_sha256'],'native_passed':True,'balanced_stacks':True,'tics':len(rows),'frame_rows':len(frames),'single_frame_per_row':all(r['count']==1 for r in frames),'metrics':totals,'ui_metrics':ui_totals,'wall_total_ms':sum(r['wall_ms'] for r in rows.values()),'scoped_exclusive_total_ms':sum(r['scoped_exclusive_ms'] for r in rows.values()),'ui_total_ms':sum(r['ui_callback_ms'] for r in rows.values()),'frame_phase_totals_ms':frame_totals,'worst_tics':worst,'rows':list(rows.values()),'qualification':manifest['qualification']}
args.output.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in summary.items() if k not in ('rows','metrics','worst_tics')},indent=2))
print(json.dumps({'top_metrics':totals[:5],'worst_tics':worst[:5]},indent=2))
