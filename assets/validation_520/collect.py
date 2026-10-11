"""Retain selected native evidence, without packages, saves or dependencies."""
from pathlib import Path
import hashlib
import json
import re
import shutil

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue147'
RUNS = [
    'legacy-a-04', 'legacy-b-01', 'current-a-01', 'current-b-01',
    'rollback-a-02', 'rollback-b-01', 'migration-a-01', 'migration-b-01',
    'menus-es-captures', 'menus-en-final', 'truehub-final',
    'migration-a-final', 'current-reload-final', 'migrated-restart-final',
    'bindings-import', 'bindings-restart', 'menus-es-delivery', 'menus-en-delivery',
    'migration-a-delivery', 'current-reload-delivery',
]
DIAGNOSTICS = ['compile-01', 'legacy-a-01', 'legacy-a-02', 'legacy-a-03',
               'menus-es-01', 'rollback-a-01']


def retain(source, destination):
    if source.suffix == '.txt':
        lines = source.read_text(encoding='utf-8-sig').splitlines()
        destination.write_text('\n'.join(line.rstrip() for line in lines).rstrip() + '\n', encoding='utf-8')
    elif source.suffix == '.json':
        record = json.loads(source.read_text(encoding='utf-8-sig'))
        initial = record.get('initial_config')
        if isinstance(initial, dict) and 'value' in initial:
            # Windows PowerShell attaches provider metadata to Get-Content strings.
            # Retain the exact config text, not that unrelated reflection tree.
            record['initial_config'] = initial['value']
        destination.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
    else:
        shutil.copyfile(source, destination)


def main():
    summary = []
    for label in RUNS:
        record = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
        log = (WORK / f'{label}.txt').read_text(encoding='utf-8-sig')
        failures = re.findall(r'^.*(?:CA147 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR|This savegame needs).*$', log, re.M)
        if record.get('exit_code') != 0 or failures:
            raise SystemExit(f'Incomplete or failed native run: {label}: {failures}')
        summary.append({'label': label, 'passed_assertions': len(re.findall(r'^CA147 PASS ', log, re.M)),
                        'exit_code': record['exit_code'], 'production_sha256': record['production_sha256'],
                        'original_log_sha256': hashlib.sha256((WORK / f'{label}.txt').read_bytes()).hexdigest(),
                        'snapshots': re.findall(r'^CA147 SNAP .+$', log, re.M)})
        for suffix in ['.txt', '-run.json']:
            retain(WORK / (label + suffix), HERE / (label + suffix))
    diagnostic_dir = HERE / 'diagnostics'
    diagnostic_dir.mkdir(exist_ok=True)
    for label in DIAGNOSTICS:
        for suffix in ['.txt', '-run.json']:
            source = WORK / (label + suffix)
            if source.exists():
                retain(source, diagnostic_dir / source.name)
    result = {'runs': summary, 'passed_assertions': sum(r['passed_assertions'] for r in summary),
              'failed_assertions': 0,
              'capture_sha256': {p.relative_to(HERE).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                                 for p in sorted((HERE / 'captures').rglob('*.png'))}}
    (HERE / 'native.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'runs': len(summary), 'passed_assertions': result['passed_assertions'],
                      'failed_assertions': 0, 'per_run': {r['label']: r['passed_assertions'] for r in summary}}, indent=2))


if __name__ == '__main__':
    main()
