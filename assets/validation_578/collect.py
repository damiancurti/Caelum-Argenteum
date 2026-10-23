"""Verify source/package identity and collect only #479 model evidence."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue479'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

package = WORK / 'current/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as archive:
    sources = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
    assert set(archive.namelist()) == set(sources), 'Package membership differs from src'
    for name, path in sources.items():
        assert archive.read(name) == path.read_bytes(), name

fixture_hashes = [digest(WORK / 'fixture.pk3')]
subprocess.run([sys.executable, str(HERE / 'prepare.py')], check=True)
fixture_hashes.append(digest(WORK / 'fixture.pk3'))
assert len(set(fixture_hashes)) == 1, 'Fixture output is not deterministic'

runs = []
for label in ('model-02', 'final-save', 'final-load'):
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8', errors='replace')
    meta = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert meta['exit_code'] == 0 and 'CA479 FAIL' not in log, label
    assert meta['package_sha256'].lower() == digest(package), label
    assert meta['addon_sha256'].lower() == fixture_hashes[0], label
    for suffix in ('.txt', '-run.json'):
        destination = HERE / 'native' / (label + suffix)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(WORK / (label + suffix), destination)
    runs.append({'label': label, 'pass': len(re.findall(r'^CA479 PASS ', log, re.M)), 'fail': 0, 'exit_code': 0})

diagnostic = HERE / 'diagnostics/model-01.txt'
diagnostic.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(WORK / 'model-01.txt', diagnostic)
report = {
    'issue': 479, 'release': '5.7.8', 'date': '2026-10-22',
    'status': 'partial foundation; not integrated into gameplay',
    'package_sha256': digest(package), 'source_entries': len(sources), 'source_bytes_match': True,
    'fixture_sha256': fixture_hashes[0], 'fixture_deterministic': True, 'runs': runs,
    'native_assertions_passed': sum(run['pass'] for run in runs),
    'save_scope': 'New model object state in a native save; not the future offensive-item migration.',
    'author_acceptance': 'Not requested for the unexposed foundation; manual tests/questions deferred by author.',
    'remaining': ['Selector destination for offensive Quintessence', 'Support economy/fabrication data',
                  'Mitigation and effect-class overlap decisions', 'Weapon/catalogue/art integration',
                  'Approved offensive-item migration', 'Combat, movement and end-to-end validation'],
}
(HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps(report, indent=2))
