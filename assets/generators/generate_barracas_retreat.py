"""Build deterministic ground flow fields toward the three southern exits.

The offline breadth-first search uses the assembled floor/headroom geometry,
including public shop/factory interiors. Runtime lookup does not scan actors or
search the complete map. Dynamic bodies still require native local avoidance.
"""
from collections import deque
from pathlib import Path
import argparse
import hashlib
import json
from generate_barracas_map import ROOT, assemble, read


def outputs(out):
    port, layout, *_ = assemble(out, compile_map=False)
    body = read('assets/map02_maze/LAYOUT.json')
    fronts = read('assets/barracas_redesign/FRONTS.json')
    cell = port.CELL
    usable = {p for p, v in port.cells.items() if v[0] == 0
              and (not v[4] or port.volumes[v[4]][0] >= body['largest_supported_height'])}
    bounds = [min(p[0] for p in usable), min(p[1] for p in usable),
              max(p[0] for p in usable) + cell, max(p[1] for p in usable) + cell]
    rows = []
    fields = []
    depths = []
    # Each direction points from a discovered cell back toward its BFS parent.
    adjacent = [(cell, 0, 'W'), (-cell, 0, 'E'), (0, cell, 'S'), (0, -cell, 'N')]
    for front in fronts['fronts']:
        start = tuple(int(c // cell) * cell for c in front['exit'][:2])
        assert start in usable, ('southern exit is not ground', front['id'], start)
        queue = deque([start]); flow = {start: 'G'}; distance = {start: 0}
        while queue:
            x, y = queue.popleft()
            for dx, dy, direction in adjacent:
                point = (x + dx, y + dy)
                if point not in usable or point in flow: continue
                flow[point] = direction; distance[point] = distance[(x, y)] + 1; queue.append(point)
        field = [''.join(flow.get((x, y), '.') for x in range(bounds[0], bounds[2], cell))
                 for y in range(bounds[1], bounds[3], cell)]
        fields.append(field)
        depths.append([[distance.get((x, y), -1) for x in range(bounds[0], bounds[2], cell)]
                       for y in range(bounds[1], bounds[3], cell)])
        rows.append({'front': front['id'], 'gate_index': front['gate_index'], 'goal_cell': start,
                     'reachable_cells': len(flow), 'unreachable_cells': len(usable - flow.keys()),
                     'maximum_grid_steps': max(distance.values()), 'rows': field})
    assert all(r['reachable_cells'] == rows[0]['reachable_cells'] for r in rows)
    digits = len(f"{max(r['maximum_grid_steps'] for r in rows) + 1:x}")
    unreachable = 16 ** digits - 1
    for row, depth in zip(rows, depths):
        row['distance_rows'] = [''.join(f'{(n if n >= 0 else unreachable):0{digits}x}' for n in line) for line in depth]
    data = {'schema_revision': 4, 'issue': 454, 'geometry_revision': layout['geometry_revision'],
            'scope': 'Static ground flow fields to southern exits after victory opens the gates; elevated layers require their existing descent routes. No automatic gate opening or dynamic collision exemption.',
            'cell': cell, 'bounds': bounds, 'clearance_height': body['largest_supported_height'],
            'distance_digits': digits, 'distance_unreachable': unreachable,
            'usable_cells': len(usable), 'fields': rows,
            'source_sha256': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in (
                'assets/barracas_redesign/LAYOUT.json', 'assets/barracas_redesign/SIEGE.json',
                'assets/barracas_redesign/RAM_CREWS.json', 'assets/barracas_redesign/FRONTS.json',
                'assets/map02_maze/LAYOUT.json')}}
    code = '// Flujo de suelo generado; los cuerpos conservan su colision nativa.\nclass CaelumBarracasRetreatData : Object play\n{\n'
    code += f'    const REVISION=4;\n    const CELL={cell};\n    const MIN_X={bounds[0]};\n    const MIN_Y={bounds[1]};\n    const COLUMNS={(bounds[2]-bounds[0])//cell};\n'
    code += f'    const DISTANCE_DIGITS={digits};\n    const UNREACHABLE_DISTANCE={unreachable};\n'
    code += '    static String Row(int front,int row){switch(front){' + ''.join(f'case {i}:return F{i}(row);' for i in range(len(rows))) + '}return "";}\n'
    code += '    static String DistanceRow(int front,int row){switch(front){' + ''.join(f'case {i}:return D{i}(row);' for i in range(len(rows))) + '}return "";}\n'
    tables = [(f'F{i}', field) for i, field in enumerate(fields)]
    tables += [(f'D{i}', row['distance_rows']) for i, row in enumerate(rows)]
    for prefix, field in tables:
        # GZDoom allocates a return register per string switch case. Keep each
        # generated function below the native register limit.
        chunks = (len(field) + 63) // 64
        code += f'    static String {prefix}(int row){{switch(row/64){{'
        code += ''.join(f'case {chunk}:return {prefix}_{chunk}(row);' for chunk in range(chunks))
        code += '}return "";}\n'
        for chunk in range(chunks):
            code += f'    static String {prefix}_{chunk}(int row){{switch(row){{\n'
            code += ''.join(f'        case {n}:return "{field[n]}";\n'
                            for n in range(chunk * 64, min((chunk + 1) * 64, len(field))) if field[n].strip('.'))
            code += '        }return "";}\n'
    code += '''    static String Direction(int lane,vector3 point)
    {
        int x=int(Floor((point.X-MIN_X)/CELL)),y=int(Floor((point.Y-MIN_Y)/CELL));
        String row=Row(lane/2,y);
        if(x<0 || x>=int(row.Length()))return ".";
        return row.Mid(x,1);
    }
    static vector3 Centre(vector3 point)
    {return (MIN_X+Floor((point.X-MIN_X)/CELL)*CELL+CELL/2,MIN_Y+Floor((point.Y-MIN_Y)/CELL)*CELL+CELL/2,0);}
    static int Distance(int lane,vector3 point)
    {
        int x=int(Floor((point.X-MIN_X)/CELL)),y=int(Floor((point.Y-MIN_Y)/CELL));
        String row=DistanceRow(lane/2,y);
        if(x<0 || (x+1)*DISTANCE_DIGITS>int(row.Length()))return -1;
        int value=row.Mid(x*DISTANCE_DIGITS,DISTANCE_DIGITS).ToInt(16);
        return value==UNREACHABLE_DISTANCE ? -1 : value;
    }
    static vector3 Next(int lane,vector3 point)
    {
        String direction=Direction(lane,point);vector3 centre=Centre(point);
        if(direction=="E")return centre+(CELL,0,0);
        if(direction=="W")return centre-(CELL,0,0);
        if(direction=="N")return centre+(0,CELL,0);
        if(direction=="S")return centre-(0,CELL,0);
        return centre;
    }
}
'''
    islands = []
    for x, y in sorted(usable - flow.keys()):
        buildings = [b['id'] for b in layout['buildings']
                     if b['bounds'][0] <= x < b['bounds'][2] and b['bounds'][1] <= y < b['bounds'][3]]
        islands.append({'cell': [x, y], 'buildings': buildings})
    report = {'usable_cells': len(usable), 'bounds': bounds, 'unreachable_ground': islands,
              'fronts': [{k: v for k, v in row.items() if k not in ('rows', 'distance_rows')} for row in rows]}
    return {'assets/barracas_redesign/RETREAT.json': (json.dumps(data, indent=2) + '\n').encode(),
            'src/caelum/world/CaelumBarracasRetreatData.zs': code.encode()}, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args(); out = args.output.resolve(); out.relative_to(ROOT / 'build')
    generated, report = outputs(out)
    for name, data in generated.items():
        path = ROOT / name
        if args.check:
            if not path.is_file() or path.read_bytes() != data: raise SystemExit('Stale retreat data: ' + name)
        else: path.write_bytes(data)
    (out / 'retreat-report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k != 'unreachable_ground'}))


if __name__ == '__main__':
    main()
