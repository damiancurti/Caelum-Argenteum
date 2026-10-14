"""Collect target-marker regressions and compare genuine native save records."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue235-targets'
RUNS = ('targets-after-02', 'targets-reload-01', 'targets-hub-01')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name) for name in archive.namelist() if not name.endswith('/')}


def normalized(data):
    # Native field identifiers are case-insensitive across engine save rewrites.
    if isinstance(data, dict):
        return {key.casefold(): normalized(value) for key, value in data.items()}
    if isinstance(data, list):
        return [normalized(value) for value in data]
    return data


def saved_record(name):
    with zipfile.ZipFile(WORK / (name + '.zds')) as archive:
        map_id = json.loads(archive.read('info.json'))['Current Map'].lower()
        data = json.loads(archive.read(map_id + '.map.json'))
    record = next(obj['class:CaelumPersistentCharacterState'].copy()
                  for obj in data['objects'] if obj['classtype'] == 'CaelumPersistentCharacterState')
    for key in ('IdentityProfile', 'IdentityAllocation', 'ThermalObservation'):
        if key in record:
            record[key] = data['objects'][record[key]]
    for key in ('KnownPois', 'ManualNotes'):
        if key in record:
            record[key] = [data['objects'][index] for index in record[key]]
    return normalized(record)


final = members(WORK / 'production.pk3')
before = members(WORK / 'baseline.pk3')
assert set(final) == set(before)
text_suffixes = {'.zs', '.mapinfo', '.usdf', '.md', '.json', '.txt', '.inf', '.textures', '.obj'}
text_lumps = {'ANIMDEFS', 'CAPALOMO', 'FONTDEFS', 'LANGUAGE', 'TERRAIN'}
changed = [name for name in final if final[name] != before[name]
           and (Path(name).suffix.lower() not in text_suffixes and name not in text_lumps
                or final[name].replace(b'\r\n', b'\n') != before[name].replace(b'\r\n', b'\n'))]
assert set(changed) == {
    'caelum/data/CaelumQuestTrackingData.zs', 'caelum/hud/CaelumJournalOverlay.zs',
    'caelum/hud/CaelumQuestTrackingView.zs', 'caelum/world/CaelumPoiKnowledge.zs'}, changed
assert final == members(ROOT / 'build/caelum_argenteum_dev.pk3')
records = []
captures = []
for label in RUNS:
    run = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0 and 'CA235 DONE failures=0' in log, label
    assert not any(text in log for text in ('CA235 FAIL', 'Script error', 'VM execution aborted'))
    assert run['runtime_sha256'].lower() == digest(WORK / 'production.pk3')
    run['assertions'] = log.count('CA235 PASS')
    records.append(run)
    for suffix in ('.txt', '-exec.cfg', '-run.json'):
        shutil.copyfile(WORK / (label + suffix), HERE / (label + suffix))
    for source in WORK.glob(label + '-*.png'):
        shutil.copyfile(source, HERE / 'captures' / source.name)
        captures.append({'file': 'captures/' + source.name, 'sha256': digest(source)})
label = 'targets-before-01'
baseline = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
assert baseline['exit_code'] == 0 and log.count('CA235 FAIL') == 12
assert baseline['runtime_sha256'].lower() == digest(WORK / 'baseline.pk3')
for suffix in ('.txt', '-exec.cfg', '-run.json'):
    shutil.copyfile(WORK / (label + suffix), HERE / (label + suffix))
checks = {
    'pre_change_save_record_unchanged_by_marker': saved_record('c235-tracked') == saved_record('targets-after-02-c235-targets-before'),
    'current_reload_entire_resolved_record_equal': saved_record('targets-after-02-c235-targets-current') == saved_record('targets-reload-01-c235-targets-reloaded'),
}
assert all(checks.values()), checks
report = {
    'issue': 235, 'version': '5.3.8', 'runtime_sha256': digest(WORK / 'production.pk3'),
    'changed_runtime_members': changed, 'normal_package_members_equal': True,
    'baseline_expected_failures': 12, 'runs': records,
    'assertions': sum(record['assertions'] for record in records),
    'save_checks': checks, 'captures': captures,
    'limits': ['Diagnostic stage/knowledge events are not ordinary campaign progression.',
               'Native marker privacy gating and existing input paths are unchanged; no new multiplayer certification.',
               'The earlier flow used generic save names; the selected final flow prefixes save names per run.',
               'CA235-01 is accepted; new target-marker author check CA235-02 remains separate.'],
}
(HERE / 'targets_evidence.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'assertions': report['assertions'], 'save_checks': checks, 'captures': len(captures)}, indent=2))
