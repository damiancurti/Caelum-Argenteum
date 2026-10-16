"""Record final Seal depth evidence while retaining earlier runtime evidence."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
WORK = ROOT / 'build/issue252-depth-02'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


manifest = json.loads((WORK / 'manifest.json').read_text())
repeat = json.loads((ROOT / 'build/issue252-depth-repeat/manifest.json').read_text())
assert manifest == repeat
runs = []
images = {}
for directory, labels in [('issue252-depth-01', ['gallery']),
                          ('issue252-depth-02', ['presentation', 'old-load', 'depth'])]:
    work = ROOT / 'build' / directory
    local = json.loads((work / 'manifest.json').read_text())
    assert digest(work / 'production.pk3') == manifest['runtime_sha256']
    assert digest(work / 'seal.pk3') == local['fixture_sha256']
    for label in labels:
        record = json.loads((work / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        log = (work / (label + '.txt')).read_text(encoding='utf-8-sig')
        assert record['exit_code'] == 0
        assert not re.search(r'CA252 FAIL|Script error|VM execution aborted|Could not open', log)
        done = re.search(r'CA252 DONE passes=(\d+) failures=0', log)
        assert done
        assert record['runtime_sha256'].lower() == manifest['runtime_sha256']
        assert record['fixture_sha256'].lower() == local['fixture_sha256']
        script = Path(record['arguments'][record['arguments'].index('+exec') + 1].strip('"'))
        runs.append({'directory': directory, 'label': label, 'assertions': int(done[1]),
                     'exit_code': 0, 'fixture_sha256': local['fixture_sha256'],
                     'log_sha256': digest(work / (label + '.txt')),
                     'script_sha256': digest(work / script.name),
                     'engine_sha256': record['engine_sha256'].lower()})
    for path in work.glob('*.png'):
        images[directory + '/' + path.name] = digest(path)

source = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
          for p in (ROOT / 'src').rglob('*') if p.is_file()}
for package in [WORK / 'production.pk3', ROOT / 'build/caelum_argenteum_dev.pk3']:
    with ZipFile(package) as archive:
        assert set(archive.namelist()) == set(source)
        assert all(archive.read(name) == data for name, data in source.items())
validation = json.loads((ROOT / 'build/issue252-depth-validation.json').read_text(encoding='utf-16'))
assert not validation['errors'], validation['errors']
assert len(images) == 18
result = {
    'issue': 252, 'version': '5.4.21', 'runtime_sha256': manifest['runtime_sha256'],
    'fixture_sha256': manifest['fixture_sha256'], 'runs': runs,
    'native_runs': len(runs), 'native_assertions': sum(r['assertions'] for r in runs),
    'screenshots': images, 'source_members': len(source),
    'static_errors': validation['errors'], 'normal_package_matches_source': True,
    'deterministic_packaging': True, 'prior_save_sha256': digest(WORK / 'pre-depth.zds'),
    'author_acceptance': {'id': 'CA252-01', 'origin': '5.4.21 / #252',
                          'date': '2026-10-15', 'result': 'accepted',
                          'quote': 'Ahora si la prueba dio correcto, queda aprobada.'},
    'scope': 'Cosmetic transparent-sprite depth tie correction. Earlier gameplay and orb evidence retain their original runtime hashes.'}
(HERE / 'depth_evidence.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
print(json.dumps({k: result[k] for k in ['native_runs', 'native_assertions', 'source_members', 'static_errors']}))
