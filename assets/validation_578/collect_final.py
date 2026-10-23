"""Verify the integrated package and preserve issue #479 native evidence."""
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
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


package = WORK / 'current/caelum_argenteum_dev.pk3'
package_hash = digest(package)
sources = {p.relative_to(ROOT / 'src').as_posix(): p
           for p in (ROOT / 'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist()) == set(sources), 'Package membership differs from src'
    for name, path in sources.items():
        assert archive.read(name) == path.read_bytes(), name

fixture_hash = digest(WORK / 'fixture.pk3')
subprocess.run([sys.executable, str(HERE / 'prepare.py')], check=True)
assert digest(WORK / 'fixture.pk3') == fixture_hash, 'Nondeterministic fixture'
legacy_hash = digest(WORK / 'legacy-fixture.pk3')
foundation_hash = digest(WORK / 'foundation/caelum_argenteum_dev.pk3')
labels = ['complete-' + name for name in
          ('gameplay', 'controls', 'model', 'live', 'save', 'load', 'legacy', 'gallery')]
labels += ['legacy-seed-02', 'legacy-rollback-02']
runs = []
errors = r'CA479 FAIL|Script error|VM execution aborted|not flagged for use|Unknown (floor|ceiling|middle) texture'
for label in labels:
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8', errors='replace')
    meta = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    old = label.startswith('legacy-')
    legacy = old or label == 'complete-legacy'
    assert meta['exit_code'] == 0 and not re.search(errors, log), label
    assert 'CA479 RESULT' in log, label
    assert meta['package_sha256'].lower() == (foundation_hash if old else package_hash), label
    assert meta['addon_sha256'].lower() == (legacy_hash if legacy else fixture_hash), label
    for suffix in ('.txt', '-run.json'):
        destination = HERE / 'native' / (label + suffix)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(WORK / (label + suffix), destination)
    runs.append({'label': label, 'pass': len(re.findall(r'^CA479 PASS ', log, re.M)),
                 'fail': 0, 'exit_code': 0, 'baseline_runtime': old,
                 'log_sha256': digest(WORK / f'{label}.txt')})

manifest_path = ROOT / 'assets/generators/support_implements_manifest.json'
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
for section in ('inputs', 'outputs'):
    for name, expected in manifest[section].items():
        assert digest(ROOT / name) == expected, name
assert manifest_path.read_bytes() == (WORK / 'art-manifest-first.json').read_bytes()
for asset in manifest['assets']:
    lines = (ROOT / 'src' / asset['model']).read_text(encoding='utf-8').splitlines()
    assert sum(line.startswith('usemtl ') for line in lines) <= 32, asset['key']

screenshots = {f'complete-gallery-art-{i:02}.png': digest(WORK / f'complete-gallery-art-{i:02}.png')
               for i in range(18)}
assert len(set(screenshots.values())) == 18, 'Gallery must show distinct frames'
visuals = HERE / 'visuals'
visuals.mkdir(exist_ok=True)
for name in ('complete-gallery-contact.png', 'complete-gallery-art-00.png',
             'complete-gallery-art-06.png', 'complete-gallery-art-17.png'):
    shutil.copyfile(WORK / name, visuals / name)
report = {
    'issue': 479, 'release': '5.7.8', 'date': '2026-10-22',
    'status': 'integrated; awaiting author check CA479-01',
    'package_sha256': package_hash, 'source_entries': len(sources), 'source_bytes_match': True,
    'fixture_sha256': fixture_hash, 'fixture_deterministic': True,
    'legacy_fixture_sha256': legacy_hash, 'foundation_package_sha256': foundation_hash,
    'runs': runs, 'full_package_assertions': sum(r['pass'] for r in runs if not r['baseline_runtime']),
    'baseline_assertions': sum(r['pass'] for r in runs if r['baseline_runtime']),
    'pass_count_rule': 'Count PASS lines emitted by each process, not serialized cumulative counters.',
    'art_manifest_sha256': digest(manifest_path), 'art_generation_byte_identical_twice': True,
    'gallery_capture_sha256': screenshots,
    'legacy_save_sha256': digest(WORK / 'ca479-legacy-v2.zds'),
    'author_acceptance': 'Pending; manual tests/questions postponed during absence.',
    'limits': ['Isolated native validation, not author acceptance.',
               'No frame-presentation or large-map performance measurement.',
               'Ordinary campaign purchase/learning/crafting UI awaits author check.',
               'Foundation and overlay evidence remain separately labeled.'],
}
(HERE / 'final_report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ('status', 'package_sha256', 'source_entries',
                                             'full_package_assertions', 'baseline_assertions')}, indent=2))
