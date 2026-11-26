"""Check native ensemble bindings, real cloth volumes and fitted details."""
import hashlib
import json
import math
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_gloves_models import dot,cross,inside,ray_hits,subtract
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_gloves_models import dot,cross,inside,ray_hits,subtract


def validate(root=ROOT):
    errors=validate_family(root,'clothing',11,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/clothing'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        expected=[('CaelumClothingPickup',f'WC{i:02}',i) for i in range(11)]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=expected:
            errors.append('Unexpected clothing catalogue bindings')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:
                errors.append('Stale editable clothing: '+name)
        for native,original in config['texture_sources'].items():
            blob=(root/original).read_bytes()
            if (root/'src'/native).read_bytes()!=blob or (source/'editable/src'/native).read_bytes()!=blob:
                errors.append('Original outfit pixels changed: '+native)
        for name,material in config['materials'].items():
            left,top,right,bottom=material['rect_pixels']
            with Image.open(root/'src'/material['texture']) as picture:
                if picture.size!=tuple(material['image_size']):errors.append('Incorrect image dimensions: '+name)
                if picture.convert('RGBA').getchannel('A').crop((left-1,top-1,right+1,bottom+1)).getextrema()[0]<250:
                    errors.append('Transparent material crop or sampling margin: '+name)
        for name,item in config['variants'].items():
            family=config['families'][item['family']];record=report['variants'][name]
            bounds=record['native_bounds'][0];reference=record['reference_opaque_bounds']
            if any(bounds['max'][axis]-bounds['min'][axis]>reference[index+2]-reference[index]+1/32 for axis,index in ((0,0),(2,1))):
                errors.append('Ensemble exceeds original sprite envelope: '+name)
            vertices=[];parts=defaultdict(list);part=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:continue
                if values[0]=='v':vertices.append(tuple(map(float,values[1:])))
                elif values[0]=='g':part=values[1]
                elif values[0]=='f':parts[part].append([vertices[int(v.split('/')[0])-1] for v in values[1:]])
            if set(parts)!={p['part'] for p in family['parts']}:errors.append('Missing ensemble component: '+name)
            if not {'shirt','trousers'}.issubset(family['component_groups']):errors.append('Incomplete outfit: '+name)
            if any(any(token in part for token in ('mannequin','skin','human_body')) for part in parts):
                errors.append('A world outfit must not contain a wearer: '+name)
            for part,triangles in parts.items():
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for points in triangles:
                    a,b,c=points;volume+=dot(a,cross(b,c))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):
                    errors.append('Open/inward garment component: '+name+'/'+part)
            factor=record['source_to_native']['factor'];floor=record['source_to_native']['floor']
            transform=lambda p:(p[0]*factor,(p[2]-floor)*factor,-p[1]*factor)
            expected_contacts={('shirt_collar','shirt_body')}
            for side in ('left','right'):
                expected_contacts.update(((side+'_shirt_sleeve','shirt_body'),(side+'_shirt_cuff',side+'_shirt_sleeve')))
                if side+'_trouser_leg' in parts:
                    expected_contacts.update(((side+'_trouser_leg','trouser_hips'),(side+'_trouser_cuff',side+'_trouser_leg')))
                if side+'_coat_sleeve' in parts:
                    expected_contacts.update(((side+'_coat_sleeve','outer_coat'),(side+'_coat_cuff',side+'_coat_sleeve')))
            if 'raised_coat_collar' in parts:expected_contacts.add(('raised_coat_collar','outer_coat'))
            if 'poncho' in parts:expected_contacts.update((part,'poncho') for part in parts if part.startswith('poncho_'))
            if {(c['part'],c['target']) for c in family['assembly_contacts']}!=expected_contacts:
                errors.append('Missing garment assembly joint: '+name)
            for contact in family['assembly_contacts']:
                for part in (contact['part'],contact['target']):
                    if not inside(transform(contact['witness']),parts[part]):
                        errors.append('Assembly witness outside solid cloth: '+name+'/'+contact['part']+' -> '+part)
            all_triangles=[triangle for triangles in parts.values() for triangle in triangles]
            for probe in family['openings']:
                dx,dy,dz=probe['direction'];hits=ray_hits(transform(probe['origin']),(dx,dz,-dy),all_triangles)
                if (not hits and not probe['allow_no_hit']) or (hits and hits[0]<probe['minimum_travel']*factor):
                    errors.append('Garment opening is blocked: '+name+'/'+probe['parts'][0])
            for shape in family['parts']:
                if 'attachment_target' not in shape:continue
                part=shape['part'];target=shape['attachment_target'];depth=shape['depth']*factor
                span=record['target_art_extent']*2;near=[]
                for point in set(p for triangle in parts[part] for p in triangle):
                    origin=(point[0],point[1],point[2]+span)
                    hits=ray_hits(origin,(0,0,-1),parts[target])
                    distance=span-hits[0] if hits else float('inf')
                    if abs(distance)>depth/2+1/32:
                        if not shape.get('allow_free_edge',False):
                            errors.append('Detail leaves its fitted garment surface: '+name+'/'+part);break
                    else:near.append(distance)
                if not near or not min(near)<0<max(near):
                    errors.append('Detail lacks intersecting front/back surfaces: '+name+'/'+part)
                attached=False
                for a,b,c in parts[part]:
                    normal=cross(subtract(b,a),subtract(c,a));length=math.sqrt(dot(normal,normal))
                    if length<1e-10 or normal[2]/length<.4:continue
                    point=tuple((x+y+z)/3-n/length*depth*.6 for x,y,z,n in zip(a,b,c,normal))
                    if inside(point,parts[part]) and inside(point,parts[target]):attached=True;break
                if not attached:errors.append('Detail has no solid attachment to its garment: '+name+'/'+part)
    except (OSError,KeyError,ValueError) as exc:
        errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
