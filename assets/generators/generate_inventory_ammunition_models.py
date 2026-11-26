"""Export closed inventory props using original owned textures without raster edits."""
from pathlib import Path
import argparse
import json
import math
import zipfile
from PIL import Image
try:
    from .generate_inventory_consumable_models import ROOT, geometry, digest
    from .generate_nahuelito_model import Mesh, md3, fixed
except ImportError:
    from generate_inventory_consumable_models import ROOT, geometry, digest
    from generate_nahuelito_model import Mesh, md3, fixed

SOURCE=ROOT/'assets/source/art/inventory_models_647/ammunition'


def output_files(source=SOURCE, definition_name='inventory_ammunition.modeldef', metadata_files=None, wrapper_name=None):
    if metadata_files is None:metadata_files=('DESIGN.json','PROMPT.txt','GENERATION_STATUS.json')
    config=json.loads((source/'DESIGN.json').read_text(encoding='utf-8'))
    for name,checksum in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=checksum:raise ValueError('Owned source changed: '+name)
    neutral={'tiers':list(config['tier_materials']),'tier_materials':config['tier_materials'],
             'atlas':{'columns':1,'rows':1,'inset':0,'tiles':{key:[0,0] for key in config['materials']}}}
    files={};records={};definitions=[]
    for key,item in config['variants'].items():
        mesh=Mesh();parts=[]
        for part in config['families'][item['family']]['parts']:
            component,volumes=geometry(neutral,{'parts':[part]},item['tier'])
            if part.get('normalize_uv',False):
                # Folded hollow profiles can revisit Z and exceed the default UV range.
                low_uv=[min(uv[axis] for uv in component.uv) for axis in (0,1)]
                high_uv=[max(uv[axis] for uv in component.uv) for axis in (0,1)]
                component.uv=[tuple((uv[axis]-low_uv[axis])/max(1e-12,high_uv[axis]-low_uv[axis]) for axis in (0,1)) for uv in component.uv]
            matrix=part.get('rotation',[[1,0,0],[0,1,0],[0,0,1]])
            offset=part.get('offset',[0,0,0])
            material=config['tier_materials'][item['tier']].get(part['material'],part['material'])
            settings=config['materials'][material]
            width,height=settings['image_size'];left,top,right,bottom=settings['rect_pixels']
            begin=len(mesh.vertices)
            for point,(u,v) in zip(component.vertices,component.uv):
                transformed=tuple(sum(a*b for a,b in zip(row,point))+offset[axis] for axis,row in enumerate(matrix))
                if 'surface_wave' in part:
                    displacement=sum(wave['amplitude']*math.sin(transformed[wave['axis']]*wave['frequency']+wave.get('phase',0)) for wave in part['surface_wave'])
                    transformed=(transformed[0],transformed[1],transformed[2]+displacement)
                mesh.vertex(transformed,((left+(right-left)*u)/width,(top+(bottom-top)*v)/height),part['part'])
            mesh.faces.extend((material,tuple(begin+index for index in triangle)) for _,triangle in component.faces)
            parts.extend(volumes)
        reference=Image.open(ROOT/item['reference']).convert('RGBA').getchannel('A')
        if 'reference_crop' in item:reference=reference.crop(tuple(item['reference_crop']))
        bounds=reference.point(lambda value:255 if value>=128 else 0).getbbox()
        axis=0 if item['reference_axis']=='width' else 2
        source_axis=0 if axis==0 else 1
        target=(bounds[source_axis+2]-bounds[source_axis])/item['sprite_scale'][source_axis]
        low=[min(point[dimension] for point in mesh.vertices) for dimension in range(3)]
        high=[max(point[dimension] for point in mesh.vertices) for dimension in range(3)]
        factor=target/(high[axis]-low[axis])
        frame=[(x*factor,y*factor,(z-low[2])*factor) for x,y,z in mesh.vertices]
        shaders={name:settings['texture'] for name,settings in config['materials'].items()}
        binary,surfaces,native_bounds=md3(mesh,[frame],shaders)
        binary=binary[:8]+fixed('CA'+str(config['issue'])+' '+key,64)+binary[72:]
        name=config['model_path']+'/'+key+'.md3';files[name]=binary
        definitions.append(f'Model {item["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}')
        for binding in item.get('additional_bindings',[]):
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}')
        # Editable OBJ keeps the original shader images referenced by materials.
        material_file=config.get('editable_materials_name','ammunition.mtl')
        lines=['# Original inventory art; OBJ Y up. Existing raster sources remain unchanged.','mtllib '+material_file]
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frame]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for material,triangle in mesh.faces:
            group=(material,mesh.parts[triangle[0]])
            if group!=previous:lines+=['g '+group[1],'usemtl '+material];previous=group
            lines.append('f '+' '.join(f'{index+1}/{index+1}' for index in triangle))
        files['editable/'+key+'.obj']=('\n'.join(lines)+'\n').encode()
        records[key]={'class':item['class'],'parts':parts,'closed_outward_components':len(parts),
                      'vertices':len(mesh.vertices),'triangles':len(mesh.faces),'surfaces':surfaces,
                      'reference_opaque_bounds':bounds,'reference_axis':item['reference_axis'],
                      'reference_sprite_scale':item['sprite_scale'],'target_art_extent':target,'native_bounds':native_bounds}
    mtl=[]
    for key,settings in config['materials'].items():
        mtl += ['newmtl '+key,'Kd 1 1 1','map_Kd '+'src/'+settings['texture']]
    files['editable/'+config.get('editable_materials_name','ammunition.mtl')]=('\n'.join(mtl)+'\n').encode()
    files['caelum/data/'+definition_name]=('\n'.join(definitions)+'\n').encode()
    report={'schema_revision':1,'issue':config['issue'],'parent_issue':config['parent_issue'],'status':config['status'],'variants':records,
            'source_sha256':{name:digest((source/name).read_bytes()) for name in metadata_files},
            'external_source_sha256':config['source_sha256'],
            'generator_sha256':{name:digest(Path(__file__).with_name(name).read_bytes()) for name in
                                ('generate_inventory_ammunition_models.py','generate_inventory_consumable_models.py','generate_nahuelito_model.py','generate_pombero_model.py')},
            'sha256':{name:digest(blob) for name,blob in files.items()}}
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    if wrapper_name:
        report['generator_sha256'][wrapper_name]=digest(Path(__file__).with_name(wrapper_name).read_bytes())
        files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main(source=SOURCE, definition_name='inventory_ammunition.modeldef', metadata_files=None, wrapper_name=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--check',action='store_true')
    parser.add_argument('--install',action='store_true')
    args=parser.parse_args();files=output_files(source,definition_name,metadata_files,wrapper_name)
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install and not name.startswith('editable/'):
            paths.append(source/'EXPORT.json' if name=='manifest.json' else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale inventory export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps({key:item['triangles'] for key,item in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
