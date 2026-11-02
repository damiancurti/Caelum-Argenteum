"""Generate issue #234 geometry data without modifying maps or spawning content."""
from pathlib import Path
import hashlib
import json
import struct
import argparse
import zipfile
try:
    from .map_catalogue import map_name
except ImportError:
    from map_catalogue import map_name

ROOT = Path(__file__).resolve().parents[2]


def map_checksum(name, root=ROOT):
    return wad_checksum(root / 'src/maps' / (name + '.wad'))


def wad_checksum(path):
    return blob_checksum(path.read_bytes())


def blob_checksum(data):
    _, count, directory = struct.unpack_from('<4sii', data)
    for i in range(count):
        start, size, lump = struct.unpack_from('<ii8s', data, directory + i * 16)
        if lump.rstrip(b'\0') == b'TEXTMAP':
            return hashlib.md5(data[start:start + size]).hexdigest()
    raise ValueError(f'Missing TEXTMAP: {path}')


def render(root=ROOT):
    mansion = json.loads((root / 'assets/map01_mansion/CARTOGRAPHY.json').read_text(encoding='utf-8'))
    city = json.loads((root / 'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    interiors = json.loads((root / 'assets/map06_port/INTERIORS.json').read_text(encoding='utf-8'))
    if map_checksum('MAP01', root) != mansion['map_checksum']:
        raise ValueError('MAP01 geometry changed: review CARTOGRAPHY.json room bounds before regeneration.')
    rooms = mansion['rooms']
    lines = ['// Generado por assets/generators/generate_cartography_catalogue.py.',
             '// La suma nativa identifica la geometrÃ­a cargada, tambiÃ©n en hubs antiguos.',
             'class CaelumCartographyCatalogueData : Object', '{']
    for name in ['MAP01', 'MAP02', 'MAP06']:
        current = map_name('port', root) if name=='MAP06' else name
        lines.append(f'    const {name}_CHECKSUM = "{map_checksum(current, root)}";')
    # The water installation changes only exterior geometry; room IDs/bounds stay valid.
    legacy_mansion = wad_checksum(root/'assets/map01_mansion/legacy_581/MAP01.wad')
    lines += [f'    const MAP01_LEGACY_CHECKSUM = "{legacy_mansion}";',
              f'    const MAP01_PREJUSTICE_CHECKSUM = "{mansion["pre_justice_checksum"]}";',
              f'    const MAP01_PREEXAMPLES_CHECKSUM = "{mansion["pre_examples_checksum"]}";',
              '    static bool MatchesMansionGeometry(String checksum)', '    {',
              '        return checksum==MAP01_CHECKSUM || checksum==MAP01_LEGACY_CHECKSUM || checksum==MAP01_PREJUSTICE_CHECKSUM || checksum==MAP01_PREEXAMPLES_CHECKSUM;',
              '    }']
    # Both layouts share exactly the same authored POI coordinates and IDs.
    furnished = wad_checksum(root/'assets/map06_port/legacy_5427/MAP06.wad')
    with zipfile.ZipFile(root/'assets/tarot_justice/legacy_5133.zip') as legacy:
        prejustice_city=blob_checksum(legacy.read(map_name('port',root)+'.wad'))
        assert blob_checksum(legacy.read('MAP01.wad'))==mansion['pre_justice_checksum']
    lines += [f'    const MAP06_FURNISHED_CHECKSUM = "{furnished}";',
              f'    const MAP06_PREJUSTICE_CHECKSUM = "{prejustice_city}";',
              '    static bool MatchesCityGeometry(String checksum)', '    {',
              '        return checksum==MAP06_CHECKSUM || checksum==MAP06_FURNISHED_CHECKSUM || checksum==MAP06_PREJUSTICE_CHECKSUM;',
              '    }']
    lines += [f'    const MANSION_ROOMS = {len(rooms)};',
              '    static bool MansionContains(int index,Vector3 point)', '    {',
              '        switch(index)', '        {']
    for i, room in enumerate(rooms):
        x0, y0, x1, y1 = room['bounds']
        lines.append(f'        case {i}: return point.X>{x0} && point.X<{x1} && point.Y>{y0} && point.Y<{y1} && point.Z>={room["floor"]} && point.Z<{room["ceiling"]};')
    lines += ['        }', '        return false;', '    }']
    for fn, field in [('MansionId', 'id'), ('MansionName', 'key')]:
        lines += [f'    static String {fn}(int index)', '    {', '        switch(index)', '        {']
        for i, room in enumerate(rooms):
            lines.append(f'        case {i}: return "{room[field]}";')
        lines += ['        }', '        return "";', '    }']
    lines += ['    static Vector3 MansionPosition(int index)', '    {', '        switch(index)', '        {']
    for i, room in enumerate(rooms):
        x0, y0, x1, y1 = room['bounds']
        lines.append(f'        case {i}: return ({(x0+x1)/2:g},{(y0+y1)/2:g},{room["floor"]});')
    lines += ['        }', '        return (0,0,0);', '    }',
              '    static bool TowerContains(int index,Vector3 point)', '    {', '        switch(index)', '        {']
    towers = city['towers']
    for i, tower in enumerate(towers):
        x, y = tower['origin']; width = city['tower_size']
        lines.append(f'        case {i}: return point.X>{x} && point.X<{x+width} && point.Y>{y} && point.Y<{y+width} && point.Z>={city["walk_height"]} && point.Z<={city["tower_deck_height"]+city["tower_parapet"]};')
    lines += ['        }', '        return false;', '    }',
              '    static Vector3 TowerPosition(int index)', '    {', '        switch(index)', '        {']
    for i, tower in enumerate(towers):
        x, y = tower['origin']; half = city['tower_size']/2
        lines.append(f'        case {i}: return ({x+half:g},{y+half:g},{city["tower_deck_height"]});')
    lines += ['        }', '        return (0,0,0);', '    }']
    # Use the existing interior generator's factory ordering and station slots.
    # IDs use authored building IDs and station kinds, never mutable actor positions.
    lines += ['    static String CityStationId(Vector3 spawnPoint)', '    {']
    factories = [building for building in city['buildings'] if building['kind'] == 'factory']
    for i, building in enumerate(factories):
        profile = interiors['factory_profiles'][i % len(interiors['factory_profiles'])]
        for j, kind in enumerate(profile['stations']):
            dx, dy = interiors['station_positions'][j]
            x, y = building['bounds'][0] + dx, building['bounds'][1] + dy
            lines.append(f'        if(spawnPoint==({x},{y},0))return "city-factory-{building["id"]}-{kind}";')
    lines += ['        return "";', '    }']
    east = next(gate for gate in city['gates'] if gate['name'] == 'east')
    x0, y0, x1, y1 = east['bounds']; mid = (x0+x1)/2
    lines += [f'    static Vector3 EastPosition() {{ return ({mid:g},{(y0+y1)/2:g},0); }}',
              '    static bool CrossesEast(Vector3 before,Vector3 after)', '    {',
              f'        if((before.X<{mid:g})==(after.X<{mid:g}) || before.X==after.X)return false;',
              f'        Vector3 crossing=before+(after-before)*(({mid:g}-before.X)/(after.X-before.X));',
              f'        return crossing.Y>{y0} && crossing.Y<{y1} && crossing.Z>=0 && crossing.Z<{city["gate_headroom"]};',
              '    }', '}']
    return ('\n'.join(lines)+'\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Reject stale output without writing files.')
    args = parser.parse_args()
    output = ROOT / 'src/caelum/data/CaelumCartographyCatalogueData.zs'
    expected = render()
    if args.check:
        if not output.is_file() or output.read_bytes() != expected:
            raise SystemExit('Stale cartography catalogue; run python assets/generators/generate_cartography_catalogue.py')
    else:
        output.write_bytes(expected)


if __name__ == '__main__':
    main()
