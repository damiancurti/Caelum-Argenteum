"""Check exact unique-creature bindings and every closed anatomical component."""
import copy
import json
from collections import defaultdict
try:
    from .validate_beast_men_models import ROOT,validate as shared_validate
    from .generate_beast_men_models import prepared_design
    from .generate_guardian_models import geometry
    from .validate_inventory_gloves_models import inside
except ImportError:
    from validate_beast_men_models import ROOT,validate as shared_validate
    from generate_beast_men_models import prepared_design
    from generate_guardian_models import geometry
    from validate_inventory_gloves_models import inside


def serialized_components(source,species,design):
    """Read emitted neutral OBJ coordinates; match the documented shape order."""
    vertices=[];faces=[]
    for line in (source/'editable'/(species+'.obj')).read_text().splitlines():
        words=line.split()
        if words and words[0]=='v':
            x,z,negative_y=map(float,words[1:]);vertices.append((x,-negative_y,z))
        elif words and words[0]=='f':faces.append(tuple(int(w.split('/')[0])-1 for w in words[1:]))
    groups={};offset=0
    for shape in design['shapes']:
        component=copy.deepcopy(design);component['shapes']=[shape]
        count=len(geometry(prepared_design(component)).faces)
        groups[shape['name']]=[tuple(vertices[i] for i in tri) for tri in faces[offset:offset+count]]
        offset+=count
    assert offset==len(faces),'Serialized component face order changed'
    return groups


def validate(root=ROOT):
    errors=shared_validate(root,'assets/source/art/guardians_698','models/caelum/folklore/guardians','caelum/data/guardian_combat.modeldef',geometry)
    try:
        source=root/'assets/source/art/guardians_698';config=json.loads((source/'ANIMATION.json').read_text())
        assert [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]==[
            ('yasi','CaelumBestiary007','CA-FOLK-007'),('yastay','CaelumBestiary011','CA-FOLK-011')],'Unexpected creature bindings'
        for species,item in config['species'].items():
            design=json.loads((root/item['design']).read_text())
            assert {s['part'] for s in design['shapes']}==set(design['parts']),'Empty or missing editable component'
            for shape in design['shapes']:
                component=copy.deepcopy(design);component['shapes']=[shape];mesh=geometry(prepared_design(component))
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for _,tri in mesh.faces:
                    points=[tuple(round(v,7) for v in mesh.vertices[i]) for i in tri];a,b,c=points
                    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):
                    errors.append('Open/inward component: '+species+'/'+shape['name'])
            contacts=json.loads((source/'CONTACTS.json').read_text())['species'][species]
            assert len(contacts)=={'yasi':45,'yastay':41}[species],'Missing attachment witnesses'
            assert len({(c['part'],c['target']) for c in contacts})==len(contacts),'Duplicate attachment witnesses'
            groups=serialized_components(source,species,design)
            for contact in contacts:
                for name in (contact['part'],contact['target']):
                    if not inside(contact['witness'],groups[name]):
                        errors.append('Detached serialized attachment: '+species+'/'+contact['part']+' -> '+name)
        entries=json.loads((root/'assets/bestiary/CATALOGUE.json').read_text())['entries']
        assert [(e['id'],e['population']) for e in entries if e['id'] in ('CA-FOLK-007','CA-FOLK-011')]==[
            ('CA-FOLK-007','unique'),('CA-FOLK-011','unique')],'Unique population identity changed'
    except (OSError,KeyError,ValueError,AssertionError) as exc:errors.append('Guardian combat art: '+str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
