"""Compare generated door faces/UVs with their original siege-leaf source."""
import json


def read_obj(path):
    vertices=[];uvs=[];faces=[];surfaces=[];material=''
    for line in path.read_text(encoding='utf-8').splitlines():
        words=line.split()
        if not words:continue
        if words[0]=='v':vertices.append(tuple(map(float,words[1:])))
        elif words[0]=='vt':uvs.append(tuple(map(float,words[1:])))
        elif words[0]=='usemtl':material=words[1];surfaces.append(material)
        elif words[0]=='f':
            face=[]
            for word in words[1:]:
                vi,ti=map(int,word.split('/')[:2]);face.append((vertices[vi-1],uvs[ti-1]))
            faces.append((material,tuple(face)))
    return surfaces,faces


def check_door_model(root):
    data=json.loads((root/'assets/map01_mansion/DOORS.json').read_text(encoding='utf-8'))
    spec=json.loads((root/'assets/generators/siege_visuals.json').read_text(encoding='utf-8'))
    _,original=read_obj(root/'src/models/caelum/siege/ca_siege_gate_intact.obj')
    surfaces,actual=read_obj(root/'src/models/caelum/siege/ca_mansion_door.obj')
    half=spec['gate']['opening_metres'][0]*spec['map_units_per_metre']/2
    height=spec['gate']['opening_metres'][1]*spec['map_units_per_metre']
    expected=[]
    for material,face in original:
        if 'stone' in material or not all(point[0][0]<0 for point in face):continue
        adapted=tuple(((round((x+half/2)*data['width']/half,6),
                        round(y*data['height']/height,6),round(z,6)),uv) for (x,y,z),uv in face)
        expected.append((material,adapted))
    return {
        'door has one surface per material within the native skin-table limit':
            len(surfaces)==len(set(surfaces))<=data['engine_surface_limit'],
        'door retains every siege-leaf face, winding, material and UV at authored dimensions':
            sorted(actual)==sorted(expected),
    }
