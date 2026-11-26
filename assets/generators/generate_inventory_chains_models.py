"""Export closed oval chain links and the owned spiked-head component design."""
from pathlib import Path
import argparse,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_peuchen_model import ellipsoid,dot,cross
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_peuchen_model import ellipsoid,dot,cross
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/inventory_models_647/chains'


def geometry(config,family,tier):
    part=family['parts'][0];mesh=Mesh();material=part['material'];name=part['part']
    if part['kind']=='ring':
        n=part['segments'];m=part['wire_segments'];a,b=part['radii'];wire=part['wire'];rings=[]
        for i in range(n):
            theta=math.tau*i/n+part['phase'];nx,nz=math.cos(theta)/a,math.sin(theta)/b
            size=math.hypot(nx,nz);nx/=size;nz/=size;row=[]
            for j in range(m):
                phi=math.tau*j/m
                row.append(mesh.vertex((a*math.cos(theta)+wire*math.cos(phi)*nx,wire*math.sin(phi),b*math.sin(theta)+wire*math.cos(phi)*nz),(j/m,i/n),name))
            rings.append(row)
        for i in range(n):
            for j in range(m):mesh.quad((rings[i][j],rings[(i+1)%n][j],rings[(i+1)%n][(j+1)%m],rings[i][(j+1)%m]),material)
    elif part['kind']=='ellipsoid':
        mesh=ellipsoid({'materials':{material:{'uv_rect':[0,0,1,1]}}},part)
    elif part['kind']=='spike':
        n=part['segments'];ring=[]
        for j in range(n):
            theta=math.tau*j/n
            ring.append(mesh.vertex((part['radius']*math.cos(theta),part['radius']*math.sin(theta),0),(j/n,0),name))
        low=mesh.vertex((0,0,0),(.5,0),name);tip=mesh.vertex((0,0,part['height']),(.5,1),name)
        for j in range(n):
            mesh.faces.extend([(material,(low,ring[(j+1)%n],ring[j])),(material,(tip,ring[j],ring[(j+1)%n]))])
    else:raise ValueError('Unsupported chain component '+part['kind'])
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Chain component has no volume')
    return mesh,{name:abs(volume)}


def output_files():
    return shared_output(SOURCE,'inventory_chains.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for p in paths:
            if args.check:
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale chain export: '+str(p))
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
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
