"""Export original Familiar and Ao Ao anatomy with inherited combat states."""
from pathlib import Path
import copy
import math
try:
    from .generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from .generate_basilisco_model import geometry as shared_geometry
    from .generate_duende_models import material_uv
    from .generate_nahuelito_model import Mesh
    from .generate_peuchen_model import dot, cross
except ImportError:
    from generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from generate_basilisco_model import geometry as shared_geometry
    from generate_duende_models import material_uv
    from generate_nahuelito_model import Mesh
    from generate_peuchen_model import dot, cross

SOURCE = ROOT / 'assets/source/art/quadrupeds_787'
MODEL_PATH = 'models/caelum/folklore/quadrupeds'
DEFINITION = 'caelum/data/quadruped_combat.modeldef'


def repeated_ellipsoid(design, shape):
    """Split UV seams at authored repeat boundaries without changing the surface."""
    mesh = Mesh()
    lat, lon = shape['latitudes'], shape['longitudes']
    ru, rv = shape['material_repeat']
    if lon % ru or (lat + 1) % rv:
        raise ValueError('Material repeats must divide the authored surface grid')
    pu, pv = lon // ru, (lat + 1) // rv
    center, radii = shape['center'], shape['radii']
    def point(i, j):
        angle = -math.pi / 2 + math.pi * i / (lat + 1)
        theta = math.tau * j / lon
        direction = (math.cos(angle)*math.cos(theta), math.cos(angle)*math.sin(theta), math.sin(angle))
        return tuple(c+r*d for c,r,d in zip(center,radii,direction))
    def polygon(points, uv):
        indices = tuple(mesh.vertex(p,material_uv(design,shape['material'],u,1-v),shape['part']) for p,(u,v) in zip(points,uv))
        if len(indices) == 4: mesh.quad(indices,shape['material'])
        else: mesh.faces.append((shape['material'],indices))
    for i in range(1,lat):
        v0, v1 = (i%pv)/pv, (i%pv+1)/pv
        for j in range(lon):
            u0, u1 = (j%pu)/pu, (j%pu+1)/pu
            polygon([point(i,j),point(i,j+1),point(i+1,j+1),point(i+1,j)],[(u0,v0),(u1,v0),(u1,v1),(u0,v1)])
    for j in range(lon):
        u0, u1 = (j%pu)/pu, (j%pu+1)/pu
        polygon([point(0,0),point(1,j+1),point(1,j)],[((u0+u1)/2,0),(u1,1/pv),(u0,1/pv)])
        polygon([point(lat+1,0),point(lat,j),point(lat,j+1)],[((u0+u1)/2,1),(u0,1-1/pv),(u1,1-1/pv)])
    volume = sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume < 0: mesh.faces = [(m,tuple(reversed(t))) for m,t in mesh.faces]
    return mesh


def geometry(design):
    mesh = Mesh()
    for shape in design['shapes']:
        one = copy.deepcopy(design)
        one['shapes'] = [shape]
        piece = repeated_ellipsoid(design,shape) if 'material_repeat' in shape else shared_geometry(one)
        if 'lower_width_factor' in shape:
            cy, cz = shape['center'][1:]
            rz = shape['radii'][2]
            lower = shape['lower_width_factor']
            piece.vertices = [(x,cy+(y-cy)*(lower+(1-lower)*min(1,max(0,1+(z-cz)/rz))),z)
                              for x,y,z in piece.vertices]
        start = len(mesh.vertices)
        for point,uv,part in zip(piece.vertices,piece.uv,piece.parts): mesh.vertex(point,uv,part)
        mesh.faces.extend((m,tuple(start+i for i in t)) for m,t in piece.faces)
    return mesh


def output_files():
    names = ['generate_quadruped_models.py', 'generate_basilisco_model.py',
             'generate_serpent_models.py', 'generate_avian_models.py',
             'generate_peuchen_model.py', 'generate_guardian_models.py',
             'generate_duende_models.py', 'generate_inventory_clothing_models.py',
             'generate_pombero_model.py', 'generate_nahuelito_model.py']
    return shared_output(SOURCE, MODEL_PATH, DEFINITION, 787, geometry,
                         tuple(Path(__file__).with_name(n) for n in names))


if __name__ == '__main__':
    shared_main(SOURCE, DEFINITION, output_files)
