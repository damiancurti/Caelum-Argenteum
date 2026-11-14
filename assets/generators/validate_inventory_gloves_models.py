"""Check four native glove pairs, joined components and genuinely open cuffs."""
import hashlib
import json
import math
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT, validate as validate_family
    from .generate_inventory_consumable_models import geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT, validate as validate_family
    from generate_inventory_consumable_models import geometry


def subtract(a, b):
    return tuple(x-y for x, y in zip(a, b))


def dot(a, b):
    return sum(x*y for x, y in zip(a, b))


def cross(a, b):
    return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])


def ray_hits(origin, direction, triangles):
    """Intersect the serialized triangles; collapse shared-edge duplicates."""
    hits=[]
    for a, b, c in triangles:
        ab=subtract(b, a);ac=subtract(c, a);p=cross(direction, ac);det=dot(ab, p)
        if abs(det)<1e-10:
            continue
        delta=subtract(origin, a);u=dot(delta, p)/det;q=cross(delta, ab);v=dot(direction, q)/det
        distance=dot(ac, q)/det
        if u>=-1e-8 and v>=-1e-8 and u+v<=1+1e-8 and distance>=-1e-8:
            hits.append(max(0., distance))
    unique=[]
    for distance in sorted(hits):
        if not unique or abs(distance-unique[-1])>1e-6:
            unique.append(distance)
    return unique


def inside(point, triangles):
    # Two independent oblique directions avoid accepting a grazing edge as a
    # volume intersection. The witness must also clear MD3 quantization.
    for direction in ((1., .378, .611), (-.419, 1., -.273)):
        length=math.sqrt(dot(direction, direction));direction=tuple(v/length for v in direction)
        hits=ray_hits(point, direction, triangles)
        if len(hits)%2!=1 or hits[0]<=1/64:
            return False
    return True


def normalization(config, family, item, record):
    neutral={'tiers':list(config['tier_materials']), 'tier_materials':config['tier_materials'],
             'atlas':{'columns':1, 'rows':1, 'inset':0, 'tiles':{key:[0, 0] for key in config['materials']}}}
    points=[]
    for part in family['parts']:
        mesh, _=geometry(neutral, {'parts':[part]}, item['tier'])
        matrix=part.get('rotation', ((1,0,0),(0,1,0),(0,0,1)));offset=part.get('offset', (0,0,0))
        points.extend(tuple(dot(row, point)+offset[axis] for axis,row in enumerate(matrix)) for point in mesh.vertices)
    factor=record['target_art_extent']/(max(p[0] for p in points)-min(p[0] for p in points))
    floor=min(p[2] for p in points)
    return factor, lambda p:(p[0]*factor, (p[2]-floor)*factor, -p[1]*factor)


def validate(root=ROOT):
    errors=validate_family(root, 'gloves', 4, distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/gloves'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        bindings=[(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]
        if bindings!=[('CaelumClothingPickup',f'WC{i}',i) for i in range(16,20)]:
            errors.append('Unexpected glove catalogue binding')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:
                errors.append('Stale editable gloves: '+name)
        for native,original in config['texture_sources'].items():
            blob=(root/original).read_bytes()
            if (root/'src'/native).read_bytes()!=blob or (source/'editable/src'/native).read_bytes()!=blob:
                errors.append('Original glove pixels changed: '+native)
        for name,material in config['materials'].items():
            left,top,right,bottom=material['rect_pixels']
            with Image.open(root/'src'/material['texture']) as picture:
                if picture.size!=tuple(material['image_size']):
                    errors.append('Incorrect image dimensions: '+name)
                if picture.convert('RGBA').getchannel('A').crop((left-1,top-1,right+1,bottom+1)).getextrema()[0]<250:
                    errors.append('Transparent UV crop or sampling margin: '+name)
        for name,item in config['variants'].items():
            family=config['families'][item['family']];record=report['variants'][name]
            bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            if any(bounds['max'][axis]-bounds['min'][axis]>ref[index+2]-ref[index]+1/32 for axis,index in ((0,0),(2,1))):
                errors.append('Glove pair exceeds original sprite envelope: '+name)
            if bounds['max'][2]-bounds['min'][2]<=1:
                errors.append('Glove pair lacks physical thickness: '+name)
            vertices=[];parts=defaultdict(list);part=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:
                    continue
                if values[0]=='v':vertices.append(tuple(map(float,values[1:])))
                elif values[0]=='g':part=values[1]
                elif values[0]=='f':parts[part].append([vertices[int(v.split('/')[0])-1] for v in values[1:]])
            if set(parts)!={p['part'] for p in family['parts']}:
                errors.append('Missing separate glove component: '+name)
            for hand in ('left','right'):
                if not {hand+'_palm_cuff',hand+'_thumb',*(hand+f'_finger_{i}' for i in range(4))}.issubset(parts):
                    errors.append('Expected a complete left/right five-finger pair: '+name)
            for part,triangles in parts.items():
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for points in triangles:
                    a,b,c=points;volume+=dot(a,cross(b,c))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):
                    errors.append('Open/inward component: '+name+'/'+part)
            factor,transform=normalization(config,family,item,record)
            contacts={c['part'] for c in family['contacts']}
            if contacts!=set(parts)-{'left_palm_cuff','right_palm_cuff'}:
                errors.append('A non-palm component lacks an attachment witness: '+name)
            for contact in family['contacts']:
                point=transform(contact['witness'])
                for part in (contact['part'],contact['target']):
                    if not inside(point,parts[part]):
                        errors.append('Attachment witness outside solid volume: '+name+'/'+contact['part']+' -> '+part)
                if contact['kind']=='surface':
                    shape=next(p for p in family['parts'] if p['part']==contact['part'])
                    matrix=shape['rotation'];dx,dy,dz=(-row[1] for row in matrix)
                    normal=(dx,dz,-dy);span=record['target_art_extent']*2;distances=[]
                    # Check every serialized patch/button vertex against the
                    # actual palm, independently of its authored surface profile.
                    for point in set(p for triangle in parts[contact['part']] for p in triangle):
                        origin=tuple(p+n*span for p,n in zip(point,normal))
                        hits=ray_hits(origin,tuple(-n for n in normal),parts[contact['target']])
                        if not hits:
                            errors.append('Surface attachment leaves palm: '+name+'/'+contact['part'])
                            break
                        distances.append(span-hits[0])
                    if not distances or not min(distances)<0<max(distances) or max(abs(d) for d in distances)>shape['depth']*factor+1/64:
                        errors.append('Surface attachment floats or sinks beyond its thickness: '+name+'/'+contact['part'])
            if {c['part'] for c in family['cuff_openings']}!={'left_palm_cuff','right_palm_cuff'}:
                errors.append('Expected two wrist-opening probes: '+name)
            for cuff in family['cuff_openings']:
                dx,dy,dz=cuff['direction'];direction=(dx,dz,-dy)
                hits=ray_hits(transform(cuff['origin']),direction,parts[cuff['part']])
                if not hits or hits[0]<cuff['minimum_travel']*factor:
                    errors.append('Cuff is sealed or lacks its deep cavity: '+name+'/'+cuff['part'])
    except (OSError,KeyError,ValueError) as exc:
        errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
