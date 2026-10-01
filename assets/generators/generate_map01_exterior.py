"""Generate issue #61 terrain from the preserved accepted MAP01, deterministically.

The native triangulated floors meet at shared sampled heights. Cells containing
existing geometry remain untouched; the new surface fades to zero at every edge.
"""
from collections import defaultdict
from copy import deepcopy
import hashlib
import json
import math
from pathlib import Path

from repair_map01_mansion import read_map, write_map

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets/map01_mansion'


def generate():
    spec = json.loads((DATA / 'EXTERIOR.json').read_text(encoding='utf-8'))
    source = DATA / spec['baseline']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == spec['baseline_sha256']
    obj = read_map(source)
    original_counts = {k: len(v) for k, v in obj.items()}
    vertices, lines, sides, sectors = (obj[k] for k in ('vertex','linedef','sidedef','sector'))
    terrain = spec['terrain']
    step = terrain['grid']
    x0,y0,x1,y1 = terrain['bounds']
    nx,ny = (x1-x0)//step,(y1-y0)//step
    base_sector = terrain['sector']
    base = sectors[base_sector]
    assert base['heightfloor'] == 0 and base['texturefloor'] == terrain['texture']
    boundary = []
    occupied = set()
    for line in lines:
        a,b = [vertices[line[k]] for k in ('v1','v2')]
        front = sides[line['sidefront']]['sector']
        back = sides[line['sideback']]['sector'] if line.get('sideback',-1)>=0 else -1
        if (front == base_sector) != (back == base_sector):
            boundary.append((a,b))
        # Bounding boxes conservatively protect all existing wall, water,
        # cave, control and decorative geometry. Nothing is cut or rewritten.
        for ix in range(max(0,math.floor((min(a['x'],b['x'])-x0)/step)),min(nx-1,math.floor((max(a['x'],b['x'])-x0)/step))+1):
            for iy in range(max(0,math.floor((min(a['y'],b['y'])-y0)/step)),min(ny-1,math.floor((max(a['y'],b['y'])-y0)/step))+1):
                # Outer horizon lines lie wholly outside this mesh.
                if max(a['x'],b['x'])<x0 or min(a['x'],b['x'])>x1 or max(a['y'],b['y'])<y0 or min(a['y'],b['y'])>y1:continue
                occupied.add((ix,iy))
    def in_base(x,y):
        return sum((a['y']>y)!=(b['y']>y) and x<(b['x']-a['x'])*(y-a['y'])/(b['y']-a['y'])+a['x'] for a,b in boundary)%2 == 1
    cells = set()
    for ix in range(nx):
        for iy in range(ny):
            x,y = x0+(ix+.5)*step,y0+(iy+.5)*step
            protected = any(a-step/2<x<b+step/2 and c-step/2<y<d+step/2 for a,c,b,d in terrain['protected_rectangles'])
            if (ix,iy) not in occupied and not protected and in_base(x,y):
                cells.add((ix,iy))
    nodes = {(ix+dx,iy+dy) for ix,iy in cells for dx,dy in [(0,0),(1,0),(1,1),(0,1)]}
    edge_nodes = {(ix,iy) for ix,iy in nodes if any((ix+dx,iy+dy) not in cells for dx,dy in [(-1,-1),(0,-1),(0,0),(-1,0)])}
    edge_points = [(x0+ix*step,y0+iy*step) for ix,iy in sorted(edge_nodes)]
    heights = {}
    for ix,iy in sorted(nodes):
        x,y = x0+ix*step,y0+iy*step
        distance = min(math.hypot(x-a,y-b) for a,b in edge_points)
        t = min(1,distance/terrain['edge_blend'])
        fade = t*t*(3-2*t)
        z = sum(h*math.exp(-2*((x-cx)/rx)**2-2*((y-cy)/ry)**2) for cx,cy,rx,ry,h in terrain['hills'])
        heights[ix,iy] = round(min(terrain['maximum_height'],z)*fade,6)
    vertex_ids = {}
    for node in sorted(nodes):
        vertex_ids[node] = len(vertices)
        vertices.append(dict(x=x0+node[0]*step,y=y0+node[1]*step))
    edges = {}
    triangles = []
    maximum_gradient = 0
    for ix,iy in sorted(cells):
        a,b,c,d = (ix,iy),(ix,iy+1),(ix+1,iy+1),(ix+1,iy)
        triples = [(a,b,c),(a,c,d)] if (ix+iy)%2==0 else [(a,b,d),(b,c,d)]
        for tri in triples:
            points=[(x0+n[0]*step,y0+n[1]*step,heights[n]) for n in tri]
            p,q,r=points
            det=(q[0]-p[0])*(r[1]-p[1])-(r[0]-p[0])*(q[1]-p[1])
            gx=((q[2]-p[2])*(r[1]-p[1])-(r[2]-p[2])*(q[1]-p[1]))/det
            gy=((q[0]-p[0])*(r[2]-p[2])-(r[0]-p[0])*(q[2]-p[2]))/det
            maximum_gradient=max(maximum_gradient,math.hypot(gx,gy))
            si=len(sectors)
            sector=deepcopy(base)
            sector.update(floorplane_a=-gx,floorplane_b=-gy,floorplane_c=1.0,floorplane_d=gx*p[0]+gy*p[1]-p[2],comment='Issue #61: continuous exterior terrain')
            sectors.append(sector)
            triangles.append(dict(sector=si,vertices=[vertex_ids[n] for n in tri],heights=[heights[n] for n in tri]))
            for u,w in zip(tri,tri[1:]+tri[:1]):
                va,vb=vertex_ids[u],vertex_ids[w]
                sd=len(sides);sides.append(dict(sector=si))
                if (vb,va) in edges:
                    lines[edges[vb,va]].update(sideback=sd,twosided=True)
                else:
                    edges[va,vb]=len(lines)
                    lines.append(dict(v1=va,v2=vb,sidefront=sd))
    for li in edges.values():
        if 'sideback' not in lines[li]:
            lines[li].update(sideback=len(sides),twosided=True)
            sides.append(dict(sector=base_sector))
    report=dict(issue=61,baseline_sha256=spec['baseline_sha256'],original_counts=original_counts,terrain_triangles=triangles,maximum_height=max(heights.values()),maximum_gradient=maximum_gradient)
    add_vegetation(obj,spec,report,in_base)
    from mansion_tympana import add_tympana
    add_tympana(obj,spec['tympana'],report,ROOT)
    report['terrain_linedef_end']=len(lines)
    from mansion_exterior_partition import partition_exterior
    partition_exterior(obj,spec['exterior_partition'],report)
    from mansion_decorative_cave import add_cave
    add_cave(obj,json.loads((DATA/spec['cave']).read_text(encoding='utf-8')),report,ROOT)
    write_map(obj,ROOT/'src/maps/MAP01.wad')
    report['counts']={k:len(v) for k,v in obj.items()}
    report['output_sha256']=hashlib.sha256((ROOT/'src/maps/MAP01.wad').read_bytes()).hexdigest()
    (DATA/'EXTERIOR_GENERATED.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k not in ('terrain_triangles','vegetation','tympana','cave')}))


def add_vegetation(obj,spec,report,in_base):
    vegetation=spec['vegetation']
    report['vegetation']=[]
    for kind,placements in [('trees',vegetation['trees']),('shrubs',vegetation['shrubs'])]:
        for p in placements:
            x,y=p[:2]
            assert in_base(x,y), f'Vegetation must stand on original exterior ground: {p}'
            margin=vegetation['exclusion_margin']
            assert not any(a-margin<=x<=b+margin and c-margin<=y<=d+margin
                           for a,c,b,d in vegetation['excluded_rectangles']), f'Vegetation intersects the protected pool margin: {p}'
            editor=vegetation['first_editor_number']+(p[2] if kind=='trees' else 3)
            thing=dict(x=x,y=y,height=0,type=editor,skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,dm=True,comment='Issue #61: decorative vegetation; no gathering')
            report['vegetation'].append(dict(thing=len(obj['thing']),kind=kind,position=[x,y]))
            obj['thing'].append(thing)


if __name__=='__main__':
    generate()
