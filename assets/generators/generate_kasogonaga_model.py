"""Export the editable Kasogonaga anteater using established native geometry."""
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
SOURCE=ROOT/'assets/source/art/kasogonaga_795'
MODEL_PATH='models/caelum/folklore/kasogonaga'
DEFINITION='caelum/data/kasogonaga_combat.modeldef'

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
        remapped={}
        for material,tri in piece.faces:
            center=tuple(sum(piece.vertices[i][a] for i in tri)/3 for a in range(3))
            chosen=material
            for marking in shape.get('markings',[]):
                if abs(center[1])<marking.get('minimum_abs_y',0):continue
                for a,b in zip(marking['polyline_xz'],marking['polyline_xz'][1:]):
                    u=(b[0]-a[0],b[1]-a[1]);v=(center[0]-a[0],center[2]-a[1])
                    t=max(0,min(1,sum(x*y for x,y in zip(u,v))/sum(x*x for x in u)))
                    if math.hypot(v[0]-t*u[0],v[1]-t*u[1])<=marking['width']:chosen=marking['material'];break
            indices=[]
            for i in tri:
                if chosen==material:indices.append(start+i);continue
                key=(i,chosen)
                if key not in remapped:
                    old_tile=design['materials'][material]['tile'];new_tile=design['materials'][chosen]['tile']
                    uv=tuple(piece.uv[i][axis]+(new_tile[axis]-old_tile[axis])/design['atlas'][dimension] for axis,dimension in enumerate(('columns','rows')))
                    remapped[key]=mesh.vertex(piece.vertices[i],uv,piece.parts[i])
                indices.append(remapped[key])
            mesh.faces.append((chosen,tuple(indices)))
    return mesh

def output_files():
    names=['generate_kasogonaga_model.py','generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py','generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,795,geometry,tuple(Path(__file__).with_name(n) for n in names))

if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
