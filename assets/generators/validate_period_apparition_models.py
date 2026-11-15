"""Check Viuda/Llorona/Futre's serialized anatomy, attachments and native combat mapping."""
import json
import math
import re
import struct
from collections import Counter,defaultdict
try:
    from .validate_beast_men_models import ROOT,validate as shared_validate,identity_policy_errors
    from .generate_beast_men_models import prepared_design
    from .generate_period_apparition_models import geometry
    from .validate_inventory_chainmail_models import dot,cross,sub
    from .validate_inventory_gloves_models import inside
    from .validate_period_garment_stride import validate as stride_problems
except ImportError:
    from validate_beast_men_models import ROOT,validate as shared_validate,identity_policy_errors
    from generate_beast_men_models import prepared_design
    from generate_period_apparition_models import geometry
    from validate_inventory_chainmail_models import dot,cross,sub
    from validate_inventory_gloves_models import inside
    from validate_period_garment_stride import validate as stride_problems


def inspect(root=ROOT,species="viuda"):
    source=root/'assets/source/art/period_apparitions_811';design=json.loads((source/(species+'.json')).read_text());config=json.loads((source/'ANIMATION.json').read_text())
    errors=[];points=[];groups=defaultdict(list);group=None;material=None;material_owners=defaultdict(list)
    for line in (source/('editable/'+species+'.obj')).read_text().splitlines():
        words=line.split()
        if not words:continue
        if words[0]=='v':x,z,y=map(float,words[1:]);points.append((x,-y,z))
        elif words[0]=='g':
            group=next((s['name'] for s in design['shapes'] for mat in design['materials'] if words[1]==s['name']+'_'+mat),None)
            if group is None:raise ValueError('Unexpected serialized group '+words[1])
            material=words[1][len(group)+1:]
        elif words[0]=='f':
            tri=tuple(points[int(v.split('/')[0])-1] for v in words[1:]);groups[group].append(tri)
            material_owners[tuple(tuple(round(v*64) for v in p) for p in tri)].append(material)
    if set(groups)!={s['name'] for s in design['shapes']}:errors.append('Serialized anatomical groups differ from authored shapes')
    for name,faces in groups.items():
        edges=defaultdict(int);winding=defaultdict(int);volume=0
        for a,b,c in faces:
            volume+=dot(a,cross(b,c))/6
            for u,v in [(a,b),(b,c),(c,a)]:
                key=tuple(sorted((u,v)));edges[key]+=1;winding[key]+=1 if u<v else -1
        if volume<=0 or any(n!=2 for n in edges.values()) or any(winding.values()):errors.append('Open/inward serialized component '+name)
    mesh=geometry(prepared_design(design));low=min(p[2] for p in mesh.vertices);factor=design['preview']['height_map_units']/(max(p[2] for p in mesh.vertices)-low)
    # Idle sample zero must be neutral for these original-space witnesses.
    for transforms in design['motion']['idle']['transforms'].values():
        for t in transforms:
            if abs(t.get('offset',0)+t['amplitude']*math.sin(t.get('phase',0)))>1e-9:errors.append('Neutral attachment frame changed')
    contacts=json.loads((source/'CONTACTS.json').read_text())['species'][species]
    for contact in contacts:
        p=contact['witness'];p=(p[0]*factor,p[1]*factor,(p[2]-low)*factor)
        for name in (contact['part'],contact['target']):
            if not inside(p,groups[name]):errors.append('Detached serialized attachment '+contact['part']+' -> '+name)
    if len(contacts)!=len(groups)-1 or len({c['part'] for c in contacts})!=len(contacts):errors.append('Incomplete attachment graph')
    linked={design['attachment_root']}
    while True:
        more={c['part'] for c in contacts if c['target'] in linked}
        if more<=linked:break
        linked|=more
    if linked!=set(groups):errors.append('Unrooted anatomical component')
    expected=Counter();owners=defaultdict(list)
    for name,faces in groups.items():
        for tri in faces:
            key=tuple(tuple(round(v*64) for v in p) for p in tri)
            expected[key]+=1;owners[key].append(name)
    blob=(root/('src/models/caelum/folklore/periodapparitions/'+species+'.md3')).read_bytes()
    header=struct.unpack_from('<4sI64s9I',blob);offset=header[10]
    uv_values=defaultdict(dict);uv_outside=0
    collapsed=0;collapsed_parts=Counter();actual=Counter();floors=[float('inf')]*header[4];poses=[[] for _ in floors]
    critical={i:defaultdict(list) for i in [0,10,17,22]}
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset)
        triangles=[struct.unpack_from('<3I',blob,offset+h[7]+i*12) for i in range(h[6])]
        neutral=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
        uvs=[struct.unpack_from('<2f',blob,offset+h[9]+i*8) for i in range(h[5])]
        part_names=[]
        for tri in triangles:
            key=tuple(neutral[i] for i in tri)
            part_names.append(owners[key].pop() if owners[key] else None)
            material=material_owners[key].pop() if material_owners[key] else None
            if material:
                for i in tri:uv_values[material][(offset,i)]=uvs[i]
        for frame in range(h[3]):
            vertices=[struct.unpack_from('<3h',blob,offset+h[10]+(frame*h[5]+i)*8) for i in range(h[5])]
            poses[frame]+=vertices;floors[frame]=min(floors[frame],min(v[2]/64 for v in vertices))
            for tri,name in zip(triangles,part_names):
                points=tuple(vertices[i] for i in tri)
                if not any(cross(sub(points[1],points[0]),sub(points[2],points[0]))):collapsed+=1;collapsed_parts[name]+=1
                if frame==0:actual[points]+=1
                if frame in critical and name:critical[frame][name].append(tuple(tuple(v/64 for v in p) for p in points))
        offset+=h[-1]
    for material,values in uv_values.items():
        spec=design['materials'][material]
        if 'uv_rect' in spec:
            u0,v0,u1,v1=spec['uv_rect']
        else:
            col,row=spec['tile'];margin=design['atlas']['inset']
            u0=(col+margin)/design['atlas']['columns'];u1=(col+1-margin)/design['atlas']['columns']
            v0=(row+margin)/design['atlas']['rows'];v1=(row+1-margin)/design['atlas']['rows']
        uv_outside+=sum(not all(-1e-6<=v<=1+1e-6 for v in ((u-u0)/(u1-u0),(v-v0)/(v1-v0))) for u,v in values.values())
    if uv_outside:errors.append(f'{uv_outside} native UVs outside assigned material cells')
    definition=(root/'src/caelum/data/period_apparition_combat.modeldef').read_text()
    block=dict(re.findall(r'\bModel\s+(\w+)\s*\{([^}]+)\}',definition))[config['species'][species]['actor']]
    offsets=re.findall(r'Offset\s+([^\n]+)',block)
    if len(offsets)>1 or (list(map(float,offsets[0].split())) if offsets else [0,0,0])!=design['preview']['model_offset']:errors.append('Authored render offset differs from MODELDEF')
    if actual!=expected:errors.append('Native neutral triangles differ from quantized editable OBJ')
    if collapsed:errors.append(str(collapsed)+' collapsed quantized triangles across combat poses: '+str(dict(collapsed_parts)))
    if any(abs(v)>1/64 for v in floors):errors.append('Unsupported native pose floor')
    if len({tuple(poses[i]) for i in range(12,18)})!=6:errors.append('Repeated death geometry')
    # Infer moved witnesses from serialized child vertices, not the generator's
    # deformation equations. This detects joints that open only in action poses.
    checks=0
    if actual==expected:
        for contact in contacts:
            child=contact['part'];target=contact['target'];x,y,z=contact['witness']
            p=(x*factor,y*factor,(z-low)*factor)
            vertices=[q for tri in critical[0][child] for q in tri]
            first=min(range(len(vertices)),key=lambda i:dot(sub(vertices[i],p),sub(vertices[i],p)))
            a=vertices[first]
            second=max(range(len(vertices)),key=lambda i:dot(sub(vertices[i],a),sub(vertices[i],a)))
            u=sub(vertices[second],a)
            third=max(range(len(vertices)),key=lambda i:dot(cross(u,sub(vertices[i],a)),cross(u,sub(vertices[i],a))))
            v=sub(vertices[third],a)
            fourth=max(range(len(vertices)),key=lambda i:abs(dot(u,cross(v,sub(vertices[i],a)))))
            w=sub(vertices[fourth],a);det=dot(u,cross(v,w));delta=sub(p,a)
            if abs(det)<1e-8:errors.append('Cannot resolve native joint '+child);continue
            weights=[dot(delta,cross(v,w))/det,dot(u,cross(delta,w))/det,dot(u,cross(v,delta))/det]
            weights=[1-sum(weights),*weights];indices=[first,second,third,fourth]
            for frame,components in critical.items():
                moved=[q for tri in components[child] for q in tri]
                witness=tuple(sum(weight*moved[i][axis] for weight,i in zip(weights,indices)) for axis in range(3))
                for name in [child,target]:
                    checks+=1
                    if not inside(witness,components[name]):errors.append(f'Native pose{frame} detached {child} -> {name}')
    return errors,dict(closed_components=len(groups),attachment_witnesses=len(contacts),rooted_components=len(linked),combat_frames=header[4],collapsed_native_triangles=collapsed,native_pose_floor_values=floors,independent_posed_attachment_checks=checks,attachment_frames=list(critical),native_material_uv_vertices=sum(len(v) for v in uv_values.values()),native_uv_outside_material_cell=uv_outside,authored_render_offset=design['preview']['model_offset'],critical_component_floors={str(frame):{name:min(p[2] for tri in faces for p in tri) for name,faces in components.items()} for frame,components in critical.items()})



def validate(root=ROOT):
    errors=shared_validate(root,'assets/source/art/period_apparitions_811','models/caelum/folklore/periodapparitions','caelum/data/period_apparition_combat.modeldef',geometry,frame_mapping_only=True)
    try:
        config=json.loads((root/'assets/source/art/period_apparitions_811/ANIMATION.json').read_text())
        errors.extend(identity_policy_errors(config))
        expected=[('viuda','CaelumBestiary031','CA-FOLK-031'),('llorona','CaelumBestiary032','CA-FOLK-032'),('futre','CaelumBestiary033','CA-FOLK-033')]
        if [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]!=expected:errors.append('Unexpected Viuda/Llorona/Futre class binding')
        for species,_,_ in expected:
            more,_=inspect(root,species);errors.extend(species+': '+e for e in more)
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    errors.extend(stride_problems(root))
    return errors


if __name__=='__main__':
    errors=validate();stats={name:inspect(ROOT,name)[1] for name in ['viuda','llorona','futre']};print(json.dumps({'errors':errors,'geometry':stats}));raise SystemExit(bool(errors))
