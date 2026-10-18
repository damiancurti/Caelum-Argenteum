"""Validate matched siege windows and summarize presented-frame evidence."""
from pathlib import Path
import argparse
import collections
import csv
import hashlib
import json
import math
import re
import statistics

ROOT = Path(__file__).resolve().parents[2]


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def fields(line):
    return dict(re.findall(r'(\w+)=([^\s]+)', line))


def percentile(values, p):
    values = sorted(values)
    rank = (len(values) - 1) * p
    lower = int(rank)
    return values[lower] + (values[math.ceil(rank)] - values[lower]) * (rank - lower)


def stats(values):
    assert values
    return dict(n=len(values), mean=statistics.mean(values), median=statistics.median(values),
                p95=percentile(values, .95), p99=percentile(values, .99), maximum=max(values))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--collector', required=True)
    args = parser.parse_args()
    folder = ROOT / 'build' / args.directory
    manifest = read_json(folder / 'manifest.json')
    order = read_json(folder / 'matrix-order.json')
    plan = read_json(folder / 'matrix-plan.json')
    expected = (len(plan['modes'].split(',')) + 1) * len(plan['sites'].split(',')) * plan['rounds']
    assert len(order) == expected, (len(order), expected)
    expected_labels = {}
    for repeat in range(plan['rounds']):
        active = [int(x) for x in plan['modes'].split(',') if int(x) != 0]
        if repeat % 2:
            active.reverse()
        for site in [int(x) for x in plan['sites'].split(',')]:
            for index, mode in enumerate([0] + active + [0]):
                expected_labels[f"matrix-s{site}-r{repeat}-n{index}-m{mode}"] = (site, repeat, mode)
    assert len({item['label'] for item in order}) == len(order)
    assert set(expected_labels) == {item['label'] for item in order}
    records = []
    wanted = collections.defaultdict(list)
    for item in order:
        label = item['label']
        assert (item['site'], item['repeat'], item['mode']) == expected_labels[label]
        assert item['seed_sha256'] == plan['seed_sha256']
        native = read_json(folder / (label + '-run.json'))
        assert native['exit_code'] == 0 and not item['audit']
        assert native['runtime_sha256'].lower() == manifest['runtime_sha256']
        assert native['fixture_sha256'].lower() == manifest['fixture_sha256']
        text = (folder / (label + '.txt')).read_text(encoding='utf-8-sig')
        assert 'CA282 DONE passes=1 failures=0' in text and 'CA282 FAIL' not in text
        assert not re.search(r'VM execution aborted|Script error|JIT error', text)
        assert 'Resolution: 1280 x 720' in text and 'Vulkan device: NVIDIA GeForce RTX 3070 Ti' in text, label
        lines = text.splitlines()
        begin = fields(next(x for x in lines if x.startswith('STAGGER BEGIN')))
        end = fields(next(x for x in lines if x.startswith('STAGGER END')))
        settings = fields(next(x for x in lines if x.startswith('STAGGER SETTINGS')))
        assert int(end['tic']) - int(begin['tic']) == 700
        assert int(begin['tic']) == manifest['measurement_start_tic'] == 3750
        assert 0 < int(begin['armedtic']) < int(begin['scheduledtic']) == 3750
        assert settings == dict(vsync='0', capfps='0', maxfps='0', pause='0', render='1', lower='0', audio='0.050'), settings
        assert begin['audit'] == '0' and end['failures'] == '0'
        assert int(begin['mode']) == item['mode'] and int(begin['site']) == item['site']
        counts = [fields(x) for x in lines if x.startswith('STAGGER COUNTS')]
        assert [int(x['key']) for x in counts] == list(range(5))
        for key, bit in enumerate((1,1,2,4,16)):
            requested, computed, raw = (int(counts[key][field]) for field in ('requests','computed','raw'))
            assert raw > 0, (label, key, 'family did not execute')
            if item['mode'] & bit:
                assert raw == computed and (key == 4 or requested >= computed), (label, key, counts[key])
            else:
                assert requested == computed == 0, (label, key, counts[key])
        census = [fields(x) for x in lines if x.startswith('STAGGER CENSUS')]
        assert len(census) == 9, len(census)
        expected_camera = (0, 320, 0, 180, 0) if item['site'] == 0 else (-14464, -14000, 0, 270, 0)
        assert all(tuple(float(x[k]) for k in ('x','y','z','angle','pitch')) == expected_camera for x in census), label
        assert [x['label'] for x in census] == ['start'] + ['sample']*7 + ['end']
        assert [int(x['tic']) for x in census] == [int(begin['tic']) + t for t in [0,100,200,300,400,500,600,700,700]]
        phases = fields(next(x for x in lines if x.startswith('STAGGER PHASES')))
        assert int(phases['max']) - int(phases['min']) <= 1
        marker = item['markers']
        lower = marker['STAGGER BEGIN']['qpc_seen_ms'] + 1000
        upper = marker['STAGGER END']['qpc_seen_ms'] - 1000
        duration = (float(end['ms']) - float(begin['ms'])) / 1000
        observed_duration = (marker['STAGGER END']['qpc_seen_ms'] - marker['STAGGER BEGIN']['qpc_seen_ms']) / 1000
        assert upper > lower and abs(observed_duration - duration) < .5, (label, duration, observed_duration)
        frame_rows = [fields(x) for x in lines if x.startswith('STAGGER FRAME ')]
        frames = [float(x['interval']) for x in frame_rows]
        assert len(frames) == int(fields(next(x for x in lines if x.startswith('STAGGER FRAMES_END')))['count'])
        assert all(math.isfinite(x) and x > 0 for x in frames)
        assert all(float(b['ms']) > float(a['ms']) for a,b in zip(frame_rows, frame_rows[1:]))
        record = dict(item, pid=native['pid'], engine_sha256=native['engine_sha256'], runtime_sha256=manifest['runtime_sha256'],
                      begin=begin, end=end, phases=phases, settings=settings, census=census,
                      counts=counts, thermal=fields(next(x for x in lines if x.startswith('STAGGER THERMAL'))),
                      duration_seconds=duration, tics_per_second=700/duration,
                      marker_duration_error_seconds=observed_duration-duration,
                      callback_intervals_ms=stats(frames), callback_window='Full 700-tic interval; differs from trimmed ETW interval', qpc_bounds_ms=[lower, upper],
                      presentation_times=[], presentation_intervals=[], present_modes=collections.Counter(), swapchains=set())
        records.append(record)
        wanted[native['pid']].append(record)
    collector = ROOT / args.collector
    selected_csv = folder / 'matrix-presentmon.csv'
    with collector.open(encoding='utf-8-sig', newline='') as stream, selected_csv.open('w', encoding='utf-8', newline='') as output:
        reader = csv.DictReader(stream)
        writer = csv.DictWriter(output, fieldnames=['RunLabel','WithinWindow'] + reader.fieldnames)
        writer.writeheader()
        for row in reader:
            for record in wanted.get(int(row['ProcessID']), []):
                timestamp = float(row['CPUStartQPCTimeInMs'])
                lower, upper = record['qpc_bounds_ms']
                interval = float(row['MsBetweenPresents']) if row['MsBetweenPresents'] not in ('', 'NA') else 0
                selected = lower < timestamp and timestamp + interval <= upper and math.isfinite(interval) and interval > 0
                if lower - 2000 <= timestamp <= upper + 2000:
                    record.setdefault('coverage_min', timestamp)
                    record['coverage_max'] = timestamp
                    writer.writerow(dict(RunLabel=record['label'],WithinWindow=int(selected),**row))
                if selected:
                    record['presentation_times'].append(timestamp)
                    record['presentation_intervals'].append(interval)
                    record['present_modes'][row['PresentMode']] += 1
                    record['swapchains'].add((row['SwapChainAddress'], row.get('PresentRuntime', row.get('Runtime', ''))))
    for record in records:
        lower, upper = record['qpc_bounds_ms']
        assert record.get('coverage_min', upper) < lower and record.get('coverage_max', lower) > upper, record['label']
        intervals = record.pop('presentation_intervals')
        timestamps = record.pop('presentation_times')
        assert all(b>a for a,b in zip(timestamps,timestamps[1:])), record['label']
        assert len(record['swapchains']) == 1, (record['label'], record['swapchains'])
        record['swapchains'] = sorted(record['swapchains'])
        assert len(timestamps) > 100 and timestamps[0] < lower + 500 and timestamps[-1] > upper - 500, record['label']
        record['present_interval_ms'] = stats(intervals)
        record['application_present_fps'] = 1000 / statistics.mean(intervals)
        record['start_interval_fps'] = (len(timestamps)-1)*1000/(timestamps[-1]-timestamps[0])
        assert abs(record['start_interval_fps']/record['application_present_fps']-1) < .05, record['label']
        record['present_sample_count'] = len(timestamps)
    assert len({r['begin']['tic'] for r in records}) == 1
    assert len({r['engine_sha256'] for r in records}) == 1
    assert records[0]['engine_sha256'].lower() == 'ec706c2ea1ef946eec13be7b1b461df8d52efcd47caa6c056ed0e0257f7f9ffa'
    comparisons = []
    for site in sorted({r['site'] for r in records}):
        for repeat in range(plan['rounds']):
            group = [r for r in records if r['site'] == site and r['repeat'] == repeat]
            baseline = [r for r in group if r['mode'] == 0]
            assert len(baseline) == 2
            assert all(r['census'][0] == baseline[0]['census'][0] for r in group), ('Initial scene differs', site, repeat)
            assert all((r['begin']['workers'],r['begin']['groups']) == (baseline[0]['begin']['workers'],baseline[0]['begin']['groups']) for r in group)
            for record in group:
                reference = next((r for r in group if r['mode'] == 39), None) if record['mode'] == 103 else baseline[0]
                if record['mode'] not in (0, 1, 2, 4, 7, 103):
                    continue
                differences = []
                for index, (first, second) in enumerate(zip(reference['census'], record['census'])):
                    for key in first:
                        if first[key] != second[key]:
                            differences.append(dict(checkpoint=index, field=key, reference=first[key], observed=second[key]))
                comparisons.append(dict(label=record['label'], reference=reference['label'],
                                        status='REFERENCE' if record['label']==reference['label'] else 'FAIL' if differences else 'PASS', differences=differences))
    summary = []
    for site in sorted({r['site'] for r in records}):
        for mode in [int(x) for x in plan['modes'].split(',')]:
            group = [r for r in records if r['site'] == site and r['mode'] == mode]
            fps = [r['application_present_fps'] for r in group]
            p99 = [r['present_interval_ms']['p99'] for r in group]
            paired = []
            for record in group:
                controls = [r for r in records if r['site'] == site and r['repeat'] == record['repeat'] and r['mode'] == 0]
                control_fps = statistics.mean(r['application_present_fps'] for r in controls)
                paired.append((record['application_present_fps']/control_fps-1)*100)
            summary.append(dict(site=site, mode=mode, runs=len(group),
                                fps_median=statistics.median(fps), fps_range=[min(fps),max(fps)],
                                p99_median=statistics.median(p99), p99_range=[min(p99),max(p99)],
                                bracketed_fps_change_percent_median=statistics.median(paired),
                                bracketed_fps_change_percent_range=[min(paired),max(paired)],
                                raw_calls_median=[statistics.median(int(r['counts'][k]['raw']) for r in group) for k in range(5)],
                                queries_median=statistics.median(int(r['end']['targetqueries']) for r in group)))
    result = dict(method='Application presentation intervals, not display refresh or CPU time; 50ms host-marker polling, 1s trims each end.',
                  collector_sha256=hashlib.sha256(collector.read_bytes()).hexdigest(),
                  selected_csv_sha256=hashlib.sha256(selected_csv.read_bytes()).hexdigest(),
                  plan=plan, manifest=manifest, summary=summary, state_comparisons=comparisons,
                  nontrivial_comparisons=sum(c['status']!='REFERENCE' for c in comparisons),
                  aggregate_equivalence_passed=not any(c['differences'] for c in comparisons),
                  equivalence_scope='Aggregate checkpoint equality only; separate audited raw reads test individual derived values.',
                  records=records)
    (folder / 'analysis.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8', newline='\n')
    by_key={(x['site'],x['mode']):x for x in summary}
    def interval(row,metric):
        lo,hi=row[metric+'_range']
        return f"{row[metric+'_median']:.2f} [{lo:.2f}-{hi:.2f}]"
    table=['| Variant | City FPS | Front FPS | City p99 ms | Front p99 ms |',
           '| --- | ---: | ---: | ---: | ---: |']
    for mode in [int(x) for x in plan['modes'].split(',')]:
        city,front=by_key[(0,mode)],by_key[(1,mode)]
        table.append(f"| {mode}: {manifest['modes'][str(mode)]} | {interval(city,'fps')} | {interval(front,'fps')} | {interval(city,'p99')} | {interval(front,'p99')} |")
    table+=['','| Complete calculations / city window | Baseline | Mode 7 | Reduction |',
            '| --- | ---: | ---: | ---: |']
    for key,name in enumerate(('Health-derived statistics','Offensive statistics','Carried-weight traversal','Resource recovery block')):
        old,new=by_key[(0,0)]['raw_calls_median'][key],by_key[(0,7)]['raw_calls_median'][key]
        table.append(f'| {name} | {old:,.0f} | {new:,.0f} | {(1-new/old)*100:.2f}% |')
    table+=['','| Variant vs bracketing baseline | City FPS change % | Front FPS change % |',
            '| --- | ---: | ---: |']
    for mode in [int(x) for x in plan['modes'].split(',') if int(x)!=0]:
        table.append(f"| {mode}: {manifest['modes'][str(mode)]} | {interval(by_key[(0,mode)],'bracketed_fps_change_percent')} | {interval(by_key[(1,mode)],'bracketed_fps_change_percent')} |")
    (folder/'summary-tables.md').write_text('\n'.join(table)+'\n',encoding='utf-8',newline='\n')
    for row in summary:
        print(f"site={row['site']} mode={row['mode']} FPS={row['fps_median']:.2f} range={row['fps_range']} p99={row['p99_median']:.2f}")
    print('Aggregate state comparisons:',len(comparisons),'FAIL:',sum(bool(c['differences']) for c in comparisons))


if __name__ == '__main__':
    main()
