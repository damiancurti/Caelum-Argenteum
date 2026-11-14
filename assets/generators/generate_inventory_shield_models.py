"""Export closed native shields from original, unchanged owned icon pixels."""
from pathlib import Path
import argparse
import json
import math
import zipfile
from collections import defaultdict
try:
    from .generate_inventory_ammunition_models import ROOT, digest, output_files as shared_output
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_inventory_ammunition_models import ROOT, digest, output_files as shared_output
    from generate_nahuelito_model import Mesh

SOURCE=ROOT/'assets/source/art/inventory_models_647/shields'


def geometry(config,family,tier):
    shape=family['parts'][0];mesh=Mesh();material=shape['material'];part=shape['part']
    def vertex(point,uv):return mesh.vertex(point,uv,part)
    def quad(a,b,c,d):mesh.quad((a,b,c,d),material)
    if shape['kind']=='shield_strap':
        x,y,z=shape['center'];radius=shape['radius'];width=shape['width'];thick=shape['thickness'];rings=[]
        for i in range(shape['segments']+1):
            angle=math.pi*i/shape['segments'];ring=[]
            for dx,r in [(-width/2,radius-thick/2),(width/2,radius-thick/2),(width/2,radius+thick/2),(-width/2,radius+thick/2)]:
                ring.append(vertex((x+dx,y+r*math.sin(angle),z+r*math.cos(angle)),(i/shape['segments'],(dx/width+.5))))
            rings.append(ring)
        for before,after in zip(rings,rings[1:]):
            for j in range(4):quad(before[j],before[(j+1)%4],after[(j+1)%4],after[j])
        quad(*reversed(rings[0]));quad(*rings[-1])
    else:
        center=shape['center'];outline=shape['outline'];count=len(outline)
        def point(index,r,side):
            ox,oz=outline[index];x=center[0]+(ox-center[0])*r;z=center[1]+(oz-center[1])*r
            curve=-shape['bow']*(1-r*r)
            if side==0:
                y=curve+shape['front_offset']
                for bump in shape.get('bumps',[]):
                    distance=sum(((v-c)/radius)**2 for v,c,radius in zip((x,z),bump['center'],bump['radii']))
                    y-=bump['height']*max(0,1-distance)**2
            else:y=shape.get('back_y',curve+shape.get('back_offset',0))
            uv=((x+64)/128,(128-z)/128) if shape.get('project_front') else (index/count,r/shape.get('outer',1))
            if shape.get('planar_uv'):
                minx,minz=(min(p[k] for p in outline) for k in (0,1));maxx,maxz=(max(p[k] for p in outline) for k in (0,1))
                uv=((x-minx)/(maxx-minx),(maxz-z)/(maxz-minz))
            return vertex((x,y,z),uv)
        if shape['kind']=='shield_panel':
            shells=[]
            for side in (0,1):
                origin=point(0,0,side);rings=[]
                for row in range(1,shape['radial_steps']+1):
                    rings.append([point(i,row/shape['radial_steps'],side) for i in range(count)])
                for i in range(count):
                    triangle=(origin,rings[0][i],rings[0][(i+1)%count])
                    mesh.faces.append((material,triangle if side==0 else tuple(reversed(triangle))))
                for before,after in zip(rings,rings[1:]):
                    for i in range(count):
                        j=(i+1)%count;indices=(before[i],after[i],after[j],before[j])
                        mesh.quad(indices if side==0 else tuple(reversed(indices)),material)
                shells.append(rings[-1])
            for i in range(count):
                j=(i+1)%count;quad(shells[0][i],shells[1][i],shells[1][j],shells[0][j])
        elif shape['kind']=='shield_rim':
            rings=[[point(i,r,side) for i in range(count)] for side,r in [(0,shape['inner']),(0,shape['outer']),(1,shape['outer']),(1,shape['inner'])]]
            for k in range(4):
                for i in range(count):
                    j=(i+1)%count;quad(rings[k][i],rings[(k+1)%4][i],rings[(k+1)%4][j],rings[k][j])
        else:raise ValueError('Unknown shield geometry '+shape['kind'])
    edges=defaultdict(int);directions=defaultdict(int);volume=0
    for _,triangle in mesh.faces:
        points=[tuple(round(v,7) for v in mesh.vertices[i]) for i in triangle]
        for a,b in zip(points,points[1:]+points[:1]):
            edge=tuple(sorted((a,b)));edges[edge]+=1;directions[edge]+=1 if a<b else -1
        a,b,c=points;volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if any(v!=2 for v in edges.values()) or any(directions.values()) or abs(volume)<1e-7:
        raise ValueError('Open or inconsistent shield component: '+part)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    return mesh,{part:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_shields.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for native,original in config['texture_sources'].items():files[native]=(ROOT/original).read_bytes()
    report=json.loads(files['manifest.json']);report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        destinations=[args.output/name]
        if args.install:destinations.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in destinations:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale shield export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
        if args.install:
            config=json.loads((SOURCE/'DESIGN.json').read_text())
            for name in config['texture_sources']:
                path=SOURCE/'editable/src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(files[name])
    print(json.dumps({name:item['triangles'] for name,item in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
