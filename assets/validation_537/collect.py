"""Collect issue #234 evidence, retaining exact runtimes and scoped reuse."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue234'
RUNS = ['mansion-final-02', 'maze-final-02', 'city-final-01', 'city-final-02',
        'reload-mansion-02', 'reload-maze-02', 'reload-city-02', 'migration-01',
        'legacy-geometry-01', 'legacy-reload-02', 'hub-02', 'legacy-port1000-02', 'legacy-city-02',
        'presentation-mansion-02', 'presentation-city-01', 'presentation-maze-01']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def saved(name, map_id):
    with zipfile.ZipFile(WORK/(name+'.zds')) as archive:
        return json.loads(archive.read(map_id+'.map.json'))


def objects(data, kind):
    return [o for o in data['objects'] if o['classtype'] == kind]


def facts(data):
    return sorted([o['class:CaelumKnownPoi'] for o in objects(data, 'CaelumKnownPoi')],
                  key=lambda o: (o['MapId'], o['PoiId']))


def record(data):
    result = objects(data, 'CaelumPersistentCharacterState')[0]['class:CaelumPersistentCharacterState'].copy()
    for field in ('IdentityProfile', 'IdentityAllocation'):
        if field in result:
            result[field] = data['objects'][result[field]]
    for field in ('KnownPois', 'ManualNotes'):
        if field in result:
            result[field] = [data['objects'][i] for i in result[field]]
    return result


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {n: archive.read(n) for n in archive.namelist()}


final = members(WORK/'production.pk3')
runtime = digest(WORK/'production.pk3')
variants = {}
for name in ['production.pk3', 'load-current/oldmap-production.pk3',
             'before-parapet.pk3', 'before-room-audit.pk3', 'oldmap-production.pk3',
             'legacy-port1000-production.pk3', 'legacy-city-final.pk3']:
    path = WORK/name
    data = members(path)
    assert set(data) == set(final), name
    changed = [n for n in data if data[n] != final[n]]
    assert set(changed) <= {'caelum/world/CaelumMazeGates.zs',
                            'caelum/data/CaelumCartographyCatalogueData.zs',
                            'maps/MAP01.wad', 'maps/MAP06.wad'}, changed
    variants[digest(path)] = {'local_archive': name, 'different_members_from_final': changed}

runs, captures = [], []
(HERE/'captures').mkdir(exist_ok=True)
for label in RUNS:
    run = json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    log = (WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0 and 'CA234 DONE failures=0' in log, label
    assert not any(s in log for s in ('CA234 FAIL', 'Script error', 'VM execution aborted',
                                     'This savegame needs', 'Savegame is from a different level')), label
    assert run['runtime_sha256'].lower() in variants, label
    run['assertions'] = log.count('CA234 PASS ')
    assert run['assertions'] > 0, label
    runs.append(run)
    for suffix in ('.txt', '-run.json', '-exec.cfg'):
        shutil.copyfile(WORK/(label+suffix), HERE/(label+suffix))
    for path in sorted(WORK.glob(label+'-*.png')):
        if label == 'legacy-city-02':
            # Its short diagnostic captures before the queued network assertions;
            # only the four completed catalogue assertions are evidence here.
            continue
        # The original mansion service capture intentionally records the fixture's
        # still-open crafting session; the presentation run closes it properly.
        shutil.copyfile(path, HERE/'captures'/path.name)
        captures.append({'file': 'captures/'+path.name, 'sha256': digest(path)})

checks = {}
old = saved('c234-source536', 'map04')
migrated = saved('c234-migrated', 'map04')
a, b = record(old), record(migrated)
a.pop('LocalKnowledgeRevision', None); b.pop('LocalKnowledgeRevision', None)
checks['536_all_prior_character_values_and_manual_notes'] = a == b
checks['536_native_automap'] = objects(old, 'Automap') == objects(migrated, 'Automap')
checks['536_native_linedefs'] = old['linedefs'] == migrated['linedefs']
for place, map_id, suffix in [('mansion','map01','02'), ('maze','map02','02'), ('city','map06','02')]:
    current = saved('c234-'+place, map_id)
    reloaded = saved('c234-reload-'+place+'-'+suffix, map_id)
    checks[place+'_exact_facts_on_reload'] = facts(current) == facts(reloaded)
    checks[place+'_native_automap_on_reload'] = objects(current, 'Automap') == objects(reloaded, 'Automap')
    checks[place+'_native_linedefs_on_reload'] = current['linedefs'] == reloaded['linedefs']
maze = saved('c234-maze','map02')
returned = saved('c234-hubback','map02')
checks['hub_exact_original_facts'] = facts(maze) == facts(returned)
checks['hub_other_map_retains_original_facts'] = facts(maze) == facts(saved('c234-hub-map04','map04'))
old_geometry = saved('c234-old-geometry','map01')
old_reloaded = saved('c234-old-geometry-reloaded','map01')
checks['legacy_geometry_no_fabricated_rooms'] = facts(old_geometry) == facts(old_reloaded) == []
checks['legacy_geometry_linedefs_retained'] = old_geometry['linedefs'] == old_reloaded['linedefs']
assert all(checks.values()), checks

validation = json.loads((WORK/'validate.json').read_text(encoding='utf-8-sig'))
assert validation['errors'] == []
assert members(ROOT/'build/caelum_argenteum_dev.pk3') == final
for name in ['validate.json', 'build.txt']:
    shutil.copyfile(WORK/name, HERE/name)
diagnostics = ['compile-01', 'mansion-01', 'legacy-reload-01', 'legacy-city-01', 'legacy-port1000-01', 'sizing-01', 'sizing-02']
for label in diagnostics:
    for suffix in ('.txt', '-run.json', '-exec.cfg', '-stop.txt'):
        path = WORK/(label+suffix)
        if path.exists():
            shutil.copyfile(path, HERE/path.name)
evidence = {'issue':234, 'version':'5.3.7', 'baseline_commit':'bdcae305',
            'runtime_sha256':runtime, 'runtime_variants':variants, 'runs':runs,
            'native_assertions':sum(r['assertions'] for r in runs),
            'save_comparisons':checks, 'captures':captures, 'diagnostics':diagnostics,
            'source536_save_sha256':digest(WORK/'c234-source536.zds'),
            'normal_build_members_match_frozen':True,
            'author_acceptance':{'id': 'CA234-01', 'status': 'Tracked separately in RESULTS.md and docs/HISTORY.md; native runs do not imply author acceptance.'},
            'reuse':'Earlier unaffected cases retain their exact package hashes. MAP02 was rerun after the upper-control secrecy fix; MAP06 after including its authored parapet height; MAP01 after native wall traces corrected the ground-room side-door strips. Archive member differences are checked above.',
            'limits':['Native input plus diagnostic positioning is not ordinary author traversal acceptance.',
                      'Legacy geometry requires its matching archived WAD; native checksum rejection precedes ZScript.',
                      'The first 6000-attacker diagnostic was interrupted after about four minutes. The shorter diagnostic completed four catalogue assertions; no battle performance or 6000-attacker save/reload claim is made.',
                      'The 1000-attacker original port also completed the focused catalogue checks.',
                      'Multiplayer rendering remains suppressed; general multiplayer is not certified.',
                      'Sector warnings remain explicitly deferred.']}
(HERE/'evidence.json').write_bytes((json.dumps(evidence,indent=2)+'\n').encode())
print(f"Collected {len(runs)} runs, {evidence['native_assertions']} assertions, {len(checks)} save comparisons, {len(captures)} captures.")
