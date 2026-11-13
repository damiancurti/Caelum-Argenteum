"""Derive southern infantry and artillery-crew approaches for the three fronts.

Side-front pedestrians use the outside edge of the existing staging strip to
pass waiting rams. All distances are geometry derived from the retained city
walkway width, artillery spacing and operator offset; no combat profile changes.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[2]
INPUTS = ['assets/barracas_redesign/FRONTS.json', 'assets/map06_port/SOUTH.json',
          'assets/map06_port/CITY.json', 'assets/map06_port/LAYOUT.json']


def vector(point):
    return '(' + ','.join(f'{n:g}' for n in point) + ')'


def outputs():
    fronts, south, city, old = [json.loads((ROOT / p).read_text(encoding='utf-8')) for p in INPUTS]
    spacing = city['walk_width'] * 2
    rows = []
    for front in fronts['fronts']:
        gate = fronts['gates'][front['gate_index']]
        a = math.radians(gate['outward_angle']); nx, ny = round(math.cos(a)), round(math.sin(a))
        road = front['rams'][0]['start'][0]
        outer = road + nx * spacing
        for ram, gun in zip(front['rams'], front['guns']):
            lane = ram['slot']
            entry = [outer, south['formation_y'], 0]
            infantry = [entry]
            if front['id'] != 'south':
                infantry += [[outer, ram['waypoints'][0][1], 0], *ram['waypoints'][1:]]
            infantry += [gate['position']]
            if front['id'] == 'south':
                start_x = gun['position'][0]
                gun_path = [[start_x, south['formation_y'], 0], [start_x, gun['position'][1] - spacing, 0]]
            else:
                start_x = outer
                gun_path = [entry, [outer, gun['position'][1] - spacing, 0]]
            starts = []
            for slot in range(2):
                side = old['operator_side'] * (-1 if slot == 0 else 1)
                starts.append([start_x - ny * side if nx == 0 else start_x,
                               south['formation_y'] - (2 + lane % 2) * spacing + (nx * side if nx else 0), 0])
            rows.append({'lane': lane, 'front': front['id'], 'infantry': infantry,
                         'gun_approach': gun_path, 'gun_crew_start': starts,
                         'gun_final_approach_offset': [nx * old['operator_side'] * 2, ny * old['operator_side'] * 2, 0]})
    data = {'schema_revision': 1, 'issue': 454, 'geometry_revision': fronts['geometry_revision'],
            'status': 'Southern pedestrian approach candidate; native movement and crowd checks required.',
            'entry_line_y': south['formation_y'], 'lanes': rows,
            'source_sha256': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in INPUTS}}
    code = '// Marchas desde el campo sur, derivadas de la geometria aprobada.\nclass CaelumBarracasMarchData : Object play\n{\n    const REVISION=1;\n'
    code += f'    const ENTRY_LINE_Y={south["formation_y"]};\n'
    for name, key in [('Infantry', 'infantry'), ('Gun', 'gun_approach')]:
        code += f'    static int {name}Count(int lane){{switch(lane){{' + ''.join(f'case {r["lane"]}:return {len(r[key])};' for r in rows) + '}return 0;}\n'
        code += f'    static vector3 {name}Point(int lane,int step){{switch(lane){{\n'
        for row in rows:
            code += f'        case {row["lane"]}:switch(step){{' + ''.join(f'case {i}:return {vector(p)};' for i, p in enumerate(row[key])) + '}break;\n'
        code += '        }return (0,0,0);}\n'
    code += '    static vector3 GunCrewStart(int lane,int slot){switch(lane){\n'
    for row in rows:
        code += f'        case {row["lane"]}:return slot==0?{vector(row["gun_crew_start"][0])}:{vector(row["gun_crew_start"][1])};\n'
    code += '        }return (0,0,0);}\n'
    code += '    static vector3 GunApproachOffset(int lane){switch(lane){' + ''.join(f'case {r["lane"]}:return {vector(r["gun_final_approach_offset"])};' for r in rows) + '}return (0,0,0);}\n}\n'
    return {'assets/barracas_redesign/MARCH.json': (json.dumps(data, indent=2) + '\n').encode(),
            'src/caelum/world/CaelumBarracasMarchData.zs': code.encode()}


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--check', action='store_true'); args = parser.parse_args()
    for name, data in outputs().items():
        path = ROOT / name
        if args.check:
            if not path.is_file() or path.read_bytes() != data: raise SystemExit('Stale march data: ' + name)
        else: path.write_bytes(data)
    print('Six infantry lanes and12 southern artillery-crew starts derived.')


if __name__ == '__main__':
    main()
