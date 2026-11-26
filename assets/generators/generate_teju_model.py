"""Export the editable seven-headed Teju Jagua using established native geometry."""
from pathlib import Path
import copy
import math
try:
    from .generate_quadruped_models import geometry as component_geometry
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_quadruped_models import geometry as component_geometry
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/teju_791'
MODEL_PATH='models/caelum/folklore/teju'
DEFINITION='caelum/data/teju_combat.modeldef'

def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        one=copy.deepcopy(design);one['shapes']=[shape]
        piece=component_geometry(one)
        t=shape.get('authored_transform')
        if t:
            a=math.radians(t['yaw']);c=math.cos(a);s=math.sin(a);points=[]
            for p in piece.vertices:
                x,y,z=[(v-o)*scale for v,o,scale in zip(p,t['origin'],t['scale'])]
                points.append((x*c-y*s+t['target'][0],x*s+y*c+t['target'][1],z+t['target'][2]))
            piece.vertices=points
        start=len(mesh.vertices)
        for p,uv,part in zip(piece.vertices,piece.uv,piece.parts):mesh.vertex(p,uv,part)
        mesh.faces.extend((m,tuple(start+i for i in tri)) for m,tri in piece.faces)
    return mesh

def output_files():
    names=['generate_teju_model.py','generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py','generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,791,geometry,tuple(Path(__file__).with_name(n) for n in names))

if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
