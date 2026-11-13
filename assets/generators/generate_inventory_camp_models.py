"""Reuse original camp geometry for two native inventory drop presentations."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/camp'
DEFINITION='caelum/data/inventory_camp.modeldef'

def digest(blob):return hashlib.sha256(blob).hexdigest()

def read_obj(blob,selected=None):
    vertices=[];uvs=[];faces=[];material=None
    for line in blob.decode('utf-8').splitlines():
        fields=line.split()
        if not fields:continue
        if fields[0]=='v':vertices.append(tuple(map(float,fields[1:4])))
        elif fields[0]=='vt':uvs.append(tuple(map(float,fields[1:3])))
        elif fields[0]=='usemtl':material=fields[1]
        elif fields[0]=='f' and (selected is None or material in selected):
            pairs=[tuple(int(value)-1 for value in token.split('/')[:2]) for token in fields[1:]]
            if not material or any(len(pair)!=2 for pair in pairs):raise ValueError('Unsupported original OBJ face')
            faces.append((material,pairs))
    used=sorted({pair for _,face in faces for pair in face});lookup={pair:i+1 for i,pair in enumerate(used)}
    if not used:raise ValueError('No selected original geometry')
    return [vertices[v] for v,_ in used],[uvs[t] for _,t in used],[(mat,[lookup[p] for p in face]) for mat,face in faces]

def obj(vertices,uvs,faces,material_names=None):
    lines=['# Original camp geometry reused for inventory presentation.','# OBJ X/Z horizontal, Y up.']
    if material_names:lines.append('mtllib camp.mtl')
    lines += ['v '+' '.join(f'{x:.6f}' for x in point) for point in vertices]
    lines += ['vt '+' '.join(f'{x:.6f}' for x in point) for point in uvs]
    previous=None
    for material,indices in faces:
        if material!=previous:
            lines += ['g '+(material_names[material] if material_names else 'original_iron'),
                      'usemtl '+(material_names[material] if material_names else material)];previous=material
        lines.append('f '+' '.join(f'{i}/{i}' for i in indices))
    return ('\n'.join(lines)+'\n').encode()

def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text());files={};records={};definitions=[]
    for name,checksum in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=checksum:raise ValueError('Changed camp source: '+name)
    material_paths=sorted(config['materials']);names={name:'material_'+str(i) for i,name in enumerate(material_paths)}
    for material in material_paths:
        files['editable/materials/'+names[material]+'.png']=(ROOT/'src'/material).read_bytes()
    files['editable/camp.mtl']=('\n'.join('newmtl '+names[name]+'\nKd 1 1 1\nmap_Kd materials/'+names[name]+'.png' for name in material_paths)+'\n').encode()
    for key,item in config['variants'].items():
        vertices,uvs,faces=read_obj((ROOT/item['source_obj']).read_bytes(),item.get('selected_materials'))
        source_low=[min(v[i] for v in vertices) for i in range(3)];source_high=[max(v[i] for v in vertices) for i in range(3)]
        with Image.open(ROOT/item['reference']) as picture:
            extent=picture.convert('RGBA').getchannel('A').point(lambda value:255 if value>=128 else 0).getbbox()
        if extent is None:raise ValueError('Empty world sprite: '+key)
        target=(extent[2]-extent[0])/item['sprite_scale'][0]
        target_height=(extent[3]-extent[1])/item['sprite_scale'][1]
        horizontal=max(source_high[i]-source_low[i] for i in (0,2))
        factor=min(target/horizontal,target_height/(source_high[1]-source_low[1]))
        if item['extract']:
            path=item['runtime_model'];files[path]=obj(vertices,uvs,faces)
        else:path=item['source_obj'].removeprefix('src/')
        folder,filename=path.rsplit('/',1)
        definitions.append(f'Model {item["class"]} {{ Path "{folder}" Model 0 "{filename}" Scale {factor:.12g} {factor:.12g} {factor:.12g} AngleOffset {item["angle_offset"]} CorrectPixelStretch DontCullBackFaces FrameIndex {item["sprite"]} A 0 0 }}')
        files['editable/'+key+'.obj']=obj(vertices,uvs,faces,names)
        # Report native XYZ bounds after fitting and the retained OBJ rotation.
        angle=math.radians(item['angle_offset']);c,s=math.cos(angle),math.sin(angle)
        native=[((x*c-z*s)*factor,(x*s+z*c)*factor,y*factor) for x,y,z in vertices]
        bounds={'min':[min(p[i] for p in native) for i in range(3)],'max':[max(p[i] for p in native) for i in range(3)]}
        records[key]=dict(class_name=item['class'],vertices=len(vertices),polygons=len(faces),triangles=sum(len(indices)-2 for _,indices in faces),
            selected_materials=sorted({mat for mat,_ in faces}),modeldef_scale=factor,reference_opaque_bounds=extent,target_art_extent=target,target_art_height=target_height,
            source_obj_bounds=dict(min=source_low,max=source_high),native_bounds=[bounds],runtime_model=path,
            selected_geometry_sha256=digest(json.dumps([vertices,uvs,faces],separators=(',',':')).encode()))
    files[DEFINITION]=('\n'.join(definitions)+'\n').encode()
    report=dict(schema_revision=1,issue=664,parent_issue=647,status=config['status'],variants=records,
        source_sha256={name:digest((SOURCE/name).read_bytes()) for name in ['DESIGN.json','PROVENANCE.json']},
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
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale camp export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name==DEFINITION else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps(dict(files=len(files),checked=args.check)))
if __name__=='__main__':main()
