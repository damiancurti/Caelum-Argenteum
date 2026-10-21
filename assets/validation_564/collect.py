"""Collect focused death/loot evidence; keep packages, saves and IWADs local."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue384'
BASE = 'a3e25502'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


labels = ['legacy-save-01', 'legacy-ice-save-01', 'ice-upgrade-01',
          'final-probe', 'final-tables', 'final-tables-reload-02',
          'final-upgrade-02', 'final-reload-02', 'final-hub-02',
          'final-original-rollback', 'final-legacy-tables',
          'final-legacy-tables-upgrade', 'final-legacy-tables-rollback',
          'final-current-ice-save', 'final-current-ice-reload', 'final-smoke']
current = WORK / 'current/caelum_argenteum_dev.pk3'
current_hash = sha(current)
runs = []
regressions = []
for label in labels + ['final-baseline-probe', 'legacy-ice-finish-01']:
    log_path = WORK / (label + '.txt')
    record_path = WORK / (label + '-run.json')
    record = json.loads(record_path.read_text(encoding='utf-8-sig'))
    log = log_path.read_text(encoding='utf-8', errors='replace')
    assert not re.search(r'Script error|VM execution aborted', log), label
    assert record['exit_code'] == 0 and not record.get('timed_out'), label
    if record['runtime'] == 'current':
        assert record['package_sha256'].lower() == current_hash, label
    passes = len(re.findall(r'CA384 PASS ', log))
    failures = len(re.findall(r'CA384 FAIL ', log))
    if label in labels:
        assert failures == 0 and (passes > 0 or label == 'final-smoke'), label
        destination = runs
    else:
        assert failures == (4 if label == 'final-baseline-probe' else 1), label
        destination = regressions
    destination.append(dict(label=label, passes=passes, failures=failures,
                            runtime=record['runtime'],
                            package_sha256=record['package_sha256'].lower(),
                            addon_sha256=record['addon_sha256'].lower(),
                            log_sha256=sha(log_path)))
    for path in (log_path, record_path):
        shutil.copy2(path, HERE / path.name)

comparison = WORK / 'baseline/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(comparison) as before, zipfile.ZipFile(current) as after:
    assert set(before.namelist()) == set(after.namelist()), 'Unexpected member change'
    changed = sorted(name for name in after.namelist()
                     if (before.getinfo(name).CRC, before.getinfo(name).file_size)
                     != (after.getinfo(name).CRC, after.getinfo(name).file_size))
    assert changed == ['caelum/actors/CaelumCombatActor.zs',
                       'caelum/world/CaelumPhysicalHazards.zs',
                       'caelum/world/CaelumSewerMaze.zs'], changed
    for name in changed:
        data = (ROOT / 'src' / name).read_bytes()
        assert data.replace(b'\r\n', b'\n') == after.read(name).replace(b'\r\n', b'\n'), name
    # The ordinary builder must produce the same tested members, independently
    # of ZIP timestamps or compression metadata.
    with zipfile.ZipFile(ROOT / 'build/caelum_argenteum_dev.pk3') as built:
        assert set(built.namelist()) == set(after.namelist())
        for name in after.namelist():
            assert (built.getinfo(name).CRC, built.getinfo(name).file_size) == (
                after.getinfo(name).CRC, after.getinfo(name).file_size), name

unchanged_paths = [
    'src/caelum/world/CaelumMazeLootCatalogue.zs',
    'src/caelum/world/CaelumMazeLayout.zs',
    'src/caelum/world/CaelumStashChest.zs',
    'src/caelum/ui/CaelumChestPreview.zs',
    'src/caelum/equipment/CaelumEquipmentPickups.zs',
    'src/caelum/equipment/CaelumInventoryService.zs',
    'src/caelum/actors/CaelumDemonService.zs',
    'src/caelum/actors/CaelumBull.zs',
    'src/caelum/player/CaelumPlayer.zs',
    'src/caelum/equipment/CaelumPersistentCharacterState.zs',
    'src/caelum/quests/CaelumSideQuestRules.zs',
    'src/caelum/dialogue/CaelumPrisonerRescue.zs',
    'assets/generators/generate_map02_maze.py',
]
unchanged = {}
for name in unchanged_paths:
    data = (ROOT / name).read_bytes().replace(b'\r\n', b'\n')
    original = subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
    assert data == original.replace(b'\r\n', b'\n'), name
    unchanged[name] = hashlib.sha256(data).hexdigest()
report = dict(issue=384, release='5.6.4', comparison_commit=BASE,
              runs=runs, expected_baseline_regressions=regressions,
              passing_assertions=sum(run['passes'] for run in runs),
              unexpected_failures=0, final_package_sha256=current_hash,
              comparison_package_sha256=sha(comparison), package_changed_members=changed,
              unchanged_source_sha256_lf=unchanged,
              retained_local_saves={path.name: sha(path) for path in sorted(WORK.glob('ca384-*.zds'))},
              author_acceptance='passed CA384-01 on 2026-10-20; initial startup qualification in HISTORY')
(HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
rows = '\n'.join(f"| {r['label']} | {r['runtime']} | {r['passes']} |" for r in runs)
(HERE / 'RESULTS.md').write_text(f'''# Issue #384 validation - release 5.6.4

The required set passes **{len(runs)} native runs, {report['passing_assertions']}
assertions and zero unexpected failures**. CA384-01 passed author review on 2026-10-20; initial startup qualification is in HISTORY.
Old-code regression runs are separate and reproduce five expected failures.

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
{rows}

## Scope and coverage

The author retained current loot tables and narrowed #384 to one-time delivery.
Only CaelumCombatActor behavior changes; two other runtime members synchronize
release labels. The package comparison permits exactly those three members and
no addition/removal. Actual table, generator, pickup, preview, ownership and quest
sources are unchanged against {BASE}; normalized hashes are in report.json.
No map regeneration, new pool, chance, quantity, refill or property rule is added.

The native DropItem reproducer uses an isolated carrier/token: the campaign has
no current DropItem metadata. Baseline final-baseline-probe reproduces reentrant
OwnerDied/WorldThingDied, repeated Die and repeated unblock (four failures).
The revised probe passes all seven checks. Its pending initialization completes
before killing the actor. The native latch commits before callbacks, survives
resurrection and blocks repeats without replacing native inventory authority.

Actual MAP02 checks reuse #220's accepted carrier cases: potion fallback with
one-unit debit, assigned ammunition at its dry anchor, quest key precedence,
empty/last potion stock, rat ration and repeated callbacks. Current and actual
5.5.8a saves reload correctly; original-pair rollback is separately tested.

The synthetic 5.5.8a save contains a finished nonblocking corpse, a living carrier,
a pending solid corpse and a pending archived corpse. Revision 1 preserves those
distinct entitlements idempotently. A real resurrection/second death does not
refill native loot. Revised claims survive reload and TMAINT -> THAZARD -> TMAINT.
Fixture references are recovered by stable map-local TIDs after travel; carried
inventory pointers to the departed map are not expected to survive.

The old ice save contains both native frozen phases and a previously raised body.
The old package duplicates the raised body's native token; the revised package
preserves remaining tics, migrates each phase without replaying effects and
delivers only the two first-life entitlements. A new-package ice save/reload also
passes. Native chunks remain present; a plain Actor proxy reuses the engine's
visual routine without inventory, conversation or drop metadata. No engine
implementation is copied into the project. No pixel-identical effect claim is made.

Existing chest preview/cancel/capacity/partial collection, recipient sizing,
same-source competing requests, native locks, old looted gaps and non-hub item
travel retain the unchanged paths and applicable #381 evidence in
../validation_562/RESULTS.md. #378 separately checked book storage. This patch
does not claim those old runs were rerun on 5.6.4. Historical 65-entry T1 coverage
is preserved as legacy provenance; #183's material quotas are the current MAP02
budget. Existing Bull/no-leather and quest claim rules are source-reviewed,
unchanged, and are not claimed as a full new campaign replay.

## Reproduction and retained evidence

GZDoom 4.14.2 / Windows 11, Vulkan, 1280x720, 60-FPS cap, sequential sessions,
unpaused background simulation and 5% master audio. Each run JSON records hardware,
driver, hashes, arguments and configuration. These are correctness tests, not
frame-time measurements or author acceptance. No retired stress case was run.
Engine, IWAD, fixture PK3s and saves remain local; report.json records save hashes.

Run python assets/validation_564/prepare.py, then run_native.ps1 with a fresh
-Label and a -Script from prepare.py. Use -Checks for current or -LegacyChecks
with -Runtime legacy (5.5.8a) / baseline (5.6.3b). LoadGame is a filename relative
to build/issue384. Use -ExpectRegression only for the two recorded old-code
failures. Frozen packages are retained beside their synthetic saves. Rollback
means restoring the untouched original save/package pair; backward loading new
frozen-state indices into old code is not promised.

Static validation is recorded in project-validation.json; normal packaging in
build.log. collect.py checks package/source agreement and the exact allowed
runtime diff. Independent read-only review found the native ice bypass and
confirmed the final fix/migration with no remaining P1/P2 findings.

## Exploratory failures and limits

Early fixture kills preceded deferred PostBeginPlay, reinitializing a synthetic
carrier after death. A five-tic setup interval corrected the harness. An initial
action used an ambiguous self type and failed compilation; the explicit actor
cast corrected it. A short MAP02 reload script ended before its queued event;
the final longer script passes and the runner rejects missing completion.
The first hub probe dereferenced a carried pointer cleared on map travel; the
corrected fixture finds the retained local bodies by TID and asserts their claims.
Failed and superseded logs remain under build/issue384 and are excluded from
the required set. No failed production test is counted as passing.

The author returned on 2026-10-20 and the temporary system-awake request
was released without changing the Windows power plan.
New lock/ownership and clothing proposals remain unapproved and separate.
''', encoding='utf-8')
print(json.dumps({'runs': len(runs), 'passes': report['passing_assertions'],
                  'package_sha256': current_hash, 'changed_members': changed}))
