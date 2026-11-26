"""Export flail, giant-gauntlet and bolas world-drop assemblies."""
from pathlib import Path
import argparse,hashlib,json,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_hygiene_models import geometry as base_geometry
    from .generate_inventory_chains_models import geometry as chain_geometry
    from .generate_inventory_consumable_models import geometry as consumable_geometry
    from .generate_nahuelito_model import Mesh,cross,sub
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_hygiene_models import geometry as base_geometry
    from generate_inventory_chains_models import geometry as chain_geometry
    from generate_inventory_consumable_models import geometry as consumable_geometry
    from generate_nahuelito_model import Mesh,cross,sub

SOURCE=ROOT/'assets/source/art/inventory_models_647/articulated_weapons'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='ring':return chain_geometry(config,family,tier)
    if part['kind']=='tube':return consumable_geometry(config,family,tier)
    mesh,volumes=base_geometry(config,family,tier)
    if part['kind']!='spike':return mesh,volumes
    # Spike caps require a planar map instead of collapsed cylindrical UVs.
    result=Mesh();radius=part['radius']
    for material,face in mesh.faces:
        points=[mesh.vertices[i] for i in face]
        normal=cross(sub(points[1],points[0]),sub(points[2],points[0]))
        if abs(normal[2])>abs(normal[0])+abs(normal[1]):
            indices=[result.vertex(p,((p[0]/radius+1)/2,(p[1]/radius+1)/2),part['part']) for p in points]
        else:indices=[result.vertex(mesh.vertices[i],mesh.uv[i],part['part']) for i in face]
        result.faces.append((material,tuple(indices)))
    return result,volumes


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    files=shared_output(SOURCE,'inventory_articulated_weapons.modeldef',('DESIGN.json','PROVENANCE.json','LEATHER_PROMPT.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        path=settings['texture'];files['editable/src/'+path]=(ROOT/'src'/path).read_bytes()
    files['models/caelum/inventory/articulated_weapons/leather.png']=(SOURCE/'leather.png').read_bytes()
    report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    report['reuse_note']='Existing owned pixels remain unchanged; one original opaque leather texture is added with its exact built-in generation prompt.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale articulated-weapon export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,15,0,0,0)),blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
