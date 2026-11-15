"""Export four closed javelin, spear, halberd and utility-staff drop models."""
from pathlib import Path
import argparse,hashlib,json,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_hygiene_models import geometry as base_geometry
    from .generate_nahuelito_model import Mesh,cross,sub
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_hygiene_models import geometry as base_geometry
    from generate_nahuelito_model import Mesh,cross,sub

SOURCE=ROOT/'assets/source/art/inventory_models_647/polearms'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(config,family,tier):
    mesh,volumes=base_geometry(config,family,tier)
    part=family['parts'][0]
    if part['kind']=='socket':
        result=Mesh();radius=max(p[1] for p in part['profile'])
        a,b,c,d=part['uv_regions']['outer'];left,top,right,bottom=part['uv_bounds']
        for material,face in mesh.faces:
            uv=[mesh.uv[i] for i in face];u,v,w=uv
            collapsed=abs((v[0]-u[0])*(w[1]-u[1])-(v[1]-u[1])*(w[0]-u[0]))<1e-12
            indices=[]
            for i,old_uv in zip(face,uv):
                point=mesh.vertices[i]
                mapped=(((a+(c-a)*(point[0]/radius+1)/2)-left)/(right-left),((b+(d-b)*(point[1]/radius+1)/2)-top)/(bottom-top)) if collapsed else old_uv
                indices.append(result.vertex(point,mapped,part['part']))
            result.faces.append((material,tuple(indices)))
        return result,volumes
    if part['kind']!='blade':return mesh,volumes
    low=[min(p[k] for p in mesh.vertices) for k in range(3)];high=[max(p[k] for p in mesh.vertices) for k in range(3)]
    result=Mesh()
    for material,face in mesh.faces:
        points=[mesh.vertices[i] for i in face];normal=cross(sub(points[1],points[0]),sub(points[2],points[0]))
        axis=max(range(3),key=lambda k:abs(normal[k]));u,v=[k for k in range(3) if k!=axis]
        indices=[result.vertex(p,((p[u]-low[u])/(high[u]-low[u]),(p[v]-low[v])/(high[v]-low[v])),part['part']) for p in points]
        result.faces.append((material,tuple(indices)))
    return result,volumes


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    files=shared_output(SOURCE,'inventory_polearms.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        path=settings['texture'];files['editable/src/'+path]=(ROOT/'src'/path).read_bytes()
    report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    report['reuse_note']='Existing owned texture pixels are reused unchanged; no duplicate runtime textures.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale polearm export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,15,0,0,0)),blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
