"""Prove additive anatomy resources, preserved accepted inputs and package bytes."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b2f8600200d17c2c76065a0bbc9628c960795627'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    original = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'src'], cwd=ROOT, text=True).splitlines()
    versions = ['src/caelum/world/CaelumPhysicalHazards.zs', 'src/caelum/world/CaelumSewerMaze.zs']
    additions = ['src/licenses/UNDERBODY_827.txt'] + [f'src/models/caelum/characters/domingo/{name}.md3' for name in ['left_hand', 'right_hand', 'underbody']]
    paths = {p.relative_to(ROOT).as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
    assert set(paths) == set(original) | set(additions)
    with zipfile.ZipFile(args.runtime) as package:
        assert len(package.namelist()) == len(paths)
        assert set(package.namelist()) == {n[4:] for n in paths}
        for name, path in paths.items():
            assert package.read(name[4:]) == path.read_bytes(), name
    changes = subprocess.check_output(['git', 'diff', '--name-only', BASE, '--', 'src'], cwd=ROOT, text=True).splitlines()
    assert set(changes) - set(additions) == set(versions)
    for name in versions:
        before = subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
        after = paths[name].read_bytes()
        assert before.replace(b'5.17.91', b'5.17.92').replace(b'\r\n', b'\n') == after.replace(b'\r\n', b'\n'), name
    retained = {}
    for folder in ['assets/source/art/domingo_3d_pilot', 'assets/source/art/character_modules_458']:
        names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', folder], cwd=ROOT, text=True).splitlines()
        for name in names:
            before = subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
            assert before == (ROOT / name).read_bytes(), name
            retained[name] = digest(ROOT / name)
    one, two = [ROOT / f'build/issue827-export{n:02d}' for n in [5, 6]]
    repeated = {}
    for path in sorted(one.rglob('*')):
        if path.is_file():
            name = path.relative_to(one).as_posix()
            assert path.read_bytes() == (two / name).read_bytes(), name
            repeated[name] = digest(path)
    assert len(repeated) == 6
    report = dict(issue=827, base_commit=BASE, runtime_sha256=digest(args.runtime), source_entries=len(paths), package_exact_source_bytes=True,
                  retained_inputs=retained, repeated_files=6, repeated_exports=repeated, additions=additions,
                  changed_existing_runtime=versions, existing_runtime_art_and_behavior_preserved=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps(dict(passed=True, source_entries=len(paths), repeated_files=6, retained_inputs=len(retained))))


if __name__ == '__main__':
    main()
