"""Install unchanged owned regional material PNGs and native display definitions."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/regional_gallery_463'
DEFINITION = 'caelum/data/regional_materials.textures'


def digest(blob): return hashlib.sha256(blob).hexdigest()


def output_files():
    config = json.loads((SOURCE / 'INVENTORY.json').read_text())
    files = {}; definitions = []
    for item in config['gaps']:
        name = 'graphics/caelum/textures/regions_463/' + item['image']
        blob = (SOURCE / item['image']).read_bytes()
        if digest(blob) != item['sha256']: raise ValueError('Source image changed: ' + item['image'])
        files[name] = blob
        width, height = item['image_size']; world_x, world_y = item['world_tile_map_units']
        for kind in ['Texture','Flat']:
            definitions += [f'{kind} "{item["texture"]}", {width}, {height}', '{',
                            f'    XScale {width/world_x:.12g}', f'    YScale {height/world_y:.12g}',
                            '    WorldPanning', f'    Patch "{name}", 0, 0', '}', '']
    files[DEFINITION] = ('\n'.join(definitions)).encode()
    sources = {name:digest((SOURCE/name).read_bytes()) for name in ['INVENTORY.json','PROVENANCE.json'] + [item['prompt'] for item in config['gaps']]}
    report = dict(schema_revision=1, issue=463, status='regional_art_candidate', source_sha256=sources,
                  generator_sha256=digest(Path(__file__).read_bytes()),
                  sha256={name:digest(blob) for name,blob in files.items()})
    files['manifest.json'] = (json.dumps(report,indent=2)+'\n').encode()
    return files


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
    print(json.dumps({'issue':463,'native_resources':len(files)-1,'check':args.check}))


if __name__=='__main__':main()
