"""Export four hollow hand armor drops and their owned material references."""
from pathlib import Path
import argparse,hashlib,json,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from .generate_inventory_armor_helmets_models import arc
    from .generate_inventory_consumable_models import geometry as consumable_geometry
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_articulated_weapons_models import geometry as shared_geometry
    from generate_inventory_armor_helmets_models import arc
    from generate_inventory_consumable_models import geometry as consumable_geometry
SOURCE=ROOT/'assets/source/art/inventory_models_647/armor_hands'
def digest(blob):return hashlib.sha256(blob).hexdigest()
def geometry(config,family,tier):
    if family['parts'][0]['kind']=='arc_shell':return arc(family['parts'][0])
    return consumable_geometry(config,family,tier) if family['parts'][0]['kind']=='prism' else shared_geometry(config,family,tier)

def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text());files=shared_output(SOURCE,'inventory_armor_hands.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    report=json.loads(files['manifest.json'])
    for settings in config['materials'].values():
        name=settings['texture'];files['editable/src/'+name]=(ROOT/'src'/name).read_bytes()
    report['sha256']={n:digest(b) for n,b in files.items() if n!='manifest.json'};report['reuse_note']='All reused owned leather, steel and gold textures remain byte-identical; no new raster assets.'
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);p.add_argument('--install',action='store_true');p.add_argument('--check',action='store_true');a=p.parse_args();files=output_files()
    for n,b in files.items():
        paths=[a.output/n]
        if a.install:paths.append(SOURCE/'EXPORT.json' if n=='manifest.json' else SOURCE/n if n.startswith('editable/') else ROOT/'src'/n)
        for path in paths:
            if a.check:
                if not path.is_file() or path.read_bytes()!=b:raise ValueError('Stale hand armor export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b)
    if not a.check:
        with zipfile.ZipFile(a.output/'preview.pk3','w') as z:
            for n,b in sorted(files.items()):
                if n=='manifest.json' or n.startswith('editable/'):continue
                z.writestr(zipfile.ZipInfo('MODELDEF' if n.endswith('.modeldef') else n,(2026,11,15,0,0,0)),b)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))
if __name__=='__main__':main()
