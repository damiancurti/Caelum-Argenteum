"""Independently check closed chain solids, linking, clearance and native meshes."""
import hashlib,json,math,struct
from collections import Counter,defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_chainmail_models import sub,dot,cross,mean,length,segment_distance,link_number
    from .validate_inventory_gloves_models import inside
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_chainmail_models import sub,dot,cross,mean,length,segment_distance,link_number
    from validate_inventory_gloves_models import inside


def inspect_geometry(root=ROOT,kind='chain'):
    source=root/'assets/source/art/inventory_models_647/chains';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
    family=config['families'][kind];record=report['variants'][kind];points=[];groups=defaultdict(list);group=None;errors=[]
    for line in (source/('editable/'+kind+'.obj')).read_text().splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='v':points.append(tuple(map(float,row[1:])))
        elif row[0]=='g':group=row[1]
        elif row[0]=='f':groups[group].append(tuple(int(v.split('/')[0])-1 for v in row[1:]))
    declared={p['part']:p for p in family['parts']};native_triangles=Counter();loops={};radii={};bounds={};solids={}
    if set(groups)!=set(declared):errors.append('Unexpected editable components')
    for name,faces in groups.items():
        edges=defaultdict(int);winding=defaultdict(int);volume=0;indices=sorted({i for tri in faces for i in tri});solids[name]=[]
        for tri in faces:
            a,b,c=[points[i] for i in tri];solids[name].append((a,b,c));volume+=dot(a,cross(b,c))/6
            for u,v in [(a,b),(b,c),(c,a)]:
                key=tuple(sorted((u,v)));edges[key]+=1;winding[key]+=1 if u<v else -1
            native=tuple(tuple(round(v*64) for v in (points[i][0],-points[i][2],points[i][1])) for i in tri)
            if not any(cross(sub(native[1],native[0]),sub(native[2],native[0]))):errors.append('Collapsed native triangle '+name)
            native_triangles[native]+=1
        if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):errors.append('Open or inward component '+name)
        shape=declared[name]
        if shape['kind']!='ring':continue
        unique={points[i] for i in indices}
        if len(unique)-len(edges)+len(faces)!=0:errors.append('Ring is not genus one '+name)
        n,m=shape['segments'],shape['wire_segments']
        if len(indices)!=n*m:errors.append('Unexpected ring tessellation '+name);continue
        rows=[[points[i] for i in indices[j*m:(j+1)*m]] for j in range(n)];loop=[mean(row) for row in rows];loops[name]=loop
        radii[name]=max(length(sub(p,center)) for row,center in zip(rows,loop) for p in row)
        center=mean(loop);radius=max(length(sub(p,center)) for p in loop);bounds[name]=(center,radius+radii[name])
        if min(length(sub(p,center)) for p in loop)<=radii[name]:errors.append('Closed ring opening '+name)
    margin=math.sqrt(3)/64+2e-6;actual=set();minimum=float('inf');checked=0;names=list(loops)
    for i,a in enumerate(names):
        for b in names[i+1:]:
            ca,ra=bounds[a];cb,rb=bounds[b]
            if length(sub(ca,cb))>ra+rb+margin:continue
            checked+=1
            distance=min(segment_distance(p,q,r,s) for p,q in zip(loops[a],loops[a][1:]+loops[a][:1]) for r,s in zip(loops[b],loops[b][1:]+loops[b][:1]))
            clearance=distance-radii[a]-radii[b];minimum=min(minimum,clearance)
            if clearance<=margin:errors.append('Ring surfaces lack native clearance '+a+'/'+b)
            linked=link_number(loops[a],loops[b]);reverse=link_number(loops[b],loops[a])
            if linked!=reverse or abs(linked)>1:errors.append('Invalid oriented linking number '+a+'/'+b)
            if linked:actual.add(tuple(sorted((a,b))))
    expected={tuple(sorted(link)) for link in family['links']}
    if actual!=expected:errors.append('Interlaced links differ: missing='+str(sorted(expected-actual))+' extra='+str(sorted(actual-expected)))
    transform=record['source_to_native'];factor=transform['factor'];floor=transform['floor'];connections=set(actual)
    for attachment in family['attachments']:
        x,y,z=attachment['witness'];p=(x*factor,(z-floor)*factor,-y*factor)
        for name in [attachment['part'],attachment['target']]:
            if not inside(p,solids[name]):errors.append('Detached solid attachment '+attachment['part']+' -> '+name)
        connections.add(tuple(sorted((attachment['part'],attachment['target']))))
    reached={family['root']}
    while True:
        more={p for a,b in connections if a in reached or b in reached for p in (a,b)}
        if more<=reached:break
        reached|=more
    if reached!=set(groups):errors.append('Disconnected assembly')
    blob=(root/'src'/config['model_path']/(kind+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10];actual_native=Counter()
    for _ in range(head[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset);vertices=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
        for i in range(h[6]):actual_native[tuple(vertices[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12))]+=1
        offset+=h[-1]
    if actual_native!=native_triangles:errors.append('Native triangles differ from quantized editable geometry')
    native_bounds=record['native_bounds'][0];reference=record['reference_opaque_bounds']
    if any(native_bounds['max'][axis]-native_bounds['min'][axis]>reference[i+2]-reference[i]+1/32 for axis,i in [(0,0),(2,1)]):errors.append('Model exceeds original sprite envelope')
    return errors,dict(closed_components=len(groups),rings=len(loops),linked_pairs=len(actual),fixed_attachment_witnesses=len(family['attachments']),connected_components=len(reached),nearby_ring_pairs=checked,minimum_capsule_clearance=minimum,quantization_margin=margin,native_triangles=sum(actual_native.values()))


def validate(root=ROOT):
    errors=validate_family(root,'chains',2,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/chains';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup','M041',41),('CaelumMaterialPickup','M043',43)]:errors.append('Unexpected chain world bindings')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque chain material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind);errors.extend(kind+': '+e for e in more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k)[1] for k in ['chain','silver_chain']};print(json.dumps(dict(errors=errors,geometry=stats)));raise SystemExit(bool(errors))
