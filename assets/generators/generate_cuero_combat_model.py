"""Bind the owned Cuero sheet rig to unchanged inherited native combat frames."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import re
import zipfile
try:
    from .generate_cuero_model import geometry, poses, surface
    from .generate_nahuelito_model import Mesh, md3, fixed
except ImportError:
    from generate_cuero_model import geometry, poses, surface
    from generate_nahuelito_model import Mesh, md3, fixed
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/cuero_660'
MODEL_PATH='models/caelum/folklore/cuero660'
DEFINITION='caelum/data/cuero_combat.modeldef'
def digest(blob):return hashlib.sha256(blob).hexdigest()

def deform(point,control,design,rig):
    x,y,z=point;rx,ry=design['geometry']['radii'];hinge=rx*rig['front_hinge_fraction']
    pivot_z=surface(design['geometry'],hinge,0)
    weight=max(0,(x-hinge)/(rx-hinge))**rig['front_weight_power']
    angle=math.radians(control['front_curl'])*weight
    local_x=x-hinge;local_z=z-pivot_z
    x=hinge+local_x*math.cos(angle)-local_z*math.sin(angle)
    z=pivot_z+local_x*math.sin(angle)+local_z*math.cos(angle)
    side=math.radians(control['side_curl'])*(abs(y)/ry)**rig['side_weight_power']
    z+=abs(y)*math.sin(side)
    y*=math.cos(side)
    x*=control['radial_scale'];y*=control['radial_scale'];z*=control['vertical_scale']
    roll=math.radians(control['roll'])
    return (x,y*math.cos(roll)-z*math.sin(roll),y*math.sin(roll)+z*math.cos(roll))

def output_files():
    config=json.loads((SOURCE/'ANIMATION.json').read_text(encoding='utf-8'))
    for name,checksum in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=checksum:raise ValueError('Changed source: '+name)
    design_path=ROOT/config['source_design'];design=json.loads(design_path.read_text(encoding='utf-8'))
    mesh=geometry(design);cycles,labels=poses(mesh,design)
    lookup={(row['action'],row['sample']):points for row,points in zip(labels,cycles)}
    profile=(ROOT/config['profile_source']).read_text(encoding='utf-8')
    body=profile.split('class '+config['profile_class']+' :',1)[1].split('class ',1)[0]
    defaults={key:float(re.search(r'\b'+key+r'\s+([\d.]+)\s*;',body)[1]) for key in ['Height','Radius','Scale']}
    diameter=max(max(p[axis] for p in mesh.vertices)-min(p[axis] for p in mesh.vertices) for axis in (0,1))
    neutral=design['preview']['diameter_map_units'];normalization=neutral/diameter
    frames=[]
    for row in config['frames']:
        if 'cycle' in row:points=lookup[(row['cycle'],row['sample'])]
        else:
            points=[tuple(value*normalization for value in deform(vertex,row['deformation'],design,config['deformation_rig'])) for vertex in mesh.vertices]
            floor=min(point[2] for point in points);points=[(x,y,z-floor) for x,y,z in points]
        frames.append(points)
    native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
    native.faces=[('atlas',tri) for _,tri in mesh.faces]
    binary,surfaces,bounds=md3(native,frames,{'atlas':MODEL_PATH+'/materials.png'})
    factor=2*defaults['Radius']/(neutral*defaults['Scale'])
    definition=['Model '+config['actor'],'{','    Path "'+MODEL_PATH+'"','    Model 0 "cuero.md3"',
                f'    Scale {factor:.12g} {factor:.12g} {factor:.12g}','    CorrectPixelStretch']
    definition += [f'    FrameIndex {row["sprite"]} {row["letter"]} 0 {i}' for i,row in enumerate(config['frames'])]
    output={MODEL_PATH+'/cuero.md3':binary[:8]+fixed('CA-FOLK-053 inherited combat art',64)+binary[72:],
            MODEL_PATH+'/materials.png':(design_path.parent/'materials.png').read_bytes(),
            DEFINITION:('\n'.join(definition+['}',''])).encode()}
    obj=['# Cuero neutral mesh; X forward, Y up. Sheet deformation rig: ANIMATION.json.','mtllib cuero.mtl']
    obj += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
    obj += [f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv];previous=None
    for _,triangle in native.faces:
        part=mesh.parts[triangle[0]]
        if part!=previous:obj+=['g '+part,'usemtl atlas'];previous=part
        obj.append('f '+' '.join(f'{index+1}/{index+1}' for index in triangle))
    output['cuero.obj']=('\n'.join(obj)+'\n').encode()
    output['cuero.mtl']=b'newmtl atlas\nKd 1 1 1\nmap_Kd materials.png\n'
    output['materials.png']=output[MODEL_PATH+'/materials.png']
    manifest=dict(schema_revision=1,issue=660,parent_issue=461,status=config['status'],source_sha256={
        **config['source_sha256'],'assets/source/art/cuero_660/ANIMATION.json':digest((SOURCE/'ANIMATION.json').read_bytes()),
        'assets/generators/generate_cuero_combat_model.py':digest(Path(__file__).read_bytes())},
        inherited_defaults=defaults,modeldef_scale=factor,neutral_diameter=neutral,frames=config['frames'],
        source_topology_sha256=digest(json.dumps(mesh.faces,separators=(',',':')).encode()),
        source_uv_sha256=digest(json.dumps(mesh.uv,separators=(',',':')).encode()),
        vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,bounds=bounds,
        sha256={name:digest(blob) for name,blob in output.items()})
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode();return output

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--check',action='store_true');parser.add_argument('--install',action='store_true')
    args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        targets=[args.output/name]
        if args.install:targets.append(SOURCE/('EXPORT.json' if name=='manifest.json' else name) if '/' not in name else ROOT/'src'/name)
        for path in targets:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale model output: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if '/' not in name:continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name==DEFINITION else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps(dict(files=len(files),frames=len(json.loads(files['manifest.json'])['frames']),checked=args.check)))
if __name__=='__main__':main()
