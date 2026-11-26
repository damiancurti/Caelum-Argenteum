"""Export three closed hooded effigy quality models."""
from pathlib import Path
import argparse,hashlib,json,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_magic_bases_models import geometry
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_magic_bases_models import geometry

SOURCE=ROOT/'assets/source/art/inventory_models_647/effigies'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    files=shared_output(SOURCE,'inventory_effigies.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json']);definitions=[]
    for key,item in config['variants'].items():
        for binding in [item,*item['additional_bindings']]:
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} {binding["frame"]} 0 0 }}')
    files['caelum/data/inventory_effigies.modeldef']=('\n'.join(definitions)+'\n').encode()
    for settings in config['materials'].values():
        path=settings['texture'];files['editable/src/'+path]=(ROOT/'src'/path).read_bytes()
    report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    report['reuse_note']='All runtime texture bytes remain owned by #755 and #723. Three original hooded sculpture variants and six exact bindings are installed.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale effigy export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,15,0,0,0)),blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
