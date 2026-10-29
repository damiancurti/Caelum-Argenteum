"""Archive the measured #415 catch-up revision without changing prior evidence."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HOME = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue415-rounds'
RUNS = [
    'spatial-area01', 'spatial-perf01', 'quiet-guards01',
    'quiet-span-sync01', 'quiet-span-staged01', 'quiet-present-before',
    'quiet-pipeline01', 'pipeline-firsthour01', 'pipeline-firstday01',
    'shared-weather01', 'weather-firstday01',
]
RUNS += ['quiet-regression01-' + name for name in (
    'math', 'rounds', 'physiology', 'area', 'spatial', 'flights', 'flightload',
    'flighttravel', 'calendarhub', 'workload', 'arrivalload', 'firstvisit',
    'quietsave', 'quietload')]
RUNS += ['weather-final01-' + name for name in ('quiet', 'quietsave', 'quietload', 'arrivalload')]


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def metrics(values):
    if not values:
        return None
    ordered = sorted(values)
    return {'n': len(values), 'mean_ms': sum(values) / len(values),
            'p95_ms': ordered[math.ceil(len(values) * .95) - 1],
            'p99_ms': ordered[math.ceil(len(values) * .99) - 1], 'max_ms': max(values)}


report = {'issue': 415, 'status': 'Unreleased catch-up improvement; issue remains incomplete',
          'runs': {}, 'presentation': {
              'status': 'Unavailable: Windows denied the unelevated PresentMon ETW session',
              'qualification': 'Renderer callbacks below are not displayed FPS or presentation intervals'}}
destination = HOME / 'native'
destination.mkdir(exist_ok=True)
for label in RUNS:
    record = read(WORK / (label + '-run.json'))
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
    assert not record.get('timed_out'), label
    assert not re.search(r'CA\w* FAIL|Script error|VM execution aborted', log), label
    assert ' RESULT ' in log, label
    report['runs'][label] = {
        'runtime_sha256': record['package_sha256'], 'addon_sha256': record['addon_sha256'],
        'timing': re.findall(r'^CA415P TIMING (.*)$', log, re.M),
        'outcomes': dict(re.findall(r'^CA415P OUTCOME (\w+) (.*)$', log, re.M)),
        'render_callback_intervals': metrics([float(v) for v in re.findall(r'^CA415P FRAME ([\d.]+)', log, re.M)]),
        'pulse_execution': metrics([float(v) for v in re.findall(r'^CA415P PULSE ([\d.]+)', log, re.M)]),
        'city_result': re.findall(r'^CA415C ARRIVAL (.*)$', log, re.M),
        'arrival_result': re.findall(r'^CA415A DETAIL (.*)$', log, re.M),
    }
    for suffix in ('.txt', '-run.json'):
        source = WORK / (label + suffix)
        target = destination / source.name
        if target.exists():
            assert target.read_bytes() == source.read_bytes(), target
        else:
            shutil.copyfile(source, target)

reference = read(HOME / 'arrival-performance.json')['runs']['arrival-perf-sync01']['outcomes']
report['exact_recorded_diagnostic_outcomes'] = all(
    report['runs'][name]['outcomes'] == reference for name in (
        'quiet-span-sync01', 'quiet-span-staged01', 'quiet-pipeline01'))
assert report['exact_recorded_diagnostic_outcomes']
report['area_comparison'] = re.findall(r'^CA415P AREA (.*)$', (WORK / 'spatial-perf01.txt').read_text(), re.M)
report['city_comparison_qualification'] = (
    'One-day original/cached-weather runs retain identical round, row, living-body, victory and reserve totals. '
    'Independent native weather checks verify the sample values; no unrecorded per-body final-value comparison is claimed.')
report['limits'] = [
    'Combat remains in one-world-second simultaneous rounds; quiet physiological work uses its existing one-active-second boundary.',
    'Native one-day city arrival still takes over two minutes including startup; further long-absence work remains.',
    'These are isolated agent checks, not author acceptance or presentation-FPS validation.',
]
for suffix in ('-monitor.json', '-out.txt', '-err.txt'):
    source = WORK / ('quiet-present-before' + suffix)
    target = destination / source.name
    if target.exists():
        assert target.read_bytes() == source.read_bytes(), target
    else:
        shutil.copyfile(source, target)

package = WORK / 'probe/caelum_argenteum_dev.pk3'
changed = subprocess.check_output(['git', 'diff', '8aab788d', '--name-only', '--', 'src'], cwd=ROOT, text=True).splitlines()
with zipfile.ZipFile(package) as archive:
    for name in changed:
        assert archive.read(name[4:]) == (ROOT / name).read_bytes(), name
report['source_members_verified'] = len(changed)
report['runtime_sha256'] = hashlib.sha256(package.read_bytes()).hexdigest()
(HOME / 'catchup-performance.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(f'Archived {len(RUNS)} runs; {len(changed)} source members match; recorded diagnostic outcomes agree.')
