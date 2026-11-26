"""Check serialized wooden components, bow openings and exact native geometry."""
import hashlib,json,struct
from collections import Counter,defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_chainmail_models import sub,dot,cross
    from .validate_inventory_gloves_models import inside,ray_hits
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_chainmail_models import sub,dot,cross
    from validate_inventory_gloves_models import inside,ray_hits


def inspect_geometry(root=ROOT,kind='shaft'):
    source=root/'assets/source/art/inventory_models_647/wood_components'
    config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
    family=config['families'][kind];record=report['variants'][kind]
    points=[];groups=defaultdict(list);group=None;errors=[];expected_native=Counter();solids={}
    for line in (source/('editable/'+kind+'.obj')).read_text().splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='v':points.append(tuple(map(float,row[1:])))
        elif row[0]=='g':group=row[1]
        elif row[0]=='f':groups[group].append(tuple(int(v.split('/')[0])-1 for v in row[1:]))
    if set(groups)!={p['part'] for p in family['parts']}:errors.append('Unexpected editable components')
    for name,faces in groups.items():
        edges=defaultdict(int);winding=defaultdict(int);volume=0;solids[name]=[]
        for tri in faces:
            a,b,c=[points[i] for i in tri];solids[name].append((a,b,c));volume+=dot(a,cross(b,c))/6
            for u,v in [(a,b),(b,c),(c,a)]:
                key=tuple(sorted((u,v)));edges[key]+=1;winding[key]+=1 if u<v else -1
            native=tuple(tuple(round(v*64) for v in (points[i][0],-points[i][2],points[i][1])) for i in tri)
            if not any(cross(sub(native[1],native[0]),sub(native[2],native[0]))):errors.append('Collapsed native triangle '+name)
            expected_native[native]+=1
        if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):errors.append('Open or inward component '+name)
        unique={points[i] for tri in faces for i in tri}
        if len(unique)-len(edges)+len(faces)!=2:errors.append('Unexpected solid topology '+name)
    transform=record['source_to_native'];factor=transform['factor'];floor=transform['floor']
    def converted(p):return p[0]*factor,(p[2]-floor)*factor,-p[1]*factor
    connections=set()
    for attachment in family['attachments']:
        p=converted(attachment['witness'])
        for name in [attachment['part'],attachment['target']]:
            if not inside(p,solids[name]):errors.append('Detached attachment '+attachment['part']+' -> '+name)
        connections.add(tuple(sorted((attachment['part'],attachment['target']))))
    reached={family['root']}
    while True:
        more={p for a,b in connections if a in reached or b in reached for p in (a,b)}
        if more<=reached:break
        reached|=more
    if reached!=set(groups):errors.append('Disconnected assembly')
    triangles=[tri for group in solids.values() for tri in group];opening_rays=0
    for opening in family['openings']:
        x,y,z=opening['point'];radius=opening['clearance'];normal=opening['normal'];direction=(normal[0],normal[2],-normal[1])
        for dx,dy in [(0,0),(radius,0),(-radius,0),(0,radius),(0,-radius)]:
            p=converted((x+dx,y+dy,z))
            for sign in [-1,1]:
                opening_rays+=1
                if ray_hits(p,tuple(sign*v for v in direction),triangles):errors.append('Blocked bow opening')
    blob=(root/'src'/config['model_path']/(kind+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10];actual_native=Counter()
    for _ in range(head[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset);vertices=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
        for i in range(h[6]):actual_native[tuple(vertices[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12))]+=1
        offset+=h[-1]
    if actual_native!=expected_native:errors.append('Native triangles differ from quantized editable geometry')
    bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
    if any(bounds['max'][axis]-bounds['min'][axis]>ref[i+2]-ref[i]+1/32 for axis,i in [(0,0),(2,1)]):errors.append('Model exceeds original sprite envelope')
    if abs(bounds['min'][2])>1/64 or bounds['max'][2]<=1:errors.append('Incorrect floor or missing thickness')
    return errors,dict(closed_components=len(groups),fixed_attachment_witnesses=len(family['attachments']),connected_components=len(reached),opening_probes=len(family['openings']),opening_rays=opening_rays,native_triangles=sum(actual_native.values()))


def validate(root=ROOT):
    errors=validate_family(root,'wood_components',6,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/wood_components';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        ids=[6,7,8,28,29,42]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup',f'M{n:03}',n) for n in ids]:errors.append('Unexpected wood world bindings')
        if config['runtime_cases']!=[dict(item_type=n,tier=t) for n in ids for t in [1,2,3]]:errors.append('Changed wood type/tier cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque wood material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind);errors.extend(kind+': '+e for e in more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k)[1] for k in ['shaft','frame','long_frame','handle','long_handle','wood']}
    print(json.dumps(dict(errors=errors,geometry=stats)));raise SystemExit(bool(errors))
