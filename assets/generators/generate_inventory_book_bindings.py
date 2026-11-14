"""Bind the original owned book to matching support and material world states."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/books'
def digest(blob):return hashlib.sha256(blob).hexdigest()
def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed original book source: '+path)
    original=json.loads((ROOT/config['source_export']).read_text())
    record=dict(original['variants'][config['source_variant']]);record['class']='CaelumWeaponPickup'
    item=config['variants']['book']
    definition=('\n'.join(f'Model {binding["class"]} {{ Path "models/caelum/inventory/documents" Model 0 "book.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex CBOO A 0 0 }}' for binding in [item,*item['additional_bindings']])+'\n').encode()
    files={'caelum/data/inventory_books.modeldef':definition}
    report=dict(schema_revision=1,issue=676,parent_issue=647,status=config['status'],variants={'book':record},
                source_sha256={p:digest((SOURCE/p).read_bytes()) for p in ('DESIGN.json','PROVENANCE.json')},
                external_source_sha256=config['source_sha256'],generator_sha256={Path(__file__).name:digest(Path(__file__).read_bytes())},
                sha256={p:digest(b) for p,b in files.items()},reuse_note='Native geometry/material bytes and editable sources remain owned by #656; only a model binding is exported.')
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files
def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale book binding: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            package.writestr(zipfile.ZipInfo('MODELDEF',(2026,11,13,0,0,0)),files['caelum/data/inventory_books.modeldef'])
    print('Exported three book bindings; original geometry and materials unchanged')
if __name__=='__main__':main()
