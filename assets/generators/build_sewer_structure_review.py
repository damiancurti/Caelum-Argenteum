"""Build the opt-in #875 vault proposal without rewriting production resources."""
from collections import Counter, defaultdict
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import zipfile

from generate_tarot_justice import append_arena, lumps, pack

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / 'assets/source/art/sewer_structure_875/CONFIG.json'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def segment_profiles(layout):
    """Describe spans using only existing layout positions and width fields."""
    rows = []

    def add(a, b, width, label):
        assert (a[0] == b[0]) != (a[1] == b[1]), (a, b)
        axis = 0 if a[1] == b[1] else 1
        rows.append(dict(axis=axis, cross=a[1-axis], low=min(a[axis], b[axis]),
                         high=max(a[axis], b[axis]), width=width, label=label))

    for section in layout['sections']:
        nodes = section['nodes']
        for a, b in section['edges']:
            add(nodes[a], nodes[b], layout['passage_width'], section['name'] + ':main')
        a, b = section['shortcut']
        add(nodes[a], nodes[b], layout['shortcut_width'], section['name'] + ':shortcut')
    for link in layout['links']:
        for a, b in zip(link['points'], link['points'][1:]):
            add(a, b, layout['service_width'], 'service')
    return rows


def vault_cells(cells, layout, metadata, profile_settings):
    """Attach a ceiling plane only where a single existing straight span fits."""
    profiles = segment_profiles(layout)
    assert profile_settings['shape'] == 'circular_segment'
    grid = layout[profile_settings['facet_spacing_key']]
    spring = layout[profile_settings['spring_height_key']]
    crown = layout[profile_settings['crown_height_key']]
    rise = crown - spring
    assert rise > 0 and rise <= min(p['width'] for p in profiles)/2
    result = {}
    counts = Counter()
    plane_cells = defaultdict(list)
    spans = set()
    for point, value in cells.items():
        floor, ceiling, group, tag, water = value
        plane = None
        if ceiling == spring and 1 <= group <= len(layout['sections']) and tag == 0 and floor >= -layout['channel_depth']:
            center = (point[0]+grid/2, point[1]+grid/2)
            matches = set()
            for profile in profiles:
                along = profile['axis']; cross = 1-along; half = profile['width']/2
                if profile['low'] <= center[along] <= profile['high'] and abs(center[cross]-profile['cross']) < half:
                    matches.add((cross, profile['cross'], profile['width']))
            if len(matches) == 1:
                axis, origin, width = next(iter(matches))
                half = width/2
                lo = point[axis]-origin; hi = lo+grid
                assert -half <= lo < hi <= half
                radius = (half*half+rise*rise)/(2*rise)

                def height(offset):
                    if abs(offset) == half:
                        return float(spring)
                    return spring+rise-radius+math.sqrt(max(0, radius*radius-offset*offset))

                z0, z1 = height(lo), height(hi)
                slope = (z1-z0)/grid
                intercept = z0-slope*point[axis]
                # GZDoom normalizes the normal vector but does not rescale D.
                # Supply D at the same unit-normal scale as the engine uses.
                normal_length = math.sqrt(slope*slope+1)
                plane = (slope if axis == 0 else 0.0,
                         slope if axis == 1 else 0.0, -1.0, intercept/normal_length)
                assert min(z0, z1) >= spring and max(z0, z1) <= crown
                plane_cells[plane].append(point)
                spans.add((axis, origin, width))
                counts['vaulted_cells'] += 1
                counts['water_cells' if water else 'dry_cells'] += 1
            else:
                counts['ambiguous_cells' if matches else 'unmatched_cells'] += 1
        else:
            counts['excluded_cells'] += 1
        result[point] = value + (plane,)
    assert counts['vaulted_cells'] > 0
    metadata.update(counts=dict(counts), profiles=profiles, distinct_cross_sections=len(spans),
                    planes=[dict(parameters=list(p), cells=positions) for p, positions in sorted(plane_cells.items())],
                    spring_mu=spring, crown_mu=crown, grid_mu=grid)
    return result


def compile_map(source_path, profile_settings=None):
    """Execute only the existing compiler's pure prefix; never its file writers."""
    source = source_path.read_text(encoding='utf-8')
    stop = "(ROOT/'assets/map02_maze/BASE_MAP02.wad').write_bytes"
    assert source.count(stop) == 1
    source = source[:source.index(stop)]
    assert '.write_' not in source and 'subprocess.run(' not in source
    metadata = {}
    if profile_settings is not None:
        anchor = '# Stable sector/line ordering and explicit gate segments preserve reproducibility.'
        assert source.count(anchor) == 1
        source = source.replace(anchor, 'cells=CA875_VAULTS(cells,cfg)\n' + anchor, 1)
        old = 'floor,ceil,group,tag,water=v;sector_ids[v]=len(sectors)'
        assert source.count(old) == 1
        source = source.replace(old, 'floor,ceil,group,tag,water=v[:5];sector_ids[v]=len(sectors)', 1)
        anchor = ' return sector_ids[v]'
        addition = '''  if v[5] is not None:
   sectors[-1].update(dict(zip(('ceilingplane_a','ceilingplane_b','ceilingplane_c','ceilingplane_d'),v[5])))
'''
        assert source.count(anchor) == 1
        source = source.replace(anchor, addition + anchor, 1)
    namespace = {'__file__': str(source_path), '__name__': 'ca875_read_only_compiler',
                 'CA875_VAULTS': lambda cells, cfg: vault_cells(cells, cfg, metadata, profile_settings)}
    exec(compile(source, str(source_path), 'exec'), namespace)
    body, directory = namespace['body'], namespace['directory']
    blob = struct.pack('<4sii', b'PWAD', 3, 12+len(body)) + body + directory
    return bytes(blob), namespace, metadata


def line_inventory(context):
    rows = {}
    for line in context['lines']:
        a, b = (context['vertices'][line[k]] for k in ['v1', 'v2'])
        key = tuple(sorted(((a['x'], a['y']), (b['x'], b['y']))))
        value = {k: v for k, v in line.items() if k not in ['v1', 'v2', 'sidefront', 'sideback']}
        value['sides'] = []
        for field in ['sidefront', 'sideback']:
            if field not in line:
                continue
            side = context['sides'][line[field]]
            sector = context['sectors'][side['sector']]
            value['sides'].append(dict(side={k: v for k, v in side.items() if k != 'sector'},
                                      sector={k: v for k, v in sector.items() if not k.startswith('ceilingplane_')}))
        assert key not in rows
        rows[key] = value
    return rows


def build(runtime, output, brick=False):
    output = output.resolve(); output.relative_to(ROOT/'build'); output.mkdir(parents=True, exist_ok=False)
    config = json.loads(CONFIG.read_text(encoding='utf-8'))
    compiler = ROOT/config['compiler']
    original, before, _ = compile_map(compiler)
    assert original == (ROOT/'assets/map02_maze/BASE_MAP02.wad').read_bytes(), 'Original compiler is not reproducible'
    proposed, after, geometry = compile_map(compiler, config['profile'])
    assert before['things'] == after['things']
    assert before['cells'] == {p: v[:5] for p, v in after['cells'].items()}
    old_lines, new_lines = line_inventory(before), line_inventory(after)
    assert all(new_lines.get(key) == value for key, value in old_lines.items()), 'An original boundary changed'
    arena = json.loads((ROOT/'assets/tarot_justice/ARENA.json').read_text(encoding='utf-8'))
    current, old_arena = append_arena(original, arena)
    candidate, new_arena = append_arena(proposed, arena)
    assert old_arena['origin'] == new_arena['origin'] and old_arena['center'] == new_arena['center']
    with zipfile.ZipFile(runtime) as archive:
        assert archive.read('maps/MAP02.wad') == current, 'Runtime differs from retained production map'
        index = archive.read('caelum/data/CaelumJusticeGeometry.zs')
    material_members = {}
    if brick:
        from build_sewer_material_review import build as build_material
        build_material(output/'material.pk3')
        with zipfile.ZipFile(output/'material.pk3') as archive:
            material_members = {name: archive.read(name) for name in archive.namelist()}
        definitions = material_members['TEXTURES']
        entries = lumps(candidate)
        for old_name, new_name in config['material_aliases'].items():
            old_token, new_token = ('"'+old_name+'"').encode(), ('"'+new_name+'"').encode()
            assert old_token in definitions and new_token not in definitions
            definitions = definitions.replace(old_token, new_token)
            entries = [(name, data.replace(old_token, new_token) if name == 'TEXTMAP' else data)
                       for name, data in entries]
        material_members['TEXTURES'] = definitions
        candidate = pack(entries)
    checksum = hashlib.md5(dict(lumps(candidate))['TEXTMAP']).hexdigest()
    source = index.decode('utf-8')
    anchor = '        if(map=="MAP02")return '+str(old_arena['sector'])+';'
    assert source.count(anchor) == 1
    newline = '\r\n' if b'\r\n' in index else '\n'
    replacement = f'        if(map=="MAP02" && level.GetChecksum()=="{checksum}")return {new_arena["sector"]};'+newline+anchor
    updated_index = source.replace(anchor, replacement, 1).encode('utf-8')
    members = {'maps/MAP02.wad': candidate, 'caelum/data/CaelumJusticeGeometry.zs': updated_index}
    assert not members.keys() & material_members.keys()
    members.update(material_members)
    with zipfile.ZipFile(output/'candidate.pk3', 'x') as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 21, 0, 0, 0)), data)
    (output/'MAP02.wad').write_bytes(candidate)
    (output/'TEXTMAP.txt').write_bytes(dict(lumps(candidate))['TEXTMAP'])
    (output/'CaelumJusticeGeometry.zs').write_bytes(updated_index)
    (output/'planes.json').write_text(json.dumps(geometry, indent=2)+'\n', encoding='utf-8', newline='\n')
    report = dict(issue=875, author_acceptance=False, runtime_sha256=digest(runtime.read_bytes()),
                  config_sha256=digest(CONFIG.read_bytes()), compiler_sha256=digest(compiler.read_bytes()),
                  builder_sha256=digest(Path(__file__).read_bytes()),
                  layout_sha256=digest((ROOT/config['layout']).read_bytes()),
                  source_map_sha256=digest(current), candidate_map_sha256=digest(candidate),
                  candidate_checksum=checksum, overlay_sha256=digest((output/'candidate.pk3').read_bytes()),
                  members={name: dict(bytes=len(data), sha256=digest(data)) for name, data in members.items()},
                  original_geometry={key: len(before[key]) for key in ['sectors', 'lines', 'vertices', 'things']},
                  candidate_geometry={key: len(after[key]) for key in ['sectors', 'lines', 'vertices', 'things']},
                  geometry={k: v for k, v in geometry.items() if k != 'planes'},
                  original_boundaries_preserved=len(old_lines), added_boundaries=len(new_lines)-len(old_lines),
                  things_equal=True, original_cell_values_equal=True, original_compiler_byte_identical=True,
                  original_arena=old_arena, candidate_arena=new_arena, brick_option=brick,
                  material_aliases=config['material_aliases'] if brick else {},
                  scope=config['review_change'], launch_scope=config['launch_scope'])
    (output/'MANIFEST.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8', newline='\n')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--brick', action='store_true')
    args = parser.parse_args()
    report = build(args.runtime.resolve(strict=True), args.output, args.brick)
    print(json.dumps({k: report[k] for k in ['overlay_sha256', 'original_geometry', 'candidate_geometry', 'added_boundaries']}))
