"""Check Avian's serialized anatomy, attachments and native combat mapping."""
import json
import math
import struct
from collections import defaultdict
try:
    from .validate_beast_men_models import ROOT,validate as shared_validate
    from .generate_beast_men_models import prepared_design
    from .generate_avian_models import geometry,dot,cross,sub
    from .validate_inventory_gloves_models import inside
except ImportError:
    from validate_beast_men_models import ROOT,validate as shared_validate
    from generate_beast_men_models import prepared_design
    from generate_avian_models import geometry,dot,cross,sub
    from validate_inventory_gloves_models import inside


def inspect(root=ROOT,species="cachiru"):
    source=root/'assets/source/art/avian_711';design=json.loads((source/(species+'.json')).read_text());config=json.loads((source/'ANIMATION.json').read_text())
    errors=[];points=[];groups=defaultdict(list);group=None
    for line in (source/('editable/'+species+'.obj')).read_text().splitlines():
        words=line.split()
        if not words:continue
        if words[0]=='v':x,z,y=map(float,words[1:]);points.append((x,-y,z))
        elif words[0]=='g':
            group=next((s['name'] for s in design['shapes'] for mat in design['materials'] if words[1]==s['name']+'_'+mat),None)
            if group is None:raise ValueError('Unexpected serialized group '+words[1])
        elif words[0]=='f':groups[group].append(tuple(points[int(v.split('/')[0])-1] for v in words[1:]))
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
    linked={'trunk'}
    while True:
        more={c['part'] for c in contacts if c['target'] in linked}
        if more<=linked:break
        linked|=more
    if linked!=set(groups):errors.append('Unrooted anatomical component')
    blob=(root/('src/models/caelum/folklore/avian/'+species+'.md3')).read_bytes();header=struct.unpack_from('<4sI64s9I',blob);offset=header[10];collapsed=0
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset)
        triangles=[struct.unpack_from('<3I',blob,offset+h[7]+i*12) for i in range(h[6])]
        for frame in range(h[3]):
            vertices=[struct.unpack_from('<3h',blob,offset+h[10]+(frame*h[5]+i)*8) for i in range(h[5])]
            for tri in triangles:
                a,b,c=[vertices[i] for i in tri]
                if not any(cross(sub(b,a),sub(c,a))):collapsed+=1
        offset+=h[-1]
    if collapsed:errors.append(str(collapsed)+' collapsed quantized triangles across combat poses')
    return errors,dict(closed_components=len(groups),attachment_witnesses=len(contacts),rooted_components=len(linked),combat_frames=header[4],collapsed_native_triangles=collapsed)


def validate(root=ROOT):
    errors=shared_validate(root,'assets/source/art/avian_711','models/caelum/folklore/avian','caelum/data/avian_combat.modeldef',geometry,frame_mapping_only=True)
    try:
        config=json.loads((root/'assets/source/art/avian_711/ANIMATION.json').read_text())
        expected=[('cachiru','CaelumBestiary045','CA-FOLK-045'),('kakuy','CaelumBestiary046','CA-FOLK-046'),('kelenken','CaelumBestiary058','CA-FOLK-058')]
        if [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]!=expected:errors.append('Unexpected avian class binding')
        for species,_,_ in expected:
            more,_=inspect(root,species);errors.extend(species+': '+e for e in more)
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={name:inspect(ROOT,name)[1] for name in ['cachiru','kakuy','kelenken']};print(json.dumps({'errors':errors,'geometry':stats}));raise SystemExit(bool(errors))
