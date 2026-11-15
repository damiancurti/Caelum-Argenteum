"""Bind existing magical base meshes to matching native weapon drop states."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/magic_weapons'
def digest(blob):return hashlib.sha256(blob).hexdigest()


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed reused magical weapon source: '+path)
    original=json.loads((ROOT/config['source_export']).read_text());records={};definitions=[]
    for key,item in config['variants'].items():
        record=dict(original['variants'][key]);record['class']=item['class'];records[key]=record
        for binding in [item,*item['additional_bindings']]:
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}')
    files={'caelum/data/inventory_magic_weapons.modeldef':('\n'.join(definitions)+'\n').encode()}
    report=dict(schema_revision=1,issue=757,parent_issue=647,status=config['status'],variants=records,
        source_sha256={p:digest((SOURCE/p).read_bytes()) for p in ('DESIGN.json','PROVENANCE.json')},
        external_source_sha256=config['source_sha256'],generator_sha256={Path(__file__).name:digest(Path(__file__).read_bytes())},
        sha256={p:digest(b) for p,b in files.items()},reuse_note='Exact geometry, atlas and editable sources remain owned by #755; only six exact weapon bindings are exported.')
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale magical weapon binding: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            package.writestr(zipfile.ZipInfo('MODELDEF',(2026,11,15,0,0,0)),files['caelum/data/inventory_magic_weapons.modeldef'])
    print('Exported six exact magical weapon bindings; original geometry/material bytes unchanged')


if __name__=='__main__':main()
