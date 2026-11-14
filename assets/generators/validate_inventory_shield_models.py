"""Check shield volumes, native bindings, original pixels and real grip attachment."""
import hashlib
import json
import struct
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_gloves_models import dot,cross,inside
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_gloves_models import dot,cross,inside


def validate(root=ROOT):
    errors=validate_family(root,'shields',4,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/shields'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        expected=[('CaelumShieldPickup',sprite,i) for i,sprite in enumerate(('CBUC','CSHK','CSHT','CSHM'))]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=expected:errors.append('Unexpected shield bindings')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable shield '+name)
        for native,original in config['texture_sources'].items():
            if (root/'src'/native).read_bytes()!=(root/original).read_bytes() or (source/'editable/src'/native).read_bytes()!=(root/original).read_bytes():errors.append('Original shield pixels changed '+native)
        for key,settings in config['materials'].items():
            if key.endswith('_front'):continue
            with Image.open(root/'src'/settings['texture']) as im:
                a,b,c,d=settings['rect_pixels']
                if im.convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()[0]<240:errors.append('Transparent rear/rim crop '+key)
        for name,item in config['variants'].items():
            record=report['variants'][name];family=config['families'][name];points=[];parts=defaultdict(list);group=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:continue
                if values[0]=='v':points.append(tuple(map(float,values[1:])))
                elif values[0]=='g':group=values[1]
                elif values[0]=='f':
                    indices=[int(v.split('/')[0])-1 for v in values[1:]];parts[group].append([points[i] for i in indices])
            for part,triangles in parts.items():
                edges=defaultdict(int);directions=defaultdict(int);volume=0
                for vertices in triangles:
                    a,b,c=vertices;volume+=dot(a,cross(b,c))/6
                    for a,b in zip(vertices,vertices[1:]+vertices[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;directions[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(directions.values()):errors.append('Open/inward shield component '+name+'/'+part)
            factor=record['source_to_native']['factor'];floor=record['source_to_native']['floor']
            transform=lambda p:(p[0]*factor,(p[2]-floor)*factor,-p[1]*factor)
            for contact in family['assembly_contacts']:
                for part in (contact['part'],contact['target']):
                    if not inside(transform(contact['witness']),parts[part]):errors.append('Detached shield assembly '+name+'/'+contact['part']+' -> '+part)
            for shape in family['parts']:
                if shape['kind']!='shield_strap':continue
                x,y,z=shape['center'];origin=transform((x,y+shape['radius']*.5,z))
                if any(inside(origin,triangles) for triangles in parts.values()):errors.append('Blocked rear grip clearance '+name+'/'+shape['part'])
            # Owned icons contain internal alpha cutouts. The unchanged painted
            # skin deliberately exposes the closed wood/metal board underneath.
            # Pixel identity is enforced above; alpha does not define solid volume.
            binary=(root/'src'/config['model_path']/(name+'.md3')).read_bytes()
            header=struct.unpack_from('<4sI64s9I',binary);offset=header[10]
            for _ in range(header[6]):
                fields=struct.unpack_from('<4s64s10I',binary,offset)
                vertices=[struct.unpack_from('<3h',binary,offset+fields[10]+i*8) for i in range(fields[5])]
                for i in range(fields[6]):
                    a,b,c=[vertices[k] for k in struct.unpack_from('<3I',binary,offset+fields[7]+i*12)]
                    u=tuple(x-y for x,y in zip(b,a));v=tuple(x-y for x,y in zip(c,a))
                    if not any(cross(u,v)):errors.append('Collapsed quantized native triangle '+name);break
                offset+=fields[-1]
            bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            if any(bounds['max'][axis]-bounds['min'][axis]>ref[index+2]-ref[index]+1/32 for axis,index in ((0,0),(2,1))):errors.append('Shield exceeds original sprite envelope '+name)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
