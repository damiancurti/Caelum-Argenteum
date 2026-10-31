"""Match bounded PresentMon QPC events to each real native client's window.

Presentation intervals are distinct from simulation and RenderOverlay callbacks.
This analyzer streams the capture and retains only the selected observation rows.
"""
from pathlib import Path
import argparse
import csv
import hashlib
import json
import math
import statistics

METRICS = ('MsBetweenPresents', 'MsBetweenDisplayChange', 'MsCPUBusy',
           'MsCPUWait', 'MsGPUBusy', 'MsGPUWait', 'MsUntilDisplayed')


def stats(values):
    if not values:
        return None
    values = sorted(values)
    count = len(values)
    return dict(samples=count, mean_ms=statistics.mean(values),
                p95_ms=values[int((count-1)*.95)],
                p99_ms=values[int((count-1)*.99)], max_ms=values[-1])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', type=Path, required=True)
    parser.add_argument('--matrix', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise SystemExit('Choose a fresh output to preserve the earlier evidence.')
    capture = args.capture.resolve(strict=True)
    matrix = args.matrix.resolve(strict=True)
    reports, by_pid, errors = [], {}, []
    metadata_path = capture.with_name('capture.json')
    metadata = json.loads(metadata_path.read_text(encoding='utf-8-sig'))
    if (metadata.get('status') != 'finished' or metadata.get('exit_code') != 0
            or metadata.get('forced_stop') or metadata.get('lost_events', 0)
            or metadata.get('lost_buffers', 0)
            or metadata.get('time_format', 'qpc') != 'qpc'):
        errors.append('Capture did not finish with loss-free QPC presentation data.')
    for entry in json.loads(matrix.read_text(encoding='utf-8')):
        if entry['exit_code'] or not entry['directory']:
            errors.append('Incomplete native scenario: '+entry['label'])
            continue
        native_path = Path(entry['directory'])/'results.json'
        native = json.loads(native_path.read_text(encoding='utf-8'))
        for peer in native['peers']:
            # Python perf_counter and --qpc_time_ms use the same Windows QPC.
            # Exclude two opening seconds and the final half-second around the
            # host log polls; these are observation windows, not exact tic clocks.
            lower = peer['window']['BEGIN']['qpc_ms']+2000
            upper = peer['window']['END']['qpc_ms']-500
            row = dict(scenario=entry['label'], slot=peer['slot'], pid=peer['pid'],
                       native_directory=str(native_path.parent),
                       runtime_sha256=native['runtime_sha256'],
                       native_passed=native['passed'],
                       window_qpc_ms=[lower, upper], frame_rows=0,
                       values={name: [] for name in METRICS},
                       modes=set(), runtimes=set(), swapchains=set())
            if not native['passed'] or upper <= lower:
                errors.append('Invalid native window: '+entry['label'])
            reports.append(row)
            by_pid.setdefault(peer['pid'], []).append(row)
    with capture.open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        required = {'ProcessID', 'CPUStartQPCTimeInMs', 'MsBetweenPresents'}
        if not required.issubset(reader.fieldnames or []):
            raise SystemExit('Capture lacks the required QPC/presentation columns.')
        for event in reader:
            try:
                pid = int(event['ProcessID'])
                stamp = float(event['CPUStartQPCTimeInMs'])
            except (ValueError, TypeError):
                continue
            for row in by_pid.get(pid, []):
                if not row['window_qpc_ms'][0] < stamp < row['window_qpc_ms'][1]:
                    continue
                row['frame_rows'] += 1
                for name in METRICS:
                    value = event.get(name, '')
                    if value in ('NA', ''):
                        continue
                    number = float(value)
                    if math.isfinite(number):
                        row['values'][name].append(number)
                row['modes'].add(event.get('PresentMode', ''))
                row['runtimes'].add(event.get('PresentRuntime', ''))
                row['swapchains'].add(event.get('SwapChainAddress', ''))
    for row in reports:
        row['metrics'] = {name: stats(values) for name, values in row.pop('values').items()}
        intervals = row['metrics']['MsBetweenPresents']
        displayed = row['metrics']['MsBetweenDisplayChange']
        row['application_present_fps'] = (1000/intervals['mean_ms']
            if intervals and intervals['mean_ms'] > 0 else None)
        row['display_change_coverage'] = (displayed['samples']/row['frame_rows']
            if displayed and row['frame_rows'] else 0)
        for key in ('modes', 'runtimes', 'swapchains'):
            row[key] = sorted(row[key])
        if not intervals:
            errors.append(f"Missing presents: {row['scenario']} peer {row['slot']}")
        if len(row['swapchains']) > 1:
            errors.append(f"Multiple swapchains require separate review: {row['scenario']} peer {row['slot']}")
    report = dict(issue=435, capture=str(capture),
                  capture_metadata=metadata,
                  capture_sha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                  matrix=str(matrix), matrix_sha256=hashlib.sha256(matrix.read_bytes()).hexdigest(),
                  presentation_measured=bool(reports) and not errors,
                  performance_accepted=False, author_accepted=False,
                  errors=errors, peers=reports,
                  qualifications=[
                      'Real native peers share one Windows machine and GPU; this is not separate-computer or Internet-latency evidence.',
                      'QPC windows come from native log observation, cropped by two opening seconds and half a closing second.',
                      'Application-present intervals, physical display changes and simulation time are different measurements.',
                      'Driver-reported Other/GDI presentation does not establish Vulkan scene GPU execution time or monitor-refresh coverage.',
                      'A one-player comparison is a control, not network validation; prior native crashes remain unresolved.'])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(dict(errors=errors, peers=[dict(scenario=row['scenario'],
          slot=row['slot'], frames=row['frame_rows'], fps=row['application_present_fps'],
          intervals=row['metrics']['MsBetweenPresents'],
          display_coverage=row['display_change_coverage']) for row in reports]), indent=2))
    raise SystemExit(bool(errors) or not reports)


if __name__ == '__main__':
    main()
