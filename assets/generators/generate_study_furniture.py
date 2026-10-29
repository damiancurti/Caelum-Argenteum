"""Export original portable study meshes and their explicit construction bills."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD, METAL

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/art_source/study_furniture'
DATA = json.loads((ART / 'DATA.json').read_text(encoding='utf-8'))

def generate():
    folder = ROOT / 'src/models/caelum/props/study'
    folder.mkdir(parents=True, exist_ok=True)
    rows = []
    for row in DATA['variants']:
        mesh = Mesh()
        masses = {'wood': 0.0, 'iron': 0.0}
        for member in row['members']:
            material = member['material']
            masses[material] += math.prod(member['size']) * DATA[material + '_density']
            mesh.add_box(WOOD if material == 'wood' else METAL,
                tuple(v * DATA['units_per_meter'] for v in member['center']),
                tuple(v * DATA['units_per_meter'] for v in member['size']))
        path = folder / ('ca_study_' + row['name'] + '.obj')
        mesh.write(path)
        path.write_text(path.read_text(encoding='utf-8').replace('o CaelumStashChest', 'o CaelumStudy' + row['name']), encoding='utf-8', newline='\n')
        rows.append(dict(row, mass=sum(masses.values()), material_kg=masses,
            recipe_grams={k:math.ceil(v*1000) for k,v in masses.items()},
            sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    (ART/'GENERATED.json').write_text(json.dumps({'issue':410,'models':rows},indent=2)+'\n',encoding='utf-8')
    lines=['// #410: geometria y materiales de assets/art_source/study_furniture/DATA.json.',
           'class CaelumStudyData : Object','{','    const REVISION=1;']
    lines += [f'    const DESK_RADIUS={math.hypot(rows[0]["width"],rows[0]["depth"])*16:.9f};',f'    const DESK_HEIGHT={rows[0]["height"]*32:.9f};']
    for method,key,scale in [('Width','width',32),('Depth','depth',32),('Height','height',32),('Mass','mass',1)]:
        lines.append(f'    static clearscope double {method}(int k){{return k==0?{rows[0][key]*scale:.9f}:{rows[1][key]*scale:.9f};}}')
    for method,key in [('Wood','wood'),('Iron','iron')]:
        lines.append(f"    static clearscope int {method}(int k){{return k==0?{rows[0]['recipe_grams'][key]}:{rows[1]['recipe_grams'][key]};}}")
    lines += ['    static clearscope double Radius(int k){double w=Width(k),d=Depth(k);return Sqrt(w*w+d*d)/2;}','}']
    (ROOT/'src/caelum/data/CaelumStudyData.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(json.dumps([{'name':r['name'],'mass':r['mass'],'recipe_grams':r['recipe_grams']} for r in rows]))

if __name__ == '__main__':
    generate()
