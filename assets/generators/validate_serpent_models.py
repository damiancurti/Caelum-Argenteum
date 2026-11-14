"""Independently inspect continuous serpent solids and all quantized poses."""
import json,struct
from collections import Counter,defaultdict
try:
    from .generate_serpent_models import ROOT,geometry
    from .validate_beast_men_models import validate as shared_validate
    from .validate_inventory_chainmail_models import sub,dot,cross
    from .validate_inventory_gloves_models import inside
except ImportError:
    from generate_serpent_models import ROOT,geometry
    from validate_beast_men_models import validate as shared_validate
    from validate_inventory_chainmail_models import sub,dot,cross
    from validate_inventory_gloves_models import inside


def inspect(root=ROOT,kind='monai',source_relative='assets/source/art/serpents_720',model_relative='models/caelum/folklore/serpents'):
    source=root/source_relative;design=json.loads((source/(kind+'.json')).read_text());report=json.loads((source/'EXPORT.json').read_text())
    record=report['species'][kind];points=[];groups=defaultdict(list);group=None;errors=[];expected=Counter();owners=defaultdict(list)
    for line in (source/('editable/'+kind+'.obj')).read_text().splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='v':x,z,y=map(float,row[1:]);points.append((x,-y,z))
        elif row[0]=='g':group=row[1]
        elif row[0]=='f':
            tri=tuple(points[int(v.split('/')[0])-1] for v in row[1:]);groups[group].append(tri)
            native=tuple(tuple(round(v*64) for v in p) for p in tri)
            expected[native]+=1;owners[native].append(group)
    if set(groups)!={s['part'] for s in design['shapes']}:errors.append('Unexpected serialized component groups')
    for name,faces in groups.items():
        edges=defaultdict(int);winding=defaultdict(int);volume=0;vertices=set()
        for a,b,c in faces:
            vertices.update([a,b,c]);volume+=dot(a,cross(b,c))/6
            for u,v in [(a,b),(b,c),(c,a)]:
                key=tuple(sorted((u,v)));edges[key]+=1;winding[key]+=1 if u<v else -1
        if volume<=0 or any(n!=2 for n in edges.values()) or any(winding.values()):errors.append('Open/inward component '+name)
        if len(vertices)-len(edges)+len(faces)!=2:errors.append('Unexpected solid topology '+name)
    floor=record['pose_floors'][0]
    for c in design['contacts']:
        x,y,z=c['witness'];p=(x,y,z-floor)
        for name in [c['part'],c['target']]:
            if not inside(p,groups[name]):errors.append('Detached attachment '+c['part']+' -> '+name)
    reached={'body'}
    while True:
        more={c['part'] for c in design['contacts'] if c['target'] in reached}
        if more<=reached:break
        reached|=more
    if len(design['contacts'])!=len(groups)-1 or reached!=set(groups):errors.append('Incomplete anatomical attachment tree')
    path=root/'src'/model_relative/(kind+'.md3');blob=path.read_bytes();header=struct.unpack_from('<4sI64s9I',blob);offset=header[10]
    collapsed=defaultdict(int);actual=Counter();floor_values=[float('inf')]*header[4];pose_points=[[] for _ in floor_values]
    critical={i:defaultdict(list) for i in [0,10,17,22]}
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset);triangles=[struct.unpack_from('<3I',blob,offset+h[7]+i*12) for i in range(h[6])]
        neutral=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
        part_names=[]
        for tri in triangles:
            key=tuple(neutral[i] for i in tri)
            part_names.append(owners[key].pop() if owners[key] else None)
        for frame in range(h[3]):
            vertices=[struct.unpack_from('<3h',blob,offset+h[10]+(frame*h[5]+i)*8) for i in range(h[5])];pose_points[frame]+=vertices
            floor_values[frame]=min(floor_values[frame],min(v[2]/64 for v in vertices))
            for tri,part_name in zip(triangles,part_names):
                points=tuple(vertices[i] for i in tri)
                if not any(cross(sub(points[1],points[0]),sub(points[2],points[0]))):collapsed[frame]+=1
                if frame==0:actual[points]+=1
                if frame in critical and part_name:critical[frame][part_name].append(tuple(tuple(v/64 for v in p) for p in points))
        offset+=h[-1]
    if actual!=expected:errors.append('Native neutral triangles differ from quantized OBJ')
    if collapsed:errors.append('Collapsed native triangles '+str(dict(collapsed)))
    if any(abs(v)>1/64 for v in floor_values):errors.append('Unsupported pose floor contact')
    if len({tuple(pose_points[i]) for i in range(12,18)})!=6:errors.append('Repeated death geometry')
    # Derive each posed witness from four serialized child vertices. This
    # verifies the actual native joints independently of the deformation code.
    posed_checks=0
    if actual==expected:
        for contact in design['contacts']:
            child=contact['part'];target=contact['target'];x,y,z=contact['witness'];p=(x,y,z-floor)
            vertices=[p for tri in critical[0][child] for p in tri]
            first=min(range(len(vertices)),key=lambda i:dot(sub(vertices[i],p),sub(vertices[i],p)))
            a=vertices[first];second=max(range(len(vertices)),key=lambda i:dot(sub(vertices[i],a),sub(vertices[i],a)))
            u=sub(vertices[second],a)
            third=max(range(len(vertices)),key=lambda i:dot(cross(u,sub(vertices[i],a)),cross(u,sub(vertices[i],a))))
            v=sub(vertices[third],a);fourth=max(range(len(vertices)),key=lambda i:abs(dot(u,cross(v,sub(vertices[i],a)))))
            w=sub(vertices[fourth],a);det=dot(u,cross(v,w));delta=sub(p,a)
            if abs(det)<1e-8:errors.append('Cannot resolve native joint '+child);continue
            coefficients=[dot(delta,cross(v,w))/det,dot(u,cross(delta,w))/det,dot(u,cross(v,delta))/det]
            coefficients=[1-sum(coefficients),*coefficients];indices=[first,second,third,fourth]
            for frame,components in critical.items():
                moved=[q for tri in components[child] for q in tri]
                witness=tuple(sum(weight*moved[i][axis] for weight,i in zip(coefficients,indices)) for axis in range(3))
                for part in [child,target]:
                    posed_checks+=1
                    if not inside(witness,components[part]):errors.append(f'Native pose{frame} detached {child} -> {part}')
    return errors,dict(closed_components=len(groups),attachment_witnesses=len(design['contacts']),rooted_components=len(reached),combat_frames=header[4],collapsed_native_triangles=sum(collapsed.values()),native_pose_floor_values=floor_values,independent_posed_attachment_checks=posed_checks,attachment_frames=list(critical))


def validate(root=ROOT):
    errors=shared_validate(root,'assets/source/art/serpents_720','models/caelum/folklore/serpents','caelum/data/serpent_combat.modeldef',geometry,frame_mapping_only=True)
    try:
        config=json.loads((root/'assets/source/art/serpents_720/ANIMATION.json').read_text())
        expected=[('monai','CaelumBestiary049','CA-FOLK-049'),('mboi_tata','CaelumBestiary051','CA-FOLK-051')]
        if [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]!=expected:errors.append('Unexpected serpent class binding')
        for kind,_,_ in expected:
            more,_=inspect(root,kind);errors.extend(kind+': '+e for e in more)
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={name:inspect(ROOT,name)[1] for name in ['monai','mboi_tata']}
    print(json.dumps(dict(errors=errors,geometry=stats)));raise SystemExit(bool(errors))
