"""Derive known-only tactical entry regions from the existing authored city."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent


def render(root=ROOT):
    city = json.loads((root / 'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    routes = [('west-flank', 'CA_TACTICS_WEST', city['exterior_ground'][0], 0)]
    for stair in city['access_stairs']:
        first = stair['steps'][0]
        routes.append((stair['name'], 'CA_TACTICS_STAIRS', first[:4], first[4]))
    source = ['// Generado desde CITY.json; no modifica la geometría ni revela recorridos.',
              'class CaelumBattleRouteData : Object', '{', f'    const COUNT={len(routes)};',
              '    static bool Contains(int id,vector3 p)', '    {', '        switch(id)', '        {']
    for i, (_, _, (x1, y1, x2, y2), z) in enumerate(routes):
        source.append(f'        case {i}:return p.X>={x1:g} && p.X<={x2:g} && p.Y>={y1:g} && p.Y<={y2:g} && Abs(p.Z-{z:g})<=1;')
    source += ['        }', '        return false;', '    }', '    static String Id(int id)', '    {', '        switch(id)', '        {']
    source += [f'        case {i}:return "battle-route-{name}";' for i, (name, _, _, _) in enumerate(routes)]
    source += ['        }', '        return "";', '    }', '    static String NameKey(int id)',
               '    {return id==0?"CA_TACTICS_WEST":"CA_TACTICS_STAIRS";}', '}', '']
    return '\n'.join(source).encode('utf-8')


if __name__ == '__main__':
    (ROOT / 'src/caelum/data/CaelumBattleRouteData.zs').write_bytes(render())
