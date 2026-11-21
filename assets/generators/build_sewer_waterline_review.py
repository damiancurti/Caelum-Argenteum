"""Compose a private damp-masonry option on existing channel risers only."""
from pathlib import Path
import argparse, hashlib, importlib.util, json, re, zipfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / 'assets/source/art/sewer_waterline_887/CONFIG.json'
SHA = lambda data: hashlib.sha256(data).hexdigest()


def reader():
    spec = importlib.util.spec_from_file_location('waterline_reader', Path(__file__).with_name('build_interior_ceiling_review.py'))
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result)
    return result


def replace_spans(text, spans, value):
    parts = []; cursor = 0
    for start, end in sorted(spans):
        assert cursor <= start < end <= len(text)
        parts.extend([text[cursor:start], value]); cursor = end
    parts.append(text[cursor:])
    return ''.join(parts)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime', 'composition', 'output']:
        p.add_argument('--' + name, type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT / 'build')
    assert out != ROOT / 'build'
    cfg = json.loads(CONFIG.read_text(encoding='utf-8'))
    layout = json.loads((ROOT / cfg['layout']).read_text(encoding='utf-8'))
    material = json.loads((ROOT / cfg['material_inventory']).read_text(encoding='utf-8'))
    inherited = json.loads((args.composition / 'MANIFEST.json').read_text(encoding='utf-8'))
    runtime_sha = SHA(args.runtime.read_bytes())
    assert inherited['issue'] == cfg['inherited_issue'] and inherited['runtime_sha256'] == runtime_sha
    package = args.composition / 'municipal.pk3'
    assert SHA(package.read_bytes()) == inherited['package_sha256']
    with zipfile.ZipFile(package) as archive:
        members = {n: archive.read(n) for n in archive.namelist()}
    assert {n: SHA(v) for n,v in members.items()} == inherited['members']
    image = ROOT / cfg['source_image']; image_data = image.read_bytes()
    assert SHA(image_data) == cfg['source_sha256']
    with Image.open(image) as picture:
        width, height = picture.size
        assert picture.mode in ['RGB', 'RGBA']
        if picture.mode == 'RGBA':
            assert picture.getchannel('A').getextrema() == (255, 255)
    source_alias = cfg['selection']['source_alias']; alias = cfg['alias']
    assert re.fullmatch('[A-Z0-9]{8}', alias) and len(source_alias) == len(alias)
    source_map = members[cfg['map_member']]
    r = reader(); offset, text = r.textmap(source_map)
    with zipfile.ZipFile(args.runtime) as archive:
        default_map = archive.read(cfg['map_member'])
        default_justice = archive.read('caelum/data/CaelumJusticeGeometry.zs').decode('utf-8')
    _, default_text = r.textmap(default_map)
    default_arenas = re.findall(r'if\(map=="MAP02"\)return (\d+);', default_justice)
    assert len(default_arenas) == 1
    sector_blocks = r.blocks(text, 'sector'); side_blocks = r.blocks(text, 'sidedef')
    sectors = [r.fields(b) for b in sector_blocks]; sides = [r.fields(b) for b in side_blocks]
    lines = [r.fields(b) for b in r.blocks(text, 'linedef')]
    vertices = [r.fields(b) for b in r.blocks(text, 'vertex')]
    selection = cfg['selection']; dry_z = selection['dry_floor_z']
    wet_z = dry_z - layout[selection['water_depth_key']]
    water = '"' + layout['materials'][selection['water_floor_key']] + '"'
    dry = '"' + selection['dry_floor_alias'] + '"'
    edits = []; spans = []; selected_sides = set()
    for index, line in enumerate(lines):
        if 'sideback' not in line or int(line['sideback']) < 0:
            continue
        if int(line.get('special', '0')) or int(line.get('id', '0')):
            continue
        for own, opposite in [('sidefront', 'sideback'), ('sideback', 'sidefront')]:
            si, oi = int(line[own]), int(line[opposite])
            s, other = sides[si], sides[oi]
            sector, dry_sector = int(s['sector']), int(other['sector'])
            a, b = sectors[sector], sectors[dry_sector]
            if not (a['texturefloor'] == water and float(a['heightfloor']) == wet_z
                    and b['texturefloor'] == dry and float(b['heightfloor']) == dry_z
                    and s[selection['field']] == '"' + source_alias + '"'):
                continue
            assert si not in selected_sides; selected_sides.add(si)
            block = side_blocks[si]
            matches = list(re.finditer(r'\b' + selection['field'] + r'\s*=\s*"(' + source_alias + r')"\s*;', block.group(1)))
            assert len(matches) == 1
            start = block.start(1) + matches[0].start(1); end = start + len(source_alias)
            spans.append((start, end))
            points = [[float(vertices[int(line[key])][axis]) for axis in ['x','y']] for key in ['v1','v2']]
            edits.append(dict(line=index, side=si, water_sector=sector, dry_sector=dry_sector,
                              points=points, lower_floor=wet_z, upper_floor=dry_z,
                              field=selection['field'], before=source_alias, after=alias, textmap_span=[start,end]))
    assert spans and len(spans) == len(selected_sides)
    changed = replace_spans(text, spans, alias)
    assert replace_spans(changed, spans, source_alias) == text
    assert len(changed.encode('utf-8')) == len(text.encode('utf-8'))
    candidate = source_map[:offset] + changed.encode('utf-8') + source_map[offset + len(text.encode('utf-8')):]
    assert len(candidate) == len(source_map)
    assert candidate[:offset] == source_map[:offset] and candidate[offset+len(text.encode()):] == source_map[offset+len(text.encode()):]
    old_checksum = hashlib.md5(text.encode('utf-8')).hexdigest()
    checksum = hashlib.md5(changed.encode('utf-8')).hexdigest()
    justice_name = 'caelum/data/CaelumJusticeGeometry.zs'; original_justice = members[justice_name]
    justice = original_justice.decode('utf-8')
    pattern = r'(        if\(map=="MAP02" && level.GetChecksum\(\)=="' + old_checksum + r'"\)return (\d+);)'
    matches = list(re.finditer(pattern, justice)); assert len(matches) == 1
    anchor = matches[0].group(1); arena = int(matches[0].group(2))
    newline = '\r\n' if '\r\n' in justice else '\n'
    addition = anchor.replace(old_checksum, checksum) + newline
    justice = justice.replace(anchor, addition + anchor, 1)
    assert justice.replace(addition, '', 1).encode('utf-8') == original_justice
    centers = re.findall(r'if\(map=="MAP02"\)return \(([^)]+)\);', justice)
    assert len(centers) == 1
    arena_center = [float(n) for n in centers[0].split(',')]
    assert len(arena_center) == 3
    assert arena == len(sectors) - 1
    texture_path = 'graphics/caelum/review887/wet-brick-v1.png'
    assert texture_path not in members and alias not in members['TEXTURES'].decode('utf-8')
    repeat = material['wall']['display_repeat_mu']
    definition = (f'\n// Private #887 channel-riser material; existing native scale.\n'
                  f'Texture "{alias}", {width}, {height}\n{{\n'
                  f'    XScale {width/repeat:.8f}\n    YScale {height/repeat:.8f}\n'
                  f'    Patch "{texture_path}", 0, 0\n}}\n').encode('utf-8')
    members[cfg['map_member']] = candidate
    members[justice_name] = justice.encode('utf-8')
    members['TEXTURES'] += definition
    members[texture_path] = image_data
    out.mkdir(parents=True, exist_ok=False)
    path = out / 'waterline.pk3'
    with zipfile.ZipFile(path, 'x', compression=zipfile.ZIP_STORED) as archive:
        for name, body in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026,11,21,0,0,0)), body)
    report = dict(issue=887, author_acceptance=False, runtime_sha256=runtime_sha,
        inherited_sha256=inherited['package_sha256'], builder_sha256=SHA(Path(__file__).read_bytes()),
        config_sha256=SHA(CONFIG.read_bytes()), sources={cfg[k]:SHA((ROOT/cfg[k]).read_bytes()) for k in ['layout','material_inventory','source_image']},
        source_map_sha256=SHA(source_map), candidate_map_sha256=SHA(candidate), source_checksum=old_checksum,
        candidate_checksum=checksum, edits=edits, edited_sides=len(edits), non_target_map_bytes_identical=True,
        default_map=dict(checksum=hashlib.md5(default_text.encode('utf-8')).hexdigest(), sha256=SHA(default_map),
                         sectors=len(r.blocks(default_text,'sector')), justice_sector=int(default_arenas[0])),
        geometry_counts={kind:len(r.blocks(text,kind)) for kind in ['vertex','linedef','sidedef','sector','thing']},
        justice=dict(sector=arena, center=arena_center, source_sha256=SHA(original_justice), candidate_sha256=SHA(members[justice_name]),
                     change='Append only a checksum alias for the same inherited arena; preserve every existing branch and center.'),
        texture=dict(source=cfg['source_image'], pixels=[width,height], bytes=len(image_data), display_repeat_mu=repeat,
                     sha256=SHA(image_data), definition=definition.decode('utf-8')),
        package_sha256=SHA(path.read_bytes()), package_bytes=path.stat().st_size,
        members={n:SHA(v) for n,v in sorted(members.items())}, qualification=cfg['scope'])
    (out/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['issue','edited_sides','candidate_checksum','package_sha256','package_bytes']}))


if __name__ == '__main__':
    main()
