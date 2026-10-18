"""Validate and summarize one-at-a-time costs, never infer presented FPS."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import statistics as st

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('directory')
parser.add_argument('--prefix', default='matrix')
args = parser.parse_args()
folder = ROOT / 'build' / args.directory
manifest = json.loads((folder / 'manifest.json').read_text())
order = json.loads((folder / (args.prefix + '-order.json')).read_text())
plan = json.loads((folder / (args.prefix + '-plan.json')).read_text())
assert hashlib.sha256((folder / 'solo-seed.zds').read_bytes()).hexdigest() == plan['seed_sha256']
assert all(row['seed_sha256'] == plan['seed_sha256'] for row in order)
assert len(order) == 66, 'Final matrix requires three repeats, two sites, nine modes and two controls per block.'
assert len({row['label'] for row in order}) == 66
for site in (0,1):
    for repeat in range(3):
        block = [row['mode'] for row in order if row['site']==site and row['repeat']==repeat]
        assert sorted(block) == [-1,-1,0,1,2,3,4,5,6,7,8], (site,repeat,'incomplete block')
seed_run = json.loads((folder / 'seed01-run.json').read_text(encoding='utf-8-sig'))
for file, key in [('production.pk3','runtime_sha256'),('quick.pk3','fixture_sha256')]:
    assert hashlib.sha256((folder / file).read_bytes()).hexdigest() == manifest[key]
cases = []
for entry in order:
    label = entry['label']
    log = (folder / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
    run = json.loads((folder / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    ini = (folder / (label + '.ini')).read_text(encoding='utf-8-sig')
    expected_settings = {'vid_vsync':'false','vid_maxfps':'0','cl_capfps':'false',
                         'i_pauseinbackground':'false','vid_activeinbackground':'true',
                         'vid_lowerinbackground':'false','snd_mastervolume':'0.05',
                         'vid_defwidth':'1280','vid_defheight':'720','vid_preferbackend':'1'}
    for key,value in expected_settings.items():
        assert re.findall(r'^'+key+r'=(.*)$',ini,re.M) == [value], (label,key)
    assert run['exit_code'] == 0
    assert run['runtime_sha256'].lower() == manifest['runtime_sha256']
    assert run['fixture_sha256'].lower() == manifest['fixture_sha256']
    assert run['engine_sha256'] == seed_run['engine_sha256']
    assert log.count('SOLO BEGIN ') == log.count('SOLO END ') == 1
    assert 'CA282 DONE passes=3 failures=0' in log
    assert 'SOLO SIDE_EFFECTS external=0 health_losses=0' in log
    assert not re.search(r'CA282 FAIL|Script error|VM execution aborted|JIT error|SOLO SPAWN', log)
    loaded = re.search(r'SOLO LOADED actors=(\d+) poses=(\d+) soldiers=(\d+) demons=(\d+) removed=(\d+)', log)
    assert loaded and loaded.groups() == ('8910','8910','600','998','0'), (label,'loaded cohort')
    inv = re.search(r'SOLO INVARIANTS actors=(\d+) expected=(\d+) changed=(\d+) missing=(\d+) frozen=(\d+) spawns=(\d+)', log)
    assert inv and inv[1] == inv[2] and inv.groups()[2:] == ('0','0','1','0'), (label, 'invariants')
    begin = re.search(r'SOLO BEGIN mode=(-?\d+) tic=(\d+) ms=([\d.]+) window=(\d+) site=(\d+)', log)
    end = re.search(r'SOLO END mode=(-?\d+) tic=(\d+) ms=([\d.]+) samples=(\d+)', log)
    assert int(begin[1]) == entry['mode'] and int(begin[5]) == entry['site']
    rows = re.findall(r'SOLO SAMPLE tic=(\d+) ms=([\d.]+) batch=([\d.]+) restore=([\d.]+)', log)
    assert len(rows) == int(begin[4]) == int(end[4])
    assert [int(r[0]) for r in rows] == list(range(int(begin[2]), int(begin[2]) + len(rows)))
    counts = [tuple(map(int, row)) for row in re.findall(r'SOLO COUNTS key=(\d+) requested=(\d+) executed=(\d+) captured=(\d+)', log)]
    assert len(counts) == 9
    for key, requested, executed, captured in counts:
        if key == entry['mode']:
            assert requested == executed == captured * len(rows) // 35 and captured > 0
        else:
            assert requested == executed == 0
    bench = (folder / (label + '-bench.txt')).read_text(encoding='utf-8', errors='replace')
    fps = re.findall(r'^(\d+) fps$', bench, re.M)
    assert len(fps) == 1
    camera = re.search(r'x = ([\d.-]+), y = ([\d.-]+), z = ([\d.-]+), angle = ([\d.-]+), pitch = ([\d.-]+)', bench)
    assert camera, (label,'native camera')
    xyzap = tuple(map(float,camera.groups()))
    assert xyzap == ((0.,320.,41.,-180.,0.) if entry['site']==0 else (-14464.,-14000.,41.,-90.,0.)), (label,xyzap)
    assert log.index('SOLO BEGIN ') < log.index('Benchmark info saved') < log.index('SOLO END ')
    batch = [float(row[2]) for row in rows]
    restore = [float(row[3]) for row in rows]
    duration = float(end[3]) - float(begin[3])
    cases.append(dict(entry, actors=int(inv[1]), samples=len(rows),
                      start_tic=int(begin[2]),
                      native_camera=xyzap,
                      final_settings=expected_settings,
                      batch_mean_ms=st.mean(batch), batch_p95_ms=sorted(batch)[int(.95*(len(batch)-1))],
                      restore_mean_ms=st.mean(restore), simulation_tics_per_second=(len(rows)-1)*1000/(float(rows[-1][1])-float(rows[0][1])),
                      window_wall_ms=duration, native_bench_fps_snapshot=int(fps[0]), counts=counts,
                      pid=run['pid'], engine_sha256=run['engine_sha256']))
assert len({case['actors'] for case in cases}) == 1, 'Population drift between runs.'
assert len({case['start_tic'] for case in cases}) == 1, 'Replay clock phase differs between runs.'
assert len({tuple(row[3] for row in case['counts']) for case in cases}) == 1, 'Recorded workload differs.'
summary = []
for site in sorted({case['site'] for case in cases}):
    for mode in range(-1, 9):
        selected = [case for case in cases if case['site'] == site and case['mode'] == mode]
        if not selected:
            continue
        deltas = []
        for case in selected:
            baseline = [control['batch_mean_ms'] for control in cases if control['site'] == site and control['repeat'] == case['repeat'] and control['mode'] == -1]
            if baseline:
                deltas.append(case['batch_mean_ms'] - st.mean(baseline))
        summary.append({'site':site, 'mode':mode, 'runs':len(selected),
                        'batch_mean_ms':st.mean(c['batch_mean_ms'] for c in selected),
                        'delta_mean_ms':st.mean(deltas) if deltas else None,
                        'delta_range_ms':[min(deltas),max(deltas)] if deltas else None,
                        'fps_snapshot_median':st.median(c['native_bench_fps_snapshot'] for c in selected),
                        'fps_snapshot_range':[min(c['native_bench_fps_snapshot'] for c in selected),max(c['native_bench_fps_snapshot'] for c in selected)],
                        'restore_mean_ms':st.mean(c['restore_mean_ms'] for c in selected)})
result = {'verification_passed':True, 'runtime_sha256':manifest['runtime_sha256'],
          'baseline_definition':'Nine named families disabled; common trace traversal, cloning, renderer and engine remain.',
          'delta_definition':'Instrumented isolated core against bracketing all-off controls; not pure production method time or additive normal-combat savings.',
          'presented_frames':'Unavailable unless separately collected through PresentMon.',
          'cases':cases,'summary':summary}
(folder / (args.prefix + '-results.json')).write_text(json.dumps(result,indent=2) + '\n')
for row in summary:
    print(json.dumps(row))
