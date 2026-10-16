"""Verify the revised #252 presentation runs without replacing original evidence."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
WORK = ROOT / 'build/issue252-visual-05'
LABELS = ['presentation', 'roof', 'input', 'interruptions', 'save-02',
          'load', 'travel', 'old-load', 'gallery']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


manifest = json.loads((WORK / 'manifest.json').read_text())
repeat = json.loads((ROOT / 'build/issue252-visual-repeat/manifest.json').read_text())
assert manifest == repeat, 'Repeated packages differ.'
assert digest(WORK / 'production.pk3') == manifest['runtime_sha256']
assert digest(WORK / 'seal.pk3') == manifest['fixture_sha256']
runs = []
for label in LABELS:
    record = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
    assert record['exit_code'] == 0, label
    assert not re.search(r'CA252 FAIL|Script error|VM execution aborted|Could not open', log), label
    done = re.search(r'CA252 DONE passes=(\d+) failures=0', log)
    assert done, label
    assert record['runtime_sha256'].lower() == manifest['runtime_sha256']
    assert record['fixture_sha256'].lower() == manifest['fixture_sha256']
    script = Path(record['arguments'][record['arguments'].index('+exec') + 1].strip('"'))
    runs.append({'label': label, 'assertions': int(done[1]), 'exit_code': 0,
                 'log_sha256': digest(WORK / (label + '.txt')),
                 'script_sha256': digest(WORK / script.name),
                 'engine_sha256': record['engine_sha256'].lower()})

source = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
          for p in (ROOT / 'src').rglob('*') if p.is_file()}
for package in [WORK / 'production.pk3', ROOT / 'build/caelum_argenteum_dev.pk3']:
    with ZipFile(package) as archive:
        assert set(archive.namelist()) == set(source), package
        assert all(archive.read(name) == data for name, data in source.items()), package
validation = json.loads((ROOT / 'build/issue252-visual-validation.json').read_text(encoding='utf-16'))
assert not validation['errors'], validation['errors']
images = sorted(WORK.glob('seal-*-*.png'))
assert len(images) == 10
result = {
    'issue': 252, 'version': '5.4.21', 'author_acceptance': 'pending revised CA252-01',
    'implementation_commit': '9ccab64b',
    'runtime_sha256': manifest['runtime_sha256'], 'fixture_sha256': manifest['fixture_sha256'],
    'native_runs': len(runs), 'native_assertions': sum(r['assertions'] for r in runs),
    'runs': runs, 'source_members': len(source), 'static_errors': validation['errors'],
    'normal_package_matches_source': True, 'deterministic_packaging': True,
    'screenshots': {p.name: digest(p) for p in images},
    'prior_save_sha256': digest(WORK / 'pre-visual.zds'),
    'scope': 'Revised ground projection, sprite registration, cosmetic orb and lifecycle. Original unchanged climate evidence remains in evidence.json.',
    'excluded_runs': ['visual-01 compiler probe', 'visual-03 gallery incomplete marker',
                      'visual-04 gallery deferred captures used adjacent camera settings',
                      'visual-05 save missing completion marker; save-02 adds completion wait']}
(HERE / 'presentation_evidence.json').write_text(json.dumps(result, indent=2) + '\n',
                                               encoding='utf-8', newline='\n')
print(json.dumps({k: result[k] for k in ['native_runs', 'native_assertions', 'source_members', 'static_errors']}))
