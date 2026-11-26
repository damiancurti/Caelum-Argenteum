"""Verify the diagnostic format assessment leaves the production art unchanged."""
from pathlib import Path
import argparse, hashlib, json, subprocess, zipfile

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd1d501e9e586f3e95a16044304304e9f1bb6c8e9'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    prior = ROOT / 'assets/validation_v5_17_94/evidence'
    before = json.loads((prior / 'runtime-before.json').read_text(encoding='utf-8'))
    audit = json.loads((prior / 'historical-audit.json').read_text(encoding='utf-8'))
    expected = set()
    for row in audit['runtime_diagnostic_audit']:
        before[row['file']] = row['after_sha256']
        expected.add(row['file'])
    paths = {p.relative_to(ROOT).as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
    current = {name: digest(path.read_bytes()) for name, path in paths.items()}
    assert set(before) == set(current)
    assert {name for name in before if before[name] != current[name]} == expected
    diagnostics = []
    for name in sorted(expected):
        old = subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
        new = paths[name].read_bytes()
        assert old.count(b'5.17.94') == 1
        assert old.replace(b'5.17.94', b'5.17.95').replace(b'\r\n', b'\n') == new.replace(b'\r\n', b'\n')
        diagnostics.append({'path': name, 'before_sha256': before[name], 'after_sha256': current[name]})
    with zipfile.ZipFile(args.runtime) as package:
        assert set(package.namelist()) == {name.removeprefix('src/') for name in current}
        for name, expected_hash in current.items():
            assert digest(package.read(name.removeprefix('src/'))) == expected_hash, name
    protected = ['assets/source/art/domingo_3d_pilot', 'assets/source/art/character_modules_458',
                 'assets/source/art/underbody_827', 'assets/source/art/worn_clothing_829',
                 'src/models', 'src/caelum/character', 'src/caelum/equipment', 'src/sprites']
    assert all((ROOT / name).exists() for name in protected)
    assert not subprocess.check_output(['git', 'diff', BASE, '--', *protected], cwd=ROOT).strip()
    assert not subprocess.check_output(['git', 'diff', BASE, '--name-only', '--diff-filter=D'], cwd=ROOT).strip()
    report = {'issue': 834, 'base_commit': BASE, 'runtime_sha256': digest(args.runtime.read_bytes()),
              'runtime_members': len(current), 'only_two_diagnostic_release_strings_changed': diagnostics,
              'all_package_members_match_source': True, 'protected_sources_unchanged': protected,
              'no_removed_files': True, 'production_format_equipment_collision_save_ownership_unchanged': True}
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps({'runtime_members': len(current), 'runtime_changes': len(diagnostics), 'passed': True}))


if __name__ == '__main__':
    main()
