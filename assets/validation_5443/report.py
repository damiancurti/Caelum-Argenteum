"""Validate same-save runtime comparisons and summarize complete ETW intervals."""
from pathlib import Path
import argparse
import collections
import csv
import hashlib
import importlib.util
import json
import math
import re
import statistics

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('prior_report',ROOT/'assets/validation_5442/report.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)
read_json,fields,stats=prior.read_json,prior.fields,prior.stats

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--collector',type=Path,required=True)
    p.add_argument('--prefix',default='matrix')
    p.add_argument('--require-equivalent',action='store_true')
    a=p.parse_args();folder=ROOT/'build'/a.directory
    manifest=read_json(folder/'manifest.json');order=read_json(folder/(a.prefix+'-order.json'));plan=read_json(folder/(a.prefix+'-plan.json'))
    expected={f'{a.prefix}-s{s}-r{r}-n{i}-m{m}':(s,r,m) for r in range(plan['rounds']) for s in map(int,plan['sites'].split(',')) for i,m in enumerate((0,1,0))}
    assert len(order)==len(expected) and {x['label'] for x in order}==set(expected)
    assert hashlib.sha256((folder/'cache-battle.zds').read_bytes()).hexdigest()==plan['seed_sha256']
    records=[];wanted=collections.defaultdict(list)
    for item in order:
        label=item['label'];assert (item['site'],item['repeat'],item['mode'])==expected[label]
        assert item['runtime']==plan['variant' if item['mode'] else 'control']
        assert item['fixture']==('front/city.pk3' if item['site'] else 'city.pk3')
        assert item['seed_sha256']==plan['seed_sha256']
        native=read_json(folder/(label+'-run.json'));assert native['exit_code']==0
        assert native['runtime_sha256'].lower()==manifest['hashes'][item['runtime']]
        assert native['fixture_sha256'].lower()==manifest['hashes'][item['fixture']]
        text=(folder/(label+'.txt')).read_text(encoding='utf-8-sig');lines=text.splitlines()
        assert 'CA282 DONE passes=1 failures=0' in text and 'CA282 FAIL' not in text
        assert not re.search(r'VM execution aborted|Script error|JIT error|CACHE AUDIT',text)
        assert 'Resolution: 1280 x 720' in text and 'Vulkan device: NVIDIA GeForce RTX 3070 Ti' in text
        begin=fields(next(x for x in lines if x.startswith('CACHE BEGIN')))
        fps_begin=fields(next(x for x in lines if x.startswith('CACHE FPS_BEGIN')))
        end=fields(next(x for x in lines if x.startswith('CACHE END')))
        settings=fields(next(x for x in lines if x.startswith('CACHE SETTINGS')))
        assert settings==dict(vsync='0',capfps='0',maxfps='0',pause='0',render='1',lower='0',audio='0.050')
        assert int(begin['site'])==item['site'] and int(end['tic'])-int(begin['tic'])==700
        assert int(fps_begin['tic'])-int(begin['tic'])==70
        census=[fields(x) for x in lines if x.startswith('CACHE CENSUS')]
        assert len(census)==9 and [x['label'] for x in census]==['start']+['sample']*7+['end']
        assert [int(x['tic']) for x in census]==[int(begin['tic'])+t for t in [0,100,200,300,400,500,600,700,700]]
        pose=(0,320,0,180,0) if item['site']==0 else (-14464,-14000,0,270,0)
        assert all(tuple(float(x[k]) for k in ('x','y','z','angle','pitch'))==pose for x in census)
        markers=item['markers'];lower=markers['CACHE FPS_BEGIN']['qpc_seen_ms']+1000;upper=markers['CACHE END']['qpc_seen_ms']-1000
        duration=(float(end['ms'])-float(begin['ms']))/1000
        fps_duration=(float(end['ms'])-float(fps_begin['ms']))/1000
        observed=(markers['CACHE END']['qpc_seen_ms']-markers['CACHE FPS_BEGIN']['qpc_seen_ms'])/1000
        assert upper>lower and abs(observed-fps_duration)<.5,(label,fps_duration,observed)
        frame_rows=[fields(x) for x in lines if x.startswith('CACHE FRAME ')]
        frames=[float(x['interval']) for x in frame_rows]
        assert len(frames)==int(fields(next(x for x in lines if x.startswith('CACHE FRAMES_END')))['count'])
        assert all(math.isfinite(x) and x>0 for x in frames)
        assert all(float(b['ms'])>float(a['ms']) for a,b in zip(frame_rows,frame_rows[1:]))
        record=dict(item,pid=native['pid'],engine_sha256=native['engine_sha256'],runtime_sha256=native['runtime_sha256'],
            begin=begin,fps_begin=fps_begin,end=end,settings=settings,census=census,duration_seconds=duration,tics_per_second=700/duration,
            fps_duration_seconds=fps_duration,marker_duration_error_seconds=observed-fps_duration,callback_intervals_ms=stats(frames),
            callback_window='Full 700-tic interval, separate from trimmed ETW',qpc_bounds_ms=[lower,upper],
            presentation_times=[],presentation_intervals=[],present_modes=collections.Counter(),swapchains=set())
        records.append(record);wanted[native['pid']].append(record)
    selected_csv=folder/(a.prefix+'-presentmon.csv')
    with a.collector.open(encoding='utf-8-sig',newline='') as stream,selected_csv.open('w',encoding='utf-8',newline='') as output:
        reader=csv.DictReader(stream);writer=csv.DictWriter(output,fieldnames=['RunLabel','WithinWindow']+reader.fieldnames);writer.writeheader()
        for row in reader:
            for record in wanted.get(int(row['ProcessID']),[]):
                timestamp=float(row['CPUStartQPCTimeInMs']);lower,upper=record['qpc_bounds_ms']
                interval=float(row['MsBetweenPresents']) if row['MsBetweenPresents'] not in ('','NA') else 0
                selected=lower<timestamp and timestamp+interval<=upper and math.isfinite(interval) and interval>0
                if lower-2000<=timestamp<=upper+2000:
                    record.setdefault('coverage_min',timestamp);record['coverage_max']=timestamp
                    writer.writerow(dict(RunLabel=record['label'],WithinWindow=int(selected),**row))
                if selected:
                    record['presentation_times'].append(timestamp);record['presentation_intervals'].append(interval)
                    record['present_modes'][row['PresentMode']]+=1
                    record['swapchains'].add((row['SwapChainAddress'],row.get('PresentRuntime',row.get('Runtime',''))))
    for record in records:
        lower,upper=record['qpc_bounds_ms']
        assert record.get('coverage_min',upper)<lower and record.get('coverage_max',lower)>upper,record['label']
        intervals=record.pop('presentation_intervals');times=record.pop('presentation_times')
        assert all(b>a for a,b in zip(times,times[1:])),record['label']
        assert len(record['swapchains'])==1;record['swapchains']=sorted(record['swapchains'])
        assert record['swapchains'][0][0]!='0x0' and record['swapchains'][0][1]=='DXGI',('Not the validated game presentation chain',record['label'],record['swapchains'])
        assert len(times)>100 and times[0]<lower+500 and times[-1]>upper-500,record['label']
        record['present_interval_ms']=stats(intervals);record['application_present_fps']=1000/statistics.mean(intervals)
        record['start_interval_fps']=(len(times)-1)*1000/(times[-1]-times[0])
        assert abs(record['start_interval_fps']/record['application_present_fps']-1)<.05
        record['present_sample_count']=len(times)
    assert len({r['begin']['tic'] for r in records})==1
    assert {r['engine_sha256'].lower() for r in records}=={'ec706c2ea1ef946eec13be7b1b461df8d52efcd47caa6c056ed0e0257f7f9ffa'}
    comparisons=[]
    for site in sorted({r['site'] for r in records}):
        group=[r for r in records if r['site']==site]
        assert all(r['census'][0]==group[0]['census'][0] for r in group),('Initial state differs',site)
        assert all((r['begin']['workers'],r['begin']['groups'])==(group[0]['begin']['workers'],group[0]['begin']['groups']) for r in group)
        for mode in (0,1):
            same=[r for r in group if r['mode']==mode]
            for r in same:comparisons.append(dict(label=r['label'],reference=same[0]['label'],aggregate_equal=r['census']==same[0]['census']))
    assert all(x['aggregate_equal'] for x in comparisons),'Same-condition combat replay diverged; investigate before using FPS'
    cross=[]
    for r in records:
        if r['mode']!=1:continue
        for control in records:
            if control['mode']==0 and control['site']==r['site'] and control['repeat']==r['repeat']:
                cross.append(dict(label=r['label'],reference=control['label'],aggregate_equal=r['census']==control['census']))
    if a.require_equivalent:assert all(x['aggregate_equal'] for x in cross),'Candidate changed combat checkpoints'
    summary=[]
    for site in sorted({r['site'] for r in records}):
        for mode in (0,1):
            group=[r for r in records if r['site']==site and r['mode']==mode]
            fps=[r['application_present_fps'] for r in group];p99=[r['present_interval_ms']['p99'] for r in group];paired=[]
            for r in group:
                controls=[x for x in records if x['site']==site and x['repeat']==r['repeat'] and x['mode']==0]
                paired.append((r['application_present_fps']/statistics.mean(x['application_present_fps'] for x in controls)-1)*100)
            summary.append(dict(site=site,mode=mode,runs=len(group),fps_median=statistics.median(fps),fps_range=[min(fps),max(fps)],
                p99_median=statistics.median(p99),p99_range=[min(p99),max(p99)],paired_change_median=statistics.median(paired),paired_change_range=[min(paired),max(paired)]))
    result=dict(method='Application presentation intervals after 70-tic startup warmup; 50ms host marker polling, 1s trims; complete intervals only. Not display refresh or subsystem CPU cost.',
        collector_sha256=hashlib.sha256(a.collector.read_bytes()).hexdigest(),selected_csv_sha256=hashlib.sha256(selected_csv.read_bytes()).hexdigest(),
        manifest=manifest,plan=plan,summary=summary,same_condition_state_comparisons=comparisons,
        cross_condition_state_comparisons=cross,cross_condition_aggregate_equal=all(x['aggregate_equal'] for x in cross),records=records)
    (folder/(a.prefix+'-analysis.json')).write_text(json.dumps(result,indent=2)+'\n')
    table=['| Camera / runtime | Median FPS [run range] | Median p99 ms [run range] | Paired FPS change |','| --- | ---: | ---: | ---: |']
    for r in summary:
        table.append(f"| {['City','Front'][r['site']]} / {['control','variant'][r['mode']]} | {r['fps_median']:.2f} [{r['fps_range'][0]:.2f}-{r['fps_range'][1]:.2f}] | {r['p99_median']:.2f} [{r['p99_range'][0]:.2f}-{r['p99_range'][1]:.2f}] | {r['paired_change_median']:+.2f}% |")
    (folder/(a.prefix+'-tables.md')).write_text('\n'.join(table)+'\n')
    print('\n'.join(table));print('Same-condition aggregate mismatches:',sum(not x['aggregate_equal'] for x in comparisons))

if __name__=='__main__':main()
