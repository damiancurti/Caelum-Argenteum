"""Validate original Nahuelito topology, portable materials and native body fitting."""
import hashlib
import json
import math
import struct
try:
    from .validate_pombero_combat_model import ROOT, validate as validate_native
    from .generate_nahuelito_model import geometry
except ImportError:
    from validate_pombero_combat_model import ROOT, validate as validate_native
    from generate_nahuelito_model import geometry

def validate(root=ROOT):
    textures={name:name for name in ['skin.png','iris.png','dark.png']}
    errors=validate_native(root,'nahuelito',662,textures)
    try:
        source=root/'assets/source/art/nahuelito_662';config=json.loads((source/'ANIMATION.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        original=root/config['source_design'];mesh=geometry(json.loads(original.read_text()))
        for field,value in [('source_topology_sha256',mesh.faces),('source_uv_sha256',mesh.uv)]:
            if hashlib.sha256(json.dumps(value,separators=(',',':')).encode()).hexdigest()!=report[field]:errors.append('Original topology/UV changed: '+field)
        for name in textures:
            if (source/name).read_bytes()!=(original.parent/name).read_bytes():errors.append('Portable material changed: '+name)
            if 'map_Kd '+name not in (source/'nahuelito.mtl').read_text():errors.append('Portable material link missing: '+name)
        defaults=report['inherited_defaults'];envelope=report['unscaled_envelope']
        expected=min(defaults['Radius']/envelope['radius'],defaults['Height']/envelope['height'])/defaults['Scale']
        if abs(report['modeldef_scale']-expected)>1e-10:errors.append('Provisional body fitting changed')
        blob=(root/'src/models/caelum/folklore/nahuelito662/nahuelito.md3').read_bytes()
        header=struct.unpack_from('<4sI64s9I',blob);offset=header[-2];factor=report['modeldef_scale']*defaults['Scale']
        for _ in range(header[6]):
            row=struct.unpack_from('<4s64s10I',blob,offset);frames,vertices=row[3],row[5];start=offset+row[10]
            for i in range(frames*vertices):
                x,y,z,_=struct.unpack_from('<3hH',blob,start+i*8);x*=factor/64;y*=factor/64;z*=factor/64
                if math.hypot(x,y)>defaults['Radius']+.01 or z<-.01 or z>defaults['Height']+.01:
                    raise ValueError('Native model exceeds the provisional body envelope')
            offset+=row[11]
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
