"""Export volumetric Umita/Chonchon faces, hair and ear-wings from authored data."""
from pathlib import Path
import copy,hashlib,json,re,math
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_quadruped_models import geometry as component_geometry
    from .generate_peuchen_model import membrane,ellipsoid
    from .generate_duende_models import material_uv
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_quadruped_models import geometry as component_geometry
    from generate_peuchen_model import membrane,ellipsoid
    from generate_duende_models import material_uv
    from generate_nahuelito_model import Mesh

SOURCE=ROOT/'assets/source/art/heads_803'
MODEL_PATH='models/caelum/folklore/heads'
DEFINITION='caelum/data/head_apparition_combat.modeldef'

def face(design,shape):
    """Deform a closed pole-fan head and project its face onto the actual volume."""
    mesh=ellipsoid(design,shape)
    for i,(x,y,z) in enumerate(mesh.vertices):
        front=max(0,(x-shape['center'][0])/shape['radii'][0])**3
        x+=sum(front*b['depth']*math.exp(-((y-b['y'])/b['width_y'])**2-((z-b['z'])/b['width_z'])**2) for b in shape['front_deformation'])
        mesh.vertices[i]=(x,y,z)
        u=.75-.25*max(-1,min(1,(x-shape['center'][0])/shape['radii'][0]))
        v=.5-(z-shape['center'][2])/(2*shape['radii'][2])
        mesh.uv[i]=material_uv(design,shape['material'],u,v)
    projection=shape['front_projection'];mapped={}
    left,right=projection['y_bounds'];bottom,top=projection['z_bounds']
    for index,(_,tri) in enumerate(mesh.faces):
        if sum(mesh.vertices[i][0] for i in tri)/3<projection['minimum_x']:continue
        for i in tri:
            if i not in mapped:
                x,y,z=mesh.vertices[i]
                mapped[i]=mesh.vertex((x,y,z),material_uv(design,projection['material'],(y-left)/(right-left),(top-z)/(top-bottom)),shape['part'])
        mesh.faces[index]=(projection['material'],tuple(mapped[i] for i in tri))
    return mesh

def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        one=copy.deepcopy(design);one['shapes']=[copy.deepcopy(shape)]
        if shape['kind']=='face':piece=face(design,shape)
        elif shape['kind']=='membrane':piece=membrane(design,shape)
        else:piece=component_geometry(one)
        start=len(mesh.vertices)
        for point,uv,part in zip(piece.vertices,piece.uv,piece.parts):mesh.vertex(point,uv,part)
        mesh.faces.extend((material,tuple(start+i for i in tri)) for material,tri in piece.faces)
    return mesh

def output_files():
    names=['generate_head_apparition_models.py','generate_quadruped_models.py','generate_basilisco_model.py',
           'generate_serpent_models.py','generate_avian_models.py','generate_peuchen_model.py',
           'generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py',
           'generate_pombero_model.py','generate_nahuelito_model.py']
    files=shared_output(SOURCE,MODEL_PATH,DEFINITION,803,geometry,tuple(Path(__file__).with_name(n) for n in names))
    config=json.loads((SOURCE/'ANIMATION.json').read_text());report=json.loads(files['manifest.json']);definition=files[DEFINITION].decode()
    for name,item in config['species'].items():
        design=json.loads((ROOT/item['design']).read_text());offset=design['preview']['model_offset']
        assert len(offset)==3
        pattern=r'(Model '+re.escape(item['actor'])+r'\s*\{\s*\n)'
        definition,count=re.subn(pattern,lambda m:m[1]+'    Offset '+' '.join(format(v,'.9g') for v in offset)+'\n',definition)
        assert count==1
        report['species'][name]['authored_model_offset']=offset
    files[DEFINITION]=definition.encode();report['sha256'][DEFINITION]=hashlib.sha256(files[DEFINITION]).hexdigest()
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files

if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
