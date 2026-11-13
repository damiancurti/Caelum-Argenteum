"""Validate three original mate models, accepted materials and sprite envelopes."""
import hashlib
import json
import math
import struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def validate(root=ROOT):
    errors=validate_family(root,'mates',3)
    try:
        source=root/'assets/source/art/inventory_models_647/mates'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mate geometry: '+name)
        for name,item in config['variants'].items():
            settings=config['materials'][name];texture=root/'src'/settings['texture'];original=root/item['source_art']
            if texture.read_bytes()!=original.read_bytes() or (source/'editable/src'/settings['texture']).read_bytes()!=original.read_bytes():errors.append('Changed accepted mate pixels: '+name)
            record=report['variants'][name];bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            if any(bounds['max'][axis]-bounds['min'][axis]>(ref[index+2]-ref[index])/item['sprite_scale'][index]+1/32 for axis,index in ((0,0),(2,1))):errors.append('Mate leaves accepted sprite envelope: '+name)
            blob=(root/'src'/config['model_path']/(name+'.md3')).read_bytes();header=struct.unpack_from('<4sI64s9I',blob);offset=header[10]
            pixels=Image.open(texture).convert('RGBA').getchannel('A');width,height=pixels.size
            bad=[]
            for surface in record['surfaces']:
                fields=struct.unpack_from('<4s64s10I',blob,offset)
                uv=[struct.unpack_from('<2f',blob,offset+fields[9]+i*8) for i in range(fields[5])]
                # Barycentric edge/interior samples include a bilinear texel margin.
                for index in range(fields[6]):
                    tri=struct.unpack_from('<3I',blob,offset+fields[7]+index*12);coords=[uv[i] for i in tri]
                    for a in range(5):
                        for b in range(5-a):
                            weights=(a/4,b/4,1-(a+b)/4)
                            u,v=(sum(weight*point[axis] for weight,point in zip(weights,coords)) for axis in (0,1))
                            x,y=math.floor(u*width-.5),math.floor(v*height-.5)
                            alpha=min(pixels.getpixel((max(0,min(width-1,x+dx)),max(0,min(height-1,y+dy)))) for dx,dy in ((0,0),(0,1),(1,0),(1,1)))
                            if alpha<250:
                                bad.append((index,x,y,alpha));break
                        else:continue
                        break
                offset+=fields[-1]
            if bad:errors.append('Mate UV alpha/margin below 250: '+name+' '+str(len(bad))+' triangles; '+str(bad[:4]))
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
