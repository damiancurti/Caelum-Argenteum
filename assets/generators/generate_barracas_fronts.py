"""Derive the approved three-front machine approaches from retained geometry.

Six stable machine slots remain south/south/east/east/west/west. The first
slot of each pair is active and the second is reserve; slot5 remains large.
Distances reuse existing staging, walkway and artillery separation data.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[2]
INPUTS = ['assets/barracas_redesign/LAYOUT.json', 'assets/map06_port/SOUTH.json',
          'assets/map06_port/CITY.json', 'assets/map06_port/LAYOUT.json']


def vector(point):
    return '(' + ','.join(f'{n:g}' for n in point) + ')'


def outputs():
    layout, south, city, old = [json.loads((ROOT / p).read_text(encoding='utf-8')) for p in INPUTS]
    gates = layout['gates']
    gap = abs(south['gate_y'] - south['ram_start_y'])
    standoff = abs(south['gate_y'] - south['attacking_gun_y'])
    spacing = city['walk_width'] * 2
    fronts = []
    for name in ('south', 'east', 'west'):
        index = next(i for i, g in enumerate(gates) if g['id'] == name)
        gate = gates[index]
        x, y, _ = gate['position']
        angle = math.radians(gate['outward_angle'])
        nx, ny = round(math.cos(angle)), round(math.sin(angle))
        road = x + nx * standoff
        front = {'id': name, 'gate_index': index, 'rams': [], 'guns': []}
        for reserve in (False, True):
            slot = len(fronts) * 2 + int(reserve)
            start = [x, y - gap - int(reserve) * spacing, 0] if name == 'south' else [road, south['formation_y'] - int(reserve) * spacing, 0]
            route = [] if name == 'south' else [[road, y - spacing * 2, 0], [x + nx * gap, y - spacing * 2, 0], [x + nx * gap, y, 0]]
            # The final contact point is scaled by the unchanged ram profile at runtime.
            front['rams'].append({'slot': slot, 'reserve': reserve, 'large': slot == 5,
                                  'start': start, 'start_angle': 90, 'waypoints': route})
            side = old['defending_gun_dx'] * (-1 if not reserve else 1)
            front['guns'].append({'slot': slot, 'position': [x + nx * standoff - ny * side, y + ny * standoff + nx * side, 0],
                                  'angle': (gate['outward_angle'] + 180) % 360})
        front['exit'] = [x if name == 'south' else road, south['exit_y'], 0]
        fronts.append(front)
    data = {'schema_revision': 1, 'issue': 454, 'geometry_revision': layout['geometry_revision'],
            'authority': 'Author approved three assault fronts, six rams (one active/one reserve per front), existing force counts and four gate materials on 2026-11-12.',
            'status': 'Generated revision4 fronts; LAYOUT.json owns production activation.',
            'source_sha256': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in INPUTS},
            'gates': gates, 'fronts': fronts}
    code = '// Generado desde los tres frentes aprobados y distancias existentes.\nclass CaelumBarracasFrontData : Object play\n{\n    const REVISION=1;\n    const GATE_COUNT=4;\n    const RAM_COUNT=6;\n'
    rams = [r for f in fronts for r in f['rams']]
    guns = [r for f in fronts for r in f['guns']]
    methods = [('GatePoint', 'vector3', [vector(g['position']) for g in gates]),
               ('GateName', 'String', ['"CA_POI_PORT_GATE_' + {'north':'6','west':'7','east':'EAST','south':'SOUTH'}[g['id']] + '"' for g in gates]),
               ('GateOutward', 'double', [g['outward_angle'] for g in gates]),
               ('GateMaterial', 'int', [g['material'] for g in gates]),
               ('GateForLane', 'int', [f['gate_index'] for f in fronts for _ in f['rams']]),
               ('RamStart', 'vector3', [vector(r['start']) for r in rams]),
               ('RamStartAngle', 'double', [r['start_angle'] for r in rams]),
               ('RamLarge', 'bool', [str(r['large']).lower() for r in rams]),
               ('RamReserve', 'bool', [str(r['reserve']).lower() for r in rams]),
               ('RamPointCount', 'int', [len(r['waypoints']) for r in rams]),
               ('GunPoint', 'vector3', [vector(r['position']) for r in guns]),
               ('GunAngle', 'double', [r['angle'] for r in guns]),
               ('ExitPoint', 'vector3', [vector(f['exit']) for f in fronts for _ in f['rams']])]
    for name, kind, values in methods:
        code += f'    static {kind} {name}(int i){{switch(i){{' + ''.join(f'case {i}:return {v};' for i, v in enumerate(values)) + f'}}return {values[0]};}}\n'
    code += '    static vector3 RamPoint(int lane,int i){switch(lane){\n'
    for r in rams:
        if not r['waypoints']:
            continue
        code += f'        case {r["slot"]}:switch(i){{' + ''.join(f'case {i}:return {vector(p)};' for i, p in enumerate(r['waypoints'])) + '}break;\n'
    code += '        }return RamStart(lane);}\n}\n'
    return {'assets/barracas_redesign/FRONTS.json': (json.dumps(data, indent=2) + '\n').encode(),
            'src/caelum/world/CaelumBarracasFrontData.zs': code.encode()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    for name, data in outputs().items():
        path = ROOT / name
        if args.check:
            if not path.is_file() or path.read_bytes() != data:
                raise SystemExit('Stale front data: ' + name)
        else:
            path.write_bytes(data)
    print('Three fronts; four gates; six ram slots; six attacking guns.')


if __name__ == '__main__':
    main()
