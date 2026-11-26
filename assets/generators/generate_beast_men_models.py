"""Export reference-based beast-men with unchanged native combat-state bindings."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import re
import zipfile
import copy
try:
    from .generate_pombero_model import geometry, poses, rotate
    from .generate_nahuelito_model import Mesh, md3, fixed, mul
except ImportError:
    from generate_pombero_model import geometry, poses, rotate
    from generate_nahuelito_model import Mesh, md3, fixed, mul

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/beast_men_680'
MODEL_PATH='models/caelum/folklore/beastmen'
DEFINITION='caelum/data/beast_men_combat.modeldef'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def prepared_design(design):
    """Subdivide editable lofts smoothly; keep source control points authoritative."""
    result=copy.deepcopy(design)
    for shape in result['shapes']:
        if shape['kind']=='loft' and shape['rows'][0][0]>shape['rows'][-1][0]:
            shape['rows'].reverse()
        steps=shape.get('curve_steps',1)
        if steps<=1:continue
        rows=shape['rows'];smooth=[]
        for index in range(len(rows)-1):
            p0,p1,p2,p3=[rows[max(0,min(len(rows)-1,j))] for j in (index-1,index,index+1,index+2)]
            for sample in range(steps):
                t=sample/steps
                smooth.append([.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)
                               for a,b,c,d in zip(p0,p1,p2,p3)])
        shape['rows']=smooth+[rows[-1]]
    return result


def surface_materials(mesh,design):
    """Assign coat markings on the body surface instead of a raised chest patch."""
    for region in design.get('surface_materials',[]):
        material=design['materials'][region['material']];duplicates={}
        column,row=material['tile'];margin=design['atlas']['inset']
        for face_index,(old,tri) in enumerate(mesh.faces):
            if old!=region['from'] or any(mesh.parts[i]!=region['part'] for i in tri):continue
            x,y,z=[sum(mesh.vertices[i][axis] for i in tri)/3 for axis in range(3)]
            if x<region['minimum_x'] or (y/region['radius_y'])**2+((z-region['center_z'])/region['radius_z'])**2>1:continue
            mapped=[]
            for i in tri:
                if i not in duplicates:
                    px,py,pz=mesh.vertices[i]
                    u=.5+py/(2*region['radius_y']);v=.5-(pz-region['center_z'])/(2*region['radius_z'])
                    uv=((column+margin+(1-2*margin)*max(0,min(1,u)))/design['atlas']['columns'],
                        (row+margin+(1-2*margin)*max(0,min(1,v)))/design['atlas']['rows'])
                    duplicates[i]=mesh.vertex((px,py,pz),uv,mesh.parts[i])
                mapped.append(duplicates[i])
            mesh.faces[face_index]=(region['material'],tuple(mapped))


def output_files(source=SOURCE, model_path=MODEL_PATH, definition=DEFINITION, issue=680, mesh_builder=geometry, extra_sources=()):
    config=json.loads((source/'ANIMATION.json').read_text(encoding='utf-8'))
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed beast source: '+path)
    profile=(ROOT/config['profile_source']).read_text(encoding='utf-8')
    body=profile.split('class '+config['profile_class']+' :',1)[1].split('class ',1)[0]
    defaults={key:float(re.search(r'\b'+key+r'\s+([\d.]+)\s*;',body)[1]) for key in ['Height','Radius','Scale']}
    output={};reports={};definitions=[]
    for species,item in config['species'].items():
        design=json.loads((ROOT/item['design']).read_text(encoding='utf-8'))
        mesh=mesh_builder(prepared_design(design))
        for index,(x,y,z) in enumerate(mesh.vertices):
            if x<=0:continue
            depth=sum(row['depth']*math.exp(-((y-row['y'])/row['width_y'])**2-((z-row['z'])/row['width_z'])**2)
                      for row in design.get('surface_contours',[]) if row['part']==mesh.parts[index])
            mesh.vertices[index]=(x+depth*min(1.,x/7.),y,z)
        surface_materials(mesh,design)
        cycles,labels=poses(mesh,design)
        lookup={(row['action'],row['sample']):points for row,points in zip(labels,cycles)}
        normalization=design['preview']['height_map_units']/(max(v[2] for v in mesh.vertices)-min(v[2] for v in mesh.vertices))
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
                            if transform['kind']!='rotate':raise ValueError('Unknown inherited presentation transform')
                            vertex=rotate(vertex,info['pivot'],transform['axis'],transform['angle'])
                        part=info['parent']
                    points.append(mul(vertex,normalization))
                floor=min(p[2] for p in points);points=[(x,y,z-floor) for x,y,z in points]
            frames.append(points)
        native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
        native.faces=[(design['materials'][material]['native_batch'],tri) for material,tri in mesh.faces]
        if 'textures' in item:
            shaders={key:model_path+'/'+Path(path).name for key,path in item['textures'].items()}
            for key,path in item['textures'].items():output[shaders[key]]=(ROOT/path).read_bytes()
        else:
            texture=model_path+'/'+species+'.png';output[texture]=(ROOT/item['reference']).read_bytes()
            atlas=model_path+'/materials.png';output[atlas]=(source/design['atlas']['source_file']).read_bytes()
            shaders={'reference':texture,'atlas':atlas}
        binary,surfaces,bounds=md3(native,frames,shaders)
        output[model_path+'/'+species+'.md3']=binary[:8]+fixed(item['catalogue_id']+' inherited combat',64)+binary[72:]
        radial=max(math.hypot(p[0],p[1]) for frame in frames for p in frame)
        height=max(p[2] for frame in frames for p in frame)
        standing_height=max(p[2] for p in frames[0])-min(p[2] for p in frames[0])
        factor=defaults['Height']/standing_height/defaults['Scale']
        definitions += ['Model '+item['actor'],'{','    Path "'+model_path+'"','    Model 0 "'+species+'.md3"',
                        f'    Scale {factor:.12g} {factor:.12g} {factor:.12g}','    CorrectPixelStretch']
        definitions += [f'    FrameIndex {row["sprite"]} {row["letter"]} 0 {index}' for index,row in enumerate(config['frames'])]
        definitions+=['}','']
        lines=['# Reference-based beast anatomy; OBJ Y up. Pose hierarchy remains editable in JSON.','mtllib '+species+'.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for source_material,tri in mesh.faces:
            material=design['materials'][source_material]['native_batch']
            part=mesh.parts[tri[0]]
            group=part+'_'+source_material
            if previous!=(group,material):lines+=['g '+group,'usemtl '+material];previous=(group,material)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        output['editable/'+species+'.obj']=('\n'.join(lines)+'\n').encode()
        output['editable/'+species+'.mtl']=''.join('newmtl '+key+'\nKd 1 1 1\nmap_Kd src/'+path+'\n' for key,path in shaders.items()).encode()
        reports[species]=dict(actor=item['actor'],catalogue_id=item['catalogue_id'],vertices=len(mesh.vertices),triangles=len(mesh.faces),
            hierarchical_parts=len(design['parts']),surfaces=surfaces,native_bounds=bounds,modeldef_scale=factor,
            native_profile=defaults,maximum_authored_radius=radial,maximum_authored_height=height,
            source_sha256=digest((ROOT/item['reference']).read_bytes()))
    output[definition]=('\n'.join(definitions)).encode()
    sources=dict(config['source_sha256'])
    for path in [source/'ANIMATION.json',source/'PROVENANCE.json',*[ROOT/v['design'] for v in config['species'].values()],Path(__file__),*extra_sources]:
        sources[path.relative_to(ROOT).as_posix()]=digest(path.read_bytes())
    report=dict(schema_revision=1,issue=issue,parent_issue=461,status=config['status'],frames=config['frames'],species=reports,
                source_sha256=sources,sha256={name:digest(blob) for name,blob in output.items()})
    output['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return output


def main(source=SOURCE, definition=DEFINITION, output_factory=output_files):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True);parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true')
    args=parser.parse_args();files=output_factory()
    for name,blob in files.items():
        targets=[args.output/name]
        if args.install:targets.append(source/'EXPORT.json' if name=='manifest.json' else source/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in targets:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale beast model: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name==definition else name,(2026,11,13,0,0,0)),blob)
                if args.install and name.endswith('.png'):
                    path=source/'editable/src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    report=json.loads(files['manifest.json'])
    print(json.dumps({name:{k:row[k] for k in ('vertices','triangles','hierarchical_parts','modeldef_scale')} for name,row in report['species'].items()}))


if __name__=='__main__':main()
