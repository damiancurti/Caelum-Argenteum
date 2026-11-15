"""Verify exact orb frames, closed radial relief and native serialized triangles."""
from collections import Counter
import hashlib,json,math,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def inspect_native(root=ROOT):
    source=root/'assets/source/art/inventory_models_647/orbs'
    config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text());errors=[];stats={}
    for kind,item in config['variants'].items():
        points=[];expected=Counter();parts={};group=None
        for line in (source/'editable'/(kind+'.obj')).read_text().splitlines():
            row=line.split()
            if not row:continue
            if row[0]=='v':points.append(tuple(map(float,row[1:])))
            elif row[0]=='g':group=row[1];parts.setdefault(group,[])
            elif row[0]=='f':
                tri=tuple(int(v.split('/')[0])-1 for v in row[1:]);parts[group].append(tri)
                native=tuple(tuple(round(v*64) for v in (points[i][0],-points[i][2],points[i][1])) for i in tri)
                u=[native[1][k]-native[0][k] for k in range(3)];v=[native[2][k]-native[0][k] for k in range(3)]
                if not any([u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]):errors.append('Collapsed quantized triangle '+kind+'/'+group)
                expected[native]+=1
        for group,faces in parts.items():
            edges=Counter();winding=Counter();signed=0
            for f in faces:
                a,b,c=[points[i] for i in f]
                signed+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                for x,y in [(a,b),(b,c),(c,a)]:
                    edge=tuple(sorted((x,y)));edges[edge]+=1;winding[edge]+=1 if x<y else -1
            if signed<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):errors.append('Open/inward orb component '+kind+'/'+group)
        for p in item['parts']:
            faces=parts[p['part']];vertices={points[i] for f in faces for i in f};edges={tuple(sorted((points[f[a]],points[f[b]]))) for f in faces for a,b in [(0,1),(1,2),(2,0)]}
            if len(vertices)-len(edges)+len(faces)!=2-2*p.get('genus',0):errors.append('Unexpected orb topology '+kind+'/'+p['part'])
        blob=(root/'src'/config['model_path']/(kind+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10];actual=Counter()
        for _ in range(head[6]):
            h=struct.unpack_from('<4s64s10I',blob,offset);vertices=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
            for i in range(h[6]):actual[tuple(vertices[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12))]+=1
            offset+=h[-1]
        if actual!=expected:errors.append('Native/editable triangle mismatch '+kind)
        bounds=report['variants'][kind]['native_bounds'][0]
        if abs(bounds['min'][2])>1/64:errors.append('Incorrect grounded origin '+kind)
        stats[kind]=dict(closed_components=len(parts),native_triangles=sum(actual.values()),depth=bounds['max'][1]-bounds['min'][1],orbit_components=sum(p.get('genus',0) for p in item['parts']))
    return errors,stats


def validate(root=ROOT):
    errors=validate_family(root,'orbs',7,False)
    try:
        source=root/'assets/source/art/inventory_models_647/orbs';c=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        expected=[dict(**{'class':kind},item_type=91 if kind=='CaelumMaterialPickup' else 19,tier=t) for kind in ['CaelumWeaponPickup','CA_LimboMagicImplement','CaelumMaterialPickup'] for t in [1,2,3]]
        if c['runtime_cases']!=expected:errors.append('Changed orb runtime identity/tier coverage')
        for name,h in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=h:errors.append('Stale editable orb '+name)
        for n,item in c['variants'].items():
            material=c['materials'][n];original=(root/material['original_source']).read_bytes()
            if (root/'src'/material['texture']).read_bytes()!=original or (source/'editable/src'/material['texture']).read_bytes()!=original:errors.append('Changed owned orb texture')
            r=report['variants'][n];bounds=r['native_bounds'][0];ref=r['reference_opaque_bounds'];size=[bounds['max'][i]-bounds['min'][i] for i in range(3)]
            if size[1]<size[0]*.9:errors.append('Orb lacks spherical depth '+n)
            if size[0]>ref[2]-ref[0]+1/32 or size[2]>ref[3]-ref[1]+1/32:errors.append('Orb exceeds original icon envelope '+n)
            center=-r['source_to_native']['floor']*r['source_to_native']['factor'];radii=[]
            for line in (source/'editable'/(n+'.obj')).read_text().splitlines():
                if line.startswith('v '):
                    x,z,y=map(float,line.split()[1:]);radii.append(math.sqrt(x*x+y*y+(z-center)**2))
            if max(radii)-min(radii)<1:errors.append('Orb lacks actual radial carving '+n)
        more,_=inspect_native(root);errors.extend(more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps(dict(errors=errors,geometry=inspect_native()[1])));raise SystemExit(bool(errors))
