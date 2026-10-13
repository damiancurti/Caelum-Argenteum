"""Collect completed issue-specific engine runs, without shipping save/runtime files."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue257'
LABELS = ['probe-03', 'forecast-03', 'old-save-03', 'current-load-02',
          'current-reload-02', 'rollback-02', 'mansion-01', 'hub-01']
runtime_hash = hashlib.sha256((WORK / 'production.pk3').read_bytes()).hexdigest()
records = []
for label in LABELS:
    run = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0 and 'CA257 DONE failures=0' in log, label
    assert not any(error in log for error in ['CA257 FAIL', 'Script error', 'VM execution aborted']), label
    if run['production_sha256']:
        assert run['production_sha256'].lower() == runtime_hash, label
    primary = 'probe' if label in ['probe-03', 'forecast-03'] else 'legacy'
    assert run['fixture_sha256'].lower() == hashlib.sha256((WORK / f'{primary}.pk3').read_bytes()).hexdigest(), label
    run['native_assertions'] = log.count('CA257 PASS ')
    records.append(run)
    for name in [f'{label}-run.json', f'{label}.txt']:
        shutil.copyfile(WORK / name, HERE / name)
old_hash = hashlib.sha256((WORK / 'c257-old.zds').read_bytes()).hexdigest()
for label in ['current-load-02', 'rollback-02']:
    assert next(run for run in records if run['label'] == label)['input_save_sha256'].lower() == old_hash
shutil.copyfile(WORK / 'input-rest-full.png', HERE / 'input-rest-full.png')
shutil.copyfile(WORK / 'validate.txt', HERE / 'validate.json')
shutil.copyfile(WORK / 'input-es-01.txt', HERE / 'input-es-01-snapshot.txt')
interactive = json.loads((WORK / 'input-es-01-run.json').read_text(encoding='utf-8-sig'))
evidence = {
    'issue': 257, 'version': '5.3.2', 'baseline_commit': '359009f0',
    'runtime_sha256': runtime_hash, 'unchanged_original_save_sha256': old_hash,
    'runs': records, 'native_assertions': sum(run['native_assertions'] for run in records),
    'interactive_run': interactive,
    'ordinary_input': 'User activated native x105 and orbited the camera; the observed rest reached 100% food/water. Agent F/G input was not delivered because user input was detected. The author subsequently passed CA257-01, including its native control checks.',
    'author_acceptance': {'id': 'CA257-01', 'origin_version': '5.3.2', 'issue': 257, 'result': 'passed', 'date': '2026-10-13', 'statement': 'La prueba que me dejaste dio todo correcto.', 'qualifications': 'none'},
    'static_commands': [
        {'command': 'python validate_project.py', 'exit_code': 0},
        {'command': 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1', 'exit_code': 0, 'packaged_files': 16054}],
    'limitations': ['Existing evolving thermal costs are not modeled by the time-skip supply forecast.',
                    'Ground-rest eligibility is checked; exhaustion induction belongs to #258.']}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8')
print(f'Collected {len(records)} runs, {evidence["native_assertions"]} native assertions and one reviewed capture.')
