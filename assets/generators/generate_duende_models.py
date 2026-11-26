"""Export two fixed-reference folklore models through the shared combat writer."""
import copy
import math
from pathlib import Path
try:
    from .generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from .generate_pombero_model import geometry as body_geometry
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from generate_pombero_model import geometry as body_geometry
    from generate_nahuelito_model import Mesh

SOURCE=ROOT/'assets/source/art/duendes_690'
MODEL_PATH='models/caelum/folklore/duendes'
DEFINITION='caelum/data/duende_combat.modeldef'


def material_uv(design, material, u, v):
    settings=design['materials'][material]
    if 'tile' in settings:
        column,row=settings['tile'];inset=design['atlas']['inset']
        return ((column+inset+(1-2*inset)*u)/design['atlas']['columns'],
                (row+inset+(1-2*inset)*v)/design['atlas']['rows'])
    left,top,right,bottom=settings['uv_rect']
    return (left+(right-left)*u,top+(bottom-top)*v)


def ring_shell(design, shape):
    """Close a thin garment's radial profile while keeping both openings free."""
    mesh=Mesh();rows=shape['rows'];segments=shape['segments'];count=len(rows)
    lifts=shape.get('row_lift',[0]*count);slopes=shape.get('row_slope',[0]*count)
    materials=shape.get('row_materials',[shape['material']]*count)
    def point(index, segment):
        z,x,y,rx,ry=rows[index];angle=math.tau*segment/segments
        return (x+rx*math.cos(angle),y+ry*math.sin(angle),
                z+lifts[index]*abs(math.sin(angle))+slopes[index]*math.sin(angle))
    for index in range(count):
        following=(index+1)%count;material=materials[index]
        for segment in range(segments):
            indices=[]
            for row,step,u,v in ((index,segment,segment/segments,1),
                                 (index,segment+1,(segment+1)/segments,1),
                                 (following,segment+1,(segment+1)/segments,0),
                                 (following,segment,segment/segments,0)):
                position=point(row,step)
                if 'uv_projection' in shape and material in shape['uv_projection'].get('only_materials',[material]):
                    projection=shape['uv_projection'];first,second=projection['axes'];left,bottom,right,top=projection['bounds']
                    u=(position[first]-left)/(right-left);v=(position[second]-bottom)/(top-bottom)
                    if projection.get('flip_v'):v=1-v
                indices.append(mesh.vertex(position,material_uv(design,material,u,v),shape['part']))
            mesh.quad(tuple(indices),material)
    volume=0
    for _,triangle in mesh.faces:
        a,b,c=(mesh.vertices[i] for i in triangle)
        volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if volume<0:mesh.faces=[(material,tuple(reversed(triangle))) for material,triangle in mesh.faces]
    return mesh


def geometry(design):
    body=copy.deepcopy(design);body['shapes']=[s for s in body['shapes'] if s['kind']!='ring_shell']
    mesh=body_geometry(body)
    for shape in design['shapes']:
        if shape['kind']!='ring_shell':continue
        shell=ring_shell(design,shape);begin=len(mesh.vertices)
        for point,uv,part in zip(shell.vertices,shell.uv,shell.parts):mesh.vertex(point,uv,part)
        mesh.faces.extend((material,tuple(begin+i for i in triangle)) for material,triangle in shell.faces)
    return mesh


def output_files():
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,690,geometry,(Path(__file__),))


if __name__=='__main__':
    shared_main(SOURCE,DEFINITION,output_files)
