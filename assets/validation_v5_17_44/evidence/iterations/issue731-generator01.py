"""Export four irregular hide sheets with subdivided folds, underside and rim."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_weapon_components_models import caps
    from .generate_nahuelito_model import Mesh,dot,cross
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_weapon_components_models import caps
    from generate_nahuelito_model import Mesh,dot,cross
SOURCE=ROOT/'assets/source/art/inventory_models_647/hides'


def geometry(config,family,tier):
    part=family['parts'][0];outline=[tuple(p) for p in part['outline']]
    area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(outline,outline[1:]+outline[:1]))
    if area<0:outline.reverse()
    points=list(outline);faces=caps(outline)
    for _ in range(part['subdivisions']):
        midpoints={};refined=[]
        def middle(a,b):
            key=tuple(sorted((a,b)))
            if key not in midpoints:
                midpoints[key]=len(points);points.append(tuple((x+y)/2 for x,y in zip(points[a],points[b])))
            return midpoints[key]
        for a,b,c in faces:
            ab,bc,ca=middle(a,b),middle(b,c),middle(c,a)
            refined.extend([(a,ab,ca),(ab,b,bc),(ca,bc,c),(ab,bc,ca)])
        faces=refined
    edges={}
    for tri in faces:
        for a,b in zip(tri,tri[1:]+tri[:1]):edges.setdefault(tuple(sorted((a,b))),[]).append((a,b))
    mesh=Mesh();low=[min(p[k] for p in points) for k in [0,1]];high=[max(p[k] for p in points) for k in [0,1]]
    for side in [-1,1]:
        for x,y in points:
            z=sum(w['amplitude']*math.sin((x,y)[w['axis']]*w['frequency']+w['phase']) for w in part['waves'])+side*part['thickness']/2
            mesh.vertex((x,y,z),((x-low[0])/(high[0]-low[0]),(y-low[1])/(high[1]-low[1])),part['part'])
    count=len(points);material=part['material']
    for tri in faces:mesh.faces.extend([(material,tuple(reversed(tri))),(material,tuple(i+count for i in tri))])
    for owners in edges.values():
        if len(owners)==1:
            a,b=owners[0];mesh.quad((a,b,b+count,a+count),material)
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Hide sheet has no volume')
    return mesh,{part['part']:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_hides.modeldef',('DESIGN.json','PROVENANCE.json','MATERIALS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/hides/materials.png';files[name]=(SOURCE/'materials.png').read_bytes()
    report=json.loads(files['manifest.json']);report['sha256'][name]=hashlib.sha256(files[name]).hexdigest()
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for p in paths:
            if args.check:
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale hide export: '+str(p))
            else:p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    if not args.check:
        config=json.loads((SOURCE/'DESIGN.json').read_text())
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
            for texture in sorted({s['texture'] for s in config['materials'].values()}):
                blob=(ROOT/'src'/texture).read_bytes()
                if texture not in files:package.writestr(zipfile.ZipInfo(texture,(2026,11,14,0,0,0)),blob)
                if args.install:
                    p=SOURCE/'editable/src'/texture;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
