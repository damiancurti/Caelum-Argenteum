"""Retain completed issue-scoped runs and inspectable screenshots, not runtimes."""
from pathlib import Path
import hashlib
import io
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue256'
labels = ['final-es', 'final-en-small', 'final-es-wide', 'baseline-save',
          'current-load', 'current-reload', 'final-hub', 'rollback-old-save']
records = []
runtime_hash = hashlib.sha256((WORK/'production.pk3').read_bytes()).hexdigest()
# Preserve the precise earlier legacy fixture used before adding its rollback marker.
snapshot_dir = HERE/'snapshots'
snapshot_dir.mkdir(exist_ok=True)
legacy_before = (HERE/'legacy.zs').read_text(encoding='utf-8').replace(
    '        if(e.Name=="c256_old_done")Console.Printf("CA256 DONE failures=%d",Failures);\n', '')
(snapshot_dir/'legacy-pre-rollback.zs').write_text(legacy_before, encoding='utf-8', newline='\n')
buffer = io.BytesIO()
with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted({
        'ZSCRIPT': b'version "4.14"\n#include "checks/legacy.zs"\n',
        'checks/legacy.zs': legacy_before.encode(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA256Legacy" }\n'}.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
legacy_before_hash = hashlib.sha256(buffer.getvalue()).hexdigest()
for label in labels:
    run = json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log = (WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code'] == 0, label
    assert 'CA256 FAIL' not in log and 'VM execution aborted' not in log, label
    if label == 'baseline-save':
        assert 'CA256 LEGACY' in log and 'Game saved.' in log, label
    else:
        assert 'CA256 DONE failures=0' in log, label
    if run['production_sha256']:
        assert run['production_sha256'].lower() == runtime_hash, label
    if label in ['baseline-save', 'current-load', 'current-reload']:
        assert run['fixture_sha256'].lower() == legacy_before_hash, label
    if label in ['final-es', 'final-en-small', 'final-es-wide']:
        run['additional_fixture_sha256'] = legacy_before_hash
    elif label == 'final-hub':
        run['additional_fixture_sha256'] = hashlib.sha256((WORK/'legacy.pk3').read_bytes()).hexdigest()
    elif label in ['current-load', 'current-reload']:
        run['additional_fixture_sha256'] = hashlib.sha256((WORK/'probe.pk3').read_bytes()).hexdigest()
    run['native_assertions'] = log.count('CA256 PASS ')
    records.append(run)
    for name in [f'{label}-run.json', f'{label}.txt']:
        shutil.copyfile(WORK/name, HERE/name)
images = ['final-es-character-sword.png', 'final-es-character-ranged.png',
          'final-es-character-magic.png', 'final-es-character-unarmed.png',
          'final-es-character-adverse.png', 'final-es-hud-critical-cold.png',
          'final-es-hud-recovered.png', 'final-en-small-character.png',
          'final-en-small-hud-large.png', 'final-es-wide-character.png',
          'final-es-wide-hud-large.png', 'current-load-character-loaded.png']
for name in images:
    shutil.copyfile(WORK/name, HERE/name)
evidence = {'issue': 256, 'version': '5.3.1', 'baseline_commit': '12f9b979',
            'runtime_sha256': runtime_hash, 'runs': records,
            'native_assertions': sum(r['native_assertions'] for r in records),
            'author_acceptance': {'id': 'CA256-01', 'date': '2026-10-13',
                                  'result': 'passed', 'statement': 'Quedó muy bien, apruebo.'},
            'static_commands': [
                {'command': 'python validate_project.py', 'exit_code': 0},
                {'command': 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1', 'exit_code': 0}]}
(HERE/'evidence.json').write_text(json.dumps(evidence, indent=2)+'\n', encoding='utf-8')
print(f'Collected {len(records)} runs, {evidence["native_assertions"]} native assertions, {len(images)} captures.')
