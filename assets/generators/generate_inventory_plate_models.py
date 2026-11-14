"""Export six native crafting plates through the existing closed shield primitives."""
from pathlib import Path
import argparse
import json
import zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,digest,output_files as shared_output
    from .generate_inventory_shield_models import geometry
except ImportError:
    from generate_inventory_ammunition_models import ROOT,digest,output_files as shared_output
    from generate_inventory_shield_models import geometry
SOURCE=ROOT/'assets/source/art/inventory_models_647/plates'

def output_files():
    files=shared_output(SOURCE,'inventory_plates.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for native,original in config['texture_sources'].items():files[native]=(ROOT/original).read_bytes()
    report=json.loads(files['manifest.json']);report['generator_sha256']['generate_inventory_shield_models.py']=digest(Path(__file__).with_name('generate_inventory_shield_models.py').read_bytes());report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        destinations=[args.output/name]
        if args.install:destinations.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in destinations:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale plate export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
        if args.install:
            config=json.loads((SOURCE/'DESIGN.json').read_text())
            for name in config['texture_sources']:
                path=SOURCE/'editable/src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(files[name])
    print(json.dumps({name:item['triangles'] for name,item in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
