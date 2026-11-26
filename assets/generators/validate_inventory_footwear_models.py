"""Validate paired footwear, attached surface details and deep open interiors."""
import hashlib,json,math
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT, validate as validate_family
    from .validate_inventory_gloves_models import dot,cross,inside,ray_hits,normalization
except ImportError:
    from validate_inventory_ammunition_models import ROOT, validate as validate_family
    from validate_inventory_gloves_models import dot,cross,inside,ray_hits,normalization


def validate(root=ROOT):
    errors=validate_family(root, 'footwear', 5, distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/footwear'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        bindings=[(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]
        if bindings!=[('CaelumClothingPickup',f'WC{i}',i) for i in range(20,25)]:
            errors.append('Unexpected footwear catalogue binding')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:
                errors.append('Stale editable footwear: '+name)
        for native,original in config['texture_sources'].items():
            blob=(root/original).read_bytes()
            if (root/'src'/native).read_bytes()!=blob or (source/'editable/src'/native).read_bytes()!=blob:
                errors.append('Original footwear pixels changed: '+native)
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
                errors.append('Footwear pair exceeds original sprite envelope: '+name)
            if bounds['max'][2]-bounds['min'][2]<=1:
                errors.append('Footwear pair lacks physical thickness: '+name)
            vertices=[];parts=defaultdict(list);part=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:
                    continue
                if values[0]=='v':vertices.append(tuple(map(float,values[1:])))
                elif values[0]=='g':part=values[1]
                elif values[0]=='f':parts[part].append([vertices[int(v.split('/')[0])-1] for v in values[1:]])
            if set(parts)!={p['part'] for p in family['parts']}:
                errors.append('Missing separate footwear component: '+name)
            for side in ('left','right'):
                if not {side+'_upper',side+'_lining',side+'_sole'}.issubset(parts):
                    errors.append('Missing complete shoe pair: '+name)
            for part,triangles in parts.items():
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for points in triangles:
                    a,b,c=points;volume+=dot(a,cross(b,c))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):
                    errors.append('Open/inward component: '+name+'/'+part)
            factor,transform=normalization(config,family,item,record)
            # A valid joint does not prove that the full lining stays beneath
            # the outer leather/cloth. Check every serialized lining vertex
            # against the actual faceted elliptical shell at its own height.
            floor=-transform((0,0,0))[1]/factor
            for side in ('left','right'):
                shape=next(p for p in family['parts'] if p['part']==side+'_upper')
                matrix=shape['rotation'];offset=shape['offset'];segments=shape['segments']
                for point in set(p for triangle in parts[side+'_lining'] for p in triangle):
                    global_point=(point[0]/factor,-point[2]/factor,point[1]/factor+floor)
                    delta=tuple(a-b for a,b in zip(global_point,offset))
                    x,y,z=(sum(matrix[j][i]*delta[j] for j in range(3)) for i in range(3))
                    for a,b in zip(family['profile'],family['profile'][1:]):
                        if a[0]-1e-6<=z<=b[0]+1e-6:
                            t=(z-a[0])/(b[0]-a[0]);cx,cy,rx,ry=(a[i]+t*(b[i]-a[i]) for i in range(1,5));break
                    else:
                        errors.append('Lining leaves outer shell height: '+name+'/'+side);break
                    nx=(x-cx)/rx;ny=(y-cy)/ry;angle=math.atan2(ny,nx)%(2*math.pi)
                    step=2*math.pi/segments;middle=(math.floor(angle/step)+.5)*step
                    limit=math.cos(step/2)/math.cos(angle-middle)
                    if math.hypot(nx,ny)>limit+1e-6:
                        errors.append('Lining protrudes through outer shell: '+name+'/'+side);break
            if {probe['part'] for probe in family['lining_exposure']}!={'left_lining','right_lining'}:
                errors.append('Expected two lining visibility probes: '+name)
            for probe in family['lining_exposure']:
                dx,dy,dz=probe['direction'];direction=(dx,dz,-dy);origin=transform(probe['origin'])
                lining_hits=ray_hits(origin,direction,parts[probe['part']])
                upper_hits=ray_hits(origin,direction,parts[probe['upper']])
                if not lining_hits or not upper_hits or lining_hits[0]+1/64>=upper_hits[0]:
                    errors.append('Lining is hidden inside its outer upper: '+name+'/'+probe['part'])
            contacts={c['part'] for c in family['contacts']}
            if contacts!=set(parts)-{'left_upper','right_upper'}:
                errors.append('A non-upper component lacks an attachment witness: '+name)
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
                    # actual upper, independently of its authored surface profile.
                    for point in set(p for triangle in parts[contact['part']] for p in triangle):
                        origin=tuple(p+n*span for p,n in zip(point,normal))
                        hits=ray_hits(origin,tuple(-n for n in normal),parts[contact['target']])
                        if not hits:
                            errors.append('Surface attachment leaves upper: '+name+'/'+contact['part'])
                            break
                        distances.append(span-hits[0])
                    if not distances or not min(distances)<0<max(distances) or max(abs(d) for d in distances)>shape['depth']*factor+1/64:
                        errors.append('Surface attachment floats or sinks beyond its thickness: '+name+'/'+contact['part'])
            if {c['part'] for c in family['openings']}!={'left_upper','right_upper'}:
                errors.append('Expected two foot-opening probes: '+name)
            for cuff in family['openings']:
                dx,dy,dz=cuff['direction'];direction=(dx,dz,-dy)
                hits=ray_hits(transform(cuff['origin']),direction,[triangle for part,triangles in parts.items() if part.startswith(cuff['part'].split('_')[0]+'_') for triangle in triangles])
                if not hits or hits[0]<cuff['minimum_travel']*factor:
                    errors.append('Foot opening is sealed or lacks its deep cavity: '+name+'/'+cuff['part'])
    except (OSError,KeyError,ValueError) as exc:
        errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
