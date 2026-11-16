"""Export four distinct reference figures through the owned anatomy/garment pipeline."""
from pathlib import Path
import hashlib,json,math,re
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main,prepared_design
    from .generate_head_apparition_models import geometry as base_geometry
    from .generate_pombero_model import poses,rotate
    from .generate_nahuelito_model import Mesh,md3,fixed,mul
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main,prepared_design
    from generate_head_apparition_models import geometry as base_geometry
    from generate_pombero_model import poses,rotate
    from generate_nahuelito_model import Mesh,md3,fixed,mul

SOURCE=ROOT/'assets/source/art/distinct_forms_822'
MODEL_PATH='models/caelum/folklore/distinctforms'
DEFINITION='caelum/data/distinct_form_combat.modeldef'


def geometry(design):
    mesh=base_geometry(design)
    # Keep cropped facial projections inside their original atlas cell.
    for shape in design['shapes']:
        projection=shape.get('front_projection',{})
        if not projection.get('clamp_to_material_cell'):continue
        material=projection['material'];left,top,right,bottom=design['materials'][material]['uv_rect']
        indices={i for owner,tri in mesh.faces if owner==material for i in tri}
        for i in indices:
            u,v=mesh.uv[i];mesh.uv[i]=(max(left,min(right,u)),max(top,min(bottom,v)))
    mesh.vertices=[tuple(v*s for v,s in zip(point,design['anatomy_scale'])) for point in mesh.vertices]
    return mesh


def output_files():
    names=['generate_distinct_form_models.py','generate_head_apparition_models.py',
           'generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py',
           'generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py',
           'generate_duende_models.py','generate_inventory_clothing_models.py',
           'generate_pombero_model.py','generate_nahuelito_model.py']
    files=shared_output(SOURCE,MODEL_PATH,DEFINITION,822,geometry,
                        tuple(Path(__file__).with_name(n) for n in names))
    config=json.loads((SOURCE/'ANIMATION.json').read_text());report=json.loads(files['manifest.json']);definition=files[DEFINITION].decode()
    for name,item in config['species'].items():
        design=json.loads((ROOT/item['design']).read_text());offset=design['preview']['model_offset']
        if any(offset):
            pattern=r'(Model '+re.escape(item['actor'])+r'\s*\{\s*\n)'
            definition,count=re.subn(pattern,lambda m:m[1]+'    Offset '+' '.join(format(v,'.9g') for v in offset)+'\n',definition)
            assert count==1
        report['species'][name]['authored_model_offset']=offset
        overrides=design.get('native_pose_overrides',{})
        if not overrides:continue
        mesh=geometry(prepared_design(design));cycles,labels=poses(mesh,design)
        lookup={(row['action'],row['sample']):points for row,points in zip(labels,cycles)}
        factor=design['preview']['height_map_units']/(max(p[2] for p in mesh.vertices)-min(p[2] for p in mesh.vertices));frames=[]
        for index,row in enumerate(config['frames']):
            if 'cycle' in row:points=lookup[(row['cycle'],row['sample'])]
            else:
                transforms={}
                for tr in overrides.get(str(index),row.get('transforms',[])):transforms.setdefault(tr['part'],[]).append(tr)
                points=[]
                for vertex,part in zip(mesh.vertices,mesh.parts):
                    while part is not None:
                        info=design['parts'][part]
                        for tr in transforms.get(part,[]):
                            if tr['kind']!='rotate':raise ValueError('Unknown authored native transform')
                            vertex=rotate(vertex,info['pivot'],tr['axis'],tr['angle'])
                        part=info['parent']
                    points.append(mul(vertex,factor))
                floor=min(p[2] for p in points);points=[(x,y,z-floor) for x,y,z in points]
            frames.append(points)
        native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
        native.faces=[(design['materials'][m]['native_batch'],tri) for m,tri in mesh.faces]
        shaders={key:MODEL_PATH+'/'+Path(path).name for key,path in item['textures'].items()}
        binary,surfaces,bounds=md3(native,frames,shaders);path=MODEL_PATH+'/'+name+'.md3'
        files[path]=binary[:8]+fixed(item['catalogue_id']+' inherited combat',64)+binary[72:]
        report['sha256'][path]=hashlib.sha256(files[path]).hexdigest()
        report['species'][name].update(surfaces=surfaces,native_bounds=bounds,maximum_authored_radius=max(math.hypot(p[0],p[1]) for frame in frames for p in frame),maximum_authored_height=max(p[2] for frame in frames for p in frame),native_pose_overrides=overrides)
    files[DEFINITION]=definition.encode();report['sha256'][DEFINITION]=hashlib.sha256(files[DEFINITION]).hexdigest()
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files



if __name__=='__main__':
    shared_main(SOURCE,DEFINITION,output_files)
