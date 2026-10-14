"""Collect city regressions, actual saved facts and the exact tested runtime delta."""
import hashlib
import json
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue234-city-fix'


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name).replace(b'\r\n', b'\n')
                if name.endswith('.zs') or name in ('KEYCONF', 'MENUDEF', 'ZSCRIPT') else archive.read(name)
                for name in archive.namelist()}


def saved(path):
    with zipfile.ZipFile(path) as archive:
        data = json.loads(archive.read('map06.map.json'))
    facts = {o['class:CaelumKnownPoi']['PoiId']: o['class:CaelumKnownPoi']
             for o in data['objects'] if o['classtype'] == 'CaelumKnownPoi'}
    record = next(o['class:CaelumPersistentCharacterState'] for o in data['objects']
                  if o['classtype'] == 'CaelumPersistentCharacterState')
    # Native object-table indices may change after loading; compare profile data.
    record = dict(record)
    record['IdentityProfile'] = data['objects'][record['IdentityProfile']]['class:CaelumCharacterProfile']
    return facts, record


original, fixed = members(WORK / 'baseline.pk3'), members(WORK / 'production.pk3')
assert original.keys() == fixed.keys()
changed = sorted(k for k in fixed if original[k] != fixed[k])
assert changed == ['caelum/data/CaelumCartographyCatalogueData.zs', 'caelum/data/CaelumPoiData.zs',
                   'caelum/world/CaelumAuthoredCartography.zs', 'caelum/world/CaelumBreakableGate.zs'], changed
assert fixed == members(ROOT / 'build/caelum_argenteum_dev.pk3')
report = {'issue': 234, 'version': '5.3.7', 'runtime_changed_members': changed,
          'runtime_sha256': hashlib.sha256((WORK / 'production.pk3').read_bytes()).hexdigest(),
          'authored_station_slots_verified_in_wad': 96, 'runs': [], 'save_comparisons': []}
cases = [('city-before-07', 8, WORK), ('city-after-02', 0, WORK), ('city-second-01', 0, WORK),
         ('city-reload-01', 0, WORK), ('city-catalogue-01', 0, WORK),
         ('city-old-save-01', 0, WORK / 'load-baseline'), ('city-native-denied-01', 0, WORK),
         ('city-open-view-01', 0, WORK)]
for label, failures, folder in cases:
    log = (folder / (label+'.txt')).read_text(encoding='utf-8-sig')
    run = json.loads((folder / (label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code'] == 0, label
    assert log.count('CA234 FAIL ') == failures, label
    assert f'CA234 DONE failures={failures}' in log, label
    assert not any(error in log for error in ['Script error', 'VM execution aborted', 'Savegame is from a different level'])
    run.update(assertions=log.count('CA234 PASS ')+failures, expected_failures=failures)
    report['runs'].append(run)
    for suffix in ['.txt', '-run.json', '-exec.cfg']:
        shutil.copyfile(folder / (label+suffix), HERE / (label+suffix))
closed, _ = saved(WORK / 'city-after-02-closed.zds')
opened, _ = saved(WORK / 'city-after-02-open.zds')
gate_id = 'port-r3-gate-0'
assert len(closed) == len(opened) == 1
assert closed[gate_id]['observedAccess'] == 1 and opened[gate_id]['observedAccess'] == 2
assert {k:v for k,v in closed[gate_id].items() if k != 'observedAccess'} == {k:v for k,v in opened[gate_id].items() if k != 'observedAccess'}
report['save_comparisons'].append('gate closed/open changes only observedAccess')
for first, second, expected_count in [('city-after-02-services', 'city-services-reloaded', 2),
                                      ('city-catalogue', 'city-reloaded', 97)]:
    a, ar = saved(WORK / (first+'.zds')); b, br = saved(WORK / (second+'.zds'))
    assert a == b and len(a) == expected_count
    assert ar['LocalKnowledgeSerial'] == br['LocalKnowledgeSerial']
    report['save_comparisons'].append(first+'/'+second+': exact facts and knowledge serial')
old, before = saved(WORK / 'city-before-07-services.zds')
preserved, after = saved(WORK / 'load-baseline/city-old-preserved.zds')
assert old == preserved and len(old) == 1 and old[gate_id]['observedAccess'] == 0
assert before['LocalKnowledgeSerial'] == after['LocalKnowledgeSerial']
for key in ['ProfileCommitted','IdentityProfile','QuestState','QuestStage','QuestRewardClaimed',
            'QuestObjectiveProgress','QuestObjectiveTarget','QuestObjectiveKnown','TarotOwned','TarotSelected',
            'EquippedArmorItemId','EquippedShieldItemId','ActiveWeaponItemId','EquippedAmuletItemId',
            'EquippedSealItemId','MagicBoxItemId','NextEquipmentItemId','ManualNotesRevision','ManualNotesSerial','ManualNoteNextId']:
    assert before.get(key) == after.get(key), key
report['save_comparisons'].append('genuine old save preserves unknown access, profile, quests, owned Tarot, equipment IDs and note metadata')
updated, _ = saved(WORK / 'load-baseline/city-old-updated.zds')
assert len(updated) == 2 and updated[gate_id]['observedAccess'] == 1
assert 'city-factory-0-workbench' in updated
report['save_comparisons'].append('old save acquires gate state and one station only after new native interactions')
captures = ['city-after-02-city-stations.png', 'city-native-denied-01-city-closed.png', 'city-open-view-01-city-open.png']
for name in captures:
    shutil.copyfile(WORK / name, HERE / 'captures' / name)
report['captures'] = captures
report['author_acceptance'] = 'Pending city correction retest in CA234-01; earlier mansion/sewer acceptance remains separate.'
report['fixed_assertions'] = sum(r['assertions'] for r in report['runs'] if r['expected_failures'] == 0)
(HERE / 'cityfix_evidence.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(f"City corrections: {report['fixed_assertions']} assertions, {len(report['save_comparisons'])} save comparisons; baseline reproduces eight failures.")
