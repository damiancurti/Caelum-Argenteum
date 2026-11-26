"""Export owned metal weapon components with bevels, spikes and hollow sockets."""
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
SOURCE=ROOT/'assets/source/art/inventory_models_647/weapon_components'


def caps(outline):
    """Triangulate a simple counterclockwise concave polygon without a fan."""
    def area(a,b,c):return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
    remaining=list(range(len(outline)));triangles=[]
    while len(remaining)>3:
        for k,b in enumerate(remaining):
            a,c=remaining[k-1],remaining[(k+1)%len(remaining)]
            if area(outline[a],outline[b],outline[c])<=1e-9:continue
            if any(all(area(outline[u],outline[v],outline[p])>=-1e-9 for u,v in [(a,b),(b,c),(c,a)]) for p in remaining if p not in [a,b,c]):continue
            triangles.append((a,b,c));remaining.pop(k);break
        else:raise ValueError('Invalid bevel outline')
    triangles.append(tuple(remaining));return triangles


def geometry(config,family,tier):
    part=family['parts'][0];kind=part['kind']
    if kind in ['ellipsoid','spike']:return rounded_geometry(config,family,tier)
    if kind=='loft':return loft_geometry(config,family,tier)
    mesh=Mesh();name=part['part'];material=part['material']
    if kind=='socket':
        profile=part['profile'];n=part['segments'];cache={};low=min(p[0] for p in profile);high=max(p[0] for p in profile)
        def vertex(i,j,region):
            key=(i,j,region)
            if key not in cache:
                z,radius=profile[i];u,v=j/n,(z-low)/(high-low);a,b,c,d=part['uv_regions'][region];left,top,right,bottom=part['uv_bounds']
                uv=((a+(c-a)*u-left)/(right-left),(b+(d-b)*v-top)/(bottom-top))
                cache[key]=mesh.vertex((radius*math.cos(math.tau*(j%n)/n),radius*math.sin(math.tau*(j%n)/n),z),uv,name)
            return cache[key]
        for i in range(len(profile)):
            region='inner' if i in part['inner_spans'] else 'outer';following=(i+1)%len(profile)
            for j in range(n):mesh.quad((vertex(i,j,region),vertex(i,j+1,region),vertex(following,j+1,region),vertex(following,j,region)),material)
    elif kind=='blade':
        rings=[]
        for i,(z,x,w,d) in enumerate(part['rows']):
            cross_section=[(-1,.06),(-.55,.5),(.55,.5),(1,.06),(1,-.06),(.55,-.5),(-.55,-.5),(-1,-.06)]
            rings.append([mesh.vertex((x+u*w,v*d,z),((u+1)/2,i/len(part['rows'])),name) for u,v in cross_section])
        for i in range(len(rings)-1):
            for j in range(8):mesh.quad((rings[i][j],rings[i][(j+1)%8],rings[i+1][(j+1)%8],rings[i+1][j]),material)
        z,x,_,_=part['rows'][0];base=mesh.vertex((x,0,z),(.5,0),name)
        tip=mesh.vertex(tuple(part['tip']),(.5,1),name)
        for j in range(8):mesh.faces.extend([(material,(base,rings[0][(j+1)%8],rings[0][j])),(material,(tip,rings[-1][j],rings[-1][(j+1)%8]))])
    elif kind=='bevel':
        outline=part['outline'];center=part['bevel_center'];scale=part['inner_scale']
        if sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(outline,outline[1:]+outline[:1]))<0:outline=list(reversed(outline))
        inner=[(center[0]+(x-center[0])*scale,center[1]+(z-center[1])*scale) for x,z in outline]
        rings=[];low=[min(p[i] for p in outline) for i in [0,1]];high=[max(p[i] for p in outline) for i in [0,1]]
        for points,y in [(inner,-part['depth']/2),(outline,-part['edge_depth']/2),(outline,part['edge_depth']/2),(inner,part['depth']/2)]:
            rings.append([mesh.vertex((x,y,z),((x-low[0])/(high[0]-low[0]),(z-low[1])/(high[1]-low[1])),name) for x,z in points])
        for i in range(3):
            for j in range(len(outline)):mesh.quad((rings[i][j],rings[i+1][j],rings[i+1][(j+1)%len(outline)],rings[i][(j+1)%len(outline)]),material)
        for tri in caps(inner):mesh.faces.extend([(material,tuple(rings[0][i] for i in tri)),(material,tuple(rings[-1][i] for i in reversed(tri)))])
    else:raise ValueError('Unsupported weapon component '+kind)
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Weapon component has no volume')
    return mesh,{name:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_weapon_components.modeldef',('DESIGN.json','PROVENANCE.json','METALS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/weapon_components/metals.png';files[name]=(SOURCE/'metals.png').read_bytes()
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
                if not p.is_file() or p.read_bytes()!=blob:raise ValueError('Stale weapon component export: '+str(p))
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
