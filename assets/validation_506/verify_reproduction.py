"""Rebuild diagnostic packages twice and verify final native run identities."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue128'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

names = ['baseline', 'current', 'no-candidates', 'no-stagger', 'neither',
         'legacy-shared', 'pruned-cannon', 'production', 'observer', 'checks',
         'cannon-study', 'battle', 'guard-oracle', 'cannon-oracle', 'counters',
         'counters-current', 'counters-no-stagger', 'counters-no-candidates',
         'counters-pruned-cannon', 'view']
passes = []
for iteration in range(2):
    for script, args in [('prepare.py', ['--baseline']), ('prepare_checks.py', []),
                         ('prepare_view.py', [])]:
        subprocess.run([sys.executable, str(HERE / script), *args], cwd=ROOT, check=True)
    passes.append({name: digest(WORK / (name + '.pk3')) for name in names})
assert passes[0] == passes[1], 'Diagnostic packaging is not deterministic'

matched = {}
for label, package, addon in [
    ('production-c', 'production', 'observer'),
    ('production-d', 'production', 'observer'),
    ('final-checks-b', 'production', 'checks'),
    ('final-load-b', 'production', 'checks'),
    ('final-travel-b', 'production', 'checks'),
    ('final-guard-a', 'guard-oracle', 'battle'),
    ('final-cannon-a', 'cannon-oracle', 'battle'),
    ('final-visual-a', 'production', 'battle'),
    ('battle-view-a', 'production', 'view'),
]:
    run = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert run['package_sha256'].lower() == passes[1][package], label
    assert run['addon_sha256'].lower() == passes[1][addon], label
    matched[label] = {'package': package, 'addon': addon}

result = {
    'identical_build_passes': 2,
    'packages_sha256': passes[1],
    'exact_native_run_identities': matched,
    'historical_experiment_commit': '031c8877636a7dfd50fefb7fcf117f956b25d886',
    'historical_limit': 'First-pass Windows package byte hashes are retained in '
                        'EXPERIMENT_MANIFEST.json. Git archive normalizes text line endings; '
                        'the pinned experiment reproduces canonical runtime content.',
}
(HERE / 'REPRODUCTION.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print('Reproduction passed: two identical builds and nine exact final native run identities.')
