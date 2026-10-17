"""Verify and report the isolated variable-height sky experiment (#318)."""
from pathlib import Path
import argparse
import csv
import hashlib
import json
import re
import statistics
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
CONFIG=json.loads((HERE/'ceiling_zones.json').read_text())


def verify_packages(folder):
    baseline=ROOT/'build'/CONFIG['baseline_directory']
    result=[];observer_hashes=set()
    for count in (1000,6000):
        for shape in ('opaque','zoned'):
            work=folder/f'{shape}-{count}'
            original=baseline/f'{"opaque" if shape=="opaque" else "houses"}-{count}'/'runtime.pk3'
            runtime=work/'runtime.pk3'
            with zipfile.ZipFile(original) as before, zipfile.ZipFile(runtime) as after:
                assert before.namelist()==after.namelist()
                changed=[name for name in before.namelist() if before.read(name)!=after.read(name)]
                expected=[] if shape=='opaque' else ['maps/MAP06.wad','caelum/data/CaelumCartographyCatalogueData.zs']
                assert set(changed)==set(expected),changed
                if shape=='zoned':
                    assert before.read('maps/MAP06.wad')==(ROOT/'src/maps/MAP06.wad').read_bytes()
                    assert after.read('maps/MAP06.wad')==(folder/'geometry/zoned/MAP06.wad').read_bytes()
                result.append({'variant':work.name,'changed_members':changed,
                    'runtime_sha256':hashlib.file_digest(runtime.open('rb'),'sha256').hexdigest()})
            observer_hashes.add(hashlib.file_digest((work/'ceiling-observer-v2.pk3').open('rb'),'sha256').hexdigest())
    assert len(observer_hashes)==1,'Paired observers differ'
    return {'variants':result,'shared_observer_sha256':observer_hashes.pop()}


def compare_sessions(folder, rows):
    """Check matched historical controls without inventing a cause of variance."""
    old=ROOT/'build'/CONFIG['baseline_directory']
    old_rows=json.loads((old/'analysis.json').read_text())
    result=[]
    for site in (0,4):
        for previous,current in ((2,1),(3,4)):
            pair=[];records=[];censuses=[]
            for directory,items,repeat in ((old,old_rows,previous),(folder,rows,current)):
                label=f'siege1000-{site}-{repeat}'
                row=next(r for r in items if r['variant']=='opaque-1000' and r['label']==label)
                record=json.loads((directory/'opaque-1000'/(label+'-run.json')).read_text())
                records.append(record);censuses.append(row['census'])
                lower,upper=row['presentmon']['qpc_bounds_ms']
                samples=[s for s in record['cpu_samples'] if lower<s['qpc_ms']<upper]
                assert len(samples)>=2
                first,last=samples[0],samples[-1]
                cpu=(last['user_ms']+last['kernel_ms']-first['user_ms']-first['kernel_ms'])/(last['qpc_ms']-first['qpc_ms'])
                log=(directory/'opaque-1000'/(label+'.txt')).read_text(encoding='utf-8')
                start=re.search(r'CA318 START tic=(\d+) start=[\d.]+ warmup=(\d+) window=(\d+)',log)
                begin=int(start[1])+int(start[2]);end=begin+int(start[3])
                ticks=[int(t) for t in re.findall(r'CA318 FRAME tic=(\d+)',log) if begin<int(t)<end]
                pair.append({'directory':directory.name,'label':label,
                    'fps':row['presentmon']['application_present_fps'],
                    'callbacks_per_second':row['callbacks_per_second'],
                    'mean_tics_between_callbacks':statistics.mean(b-a for a,b in zip(ticks,ticks[1:])),
                    'process_cpu_seconds_per_second':cpu,
                    'cpu_observation_seconds':(last['qpc_ms']-first['qpc_ms'])/1000})
            for key in ('initial_config','engine_sha256','runtime_sha256'):
                assert records[0][key]==records[1][key],(site,key)
            assert censuses[0]==censuses[1]
            result.append({'site':site,'matched_runtime_engine_config_censuses':True,'observations':pair})
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',default=CONFIG['evidence_directory'])
    args=parser.parse_args()
    folder=ROOT/'build'/args.directory
    destination=HERE if args.directory==CONFIG['evidence_directory'] else folder
    analysis=json.loads((folder/'analysis.json').read_text())
    expected={}
    for repeat,shape in enumerate(CONFIG['order'],1):
        for site in (0,5):
            for pitch in (0,75):expected[shape+'-6000',f'peace-{site}-{pitch}-{repeat}']=(0,site,pitch,140,350)
        for site in (0,4):expected[shape+'-1000',f'siege1000-{site}-{repeat}']=(1,site,0,700,1050)
    rows=[r for r in analysis if r['label'].startswith(('peace-','siege1000-'))]
    retired=[{'variant':r['variant'],'label':r['label'],'completed':r['completed'],
              'reason':'Retired by author decision; not part of the current comparison'}
             for r in analysis if r['label'].startswith('siege6000-')]
    if args.directory==CONFIG['evidence_directory']:
        assert len(retired)==4 and sum(r['completed'] for r in retired)==3
        assert any(r['label']=='siege6000-4' and not r['completed'] for r in retired)
    assert len(rows)==len(expected) and {(r['variant'],r['label']) for r in rows}==set(expected)
    pids={r['pid'] for r in rows};timestamps={pid:[] for pid in pids}
    with (folder/'presentmon-global.csv').open(encoding='utf-8-sig',newline='') as stream:
        for row in csv.DictReader(stream):
            assert row['Application'].lower()=='gzdoom.exe'
            pid=int(row['ProcessID'])
            if pid in pids:timestamps[pid].append(float(row['CPUStartQPCTimeInMs']))
    result={'directory':folder.name,'runs':[],'comparisons':{},'functional':[],
            'packages':verify_packages(folder),'retired_runs':retired,
            'retired_test_policy':CONFIG['retired_test_policy']}
    if args.directory==CONFIG['evidence_directory']:
        result['historical_control_comparison']=compare_sessions(folder,rows)
    for row in rows:
        assert row['completed'] and row['measurement_window_complete'],row['label']
        assert row['options']['map']=='MAP06'
        assert tuple(row['options'][k] for k in ('phase','site','pitch','warmup','window'))==expected[row['variant'],row['label']]
        pm=row['presentmon'];assert pm['sample_count']>0
        record=json.loads((folder/row['variant']/(row['label']+'-run.json')).read_text())
        assert record['fixture_sha256']==result['packages']['shared_observer_sha256']
        assert record['runtime_sha256']==next(v['runtime_sha256'] for v in result['packages']['variants'] if v['variant']==row['variant'])
        times=[t for t in timestamps[row['pid']] if record['qpc_launch_ms']<t<record['qpc_exit_ms']]
        lower,upper=pm['qpc_bounds_ms']
        assert min(times)<lower and max(times)>upper, ('ETW does not bracket full observation',row['label'])
        cameras=[x for x in row['camera'] if 'CAMERA_WINDOW' in x];assert len(cameras)==1
        camera=cameras[0]
        assert 'fits=1' in camera
        pose={**CONFIG['camera_poses'][str(row['options']['site'])],'pitch':row['options']['pitch']}
        for key,value in pose.items():
            assert abs(float(re.search(r'\b'+key+r'=([-\d.]+)',camera)[1])-value)<0.01,(row['label'],key,camera)
        ceiling=float(re.search(r'ceiling=([-\d.]+)',camera)[1])
        assert ceiling==(184 if row['variant'].startswith('zoned') and row['options']['site']==5 else 1024)
        assert len(row['census'])==3
        assert [re.search(r'CENSUS (\w+) ',x)[1] for x in row['census']]==['begin','window','end']
        assert all(int(re.search(k+r'=(\d+)',row['census'][0])[1])==0 for k in ('soldiers','demons'))
        census=row['census'][1]
        pop=tuple(int(re.search(k+r'=(\d+)',census)[1]) for k in ('soldiers','demons'))
        assert pop==((600,1000 if '-1000' in row['variant'] else 6000) if row['options']['phase'] else (0,0))
        result['runs'].append({'variant':row['variant'],'label':row['label'],
            'etw_intervals':pm['sample_count'],'etw_brackets_window':True,'camera':camera,
            'censuses':row['census'],'fps':pm['application_present_fps'],'tics_per_second':row['tics_per_second'],
            'p95_frame_ms':pm['MsBetweenPresents']['p95'],'p99_frame_ms':pm['MsBetweenPresents']['p99']})
    for label,count in (('geometry-03',823),('portals-01',45),('deploy-01',3)):
        record=json.loads((folder/'zoned-6000'/(label+'-run.json')).read_text())
        log=(folder/'zoned-6000'/(label+'.txt')).read_text(encoding='utf-8')
        assert record['exit_code']==0 and 'CA318 FAIL' not in log
        assert record['runtime_sha256']==next(v['runtime_sha256'] for v in result['packages']['variants'] if v['variant']=='zoned-6000')
        assert 'CA318 DONE failures=0' in log
        assert len(re.findall(r'^CA318 PASS ',log,re.M))==count
        result['functional'].append({'label':label,'assertions':count,'runtime_sha256':record['runtime_sha256'],
                                     'fixture_sha256':record['fixture_sha256']})
    groups=[('peace-0-0-','Exterior city view, forward'),('peace-0-75-','Exterior city view, ground'),
            ('peace-5-0-','Residential street, forward'),('peace-5-75-','Residential street, ground'),
            ('siege1000-0-','1,000 attackers, city view'),('siege1000-4-','1,000 attackers, front line')]
    lines=['## Variable-height physical sky over house districts','',
        'Author-requested follow-up, 2026-10-17. This is an isolated diagnostic',
        'against the previously tested tall opaque walls. Normal source MAP06,',
        'its gameplay code and the normal package remain unchanged.', '',
        'House/shop lots plus half the existing road width receive the existing',
        '184-MU house-roof height as physical ceiling. Retained houses derive',
        'their district from their footprint, doorstep and authored road endpoint.',
        'The perimeter wall-walk belt and nonresidential exterior remain at their',
        'existing 1,024 MU; higher floors/3D volumes are excluded. Open streets',
        'retain F_SKY1. Solids whose floor reaches 184 MU close with their own',
        'opaque roof material, avoiding the native both-sky clipping exception.', '',
        'A temporary cell-flat marker splits shared sectors before compaction and',
        'is removed from the final WAD. Normal baseline regeneration is byte-exact;',
        'two diagnostic regenerations are byte-identical. Floor-cell properties,',
        'footprints, doors, map things and high control volumes are preserved.',
        'The diagnostic has 767 sectors/43,000 lines/491 things, versus normal',
        '765/42,945/491. The added 55 lines partition ceiling zones.', '',
        '### Native functional checks','',
        'Three successful runs log 871 passing assertions: all 160 doorsteps fit defender',
        'dimensions under ceiling184 and remain thermally outdoors; 64 shops keep',
        'entrance access, 160-MU interior headroom, real shelter and original window',
        'heights; 40 wall/tower positions keep standing room and ceiling1024.',
        'Actual upward movement stops under the low sky. A closed house roof has',
        'no standing headroom: this removes roof access, rather than creating a',
        'new walkable roof surface. Native Use/return and 600 unique defender',
        'deployments/cannon reassignment also pass. Counts use PASS log records,',
        'because a map transition can reconstruct the handler and reset its local',
        'DONE counter. This does not replace author',
        'acceptance of elevated views, transitions, flight or complete playability.',
        'With the local package prepared and other engines closed, preview with',
        f'`python assets/validation_issue318/house_preview.py --directory {folder.name} --variant zoned-1000`.',
        'The isolated preview uses normal input and its own config/saves; CA318-05',
        'records the outstanding author check. No preview is launched during timing.', '',
        'Two early fixture failures remain archived: geometry-01 exceeded the',
        'ZScript register limit with unrolled checks; geometry-02 waited35 tics',
        'after an upward launch and observed the player back on the floor. The',
        'corrected loop and one-tic observation pass in geometry-03. No runtime',
        'gameplay fix was made to turn those fixture failures into passes.', '',
        '### Fresh matched presentation measurements','',
        'GZDoom4.14.2, Vulkan1280x720, Ryzen9 5950X/RTX3070Ti, seed116, skill2,',
        'uncapped unpaused background rendering, 5% audio, ordinary sprites and',
        'inventories. One engine at a time. The same immutable observer is used',
        'for both shapes. Each condition runs opaque-zoned-zoned-opaque.',
        'No profiling instrumentation is added to gameplay methods.', '',
        'Sites0 `(0,320,0)` and4 `(-14464,-14000,0)` remain in the high region.',
        'Site5 is the authored HouseRoad(0), facing90 along its residential street;',
        'native camera markers prove ceiling184 in zoned and1024 in opaque.',
        'Peace:140 warmup/350 observation tics, pitch0/75. Siege:700 warmup/',
        '1050 observation tics, 600 defenders and1000 attackers. All24 windows',
        'assert valid camera collision and initial populations. Geometry can alter',
        'combat trajectories; end censuses are retained for every run.', '',
        'ETW measures application presents, not display refresh. The collector',
        'is bounded to30 minutes. Every included process has presentation events',
        'before and after its trimmed QPC observation window. Host markers use',
        '200-ms polling and300/500-ms edge trims; no exact per-tic correlation',
        'or complete additive CPU/GPU attribution is claimed.', '',
        '| Scene | Tall opaque walls FPS | Zoned sky FPS | Tall tics/s | Zoned tics/s |',
        '| --- | ---: | ---: | ---: | ---: |']
    for prefix,title in groups:
        values={};cells=[title]
        for shape in ('opaque','zoned'):
            subset=[r for r in result['runs'] if r['variant'].startswith(shape) and r['label'].startswith(prefix)]
            assert len(subset)==2
            values[shape]={key:[min(r[key] for r in subset),max(r[key] for r in subset)]
                           for key in ('fps','tics_per_second','p95_frame_ms','p99_frame_ms')}
        result['comparisons'][prefix]=values
        for key in ('fps','tics_per_second'):
            for shape in ('opaque','zoned'):
                cells.append('-'.join(f'{v:.2f}' for v in values[shape][key]))
        lines.append('| '+' | '.join(cells)+' |')
    lines+=['','Ranges contain two per-run means, not instantaneous FPS extremes or',
            'confidence intervals. Earlier normal-shell/opaque results were captured',
            'in another session; compare the fresh paired controls above for this',
            'experiment, rather than treating historical values as a new third arm.','',
            '| Variant / run | App FPS | Tics/s | ETW N | p95 ms | p99 ms |',
            '| --- | ---: | ---: | ---: | ---: | ---: |']
    for r in result['runs']:
        lines.append('| '+' | '.join([r['variant']+' / '+r['label'],f'{r["fps"]:.2f}',f'{r["tics_per_second"]:.2f}',
            str(r['etw_intervals']),f'{r["p95_frame_ms"]:.2f}' if r['etw_intervals']>=30 else 'n/a',
            f'{r["p99_frame_ms"]:.2f}' if r['etw_intervals']>=30 else 'n/a'])+' |')
    lines+=['','Tail percentiles are withheld when fewer than30 intervals are available.']
    if 'historical_control_comparison' in result:
        lines+=['','### Unresolved difference between sessions','',
            'The unchanged tall-wall control is slower than in house-perf-03.',
            'Exact runtime, engine, initial configuration and full population/end',
            'censuses match. Independent review also matched the final INI and',
            'breath counts. The observer adds only site5 and two CeilingZ log fields.',
            'Native callbacks slow along with ETW, so this is not merely an ETW',
            'parser artifact. Process CPU samples are aggregate CPU time across',
            'all process threads, not main-thread/GPU utilization. They use the',
            'first/last available samples strictly inside each trimmed window.', '',
            '| Control | Historical FPS / callbacks per s / tics per callback / CPU-s per s | Current values |',
            '| --- | ---: | ---: |']
        for pair in result['historical_control_comparison']:
            cells=[f'site{pair["site"]} / '+pair['observations'][1]['label']]
            for obs in pair['observations']:
                cells.append(' / '.join(f'{obs[k]:.3f}' for k in ('fps','callbacks_per_second','mean_tics_between_callbacks','process_cpu_seconds_per_second')))
            lines.append('| '+' | '.join(cells)+' |')
        lines+=['','This supports a tighter simulation/rendering time budget in this',
            'session; the cause of the session difference is not identified.',
            'Post-window thinker snapshots also cost more, but they cannot prove',
            'a thermal, power, scheduling or external-application cause. No such',
            'cause is asserted. Use only the fresh paired controls for the ceiling',
            'comparison and do not treat earlier siege FPS as a current guarantee.']
    lines+=['','### Native renderer work after the peaceful window','',
            'These are point samples after the timed window, not ETW FPS or GPU',
            'durations. CPU renderer clocks can overlap; they must not be summed.','',
            '| View | Tall wall jobs / flats / flat vertices | Zoned wall jobs / flats / flat vertices |',
            '| --- | ---: | ---: |']
    for site in (0,5):
        for pitch in (0,75):
            cells=[f'site{site} / pitch{pitch}']
            for shape,repeat in (('opaque',1),('zoned',2)):
                bench=(folder/(shape+'-6000')/f'peace-{site}-{pitch}-{repeat}-bench.txt').read_text()
                counts=[re.search(key+r': (\d+)',bench)[1] for key in ('Walls','Flats')]
                counts.append(re.search(r'Flats: \d+ \(\d+ primitives, (\d+) vertices\)',bench)[1])
                cells.append(' / '.join(counts))
            lines.append('| '+' | '.join(cells)+' |')
    lines+=['','### Retired full-army tests','',
            'During this batch the author ruled out 6,000 simultaneous actors and',
            'instructed that this size never be tested again. Three earlier full-army',
            'runs had completed; the fourth owned engine was stopped immediately',
            'on request. Its incomplete-run traceback is an intentional author stop,',
            'not an observed engine crash. All four raw records remain preserved',
            'outside the current24-window comparison. AUTHOR_STOP.json records',
            'the decision. The siege6000 runner now refuses execution. No further',
            'full-army run is required or authorized; no replacement production',
            'army budget is invented. Peaceful runs named *-6000 contain zero',
            'attackers; their suffix identifies the prepared historical package.', '',
            '### Reproduction and package scope','',
            'From the tested house-perf-03 baseline, run `ceiling_perf.py prepare`,',
            'then `ceiling_perf.py observer`. Preparation refuses to overwrite an',
            'existing evidence directory; use `--directory` for a fresh local run.',
            'Use run.py with checks-v3.pk3 and the generated geometry.cfg, portals.cfg',
            'and deploy.cfg for the functional checks. With one authorized PresentMon',
            'collector, run peace and siege1000 serially. Do not run siege6000.',
            'Wait for CSV release before',
            'analysis. Run analyze.py with this directory and its explicit collector,',
            'then `ceiling_report.py --directory NEW`. A new-directory reproduction',
            'writes its report/verification inside that build directory, preserving',
            'the canonical results of this run. The default directory and baseline',
            'are declared in ceiling_zones.json.', '',
            'Exact package comparison verifies that opaque controls are unchanged;',
            'zoned packages differ from the corresponding house baseline only in',
            'MAP06 and its cartography checksum. All four use the same observer hash.',
            'The baseline MAP06 still matches src. Policy and source',
            'authorities are in ceiling_zones.json; geometry metadata, packages hashes,',
            'configs, native logs, captures and ETW are retained in the evidence.',
            'Normal bounded attacker deployment, acceptable siege FPS and author review',
            'remain open under #318. Diagnostic ceilings are not adopted production',
            'geometry and do not select a new army budget.','']
    section='<!-- CEILINGS_BEGIN -->\n'+'\n'.join(lines)+'\n<!-- CEILINGS_END -->'
    path=destination/'RESULTS.md';content=path.read_text(encoding='utf-8') if path.exists() else '# Variable-height sky experiment (#318)\n'
    if '<!-- CEILINGS_BEGIN -->' in content:
        content=re.sub(r'<!-- CEILINGS_BEGIN -->.*?<!-- CEILINGS_END -->',lambda _:section,content,flags=re.S)
    else:content+='\n'+section+'\n'
    path.write_text(content,encoding='utf-8')
    (destination/'CEILING_VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result['comparisons'],indent=2))


if __name__=='__main__':main()
