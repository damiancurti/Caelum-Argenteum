"""Read-only #183 supply/geometry delta audit and deterministic generators.

The older revision-3 pathfinder does not model the accepted revision-4 flooded
return network. Verify unchanged geometry against the issue base instead of
claiming that historical pathfinder proves current native traversal.
"""
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'd313c227'


def git_bytes(path):
    return subprocess.check_output(['git', 'show', f'{BASE}:{path}'], cwd=ROOT)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    spec = importlib.util.spec_from_file_location('map_reader', ROOT / 'assets/generators/validate_map02_layout.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    before_path = ROOT / 'build/issue183/baseline-map02.wad'
    before_path.parent.mkdir(parents=True, exist_ok=True)
    before_path.write_bytes(git_bytes('src/maps/MAP02.wad'))
    before = module.read_map(before_path)
    after = module.read_map(ROOT / 'src/maps/MAP02.wad')
    old_manifest = json.loads(git_bytes('assets/map02_maze/MAP02_MANIFEST.json'))
    manifest = json.loads((ROOT / 'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    checks = []

    def check(name, passed):
        checks.append(dict(name=name, passed=bool(passed)))

    for kind in ('vertex', 'sector', 'sidedef', 'linedef'):
        check(f'Exact baseline {kind} geometry retained', before[kind] == after[kind])
    identity = lambda row: json.dumps(row, sort_keys=True)
    old_things = Counter(map(identity, before['thing']))
    new_things = Counter(map(identity, after['thing']))
    added = [json.loads(row) for row in (new_things - old_things).elements()]
    check('Only four armor workshops added; no original map things removed',
          not old_things - new_things and len(added) == 4 and all(row['type'] == 18002 for row in added))
    check('Generated WAD things match manifest', after['thing'] == manifest['things'])
    for refuge in manifest['refuges']:
        check(f'Refuge {refuge["zone"]} supports every initial T1 armor family',
              {row['type'] for row in refuge['stations']} == {18000, 18001, 18002, 18003, 18004})
    replacements = {'CaelumCarbineAmmo': 'CaelumArrowAmmo', 'CaelumShotgunAmmo': 'CaelumBoltAmmo'}
    expected = [{**row, 'cls': replacements.get(row['cls'], row['cls'])} for row in old_manifest['drops']]
    check('Every drop retains carrier/position/quantity except authorized ammo class replacement', manifest['drops'] == expected)
    totals = Counter()
    for row in manifest['drops']:
        if row['cls'].endswith('Ammo'):
            totals[row['cls']] += row['amount']
    check('Exactly 600 assigned rounds: 360 arrows, 240 bolts', totals == {'CaelumArrowAmmo': 360, 'CaelumBoltAmmo': 240})
    outputs = [ROOT / p for p in ('src/maps/MAP02.wad', 'src/caelum/world/CaelumMazeLayout.zs',
               'assets/map02_maze/MAP02_MANIFEST.json', 'src/caelum/dialogue/CaelumDialogueHistoryData.zs')]
    initial = {str(p.relative_to(ROOT)): sha(p) for p in outputs}
    runs = []
    for _ in range(2):
        for generator in ('generate_map02_maze.py', 'generate_dialogue_history.py'):
            subprocess.run([sys.executable, str(ROOT / 'assets/generators' / generator)], check=True, capture_output=True)
        runs.append({str(p.relative_to(ROOT)): sha(p) for p in outputs})
    check('Both generator reruns match existing output byte-for-byte', initial == runs[0] == runs[1])
    report = dict(issue=183, base=BASE, checks=checks, hashes=initial,
                  failures=sum(not row['passed'] for row in checks),
                  evidence='static differential audit; native fixtures verify inventory/crafting')
    (HERE / 'static-audit.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'#183 differential audit: {len(checks)} checks; {report["failures"]} failures')
    for row in checks:
        if not row['passed']:
            print('FAIL:', row['name'])
    return bool(report['failures'])


if __name__ == '__main__':
    raise SystemExit(main())
