"""Bind original Nahuelito anatomy to inherited native combat frames."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import re
import zipfile
try:
    from .generate_nahuelito_model import geometry, poses, md3, fixed, rotate_x
except ImportError:
    from generate_nahuelito_model import geometry, poses, md3, fixed, rotate_x
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/nahuelito_662'
MODEL_PATH='models/caelum/folklore/nahuelito662'
DEFINITION='caelum/data/nahuelito_combat.modeldef'

def digest(blob):return hashlib.sha256(blob).hexdigest()

def rotate(point,pivot,degrees,axis):
    x,y,z=[a-b for a,b in zip(point,pivot)];angle=math.radians(degrees);c,s=math.cos(angle),math.sin(angle)
    if axis=='y':result=(x*c+z*s,y,-x*s+z*c)
    else:result=(x*c-y*s,x*s+y*c,z)
    return tuple(a+b for a,b in zip(result,pivot))

def smooth(value):
    value=max(0,min(1,value));return value*value*(3-2*value)

def deform(point,part,control,design,rig):
    original=point
    if 'flipper' in part:
        side=-1 if part.endswith('-1') else 1;label=part.replace('-1','').replace('1','')
        x,y,z=design['geometry'][label][0][:3]
        point=rotate_x(point,(x,side*y,z),side*math.radians(control['flipper_pitch']))
    if part=='jaw':point=rotate(point,rig['jaw_pivot'],control['jaw_open'],'y')
    neck=smooth((original[2]-rig['neck_weight_start'])/(rig['neck_weight_end']-rig['neck_weight_start']))
    tail=smooth((original[0]-rig['tail_pivot'][0])/(rig['tail_weight_end']-rig['tail_pivot'][0]))
    point=rotate(point,rig['neck_pivot'],control['neck_pitch']*neck,'y')
    point=rotate(point,rig['neck_pivot'],control['neck_yaw']*neck,'z')
    point=rotate(point,rig['tail_pivot'],control['tail_yaw']*tail,'z')
    return rotate_x(point,(0,0,0),math.radians(control['body_roll']))

def output_files():
    config=json.loads((SOURCE/'ANIMATION.json').read_text(encoding='utf-8'))
    for name,checksum in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=checksum:raise ValueError('Changed source: '+name)
    original=ROOT/config['source_design'];design=json.loads(original.read_text());mesh=geometry(design)
    cycles,labels=poses(mesh,design);lookup={(row['action'],row['sample']):points for row,points in zip(labels,cycles)}
    profile=(ROOT/config['profile_source']).read_text(encoding='utf-8')
    body=profile.split('class '+config['profile_class']+' :',1)[1].split('class ',1)[0]
    defaults={key:float(re.search(r'\b'+key+r'\s+([\d.]+)\s*;',body)[1]) for key in ['Height','Radius','Scale']}
    frames=[]
    for row in config['frames']:
        points=lookup[(row['cycle'],row['sample'])] if 'cycle' in row else [deform(p,part,row['deformation'],design,config['deformation_rig']) for p,part in zip(mesh.vertices,mesh.parts)]
        floor=min(p[2] for p in points);frames.append([(x,y,z-floor) for x,y,z in points])
    radial=max(math.hypot(x,y) for points in frames for x,y,z in points)
    height=max(z for points in frames for x,y,z in points)
    factor=min(defaults['Radius']/radial,defaults['Height']/height)/defaults['Scale']
    textures={'hide':'skin.png','iris':'iris.png','dark':'dark.png'}
    binary,surfaces,bounds=md3(mesh,frames,{mat:MODEL_PATH+'/'+name for mat,name in textures.items()})
    definition=['Model '+config['actor'],'{','    Path "'+MODEL_PATH+'"','    Model 0 "nahuelito.md3"',
        f'    Scale {factor:.12g} {factor:.12g} {factor:.12g}','    CorrectPixelStretch']
    definition += [f'    FrameIndex {row["sprite"]} {row["letter"]} 0 {i}' for i,row in enumerate(config['frames'])]
    output={MODEL_PATH+'/nahuelito.md3':binary[:8]+fixed('CA-FOLK-055 inherited combat art',64)+binary[72:],DEFINITION:('\n'.join(definition+['}',''])).encode()}
    for name in textures.values():
        output[MODEL_PATH+'/'+name]=(original.parent/name).read_bytes();output[name]=output[MODEL_PATH+'/'+name]
    obj=['# Nahuelito neutral pose; X forward, Y up. Editable rig: ANIMATION.json.','mtllib nahuelito.mtl']
    obj += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
    obj += [f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv];previous=None
    for material,triangle in mesh.faces:
        part=mesh.parts[triangle[0]]
        if (part,material)!=previous:obj+=['g '+part,'usemtl '+material];previous=(part,material)
        obj.append('f '+' '.join(f'{i+1}/{i+1}' for i in triangle))
    output['nahuelito.obj']=('\n'.join(obj)+'\n').encode()
    output['nahuelito.mtl']=('\n'.join(f'newmtl {mat}\nKd 1 1 1\nmap_Kd {name}' for mat,name in textures.items())+'\n').encode()
    manifest=dict(schema_revision=1,issue=662,parent_issue=461,status=config['status'],source_sha256={**config['source_sha256'],
        'assets/source/art/nahuelito_662/ANIMATION.json':digest((SOURCE/'ANIMATION.json').read_bytes()),
        'assets/generators/generate_nahuelito_combat_model.py':digest(Path(__file__).read_bytes())},
        inherited_defaults=defaults,modeldef_scale=factor,unscaled_envelope=dict(radius=radial,height=height),frames=config['frames'],
        source_topology_sha256=digest(json.dumps(mesh.faces,separators=(',',':')).encode()),source_uv_sha256=digest(json.dumps(mesh.uv,separators=(',',':')).encode()),
        vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,bounds=bounds,sha256={name:digest(blob) for name,blob in output.items()})
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode();return output

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--check',action='store_true');parser.add_argument('--install',action='store_true');args=parser.parse_args()
    files=output_files()
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
