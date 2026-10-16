"""Verify frozen #282 runs, package parity and rendered capture identities."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import importlib.util
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
WORK = ROOT / 'build/issue282-final-06'
LEGACY = ROOT / 'build/issue282-final-04'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(work, label):
    record = json.loads((work / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    log = (work / (label + '.txt')).read_text(encoding='utf-8-sig')
    assert record['exit_code'] == 0
    assert not re.search(r'CA282 FAIL|Script error|VM execution aborted|Could not open|This savegame needs', log)
    done = re.search(r'CA282 DONE passes=(\d+) failures=0', log)
    assert done
    arguments = record['arguments']
    script = Path(arguments[arguments.index('+exec') + 1].strip('"'))
    return {'directory': work.name, 'label': label, 'assertions': int(done[1]),
            'exit_code': 0, 'runtime_sha256': record['runtime_sha256'].lower(),
            'fixture_sha256': record['fixture_sha256'].lower(),
            'engine_sha256': record['engine_sha256'].lower(),
            'log_sha256': digest(work / (label + '.txt')),
            'commands_sha256': digest(script)}


manifest = json.loads((WORK / 'manifest.json').read_text())
labels = ['probe', 'input', 'transfers', 'save', 'load', 'travel', 'legacy-load',
          'spanish43', 'english169', 'scaled-water', 'unbound']
runs = [run(WORK, label) for label in labels]
assert all(r['runtime_sha256'] == manifest['runtime_sha256'] for r in runs)
assert all(r['fixture_sha256'] == manifest['fixture_sha256'] for r in runs)
assert digest(WORK / 'production.pk3') == manifest['runtime_sha256']
assert digest(WORK / 'quick.pk3') == digest(WORK / 'migration/legacy.pk3') == manifest['fixture_sha256']
legacy = run(LEGACY, 'legacy-save')
old_manifest = json.loads((LEGACY / 'manifest.json').read_text())
assert legacy['runtime_sha256'] == old_manifest['legacy_runtime_sha256']
assert legacy['fixture_sha256'] == old_manifest['legacy_fixture_sha256']
assert digest(WORK / 'legacy.zds') == digest(LEGACY / 'legacy.zds')

source = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
          for p in (ROOT / 'src').rglob('*') if p.is_file()}
for package in [WORK / 'production.pk3', ROOT / 'build/caelum_argenteum_dev.pk3']:
    with ZipFile(package) as archive:
        assert set(archive.namelist()) == set(source)
        assert all(archive.read(name) == data for name, data in source.items())
spec = importlib.util.spec_from_file_location('preparation', HERE / 'prepare.py')
preparation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preparation)
with ZipFile(WORK / 'quick.pk3') as archive:
    repeated = preparation.seal.shared.package(WORK / 'quick-repeat.pk3',
                                               {n: archive.read(n) for n in archive.namelist()})
assert repeated == manifest['fixture_sha256']
validation = json.loads((ROOT / 'build/issue282-validation-final2.json').read_text(encoding='utf-16'))
assert not validation['errors'], validation['errors']
captures = {p.name: {'sha256': digest(p), 'pixels': struct.unpack('>II', p.read_bytes()[16:24])}
            for p in WORK.glob('*-quick-*.png')}
assert len(captures) == 4
result = {'issue': 282, 'version': '5.4.22', **manifest,
          'source_members': len(source), 'normal_package_matches_source': True,
          'deterministic_fixture_packaging': True, 'static_errors': validation['errors'],
          'runs': runs, 'native_runs': len(runs),
          'native_assertions': sum(r['assertions'] for r in runs),
          'previous_runtime_seed': legacy, 'old_save_sha256': digest(WORK / 'legacy.zds'),
          'current_save_sha256': digest(WORK / 'quick.zds'), 'captures': captures,
          'author_acceptance': 'pending CA282-01; author requested deferral while away',
          'scope': 'Isolated inventory commands, real transfers, save/load/hub, old-save reconciliation and four rendered HUD checks; physical input/campaign/multiplayer acceptance not claimed.'}
(HERE / 'evidence.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
print(json.dumps({k: result[k] for k in ['native_runs', 'native_assertions', 'source_members', 'static_errors']}))
