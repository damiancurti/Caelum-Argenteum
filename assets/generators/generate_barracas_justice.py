"""Append the existing Justice arena to an isolated Barracas candidate.

The input candidate and all production maps remain intact. Optional registration
adds a checksum-qualified arena to the authoritative Justice manifest/index.
"""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile
from generate_tarot_justice import ROOT, DATA, append_arena, lumps, digest, runtime_index


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--register', action='store_true')
    args = parser.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    settings = json.loads((DATA / 'ARENA.json').read_text(encoding='utf-8'))
    with zipfile.ZipFile(args.candidate) as archive:
        files = {n: archive.read(n) for n in archive.namelist()}
    original = files['maps/MAP03.wad']
    revised, geometry = append_arena(original, settings)
    old_text = dict(lumps(original))['TEXTMAP']; new_text = dict(lumps(revised))['TEXTMAP']
    assert new_text.startswith(old_text), 'Existing candidate geometry was modified'
    geometry['checksum'] = hashlib.md5(new_text).hexdigest()
    geometry['settings_sha256'] = digest((DATA / 'ARENA.json').read_bytes())
    files['maps/MAP03.wad'] = revised
    with zipfile.ZipFile(out / 'preview.pk3', 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, blob in sorted(files.items()):
            info = zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)); info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, blob, compresslevel=9)
    (out / 'MAP03.wad').write_bytes(revised)
    if args.register:
        path = DATA / 'MAPS.json'; manifest = json.loads(path.read_text(encoding='utf-8'))
        row = next(r for r in manifest['maps'] if r['file'] == 'MAP03.wad')
        row['candidate_geometry'] = geometry
        index = runtime_index(manifest, settings)
        (ROOT / 'src/caelum/data/CaelumJusticeGeometry.zs').write_bytes(index)
        manifest['index_sha256'] = digest(index)
        path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8', newline='\n')
    report = {'issue': 454, 'geometry': geometry, 'existing_textmap_prefix_unchanged': True,
              'input_package_sha256': digest(args.candidate.read_bytes()),
              'input_map_sha256': digest(original), 'candidate_map_sha256': digest(revised),
              'candidate_package_sha256': digest((out / 'preview.pk3').read_bytes()),
              'production_maps_modified': False, 'registered': args.register}
    (out / 'justice-report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
