"""Verify final house sources, native runtime reuse and matched package scope."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def digest(data):
    return hashlib.sha256(data).hexdigest()


def package_hashes(path):
    with zipfile.ZipFile(path) as archive:
        return {name: digest(archive.read(name)) for name in sorted(archive.namelist())}


def changed(left, right):
    return sorted(name for name in left.keys() | right.keys() if left.get(name) != right.get(name))


def main():
    source = {path.relative_to(ROOT/'src').as_posix(): digest(path.read_bytes())
              for path in sorted((ROOT/'src').rglob('*')) if path.is_file()}
    normal = ROOT/'build/caelum_argenteum_dev.pk3'
    current = ROOT/'build/issue318-houses-09/current/runtime.pk3'
    assert package_hashes(normal) == source, 'Normal package is stale'
    final_native = package_hashes(current)
    assert final_native == source, 'Source changed after native house tests'
    previous = package_hashes(ROOT/'build/issue318-houses-07/current/runtime.pk3')
    status = package_hashes(ROOT/'build/issue318-houses-08/current/runtime.pk3')
    first_changes = changed(previous, status)
    last_changes = changed(status, final_native)
    assert first_changes == ['caelum/data/CaelumCartographyCatalogueData.zs']
    assert last_changes == [f'graphics/caelum/shop_signs/CASG{i:02d}.png' for i in range(6)]+['licenses/SHOP_SIGNS_5428.txt']
    pairs = []
    directory = ROOT/'build/issue318-houses-perf-03'
    for population in (6000, 1000):
        left = package_hashes(directory/f'houses-{population}'/'runtime.pk3')
        right = package_hashes(directory/f'opaque-{population}'/'runtime.pk3')
        diff = changed(left, right)
        assert diff == ['caelum/data/CaelumCartographyCatalogueData.zs', 'maps/MAP06.wad']
        base_diff = changed(source, left)
        assert base_diff == ([] if population == 6000 else ['caelum/world/CaelumPortData.zs'])
        if population == 1000:
            with zipfile.ZipFile(directory/'houses-1000/runtime.pk3') as archive:
                name = 'caelum/world/CaelumPortData.zs'
                expected = (ROOT/'src'/name).read_bytes().replace(b'\r\n', b'\n').replace(
                    b'return IsSouth()?6000:MANDINGAS;', b'return MANDINGAS;')
                assert archive.read(name) == expected
        pairs.append({'population': population, 'pair_changed_members': diff,
                      'source_changed_members': base_diff})
    result = {'source_members': len(source),
        'source_tree_sha256': digest(json.dumps(source, sort_keys=True).encode()),
        'normal_package_sha256': digest(normal.read_bytes()),
        'native09_package_sha256': digest(current.read_bytes()),
        'normal_package_matches_source': True, 'native09_matches_source': True,
        'functional07_to_08_changed_members': first_changes,
        'functional08_to_09_changed_members': last_changes,
        'matched_uninstrumented_packages': pairs,
        'diagnostic_text_newlines': 'The existing prepare.replace helper normalizes edited diagnostic PortData to LF; the expected byte comparison includes this normalization.',
        'scope': 'Exact member-byte verification, not a new native playthrough or author acceptance.'}
    (HERE/'HOUSE_PACKAGE_VERIFICATION.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
