"""Export reference-led Yasi and Yastay with editable open mantle volumes."""
from pathlib import Path
import copy
import math
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_nahuelito_model import Mesh
    from .generate_duende_models import geometry as shared_geometry,material_uv
    from .generate_inventory_clothing_models import garment_shell
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_nahuelito_model import Mesh
    from generate_duende_models import geometry as shared_geometry,material_uv
    from generate_inventory_clothing_models import garment_shell
SOURCE=ROOT/'assets/source/art/guardians_698'
MODEL_PATH='models/caelum/folklore/guardians'
DEFINITION='caelum/data/guardian_combat.modeldef'


def mantle(design,shape):
    """Lift the open front hem while retaining closed inner/outer cloth walls."""
    mesh,_=garment_shell(shape)
    start,stop=shape['arc_degrees'];segments=shape['segments'];rows=len(shape['rows'])
    for index,(x,y,z) in enumerate(mesh.vertices):
        row=index//(segments+1)%rows;step=index%(segments+1)
        angle=math.radians(start+(stop-start)*step/segments)
        mesh.vertices[index]=(x,y,z+shape['front_lift'][row]*max(0,math.cos(angle)))
    mesh.uv=[material_uv(design,shape['material'],u,v) for u,v in mesh.uv]
    return mesh


def dot(a,b):return sum(x*y for x,y in zip(a,b))
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def unit(v):
    length=math.sqrt(dot(v,v))
    if length<1e-12:raise ValueError('Collapsed tube tangent')
    return tuple(x/length for x in v)


def transport_tube(design,shape):
    """Carry a stable ring frame along a bend; use consistent outward winding."""
    mesh=Mesh();rows=shape['rows'];segments=shape.get('segments',16);rings=[];normal=None
    for i,row in enumerate(rows):
        tangent=unit(sub(rows[min(i+1,len(rows)-1)][:3],rows[max(i-1,0)][:3]))
        if normal is None:normal=min(((1.,0,0),(0,1.,0),(0,0,1.)),key=lambda v:abs(dot(v,tangent)))
        projected=tuple(v-dot(normal,tangent)*t for v,t in zip(normal,tangent))
        if dot(projected,projected)<1e-12:
            normal=min(((1.,0,0),(0,1.,0),(0,0,1.)),key=lambda v:abs(dot(v,tangent)))
            projected=tuple(v-dot(normal,tangent)*t for v,t in zip(normal,tangent))
        normal=unit(projected);up=cross(tangent,normal);ring=[]
        for j in range(segments+1):
            angle=math.tau*j/segments
            point=tuple(p+row[3]*math.cos(angle)*n+row[4]*math.sin(angle)*u for p,n,u in zip(row[:3],normal,up))
            u=.75-.25*math.cos(angle) if shape.get('cylindrical_shading') else j/segments
            ring.append(mesh.vertex(point,material_uv(design,shape['material'],u,i/(len(rows)-1)),shape['part']))
        rings.append(ring)
    material=shape['material']
    for i in range(len(rings)-1):
        for j in range(segments):mesh.quad((rings[i][j],rings[i][j+1],rings[i+1][j+1],rings[i+1][j]),material)
    for index in (0,len(rows)-1):
        center=mesh.vertex(tuple(rows[index][:3]),material_uv(design,material,.5,.5),shape['part'])
        for j in range(segments):
            tri=(center,rings[index][j],rings[index][j+1])
            if index==0:tri=tuple(reversed(tri))
            mesh.faces.append((material,tri))
    return mesh


def close_ellipsoid_caps(mesh,shape):
    """Seal the two deliberately clipped pole loops in the inherited primitive."""
    edges={}
    for material,tri in mesh.faces:
        for a,b in zip(tri,tri[1:]+tri[:1]):
            pa=tuple(round(v,7) for v in mesh.vertices[a]);pb=tuple(round(v,7) for v in mesh.vertices[b]);key=tuple(sorted((pa,pb)))
            edges.setdefault(key,[]).append((material,a,b))
    centers={}
    for owners in edges.values():
        if len(owners)!=1:continue
        material,a,b=owners[0];side=1 if mesh.vertices[a][2]>shape['center'][2] else -1;key=(side,material)
        if key not in centers:
            point=(shape['center'][0],shape['center'][1],shape['center'][2]+side*shape['radii'][2])
            uv=tuple((x+y)/2 for x,y in zip(mesh.uv[a],mesh.uv[b]))
            centers[key]=mesh.vertex(point,uv,shape['part'])
        mesh.faces.append((material,(b,a,centers[key])))
    return mesh


def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        if shape['kind']=='open_mantle':component=mantle(design,shape)
        elif shape['kind']=='tube':component=transport_tube(design,shape)
        else:
            body=copy.deepcopy(design);body['shapes']=[shape];component=shared_geometry(body)
            if shape['kind']=='ellipsoid':component=close_ellipsoid_caps(component,shape)
            projection=shape.get('front_projection')
            if projection and 'uv_rect' in design['materials'][projection['material']]:
                indices={i for material,tri in component.faces if material==projection['material'] for i in tri}
                for i in indices:component.uv[i]=material_uv(design,projection['material'],*component.uv[i])
            if shape['kind']=='ellipsoid' and shape['material']=='skin':
                indices={i for material,tri in component.faces if material=='skin' for i in tri}
                for i in indices:
                    x,y,z=component.vertices[i];u=.75-.25*max(-1,min(1,(x-shape['center'][0])/shape['radii'][0]))
                    v=.5-(z-shape['center'][2])/(2*shape['radii'][2]);component.uv[i]=material_uv(design,'skin',u,v)
        begin=len(mesh.vertices)
        for point,uv,part in zip(component.vertices,component.uv,component.parts):mesh.vertex(point,uv,part)
        mesh.faces.extend((material,tuple(begin+i for i in tri)) for material,tri in component.faces)
    return mesh


def output_files():
    extra=tuple(Path(__file__).with_name(n) for n in ('generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py'))
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,698,geometry,extra)


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
