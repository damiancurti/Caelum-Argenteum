"""Validate exact Mikilo/Coquena bindings and their distinct editable garments."""
from collections import defaultdict
import json
try:
    from .validate_beast_men_models import ROOT, validate as shared_validate
    from .generate_duende_models import geometry, ring_shell
except ImportError:
    from validate_beast_men_models import ROOT, validate as shared_validate
    from generate_duende_models import geometry, ring_shell


def validate(root=ROOT):
    errors=shared_validate(root,'assets/source/art/duendes_690','models/caelum/folklore/duendes','caelum/data/duende_combat.modeldef',geometry)
    try:
        source=root/'assets/source/art/duendes_690'
        config=json.loads((source/'ANIMATION.json').read_text())
        assert [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]==[
            ('mikilo','CaelumBestiary009','CA-FOLK-009'),('coquena','CaelumBestiary010','CA-FOLK-010')],'Unexpected creature identities'
        for species,item in config['species'].items():
            design=json.loads((root/item['design']).read_text())
            used={shape['part'] for shape in design['shapes']}
            assert used==set(design['parts']),'Empty or missing editable body/garment group'
            for shape in design['shapes']:
                if shape['kind']!='ring_shell':continue
                mesh=ring_shell(design,shape);edges=defaultdict(int);winding=defaultdict(int);volume=0
                for _,triangle in mesh.faces:
                    points=[tuple(round(v,6) for v in mesh.vertices[i]) for i in triangle]
                    a,b,c=points
                    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                assert volume>0 and all(n==2 for n in edges.values()) and not any(winding.values()),'Open or inward garment: '+species+'/'+shape['name']
        catalogue=json.loads((root/'assets/bestiary/CATALOGUE.json').read_text())['entries']
        assert [(e['id'],e['population']) for e in catalogue if e['id'] in ('CA-FOLK-009','CA-FOLK-010')]==[
            ('CA-FOLK-009','repeatable'),('CA-FOLK-010','unique')],'Catalogue population identity changed'
    except (OSError,KeyError,ValueError,AssertionError) as exc:
        errors.append('Duende combat art: '+(str(exc) or 'Invalid source geometry'))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
