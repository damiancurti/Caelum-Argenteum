"""Retain exhaustion-wake evidence without bundling engine, IWAD or fixtures."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

here = Path(__file__).resolve().parent
root = here.parents[1]
work = root / 'build/issue502-hygiene'
out = here / 'wake'
labels = [
    'wake-core-final02', 'wake-final-wake-save01', 'wake-load-final02',
    'wake-hub-final02', 'wake-legacy-load-final02', 'wake-rev1-load-final02',
    'wake-live-final03', 'wake-capture-final03', 'clean-core-final03',
    'clean-sleep-final03', 'clean-repair-final03', 'clean-bag-final03',
    'clean-live-final03', 'wake-legacy-seed01', 'wake-legacy-rollback01',
]
package = work / 'wake-final01/caelum_argenteum_dev.pk3'
baseline = work / 'surface-final05/caelum_argenteum_dev.pk3'
digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
final_hash, old_hash = digest(package), digest(baseline)
records = []
(out / 'native').mkdir(parents=True, exist_ok=True)
for label in labels:
    log = (work / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
    record = json.loads((work / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert 'CA502H RESULT' in log, label
    assert not re.search(r'CA502H FAIL|Script error|VM execution aborted|failures=[1-9]', log), label
    assert record['exit_code'] == 0 and not record.get('timed_out'), label
    expected = old_hash if label in ('wake-legacy-seed01', 'wake-legacy-rollback01') else final_hash
    assert record['package_sha256'].lower() == expected, label
    records.append({'label': label, 'passes': len(re.findall(r'^CA502H PASS', log, re.M)),
                    'runtime': record['runtime'], 'package_sha256': expected,
                    'addon_sha256': record['addon_sha256'].lower()})
    for suffix in ('.txt', '-run.json'):
        shutil.copyfile(work / (label + suffix), out / 'native' / (label + suffix))
with zipfile.ZipFile(package) as current, zipfile.ZipFile(baseline) as previous:
    names = current.namelist()
    assert set(names) == {p.relative_to(root / 'src').as_posix() for p in (root / 'src').rglob('*') if p.is_file()}
    for name in names:
        assert current.read(name) == (root / 'src' / name).read_bytes(), name
    changes = [n for n in names if current.read(n) != previous.read(n)]
    assert set(changes) == {'caelum/equipment/CaelumEquipmentCleaning.zs',
                            'caelum/world/CaelumRest.zs', 'caelum/world/CaelumTimeSkipModel.zs'}, changes
    maps = [n for n in names if n.startswith('maps/')]
    art = [n for n in names if n.startswith(('sprites/', 'models/', 'graphics/', 'textures/', 'flats/'))]
    for name in maps + art:
        assert current.read(name) == previous.read(name), name
(out / 'captures').mkdir(exist_ok=True)
for name in ('wake-collapse.png', 'wake-start.png', 'wake-finished.png'):
    shutil.copyfile(work / name, out / 'captures' / name)
report = {
    'issue': 502, 'version': '5.8.12', 'package_sha256': final_hash,
    'baseline_sha256': old_hash, 'source_members': len(names),
    'unchanged_maps': len(maps), 'unchanged_art_members': len(art),
    'production_changes': changes, 'passes': sum(r['passes'] for r in records),
    'runs': records, 'author_test': 'CA502-WAKE-01 pending',
    'save_sha256': {n: digest(work / n) for n in
                    ('ca502w-cleaning.zds', 'ca502w-exhausted.zds', 'ca502h-clean.zds')},
    'limits': [
        'Exhaustion wake hook only; calendar-triggered sleep cleaning remains unfinished.',
        'Immediate collapse and the existing wake lock are retained.',
        'Exact-date forecasts explicitly reject multi-piece wake/sleep queues; ordinary world time remains supported.',
        'Native functional checks and console captures, not multiplayer or campaign-wide presentation performance acceptance.',
        'Earlier passing runs use the same final production bytes; the diagnostic addon gained the live helper and corrected assertions during the suite.',
    ],
    'resolved_fixture_failures': [
        'Probe core01-03: synthetic armor identity did not match ArmorModel; native profile reconciliation removed the invalid reference. Corrected fixture metadata, not gameplay.',
        'Final load01: one Advance call completes one piece, not the full queue. Later clothing had real ambient exposure. Check every queued piece and exact remaining budgets.',
        'Final live02: inherited reset supplies 100g soap, not 10g. Corrected the test threshold and manual instructions.',
    ],
}
(out / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
print(json.dumps({k: report[k] for k in ('passes', 'source_members', 'unchanged_maps', 'unchanged_art_members', 'package_sha256')}, indent=2))
