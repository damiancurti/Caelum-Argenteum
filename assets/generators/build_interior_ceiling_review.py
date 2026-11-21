"""Build private #883 ceiling options, preserving every non-target map byte."""
from pathlib import Path
import argparse, hashlib, json, re, struct, zipfile

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / 'assets/source/art/interior_ceilings_883/CONFIG.json'
SHA = lambda data: hashlib.sha256(data).hexdigest()


def textmap(blob):
    magic, count, directory = struct.unpack_from('<4sii', blob)
    assert magic == b'PWAD' and directory + count * 16 <= len(blob)
    entries = [struct.unpack_from('<ii8s', blob, directory + i * 16) for i in range(count)]
    entries = [r for r in entries if r[2].rstrip(b'\0') == b'TEXTMAP']
    assert len(entries) == 1
    offset, size, _ = entries[0]
    assert 0 <= offset <= offset + size <= directory
    return offset, blob[offset:offset + size].decode('utf-8')


def blocks(text, kind):
    return list(re.finditer(r'\b' + kind + r'\s*\{([^}]+)\}', text))


def fields(block):
    return dict(re.findall(r'\b(\w+)\s*=\s*([^;]+);', block.group(1)))


def change_surfaces(blob, targets, old_name, new_name):
    """Patch equal-length names in selected sector fields, without reserialization."""
    assert len(old_name.encode()) == len(new_name.encode())
    offset, text = textmap(blob)
    sectors = blocks(text, 'sector'); edits = []; records = []
    for index, field in targets:
        block = sectors[index]
        pattern = r'\b' + field + r'\s*=\s*"(' + re.escape(old_name) + r')"\s*;'
        matches = list(re.finditer(pattern, block.group(1)))
        assert len(matches) == 1, (index, field)
        start = block.start(1) + matches[0].start(1)
        end = block.start(1) + matches[0].end(1)
        edits.append((start, end))
        records.append(dict(sector=index, field=field, before=old_name, after=new_name,
                            source_fields=fields(block), textmap_span=[start, end]))
    assert edits and len(set(edits)) == len(edits)
    changed = text
    for start, end in sorted(edits, reverse=True):
        changed = changed[:start] + new_name + changed[end:]
    restored = changed
    for start, end in sorted(edits, reverse=True):
        restored = restored[:start] + old_name + restored[end:]
    assert restored == text and len(changed.encode()) == len(text.encode())
    # Source TEXTMAPs are UTF-8. Byte offsets into the WAD refer to encoded length;
    # string character offsets above are used only inside decoded sector blocks.
    candidate = blob[:offset] + changed.encode() + blob[offset + len(text.encode()):]
    assert len(candidate) == len(blob)
    assert candidate[:offset] == blob[:offset] and candidate[offset + len(text.encode()):] == blob[offset + len(text.encode()):]
    return candidate, records, hashlib.md5(changed.encode()).hexdigest()


def municipal_control(text, tag):
    sides = [fields(row) for row in blocks(text, 'sidedef')]
    controls = set()
    for row in blocks(text, 'linedef'):
        line = fields(row)
        if line.get('special') == '160' and line.get('arg0') == str(tag):
            controls.add(int(sides[int(line['sidefront'])]['sector']))
    assert len(controls) == 1, controls
    return controls.pop()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime', 'composition', 'output']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT / 'build')
    out.mkdir(parents=True, exist_ok=False)
    config = json.loads(CONFIG.read_text(encoding='utf-8'))
    interior = json.loads((ROOT / config['source_interior_data']).read_text(encoding='utf-8'))
    hubs = json.loads((ROOT / config['source_hub_data']).read_text(encoding='utf-8'))
    city = json.loads((ROOT / config['source_city_layout']).read_text(encoding='utf-8'))
    profiles = json.loads((ROOT / config['source_city_profiles']).read_text(encoding='utf-8'))['profiles']
    assert interior['roof'] == config['old_ceiling']
    assert SHA((ROOT / config['owned_material']).read_bytes()) == config['owned_material_sha256']
    house_count = sum(row['kind'] == 'house' for row in city['buildings'])
    house_maps = [hubs['map_prefix'] + f'{i:03d}' for i in range(house_count)]
    civic = [row for row in city['buildings'] if row.get('civic')]
    assert len(civic) == 1
    maps = {}; changes = []; runtime_sha = SHA(args.runtime.read_bytes())
    with zipfile.ZipFile(args.runtime) as archive:
        names = {n.lower(): n for n in archive.namelist()}
        assert len(names) == len(archive.namelist())
        for map_name in [*house_maps, 'MAP03']:
            name = 'maps/' + map_name + '.wad'; blob = archive.read(names[name.lower()])
            assert blob == (ROOT / 'src' / name).read_bytes(), name
            _, source = textmap(blob); sectors = blocks(source, 'sector')
            if map_name == 'MAP03':
                index = municipal_control(source, civic[0]['tag']); before = fields(sectors[index])
                assert before['texturefloor'] == before['textureceiling'] == '"' + config['old_ceiling'] + '"'
                profile = profiles[civic[0]['kind']]
                assert float(before['heightfloor']) == profile['headroom'] and float(before['heightceiling']) == profile['height']
                targets = [(index, 'texturefloor')]
            else:
                targets = [(i, 'textureceiling') for i, sector in enumerate(sectors)
                           if fields(sector).get('textureceiling') == '"' + config['old_ceiling'] + '"'
                           and float(fields(sector)['heightceiling']) > float(fields(sector)['heightfloor'])]
            candidate, edits, checksum = change_surfaces(blob, targets, config['old_ceiling'], config['candidate_ceiling'])
            maps[name] = candidate
            changes.append(dict(map=map_name, source_sha256=SHA(blob), candidate_sha256=SHA(candidate),
                                source_checksum=hashlib.md5(source.encode()).hexdigest(), candidate_checksum=checksum,
                                bytes=len(candidate), sectors=len(sectors), edits=edits,
                                unchanged_outside_target_names=True))
        justice = archive.read(names['caelum/data/caelumjusticegeometry.zs'])
    current = next(row for row in changes if row['map'] == 'MAP03')
    defaults = re.findall(rb'if\(map=="MAP03"\)return ([^;]+);', justice)
    selected = re.findall(('if\\(map=="MAP03" && level.GetChecksum\\(\\)=="' + current['source_checksum'] + '"\\)return ([^;]+);').encode(), justice)
    assert len(defaults) == 2 and selected == defaults, 'The native fallback must match the unchanged current arena'
    manifest = json.loads((args.composition / 'MANIFEST.json').read_text(encoding='utf-8'))
    assert manifest['issue'] == 881 and manifest['runtime_sha256'] == runtime_sha
    variants = []
    for variant in ['ceilings', 'appearance', 'vaults']:
        members = {}; inherited = None
        if variant != 'ceilings':
            item = next(r for r in manifest['variants'] if r['name'] == variant)
            path = args.composition / (variant + '.pk3'); inherited = SHA(path.read_bytes())
            assert inherited == item['sha256']
            with zipfile.ZipFile(path) as archive:
                members = {name: archive.read(name) for name in archive.namelist()}
            assert {n: SHA(b) for n, b in members.items()} == {n: r['sha256'] for n, r in item['members'].items()}
        assert not {n.lower() for n in members} & {n.lower() for n in maps}
        # Geometry indices/centers are unchanged. The current native Justice
        # fallback already selects the retained MAP03 arena; preserve every byte,
        # including the #875 checksum alias in the combined vault option.
        active_justice = members.get('caelum/data/CaelumJusticeGeometry.zs', justice)
        for value in defaults:
            clause = b'if(map=="MAP03")return ' + value + b';'
            assert clause in active_justice
        members.update(maps)
        path = out / (variant + '.pk3')
        with zipfile.ZipFile(path, 'x', compression=zipfile.ZIP_STORED) as archive:
            for name, blob in sorted(members.items()):
                archive.writestr(zipfile.ZipInfo(name, (2026, 11, 21, 0, 0, 0)), blob)
        variants.append(dict(name=variant, sha256=SHA(path.read_bytes()), bytes=path.stat().st_size,
                             inherited_composition_sha256=inherited, requires_fresh_session=True,
                             justice_source_unchanged=True, justice_sha256=SHA(active_justice),
                             members={n: SHA(b) for n, b in sorted(members.items())}))
    report = dict(issue=883, author_acceptance=False, runtime_sha256=runtime_sha,
                  config_sha256=SHA(CONFIG.read_bytes()), builder_sha256=SHA(Path(__file__).read_bytes()),
                  sources={p: SHA((ROOT / p).read_bytes()) for p in [config['source_interior_data'], config['source_hub_data'], config['source_city_layout'], config['source_city_profiles'], *config['references']]},
                  maps=changes, house_maps=house_count, edited_surface_fields=sum(len(r['edits']) for r in changes),
                  justice_map03=dict(sector=int(defaults[0]),center=[float(n) for n in defaults[1].decode().strip('()').split(',')]),
                  variants=variants, qualification='Private material-assignment proposal only. Equal-length TEXTMAP edits preserve all bytes except explicitly listed surface names. Exterior roof tops, solid/sky/Justice sectors, all geometry and things remain unchanged. No production installation or visited-save migration. The Justice fallback matches the unchanged current arena sector/center; verify natively.')
    (out / 'MANIFEST.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps(dict(issue=883, house_maps=house_count, edited_surface_fields=report['edited_surface_fields'],
                          variants=[{k: r[k] for k in ['name', 'bytes', 'sha256']} for r in variants])))


if __name__ == '__main__':
    main()
