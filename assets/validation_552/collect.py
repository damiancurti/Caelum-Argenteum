"""Gate #311 evidence against frozen packages, native logs and actual saved state."""
from pathlib import Path
import hashlib
import json
import re
import statistics
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
REQUIRED = {
    'issue311-expanded01': ['energy-final01', 'combat-final01', 'motion-final01', 'siege-final01', 'contacts-final01'],
    'issue311-final01': ['dense-64-on01', 'dense-64-0-run01', 'dense-512-1-run01', 'dense-512-0-run01'],
    'issue311-legacy02': ['original-save'],
    'issue311-legacy04': ['original-rollback', 'converted-rollback'],
    'issue311-final03': ['upgrade-original', 'player-adapted', 'multiple-current', 'migration', 'contacts-reload',
        'reload-current', 'reload-upgraded', 'separation-save', 'separation-reload'],
    'issue311-final04': ['preview-visible', 'grid-on', 'grid-off'],
}
CACHE = {}


def sha(path):
    path = Path(path)
    if path not in CACHE: CACHE[path] = hashlib.sha256(path.read_bytes()).hexdigest()
    return CACHE[path]


def members(path, normalize_labels=False):
    with zipfile.ZipFile(path) as z:
        result = {}
        for name in z.namelist():
            data = z.read(name)
            if normalize_labels and name in ('caelum/world/CaelumPhysicalHazards.zs', 'caelum/world/CaelumSewerMaze.zs'):
                data = data.replace(b'[Caelum 5.5.1]', b'[Caelum 5.5.2]').replace(b'\r\n', b'\n')
            result[name] = hashlib.sha256(data).hexdigest()
        return result


def save_contact(path):
    with zipfile.ZipFile(path) as z: objects = json.loads(z.read('.mapd.json'))['objects']
    actor_ids = {}
    for i, obj in enumerate(objects):
        if obj.get('tid') in (45311, 45312): actor_ids[i] = obj['tid']
    candidates = []
    for obj in objects:
        if obj.get('classtype') != 'ImpactContactState': continue
        data = obj['class:ImpactContactState']
        if data.get('FirstActor') in actor_ids and data.get('SecondActor') in actor_ids:
            candidates.append(data)
    assert len(candidates) == 1, (path, actor_ids, len(candidates))
    return {'sha256': sha(path), 'contact': candidates[0]}


def main():
    evidence = {'required': [], 'all_runs': [], 'costs': [], 'saved_state': {}, 'notes': [
        'Body timers include nested contact timers; do not add them.',
        'Synthetic position/velocity restoration lies outside timers. Controls change contact resolution and pressure work.',
        'CPU measurements are instrumented per-tic samples, not FPS or siege performance.',
        'The early legacy01 run completed assertions but exited before writing its save; it is not migration evidence.',
        'Expanded player-final01 retains three obsolete pre-#211 landing expectations; player-adapted uses the already approved 150% rule.',
    ]}
    required = {(directory, label) for directory, labels in REQUIRED.items() for label in labels}
    found = set()
    for directory in sorted((ROOT / 'build').glob('issue311-*')):
        if not (directory / 'manifest.json').is_file(): continue
        manifest = json.loads((directory / 'manifest.json').read_text(encoding='utf-8'))
        for record_path in sorted(directory.glob('*-run.json')):
            record = json.loads(record_path.read_text(encoding='utf-8-sig'))
            label = record['label']; key = (directory.name, label)
            log_path = directory / (label + '.txt')
            log = log_path.read_text(encoding='utf-8-sig', errors='replace') if log_path.exists() else ''
            markers = re.findall(r'CA194 DONE failures=(\d+) passes=(\d+)', log)
            failed = re.findall(r'^.*(?:CA194 FAIL|Script error|Could not open|VM execution aborted|DIED WITH FATAL ERROR).*$', log, re.M)
            success = record.get('exit_code') == 0 and markers and all(int(f) == 0 for f, _ in markers) and not failed
            row = {'directory': directory.name, 'label': label, 'passed': bool(success),
                'markers': markers, 'failures': failed, 'runtime_sha256': record.get('runtime_sha256'),
                'fixture_sha256': record.get('fixture_sha256'), 'engine_sha256': record.get('engine_sha256'),
                'log_sha256': sha(log_path), 'record_sha256': sha(record_path)}
            evidence['all_runs'].append(row)
            target = HERE / 'evidence'; target.mkdir(exist_ok=True)
            for path in (record_path, log_path):
                (target / (directory.name + '--' + path.name)).write_bytes(path.read_bytes())
            (target / (directory.name + '--manifest.json')).write_bytes((directory / 'manifest.json').read_bytes())
            if key in required:
                assert success, row
                args = record['arguments']; index = args.index('-file')
                runtime, fixture = (Path(args[index + n].strip('"')) for n in (1, 2))
                assert sha(runtime) == record['runtime_sha256'].lower() == manifest['runtime_sha256'].lower(), key
                assert sha(fixture) == record['fixture_sha256'].lower() == manifest['fixtures'][fixture.name].lower(), key
                for name, digest in manifest['script_hashes'].items(): assert sha(directory / name) == digest
                assert record.get('finished_utc') and record['engine_sha256']
                found.add(key); evidence['required'].append(row)
            samples = re.findall(r'CA311 COST mode=(\d+) population=(\d+)(?: layout=(\d+))? tic=(\d+) body_ms=([.\d]+) contact_ms=([.\d]+) ticks=(\d+) callbacks=(\d+)', log)
            if key in required and samples:
                assert len(samples) == 350, (key, len(samples))
                assert all(int(s[6]) == int(s[1]) for s in samples), key
                def metrics(index):
                    values = sorted(float(s[index]) for s in samples)
                    return {'mean_ms': statistics.mean(values), 'median_ms': statistics.median(values),
                        'p95_ms': values[int(0.95 * (len(values)-1))], 'max_ms': max(values)}
                evidence['costs'].append({'directory': directory.name, 'label': label, 'samples': len(samples),
                    'mode': int(samples[0][0]), 'population': int(samples[0][1]), 'layout': int(samples[0][2] or 0),
                    'body': metrics(4), 'contact': metrics(5),
                    'mean_native_callbacks_per_tic': statistics.mean(int(s[7]) for s in samples)})
    assert found == required, sorted(required - found)
    assert len({r['engine_sha256'] for r in evidence['required']}) == 1
    normal = ROOT / 'build/caelum_argenteum_dev.pk3'
    current = members(normal)
    assert members(ROOT / 'build/issue311-final03/production.pk3') == current
    assert members(ROOT / 'build/issue311-final01/production.pk3') == current
    assert members(ROOT / 'build/issue311-expanded01/production.pk3', True) == members(normal, True)
    baseline = members(ROOT / 'build/issue311-explore05/production.pk3')
    changed = sorted(n for n in current if current[n] != baseline.get(n))
    assert changed == sorted(['caelum/actors/CaelumCombatActor.zs', 'caelum/core/CaelumImpactEnergy.zs',
        'caelum/player/CaelumPlayer.zs', 'caelum/world/CaelumPhysicalHazards.zs',
        'caelum/world/CaelumSewerMaze.zs', 'impactphysics/ImpactPhysics.zs']), changed
    assert set(current) == set(baseline)
    evidence['package'] = {'normal_sha256': sha(normal), 'members': len(current), 'changed_vs_5_5_1': changed,
        'reused_component_package': 'Exact member equality after normalizing only two diagnostic version labels and their CRLF/LF line endings.'}
    for key, name in [('original', 'issue311-legacy02/ca311-legacy.zds'),
        ('upgraded', 'issue311-final03/ca311-upgraded.zds'), ('separated', 'issue311-final03/ca311-separated.zds')]:
        evidence['saved_state'][key] = save_contact(ROOT / 'build' / name)
    old = evidence['saved_state']['original']['contact']; upgraded = evidence['saved_state']['upgraded']['contact']
    separated = evidence['saved_state']['separated']['contact']
    assert old.get('ReleaseDistance', 0) == 0 and old.get('ReleaseDistanceRevision', 0) == 0
    assert upgraded['ReleaseDistance'] == 48 and upgraded['ReleaseDistanceRevision'] == 1
    assert separated['ReleaseDistanceRevision'] == 1 and 0 < separated['SeparatedTics'] < 5
    assert sha(ROOT / 'build/issue311-final03/original-legacy.zds') == evidence['saved_state']['original']['sha256']
    assert sha(ROOT / 'build/issue311-legacy04/converted-current.zds') == evidence['saved_state']['upgraded']['sha256']
    assert sha(ROOT / 'build/issue311-legacy04/ca311-legacy.zds') == evidence['saved_state']['original']['sha256']
    evidence['status'] = 'PASS'
    (HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'status': evidence['status'], 'required_runs': len(found), 'preserved_runs': len(evidence['all_runs']),
        'costs': evidence['costs']}, indent=2))


if __name__ == '__main__': main()
