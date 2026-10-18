"""Summarize native MAP03 timing; callback cadence is never presented FPS."""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import re
import statistics

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('directory')
parser.add_argument('--verify', action='store_true')
args = parser.parse_args()
folder = ROOT / 'build' / args.directory
manifest = json.loads((folder / 'manifest.json').read_text())
methods = {m['id']: m for m in manifest.get('methods', [])}
if args.verify:
    for file, key in (('production.pk3', 'runtime_sha256'), ('quick.pk3', 'fixture_sha256')):
        assert hashlib.sha256((folder / file).read_bytes()).hexdigest() == manifest[key], (file, 'package hash')
result = {'directory': args.directory, 'runtime': manifest['runtime_sha256'], 'cases': {}}
for label in ('peace-forward', 'peace-ground', 'siege-city', 'siege-front'):
    path = folder / (label + '.txt')
    if not path.exists():
        assert not args.verify, (label, 'missing log')
        continue
    log = path.read_text(encoding='utf-8', errors='replace')
    start = re.search(r'CA318 START tic=(\d+).*?warmup=(\d+) window=(\d+)', log)
    if not start:
        continue
    begin = int(start[1]) + int(start[2])
    end = begin + int(start[3])
    tick_rows = re.findall(r'CA318 TICK tic=(\d+) ms=([\d.]+)', log)
    ticks = {int(t): float(ms) for t, ms in tick_rows}
    if args.verify:
        run = json.loads((folder / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        assert run['exit_code'] == 0, (label, 'exit status')
        for key in ('runtime_sha256', 'fixture_sha256'):
            assert run[key].lower() == manifest[key], (label, key)
        assert not re.search(r'CA(?:318|282) FAIL|Script error|VM execution aborted|JIT error', log), label
        for marker in ('CA318 START ', 'CA318 WINDOW ', 'CA318 DONE ', 'CA318 FRAMES_END ', 'CA282 DONE passes=1 failures=0'):
            assert log.count(marker) == 1, (label, marker)
        assert len(ticks) == len(tick_rows) and all(t in ticks for t in range(begin, end + 1)), (label, 'tick continuity')
        assert all(ticks[t + 1] > ticks[t] for t in range(begin, end)), (label, 'monotonic world clock')
        assert 'CA318 SETTINGS vsync=0 capfps=0 maxfps=0 pause=0 render=1 lower=0 audio=0.050' in log, (label, 'settings')
        expected = 'x=-14464.000 y=-14000.000 z=0.000 angle=270.000 pitch=0.000' if label == 'siege-front' else 'x=0.000 y=320.000 z=-0.000 angle=180.000 pitch=' + ('75.000' if label == 'peace-ground' else '0.000')
        assert 'CA318 CAMERA_WINDOW ' + expected + ' fits=1' in log, (label, 'fixed camera')
    # Render callbacks carry a different tic phase. Match their entire wall-clock
    # interval against the world-clock bounds instead of filtering that label.
    frames = [(float(ms), float(v)) for t, ms, v in re.findall(r'CA318 FRAME tic=(\d+) ms=([\d.]+) interval=([\d.]+)', log)]
    if args.verify:
        assert len(frames) == int(re.search(r'CA318 FRAMES_END count=(\d+)', log)[1]), (label, 'frame record continuity')
    samples = [v for ms, v in frames if begin in ticks and end in ticks
               and ms - v >= ticks[begin] and ms <= ticks[end]]
    cost = collections.defaultdict(dict)
    for t, key, calls, inc, exc in re.findall(r'CA318 COST tic=(\d+) id=(\d+) calls=(\d+) inclusive=([\d.]+) exclusive=([\d.]+)', log):
        t, key = int(t), int(key)
        if not methods[key]['always']:
            assert t % 17 in (0, 16), (label, key, t, 'unexpected sampling phase')
            if t % 17 == 16:
                t += 1
        if begin <= t < end:
            prior = cost[key].get(t, (0, 0.0, 0.0))
            cost[key][t] = (prior[0] + int(calls), prior[1] + float(inc), prior[2] + float(exc))
    ranking = []
    for key, by_tic in cost.items():
        method = methods[key]
        denominator = end - begin if method['always'] else sum(t % 17 == 0 for t in range(begin, end))
        ranking.append({'method': method['class'] + '.' + method['method'], 'sample_tics': denominator,
                        'calls_per_sample_tic': sum(v[0] for v in by_tic.values()) / denominator,
                        'inclusive_ms_per_sample_tic': sum(v[1] for v in by_tic.values()) / denominator,
                        'exclusive_ms_per_sample_tic': sum(v[2] for v in by_tic.values()) / denominator})
    ranking.sort(key=lambda item: item['exclusive_ms_per_sample_tic'], reverse=True)
    item = {'complete': 'CA282 DONE passes=1 failures=0' in log,
            'failures': re.findall(r'^.*CA318 FAIL.*$', log, re.M),
            'census': re.findall(r'CA318 CENSUS (?:window|end)[^\r\n]+', log),
            'camera': re.findall(r'CA318 CAMERA_WINDOW[^\r\n]+', log),
            'simulation_tics_per_second': (end - begin) * 1000 / (ticks[end] - ticks[begin]) if begin in ticks and end in ticks else None,
            'window_wall_ms': [ticks.get(begin), ticks.get(end)],
            'ui_callback_count': len(samples),
            'ui_callback_mean_ms_not_presentation': statistics.mean(samples) if samples else None,
            'ui_callback_p99_ms_not_presentation': sorted(samples)[int(.99 * (len(samples) - 1))] if samples else None,
            'sampled_costs': ranking}
    if args.verify:
        assert item['complete'] and samples and len(item['census']) == 2 and len(item['camera']) == 1, label
        assert item['camera'][0].endswith('fits=1'), (label, 'camera position')
    result['cases'][label] = item
target = folder / 'attribution.json'
if args.verify:
    assert len(result['cases']) == 4
    blocks = re.split(r'(?=^Map MAP03:)', (folder / 'benchmarks.txt').read_text(encoding='utf-8'), flags=re.M)
    blocks = [block for block in blocks if block.strip()]
    assert len(blocks) == 4 and all(re.search(r'^\d+ fps$', block, re.M) for block in blocks), 'native benchmark snapshots'
    result['verification_passed'] = True
target.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
for label, item in result['cases'].items():
    print(label, json.dumps({k: v for k, v in item.items() if k != 'sampled_costs'}))
    for row in item['sampled_costs'][:12]:
        print(' ', row['method'], 'calls=', round(row['calls_per_sample_tic'], 2), 'own_ms=', round(row['exclusive_ms_per_sample_tic'], 6), 'inclusive_ms=', round(row['inclusive_ms_per_sample_tic'], 6))
