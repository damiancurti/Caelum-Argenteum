"""Join native tic clocks with PresentMon 2.6.0 display events; retain raw evidence.

Vulkan's Other provider reports zero Present API time. In the default hybrid CSV,
TimeInSeconds actually contains relative milliseconds with --qpc_time_ms.
CPUStartQPCTimeInMs + MsCPUBusy is the absolute current present start.
MsUntilDisplayed adds display latency; MsBetweenDisplayChange is backward-looking.
See the pinned upstream source URLs in RESULTS.md. Never infer FPS from callbacks.
"""
from pathlib import Path
import bisect
import csv
import gzip
import hashlib
import json
import math
import re
import statistics as st

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue132'
LABELS = ['staged-natural-a', 'baseline-natural-a', 'baseline-natural-b',
          'cap-natural-a', 'cap-natural-b', 'staged-long-a', 'baseline-long-a', 'staged-long-b',
          'focus-full-a', 'focus-cap-a']
PHASES = [('arrival', 35, 3500), ('buildup', 3500, 6650),
          ('sustained', 6650, 14000), ('budget', 14000, 20650),
          ('late', 20650, 22750), ('decline', 22750, 24850)]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def quantile(values, p):
    values = sorted(values)
    return values[max(0, math.ceil(len(values)*p)-1)] if values else None


def distribution(values):
    return ({'n': len(values), 'median_ms': st.median(values),
             'p95_ms': quantile(values, .95), 'p99_ms': quantile(values, .99),
             'worst_ms': max(values), 'mean_fps': 1000*len(values)/sum(values),
             'median_fps': 1000/st.median(values),
             'intervals_over_33_333ms_pct': 100*sum(v > 1000/30 for v in values)/len(values)}
            if values else {'n': 0})


def records(raw, name):
    return [{k: float(v) for k, v in re.findall(r'(\w+)=(-?[\d.]+)', line)}
            for line in raw.splitlines() if line.startswith('CA132 '+name+' ')]


def analyse(label):
    path = HERE/(label+'.txt')
    if not path.exists():
        return None
    raw = path.read_text(encoding='utf-8-sig')
    run = json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    sims, frames = records(raw, 'SIM'), records(raw, 'FRAME')
    out = {'label': label, 'package_sha256': run['package_sha256'],
           'addon_sha256': run['addon_sha256'], 'log_sha256': sha(path.read_bytes()),
           'completed': 'CA132 PERFORMANCE COMPLETE' in raw, 'phases': {}, 'views': {},
           'settings': next((l for l in raw.splitlines() if l.startswith('CA132 SETTINGS')), None),
           'last': sims[-1], 'max_alive': max(s['alive'] for s in sims),
           'max_corpses': max(s['corpses'] for s in sims),
           'max_pending': max(s['pending'] for s in sims)}
    # Intersect one-second SystemTime.Now() bounds, rather than assuming launch
    # time equals engine MSTimeF origin. This also exposes clock discontinuities.
    # The two engine clock calls are not atomic; allow 5 ms call/clock jitter.
    lower = max(f['epoch']*1000-f['ms'] for f in frames)-5
    upper = min((f['epoch']+1)*1000-f['ms'] for f in frames)+5
    assert lower <= upper, (label, 'Wall clock changed during the capture', lower, upper)
    offset = (lower+upper)/2
    out['clock_alignment_uncertainty_ms'] = (upper-lower)/2
    tic_list = [s['tic'] for s in sims]

    def at(tic):
        i = bisect.bisect_left(tic_list, tic)
        if i == 0:
            return sims[0]['ms']
        if i == len(sims):
            return sims[-1]['ms']
        left, right = sims[i-1:i+1]
        return left['ms']+(right['ms']-left['ms'])*(tic-left['tic'])/(right['tic']-left['tic'])

    csv_path = WORK/(label+'-present.csv')
    displayed, presentation_rows, gpu_busy = [], [], []
    if csv_path.exists() and csv_path.stat().st_size:
        data = csv_path.read_bytes()
        with csv_path.open(encoding='utf-8-sig', newline='') as stream:
            rows = list(csv.DictReader(stream))
        assert all(int(r['ProcessID']) == run['pid'] for r in rows)
        assert all(float(r['MsInPresentAPI']) == 0 for r in rows), 'Review Present API origin'
        valid_clock_rows = [r for r in rows if float(r['MsCPUBusy']) > 0]
        origins = [float(r['CPUStartQPCTimeInMs'])+float(r['MsCPUBusy'])-float(r['TimeInSeconds'])
                   for r in valid_clock_rows]
        assert max(origins)-min(origins) < .01, (label, 'Inconsistent absolute present clock')
        origin = st.median(origins)
        for r in rows:
            # A zero CPU/previous-present row can lack a usable CPU-start metric.
            # Its relative present timestamp still uses the verified trace origin.
            present = origin+float(r['TimeInSeconds'])
            present_ms = present-run['qpc_ms']+run['epoch_ms']-offset
            presentation_rows.append(present_ms)
            if r['MsGPUBusy'] != 'NA':
                gpu_busy.append((present_ms, float(r['MsGPUBusy'])))
            if r['MsBetweenDisplayChange'] == 'NA' or r['MsUntilDisplayed'] == 'NA':
                continue
            gap = float(r['MsBetweenDisplayChange'])
            if gap > 0:
                displayed.append((present_ms+float(r['MsUntilDisplayed']), gap))
        # Check that display intervals agree with the independently reconstructed
        # screen clock; skip the first event whose predecessor is outside CSV.
        residual = max(abs(b[0]-a[0]-b[1]) for a, b in zip(displayed, displayed[1:]))
        assert residual < .02, (label, 'Display sequence discontinuity', residual)
        out['presentmon'] = {'raw_sha256': sha(data), 'rows': len(rows),
                            'zero_cpu_clock_rows': len(rows)-len(valid_clock_rows),
                            'displayed_intervals': len(displayed), 'display_clock_max_residual_ms': residual,
                            'first_native_ms': displayed[0][0], 'last_native_ms': displayed[-1][0],
                            'presentation_modes': sorted(set(r['PresentMode'] for r in rows))}
        (HERE/(label+'-present.csv.gz')).write_bytes(gzip.compress(data, mtime=0))
        for suffix in ['.capture-started.json', '.capture-done.json']:
            p = WORK/(label+suffix)
            if p.exists():
                (HERE/p.name).write_bytes(p.read_bytes())

    def summarize(start, end):
        end = min(end, sims[-1]['tic'])
        if start >= end:
            return None
        selected = [s for s in sims if start <= s['tic'] <= end]
        begin_ms, end_ms = at(start), at(end)
        gaps = [gap for when, gap in displayed if when-gap >= begin_ms and when <= end_ms]
        callbacks = [f['interval'] for f in frames if start < f['tic'] <= end]
        busy = [value for when, value in gpu_busy if begin_ms <= when <= end_ms]
        sec_tps = [(b['tic']-a['tic'])*1000/(b['ms']-a['ms']) for a, b in zip(selected, selected[1:])]
        return {'start_tic': start, 'end_tic': end, 'wall_seconds': (end_ms-begin_ms)/1000,
                'tics_per_second': (end-start)*1000/(end_ms-begin_ms),
                'one_second_tps_p05': quantile(sec_tps, .05),
                'alive_range': [min(s['alive'] for s in selected), max(s['alive'] for s in selected)],
                'corpses_range': [min(s['corpses'] for s in selected), max(s['corpses'] for s in selected)],
                'projectiles_range': [min(s['projectiles'] for s in selected), max(s['projectiles'] for s in selected)],
                'combatants_range': [min(s['combatants'] for s in selected), max(s['combatants'] for s in selected)],
                'display': distribution(gaps), 'display_covered_wall_pct': 100*sum(gaps)/(end_ms-begin_ms),
                'presentmon_gpu_busy': {'n':len(busy), 'median_ms':st.median(busy) if busy else None,
                                        'p95_ms':quantile(busy, .95)},
                'render_callback_only': distribution(callbacks)}

    out['whole'] = summarize(35, sims[-1]['tic'])
    if label.startswith('focus-'):
        out['foreground_settled'] = summarize(700, 1050)
    for name, start, end in PHASES:
        if start < sims[-1]['tic']:
            out['phases'][name] = summarize(start, end)
    for i in range(math.ceil(sims[-1]['tic']/1750)):
        start, end = max(35, i*1750), min((i+1)*1750, sims[-1]['tic'])
        if start < end:
            out['views'][str(i)] = {'view': i%4, **summarize(start, end)}
    # The observer runs before the controller. A changed cumulative count at
    # 385 means creation happened at 350. Exclude screenshots/bench/save points
    # and camera changes from these isolated spawn windows.
    command_tics = ({350, 1750, 3500} if 'natural' in label else
                    {350, 3500, 6650, 7000, 14000, 20650, 22050, 24150, 24850})
    windows = []
    for a, b in zip(sims, sims[1:]):
        if b['total'] <= a['total']:
            continue
        tic = b['tic']-35
        if tic in command_tics or tic%1750 == 0:
            continue
        if tic-35 >= 35 and tic+35 <= sims[-1]['tic']:
            windows.append(summarize(tic-35, tic+35))
    out['spawn_windows'] = windows
    out['native_thinkers'] = [l.strip() for l in raw.splitlines()
                              if re.match(r'\s*[\d.]+\s+[\d.]+\s+\d+\s+Caelum(Mandinga|Conquistador|Cannon|PortSiege|SiegeReinforcements)', l)]
    return out


result = {'method': __doc__, 'runs': {}}
for label in LABELS:
    report = analyse(label)
    if report:
        result['runs'][label] = report
        d = report['whole']['display']
        print(label, 'TPS', round(report['whole']['tics_per_second'], 2),
              'FPS', round(d.get('mean_fps', 0), 2), 'display p95', round(d.get('p95_ms', 0), 2))
(HERE/'PERFORMANCE.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
