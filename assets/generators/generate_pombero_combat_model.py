"""Bind reference-led Pombero geometry to unchanged inherited combat frames."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import zipfile
try:
    from .generate_pombero_model import geometry, poses, rotate
    from .generate_nahuelito_model import Mesh, md3, fixed, mul
except ImportError:
    from generate_pombero_model import geometry, poses, rotate
    from generate_nahuelito_model import Mesh, md3, fixed, mul

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/pombero_461'
MODEL_PATH='models/caelum/folklore/pombero461'
DEFINITION='caelum/data/pombero_combat.modeldef'


def digest(blob):return hashlib.sha256(blob).hexdigest()


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
    original_height=max(v[2] for v in mesh.vertices)-min(v[2] for v in mesh.vertices)
    neutral_height=design['preview']['height_map_units'];normalization=neutral_height/original_height
    frames=[]
    for row in config['frames']:
        if 'cycle' in row:points=lookup[(row['cycle'],row['sample'])]
        else:
            transforms={}
            for transform in row.get('transforms',[]):transforms.setdefault(transform['part'],[]).append(transform)
            points=[]
            for vertex,part in zip(mesh.vertices,mesh.parts):
                while part is not None:
                    info=design['parts'][part]
                    for transform in transforms.get(part,[]):
                        assert transform['kind']=='rotate'
                        vertex=rotate(vertex,info['pivot'],transform['axis'],transform['angle'])
                    part=info['parent']
                points.append(mul(vertex,normalization))
            floor=min(p[2] for p in points);points=[(x,y,z-floor) for x,y,z in points]
        frames.append(points)
    native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
    batches={'atlas':MODEL_PATH+'/materials.png','dark':MODEL_PATH+'/dark.png'}
    output={MODEL_PATH+'/materials.png':(design_path.parent/design['atlas']['source_file']).read_bytes(),
            MODEL_PATH+'/dark.png':(design_path.parent/'dark.png').read_bytes()}
    for name,entry in design['materials'].items():
        if 'source_file' in entry:
            target=MODEL_PATH+'/'+Path(entry['path']).name;batches[entry.get('native_batch',name)]=target
            output[target]=(design_path.parent/entry['source_file']).read_bytes()
    native.faces=[(design['materials'][name].get('native_batch','dark' if name=='dark' else 'atlas'),tri) for name,tri in mesh.faces]
    binary,surfaces,bounds=md3(native,frames,batches)
    output[MODEL_PATH+'/pombero.md3']=binary[:8]+fixed('CA-FOLK-006 inherited combat art',64)+binary[72:]
    factor=defaults['Height']/(neutral_height*defaults['Scale'])
    lines=['Model '+config['actor'],'{','    Path "'+MODEL_PATH+'"','    Model 0 "pombero.md3"',
           f'    Scale {factor:.12g} {factor:.12g} {factor:.12g}','    CorrectPixelStretch']
    lines += [f'    FrameIndex {row["sprite"]} {row["letter"]} 0 {i}' for i,row in enumerate(config['frames'])]
    output[DEFINITION]=('\n'.join(lines+['}',''])).encode()
    # Keep editable geometry next to the animation recipe; no raster edits.
    obj=['# Pombero neutral mesh; X forward, Y up. Pose controls: ANIMATION.json.','mtllib pombero.mtl']
    obj += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
    obj += [f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv]
    previous=None
    for material,tri in native.faces:
        if material!=previous:obj.append('usemtl '+material);previous=material
        obj.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
    output['pombero.obj']=('\n'.join(obj)+'\n').encode()
    output['pombero.mtl']=('\n'.join(f'newmtl {name}\nKd 1 1 1\nmap_Kd src/{path}' for name,path in batches.items())+'\n').encode()
    manifest=dict(schema_revision=1,issue=461,status='functional_art_candidate',source_sha256={
        **config['source_sha256'],'assets/source/art/pombero_461/ANIMATION.json':digest((SOURCE/'ANIMATION.json').read_bytes()),
        'assets/generators/generate_pombero_combat_model.py':digest(Path(__file__).read_bytes())},
        inherited_defaults=defaults,modeldef_scale=factor,neutral_height=neutral_height,frames=config['frames'],
        vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,bounds=bounds,
        sha256={name:digest(blob) for name,blob in output.items()})
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode()
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True);parser.add_argument('--check',action='store_true')
    parser.add_argument('--install',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        targets=[args.output/name]
        if args.install:
            targets.append(SOURCE/('EXPORT.json' if name=='manifest.json' else name) if name in ['manifest.json','pombero.obj','pombero.mtl'] else ROOT/'src'/name)
        for path in targets:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale model output: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name in ['manifest.json','pombero.obj','pombero.mtl']:continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name==DEFINITION else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps(dict(files=len(files),frames=len(json.loads(files['manifest.json'])['frames']),checked=args.check)))


if __name__=='__main__':main()
