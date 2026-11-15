"""Export four hollow torso armor drops and their owned material references."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from .generate_inventory_armor_helmets_models import arc
    from .generate_inventory_clothing_models import garment_shell
    from .generate_nahuelito_model import Mesh
    from .generate_inventory_consumable_models import geometry as consumable_geometry
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from generate_inventory_armor_helmets_models import arc
    from generate_inventory_clothing_models import garment_shell
    from generate_nahuelito_model import Mesh
    from generate_inventory_consumable_models import geometry as consumable_geometry
SOURCE=ROOT/'assets/source/art/inventory_models_647/armor_torso'
def digest(blob):return hashlib.sha256(blob).hexdigest()
def cuirass_shell(shape):
    """Thicken a torso surface with real neck, waist and two arm apertures."""
    mesh=Mesh();rows=shape['rows'];n=shape['segments'];points={};quads=[]
    for side in [0,1]:
        for j,(z,x,y,rx,ry) in enumerate(rows):
            for k in range(n):
                a=2*math.pi*k/n;t=side*shape['thickness']
                points[side,j,k]=(x+(rx-t)*math.cos(a),y+(ry-t)*math.sin(a),z)
    for j in range(len(rows)-1):
        for k in range(n):
            angle=360*(k+.5)/n
            if any(h['low']<=rows[j][0] and rows[j+1][0]<=h['high'] and any(a<=angle<=b for a,b in h['arcs']) for h in shape['holes']):continue
            q=[(0,j,k),(0,j,(k+1)%n),(0,j+1,(k+1)%n),(0,j+1,k)]
            quads.append(q)
    edges={}
    for q in quads:
        for a,b in zip(q,q[1:]+q[:1]):
            key=tuple(sorted((a,b)))
            if key in edges:edges[key]=None
            else:edges[key]=(a,b)
    inner=lambda p:(1,p[1],p[2])
    surface=quads+[list(reversed([inner(p) for p in q])) for q in quads]
    surface += [[b,a,inner(a),inner(b)] for pair in edges.values() if pair is not None for a,b in [pair]]
    volume=0
    for q in surface:
        ids=[mesh.vertex(points[p],uv,shape['part']) for p,uv in zip(q,[(0,0),(1,0),(1,1),(0,1)])]
        mesh.quad(ids,shape['material'])
    for _,tri in mesh.faces:
        a,b,c=[mesh.vertices[i] for i in tri]
        volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if volume<=0:raise ValueError('Inward cuirass shell')
    return mesh,{shape['part']:volume}


def project_shell(mesh,volumes,part):
    """Give shell rims independent nondegenerate planar UV coordinates."""
    low=[min(p[i] for p in mesh.vertices) for i in range(3)]
    high=[max(p[i] for p in mesh.vertices) for i in range(3)];projected=Mesh()
    for material,tri in mesh.faces:
        points=[mesh.vertices[i] for i in tri]
        a=[points[1][i]-points[0][i] for i in range(3)];b=[points[2][i]-points[0][i] for i in range(3)]
        normal=[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
        axis=max(range(3),key=lambda i:abs(normal[i]));u,v=((1,2),(0,2),(0,1))[axis]
        indices=tuple(projected.vertex(p,((p[u]-low[u])/(high[u]-low[u]),(p[v]-low[v])/(high[v]-low[v])),part) for p in points)
        projected.faces.append((material,indices))
    return projected,volumes

def mantle_shell(shape):
    """Build one closed fur mantle following its shoulder's curved surface."""
    mesh=Mesh();n=shape['segments'];rings=[];cx,cy,cz=shape['center'];rx,ry,rz=shape['radii']
    for side in [1,-1]:
        layers=[]
        center=mesh.vertex((cx,cy,cz+rz+side*shape['thickness']/2),(.5,.5),shape['part'])
        for row in range(1,shape['rows']+1):
            ring=[]
            for i in range(n):
                angle=i*math.tau/n;radius=shape['edge_radius'][i%len(shape['edge_radius'])]*row/shape['rows']
                x=rx*radius*math.cos(angle);y=ry*radius*math.sin(angle)
                z=cz+rz*math.sqrt(1-radius*radius)+side*shape['thickness']/2
                ring.append(mesh.vertex((cx+x,cy+y,z),(.5+x/(2*rx),.5+y/(2*ry)),shape['part']))
            if not layers:
                for i in range(n):
                    tri=(center,ring[i],ring[(i+1)%n]);mesh.faces.append((shape['material'],tri if side==1 else tuple(reversed(tri))))
            else:
                for i in range(n):
                    q=(layers[-1][i],ring[i],ring[(i+1)%n],layers[-1][(i+1)%n]);mesh.quad(q if side==1 else tuple(reversed(q)),shape['material'])
            layers.append(ring)
        rings.append(layers[-1])
    for i in range(n):mesh.quad((rings[0][i],rings[1][i],rings[1][(i+1)%n],rings[0][(i+1)%n]),shape['material'])
    volume=0
    for _,tri in mesh.faces:
        a,b,c=[mesh.vertices[i] for i in tri]
        volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if volume<=0:raise ValueError('Inward fur mantle')
    return mesh,{shape['part']:volume}

def geometry(config,family,tier):
    shape=family['parts'][0]
    if shape['kind']=='mantle_shell':return project_shell(*mantle_shell(shape),shape['part'])
    if shape['kind']=='cuirass_shell':return project_shell(*cuirass_shell(shape),shape['part'])
    if shape['kind']=='garment_shell':return project_shell(*garment_shell(shape),shape['part'])
    if family['parts'][0]['kind']=='arc_shell':return arc(family['parts'][0])
    return consumable_geometry(config,family,tier) if family['parts'][0]['kind']=='prism' else shared_geometry(config,family,tier)

def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text());files=shared_output(SOURCE,'inventory_armor_torso.modeldef',('DESIGN.json','PROVENANCE.json','FUR_BRIEF.json','FUR_PROMPT.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        name=settings['texture'];files['editable/src/'+name]=(ROOT/'src'/name).read_bytes()
    files[config['model_path']+'/fur.png']=(SOURCE/'fur.png').read_bytes()
    report['sha256']={n:digest(b) for n,b in files.items() if n!='manifest.json'};report['reuse_note']='Original inventory icons and reused materials remain byte-identical. One new generated fur material is copied unchanged from its recorded source.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);p.add_argument('--install',action='store_true');p.add_argument('--check',action='store_true');a=p.parse_args();files=output_files()
    for n,b in files.items():
        paths=[a.output/n]
        if a.install:paths.append(SOURCE/'EXPORT.json' if n=='manifest.json' else SOURCE/n if n.startswith('editable/') else ROOT/'src'/n)
        for path in paths:
            if a.check:
                if not path.is_file() or path.read_bytes()!=b:raise ValueError('Stale torso armor export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b)
    if not a.check:
        with zipfile.ZipFile(a.output/'preview.pk3','w') as z:
            for n,b in sorted(files.items()):
                if n=='manifest.json' or n.startswith('editable/'):continue
                z.writestr(zipfile.ZipInfo('MODELDEF' if n.endswith('.modeldef') else n,(2026,11,15,0,0,0)),b)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))
if __name__=='__main__':main()
