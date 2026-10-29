"""Export deterministic mansion bathroom placements without modifying maps/art."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads((ROOT / 'assets/map01_mansion/BATHROOMS.json').read_text(encoding='utf-8'))
ROOMS = json.loads((ROOT / 'assets/map01_mansion/CARTOGRAPHY.json').read_text(encoding='utf-8'))
rooms = {r['id']: r for r in ROOMS['rooms']}
fixtures = DATA['fixtures']
assert len(fixtures) == 12
for fixture in fixtures:
    room = rooms[fixture['room']]
    x, y, z = fixture['position']
    x0, y0, x1, y1 = room['bounds']
    assert x0 < x < x1 and y0 < y < y1 and z == room['floor']
    assert fixture['kind'] in (0, 1, 2)
lines = ['// #410: generado desde assets/map01_mansion/BATHROOMS.json.',
         'class CaelumMansionBathroomData : Object', '{',
         f'    const REVISION={DATA["revision"]};', f'    const COUNT={len(fixtures)};']
for name, result_type, default in [('Position', 'vector3', '(0,0,0)'), ('Facing', 'double', '0'), ('Kind', 'int', '-1')]:
    lines += [f'    static clearscope {result_type} {name}(int index)', '    {', '        switch(index)', '        {']
    for index, fixture in enumerate(fixtures):
        value = '(' + ','.join(map(str, fixture['position'])) + ')' if name == 'Position' else str(fixture['facing' if name == 'Facing' else 'kind'])
        lines.append(f'            case {index}:return {value};')
    lines += ['        }', f'        return {default};', '    }']
lines += ['}', '']
target = ROOT / 'src/caelum/data/CaelumMansionBathroomData.zs'
target.write_bytes('\n'.join(lines).encode('utf-8'))
print('Generated twelve mansion fixture placements; map and artwork unchanged.')
