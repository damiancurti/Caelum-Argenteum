"""Export two cartridge-kit drops using owned closed-volume geometry."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_hygiene_models import geometry as shared_geometry
    from .generate_nahuelito_model import Mesh,sub,cross,dot
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_hygiene_models import geometry as shared_geometry
    from generate_nahuelito_model import Mesh,sub,cross,dot
SOURCE=ROOT/'assets/source/art/inventory_models_647/cartridge_kits'


def geometry(config,family,tier):
    part=family['parts'][0];mesh,volumes=shared_geometry(config,family,tier)
    if 'radial_folds' in part:
        folds=part['radial_folds'];points=[]
        for x,y,z in mesh.vertices:
            angle=math.atan2(y,x);amount=1+folds['amplitude']*math.sin(angle*folds['count']+folds['phase'])
            points.append((x*amount,y*amount,z))
        mesh.vertices=points
        volume=sum(dot(points[a],cross(points[b],points[c]))/6 for _,(a,b,c) in mesh.faces)
        if volume<=0:raise ValueError('Folded package is not outward')
        volumes={part['part']:volume}
    if 'rim_relief' in part:
        r=part['rim_relief'];points=[]
        for x,y,z in mesh.vertices:
            angle=math.atan2(y,x)
            height=z if z<=2 else 2+(z-2)*(1+r['back_rise']*math.sin(angle)+r['wave']*math.sin(angle*r['frequency']))
            points.append((x,y,height))
        mesh.vertices=points
        volume=sum(dot(points[a],cross(points[b],points[c]))/6 for _,(a,b,c) in mesh.faces)
        if volume<=0:raise ValueError('Kit wrapper is not outward')
        volumes={part['part']:volume}
    if part.get('planar_uv'):
        low=[min(p[k] for p in mesh.vertices) for k in range(3)];high=[max(p[k] for p in mesh.vertices) for k in range(3)]
        result=Mesh()
        for material,face in mesh.faces:
            points=[mesh.vertices[i] for i in face];normal=cross(sub(points[1],points[0]),sub(points[2],points[0]))
            axis=max(range(3),key=lambda k:abs(normal[k]));u,v=[k for k in range(3) if k!=axis]
            indices=[result.vertex(p,((p[u]-low[u])/(high[u]-low[u]),(p[v]-low[v])/(high[v]-low[v])),part['part']) for p in points]
            result.faces.append((material,tuple(indices)))
        mesh=result
    return mesh,volumes


def output_files():
    files=shared_output(SOURCE,'inventory_cartridge_kits.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for p in paths:
            if args.check:
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale cartridge_kits export: '+str(p))
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
