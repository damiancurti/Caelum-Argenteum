"""Export reference-led avian anatomy with closed, curved feather volumes."""
from pathlib import Path
import copy,math
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_peuchen_model import geometry as body_geometry,dot,cross,sub
    from .generate_guardian_models import unit
    from .generate_duende_models import material_uv
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_peuchen_model import geometry as body_geometry,dot,cross,sub
    from generate_guardian_models import unit
    from generate_duende_models import material_uv
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/avian_711'
MODEL_PATH='models/caelum/folklore/avian'
DEFINITION='caelum/data/avian_combat.modeldef'


def feather(design,shape):
    """Close a curved vane with elliptical sections and a true terminal fan."""
    mesh=Mesh();start=shape['start'];end=shape['end'];bend=shape['bend'];rings=[]
    tangent=unit(sub(end,start));normal=unit(shape['normal'])
    normal=unit(tuple(n-dot(normal,tangent)*t for n,t in zip(normal,tangent)));side=cross(tangent,normal)
    rows=shape['profile'];segments=shape['segments'];material=shape['material']
    for t,width,thickness in rows:
        center=tuple((1-t)*a+t*b+4*t*(1-t)*c for a,b,c in zip(start,end,bend));ring=[]
        for j in range(segments+1):
            theta=math.tau*j/segments
            p=tuple(c+width*math.cos(theta)*s+thickness*math.sin(theta)*n for c,s,n in zip(center,side,normal))
            ring.append(mesh.vertex(p,material_uv(design,material,.5+.5*math.cos(theta),1-t),shape['part']))
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for j in range(segments):mesh.quad((a[j],a[j+1],b[j+1],b[j]),material)
    for index,point in [(0,start),(-1,end)]:
        cap=mesh.vertex(tuple(point),material_uv(design,material,.5,1 if index==0 else 0),shape['part'])
        for j in range(segments):
            tri=(cap,rings[index][j],rings[index][j+1]);mesh.faces.append((material,tri if index==-1 else tuple(reversed(tri))))
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    return mesh


def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        one=copy.deepcopy(design);one['shapes']=[shape]
        piece=feather(design,shape) if shape['kind']=='feather' else body_geometry(one)
        begin=len(mesh.vertices)
        for p,uv,part in zip(piece.vertices,piece.uv,piece.parts):mesh.vertex(p,uv,part)
        mesh.faces.extend((m,tuple(begin+i for i in tri)) for m,tri in piece.faces)
    return mesh


def output_files():
    names=['generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,711,geometry,tuple(Path(__file__).with_name(n) for n in names))


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
