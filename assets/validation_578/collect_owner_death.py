"""Collect focused #479 owner-lifetime regression evidence without changing art."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / 'assets/validation_578'
WORK = ROOT / 'build/issue479'
OUT = HERE / 'native/owner_death'
OUT.mkdir(parents=True, exist_ok=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def preserve(label):
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8-sig', errors='strict')
    meta = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    (OUT / f'{label}.txt').write_text(
        '\n'.join(line.rstrip() for line in log.splitlines()) + '\n', encoding='utf-8')
    (OUT / f'{label}-run.json').write_text(
        json.dumps(meta, indent=2) + '\n', encoding='utf-8')
    return log, meta


package = WORK / 'owner-death/caelum_argenteum_dev.pk3'
original = WORK / 'pre-owner-death/caelum_argenteum_dev.pk3'
if not original.exists():
    original = WORK / 'current/caelum_argenteum_dev.pk3'
originals = json.loads((WORK / 'owner-death-originals.json').read_text(encoding='utf-8-sig'))
assert digest(original) == originals['original_package_sha256'].lower()
assert digest(WORK / 'ca479-live.zds') == originals['live_save_sha256'].lower()
sources = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as fixed, zipfile.ZipFile(original) as old:
    assert set(fixed.namelist()) == set(sources) == set(old.namelist())
    changed = []
    for name, path in sources.items():
        assert fixed.read(name) == path.read_bytes(), name
        if fixed.read(name) != old.read(name):
            changed.append(name)
assert changed == ['caelum/world/CaelumSupportMagic.zs'], changed

failures = {}
for label in ['author-combat-20261023-154650', 'owner-death-before01', 'owner-death-before02']:
    log, meta = preserve(label)
    if label != 'owner-death-before01':
        assert 'VM execution aborted: tried to read from address zero.' in log
        assert 'Called from CaelumSupportStatus.Tick' in log
    failures[label] = {
        'expected_vm_reproduction': label != 'owner-death-before01',
        'excluded_from_pass_total': True,
        'package_sha256': meta['package_sha256'].lower(),
    }

cases = {}
labels = ['owner-death-after01', 'owner-death-player01', 'owner-death-controls01',
          'owner-death-load01', 'owner-death-reload01', 'owner-death-gameplay01',
          'owner-death-input01', 'owner-death-live-load01']
for label in labels + ['owner-death-old-save01']:
    log, meta = preserve(label)
    assert meta['exit_code'] == 0 and not meta.get('timed_out'), label
    assert not re.search(r'CA479 FAIL|Script error|VM execution aborted|Unknown command|failed=[1-9]', log), label
    expected = original if label == 'owner-death-old-save01' else package
    assert meta['package_sha256'].lower() == digest(expected), label
    assert meta['addon_sha256'].lower() == digest(WORK / 'fixture.pk3'), label
    count = len(re.findall(r'^CA479 PASS ', log, re.M))
    assert count > 0, label
    cases[label] = {'assertions': count, 'package_sha256': digest(expected)}

report = {
    'issue': 479, 'version': '5.7.8', 'date': '2026-10-23',
    'package_sha256': digest(package), 'original_package_sha256': digest(original),
    'fixture_sha256': digest(WORK / 'fixture.pk3'), 'source_entries': len(sources),
    'source_package_identity': True, 'changed_runtime_entries': changed,
    'original_live_save_sha256_unchanged': digest(WORK / 'ca479-live.zds'),
    'pre_fix_lethal_save_sha256': digest(WORK / 'owner-death-old-save01.zds'),
    'cases': cases, 'fixed_package_assertions': sum(cases[label]['assertions'] for label in labels),
    'baseline_save_assertions': cases['owner-death-old-save01']['assertions'],
    'failures_preserved': failures, 'save_schema_changed': False,
    'author_gameplay_accepted': False,
    'limits': 'Functional regression only; accepted artwork is unchanged. No rendering-performance claim.',
}
(HERE / 'owner_death_report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ['fixed_package_assertions', 'baseline_save_assertions', 'source_entries', 'package_sha256']}, indent=2))
