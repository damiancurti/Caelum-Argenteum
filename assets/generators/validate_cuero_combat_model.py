"""Validate Cuero native frames and byte-identical original topology, UVs and skin."""
import hashlib
import json
try:
    from .validate_pombero_combat_model import ROOT, validate as validate_native
    from .generate_cuero_combat_model import obj_uv_lines, uv_digest
    from .generate_cuero_model import geometry
except ImportError:
    from validate_pombero_combat_model import ROOT, validate as validate_native
    from generate_cuero_combat_model import obj_uv_lines, uv_digest
    from generate_cuero_model import geometry

def validate(root=ROOT):
    errors=validate_native(root,'cuero',660,{'materials.png':'materials.png'})
    try:
        source=root/'assets/source/art/cuero_660'
        config=json.loads((source/'ANIMATION.json').read_text())
        report=json.loads((source/'EXPORT.json').read_text())
        if (source/'materials.png').read_bytes()!=(root/config['source_design']).parent.joinpath('materials.png').read_bytes():
            errors.append('Portable OBJ skin changed')
        if 'map_Kd materials.png' not in (source/'cuero.mtl').read_text():
            errors.append('Portable OBJ material link changed')
        mesh=geometry(json.loads((root/config['source_design']).read_text()))
        topology = hashlib.sha256(json.dumps(mesh.faces,separators=(',',':')).encode()).hexdigest()
        if topology!=report['source_topology_sha256']:
            errors.append('Original Cuero topology changed')
        exported_uv=[line for line in (source/'cuero.obj').read_text().splitlines() if line.startswith('vt ')]
        if uv_digest(mesh.uv)!=report['source_uv_sha256'] or obj_uv_lines(mesh.uv)!=exported_uv:
            errors.append('Original Cuero OBJ texture coordinates changed')
        expected=2*report['inherited_defaults']['Radius']/(report['neutral_diameter']*report['inherited_defaults']['Scale'])
        if abs(expected-report['modeldef_scale'])>1e-10:errors.append('Provisional diameter fitting changed')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors

if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
