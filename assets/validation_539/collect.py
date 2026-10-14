"""Collect bounded native evidence for issue #236; saves/packages stay local."""
from pathlib import Path
import hashlib
import io
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue236'
RUNS = ['flow-08', 'fresh-01', 'travel-01', 'compat-01', 'reload-01', 'hub-01',
        'box-01', 'empty-01', 'presentation-small-01', 'presentation-large-01',
        'map-small-01', 'map-large-01', 'pointer-01', 'case-01']
CAPTURES = ['flow-08-' + x for x in ['navigation', 'documents', 'notes', 'map']]
CAPTURES += ['travel-01-arrival', 'compat-01-old-notes', 'box-01-boxed', 'empty-01-empty']
CAPTURES += [f'presentation-{size}-01-{view}' for size in ['small', 'large']
             for view in ['navigation', 'documents', 'world']]
CAPTURES += ['map-small-01-map', 'map-large-01-map']
CAPTURES += ['pointer-01-pointer-world']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name) for name in archive.namelist()}


def saved(name):
    with zipfile.ZipFile(WORK / (name + '.zds')) as archive:
        map_id = json.loads(archive.read('info.json'))['Current Map'].lower()
        return json.loads(archive.read(map_id + '.map.json'))


def objects(data, kind):
    return [o for o in data['objects'] if o['classtype'] == kind]


def record(data):
    result = objects(data, 'CaelumPersistentCharacterState')[0]['class:CaelumPersistentCharacterState'].copy()
    for key in ('IdentityProfile', 'IdentityAllocation', 'ThermalState'):
        if result.get(key) is not None:
            result[key] = data['objects'][result[key]]
    for key in ('KnownPois', 'ManualNotes'):
        if key in result:
            result[key] = [data['objects'][i] for i in result[key]]
    return result


def inventory(data):
    """Native owned instance IDs, quantities, equipment IDs and Box placement."""
    owner = next(i for i, o in enumerate(data['objects']) if o['classtype'] == 'CaelumPlayer')
    rows = []
    for obj in data['objects']:
        native = obj.get('class:Inventory', {})
        if native.get('Owner') != owner:
            continue
        identities = {}
        for name, fields in obj.items():
            if name.startswith('class:') and isinstance(fields, dict):
                for field in ('ItemId', 'InMagicBox', 'Equipped', 'Durability'):
                    if field in fields:
                        identities[name + '.' + field] = fields[field]
        rows.append((obj['classtype'], obj.get('inventoryid'), native.get('Amount'), identities))
    return sorted(rows, key=lambda row: (row[0], row[1] or 0))


checks = {}
for first, second, prefix, ignored in [
    ('c236-final-before', 'c236-final-after', 'current_browsing', ('ThermalState',)),
    ('c236-before', 'c236-reloaded', 'native_reload', ('ThermalState',)),
    ('c236-fresh-before', 'c236-fresh-after', 'fresh_browsing', ('ThermalState',)),
    ('c236-loaded', 'c236-compat', 'older_browsing', ('ThermalState',)),
]:
    old, new = saved(first), saved(second)
    a, b = record(old), record(new)
    for field in ignored:
        a.pop(field, None)
        b.pop(field, None)
    checks[prefix + '_record'] = a == b
    checks[prefix + '_inventory'] = inventory(old) == inventory(new)
    checks[prefix + '_automap'] = objects(old, 'Automap') == objects(new, 'Automap')
    checks[prefix + '_linedefs'] = old['linedefs'] == new['linedefs']

old, new = saved('c236-source537-notes'), saved('c236-loaded')
a, b = record(old), record(new)
checks['older_only_existing_235_revision'] = b.pop('QuestTrackingRevision') == 1
checks['older_no_inferred_tracking'] = b.pop('QuestTracked') == [0] * 32
a.pop('ThermalState', None)
b.pop('ThermalState', None)
checks['older_all_prior_nonthermal_record_values'] = a == b
checks['older_owned_instances'] = inventory(old) == inventory(new)
checks['older_native_automap'] = objects(old, 'Automap') == objects(new, 'Automap')
checks['older_native_linedefs'] = old['linedefs'] == new['linedefs']

old, new = saved('c236-hub-before'), saved('c236-hub-return')
a, b = record(old), record(new)
for field in ('StoredSleep', 'StoredHunger', 'StoredThirst', 'ThermalState'):
    a.pop(field, None)
    b.pop(field, None)
checks['hub_other_record_values'] = a == b
checks['hub_owned_instances'] = inventory(old) == inventory(new)
checks['hub_notes_pois_not_copied_to_other_map'] = record(old)['KnownPois'] == record(saved('c236-hub-sewers'))['KnownPois']

old, new = saved('c236-travel-before'), saved('c236-travel-cancelled')
a, b = record(old), record(new)
a.pop('ThermalState', None)
b.pop('ThermalState', None)
checks['cancel_other_record_values'] = a == b
# Preview owns one transient native plan Inventory; it is not a carried item.
checks['cancel_owned_instances'] = inventory(old) == [r for r in inventory(new) if r[0] != 'CaelumJourneyPlan']
clock_a = objects(old, 'CaelumWorldClock')[0]['class:CaelumWorldClock']
clock_b = objects(new, 'CaelumWorldClock')[0]['class:CaelumWorldClock']
checks['cancel_only_natural_clock_ticks'] = (clock_b['CompletedDays'] == clock_a['CompletedDays']
    and clock_b['DayTics'] - clock_a['DayTics'] == new['maptime'] - old['maptime'])
assert all(checks.values()), {k: v for k, v in checks.items() if not v}

runtime = digest(WORK / 'production.pk3')
previous = digest(WORK / 'before-craft-pointer.pk3')
pointer_runtime = digest(WORK / 'before-command-case.pk3')
old_members, final_members = members(WORK / 'before-craft-pointer.pk3'), members(WORK / 'production.pk3')
changed = {name for name in old_members.keys() | final_members.keys() if old_members.get(name) != final_members.get(name)}
assert changed == {'caelum/ui/CaelumLiveMenu.zs', 'caelum/ui/CaelumExplorationNavigation.zs'}, changed
old_router = old_members['caelum/ui/CaelumExplorationNavigation.zs'].decode().replace('\r\n', '\n')
new_router = final_members['caelum/ui/CaelumExplorationNavigation.zs'].decode().replace('\r\n', '\n')
assert new_router.replace('if(command~=="ca_', 'if(command=="ca_') == old_router
pointer_members = members(WORK / 'before-command-case.pk3')
assert {name for name in pointer_members if pointer_members[name] != final_members[name]} == {'caelum/ui/CaelumExplorationNavigation.zs'}
assert pointer_members['caelum/ui/CaelumExplorationNavigation.zs'] == old_members['caelum/ui/CaelumExplorationNavigation.zs']
old_code = old_members['caelum/ui/CaelumLiveMenu.zs'].decode().replace('\r\n', '\n')
final_code = final_members['caelum/ui/CaelumLiveMenu.zs'].decode().replace('\r\n', '\n')
old_mouse = 'if(mouseScan!=0 && (CaelumInputHints.Matches(mouseScan,"ca_journal_toggle") || CaelumInputHints.Matches(mouseScan,"ca_time_skip")))'
new_mouse = 'if(mouseScan!=0 && (CaelumInputHints.Matches(mouseScan,"ca_journal_toggle") || CaelumInputHints.Matches(mouseScan,"ca_time_skip")\n            || (Context>=1 && Context<=7 && CaelumExplorationNavigation.IsShortcut(Bindings.GetBinding(mouseScan)))))'
old_craft = '&& !CaelumMenuPointer.Inside(point,(508,15),(100,18)))'
new_craft = '&& !CaelumMenuPointer.Inside(point,(508,15),(100,18))\n            && !CaelumMenuPointer.Inside(point,(32,15),(104,18)))'
assert final_code.replace(new_mouse, old_mouse).replace(new_craft, old_craft) == old_code
revisions = {}
for source in sorted((HERE / 'fixture_revisions').glob('*.zs')):
    stream = io.BytesIO()
    data = {'ZSCRIPT': b'version "4.14"\n#include "checks/probe.zs"\n',
            'checks/probe.zs': source.read_bytes(), 'MAPINFO': b'GameInfo { AddEventHandlers="CA236Probe" }\n'}
    with zipfile.ZipFile(stream, 'w', zipfile.ZIP_STORED) as archive:
        for name, blob in sorted(data.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), blob)
    revisions[hashlib.sha256(stream.getvalue()).hexdigest()] = source.relative_to(HERE).as_posix()
runs = []
for label in RUNS:
    report = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8')
    actual_runtime = report['runtime_sha256'].lower()
    assert report['exit_code'] == 0 and actual_runtime in (runtime, previous, pointer_runtime), label
    if label in ('flow-08', 'pointer-01'):
        assert actual_runtime == pointer_runtime, label
    if label == 'case-01':
        assert actual_runtime == runtime, label
    assert 'CA236 DONE failures=0' in log, label
    fixture_source = revisions[report['fixture_sha256'].lower()]
    assert not any(bad in log for bad in ('CA236 FAIL', 'Script error', 'VM execution aborted',
        'DIED WITH FATAL ERROR', 'This savegame needs', 'Savegame is from a different level')), label
    runs.append({'label': label, 'assertions': log.count('CA236 PASS'), 'fixture_sha256': report['fixture_sha256'], 'fixture_source': fixture_source,
                 'runtime_sha256': actual_runtime, 'exit_code': report['exit_code']})
    for suffix in ['.txt', '-run.json', '-exec.cfg']:
        shutil.copyfile(WORK / (label + suffix), HERE / (label + suffix))

captures = HERE / 'captures'
captures.mkdir(exist_ok=True)
for name in CAPTURES:
    shutil.copyfile(WORK / (name + '.png'), captures / (name + '.png'))

diagnostics = ['compile-01', 'compile-02', 'flow-01', 'flow-02', 'flow-03', 'flow-04', 'flow-05', 'flow-06', 'flow-07']
for label in diagnostics:
    for suffix in ['.txt', '-run.json', '-exec.cfg', '-stdout.txt', '-stderr.txt']:
        source = WORK / (label + suffix)
        if source.exists():
            shutil.copyfile(source, HERE / source.name)

validation = json.loads((WORK / 'validate.json').read_text(encoding='utf-8-sig'))
assert validation['errors'] == [], validation
assert members(ROOT / 'build/caelum_argenteum_dev.pk3') == members(WORK / 'production.pk3')
for name in ('validate.json', 'build.txt'):
    shutil.copyfile(WORK / name, HERE / name)
evidence = {'issue': 236, 'version': '5.3.9', 'baseline': '2f738c39', 'runtime_sha256': runtime,
            'previous_runtime_sha256': previous,
            'pointer_runtime_sha256': pointer_runtime,
            'verified_runtime_delta': ['Crafting header pointer exclusion', 'Exact navigation shortcuts on GUI middle/forward mouse events', 'Case-insensitive command routing matches native command semantics'],
            'runs': runs, 'native_assertions': sum(r['assertions'] for r in runs), 'save_checks': checks,
            'captures_inspected': CAPTURES, 'validation_exit': 0, 'build_exit': 0,
            'saved_sha256': {p.name: digest(p) for p in sorted(WORK.glob('c236-*.zds'))},
            'limits': ['Native handlers and console routes, not physical input acceptance.',
                       'Record comparisons resolve identity/POI/note references and exclude live ThermalState; hub also excludes three survival observations.',
                       'A preview may create one transient journey plan; cancellation changes no carried instances.',
                       'The 5.3.7 upgrade includes only the previously delivered #235 tracking revision.',
                       'Author CA236-01 deferred; no multiplayer certification or merge.']}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
print(f"{len(runs)} runs, {evidence['native_assertions']} native assertions, {len(checks)} save checks, {len(CAPTURES)} inspected captures")
