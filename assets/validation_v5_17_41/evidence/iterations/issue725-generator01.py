"""Export nine owned assembly components with closed grips, coils, loops and openings."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_weapon_components_models import geometry as component_geometry
    from .generate_inventory_consumable_models import geometry as loft_geometry
    from .generate_nahuelito_model import Mesh,dot,cross
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_weapon_components_models import geometry as component_geometry
    from generate_inventory_consumable_models import geometry as loft_geometry
    from generate_nahuelito_model import Mesh,dot,cross
SOURCE=ROOT/'assets/source/art/inventory_models_647/assembly_components'


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='tube':return loft_geometry(config,family,tier)
    if part['kind']!='band':return component_geometry(config,family,tier)
    mesh=Mesh();name=part['part'];material=part['material'];n=part['segments']
    closed=part['genus']==1;rows=[]
    for i in range(n if closed else n+1):
        angle=part['start']+(part['end']-part['start'])*i/n;row=[]
        for j,(radii,z) in enumerate([(part['radii'],part['z'][0]),(part['radii'],part['z'][1]),(part['inner'],part['z'][1]),(part['inner'],part['z'][0])]):
            row.append(mesh.vertex((radii[0]*math.cos(angle),radii[1]*math.sin(angle),z),(i/n,j/3),name))
        rows.append(row)
    for i in range(n):
        following=(i+1)%len(rows)
        for j in range(4):mesh.quad((rows[i][j],rows[following][j],rows[following][(j+1)%4],rows[i][(j+1)%4]),material)
    if not closed:
        mesh.faces.extend([(material,(rows[0][0],rows[0][1],rows[0][2])),(material,(rows[0][0],rows[0][2],rows[0][3])),(material,(rows[-1][2],rows[-1][1],rows[-1][0])),(material,(rows[-1][3],rows[-1][2],rows[-1][0]))])
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Assembly component has no volume')
    return mesh,{name:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_assembly_components.modeldef',('DESIGN.json','PROVENANCE.json','FIBERS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/assembly_components/fibers.png';files[name]=(SOURCE/'fibers.png').read_bytes()
    report=json.loads(files['manifest.json']);report['sha256'][name]=hashlib.sha256(files[name]).hexdigest()
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for p in paths:
            if args.check:
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale assembly component export: '+str(p))
            else:p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    if not args.check:
        config=json.loads((SOURCE/'DESIGN.json').read_text())
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
            for texture in sorted({s['texture'] for s in config['materials'].values()}):
                blob=(ROOT/'src'/texture).read_bytes()
                if texture not in files:package.writestr(zipfile.ZipInfo(texture,(2026,11,14,0,0,0)),blob)
                if args.install:
                    p=SOURCE/'editable/src'/texture;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
