"""Export distinct mule and plated-boar apparitions through shared native geometry."""
from pathlib import Path
import copy,math
try:
    from .generate_teju_model import geometry as component_geometry
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_nahuelito_model import Mesh,dot,cross
    from .generate_duende_models import material_uv
except ImportError:
    from generate_teju_model import geometry as component_geometry
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_nahuelito_model import Mesh,dot,cross
    from generate_duende_models import material_uv
SOURCE=ROOT/'assets/source/art/apparitions_797'
MODEL_PATH='models/caelum/folklore/apparitions'
DEFINITION='caelum/data/apparition_combat.modeldef'

def plate(design,shape):
    mesh=Mesh();rows,columns=shape['grid'];layers=[]
    for factor in shape['radial']:
        grid=[]
        for i in range(rows+1):
            row=[];lat=math.radians(shape['latitude'][0]+i/rows*(shape['latitude'][1]-shape['latitude'][0]))
            for j in range(columns+1):
                lon=math.radians(shape['longitude'][0]+j/columns*(shape['longitude'][1]-shape['longitude'][0]))
                q=(math.cos(lat)*math.cos(lon),math.cos(lat)*math.sin(lon),math.sin(lat))
                p=tuple(c+factor*r*v for c,r,v in zip(shape['center'],shape['radii'],q))
                row.append(mesh.vertex(p,material_uv(design,shape['material'],j/columns,1-i/rows),shape['part']))
            grid.append(row)
        layers.append(grid)
    material=shape['material'];inner,outer=layers;edges={}
    for i in range(rows):
        for j in range(columns):
            q=(outer[i][j],outer[i][j+1],outer[i+1][j+1],outer[i+1][j]);mesh.quad(q,material)
            for a,b in zip(q,q[1:]+q[:1]):edges.setdefault(tuple(sorted((a,b))),[]).append((a,b))
            mesh.quad((inner[i+1][j],inner[i+1][j+1],inner[i][j+1],inner[i][j]),material)
    correspondence={outer[i][j]:inner[i][j] for i in range(rows+1) for j in range(columns+1)}
    for owners in edges.values():
        if len(owners)==1:
            a,b=owners[0];mesh.quad((b,a,correspondence[a],correspondence[b]),material)
    if sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c])) for _,(a,b,c) in mesh.faces)<0:mesh.faces=[(m,tuple(reversed(t))) for m,t in mesh.faces]
    return mesh

def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        one=copy.deepcopy(design);one['shapes']=[shape]
        piece=plate(design,shape) if shape['kind']=='ellipsoid_patch' else component_geometry(one)
        start=len(mesh.vertices)
        for p,uv,part in zip(piece.vertices,piece.uv,piece.parts):mesh.vertex(p,uv,part)
        mesh.faces.extend((m,tuple(start+i for i in tri)) for m,tri in piece.faces)
    return mesh

def output_files():
    names=['generate_apparition_models.py','generate_teju_model.py','generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py','generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,797,geometry,tuple(Path(__file__).with_name(n) for n in names))

if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
