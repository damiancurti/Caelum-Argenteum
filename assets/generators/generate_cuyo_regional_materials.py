"""Install the Cuyo ground study through the shared material exporter."""
from pathlib import Path
import argparse,json,zipfile
try:
    from .generate_regional_materials import output_files as shared_output_files
except ImportError:
    from generate_regional_materials import output_files as shared_output_files
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/regional_gallery_700'
DEFINITION='caelum/data/regional_materials_700.textures'
def output_files():return shared_output_files(SOURCE,DEFINITION,'regions_700',700)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true')
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        destinations=[args.output/name]
        if args.install:destinations.append(SOURCE/'EXPORT.json' if name=='manifest.json' else ROOT/'src'/name)
        for target in destinations:
            if args.check:
                if not target.is_file() or target.read_bytes()!=blob:raise ValueError('Stale regional material: '+str(target))
            else:target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json':continue
                archive.writestr(zipfile.ZipInfo('TEXTURES' if name==DEFINITION else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps({'issue':700,'native_resources':len(files)-1,'check':args.check}))


if __name__=='__main__':main()
