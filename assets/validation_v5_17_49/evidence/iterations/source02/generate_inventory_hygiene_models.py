"""Export three hygiene crafting drops using existing closed-volume geometry."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_weapon_components_models import geometry as component_geometry
    from .generate_nahuelito_model import Mesh,dot,cross,sub
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_weapon_components_models import geometry as component_geometry
    from generate_nahuelito_model import Mesh,dot,cross,sub
SOURCE=ROOT/'assets/source/art/inventory_models_647/hygiene'


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='organic':
        shape=dict(part,kind='ellipsoid')
        mesh,_=component_geometry(config,{'parts':[shape]},tier)
        points=[]
        for point in mesh.vertices:
            unit=[(v-c)/r for v,c,r in zip(point,part['center'],part['radii'])]
            multiplier=1+sum(b['amplitude']*math.exp(-sum((x-y)**2 for x,y in zip(unit,b['direction']))/b['width']) for b in part['bumps'])
            shaped=[c+r*math.copysign(abs(v)**power,v)*multiplier for v,c,r,power in zip(unit,part['center'],part['radii'],part['axis_powers'])]
            shaped[2]+=sum(w['amplitude']*math.sin(shaped[w['axis']]*w['frequency']+w['phase']) for w in part['waves'])
            points.append(tuple(shaped))
        mesh.vertices=points
        volume=sum(dot(points[a],cross(points[b],points[c]))/6 for _,(a,b,c) in mesh.faces)
        if volume<=0:raise ValueError('Organic hygiene volume is not outward')
        return mesh,{part['part']:volume}
    mesh,volumes=component_geometry(config,family,tier)
    if part['kind']=='bevel':
        # Give every side actual two-dimensional texture coordinates.
        low=[min(p[k] for p in mesh.vertices) for k in range(3)];high=[max(p[k] for p in mesh.vertices) for k in range(3)]
        result=Mesh()
        for material,face in mesh.faces:
            points=[mesh.vertices[i] for i in face];normal=cross(sub(points[1],points[0]),sub(points[2],points[0]))
            axis=max(range(3),key=lambda k:abs(normal[k]));u,v=[k for k in range(3) if k!=axis]
            indices=[result.vertex(p,((p[u]-low[u])/(high[u]-low[u]),(p[v]-low[v])/(high[v]-low[v])),part['part']) for p in points]
            result.faces.append((material,tuple(indices)))
        return result,volumes
    return mesh,volumes


def output_files():
    files=shared_output(SOURCE,'inventory_hygiene.modeldef',('DESIGN.json','PROVENANCE.json','MATERIALS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/hygiene/materials.png';files[name]=(SOURCE/'materials.png').read_bytes()
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
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale hygiene export: '+str(p))
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
