"""Report the matched house geometry experiment and preserve its qualifications."""
from pathlib import Path
import argparse
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def fmt(value):
    return '-' if value is None else f'{value:.2f}'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', default='issue318-houses-perf-03')
    args = parser.parse_args()
    folder = ROOT/'build'/args.directory
    all_rows = json.loads((folder/'analysis.json').read_text())
    excluded = [row for row in all_rows if row['label'].startswith('interior-')]
    rows = [row for row in all_rows if row not in excluded]
    expected = set()
    for repeat, shape in enumerate(('houses', 'opaque', 'opaque', 'houses'), 1):
        for pitch in (0, 75):expected.add((f'{shape}-6000', f'peace-{pitch}-{repeat}'))
        for site in (0, 4):expected.add((f'{shape}-1000', f'siege1000-{site}-{repeat}'))
        expected.add((f'{shape}-6000', f'siege6000-{repeat}'))
        expected.add((f'{shape}-6000', f'house-interior-{repeat}'))
    for shape in ('houses', 'opaque'):
        expected.add((f'{shape}-1000-profile', 'profile-siege1000'))
        expected.add((f'{shape}-6000-profile', 'profile-siege6000'))
    observed = {(row['variant'], row['label']) for row in rows}
    assert observed == expected, ('Condition mismatch',
                                  sorted(expected-observed), sorted(observed-expected))
    assert len(rows) == len(expected), 'Duplicate performance records'
    verification = {'directory': args.directory, 'runs': [], 'functional': []}
    verification['excluded_wrong_map_runs'] = [
        {'variant': row['variant'], 'label': row['label'],
         'reason': 'Startup changemap was issued before the initial MAP06 load completed; these are city measurements, not an interior.'}
        for row in excluded]
    verification['functional_reuse'] = {
        '07_to_08': 'Only the MAP06 cartography checksum data changes.',
        '08_to_09': 'Only six sign PNGs and their new license change.',
        'scope': 'Resident/door/cannon gameplay code is unchanged between these functional batteries; final-source byte comparison is recorded separately.'}
    for directory, expected in (('issue318-houses-07', 7), ('issue318-houses-08', 5),
                                ('issue318-houses-09', 1)):
        records = sorted((ROOT/'build'/directory/'current').glob('*-run.json'))
        assert len(records) == expected, (directory, len(records))
        for record in records:
            data = json.loads(record.read_text())
            log = record.with_name(data['options']['label']+'.txt').read_text(encoding='utf-8')
            assert data['exit_code'] == 0 and 'CA318 FAIL' not in log
            assert 'CA318 DONE failures=0' in log
            verification['functional'].append({'directory': directory,
                'label': data['options']['label'],
                'assertions': len(re.findall(r'^CA318 PASS', log, re.M)),
                'runtime_sha256': data['runtime_sha256']})
    for row in rows:
        assert row['completed'] and row.get('measurement_window_complete'), (
            'Incomplete measurement', row['variant'], row['label'])
        cameras = row.get('camera', [])
        valid = any('CAMERA_WINDOW' in line and 'fits=1' in line for line in cameras)
        if row['completed']:
            assert valid, (row['label'], cameras)
            assert row.get('presentmon', {}).get('sample_count', 0) > 0, row['label']
            assert len(row['census']) == 3, row['label']
            window = next(line for line in row['census'] if 'CENSUS window ' in line)
            soldiers = int(re.search(r'soldiers=(\d+)', window)[1])
            demons = int(re.search(r'demons=(\d+)', window)[1])
            expected_living = (3, 0) if row['label'].startswith('house-interior-') else (
                (600, 6000 if '-6000' in row['variant'] else 1000) if row['options']['phase'] else (0, 0))
            assert (soldiers, demons) == expected_living, (row['label'], window)
            if row['label'].startswith('house-interior-'):
                bench = (folder/row['variant']/(row['label']+'-bench.txt')).read_text(encoding='utf-8')
                assert 'Map CAH158:' in bench, row['label']
                assert all('soldiers=3 ' in line for line in row['census']), row['label']
        verification['runs'].append({'label': row['label'], 'variant': row['variant'],
            'completed': row['completed'], 'valid_window_camera': valid,
            'etw_intervals': row.get('presentmon', {}).get('sample_count', 0),
            'census': row.get('census', []), 'camera': cameras})
    verification['comparisons'] = {}
    for prefix in ('peace-0-', 'peace-75-', 'siege1000-0-', 'siege1000-4-',
                   'siege6000-', 'house-interior-'):
        group = {}
        for shape in ('houses', 'opaque'):
            selected = [row for row in rows if row['label'].startswith(prefix)
                        and row['variant'].startswith(shape+'-')]
            assert len(selected) == 2, (prefix, shape, len(selected))
            complete = [row for row in selected if row['completed'] and 'presentmon' in row]
            group[shape] = {'completed_repeats': len(complete)}
            for key, values in (
                ('fps_range', [row['presentmon']['application_present_fps'] for row in complete]),
                ('tics_per_second_range', [row['tics_per_second'] for row in complete]),
                ('p95_frame_ms_range', [row['presentmon']['MsBetweenPresents']['p95'] for row in complete]),
                ('p99_frame_ms_range', [row['presentmon']['MsBetweenPresents']['p99'] for row in complete]),
            ):
                group[shape][key] = [min(values), max(values)] if values else None
        verification['comparisons'][prefix] = group

    lines = ['## Separate house interiors versus full-height house walls', '',
        'Author-requested follow-up, 2026-10-17. Production keeps all 160 original',
        '960-by-1,216-MU house footprints and 184-MU roofs. Front-door Use loads',
        'one private CAH000..CAH159 map, retaining real resident bodies and finite',
        'inventories; defenders emerge at their original doors during the siege.',
        'Shops/factories remain in the city. Six original painted sign designs',
        'identify the 64 shops using their existing merchandise categories.', '',
        '### Comparison at a glance', '',
        'Ranges below contain the two completed per-run means for each condition,',
        'not minimum/maximum instantaneous FPS or confidence intervals. A is the',
        '184-MU shell; B adds full-height opaque house walls. All siege rows retain',
        '600 defenders. The nominal simulation rate is 35 tics/s.', '',
        '| Scene | A app FPS | B app FPS | A tics/s | B tics/s |',
        '| --- | ---: | ---: | ---: | ---: |']
    for prefix, title in (
        ('peace-0-', 'Peaceful city, forward'),
        ('peace-75-', 'Peaceful city, ground'),
        ('siege1000-0-', '1,000 attackers, city centre'),
        ('siege1000-4-', '1,000 attackers, front line'),
        ('siege6000-', '6,000 attackers, city centre'),
        ('house-interior-', 'Private interior CAH158'),
    ):
        comparison = verification['comparisons'][prefix]
        cells = [title]
        for metric in ('fps_range', 'tics_per_second_range'):
            for shape in ('houses', 'opaque'):
                low, high = comparison[shape][metric]
                cells.append(f'{low:.2f}-{high:.2f}')
        lines.append('| '+' | '.join(cells)+' |')
    lines += ['',
        'Real opaque closure strongly improves the two peaceful street views.',
        'The 1,000-attacker central view also improves, but remains below 60 FPS;',
        'its p99 frame intervals are 112-131 ms even with occlusion. The front-line',
        'view does not improve: both native snapshots contain 1,146 wall jobs,',
        'and B records lower FPS in these repeats. This is not a uniform map-wide',
        'gain or proof that the geometry alone caused that smaller regression.', '',
        'The private interior exceeds 1,000 application presents/s with three',
        'residents and 44 actors; this does not represent the entire city or a',
        'large indoor battle. At 6,000 attackers both variants remain near 0.7 FPS',
        'and 12 simulation tics/s. Thirty simulated seconds take about 86-89 real',
        'seconds. Opaque walls do not solve the full-army simulation bottleneck.',
        'Bounded normal attacker deployment and measured actor-work reduction',
        'remain necessary; this test does not choose a new combat budget.', '',
        'Static final-WAD verification confirms all four outer house boundaries,',
        '160 portals/return starts and correct sign categories. MAP06 changes from',
        '1,565 sectors/65,661 lines/2,987 things to 765/42,945/491. Each of the 160',
        'private interiors has five sectors, 194 lines, 16 map things and four',
        'native door leaves. All private WADs regenerate byte-for-byte; sign',
        'generation is byte-identical under the pinned Windows PowerShell 5.1',
        'and .NET Framework rasterizer. Counts do not include runtime-created props.', '',
        'Full exterior MAP06 regeneration also matches byte-for-byte; its result',
        'is recorded in issue318-houses-static-02/EXTERIOR_REGENERATION.json.', '',
        'Native functional checks cover actual Use in houses 0/119/120/158/159,',
        'return position, three/four residents, injury, gear durability, ammunition,',
        'finite inventory, current saves on both sides, fresh birth plus immediate',
        'travel, 600 unique deployments, cannon reassignment, blocked placement and',
        'retry, death, burning, bolas, resurrection memory and active/expired',
        'Redemption. The same real body travels; absent-map combat is suspended.',
        'A due siege starts when returning to the city. These are isolated engine',
        'checks, not author acceptance of the entire campaign or multiplayer.', '',
        'Functional runtime07 differs from08 only in the MAP06 cartography',
        'checksum; runtime08 differs from09 only in six regenerated sign PNGs',
        'and their license. Resident/door/cannon gameplay code is unchanged.', '',
        'With 600 instantiated residents, the native compressed save grows from',
        '331,899 bytes before visiting ten houses to 2,063,831 bytes afterward.',
        'All 600 identities remain unique/alive. This is a measured hub-storage',
        'cost; no linear extrapolation, memory-leak diagnosis or whole-campaign',
        'memory/transition-latency guarantee follows from it.', '',
        '### Matched performance conditions', '',
        'A (`houses`) is the production house-shell prototype. B (`opaque`) keeps',
        'the same private interiors, XY footprints, lines, vertices and map things,',
        'but extends house walls to the existing 1,024-MU sky ceiling.',
        'The original 184-MU sector is shared with unrelated structures, so B',
        'adds one sector and reassigns only 10,880 house sides. It does not raise',
        'the shared original sector. Its closed ceiling uses the existing opaque',
        'roof material: leaving F_SKY1 on both sides invokes hw_CheckClip\'s sky',
        'exception and does not block background BSP traversal. Wall materials',
        'remain unchanged. The paired packages differ only in MAP06 and',
        'its cartography checksum. B remains diagnostic, with changed sight,',
        'projectile/flight paths and thermal geometry; it is not a renderer-only',
        'toggle. No tall walls or reduced army budget are adopted in production.', '',
        'GZDoom 4.14.2, Vulkan 1280x720, Ryzen 9 5950X/RTX 3070 Ti, seed116,',
        'skill2, uncapped presentation, unpaused background simulation/rendering',
        'and 5% audio. Each run uses a fresh isolated process/configuration.',
        'No concurrent engine or package build runs during measurement.',
        'The ordinary inventory, sprite art, RPG bodies, collisions and resources',
        'remain enabled. The 1,000-Mandinga control changes only the diagnostic',
        'attacker count; 600 defenders and the commander remain.', '',
        'Peaceful views use site0 `(0,320,0)`, yaw180, pitch0/75: 140 warmup and',
        '350 observation tics. Siege windows start after 700 warmup tics and run',
        '1,050 tics (30 simulated seconds); 1,000 attackers use sites0 and4',
        '(`-14464,-14000,0`, yaw270), while 6,000 use site0. Each condition runs',
        'A-B-B-A. Interior benchmarks load CAH158 through native changemap and',
        'retain its native start; actual door Use is covered by functional checks.',
        'Separate instrumented 1,000- and 6,000-attacker profiles sample every17 tics during',
        'a 350-tic window; their FPS is not mixed with the uninstrumented repeats.', '',
        'The earlier `issue318-houses-perf-01` site1 camera was on a newly solid',
        'house boundary and failed native placement. Its data is retained as an',
        'invalid-camera diagnostic, excluded from this comparison. Directory02',
        'has legal cameras but retains sky ceilings in the tall closed sectors;',
        'it is an ineffective-occluder control, not the requested final B.',
        'Directory03 corrects that ceiling material and repeats the full comparison.',
        'The final observer',
        'checks `TestMobjLocation` at the measurement boundary and records camera',
        'coordinates/populations. Matching camera and initial populations does',
        'not establish identical combat trajectories under different geometry.', '',
        'Early directory03 `interior-*` labels remained in MAP06 because changemap',
        'was requested before the first level finished loading. They are excluded',
        'from the interior results. Corrected `house-interior-*` commands first',
        'wait for MAP06, then change level; native bench must identify CAH158 and',
        'every census must contain its three residents.', '',
        'ETW measures application presents, not display refresh. Host marker',
        'detection polls at 200 ms and trims 300 ms at the start/500 ms at the end;',
        'no exact per-tic correlation is claimed. Tails are empirical capture',
        'percentiles; fewer than30 intervals do not support a tail report.',
        'Renderer `bench` snapshots are separate CPU-side diagnostics, not GPU',
        'timings or a complete additive breakdown. Its native five-second delay',
        'requires at least210 postwait tics. The earlier directory02 peace/1,000',
        'runs used35 and did not produce a bench file; final directory03 uses210',
        'and records these snapshots after each measurement window.', '']
    groups = [('Peaceful city', 'peace-'), ('1,000 Mandingas / 600 defenders', 'siege1000-'),
              ('6,000 Mandingas / 600 defenders', 'siege6000-'),
              ('Private interior CAH158', 'house-interior-'),
              ('Renderer diagnostic repeats', 'render-'), ('Instrumented profiles', 'profile-')]
    for title, prefix in groups:
        subset = [row for row in rows if row['label'].startswith(prefix)]
        if not subset:continue
        lines += ['### '+title, '', '| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |',
                  '| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |']
        for row in subset:
            pm = row.get('presentmon', {})
            frame = pm.get('MsBetweenPresents', {})
            count = pm.get('sample_count', 0)
            lines.append('| '+' | '.join([row['variant']+' / '+row['label'],
                str(row['completed']), fmt(row.get('tics_per_second')),
                fmt(pm.get('application_present_fps')), str(count), fmt(frame.get('mean')),
                fmt(frame.get('p95') if count >= 30 else None),
                fmt(frame.get('p99') if count >= 30 else None)])+' |')
        lines += ['']
    lines += ['### Native renderer snapshots after peaceful windows', '',
        'These are individual native bench samples after the timed window, with',
        'the same stationary scene. CPU-side render/setup clocks may overlap',
        'worker threads; do not sum them into an additive CPU/GPU budget.', '',
        '| Variant / view | Walls | Flats | Sprites | Wall render ms | Wall setup ms | All ms |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for pitch in (0, 75):
        for shape, repeat in (('houses', 1), ('opaque', 2)):
            path = folder/f'{shape}-6000'/f'peace-{pitch}-{repeat}-bench.txt'
            text = path.read_text(encoding='utf-8')
            walls = re.search(r'Walls: (\d+)', text)
            flats = re.search(r'Flats: (\d+)', text)
            sprites = re.search(r'Sprites: (\d+)', text)
            walltime = re.search(r'W: Render=([\d.]+), Setup=([\d.]+)', text)
            total = re.search(r'All=([\d.]+)', text)
            assert all((walls, flats, sprites, walltime, total)), path
            lines.append('| '+' | '.join([f'{shape} / pitch{pitch}', walls[1], flats[1], sprites[1],
                fmt(float(walltime[1])), fmt(float(walltime[2])), fmt(float(total[1]))])+' |')
    lines += ['', '### Sampled CPU methods', '',
        'Exclusive milliseconds per sampled tic. These probes cover selected',
        'methods; native/uninstrumented work and instrumentation overhead remain.',
        'Inclusive nested costs must not be summed. Full costs, counts, bursts,',
        'censuses, camera state and CPU samples are retained in analysis/raw logs.', '',
        '| Method | 1000 houses | 1000 opaque | 6000 houses | 6000 opaque |',
        '| --- | ---: | ---: | ---: | ---: |']
    order = ['houses-1000-profile', 'opaque-1000-profile', 'houses-6000-profile', 'opaque-6000-profile']
    profiles = {row['variant']: row for row in rows if row['label'].startswith('profile-')}
    if set(profiles) == set(order) and all(row['completed'] and row.get('measurement_window_complete')
                                 for row in profiles.values()):
        costs = {shape: {p['name']: p['exclusive_ms_per_sample_tic'] for p in row.get('profile', [])}
                 for shape, row in profiles.items()}
        names = sorted(set().union(*(cost.keys() for cost in costs.values())),
                       key=lambda name: -max(costs[s].get(name, 0) for s in costs))
        for name in names[:25]:
            lines.append('| '+' | '.join([name]+[fmt(costs[variant].get(name)) for variant in order])+' |')
    else:
        lines += ['', 'All four completed profile windows are required for this comparison.',
                  'Incomplete/partial captures remain in the raw evidence and run table.']
    lines += ['', 'Reproduce with house_fixture.py, house_suite.py, house_verify.py and',
        'house_perf.py. Keep immutable evidence directories and stop the authorized',
        'ETW session before analyze.py/house_report.py. Old fixture failures and',
        'invalid-camera runs are preserved, not counted as successful acceptance.',
        'Normal synchronous attacker deployment remains unresolved; this experiment',
        'does not close #318 or replace author checks CA318-01..04.', '']
    section = '<!-- HOUSES_BEGIN -->\n'+'\n'.join(lines)+'\n<!-- HOUSES_END -->'
    report = HERE/'RESULTS.md'
    content = report.read_text(encoding='utf-8')
    if '<!-- HOUSES_BEGIN -->' in content:
        content = re.sub(r'<!-- HOUSES_BEGIN -->.*?<!-- HOUSES_END -->', lambda _: section,
                         content, flags=re.S)
    else:
        content += '\n'+section+'\n'
    report.write_text(content, encoding='utf-8')
    (HERE/'HOUSE_VERIFICATION.json').write_text(json.dumps(verification, indent=2)+'\n', encoding='utf-8')
    print('House report:', len(rows), 'performance runs;', len(verification['functional']), 'functional runs')


if __name__ == '__main__':
    main()
