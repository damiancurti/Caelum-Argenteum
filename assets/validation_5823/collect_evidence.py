"""Collect scoped constant-climate history evidence without counting saved totals."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue410-cooking'
package = WORK / 'final23/caelum_argenteum_dev.pk3'
digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
files = {p.relative_to(ROOT/'src').as_posix(): p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive, zipfile.ZipFile(WORK/'legacy22/caelum_argenteum_dev.pk3') as old:
    assert set(archive.namelist()) == set(files) == set(old.namelist())
    differences = []
    line_endings = []
    unchanged_art = 0
    for name, path in files.items():
        assert archive.read(name) == path.read_bytes(), name
        if old.read(name) != archive.read(name):
            if old.read(name).replace(b'\r\n',b'\n') == archive.read(name).replace(b'\r\n',b'\n'):
                line_endings.append(name)
            else:
                differences.append(name)
        if name.startswith(('maps/', 'models/', 'sprites/', 'graphics/')):
            assert old.read(name) == archive.read(name), name
            unchanged_art += 1
    assert set(differences) == {
        'caelum/survival/CaelumContaminationObject.zs',
        'caelum/survival/CaelumContaminationState.zs',
        'caelum/world/CaelumPhysicalHazards.zs',
        'caelum/world/CaelumSewerMaze.zs',
    }, differences
    assert set(line_endings) == {'caelum/data/CaelumMansionBathroomData.zs', 'caelum/world/CaelumMansionBathrooms.zs'}, line_endings
report = {
    'issue': 502, 'version': '5.8.23', 'runtime_sha256': digest(package),
    'source_matching_members': len(files), 'unchanged_map_art_members': unchanged_art,
    'previous_runtime_sha256': digest(WORK/'legacy22/caelum_argenteum_dev.pk3'),
    'changed_runtime_members': differences, 'native_passes': 0, 'native_failures': 0,
    'checkout_line_endings_only': line_endings,
    'runs': [], 'author_check': 'CA502-LIMBO-HISTORY-01', 'author_acceptance': 'pending',
}
native = HERE/'native'
native.mkdir(exist_ok=True)
runs = [(WORK, name, 'H') for name in (
    'history-final-core', 'history-final-hub', 'history-final-oldload',
    'history-final-seed', 'history-final-load', 'history-final-manual3',
    'history-oldseed22', 'history-rollback22')]
runs.append((ROOT/'build/issue502-scenery', 'history-regression', 'O'))
for folder, label, kind in runs:
    log = (folder/(label+'.txt')).read_text(encoding='utf-8-sig')
    record = json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    count = len(re.findall(r'^CA502'+kind+r' PASS ', log, re.M))
    assert count and 'CA502'+kind+' RESULT' in log, label
    assert not re.search(r'CA502[HO] FAIL|Script error|VM execution aborted|Fatal:|fail(?:ed|ures)=[1-9]', log), label
    assert record.get('exit_code') == 0 and not record.get('timed_out'), label
    expected = report['previous_runtime_sha256'] if label in ('history-oldseed22', 'history-rollback22') else report['runtime_sha256']
    assert record['package_sha256'].lower() == expected, label
    report['native_passes'] += count
    report['runs'].append({'label': label, 'executed_passes': count, 'runtime_sha256': expected})
    for suffix in ('.txt', '-run.json'):
        shutil.copy2(folder/(label+suffix), native/(label+suffix))
static_bytes = (WORK/'static-5823.json').read_bytes()
static = json.loads(static_bytes.decode('utf-16' if static_bytes.startswith(b'\xff\xfe') else 'utf-8-sig'))
assert not static['errors'], static['errors']
report['static_errors'] = 0
(HERE/'static-validation.json').write_text(json.dumps(static, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
report['performance'] = []
for label in ('history-perf-base', 'history-perf-final'):
    folder = ROOT/'build/issue502-hygiene'
    timing = json.loads((folder/(label+'.json')).read_text())
    expected = report['runtime_sha256'] if label.endswith('final') else report['previous_runtime_sha256']
    assert timing['runtime_sha256'] == expected
    assert timing['receivers_exposed'] == timing['spawned_objects'] == 1000
    report['performance'].append(timing)
    for suffix in ('.json', '.txt', '-presentmon.txt'):
        shutil.copy2(folder/(label+suffix), native/(label+suffix))
report['save_sha256'] = {name: digest(WORK/name) for name in ('history-legacy22.zds', 'history-current23.zds')}
(HERE/'captures').mkdir(exist_ok=True)
for name in ('history-author-before3.png', 'history-author-final3.png'):
    shutil.copy2(WORK/name, HERE/'captures'/name)
(HERE/'report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ('runs', 'performance')}))
