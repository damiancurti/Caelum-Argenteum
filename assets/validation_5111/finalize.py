"""Collect focused native evidence without copying saves or development binaries."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue156'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    runs = {}
    for label in ['regression-final', 'reload-final']:
        record = json.loads((OUT / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        log = (OUT / (label + '.txt')).read_text(encoding='utf-8-sig')
        assert record['exit_code'] == 0
        assert not any(x in log for x in ['CA156 FAIL', 'VM execution aborted', 'Script error'])
        expected = 21 if label == 'regression-final' else 2
        assert log.count('CA156 PASS ') == expected
        if label == 'regression-final':
            assert 'CA156 RESULT passed=21 failed=0' in log
        for suffix in ['.txt', '-run.json']:
            shutil.copyfile(OUT / (label + suffix), HERE / (label + suffix))
        runs[label] = {'checks_passed': expected, 'package_sha256': record['package_sha256']}
    original = Path.home() / 'Saved Games/GZDoom/doom.id.doom2.commercial/save04.zds'
    protected = OUT / 'craft-tiempo-original.zds'
    assert sha(original) == sha(protected)
    package = ROOT / 'build/caelum_argenteum_dev.pk3'
    assert all(r['package_sha256'].lower() == sha(package) for r in runs.values())
    static = json.loads((OUT / 'validate-project.txt').read_text(encoding='utf-8-sig'))
    assert not static['errors']
    shutil.copyfile(OUT / 'validate-project.txt', HERE / 'STATIC.json')
    shutil.copyfile(OUT / 'input-probe-e.txt', HERE / 'input-probe-e.txt')
    power = ROOT / 'build/issue140/power-156b.json'
    state = json.loads(power.read_text(encoding='utf-8-sig'))
    assert 'released_utc' in state
    shutil.copyfile(power, HERE / 'power-release.json')
    result = {
        'version': '5.1.11', 'issue': 156, 'baseline': 'fe5ba743',
        'runs': runs, 'final_package_sha256': sha(package),
        'protected_baseline_package_sha256': sha(OUT / 'baseline/caelum_argenteum_dev.pk3'),
        'author_save_sha256': sha(original), 'original_save_unchanged': True,
        'panel_source_sha256': sha(ROOT / 'src/caelum/hud/CaelumTimeSkipPanel.zs'),
        'checks_source_sha256': sha(HERE / 'checks.zs'),
        'reload_source_sha256': sha(HERE / 'reload.zs'),
        'author_confirmation': '2026-10-10: physical Tab closes baseline panel only',
        'pending': ['CA154-01', 'CA154-02', 'CA156-01'],
        'os_input_automation': 'No reliable delivery; not counted as a pass',
    }
    (HERE / 'RESULTS.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print('Collected 23 native checks; original save unchanged; power request released.')


if __name__ == '__main__':
    main()
