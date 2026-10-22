"""Collect #406 native checks without distributing packages or private saves."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue406'
FINAL = ['verified-matrix', 'verified-boundaries', 'verified-separation',
         'verified-active', 'verified-save', 'verified-load', 'verified-resume',
         'verified-resumed-load', 'verified-travel', 'verified-upgrade',
         'verified-upgraded-load', 'verified-manual-controls', 'verified-manual-load', 'rollback']
EXPLORATORY = ['compile-01', 'baseline-boundaries', 'current-matrix',
               'separation-01', 'legacy-save', 'final-matrix', 'deadline-regression']
EXPLORATORY += ['delivery-' + name for name in ['matrix', 'boundaries', 'separation',
               'active', 'save', 'load', 'resume', 'resumed-load', 'travel', 'upgrade',
               'upgraded-load', 'manual-smoke', 'manual-controls', 'manual-load']]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    native = HERE / 'native'
    native.mkdir(exist_ok=True)
    records = []
    total = 0
    for label in FINAL + EXPLORATORY:
        log = WORK / f'{label}.txt'
        metadata = WORK / f'{label}-run.json'
        text = log.read_text(encoding='utf8', errors='replace')
        record = json.loads(metadata.read_text(encoding='utf-8-sig'))
        results = re.findall(r'CA406 RESULT passed=(\d+) failed=(\d+)', text)
        passed, failed = map(int, results[-1]) if results else (0, 0)
        if label in FINAL:
            assert record['exit_code'] == 0 and not record.get('timed_out'), label
            assert results and not re.search(
                r'CA406 FAIL|Script error|VM execution aborted|failed=[1-9]', text), label
            total += passed
        shutil.copy2(log, native / log.name)
        records.append({**record, 'label': label, 'selected': label in FINAL,
                        'passed': passed, 'failed': failed, 'log_sha256': sha(log)})
    original = json.loads((WORK / 'legacy-original-hash.json').read_text())
    assert sha(WORK / original['file']) == original['sha256'], 'Original save changed'
    package = WORK / 'current/caelum_argenteum_dev.pk3'
    for record in records:
        if record['selected'] and record['runtime'] == 'current':
            assert record['package_sha256'].lower() == sha(package), record['label']
    members = 0
    with zipfile.ZipFile(package) as archive:
        for member in archive.infolist():
            assert not member.is_dir()
            source = ROOT / 'src' / member.filename
            assert source.is_file() and archive.read(member) == source.read_bytes(), member.filename
            members += 1
    report = dict(issue=406, version='5.7.3', selected_runs=len(FINAL), passed=total,
                  failed=0, package_sha256=sha(package), source_matching_members=members,
                  original_save=original, runs=records,
                  presentation='No renderer change or frame-rate improvement is claimed.',
                  author_acceptance='CA406-01 pending')
    (HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf8')
    result = subprocess.run([sys.executable, 'validate_project.py'], cwd=ROOT,
                            capture_output=True, check=True)
    (HERE / 'project-validation.json').write_bytes(result.stdout)
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}, indent=2))


if __name__ == '__main__':
    main()
