"""Rebuild the owned chair/cot at documented human scale; retain sleeping bags."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD, METAL, INSIDE
from furniture_bedding import bedding

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/art_source/basic_rest_furniture'
DATA = json.loads((ART / 'DATA.json').read_text(encoding='utf-8'))
MATERIALS = {'wood': WOOD, 'iron': METAL, 'cloth': INSIDE}

def construction(kind):
    mesh = Mesh()
    mass = dict.fromkeys(MATERIALS, 0.0)
    for part in DATA[kind]['members']:
        material, size = part['material'], list(part['size'])
        center=list(part['center'])
        if kind=='bed':
            if material=='cloth':continue
            lower=DATA['bedding']['mattress_thickness_m']
            if material=='wood' and size[1]>.4 and size[0]<.1:
                size[1]-=lower;center[1]-=lower/2
            elif center[1]<DATA[kind]['surface']:center[1]-=lower

        mesh.add_box(MATERIALS[material], tuple(v*DATA['units_per_meter'] for v in center),
                     tuple(v*DATA['units_per_meter'] for v in size))
        if material == 'cloth':
            # A fitted textile face, including the existing folded head support;
            # no new stuffing or foam material is inferred from visual thickness.
            mass[material] += math.prod(sorted(size)[1:])*DATA['cloth_kg_m2']
        else:
            mass[material] += math.prod(size)*DATA[material+'_density']
    if kind=='bed':
        mass['cloth']+=bedding(mesh,DATA[kind]['width'],DATA[kind]['depth'],DATA[kind]['surface'],DATA['bedding'],DATA['units_per_meter'],DATA['cloth_kg_m2'])
    return mesh, mass

def generate():
    rows = []
    for kind in ('chair', 'bed'):
        mesh, mass = construction(kind)
        path = ROOT / f'src/models/caelum/props/rest/ca_rest_{kind}.obj'
        mesh.write(path)
        path.write_text(path.read_text().replace('o CaelumStashChest', 'o CaelumRest'+kind.title()), encoding='utf-8', newline='\n')
        row = {k: v for k, v in DATA[kind].items() if k != 'members'}
        row.update(kind=kind, material_kg=mass, empty_kg=sum(mass.values()),
                   recipe_grams={k: math.ceil(v*1000) for k, v in mass.items()},
                   sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        rows.append(row)
    (ART/'GENERATED.json').write_text(json.dumps({'models': rows, 'mass_method': 'Sum of modeled members, including joint overlaps; textile face area. Design construction estimates, not measured museum masses.'}, indent=2)+'\n', encoding='utf-8')
    lines = ['// #410: generado desde basic_rest_furniture/DATA.json.', 'class CaelumBasicRestData : Object', '{', '    const REVISION=2;']
    for row in rows:
        for name, value in [('RADIUS', math.hypot(row['width'], row['depth'])/2*DATA['units_per_meter']),
                            ('HEIGHT', row['height']*DATA['units_per_meter']),
                            ('SURFACE', row['surface']*DATA['units_per_meter']), ('MASS', row['empty_kg'])]:
            lines.append(f"    const {row['kind'].upper()}_{name}={value:.9f};")
    for material in MATERIALS:
        lines.append(f"    static clearscope int {material.title()}(int kind){{return kind==0?{rows[0]['recipe_grams'][material]}:{rows[1]['recipe_grams'][material]};}}")
    lines += ['}', '']
    (ROOT/'src/caelum/data/CaelumBasicRestData.zs').write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    print(json.dumps(rows))

if __name__ == '__main__':
    generate()
