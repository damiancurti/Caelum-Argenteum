"""Independently verify serialized chainmail links, clearance and native geometry."""
import hashlib
import json
import math
import struct
from collections import Counter,defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def mean(points):return tuple(sum(p[k] for p in points)/len(points) for k in range(3))
def length(a):return math.sqrt(dot(a,a))


def point_segment(p,a,b):
    direction=sub(b,a);t=max(0,min(1,dot(sub(p,a),direction)/dot(direction,direction)))
    return length(sub(p,tuple(x+t*d for x,d in zip(a,direction))))


def segment_distance(p,q,r,s):
    # Interior line minimum plus all four boundary minima: exact for segments.
    u,v,w=sub(q,p),sub(s,r),sub(p,r)
    a,b,c,d,e=dot(u,u),dot(u,v),dot(v,v),dot(u,w),dot(v,w)
    denominator=a*c-b*b
    result=min(point_segment(p,r,s),point_segment(q,r,s),point_segment(r,p,q),point_segment(s,p,q))
    if denominator>1e-16:
        t=(b*e-c*d)/denominator;f=(a*e-b*d)/denominator
        if 0<=t<=1 and 0<=f<=1:result=min(result,length(tuple(w[k]+t*u[k]-f*v[k] for k in range(3))))
    return result


def link_number(a,b):
    # Intersections of B with A's oriented convex polygon disk. The boundary
    # loops come from serialized OBJ vertex rings, not declared link metadata.
    center=mean(a);normal=cross(sub(a[1],a[0]),sub(a[2],a[1]));size=length(normal)
    normal=tuple(v/size for v in normal);total=0
    for p,q in zip(b,b[1:]+b[:1]):
        da,db=dot(sub(p,center),normal),dot(sub(q,center),normal)
        if da*db>=0:continue
        t=da/(da-db);point=tuple(x+t*(y-x) for x,y in zip(p,q))
        if all(dot(cross(sub(v,u),sub(point,u)),normal)>=-1e-6 for u,v in zip(a,a[1:]+a[:1])):
            total+=1 if db>da else -1
    return total


def inspect_geometry(root=ROOT):
    errors=[];source=root/'assets/source/art/inventory_models_647/chainmail'
    config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
    item=config['variants']['chainmail'];record=report['variants']['chainmail'];family=config['families']['chainmail']
    points=[];parts=defaultdict(list);group=None
    for line in (source/'editable/chainmail.obj').read_text().splitlines():
        values=line.split()
        if not values:continue
        if values[0]=='v':points.append(tuple(map(float,values[1:])))
        elif values[0]=='g':group=values[1]
        elif values[0]=='f':parts[group].append(tuple(int(v.split('/')[0])-1 for v in values[1:]))
    declared={p['part']:p for p in family['parts']}
    if set(parts)!=set(declared) or len(parts)!=55:errors.append('Expected 55 independently editable ring components')
    loops={};radii={};bounds={};native_triangles=Counter()
    for name,faces in parts.items():
        edges=defaultdict(int);directions=defaultdict(int);volume=0;indices=sorted({i for tri in faces for i in tri})
        for tri in faces:
            a,b,c=[points[i] for i in tri];volume+=dot(a,cross(b,c))/6
            for i,j in zip(tri,tri[1:]+tri[:1]):
                edge=tuple(sorted((i,j)));edges[edge]+=1;directions[edge]+=1 if i<j else -1
            native=tuple(tuple(round(v*64) for v in (points[i][0],-points[i][2],points[i][1])) for i in tri)
            if not any(cross(sub(native[1],native[0]),sub(native[2],native[0]))):errors.append('Quantization collapses ring triangle '+name)
            native_triangles[native]+=1
        if volume<=0 or any(v!=2 for v in edges.values()) or any(directions.values()):errors.append('Open/inward ring '+name)
        if len(indices)-len(edges)+len(faces)!=0:errors.append('Ring is not a closed genus-one surface '+name)
        shape=declared[name];n,m=shape['segments'],shape['wire_segments']
        if len(indices)!=n*m:errors.append('Unexpected serialized ring tessellation '+name);continue
        rings=[[points[i] for i in indices[j*m:(j+1)*m]] for j in range(n)]
        loop=[mean(row) for row in rings];loops[name]=loop
        radii[name]=max(length(sub(p,center)) for row,center in zip(rings,loop) for p in row)
        center=mean(loop);radius=max(length(sub(p,center)) for p in loop);bounds[name]=(center,radius+radii[name])
        if min(length(sub(p,center)) for p in loop)<=radii[name]:errors.append('Closed ring opening '+name)
    names=list(loops);actual=set();minimum=float('inf');checked=0
    # Every mesh triangle lies within its centerline segment's wire-radius
    # capsule. A positive capsule separation proves the surfaces cannot cross.
    quantization_margin=math.sqrt(3)/64+2e-6
    for index,a in enumerate(names):
        for b in names[index+1:]:
            ca,ra=bounds[a];cb,rb=bounds[b]
            if length(sub(ca,cb))>ra+rb+quantization_margin:continue
            checked+=1
            distance=min(segment_distance(p,q,r,s) for p,q in zip(loops[a],loops[a][1:]+loops[a][:1]) for r,s in zip(loops[b],loops[b][1:]+loops[b][:1]))
            clearance=distance-radii[a]-radii[b];minimum=min(minimum,clearance)
            if clearance<=quantization_margin:errors.append('Ring surfaces intersect or lack native quantization clearance: '+a+'/'+b)
            linked=link_number(loops[a],loops[b]);reverse=link_number(loops[b],loops[a])
            if linked!=reverse or abs(linked)>1:errors.append('Invalid oriented linking count: '+a+'/'+b)
            if linked:actual.add(tuple(sorted((a,b))))
    expected={tuple(sorted(link)) for link in family['links']}
    if actual!=expected or len(actual)!=90:errors.append('Serialized chainmail does not have the expected 90 interlaced links')
    reached={names[0]}
    while True:
        more={p for a,b in actual if a in reached or b in reached for p in (a,b)}
        if more<=reached:break
        reached|=more
    if len(reached)!=len(names):errors.append('Detached chainmail ring component')
    blob=(root/'src'/config['model_path']/'chainmail.md3').read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10];actual_native=Counter()
    for _ in range(head[6]):
        fields=struct.unpack_from('<4s64s10I',blob,offset)
        vertices=[struct.unpack_from('<3h',blob,offset+fields[10]+i*8) for i in range(fields[5])]
        for i in range(fields[6]):actual_native[tuple(vertices[k] for k in struct.unpack_from('<3I',blob,offset+fields[7]+i*12))]+=1
        offset+=fields[-1]
    if actual_native!=native_triangles:errors.append('Native triangles differ from the independently checked quantized editable mesh')
    bounds=record['native_bounds'][0];reference=record['reference_opaque_bounds']
    if any(bounds['max'][axis]-bounds['min'][axis]>reference[i+2]-reference[i]+1/32 for axis,i in ((0,0),(2,1))):errors.append('Chainmail exceeds the original sprite envelope')
    return errors,dict(rings=len(parts),linked_pairs=len(actual),connected_rings=len(reached),nearby_pairs_checked=checked,minimum_capsule_clearance=minimum,quantization_margin=quantization_margin,native_triangles=sum(actual_native.values()))


def validate(root=ROOT):
    errors=validate_family(root,'chainmail',1)
    try:
        source=root/'assets/source/art/inventory_models_647/chainmail'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup','M017',17)]:errors.append('Unexpected chainmail native binding')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale chainmail portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable iron texture')
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Chainmail material is not fully opaque')
        problems,_=inspect_geometry(root);errors.extend(problems)
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();_,stats=inspect_geometry();print(json.dumps({'errors':errors,'geometry':stats}));raise SystemExit(bool(errors))
