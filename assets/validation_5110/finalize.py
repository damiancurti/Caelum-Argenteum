"""Collect #154 evidence and verify the final package without altering saves."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue154'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def main():
    required = {
        'official-final-b': ('CA154 CHECKS COMPLETE pass=327 fail=0', 1),
        'movement-final-a': ('CA154 JUMP PASS', 6),
        'projectiles-final-a': ('CA154 PROJECTILES COMPLETE pass=165 fail=0', 1),
        'launchers-final': ('CA154 LAUNCHERS COMPLETE pass=9 fail=0', 1),
        'hazards-b': ('CA154 HAZARDS COMPLETE pass=16 fail=0', 1),
        'stairs-a': ('CA154 STAIRS PASS', 1),
        'elevator-b': ('CA154 ELEVATOR_', 2),
        'pool-b': ('CA154 POOL PASS', 1),
        'save-upgrade-b': ('CA154 PERSISTENCE COMPLETE pass=18 fail=0', 1),
        'save-repeat-b': ('CA154 PERSISTENCE COMPLETE pass=18 fail=0', 1),
        'author-save-b': ('CA154 PERSISTENCE COMPLETE pass=12 fail=0', 1),
        'author-rollback-a': ('CA154 PERSISTENCE COMPLETE pass=12 fail=0', 1),
        'hub-upgrade-final': ('CA154 HUB PASS', 3),
    }
    raw = HERE / 'raw'
    raw.mkdir(exist_ok=True)
    runs = []
    fatal = re.compile(r'VM execution aborted|Script error|needs these files|CA154[^\n]*\bFAIL\b(?!\s*=\s*0)', re.I)
    for record_path in sorted(WORK.glob('*-run.json')):
        record = read_json(record_path)
        label = record['label']
        log_path = WORK / (label + '.txt')
        log = log_path.read_text(encoding='utf-8', errors='replace') if log_path.exists() else ''
        if label in required:
            token, count = required[label]
            assert record.get('exit_code') == 0, label
            assert log.count(token) == count, (label, token, log.count(token))
            assert not fatal.search(log), label
            if label == 'movement-final-a':
                assert len(re.findall(r'CA154 MOVEMENT PASS stage=\d tic=350 ', log)) == 4
        for path in (record_path, log_path, WORK / (label + '-exec.cfg')):
            if path.exists():
                shutil.copyfile(path, raw / path.name)
        runs.append({'label': label, 'selected_acceptance_evidence': label in required,
                     'exit_code': record.get('exit_code'),
                     'package_sha256': record.get('package_sha256'),
                     'log_sha256': digest(log_path) if log_path.exists() else None,
                     'diagnostic_error_present': bool(fatal.search(log))})

    baseline = read_json(HERE / 'BASELINE.json')
    assert digest(WORK / 'baseline.pk3') == baseline['package_sha256']
    protected = WORK / 'prueba-protected.zds'
    original = ROOT / 'build/issue152/prueba-original.zds'
    assert digest(protected) == digest(original)
    power = read_json(ROOT / 'build/issue140/power-154.json')
    assert power['release_result'] and power['active_plan_before'] == power['active_plan_after']
    shutil.copyfile(ROOT / 'build/issue140/power-154.json', HERE / 'POWER.json')

    source = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
    package = ROOT / 'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        assert set(archive.namelist()) == set(source)
        for name, path in source.items():
            assert archive.read(name) == path.read_bytes(), name
    before = {p.name: digest(p) for p in WORK.glob('*-addon.pk3')}
    subprocess.run(['python', str(HERE / 'prepare.py')], cwd=ROOT, check=True)
    assert before == {p.name: digest(p) for p in WORK.glob('*-addon.pk3')}
    changed = subprocess.check_output(['git', 'diff', '--name-only', baseline['commit'], '--', 'src'], cwd=ROOT, text=True).splitlines()
    assert all(p.endswith('.zs') or p in ('src/ZSCRIPT', 'src/LANGUAGE') for p in changed)

    # Inventory adapters and direct consumers, including callers not modified.
    consumers = {}
    old = {}
    for p in sorted((ROOT / 'src').rglob('*.zs')):
        lines = p.read_text(encoding='utf-8-sig').splitlines()
        name = p.relative_to(ROOT).as_posix()
        hits = [{'line': i, 'text': line.strip()} for i, line in enumerate(lines, 1)
                if re.search(r'Calculate(?:Actor)?Type[124]Percent|CaelumGrowthRules\.', line)]
        if hits:
            consumers[name] = hits
        legacy = [{'line': i, 'text': line.strip()} for i, line in enumerate(lines, 1)
                  if re.search(r'/\s*101(?:00)?(?:\.0)?\b', line)]
        if legacy:
            old[name] = legacy
    assert set(old) == {'src/caelum/statistics/CaelumGrowthMigration.zs'}, old
    audit = {'release': '5.1.10', 'issue': 154, 'baseline': baseline,
             'official_package_sha256': digest(package), 'package_members': len(source),
             'package_exactly_matches_src': True, 'unchanged_maps_art_and_audio': True,
             'deterministic_fixture_hashes': before,
             'protected_author_save_sha256': digest(protected),
             'original_author_save_unchanged': True, 'keep_awake_released': True,
             'source_sha256': {name: digest(path) for name, path in source.items() if name.endswith('.zs')},
             'growth_consumer_inventory': consumers, 'legacy_curve_occurrences': old,
             'runs': runs, 'author_acceptance': 'pending: CA154-01 and CA154-02'}
    (HERE / 'AUDIT.json').write_text(json.dumps(audit, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'Final evidence: {len(required)} selected runs; {len(runs)} total attempts retained; '
          f'{len(source)} package members verified; original save preserved; power request released.')


if __name__ == '__main__':
    main()
