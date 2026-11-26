"""Reconstruct accepted closed mate silhouettes with unchanged painted materials."""
from pathlib import Path
import argparse
import json
import math
import zipfile
from PIL import Image
try:
    from .generate_inventory_consumable_models import ROOT,geometry,digest
    from .generate_nahuelito_model import Mesh,md3,fixed
except ImportError:
    from generate_inventory_consumable_models import ROOT,geometry,digest
    from generate_nahuelito_model import Mesh,md3,fixed

SOURCE=ROOT/'assets/source/art/inventory_models_647/mates'


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed accepted source: '+path)
    neutral={'tiers':['original'],'tier_materials':{'original':{}},
             'atlas':{'columns':1,'rows':1,'inset':0,'tiles':{name:[0,0] for name in config['materials']}}}
    files={};records={};definitions=[]
    for name,item in config['variants'].items():
        mesh=Mesh();volumes={}
        for part in config['families'][item['family']]['parts']:
            component,part_volumes=geometry(neutral,{'parts':[part]},'original');volumes.update(part_volumes)
            material=part['material'];w,h=config['materials'][material]['image_size']
            if 'uv_rows' in part:
                # Project the accepted front decoration over each curved half;
                # the reversed traversal supplies the same motif on the rear.
                uv=[]
                for left,right,y in part['uv_rows']:
                    uv.extend(((left+(right-left)*abs(1-2*i/part['segments']))/w,y/h) for i in range(part['segments']+1))
                uv.extend(((sum(part['uv_rows'][row][:2])/2/w,part['uv_rows'][row][2]/h) for row in (0,-1)))
                component.uv=uv
            elif 'uv_rectangle' in part:
                left,top,right,bottom=part['uv_rectangle']
                component.uv=[((left+(right-left)*u)/w,(top+(bottom-top)*v)/h) for u,v in component.uv]
            else:
                origin,base=part['image_projection']
                component.uv=[((x+origin)/w,(base-z)/h) for x,y,z in component.vertices]
            begin=len(mesh.vertices)
            for point,uv in zip(component.vertices,component.uv):mesh.vertex(point,uv,part['part'])
            mesh.faces.extend((material,tuple(begin+i for i in triangle)) for _,triangle in component.faces)
        alpha=Image.open(ROOT/item['reference']).convert('RGBA').getchannel('A')
        bounds=alpha.point(lambda value:255 if value>=128 else 0).getbbox()
        low=[min(p[a] for p in mesh.vertices) for a in range(3)];high=[max(p[a] for p in mesh.vertices) for a in range(3)]
        factor=min((bounds[2]-bounds[0])/item['sprite_scale'][0]/(high[0]-low[0]),
                   (bounds[3]-bounds[1])/item['sprite_scale'][1]/(high[2]-low[2]))
        frame=[(x*factor,y*factor,(z-low[2])*factor) for x,y,z in mesh.vertices]
        binary,surfaces,native_bounds=md3(mesh,[frame],{m:s['texture'] for m,s in config['materials'].items()})
        files[config['model_path']+'/'+name+'.md3']=binary[:8]+fixed('CA670 '+name,64)+binary[72:]
        definitions.append(f'Model {item["class"]} {{ Path "{config["model_path"]}" Model 0 "{name}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}')
        lines=['# Original derivative of accepted #472 art; OBJ Y up.','mtllib mates.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frame]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for material,triangle in mesh.faces:
            group=(material,mesh.parts[triangle[0]])
            if group!=previous:lines+=['g '+group[1],'usemtl '+material];previous=group
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in triangle))
        files['editable/'+name+'.obj']=('\n'.join(lines)+'\n').encode()
        records[name]=dict(**{'class':item['class']},parts=volumes,closed_outward_components=len(volumes),vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,native_bounds=native_bounds,reference_opaque_bounds=bounds,reference_sprite_scale=item['sprite_scale'],uniform_fit=factor)
    mtl=[]
    for name,settings in config['materials'].items():
        mtl+=['newmtl '+name,'Kd 1 1 1','map_Kd src/'+settings['texture']]
    files['editable/mates.mtl']=('\n'.join(mtl)+'\n').encode()
    files['caelum/data/inventory_mates.modeldef']=('\n'.join(definitions)+'\n').encode()
    report=dict(schema_revision=1,issue=670,parent_issue=647,status=config['status'],variants=records,
                source_sha256={p:digest((SOURCE/p).read_bytes()) for p in ('DESIGN.json','PROVENANCE.json')},
                external_source_sha256=config['source_sha256'],
                generator_sha256={p:digest(Path(__file__).with_name(p).read_bytes()) for p in ('generate_inventory_mate_models.py','generate_inventory_consumable_models.py','generate_nahuelito_model.py','generate_pombero_model.py')},
                sha256={p:digest(b) for p,b in files.items()})
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:
            paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale mate model: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,13,0,0,0)),blob)
            config=json.loads((SOURCE/'DESIGN.json').read_text())
            for settings in config['materials'].values():
                texture=settings['texture'];blob=(ROOT/'src'/texture).read_bytes()
                package.writestr(zipfile.ZipInfo(texture,(2026,11,13,0,0,0)),blob)
                if args.install:
                    p=SOURCE/'editable/src'/texture;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    print(json.dumps({k:v['triangles'] for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
