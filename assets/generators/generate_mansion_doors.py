"""Reuse the original siege leaf mesh at existing mansion doorway dimensions."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
data = json.loads((ROOT/'assets/map01_mansion/DOORS.json').read_text(encoding='utf-8'))
assert data['siege_variant']=='wood', 'Only the approved wood variant is authored.'
SPEC = json.loads((ROOT/'assets/generators/siege_visuals.json').read_text(encoding='utf-8'))
source = ROOT/'src/models/caelum/siege/ca_siege_gate_intact.obj'
vertices=[];uvs=[];faces=[];material=''
for line in source.read_text(encoding='utf-8').splitlines():
    words=line.split()
    if not words:continue
    if words[0]=='v':vertices.append(tuple(map(float,words[1:])))
    elif words[0]=='vt':uvs.append(line)
    elif words[0]=='usemtl':material=words[1]
    elif words[0]=='f':
        indices=[int(word.split('/')[0])-1 for word in words[1:]]
        if 'stone' not in material and all(vertices[i][0]<0 for i in indices):
            faces.append((material,words[1:]))
half = SPEC['gate']['opening_metres'][0] * SPEC['map_units_per_metre'] / 2
height = SPEC['gate']['opening_metres'][1] * SPEC['map_units_per_metre']
used=sorted({int(word.split('/')[0])-1 for _,face in faces for word in face})
remap={old:new+1 for new,old in enumerate(used)}
output=['# Original siege wood leaf adapted for MAP01 issue #36.', 'o ca_mansion_door']
for i in used:
    x,y,z=vertices[i]
    output.append(f"v {(x+half/2)*data['width']/half:.6f} {y*data['height']/height:.6f} {z:.6f}")
output+=uvs
# GZDoom creates a surface for every usemtl, even if the name is repeated.
# Group opaque faces by material to keep surface skin lookup within its limit.
materials=sorted({material for material,_ in faces})
assert len(materials)<=data['engine_surface_limit'], 'Too many model surfaces for GZDoom 4.14.2.'
for material in materials:
    output.append('usemtl '+material)
    for face_material,face in faces:
        if face_material==material:
            output.append('f '+' '.join(str(remap[int(word.split('/')[0])-1])+'/'+word.split('/')[1] for word in face))
(ROOT/'src/models/caelum/siege/ca_mansion_door.obj').write_text('\n'.join(output)+'\n',encoding='utf-8')
code = '// Datos generados desde assets/map01_mansion/DOORS.json y siege_visuals.json.\n'
code += 'class CaelumMansionDoorData : Object\n{\n'
for key,value in [('HALF_WIDTH',data['width']/2),('OPEN_DEGREES',data['open_degrees']),('SWEEP_RADIUS',data['sweep_radius'])]:
    code += f'    const {key} = {value};\n'
code += '}\n'
(ROOT/'src/caelum/world/CaelumMansionDoorData.zs').write_text(code,encoding='utf-8')
print('Generated mansion leaf:',len(faces),'faces')
