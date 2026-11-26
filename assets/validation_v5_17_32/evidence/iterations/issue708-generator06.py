"""Export Peuchen anatomy and thick membranes without changing creature rules."""
from pathlib import Path
import copy
import math
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_guardian_models import geometry as closed_geometry
    from .generate_duende_models import material_uv
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_guardian_models import geometry as closed_geometry
    from generate_duende_models import material_uv
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/peuchen_708'
MODEL_PATH='models/caelum/folklore/peuchen'
DEFINITION='caelum/data/peuchen_combat.modeldef'


def dot(a,b):return sum(x*y for x,y in zip(a,b))
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])


def ellipsoid(design,shape):
    """Use true pole fans, avoiding sub-quantization clipped pole loops."""
    mesh=Mesh();rings=[];latitudes=shape['latitudes'];segments=shape['longitudes']
    cx,cy,cz=shape['center'];rx,ry,rz=shape['radii'];material=shape['material']
    for i in range(latitudes):
        angle=-math.pi/2+math.pi*(i+1)/(latitudes+1);ring=[]
        for j in range(segments+1):
            theta=math.tau*j/segments
            ring.append(mesh.vertex((cx+rx*math.cos(angle)*math.cos(theta),cy+ry*math.cos(angle)*math.sin(theta),cz+rz*math.sin(angle)),material_uv(design,material,j/segments,1-(i+1)/(latitudes+1)),shape['part']))
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for j in range(segments):mesh.quad((a[j],a[j+1],b[j+1],b[j]),material)
    for side,row in [(-1,rings[0]),(1,rings[-1])]:
        center=mesh.vertex((cx,cy,cz+side*rz),material_uv(design,material,.5,1 if side<0 else 0),shape['part'])
        for j in range(segments):
            tri=(center,row[j],row[j+1]);mesh.faces.append((material,tri if side>0 else tuple(reversed(tri))))
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    return mesh


def membrane(design,shape):
    """Subdivide a triangulated wing sheet, then close both faces and its rim."""
    mesh=Mesh();polygon=shape['polygon'];positions=[];faces=[];cache={};steps=shape['subdivisions']
    normal=cross(sub(polygon[1],polygon[0]),sub(polygon[-1],polygon[0]));size=dot(normal,normal)**.5
    normal=tuple(v/size for v in normal)
    def point(triangle,i,j):
        a,b,c=[polygon[k] for k in triangle];u=i/steps;v=j/steps;w=1-u-v
        p=tuple(w*a[k]+u*b[k]+v*c[k]+normal[k]*shape['billow']*27*u*v*w for k in range(3))
        key=tuple(round(x,8) for x in p)
        if key not in cache:cache[key]=len(positions);positions.append(p)
        return cache[key]
    for triangle in shape['triangles']:
        for i in range(steps):
            for j in range(steps-i):
                faces.append((point(triangle,i,j),point(triangle,i+1,j),point(triangle,i,j+1)))
                if i+j<steps-1:faces.append((point(triangle,i+1,j),point(triangle,i+1,j+1),point(triangle,i,j+1)))
    edges={}
    for tri in faces:
        for a,b in zip(tri,tri[1:]+tri[:1]):edges.setdefault(tuple(sorted((a,b))),[]).append((a,b))
    low=[min(p[k] for p in positions) for k in range(3)];high=[max(p[k] for p in positions) for k in range(3)]
    axes=sorted(range(3),key=lambda k:high[k]-low[k],reverse=True)[:2]
    for side in [-1,1]:
        for p in positions:
            uv=[(p[k]-low[k])/max(1e-9,high[k]-low[k]) for k in axes]
            mesh.vertex(tuple(v+side*shape['thickness']/2*n for v,n in zip(p,normal)),material_uv(design,shape['material'],*uv),shape['part'])
    count=len(positions)
    for tri in faces:
        mesh.faces.append((shape['material'],tuple(reversed(tri))))
        mesh.faces.append((shape['material'],tuple(i+count for i in tri)))
    for owners in edges.values():
        if len(owners)==1:
            a,b=owners[0];mesh.quad((a,b,b+count,a+count),shape['material'])
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    return mesh


def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        body=copy.deepcopy(design);body['shapes']=[shape]
        component=membrane(design,shape) if shape['kind']=='membrane' else ellipsoid(design,shape) if shape['kind']=='ellipsoid' else closed_geometry(body)
        for region in shape.get('surface_regions',[]):
            mapped={};old_uv=design['materials'][shape['material']];new=region['material']
            for index,(material,tri) in enumerate(component.faces):
                center=[sum(component.vertices[i][k] for i in tri)/3 for k in range(3)];value=center[region['axis']]
                if value<region.get('minimum',float('-inf')) or value>region.get('maximum',float('inf')) or abs(center[1])>region['max_abs_y']:continue
                if 'z_range' in region and not region['z_range'][0]<=center[2]<=region['z_range'][1]:continue
                vertices=[]
                for i in tri:
                    if i not in mapped:
                        u,v=component.uv[i];col,row=old_uv['tile'];inset=design['atlas']['inset']
                        u=(u*design['atlas']['columns']-col-inset)/(1-2*inset);v=(v*design['atlas']['rows']-row-inset)/(1-2*inset)
                        mapped[i]=component.vertex(component.vertices[i],material_uv(design,new,u,v),shape['part'])
                    vertices.append(mapped[i])
                component.faces[index]=(new,tuple(vertices))
        begin=len(mesh.vertices)
        for p,uv,part in zip(component.vertices,component.uv,component.parts):mesh.vertex(p,uv,part)
        mesh.faces.extend((m,tuple(begin+i for i in tri)) for m,tri in component.faces)
    return mesh


def output_files():
    extra=tuple(Path(__file__).with_name(n) for n in ('generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py'))
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,708,geometry,extra)


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
