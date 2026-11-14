"""Export six textile drops with folded sheets, fiber clusters and real rope strands."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_chains_models import geometry as rounded_geometry
    from .generate_inventory_consumable_models import geometry as loft_geometry
    from .generate_nahuelito_model import Mesh,dot,cross
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_chains_models import geometry as rounded_geometry
    from generate_inventory_consumable_models import geometry as loft_geometry
    from generate_nahuelito_model import Mesh,dot,cross
SOURCE=ROOT/'assets/source/art/inventory_models_647/textiles'


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='tube':return loft_geometry(config,family,tier)
    if part['kind']!='folded_sheet':return rounded_geometry(config,family,tier)
    mesh=Mesh();rows=[];path=part['path'];name=part['part'];material=part['material']
    for i,(y,z) in enumerate(path):
        before=path[max(0,i-1)];after=path[min(len(path)-1,i+1)];dy=after[0]-before[0];dz=after[1]-before[1];length=math.hypot(dy,dz);ny,nz=-dz/length,dy/length
        row=[]
        for x,side in [(-1,-1),(1,-1),(1,1),(-1,1)]:
            row.append(mesh.vertex((x*part['width']/2,y+ny*side*part['thickness']/2,z+nz*side*part['thickness']/2),((x+1)/2,i/(len(path)-1)),name))
        rows.append(row)
    for a,b in zip(rows,rows[1:]):
        for j in range(4):mesh.quad((a[j],a[(j+1)%4],b[(j+1)%4],b[j]),material)
    mesh.quad(tuple(reversed(rows[0])),material);mesh.quad(tuple(rows[-1]),material)
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Folded sheet has no volume')
    return mesh,{name:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_textiles.modeldef',('DESIGN.json','PROVENANCE.json','MATERIALS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/textiles/materials.png';files[name]=(SOURCE/'materials.png').read_bytes()
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
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale textile export: '+str(p))
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
