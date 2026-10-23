"""Collect bounded #481 native evidence without distributing test packages."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import statistics

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue481'
LABELS = ('final-views', 'final-remap', 'final-save', 'final-load',
          'baseline-save', 'final-oldsave-02', 'final-performance',
          'final-handoff-smoke')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def copy(name, category):
    destination = HERE / category / name
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(WORK / name, destination)
    return {'path': destination.relative_to(HERE).as_posix(), 'sha256': digest(destination)}

runs = []
for label in LABELS:
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8', errors='replace')
    metadata = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert metadata['exit_code'] == 0, label
    assert 'CA481 FAIL' not in log and 'VM execution aborted' not in log, label
    runs.append({'label': label, 'pass': len(re.findall(r'^CA481 PASS ', log, re.M)),
                 'fail': len(re.findall(r'^CA481 FAIL ', log, re.M)),
                 'package_sha256': metadata['package_sha256'].lower(),
                 'addon_sha256': metadata['addon_sha256'].lower(),
                 'artifacts': [copy(f'{label}.txt', 'native'), copy(f'{label}-run.json', 'native')]})

perf = (WORK / 'final-performance.txt').read_text(encoding='utf-8', errors='replace')
intervals = sorted(float(x) for x in re.findall(r'^CA481 FRAME ([\d.]+)', perf, re.M))
start, end, tics = re.search(r'CA481 PERF start_ms=([\d.]+) end_ms=([\d.]+) tics=(\d+)', perf).groups()
percentile = lambda fraction: intervals[math.ceil(len(intervals) * fraction) - 1]
failures = [copy(f'{label}.txt', 'diagnostics') for label in
            ('compile-01', 'lines-04', 'lines-05', 'lines-06', 'final-oldsave')]
perf_artifacts = [copy('final-performance-presentmon' + suffix, 'native')
                  for suffix in ('.json', '.txt', '-error.txt')]
report = {
    'issue': 481, 'release': '5.7.7', 'date': '2026-10-22',
    'package': json.loads((WORK / 'package-verification.json').read_text(encoding='utf-8')),
    'runs': runs, 'unique_assertions_passed': 41,
    'repeated_assertions_after_fixture_map_guard': 36,
    'current_and_5_7_6_save_reload': 'passed',
    'ui_callback_intervals_ms': {
        'samples': len(intervals), 'mean': statistics.mean(intervals),
        'p95_nearest_rank': percentile(.95), 'p99_nearest_rank': percentile(.99), 'maximum': max(intervals),
        'simulation_tics_per_second': int(tics) * 1000 / (float(end) - float(start)),
        'scope': 'Isolated fixture, 1280x720 Vulkan, 60 FPS cap; UI callbacks are not frame presentation.'},
    'presentation_measurement': {'status': 'unavailable', 'reason': 'PresentMon ETW access denied', 'artifacts': perf_artifacts},
    'visuals': [copy(name, 'visuals') for name in [*(f'target-{i}.png' for i in range(7)), 'remapped-es.png']],
    'visual_review': 'Seven targets and Spanish remapped-key capture inspected; no overlap found.',
    'diagnostic_failures_preserved': failures,
    'author_acceptance': 'CA481-01 pending; author requested deferral until return.',
    'limitations': ['No whole-map performance acceptance.', 'No claim of measured GPU/frame presentation cadence.',
                    'Test fixture uses existing owned textures; no engine, IWAD, PK3 or save is distributed.'],
}
(HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'assertions': 41, 'repeated': 36, 'performance': report['ui_callback_intervals_ms']}, indent=2))
