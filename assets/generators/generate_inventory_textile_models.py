"""Export six textile drops with folded sheets, fiber clusters and real rope strands."""
from pathlib import Path
import argparse,hashlib,json,math,zipfile
try:
    from .generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from .generate_inventory_chains_models import geometry as rounded_geometry
    from .generate_inventory_consumable_models import geometry as loft_geometry
    from .generate_inventory_weapon_components_models import caps
    from .generate_nahuelito_model import Mesh,dot,cross
except ImportError:
    from generate_inventory_ammunition_models import ROOT,output_files as shared_output
    from generate_inventory_chains_models import geometry as rounded_geometry
    from generate_inventory_consumable_models import geometry as loft_geometry
    from generate_inventory_weapon_components_models import caps
    from generate_nahuelito_model import Mesh,dot,cross
SOURCE=ROOT/'assets/source/art/inventory_models_647/textiles'


def geometry(config,family,tier):
    part=family['parts'][0]
    if part['kind']=='tube':return loft_geometry(config,family,tier)
    if part['kind']!='folded_sheet':return rounded_geometry(config,family,tier)
    mesh=Mesh();rows=[];path=[(*part['path'][0],0.)];name=part['part'];material=part['material'];distance=0.;repeat=part['uv_repeat_length']
    for a,b in zip(part['path'],part['path'][1:]):
        span=math.dist(a,b);steps=max(1,math.ceil(span/part['path_step']));cuts=[span*i/steps for i in range(1,steps+1)]
        cuts.extend(k*repeat-distance for k in range(math.floor(distance/repeat)+1,math.ceil((distance+span)/repeat)) if 1e-8<k*repeat-distance<span-1e-8)
        for cut in sorted(set(cuts)):path.append((a[0]+(b[0]-a[0])*cut/span,a[1]+(b[1]-a[1])*cut/span,distance+cut))
        distance+=span
    profile=[(-1+2*j/part['cross_segments'],-1) for j in range(part['cross_segments']+1)]
    profile += [(1-2*j/part['cross_segments'],1) for j in range(part['cross_segments']+1)]
    for i,(y,z,arc) in enumerate(path):
        before=path[max(0,i-1)];after=path[min(len(path)-1,i+1)];dy=after[0]-before[0];dz=after[1]-before[1];length=math.hypot(dy,dz);ny,nz=-dz/length,dy/length
        width=part['width']+part['width_wave']*math.sin(arc*.1);row=[]
        for x,side in profile:
            bend=part['billow']*math.sin((x+1)*math.pi/2)*math.sin(arc*.16)
            row.append((x*width/2,y+ny*side*part['thickness']/2,z+nz*side*part['thickness']/2+bend))
        rows.append(row)
    def face(points,uvs):
        indices=[mesh.vertex(p,uv,name) for p,uv in zip(points,uvs)];mesh.quad(tuple(indices),material)
    for i,(a,b) in enumerate(zip(rows,rows[1:])):
        tile=math.floor(path[i][2]/repeat+1e-8);v0=max(0,min(1,path[i][2]/repeat-tile));v1=max(0,min(1,path[i+1][2]/repeat-tile))
        for j in range(len(profile)):
            k=(j+1)%len(profile);u0=(profile[j][0]+1)/2;u1=(profile[k][0]+1)/2
            if profile[j][1]!=profile[k][1]:u0,u1=0,1
            face([a[j],a[k],b[k],b[j]],[(u0,v0),(u1,v0),(u1,v1),(u0,v1)])
    for index,reverse in [(0,True),(-1,False)]:
        points=rows[index];outline=[(p[0],p[2]) for p in points]
        area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(outline,outline[1:]+outline[:1]))
        triangles=caps(outline) if area>0 else [tuple(reversed(tuple(len(points)-1-j for j in tri))) for tri in caps(list(reversed(outline)))]
        for tri in triangles:
            if reverse:tri=tuple(reversed(tri))
            mesh.faces.append((material,tuple(mesh.vertex(points[j],((profile[j][0]+1)/2,(profile[j][1]+1)/2),name) for j in tri)))
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
