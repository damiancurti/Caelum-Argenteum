"""Collect focused issue #378 evidence without distributing runtime fixtures."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue378'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


labels = ['legacy-save-05', 'final-rollback', 'verified-time',
          'verified-mansion-time', 'verified-suite', 'verified-craft',
          'verified-save', 'verified-reload', 'verified-travel',
          'verified-mansion', 'verified-upgrade', 'verified-upgraded-reload',
          'verified-ui-02', 'verified-smoke', 'verified-sources']
current = WORK / 'current/caelum_argenteum_dev.pk3'
current_hash = sha(current)
runs = []
for label in labels:
    log_path = WORK / (label + '.txt')
    record_path = WORK / (label + '-run.json')
    record = json.loads(record_path.read_text(encoding='utf-8-sig'))
    log = log_path.read_text(encoding='utf-8', errors='replace')
    failures = re.findall(r'CA378 FAIL|Script error|VM execution aborted', log)
    assert not failures and record['exit_code'] == 0 and not record.get('timed_out'), label
    if record['runtime'] == 'current':
        assert record['package_sha256'].lower() == current_hash, label
    count = len(re.findall(r'CA378 PASS ', log))
    runs.append(dict(label=label, passes=count, runtime=record['runtime'],
                     package_sha256=record['package_sha256'].lower(),
                     addon_sha256=record['addon_sha256'].lower(), log_sha256=sha(log_path)))
    for path in (log_path, record_path):
        shutil.copy2(path, HERE / path.name)

comparison = ROOT / 'build/issue381/current/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(comparison) as before, zipfile.ZipFile(current) as after:
    old, new = set(before.namelist()), set(after.namelist())
    assert not old - new, 'Unexpected packaged removal'
    changed = sorted(name for name in new if name not in old
                     or before.getinfo(name).CRC != after.getinfo(name).CRC
                     or before.getinfo(name).file_size != after.getinfo(name).file_size)
    for name in changed:
        data = (ROOT / 'src' / name).read_bytes()
        assert data.replace(b'\r\n', b'\n') == after.read(name).replace(b'\r\n', b'\n'), name

outputs = [ROOT / 'src/models/caelum/props/reading/ca_reading_shelf.obj',
           ROOT / 'src/caelum/world/CaelumReadingFurnitureData.zs']
first = [sha(path) for path in outputs]
for _ in range(2):
    subprocess.run(['python', 'assets/generators/generate_reading_shelf.py'], cwd=ROOT, check=True,
                   capture_output=True)
    assert [sha(path) for path in outputs] == first, 'Generator is not deterministic'
images = {}
for name in ['recipe-en.png', 'recipe-es.png', 'shelf.png']:
    shutil.copy2(WORK / name, HERE / name)
    images[name] = sha(HERE / name)
report = dict(issue=378, release='5.6.3', runs=runs,
              passing_assertions=sum(run['passes'] for run in runs), unexpected_failures=0,
              final_package_sha256=current_hash, comparison_package_562_sha256=sha(comparison),
              package_changed_members=changed,
              deterministic_outputs={str(path.relative_to(ROOT)): sha(path) for path in outputs},
              retained_local_saves={path.name: sha(path) for path in sorted(WORK.glob('ca378-*.zds'))},
              images=images, author_acceptance='pending CA378-01')
(HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
rows = '\n'.join(f"| {run['label']} | {run['runtime']} | {run['passes']} |" for run in runs)
(HERE / 'RESULTS.md').write_text(f'''# Issue #378 validation - release 5.6.3

The final recipe runtime passes **{len(runs)} native runs, {report['passing_assertions']}
assertions and zero failures**. CA378-01 awaits author acceptance.

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
{rows}

## Scope and evidence

GZDoom 4.14.2 / Windows 11, Vulkan, 1280x720, 60-FPS limit, unpaused background
simulation and 5% master audio. Runs are sequential. Each run JSON records the
hardware, driver, engine/IWAD/package/addon hashes, arguments and configuration.
No engine, IWAD, fixture PK3 or save is distributed. The comparison against 5.6.2
records every changed package member with no removal; changed bytes match source
after newline normalization. The bookshelf generator reproduces both outputs
byte for byte on two runs. Static validation is in project-validation.json.

The suite covers the exact time formula/caps, independent tiers, unknown previews,
fixed-batch and rounded proportional alloy normalization, deferred source delivery
and capacity retry, first-book/page mass, duplicate sources, Intelligence M3,
first learning/component closure, reread progress and faster rereads, retained
pages, chest deposit/withdrawal, native reusable Use, lost-book cleanup and
preservation of the crafting selection and frozen task duration. Personal time
steps advance reading once, pause closed reading and reject simultaneous work.

Actual native crafts cover equipment, ammunition batches and partial component
stock with recursively made bronze/points. Successful outputs alone grant practice;
cancel/repeated completion do not. Tests exercise existing x105 and date skip,
sleep pauses, thermal forecast rejection and a valid forecast's real execution.
Both TMAINT and MAP01 reach the rounded target date with CA_SKIP_COMPLETE after
reading finishes; the Limbo anchor is retained through the final partial minute.

A real 5.5.8a synthetic save preserves known/unknown recipes, gains sheets and
zero progress through revision 1, then reloads idempotently. A revised paused
reading retains book identity/pages/mass and frozen duration through reload and
TMAINT -> THAZARD -> TMAINT -> MAP02. Original-package/original-save rollback is
verified; backward loading a revised save into 5.5.8a is not claimed. Original
and revised pairs remain local, with save hashes in report.json.

Native checks establish one fitting bookshelf at the authored opposite-room
position and idempotent installation. English/Spanish menu and shelf captures
are retained for visual review. Manual mouse/keyboard feel and campaign NPC
interaction remain the author's CA378-01 review, not automated acceptance.
Native source checks exercise Ronnie/Caella eligibility rejection, confirmed
sheet receipt, duplicate handling and no premature learning/quest progress.
These call existing helpers with a controlled speaker context; no broad tutorial replay or
multiplayer synchronization claim is made. Library commercial integration is #383.

## Review and exploratory failures

Independent review found and corrected processing-tier canonicalization, lost-book
task cleanup, duplicate-book pickup, chosen-node restoration, rounded alloy time,
reading/crafting arbitration and the Limbo post-completion skip anchor. The
final checks include those regressions. Early suite-02 failed to compile the
fixture's nested generic spelling; corrected spacing is used in all final runs.
Early time-advance assertions expected a forecast while the fixture still had
thermal exposure. The corrected fixture explicitly tests that rejection and
clears only its synthetic exposure before testing successful execution. Earlier
logs remain under build/issue378 and are excluded from passing totals. No failed
production test is silently counted as a pass.

The native checks establish behavior, not sustained performance or campaign
playability. No retired large-battle stress scenario was run. Temporary keep-awake
was released after the first return; a second explicitly requested thread-scoped
request is active during the new absence. No power plan was modified.
''', encoding='utf-8')
print(json.dumps({'runs': len(runs), 'passes': report['passing_assertions'],
                  'changed_members': len(changed), 'package_sha256': current_hash}))
