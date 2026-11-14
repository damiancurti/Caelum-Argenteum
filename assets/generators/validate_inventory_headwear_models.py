"""Validate five native headwear bindings, closed props and real underside cavities."""
import hashlib
import json
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def validate(root=ROOT):
    errors=validate_family(root,'headwear',5,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/headwear'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        bindings=[(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]
        if bindings!=[('CaelumClothingPickup',f'WC{i}',i) for i in range(11,16)]:errors.append('Unexpected headwear catalogue binding')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale editable headwear: '+name)
        for native,original in config['texture_sources'].items():
            blob=(root/original).read_bytes()
            if (root/'src'/native).read_bytes()!=blob or (source/'editable/src'/native).read_bytes()!=blob:errors.append('Original headwear pixels changed: '+native)
        for name,material in config['materials'].items():
            left,top,right,bottom=material['rect_pixels']
            with Image.open(root/'src'/material['texture']) as picture:
                if picture.size!=tuple(material['image_size']):errors.append('Incorrect image dimensions: '+name)
                if picture.convert('RGBA').getchannel('A').crop((left-1,top-1,right+1,bottom+1)).getextrema()[0]<250:errors.append('Transparent UV crop or sampling margin: '+name)
        for name,item in config['variants'].items():
            record=report['variants'][name];bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            if any(bounds['max'][axis]-bounds['min'][axis]>ref[index+2]-ref[index]+1/32 for axis,index in ((0,0),(2,1))):errors.append('Headwear exceeds original sprite envelope: '+name)
            if bounds['max'][1]-bounds['min'][1]<=1:errors.append('Headwear lacks physical depth: '+name)
            vertices=[];parts=defaultdict(list);part=None
            for line in (source/'editable'/(name+'.obj')).read_text().splitlines():
                values=line.split()
                if not values:continue
                if values[0]=='v':vertices.append(tuple(map(float,values[1:])))
                elif values[0]=='g':part=values[1]
                elif values[0]=='f':parts[part].append([vertices[int(v.split('/')[0])-1] for v in values[1:]])
            if set(parts)!={p['part'] for p in config['families'][item['family']]['parts']}:errors.append('Missing separate headwear component: '+name)
            for part,triangles in parts.items():
                edges=defaultdict(int);winding=defaultdict(int);volume=0
                for points in triangles:
                    a,b,c=points
                    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                    for a,b in zip(points,points[1:]+points[:1]):
                        edge=tuple(sorted((a,b)));edges[edge]+=1;winding[edge]+=1 if a<b else -1
                if volume<=0 or any(v!=2 for v in edges.values()) or any(winding.values()):errors.append('Open/inward component: '+name+'/'+part)
            # A vertical ray through the head opening must reach the inner roof,
            # not a disk closing the base. OBJ uses Y up and Z depth.
            hits=[]
            for a,b,c in parts['hollow_crown_and_rim']:
                denominator=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
                if abs(denominator)<1e-10:continue
                u=((b[2]-c[2])*(-c[0])+(c[0]-b[0])*(-c[2]))/denominator
                v=((c[2]-a[2])*(-c[0])+(a[0]-c[0])*(-c[2]))/denominator
                if min(u,v,1-u-v)>=-1e-7:hits.append(u*a[1]+v*b[1]+(1-u-v)*c[1])
            if not hits or min(hits)<bounds['max'][2]*.5:errors.append('Missing open underside and deep crown cavity: '+name)
            # Compare patch vertices with the actual triangulated outer crown,
            # independently of the profile used to construct each patch.
            for part,triangles in parts.items():
                if not part.startswith('sewn_patch_'):continue
                distances=[]
                for point in set(p for triangle in triangles for p in triangle):
                    intersections=[]
                    for a,b,c in parts['hollow_crown_and_rim']:
                        denominator=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
                        if abs(denominator)<1e-10:continue
                        u=((b[1]-c[1])*(point[0]-c[0])+(c[0]-b[0])*(point[1]-c[1]))/denominator
                        v=((c[1]-a[1])*(point[0]-c[0])+(a[0]-c[0])*(point[1]-c[1]))/denominator
                        if min(u,v,1-u-v)>=-1e-7:intersections.append(u*a[2]+v*b[2]+(1-u-v)*c[2])
                    if not intersections:errors.append('Patch extends beyond crown: '+name+'/'+part);continue
                    distances.append(point[2]-max(intersections))
                shape=next(p for p in config['families'][item['family']]['parts'] if p['part']==part)
                shell=config['families'][item['family']]['parts'][0]
                art_width=max(2*r[3] for r in shell['rows'])
                thickness=shape['depth']*(bounds['max'][0]-bounds['min'][0])/art_width
                if not distances or not min(distances)<0<max(distances) or max(abs(d) for d in distances)>thickness:
                    errors.append('Patch does not sit against and intersect crown: '+name+'/'+part)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
