"""Reuse owned furniture and complete native dining assemblies for inventory."""
from pathlib import Path
import argparse
import json
import math
import re
import zipfile
from PIL import Image
try:
    from .generate_inventory_camp_models import ROOT, digest, read_obj, obj
except ImportError:
    from generate_inventory_camp_models import ROOT, digest, read_obj, obj

SOURCE=ROOT/'assets/source/art/inventory_models_647/furniture'
DEFINITION='caelum/data/inventory_furniture.modeldef'

def seat_transforms(data):
    """Mirror the source-hashed SeatPosition/SeatAngle for an origin at angle 0."""
    n=data['seats'];width=data['width'];depth=data['depth']
    gap=max(data['chair_radius'],data['player_radius'])+1
    spacing=data['chair_radius']+data['player_radius']+1
    result=[]
    for i in range(n):
        if n==2:x,y,a=0,(-1 if i==0 else 1)*(depth/2+gap),180+(90 if i==0 else 270)
        else:
            side=(n-2)//2
            if i<side*2:x,y=(i%side-(side-1)*.5)*max(width/side,spacing),(-1 if i<side else 1)*(depth/2+gap)
            else:x,y=(-1 if i==side*2 else 1)*(width/2+gap),0
            a=180+(90 if i<side else 270 if i<side*2 else 0 if i==side*2 else 180)
        result.append([x,y,0,a])
    return result

def native(point,angle):
    # GZDoom 4.14.2 OBJ RealignVector negates OBJ Z before actor yaw.
    x,y,z=point;c=math.cos(math.radians(angle));s=math.sin(math.radians(angle))
    return x*c+z*s,x*s-z*c,y

def inverse_native(point,angle):
    x,y,z=point;c=math.cos(math.radians(angle));s=math.sin(math.radians(angle))
    return x*c+y*s,z,x*s-y*c

def assemble(item,config,root=ROOT):
    vertices,uvs,faces=read_obj((root/item['source_obj']).read_bytes())
    parts=[dict(source=item['source_obj'],vertex_start=0,vertex_count=len(vertices),world_transform=[0,0,0,0])]
    if 'dining' in item:
        chair=config['variants'][item['dining']['chair_variant']]
        cv,cu,cf=read_obj((root/chair['source_obj']).read_bytes())
        for dx,dy,dz,yaw in seat_transforms(item['dining']):
            offset=len(vertices)
            for point in cv:
                x,y,z=native(point,chair['angle_offset']+yaw)
                vertices.append(inverse_native((x+dx,y+dy,z+dz),item['angle_offset']))
            uvs.extend(cu);faces.extend((m,[index+offset for index in ids]) for m,ids in cf)
            parts.append(dict(source=chair['source_obj'],vertex_start=offset,vertex_count=len(cv),world_transform=[dx,dy,dz,yaw]))
    return vertices,uvs,faces,parts

def verify_sources(config,root=ROOT):
    for name,checksum in config['source_sha256'].items():
        if digest((root/name).read_bytes())!=checksum:raise ValueError('Changed furniture source: '+name)
    for cls,entry in config['original_model_blocks'].items():
        blocks=re.findall(r'\bModel\s+'+re.escape(cls)+r'\s*\{[^}]+\}',(root/entry['file']).read_text())
        if len(blocks)!=1 or ' '.join(blocks[0].split())!=entry['text']:raise ValueError('Changed original body binding: '+cls)

def output_files(root=ROOT):
    source=root/'assets/source/art/inventory_models_647/furniture'
    config=json.loads((source/'DESIGN.json').read_text());verify_sources(config,root)
    files={};records={};definitions=[]
    names={name:'material_'+str(i) for i,name in enumerate(sorted(config['materials']))}
    for material,name in names.items():files['editable/materials/'+name+'.png']=(root/'src'/material).read_bytes()
    files['editable/furniture.mtl']=('\n'.join('newmtl '+name+'\nKd 1 1 1\nmap_Kd materials/'+name+'.png' for name in names.values())+'\n').encode()
    for key,item in config['variants'].items():
        vertices,uvs,faces,parts=assemble(item,config,root)
        low=[min(v[i] for v in vertices) for i in range(3)];high=[max(v[i] for v in vertices) for i in range(3)]
        with Image.open(root/item['reference']) as picture:
            extent=picture.convert('RGBA').getchannel('A').point(lambda value:255 if value>=128 else 0).getbbox()
        if extent is None:raise ValueError('Empty furniture reference: '+key)
        width=(extent[2]-extent[0])/item['sprite_scale'][0];height=(extent[3]-extent[1])/item['sprite_scale'][1]
        factor=min(width/max(high[i]-low[i] for i in (0,2)),height/(high[1]-low[1]))
        def render(material_names=None):
            return obj(vertices,uvs,faces,material_names).replace(b'Original camp geometry',b'Original furniture geometry').replace(b'mtllib camp.mtl',b'mtllib furniture.mtl').replace(b'g original_iron',b'g original_material')
        path=item.get('runtime_model',item['source_obj'].removeprefix('src/'))
        if 'runtime_model' in item:files[path]=render()
        files['editable/'+key+'.obj']=render(names)
        folder,filename=path.rsplit('/',1)
        definitions.append(f'Model {item["class"]} {{ Path "{folder}" Model 0 "{filename}" Scale {factor:.12g} {factor:.12g} {factor:.12g} AngleOffset {item["angle_offset"]:g} CorrectPixelStretch DontCullBackFaces FrameIndex {item["sprite"]} A 0 0 }}')
        native_points=[tuple(v*factor for v in native(point,item['angle_offset'])) for point in vertices]
        bounds={label:[fn(p[i] for p in native_points) for i in range(3)] for label,fn in [('min',min),('max',max)]}
        records[key]=dict(class_name=item['class'],vertices=len(vertices),polygons=len(faces),triangles=sum(len(ids)-2 for _,ids in faces),parts=parts,
            modeldef_scale=factor,reference_opaque_bounds=extent,target_art_extent=width,target_art_height=height,
            source_obj_bounds=dict(min=low,max=high),native_bounds=[bounds],runtime_model=path)
    files[DEFINITION]=('\n'.join(definitions)+'\n').encode()
    report=dict(schema_revision=1,issue=666,parent_issue=647,status=config['status'],variants=records,
        source_sha256={name:digest((source/name).read_bytes()) for name in ['DESIGN.json','PROVENANCE.json']},
        external_source_sha256=config['source_sha256'],generator_sha256=digest(Path(__file__).read_bytes()),
        sha256={name:digest(blob) for name,blob in files.items()})
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        targets=[args.output/name]
        if args.install:targets.append(SOURCE/('EXPORT.json' if name=='manifest.json' else name) if name=='manifest.json' or name.startswith('editable/') else ROOT/'src'/name)
        for path in targets:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale furniture export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name==DEFINITION else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps(dict(files=len(files),checked=args.check)))
if __name__=='__main__':main()
