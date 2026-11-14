"""Export closed gems props using unchanged owned painted icon materials."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image
try:
    from .generate_inventory_jewelry_models import geometry as closed_geometry
except ImportError:
    from generate_inventory_jewelry_models import geometry as closed_geometry
try:
    from .generate_nahuelito_model import Mesh, md3, fixed
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/gems'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(item, material, metal):
    mesh=Mesh(); volumes={}
    for part in item['parts']:
        local=dict(item,parts=[part],undercoat_uv=part.get('undercoat_uv',item['undercoat_uv']))
        component,closed=closed_geometry(local,material,metal)
        if part.get('project_all_faces'):
            component.uv=[((x+64)/128,(120-z)/128) for x,y,z in component.vertices]
            component.faces=[('paint',face) for _,face in component.faces]
        offset=len(mesh.vertices)
        mesh.vertices.extend(component.vertices);mesh.uv.extend(component.uv);mesh.parts.extend(component.parts)
        mesh.faces.extend((mat,tuple(offset+i for i in face)) for mat,face in component.faces)
        volumes.update(closed)
    return mesh,volumes


def output_files(source=SOURCE, family='gems', issue=678, generator_names=('generate_inventory_gems_models.py','generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')):
    config=json.loads((source/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed owned source: '+path)
    files={};records={};definitions=[];mtl=[]
    for material in config['materials'].values():
        if 'original_texture' in material:files[material['texture']]=(ROOT/'src'/material['original_texture']).read_bytes()
    for name,item in config['variants'].items():
        material=config['materials'][name];mesh,volumes=geometry(item,material,config['materials'][item['metal']])
        mesh.faces=[(name if mat=='paint' else item['metal'],tri) for mat,tri in mesh.faces]
        alpha=Image.open(ROOT/item['reference']).convert('RGBA').getchannel('A')
        bounds=alpha.point(lambda v:255 if v>=128 else 0).getbbox()
        low=[min(p[a] for p in mesh.vertices) for a in range(3)];high=[max(p[a] for p in mesh.vertices) for a in range(3)]
        factor=min((bounds[2]-bounds[0])/(high[0]-low[0]),(bounds[3]-bounds[1])/(high[2]-low[2]))
        frame=[(x*factor,y*factor,(z-low[2])*factor) for x,y,z in mesh.vertices]
        binary,surfaces,native_bounds=md3(mesh,[frame],{m:s['texture'] for m,s in config['materials'].items()})
        files[config['model_path']+'/'+name+'.md3']=binary[:8]+fixed(f'CA{issue} '+name,64)+binary[72:]
        for binding in [item,*item.get('additional_bindings',[])]:
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{name}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}')
        lines=[f'# Original volumetric {family}; OBJ Y up. Separate closed editable parts.',f'mtllib {family}.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frame]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for mat,tri in mesh.faces:
            part=mesh.parts[tri[0]]
            if (part,mat)!=previous:lines+=['g '+part,'usemtl '+mat];previous=(part,mat)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        files['editable/'+name+'.obj']=('\n'.join(lines)+'\n').encode()
        records[name]=dict(**{'class':item['class']},parts=volumes,closed_outward_components=len(volumes),vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,native_bounds=native_bounds,reference_opaque_bounds=bounds,reference_sprite_scale=item['sprite_scale'],uniform_fit=factor)
    for name,material in config['materials'].items():mtl+=['newmtl '+name,'Kd 1 1 1','map_Kd src/'+material['texture']]
    files['editable/'+family+'.mtl']=('\n'.join(mtl)+'\n').encode()
    files['caelum/data/inventory_'+family+'.modeldef']=('\n'.join(definitions)+'\n').encode()
    report=dict(schema_revision=1,issue=issue,parent_issue=647,status=config['status'],variants=records,
                source_sha256={p:digest((source/p).read_bytes()) for p in ('DESIGN.json','PROVENANCE.json')},
                external_source_sha256=config['source_sha256'],
                generator_sha256={p:digest(Path(__file__).with_name(p).read_bytes()) for p in generator_names},
                sha256={p:digest(b) for p,b in files.items()})
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main(source=SOURCE, family='gems', issue=678, generator_names=('generate_inventory_gems_models.py','generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')):
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files(source,family,issue,generator_names)
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(source/'EXPORT.json' if name=='manifest.json' else source/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale '+family+' model: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,13,0,0,0)),blob)
            config=json.loads((source/'DESIGN.json').read_text())
            for texture in sorted({s['texture'] for s in config['materials'].values()}):
                blob=files[texture] if texture in files else (ROOT/'src'/texture).read_bytes()
                if texture not in files:package.writestr(zipfile.ZipInfo(texture,(2026,11,13,0,0,0)),blob)
                if args.install:
                    path=source/'editable/src'/texture;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    print(json.dumps({k:v['triangles'] for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
