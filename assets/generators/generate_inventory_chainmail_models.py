"""Export the chainmail material as closed, interlaced editable rings."""
from pathlib import Path
import argparse
import json
import math
import zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/inventory_models_647/chainmail'


def geometry(config,family,tier):
    part=family['parts'][0];mesh=Mesh();rings=[]
    n=part['segments'];m=part['wire_segments'];r=part['radius'];wire=part['wire']
    tilt=math.radians(part['tilt']);cx,cy,cz=part['center']
    for i in range(n):
        a=math.tau*i/n;row=[]
        for j in range(m):
            b=math.tau*j/m
            x=(r+wire*math.cos(b))*math.cos(a)
            z=(r+wire*math.cos(b))*math.sin(a);y=wire*math.sin(b)
            y,z=y*math.cos(tilt)+z*math.sin(tilt),-y*math.sin(tilt)+z*math.cos(tilt)
            row.append(mesh.vertex((cx+x,cy+y,cz+z),(j/m,i/n),part['part']))
        rings.append(row)
    for i in range(n):
        for j in range(m):mesh.quad((rings[i][j],rings[(i+1)%n][j],rings[(i+1)%n][(j+1)%m],rings[i][(j+1)%m]),part['material'])
    volume=0
    for _,tri in mesh.faces:
        a,b,c=[mesh.vertices[i] for i in tri]
        volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if volume<0:mesh.faces=[(mat,tuple(reversed(tri))) for mat,tri in mesh.faces]
    if abs(volume)<1e-7:raise ValueError('Ring has no volume')
    return mesh,{part['part']:abs(volume)}


def output_files():
    return shared_output(SOURCE,'inventory_chainmail.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for p in paths:
            if args.check:
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale chainmail export: '+str(p))
            else:p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    if not args.check:
        config=json.loads((SOURCE/'DESIGN.json').read_text())
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
            for texture in sorted({s['texture'] for s in config['materials'].values()}):
                blob=(ROOT/'src'/texture).read_bytes();package.writestr(zipfile.ZipInfo(texture,(2026,11,14,0,0,0)),blob)
                if args.install:
                    p=SOURCE/'editable/src'/texture;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
    print(json.dumps({k:v['triangles'] for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
