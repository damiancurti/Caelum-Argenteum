"""Export six closed magical crafting bases with real cavities and perforations."""
from pathlib import Path
import argparse, hashlib, json, math, zipfile
try:
    from .generate_inventory_ammunition_models import ROOT, output_files as shared_output
    from .generate_inventory_hygiene_models import geometry as solid_geometry
    from .generate_inventory_chains_models import geometry as rounded_geometry
    from .generate_inventory_consumable_models import tube, loft
    from .generate_nahuelito_model import Mesh, dot, cross, sub
    from .generate_pombero_model import orient
except ImportError:
    from generate_inventory_ammunition_models import ROOT, output_files as shared_output
    from generate_inventory_hygiene_models import geometry as solid_geometry
    from generate_inventory_chains_models import geometry as rounded_geometry
    from generate_inventory_consumable_models import tube, loft
    from generate_nahuelito_model import Mesh, dot, cross, sub
    from generate_pombero_model import orient

SOURCE=ROOT/'assets/source/art/inventory_models_647/magic_bases'


def perforated_shell(part):
    """Join curved panels around lobed apertures, including their inner walls."""
    mesh=Mesh(); n=part['columns']; steps=part['boundary_steps']; rows=part['rows']
    material=part['material']; name=part['part']; thickness=part['thickness']
    holes={tuple(p) for p in part['holes']}
    def radius(z):
        for (za,ra),(zb,rb) in zip(rows,rows[1:]):
            if za-1e-8<=z<=zb+1e-8:return ra+(rb-ra)*(z-za)/(zb-za)
        raise ValueError('Shell coordinate outside profile')
    def point(a,z,inner):
        r=radius(z)-thickness*inner
        return tuple(round(v,9) for v in (r*math.cos(a),r*math.sin(a),z))
    def vertex(a,z,inner):
        u,v=a/math.tau,(z-rows[0][0])/(rows[-1][0]-rows[0][0])
        if 'surface_regions' in part:
            left,top,right,bottom=part['surface_regions']['inner' if inner else 'outer']
            u,v=left+(right-left)*u,top+(bottom-top)*v
        return mesh.vertex(point(a,z,inner),(u,v),name)
    def face(indices,direction):
        for tri in ((indices[0],indices[1],indices[2]),(indices[0],indices[2],indices[3])):
            mesh.faces.append((material,orient(mesh,tri,direction)))
    for band in range(len(rows)-1):
        za,zb=rows[band][0],rows[band+1][0];zc=(za+zb)/2;hz=(zb-za)/2
        for column in range(n):
            ac=math.tau*(column+.5)/n;ha=math.pi/n; boundary=[]; aperture=[]
            for k in range(steps):
                phi=math.pi/4+math.tau*k/steps;u,v=math.cos(phi),math.sin(phi)
                scale=max(abs(u),abs(v));boundary.append((ac+ha*u/scale,zc+hz*v/scale))
                r=part['hole_scale']*(1+part['hole_lobes']*math.cos(4*phi))
                aperture.append((ac+ha*r*u,zc+hz*r*v))
            hole=(band,column) in holes
            rings=[]
            for inner in (0,1):
                outside=[vertex(a,z,inner) for a,z in boundary]
                inside=[vertex(a,z,inner) for a,z in aperture] if hole else [vertex(ac,zc,inner)]*steps
                rings.append((outside,inside));direction=((1-2*inner)*math.cos(ac),(1-2*inner)*math.sin(ac),0)
                for k in range(steps):
                    j=(k+1)%steps
                    if hole:face((outside[k],outside[j],inside[j],inside[k]),direction)
                    else:mesh.faces.append((material,orient(mesh,(outside[k],outside[j],inside[k]),direction)))
            if hole:
                center=point(ac,zc,.5)
                for k in range(steps):
                    j=(k+1)%steps;mid=point(*aperture[k],.5)
                    face((rings[0][1][k],rings[0][1][j],rings[1][1][j],rings[1][1][k]),sub(center,mid))
            for k in range(steps):
                j=(k+1)%steps
                if all(abs(boundary[t][1]-rows[0][0])<1e-8 for t in (k,j)):
                    face((rings[0][0][k],rings[0][0][j],rings[1][0][j],rings[1][0][k]),(0,0,-1))
                if all(abs(boundary[t][1]-rows[-1][0])<1e-8 for t in (k,j)):
                    face((rings[0][0][k],rings[0][0][j],rings[1][0][j],rings[1][0][k]),(0,0,1))
    return mesh


def geometry(config,family,tier):
    part=family['parts'][0];kind=part['kind']
    if kind=='perforated_shell':mesh=perforated_shell(part)
    elif kind=='tube':mesh=Mesh();tube(mesh,part)
    elif kind=='loft':mesh=Mesh();loft(mesh,part)
    elif kind=='ring':mesh,_=rounded_geometry(config,family,tier)
    else:mesh,_=solid_geometry(config,family,tier)
    if part.get('planar_caps'):
        centers={len(part['rows'])*(part['segments']+1),len(part['rows'])*(part['segments']+1)+1};copies={};faces=[]
        low=[min(p[a] for p in mesh.vertices) for a in (0,1)];high=[max(p[a] for p in mesh.vertices) for a in (0,1)]
        for material,tri in mesh.faces:
            if centers.intersection(tri):
                indices=[]
                for index in tri:
                    if index not in copies:
                        x,y,z=mesh.vertices[index];copies[index]=mesh.vertex((x,y,z),((x-low[0])/(high[0]-low[0]),(y-low[1])/(high[1]-low[1])),part['part'])
                    indices.append(copies[index])
                tri=tuple(indices)
            faces.append((material,tri))
        mesh.faces=faces
    if kind=='loft' and 'surface_regions' in part:
        low=min(p[2] for p in mesh.vertices);high=max(p[2] for p in mesh.vertices);regions=part['surface_regions'];stride=part['segments']+1
        for index,((x,y,z),(u,v)) in enumerate(zip(mesh.vertices,mesh.uv)):
            row=index//stride if index<len(part['rows'])*stride else 0 if index==len(part['rows'])*stride else len(part['rows'])-1
            left,top,right,bottom=regions['inner' if row>=part['inner_start_row'] else 'outer']
            mesh.uv[index]=(left+(right-left)*u,top+(bottom-top)*(z-low)/(high-low))
    if 'surface_regions' in part:
        # Duplicate only the lip vertices that cross atlas cells. Every triangle
        # stays within one tile, including the thickness around each aperture.
        inner=part['surface_regions']['inner'];outer=part['surface_regions']['outer'];copies={};faces=[]
        def is_inner(index):
            u,v=mesh.uv[index];return inner[0]-1e-9<=u<=inner[2]+1e-9 and inner[1]-1e-9<=v<=inner[3]+1e-9
        for material,tri in mesh.faces:
            if any(is_inner(i) for i in tri) and not all(is_inner(i) for i in tri):
                indices=[]
                for index in tri:
                    if is_inner(index):
                        if index not in copies:
                            u,v=mesh.uv[index];uv=(outer[0]+(outer[2]-outer[0])*(u-inner[0])/(inner[2]-inner[0]),outer[1]+(outer[3]-outer[1])*(v-inner[1])/(inner[3]-inner[1]))
                            copies[index]=mesh.vertex(mesh.vertices[index],uv,part['part'])
                        index=copies[index]
                    indices.append(index)
                tri=tuple(indices)
            faces.append((material,tri))
        mesh.faces=faces
    if 'folds' in part:
        folds=part['folds'];points=[]
        for x,y,z in mesh.vertices:
            angle=math.atan2(y,x);weight=1+folds['amplitude']*math.cos(folds['count']*angle+folds['phase'])
            points.append((x*weight,y*weight,z))
        mesh.vertices=points
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    if abs(volume)<1e-9:raise ValueError('Magic base part has no volume')
    return mesh,{part['part']:abs(volume)}


def output_files():
    files=shared_output(SOURCE,'inventory_magic_bases.modeldef',('DESIGN.json','PROVENANCE.json','MATERIALS_PROMPT.json'),Path(__file__).name,geometry)
    name='models/caelum/inventory/magic_bases/materials.png';files[name]=(SOURCE/'materials.png').read_bytes()
    report=json.loads(files['manifest.json']);report['sha256'][name]=hashlib.sha256(files[name]).hexdigest()
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale magic base export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,15,0,0,0)),blob)
        if args.install:
            texture='models/caelum/inventory/magic_bases/materials.png';path=SOURCE/'editable/src'/texture
            path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(files[texture])
    print(json.dumps({k:dict(vertices=v['vertices'],triangles=v['triangles']) for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
