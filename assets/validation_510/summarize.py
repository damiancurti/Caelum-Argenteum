"""Summarize retained #130 native evidence and inspect saves without modifying them."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue130'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def saved_objects(name):
    path = WORK / f'ca130_rich{name}.zds'
    with zipfile.ZipFile(path) as package:
        return json.loads(package.read('qa130a.map.json'))['objects']


def saved_class(name, kind):
    return next(obj for obj in saved_objects(name) if obj['classtype'] == kind)


def main():
    labels = ['final-math-b', 'final-geometry', 'delivery-effects-d', 'final-live',
              'final-limbo-b', 'delivery-build', 'final-ui-enu', 'final-ui-esp',
              'final-save-baseline', 'final-save-upgrade-b', 'final-save-control',
              'final-save-current', 'final-save-hub', 'final-save-rollback',
              'final-save-reupgrade', 'final-perf-a', 'final-perf-baseline',
              'final-perf-b', 'final-stress']
    runs = []
    for label in labels:
        record = read_json(HERE / f'{label}-run.json')
        log = (HERE / f'{label}.txt').read_text(encoding='utf-8-sig')
        assert not re.search(r'CA130 FAIL|VM execution aborted|Script error,|DIED WITH FATAL ERROR', log), label
        assert re.search(record['expected'], log), label
        completed = re.search(r'CA130 COMPLETE checks=(\d+) failures=(\d+)', log)
        runs.append(dict(label=label, package_sha256=record['package_sha256'].lower(),
                         addon_sha256=record['addon_sha256'].lower(),
                         checks=int(completed[1]) if completed else None,
                         failures=int(completed[2]) if completed else 0,
                         log_sha256=sha(HERE / f'{label}.txt'),
                         config_sha256=sha(HERE / f'{label}.ini')))

    performance = []
    for label in ['perf-baseline-a', 'perf-current-a', 'perf-cache-a', 'perf-cache-b',
                  'final-perf-a', 'final-perf-baseline', 'final-perf-b', 'final-stress']:
        log = (HERE / f'{label}.txt').read_text(encoding='utf-8-sig')
        rows = {int(tic): float(ms) for tic, ms in re.findall(r'CA130 PERF tic=(\d+) ms=([\d.]+)', log)}
        record = read_json(HERE / f'{label}-run.json')
        performance.append(dict(label=label, interval=[105, 700], tics=595,
                                elapsed_ms=rows[700]-rows[105],
                                tics_per_second=595000/(rows[700]-rows[105]),
                                package_sha256=record['package_sha256'].lower()))

    record_key = 'class:CaelumPersistentCharacterState'
    old = saved_class('control', 'CaelumPersistentCharacterState')[record_key]
    new = saved_class('upgraded', 'CaelumPersistentCharacterState')[record_key]
    changes = [key for key in old if old[key] != new.get(key)]
    assert not changes, changes
    resources = ['CurrentAir', 'CurrentThirst', 'CurrentHunger', 'CurrentSleep', 'ActiveWeaponItemId']
    old_player = saved_class('control', 'CaelumPlayer')['class:CaelumPlayer']
    new_player = saved_class('upgraded', 'CaelumPlayer')['class:CaelumPlayer']
    assert all(old_player[key] == new_player[key] for key in resources)
    old_item = saved_class('control', 'CaelumWeaponPickup')['class:CaelumEquipmentItem']
    new_item = saved_class('upgraded', 'CaelumWeaponPickup')['class:CaelumEquipmentItem']
    assert all(old_item[key] == new_item[key] for key in ['ItemId', 'itemtype', 'Durability'])
    thermal_key = 'class:CaelumThermalState'
    current = saved_class('current', 'CaelumThermalState')[thermal_key]
    rollback = saved_class('rollback', 'CaelumThermalState')[thermal_key]
    personal = ['Exposure', 'Acclimation', 'ActivityWatts', 'DamageRemainder', 'BaseWaterKg', 'ActorWaterKg']
    assert all(current[key] == rollback[key] for key in personal)
    for name in ['reloaded', 'hub']:
        assert saved_class(name, 'CaelumThermalState')[thermal_key]['DamageRemainder'] == 0.3125
        record = saved_class(name, 'CaelumPersistentCharacterState')[record_key]
        assert record['QuestObjectiveProgress'][0] == 7 and record['QuestRewardClaimed'][0]
    saves = {name: sha(WORK / f'ca130_rich{name}.zds') for name in
             ['baseline', 'control', 'upgraded', 'current', 'rollback', 'reloaded', 'hub']}

    with zipfile.ZipFile(WORK/'pre-version-labels.pk3') as before, zipfile.ZipFile(WORK/'production.pk3') as after:
        assert set(before.namelist()) == set(after.namelist())
        differences = [name for name in before.namelist() if before.read(name) != after.read(name)]
        assert sorted(differences) == ['caelum/world/CaelumPhysicalHazards.zs', 'caelum/world/CaelumSewerMaze.zs']
        assert all(before.read(name).replace(b'\r\n', b'\n').replace(b'5.0.6', b'5.1.0') == after.read(name).replace(b'\r\n', b'\n') for name in differences)
    with zipfile.ZipFile(WORK/'production.pk3') as fixture, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as standard:
        assert set(fixture.namelist()) == set(standard.namelist())
        assert all(fixture.read(name) == standard.read(name) for name in fixture.namelist())

    validation = subprocess.run(['python', 'validate_project.py'], cwd=ROOT, capture_output=True, text=True, check=True)
    static = json.loads(validation.stdout)
    (HERE/'STATIC_VALIDATION.json').write_text(json.dumps(static, indent=2)+'\n', encoding='utf-8')
    manifest = read_json(WORK/'MANIFEST.json')
    (HERE/'MANIFEST.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    rollback_manifest = read_json(WORK/'ROLLBACK_MANIFEST.json')
    (HERE/'ROLLBACK_MANIFEST.json').write_text(json.dumps(rollback_manifest, indent=2)+'\n', encoding='utf-8')
    result = dict(
        issue=130, release='5.1.0', status='implemented and agent-verified; author acceptance pending',
        baseline_commit='45f16371d49c38894e6d256d32d8101d4b06cd4c',
        engine='GZDoom 4.14.2', settings='Windows/Vulkan, 1280x720, cap 60, RNG 116, 5% volume, background unpaused',
        production_sha256=manifest['production_sha256'], standard_build_sha256=sha(ROOT/'build/caelum_argenteum_dev.pk3'),
        standard_build_members_identical=True, post_functional_changes='Only diagnostic release strings and line endings in '+', '.join(differences),
        runs=runs, performance=performance,
        performance_scope='Short MAP06 arrival, not late battle or sustained FPS; current observer also aggregates thermal state once per second.',
        army='6001 attackers + 600 defenders; full normal high-density AI. Seeded stress ends with 6597 supported surviving NPCs in harmful cold.',
        persistence=dict(prior_record_fields_checked=len(old), changed_prior_fields=changes,
                         unchanged_resources=resources, unchanged_weapon_fields=['ItemId','itemtype','Durability'],
                         rollback_preserved=personal, hub_fraction=0.3125, quest_progress=7,
                         source_saves_modified=False, save_fingerprints=saves,
                         limitations='Controlled seeded inventory/quest fixture, not every historical author save; retain originals and map-addon basenames.'),
        drying='DRYING_CALIBRATION.json; coupled native drying checks pass at 3600/7200/10800/18000 world seconds.',
        visual_review=['thermal-ui-enu.png', 'thermal-ui-es.png'],
        qualifications=[
            'Intermediate logs retain earlier partial builds, including superseded activity/drying contracts; final run list takes precedence.',
            'Native shield test explicitly sets durability multiplier and a guaranteed-breaking 2000-HP input; delivered thermal energy is 32.5 J from 100 J through 50% shield and 35% gear defense.',
            'Failed local fixtures were corrected: shield 1000-HP input did not guarantee durability loss, Limbo civil time must be queried through calendar anchors, and -loadgame resolves relative to engine workdir.',
            'Formula, seeded engine, visual inspection and author acceptance are distinct evidence levels.',
            'No decorative fire rating or new hot/cold consumable invented; service/source hooks tested with isolated fixtures.',
            'Irregular shelters, combined knockback/support motion, exceptional locomotion speeds and species moisture capacities remain documented approximations.',
            'Full network multiplayer and every late-battle frame regime are not established by these tests.'
        ], pending_author_checks=['CA130-01','CA130-02','CA130-03'],
        power_requests=[read_json(WORK/name) for name in ['power-request.json','power-request-renewed.json']])
    (HERE/'RESULTS.json').write_text(json.dumps(result, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    print(json.dumps(dict(runs=len(runs), prior_fields=len(old), save_checks='passed', static_errors=static['errors']), indent=2))


if __name__ == '__main__':
    main()
