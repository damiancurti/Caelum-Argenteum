"""Check retained regional layouts and exact production bytes against #806."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
BASE = '7768bd0cc640b8f5c07bcaa8a151a94ca65d5a85'


def previous(name):
    return subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    layouts = {}
    repeated = {}
    for number, old_count, old_views, new_kind in [(682, 18, 24, 'umita'), (709, 14, 21, 'chonchon')]:
        name = f'assets/source/art/regional_gallery_{number}/GALLERY.json'
        old = json.loads(previous(name))
        new = json.loads((ROOT / name).read_text())
        assert len(old['subjects']) == old_count and len(old['views']) == old_views
        assert new['subjects'][:-1] == old['subjects']
        assert new['views'][:-1] == old['views']
        assert new['subjects'][-1]['kind'] == new_kind and new['views'][-1]['id'] == new_kind
        retained = ['plots', 'crossing_test', 'walkway_y', 'plot_y', 'player_start',
                    'ambient', 'ceiling_height', 'outer_wall', 'walkway_flat',
                    'silent_observer_steps', 'animation_sample_wait_tics']
        assert all(new[key] == old[key] for key in retained)
        keys = [view['key'].lower() for view in new['views']]
        assert len(keys) == len(set(keys))
        a = ROOT / f'build/issue809-{number}-export01'
        b = ROOT / f'build/issue809-{number}-export02'
        files = sorted(p.name for p in a.iterdir() if p.is_file())
        assert files == ['GALLERY_MANIFEST.json', 'TEXTMAP.txt', 'gallery.pk3', 'gallery.zs']
        assert all((a / n).read_bytes() == (b / n).read_bytes() for n in files)
        repeated[str(number)] = {n: hashlib.sha256((a / n).read_bytes()).hexdigest() for n in files}
        layouts[str(number)] = dict(previous_subjects=old_count, previous_controls=old_views,
                                    current_subjects=len(new['subjects']), current_controls=len(keys),
                                    prior_subjects_and_controls_exact=True, retained_fields=retained)
    runtime = args.runtime.resolve(strict=True)
    paths = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(runtime) as package:
        assert len(package.namelist()) == len(paths) and set(package.namelist()) == set(paths)
        assert all(package.read(n) == p.read_bytes() for n, p in paths.items())
    changed = subprocess.check_output(['git', 'diff', '--name-only', BASE, '--', 'src'], cwd=ROOT, text=True).splitlines()
    assert changed == ['src/caelum/world/CaelumPhysicalHazards.zs', 'src/caelum/world/CaelumSewerMaze.zs']
    for name in changed:
        assert previous(name).decode().replace('5.17.82', '5.17.83') == (ROOT / name).read_text()
    result = dict(issue=809, base_commit=BASE, layouts=layouts, repeated_fixtures=repeated,
                  repeated_files=8, all_production_art_and_behavior_exact=True,
                  changed_runtime_resources=changed, runtime_sha256=hashlib.sha256(runtime.read_bytes()).hexdigest(),
                  runtime_source_entries=len(paths), package_exact_source_bytes=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps(dict(passed=True, repeated_files=8, package_entries=len(paths))))


if __name__ == '__main__':
    main()
