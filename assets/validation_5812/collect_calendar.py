"""Retain calendar-sleep evidence without bundling engine, IWAD or fixtures."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

here = Path(__file__).resolve().parent
root = here.parents[1]
work = root / 'build/issue502-hygiene'
out = here / 'calendar'
cases = ['calendar-core','calendar-edges','calendar-forecast','calendar-save',
         'calendar-load','calendar-hub','calendar-live','calendar-accelerated',
         'calendar-legacy-load','clean-core','clean-sleep',
         'clean-repair','clean-bag','clean-live','wake-core','wake-load','wake-hub']
labels = ['calendar-suite-'+case+'-01' for case in cases]
labels += ['calendar-legacy-save01','calendar-legacy-rollback01',
           'calendar-suite-calendar-existing-save-01','calendar-suite-calendar-existing-load-01',
           'calendar-suite-calendar-capture-02']
package = work / 'calendar-final01/caelum_argenteum_dev.pk3'
baseline = work / 'wake-final01/caelum_argenteum_dev.pk3'
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
    expected = old_hash if label in ('calendar-legacy-save01', 'calendar-legacy-rollback01') else final_hash
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
    maps = [n for n in names if n.startswith('maps/')]
    art = [n for n in names if n.startswith(('sprites/', 'models/', 'graphics/', 'textures/', 'flats/'))]
    for name in maps + art:
        assert current.read(name) == previous.read(name), name
(out / 'captures').mkdir(exist_ok=True)
for name in ('calendar-preparing.png', 'calendar-sleeping.png', 'calendar-resumed.png'):
    shutil.copyfile(work / name, out / 'captures' / name)
report = {
    'issue': 502, 'version': '5.8.12', 'package_sha256': final_hash,
    'baseline_sha256': old_hash, 'source_members': len(names),
    'unchanged_maps': len(maps), 'unchanged_art_members': len(art),
    'production_changes': changes, 'passes': sum(r['passes'] for r in records),
    'runs': records, 'author_test': 'CA502-CALENDAR-01 pending',
    'save_sha256': {n: digest(work / n) for n in
                    ('ca502c-calendar.zds', 'ca502c-legacy.zds', 'ca502c-existing.zds', 'ca502w-cleaning.zds')},
    'limits': [
        'Seeded actual crafting/reading tasks exercise pause, identity, reservations and resumption; not full recipe acquisition UI.',
        'Ordinary-clock fixture holds acceleration for observability; accelerated destination is independently exercised.',
        'Unsupported exact-date forecasts stop explicitly instead of advertising an inaccurate completion time.',
        'Functional native checks and inspected captures do not establish multiplayer or campaign-wide presentation performance acceptance.',
        'Production package bytes are identical to calendar-probe02; all final gameplay tests use calendar-final01.',
    ],
    'resolved_probes': [
        'Live01/02/04/05 exposed fatigue health loss cancelling pre-sleep cleaning. Production now accounts this existing loss as periodic during preparation only; damage still occurs. Live06 and final suite pass.',
        'Live03 diagnostic printed incompatible name/string ternary; corrected fixture types.',
        'Edges01 used the DetachFromOwner callback as removal. The final fixture uses native RemoveInventory and checks foreign ownership.',
        'Accelerated01 checked craft work after waiting additional real seconds beyond calendar completion. Final fixture observes the exact completion boundary; subsequent real-time work correctly resumes.',
    ],
}
(out / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
print(json.dumps({k: report[k] for k in ('passes', 'source_members', 'unchanged_maps', 'unchanged_art_members', 'package_sha256')}, indent=2))
