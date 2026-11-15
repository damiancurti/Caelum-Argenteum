"""Export four hollow armor helmet drops and their owned material references."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from .generate_nahuelito_model import Mesh,cross,sub
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from generate_nahuelito_model import Mesh,cross,sub
SOURCE=ROOT/'assets/source/art/inventory_models_647/armor_helmets'
def digest(blob):return hashlib.sha256(blob).hexdigest()
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def arc(part):
    mesh=Mesh();rows=part['rows'];profile=[(z,rx,ry) for z,rx,ry in rows]+[(z,rx-part['thickness'],ry-part['thickness']) for z,rx,ry in reversed(rows)]
    count=len(profile);segments=part['segments'];rings=[];material=part['material'];name=part['part']
    for i in range(segments+1):
        theta=math.radians(part['angles'][0]+(part['angles'][1]-part['angles'][0])*i/segments)
        rings.append([mesh.vertex((rx*math.cos(theta),ry*math.sin(theta),z),(i/segments,j/count),name) for j,(z,rx,ry) in enumerate(profile)])
    for i in range(segments):
        for j in range(count):
            k=(j+1)%count;mesh.quad((rings[i][j],rings[i+1][j],rings[i+1][k],rings[i][k]),material)
    for i,sign in [(0,-1),(segments,1)]:
        theta=math.radians(part['angles'][0] if i==0 else part['angles'][1]);normal=(-sign*math.sin(theta),sign*math.cos(theta),0)
        points=[mesh.vertices[n] for n in rings[i]];center=mesh.vertex(tuple(sum(p[k] for p in points)/count for k in range(3)),(.5,.5),name)
        for j in range(count):
            face=(center,rings[i][j],rings[i][(j+1)%count]);a,b,c=[mesh.vertices[n] for n in face]
            if dot(cross(sub(b,a),sub(c,a)),normal)<0:face=tuple(reversed(face))
            mesh.faces.append((material,face))
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<=0:raise ValueError('Inward helmet shell '+name)
    # Independent planar UVs preserve area on side walls, rims and end caps.
    low=[min(p[k] for p in mesh.vertices) for k in range(3)];high=[max(p[k] for p in mesh.vertices) for k in range(3)];result=Mesh()
    for material,face in mesh.faces:
        points=[mesh.vertices[i] for i in face];normal=cross(sub(points[1],points[0]),sub(points[2],points[0]));axis=max(range(3),key=lambda k:abs(normal[k]));u,v=[k for k in range(3) if k!=axis]
        indices=[result.vertex(p,((p[u]-low[u])/(high[u]-low[u]),(p[v]-low[v])/(high[v]-low[v])),name) for p in points];result.faces.append((material,tuple(indices)))
    return result,{name:volume}
def geometry(config,family,tier):
    part=family['parts'][0]
    return arc(part) if part['kind']=='arc_shell' else shared_geometry(config,family,tier)
def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text());files=shared_output(SOURCE,'inventory_armor_helmets.modeldef',('DESIGN.json','PROVENANCE.json','GOLD_PROMPT.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        name=settings['texture'];files['editable/src/'+name]=(ROOT/'src'/name).read_bytes()
    files['models/caelum/inventory/armor_helmets/gold.png']=(SOURCE/'gold.png').read_bytes()
    report['sha256']={n:digest(b) for n,b in files.items() if n!='manifest.json'};report['reuse_note']='Existing owned pixels remain unchanged; one original opaque golden brass texture is added. Small original plumage color samples retain their source alpha.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);p.add_argument('--install',action='store_true');p.add_argument('--check',action='store_true');a=p.parse_args();files=output_files()
    for n,b in files.items():
        paths=[a.output/n]
        if a.install:paths.append(SOURCE/'EXPORT.json' if n=='manifest.json' else SOURCE/n if n.startswith('editable/') else ROOT/'src'/n)
        for path in paths:
            if a.check:
                if not path.is_file() or path.read_bytes()!=b:raise ValueError('Stale armor helmet export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b)
    if not a.check:
        with zipfile.ZipFile(a.output/'preview.pk3','w') as z:
            for n,b in sorted(files.items()):
                if n=='manifest.json' or n.startswith('editable/'):continue
                z.writestr(zipfile.ZipInfo('MODELDEF' if n.endswith('.modeldef') else n,(2026,11,15,0,0,0)),b)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))
if __name__=='__main__':main()
