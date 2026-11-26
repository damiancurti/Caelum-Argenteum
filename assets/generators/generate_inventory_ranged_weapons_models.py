"""Export carbine, shotgun, longbow and crossbow world-drop assemblies."""
from pathlib import Path
import argparse,hashlib,json,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_polearms_models import geometry as socket_geometry
    from .generate_inventory_articulated_weapons_models import geometry as articulated_geometry
    from .generate_inventory_chains_models import geometry as chain_geometry
    from .generate_inventory_consumable_models import geometry as consumable_geometry
    from .generate_nahuelito_model import Mesh,cross,sub
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_polearms_models import geometry as socket_geometry
    from generate_inventory_articulated_weapons_models import geometry as articulated_geometry
    from generate_inventory_chains_models import geometry as chain_geometry
    from generate_inventory_consumable_models import geometry as consumable_geometry
    from generate_nahuelito_model import Mesh,cross,sub

SOURCE=ROOT/'assets/source/art/inventory_models_647/ranged_weapons'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='socket':return socket_geometry(config,family,tier)
    return articulated_geometry(config,family,tier)


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    files=shared_output(SOURCE,'inventory_ranged_weapons.modeldef',('DESIGN.json','PROVENANCE.json','CANVAS_PROMPT.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        path=settings['texture'];files['editable/src/'+path]=(ROOT/'src'/path).read_bytes()
    files['models/caelum/inventory/ranged_weapons/canvas.png']=(SOURCE/'canvas.png').read_bytes()
    report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    report['reuse_note']='Existing owned pixels remain unchanged; one original opaque canvas texture is added with its exact built-in generation prompt.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale ranged-weapon export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,15,0,0,0)),blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
