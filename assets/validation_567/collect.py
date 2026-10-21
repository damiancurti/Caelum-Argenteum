"""Collect #387's final-package checks separately from early diagnostic runs."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue387'
LABELS = ['delivery-ui-es', 'delivery-world', 'delivery-suite', 'delivery-save',
          'delivery-load', 'delivery-travel', 'delivery-upgrade',
          'delivery-upgrade-load', 'delivery-baseline', 'delivery-smoke']


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def redact(value):
    if isinstance(value, list):
        return [redact(v) for v in value]
    if isinstance(value, dict):
        return {k: redact(v) for k, v in value.items()}
    if not isinstance(value, str):
        return value
    value = value.replace(str(ROOT), '<repo>').replace(ROOT.as_posix(), '<repo>')
    value = value.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe', '<engine>')
    value = re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD', '<iwad>', value, flags=re.I)
    return re.sub(r'C:\\Users\\[^\\\s]+', '<user>', value, flags=re.I)


def collect_run(work, label, package, addon, category):
    log_path = work/(label+'.txt')
    log = log_path.read_text(encoding='utf-8', errors='replace')
    record = json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code'] == 0 and not record.get('timed_out'), label
    assert not re.search(r'CA38[67] FAIL|Script error|VM execution aborted', log), label
    assert record['package_sha256'].lower() == sha(package), label
    if record['addon_sha256']:
        assert record['addon_sha256'].lower() == sha(addon), label
    (HERE/'native'/(label+'.txt')).write_text(clean_log(log), encoding='utf-8')
    return {'label': label, 'category': category, 'record': redact(record),
            'passes': len(re.findall(r'CA38[67] PASS ', log)), 'raw_log_sha256': sha(log_path)}


def clean_log(log):
    return '\n'.join(line.rstrip() for line in redact(log).splitlines()).rstrip()+'\n'


def main():
    package = WORK/'current/caelum_argenteum_dev.pk3'
    assert sha(package) == sha(ROOT/'build/caelum_argenteum_dev.pk3')
    (HERE/'native').mkdir(exist_ok=True)
    runs = [collect_run(WORK, label, package, WORK/'checks.pk3', 'final package') for label in LABELS]
    old = ROOT/'build/issue386'
    runs.append(collect_run(old, 'issue387-original-rollback', old/'current/caelum_argenteum_dev.pk3',
                            old/'checks.pk3', 'original 5.6.6 recovery pair'))
    runs.append(collect_run(old, 'issue387-baseline-rollback', old/'baseline/caelum_argenteum_dev.pk3',
                            old/'baseline-checks.pk3', 'original 5.5.8a recovery pair'))
    with zipfile.ZipFile(package) as archive:
        members = {}
        for name in archive.namelist():
            content = archive.read(name)
            assert content.replace(b'\r\n', b'\n') == (ROOT/'src'/name).read_bytes().replace(b'\r\n', b'\n'), name
            members[name] = hashlib.sha256(content).hexdigest()
    exports = json.loads((ROOT/'assets/art_source/clothing/exports.json').read_text(encoding='utf-8'))
    assert len(exports['exports']) == 25
    for row in exports['exports']:
        assert sha(ROOT/row['source']) == row['source_sha256']
        assert sha(ROOT/row['output']) == row['output_sha256']
    assert len({row['output_sha256'] for row in exports['exports']}) == 25
    check = subprocess.run(['python', 'validate_project.py'], cwd=ROOT, capture_output=True,
                           encoding='utf-8', check=True)
    validation = json.loads(check.stdout)
    assert not validation['errors']
    (HERE/'project-validation.json').write_text(json.dumps(validation, indent=2)+'\n', encoding='utf-8')
    screens = {}
    for name in ['clothing-es.png', 'clothing-world.png']:
        shutil.copy2(WORK/name, HERE/name)
        screens[name] = sha(HERE/name)
    diagnostics = []
    for label in ['suite-01', 'suite-02', 'suite-03', 'suite-04', 'suite-05']:
        path = WORK/(label+'.txt')
        (HERE/'native'/('diagnostic-'+label+'.txt')).write_text(clean_log(path.read_text(encoding='utf-8', errors='replace')), encoding='utf-8')
        diagnostics.append({'label': label, 'raw_log_sha256': sha(path), 'counts_as_passing': False})
    report = {'issue': 387, 'version': '5.6.7', 'base_commit': 'f4c87d6e5ec42f3f96e601149b5574b5142e6195',
              'package_sha256': sha(package), 'source_member_count': len(members),
              'source_manifest_sha256': hashlib.sha256(json.dumps(members, sort_keys=True).encode()).hexdigest(),
              'runs': runs, 'native_runs': len(runs), 'passes': sum(r['passes'] for r in runs), 'failures': 0,
              'early_diagnostics': diagnostics, 'screenshots': screens, 'distinct_garment_outputs': 25,
              'author_acceptance': 'CA387-01 passed on 2026-10-21; inventory/crafting and dropped-item views only',
              'limitations': ['Worn-character, preview and first-person coverage unfinished.',
                              'Not a frame-presentation or large-map performance benchmark.']}
    (HERE/'report.json').write_text(json.dumps(report, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    print(json.dumps({k: report[k] for k in ['native_runs', 'passes', 'failures', 'package_sha256']}))


if __name__ == '__main__':
    main()
