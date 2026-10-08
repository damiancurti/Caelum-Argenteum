"""Check actual native save contents, without distributing private save fixtures."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue132'
HERE = Path(__file__).resolve().parent

def read(name):
    actual = 'final-'+name if name in ('pending-group','pending-reloaded','terminal-reloaded') else name
    path = OUT / (actual+'.zds')
    with zipfile.ZipFile(path) as z:
        objects = json.loads(z.read('map06.map.json'))['objects']
    return objects, hashlib.sha256(path.read_bytes()).hexdigest()

def objects_of(objects, kind):
    return [o for o in objects if o.get('classtype') == kind]

def fields(obj, kind):
    return {k.lower(): v for k, v in obj['class:'+kind].items()}

def controller(objects):
    found = objects_of(objects, 'CaelumSiegeReinforcements')
    return fields(found[0], 'CaelumSiegeReinforcements') if found else None

names = ['pending-group', 'pending-reloaded', 'terminal-reloaded', 'original-full-army',
         'upgraded-full-army', 'rollback-full-army', 'staged-cadence', 'staged-reloaded',
         'staged-next', 'staged-hub']
data = {n: read(n) for n in names}
results = {'checks': [], 'saves': {n: {'sha256': value[1]} for n, value in data.items()}}

def check(condition, text):
    assert condition, text
    results['checks'].append(text)

pending = controller(data['pending-group'][0])
reload = controller(data['pending-reloaded'][0])
for key in ['revision', 'pending', 'remaining', 'enabled', 'successful', 'living', 'groupstart',
            'nextopportunity', 'placementcursor', 'placementfailures', 'opportunities', 'placed', 'stopped']:
    check(pending[key] == reload[key], 'Partial-group load preserves '+key)
check(sum(pending['placed']) == 50 and pending['pending'] == 50, 'Exactly 50 successful and 50 pending slots')
check(pending['nextopportunity'] == 755, 'Deadline remains 755, not load time plus cadence')
terminal = controller(data['terminal-reloaded'][0])
check(terminal['successful'] == 2300 and terminal['remaining'] == 3700 and terminal['stopped'],
      'Reloaded partial group completes and legitimate terminal state stops reserves')

original = data['original-full-army'][0]
for name in ['upgraded-full-army', 'rollback-full-army']:
    current = data[name][0]
    for kind, expected in [('CaelumMandinga', 6000), ('CaelumPortCommander', 1), ('CaelumPortDefender', 600)]:
        old_bodies, new_bodies = objects_of(original, kind), objects_of(current, kind)
        check(len(old_bodies) == len(new_bodies) == expected, name+' preserves '+kind+' population')
        check(sorted(o.get('spawnorder', 0) for o in old_bodies) == sorted(o.get('spawnorder', 0) for o in new_bodies),
              name+' preserves native '+kind+' identities')
    before = [fields(o, 'CaelumSiegeCombatant') for o in objects_of(original, 'CaelumSiegeCombatant')]
    after = [fields(o, 'CaelumSiegeCombatant') for o in objects_of(current, 'CaelumSiegeCombatant')]
    check(sorted(e['stableidentity'] for e in before) == sorted(e['stableidentity'] for e in after),
          name+' preserves all 6001 roster identities')
    check(sum(e.get('crewmachine') is not None for e in before) == sum(e.get('crewmachine') is not None for e in after) == 74,
          name+' preserves 74 initial crew assignments')
upgraded = controller(data['upgraded-full-army'][0])
check(upgraded['revision'] == 1 and not upgraded['enabled'] and upgraded['successful'] == 6000
      and upgraded['remaining'] == 0 and upgraded['opportunities'] == 0, 'Old army migrates once into disabled controller')
check(controller(data['rollback-full-army'][0]) is None, 'Untouched original save loads in original package without new schema')

staged = controller(data['staged-cadence'][0])
for name in ['staged-reloaded', 'staged-hub']:
    current = controller(data[name][0])
    for key in ['successful', 'remaining', 'pending', 'groupstart', 'nextopportunity', 'placementcursor', 'opportunities', 'placed']:
        check(staged[key] == current[key], name+' preserves '+key)
next_group = controller(data['staged-next'][0])
check(next_group['successful'] == staged['successful'] + 100 and next_group['remaining'] == staged['remaining'] - 100,
      'Loaded cadence creates exactly one next group')
check(next_group['nextopportunity'] == staged['nextopportunity'] + 350, 'Loaded cadence keeps original phase')
for name, (objects, _) in data.items():
    r = controller(objects)
    if r:
        results['saves'][name]['controller'] = {k: v for k, v in r.items() if k != 'initialcrew'}
results['count'] = len(results['checks'])
(HERE/'SAVE_VERIFICATION.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
print(f"Native save comparisons passed: {results['count']}")
