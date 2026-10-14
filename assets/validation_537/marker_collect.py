"""Collect the native open-grate icon regression and preserve its baseline evidence."""
from pathlib import Path
import hashlib
import json
import shutil
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OPEN_PADLOCK = '--open-padlock' in sys.argv
WORK = ROOT / ('build/issue234-open-padlock' if OPEN_PADLOCK else 'build/issue234-marker-fix')


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name).replace(b'\r\n', b'\n') if name.endswith('.zs') or name in ('KEYCONF', 'MENUDEF', 'ZSCRIPT') else archive.read(name)
                for name in archive.namelist()}


def state(name):
    with zipfile.ZipFile(WORK / (name + '.zds')) as archive:
        data = json.loads(archive.read('map02.map.json'))
    facts = [o['class:CaelumKnownPoi'] for o in data['objects'] if o['classtype'] == 'CaelumKnownPoi']
    record = next(o['class:CaelumPersistentCharacterState'] for o in data['objects']
                  if o['classtype'] == 'CaelumPersistentCharacterState')
    return facts, record


original = members(WORK / 'baseline.pk3')
fixed = members(WORK / 'production.pk3')
added = {'graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png'} if OPEN_PADLOCK else set()
assert fixed.keys() - original.keys() == added and not original.keys() - fixed.keys()
changed = sorted(name for name in fixed if name not in original or original[name] != fixed[name])
expected = ['caelum/data/CaelumPoiData.zs', 'graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png'] if OPEN_PADLOCK else ['caelum/data/CaelumPoiData.zs', 'caelum/world/CaelumPoiKnowledge.zs']
assert changed == expected, changed
assert fixed == members(ROOT / 'build/caelum_argenteum_dev.pk3'), 'Production build differs from tested package.'
report = {'issue': 234, 'version': '5.3.7', 'runtime_changed_members': changed,
          'runtime_sha256': hashlib.sha256((WORK / 'production.pk3').read_bytes()).hexdigest(),
          'runs': [], 'save_comparisons': []}
cases = [('unlocked-after-01', 0), ('unlocked-reload-01', 0)] if OPEN_PADLOCK else [('regression-before-02', 2), ('marker-after-01', 0), ('marker-reload-02', 0)]
for label, failures in cases:
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
    run = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code'] == 0
    assert log.count('CA234 FAIL ') == failures
    assert f'CA234 DONE failures={failures}' in log
    assert not any(error in log for error in ['Script error', 'VM execution aborted', 'Savegame is from a different level'])
    if failures:
        assert log.count('CA234 FAIL open-marker-is-passage-not-lock') == failures
    run.update(assertions=log.count('CA234 PASS ') + failures, expected_failures=failures)
    report['runs'].append(run)
    for suffix in ['.txt', '-run.json']:
        shutil.copyfile(WORK / (label + suffix), HERE / (label + suffix))
closed, _ = state('marker-closed')
opened, open_record = state('marker-open')
reloaded, reload_record = state('marker-reloaded')
assert len(closed) == len(opened) == 1
assert closed[0]['observedAccess'] == 1 and opened[0]['observedAccess'] == 2
assert {k: v for k, v in closed[0].items() if k != 'observedAccess'} == {k: v for k, v in opened[0].items() if k != 'observedAccess'}
assert opened == reloaded
assert open_record['LocalKnowledgeSerial'] == reload_record['LocalKnowledgeSerial']
report['save_comparisons'] = ['closed/open stable fact except observedAccess', 'open/reloaded facts and knowledge serial']
captures = ['unlocked-after-01-marker-closed.png', 'unlocked-after-01-marker-open.png', 'unlocked-reload-01-marker-reload.png'] if OPEN_PADLOCK else ['marker-after-01-marker-closed.png', 'marker-after-01-marker-open.png', 'marker-reload-02-marker-reload.png']
for capture in captures:
    shutil.copyfile(WORK / capture, HERE / 'captures' / capture)
report['captures'] = captures
report['author_acceptance'] = 'Tracked separately in RESULTS.md and docs/HISTORY.md; native runs do not imply author acceptance.'
(HERE / ('unlocked_evidence.json' if OPEN_PADLOCK else 'marker_evidence.json')).write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print('Open padlock: 43 assertions and 2 save comparisons passed.' if OPEN_PADLOCK else 'Baseline reproduced 2 icon failures; corrected runs passed 43 assertions and 2 save comparisons.')
