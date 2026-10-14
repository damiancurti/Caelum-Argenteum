"""Collect final native runs; never package engines, IWADs or save files."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue258'
RUNS = {
    'core-03': 'probe', 'physics-07': 'probe', 'death-02': 'probe',
    'sewer-01': 'probe', 'hub-02': 'probe', 'old-save-01': 'legacy',
    'current-load-02': 'legacy', 'current-reload-02': 'legacy', 'rollback-01': 'legacy',
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


runtime = digest(WORK / 'production.pk3')
records = []
for label, fixture in RUNS.items():
    run = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0 and 'CA258 DONE failures=0' in log, label
    assert not any(error in log for error in ('CA258 FAIL', 'Script error', 'VM execution aborted')), label
    if run['production_sha256']:
        assert run['production_sha256'].lower() == runtime, label
    assert run['fixture_sha256'].lower() == digest(WORK / f'{fixture}.pk3'), label
    if run['additional_fixture_sha256']:
        extra = 'legacy' if fixture == 'probe' else 'probe'
        assert run['additional_fixture_sha256'].lower() == digest(WORK / f'{extra}.pk3'), label
    run['native_assertions'] = log.count('CA258 PASS ')
    records.append(run)
    for filename in (f'{label}-run.json', f'{label}.txt'):
        shutil.copyfile(WORK / filename, HERE / filename)

old_hash = digest(WORK / 'c258-old.zds')
for label in ('current-load-02', 'rollback-01'):
    assert next(r for r in records if r['label'] == label)['input_save_sha256'].lower() == old_hash
def shell_text(path):
    raw = path.read_bytes()
    return raw.decode('utf-16' if raw.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig')


validation = json.loads(shell_text(WORK / 'validate.txt'))
assert validation['errors'] == []
(HERE / 'validate.json').write_text(json.dumps(validation, indent=2)+'\n', encoding='utf-8')
(HERE / 'build.txt').write_text(shell_text(WORK / 'build.txt'), encoding='utf-8')
evidence = {
    'issue': 258, 'version': '5.3.3', 'baseline_commit': 'd974f859',
    'runtime_sha256': runtime, 'unchanged_original_save_sha256': old_hash,
    'runs': records, 'native_assertions': sum(r['native_assertions'] for r in records),
    'static_commands': [
        {'command': 'python validate_project.py', 'exit_code': 0},
        {'command': 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1', 'exit_code': 0, 'packaged_files': 16055}],
    'ordinary_input': 'Pending: Computer Use reported a user Escape interruption before window selection. No app input was sent afterward. The isolated interactive build and Probar258 handoff are prepared.',
    'author_acceptance': {'id': 'CA258-01', 'status': 'Tracked separately in RESULTS.md and docs/HISTORY.md; native runs do not imply author acceptance.'},
    'limits': ['Engine assertions use isolated fixtures, not author input.',
              'Tracked separately in RESULTS.md and docs/HISTORY.md; native runs do not imply author acceptance.',
              'Fixture map physics and native MAP02/MAP03/MAP04 runs do not certify every campaign location.'],
}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
print(f'Collected {len(records)} runs and {evidence["native_assertions"]} native assertions.')
