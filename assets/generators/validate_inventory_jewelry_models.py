"""Verify fourteen exact jewelry bindings and independently closed editable parts."""
import hashlib
import json
import math
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def validate(root=ROOT):
    errors=validate_family(root,'jewelry',14,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/jewelry'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale editable jewelry: '+name)
        for material in config['materials'].values():
            texture=material['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable original material: '+texture)
        for name,item in config['variants'].items():
            record=report['variants'][name];bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            pixels=Image.open(root/item['reference']).convert('RGBA').getchannel('A')
            x,y=(math.floor(value*128-.5) for value in item['undercoat_uv'])
            if any(pixels.getpixel((x+dx,y+dy))!=255 for dx in (0,1) for dy in (0,1)):errors.append('Transparent gem/emblem undercoat sample: '+name)
            if any(bounds['max'][axis]-bounds['min'][axis]>(ref[index+2]-ref[index])+1/32 for axis,index in ((0,0),(2,1))):errors.append('Jewelry exceeds original sprite envelope: '+name)
            if bounds['max'][1]-bounds['min'][1]<=1:errors.append('Jewelry lacks actual depth: '+name)
            vertices=[];parts=defaultdict(list);part=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:continue
                if values[0]=='v':vertices.append(tuple(map(float,values[1:])))
                elif values[0]=='g':part=values[1]
                elif values[0]=='f':parts[part].append([vertices[int(v.split('/')[0])-1] for v in values[1:]])
            if set(parts)!={p['part'] for p in item['parts']}:errors.append('Missing independent jewelry component: '+name)
            for part,triangles in parts.items():
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for points in triangles:
                    a,b,c=points
                    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):errors.append('Open/inward jewelry component: '+name+'/'+part)
        # The three reused metal tiles must stay opaque through their UV domain.
        for name in ('silver','bronze','gold'):
            settings=config['materials'][name];alpha=Image.open(root/'src'/settings['texture']).convert('RGBA').getchannel('A')
            if alpha.crop(tuple(settings['rect_pixels'])).getextrema()!=(255,255):errors.append('Transparent jewelry backing tile: '+name)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
