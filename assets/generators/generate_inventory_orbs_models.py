"""Export closed baseless orbs using unchanged owned painted icon materials."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image
try:
    from .generate_inventory_jewelry_models import geometry as closed_geometry, volume
    from .generate_inventory_consumable_models import tube
except ImportError:
    from generate_inventory_jewelry_models import geometry as closed_geometry, volume
    from generate_inventory_consumable_models import tube
try:
    from .generate_nahuelito_model import Mesh, md3, fixed
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/orbs'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(item, material, metal):
    part=item['parts'][0];mesh=Mesh();image=Image.open(ROOT/material['original_source']).convert('RGBA')
    width,height=image.size;cx,cy=part['source_center'];rx,rz=part['source_radii'];radius=part['radius']
    def vertex(direction):
        x,y,z=direction;amount=part['uv_edge_inset']
        for attempt in range(512):
            px=cx+x*rx*amount;py=cy-z*rz*amount;ix,iy=int(px),int(py)
            if image.getpixel((ix,iy))[3]>=part['alpha_floor']:break
            amount*=part['uv_inward_step']
        else:raise ValueError('No opaque owned orb pixel on radial UV path')
        samples=[];r=part['sample_radius']
        for dx in range(-r,r+1):
            for dy in range(-r,r+1):
                red,green,blue,alpha=image.getpixel((max(0,min(width-1,ix+dx)),max(0,min(height-1,iy+dy))))
                if alpha>=part['alpha_floor']:samples.append(max(0,min(1,(red-blue)/part['wood_color_span'])))
        relief=part['relief_depth']*sum(samples)/len(samples)
        length=radius+relief
        return mesh.vertex((x*length,y*length,z*length),(px/width,py/height),part['part'])
    north=vertex((0,0,1));rows=[];n=part['segments'];m=part['rings']
    for i in range(1,m):
        theta=math.pi*i/m
        rows.append([vertex((math.sin(theta)*math.cos(math.tau*j/n),math.sin(theta)*math.sin(math.tau*j/n),math.cos(theta))) for j in range(n)])
    south=vertex((0,0,-1))
    for j in range(n):
        mesh.faces.append(('paint',(north,rows[0][j],rows[0][(j+1)%n])))
        mesh.faces.append(('paint',(south,rows[-1][(j+1)%n],rows[-1][j])))
    for i in range(len(rows)-1):
        for j in range(n):mesh.quad((rows[i][j],rows[i+1][j],rows[i+1][(j+1)%n],rows[i][(j+1)%n]),'paint')
    measure=volume(mesh,mesh.faces)
    if measure<0:mesh.faces=[(mat,tuple(reversed(tri))) for mat,tri in mesh.faces]
    return mesh,{part['part']:abs(measure)}


def output_files(source=SOURCE, family='orbs', issue=753, generator_names=('generate_inventory_orbs_models.py','generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')):
    config=json.loads((source/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed owned source: '+path)
    files={};records={};definitions=[];mtl=[]
    for material in config['materials'].values():
        if 'original_source' in material:files[material['texture']]=(ROOT/material['original_source']).read_bytes()
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
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{name}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} {binding.get("frame","A")} 0 0 }}')
        lines=[f'# Original volumetric {family}; OBJ Y up. Separate closed editable parts.',f'mtllib {family}.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frame]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for mat,tri in mesh.faces:
            part=mesh.parts[tri[0]]
            if (part,mat)!=previous:lines+=['g '+part,'usemtl '+mat];previous=(part,mat)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        files['editable/'+name+'.obj']=('\n'.join(lines)+'\n').encode()
        records[name]=dict(**{'class':item['class']},parts=volumes,closed_outward_components=len(volumes),vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,native_bounds=native_bounds,reference_opaque_bounds=bounds,reference_sprite_scale=item['sprite_scale'],uniform_fit=factor,source_to_native=dict(factor=factor,floor=low[2]))
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


def main(source=SOURCE, family='orbs', issue=753, generator_names=('generate_inventory_orbs_models.py','generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')):
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
