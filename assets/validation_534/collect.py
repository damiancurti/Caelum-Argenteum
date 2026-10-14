"""Retain final native evidence; keep engines, IWADs and saves local."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue231'
RUNS = {
    'contract-05': ('probe', 'legacy'),
    'old-save-01': ('legacy', ''), 'current-load-03': ('legacy', ''),
    'current-reload-03': ('legacy', ''), 'rollback-01': ('legacy', ''),
    'hub-02': ('legacy', ''),
    'clock-limbo-02': ('probe', 'legacy'), 'clock-campaign-02': ('probe', 'legacy'),
    'floors-es-04': ('probe', 'legacy'),
    'layout-43-es-02': ('probe', 'legacy'), 'layout-wide-en-03': ('probe', 'legacy'),
    'layout-169-en-02': ('probe', 'legacy'),
    'perf-current-02': ('bench', 'legacy'), 'perf-baseline-02': ('bench', 'legacy'),
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def saved(name, map_name='map01'):
    with zipfile.ZipFile(WORK / (name + '.zds')) as archive:
        return json.loads(archive.read(map_name + '.map.json'))


def object_of(data, class_name):
    return next(o for o in data['objects'] if o['classtype'] == class_name)


runtime = digest(WORK / 'production.pk3')
records, captures, performance = [], [], {}
(HERE / 'captures').mkdir(exist_ok=True)
for label, (fixture, extra) in RUNS.items():
    run = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0 and 'CA231 DONE failures=0' in log, label
    assert not any(error in log for error in ('CA231 FAIL', 'Script error', 'VM execution aborted')), label
    if run['production_sha256']:
        assert run['production_sha256'].lower() == runtime, label
    assert run['fixture_sha256'].lower() == digest(WORK / f'{fixture}.pk3'), label
    if extra:
        assert run['additional_fixture_sha256'].lower() == digest(WORK / f'{extra}.pk3'), label
    run['native_assertions'] = log.count('CA231 PASS ')
    records.append(run)
    for filename in (f'{label}-run.json', f'{label}.txt'):
        shutil.copyfile(WORK / filename, HERE / filename)
    for path in sorted(WORK.glob(label + '-*.png')):
        shutil.copyfile(path, HERE / 'captures' / path.name)
        captures.append({'file': 'captures/' + path.name, 'sha256': digest(path)})
    measurements = []
    for line in log.splitlines():
        if line.startswith('CA231 PERF '):
            measurements.append({k: float(v) for k, v in re.findall(r'(\w+)=([\d.]+)', line)})
    if measurements:
        performance[label] = measurements

original = saved('c231-old')
save_checks = []
for name in ('c231-current-final', 'c231-reload-final', 'c231-rollback'):
    loaded = saved(name)
    checks = {
        'entire_native_automap': object_of(original, 'Automap') == object_of(loaded, 'Automap'),
        'native_linedefs': original['linedefs'] == loaded['linedefs'],
        'character_record': object_of(original, 'CaelumPersistentCharacterState') == object_of(loaded, 'CaelumPersistentCharacterState'),
    }
    assert all(checks.values()), (name, checks)
    save_checks.append({'save': name, 'sha256': digest(WORK / (name + '.zds')), 'checks': checks})
before, after = saved('c231-hub-before', 'map03'), saved('c231-hub-after', 'map03')
hub_checks = {
    'native_automap': object_of(before, 'Automap') == object_of(after, 'Automap'),
    'native_linedefs': before['linedefs'] == after['linedefs'],
}
assert all(hub_checks.values()), hub_checks
old_hash = digest(WORK / 'c231-old.zds')
for label in ('current-load-03', 'rollback-01'):
    assert next(r for r in records if r['label'] == label)['input_save_sha256'].lower() == old_hash

validation = json.loads((WORK / 'validate.txt').read_text(encoding='utf-8-sig'))
assert validation['errors'] == []
(HERE / 'validate.json').write_text(json.dumps(validation, indent=2) + '\n', encoding='utf-8')
shutil.copyfile(WORK / 'build.txt', HERE / 'build.txt')
evidence = {
    'issue': 231, 'version': '5.3.4', 'baseline_commit': '7b90cfde8507808ebee5539952956b8027df2a28',
    'engine_source_commit': '99aa489d09015a95bb78df2b30ede29f328cc874',
    'runtime_sha256': runtime, 'unchanged_original_save_sha256': old_hash,
    'runs': records, 'native_assertions': sum(r['native_assertions'] for r in records),
    'save_comparisons': save_checks, 'hub_comparison': hub_checks,
    'captures': captures, 'map06_frame_samples': performance,
    'static_commands': [
        {'command': 'python validate_project.py', 'exit_code': 0},
        {'command': 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1', 'exit_code': 0}],
    'author_acceptance': {'id': 'CA231-01', 'origin_version': '5.3.4', 'result': 'pending'},
    'limits': [
        'Native commands are scripted; physical keyboard/controller and nested settings input remain pending after the Computer Use Escape interruption.',
        'MAP01 native linework overlaps storeys; no floor picker or automatic zoom policy was added.',
        'Saves are genuine engine-created isolated scenarios, not a full author campaign or multiplayer certification.',
        'MAP06 samples cover frame intervals during scripted map modes/navigation; they are not physical-input latency measurements or a new mass-AI performance pass.'],
}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
print(f'Collected {len(records)} runs, {evidence["native_assertions"]} native assertions, 11 save comparisons and {len(captures)} captures.')
