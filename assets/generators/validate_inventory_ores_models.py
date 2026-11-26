"""Validate all six closed raw-material props and their existing native states."""
import json
from PIL import Image
try:
    from .validate_inventory_gems_models import ROOT,validate as shared_validate
except ImportError:
    from validate_inventory_gems_models import ROOT,validate as shared_validate
def cross(a,b,p):return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
def area(poly):return sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(poly,poly[1:]+poly[:1]))/2
def section(part,depth):
    rows=sorted(part['profile'])
    for a,b in zip(rows,rows[1:]):
        if a[0]<=depth<=b[0]:
            factor=a[1]+(b[1]-a[1])*(depth-a[0])/(b[0]-a[0])
            x,y=part['center'];poly=[(x+u*factor,-y+v*factor) for u,v in part['outline']]
            if area(poly)<0:poly.reverse()
            return poly
    return []
def intersection(subject,clip):
    for a,b in zip(clip,clip[1:]+clip[:1]):
        result=[]
        for previous,current in zip(subject[-1:]+subject[:-1],subject):
            before=cross(a,b,previous);after=cross(a,b,current)
            if (before>=0)!=(after>=0):
                fraction=before/(before-after)
                result.append(tuple(p+(q-p)*fraction for p,q in zip(previous,current)))
            if after>=0:result.append(current)
        subject=result
        if not subject:break
    return subject
def connection_witness(core,rock):
    depths=sorted({row[0] for part in (core,rock) for row in part['profile']})
    for depth in depths+[(a+b)/2 for a,b in zip(depths,depths[1:])]:
        first=section(core,depth);second=section(rock,depth)
        if not first or not second:continue
        common=intersection(first,second)
        if common and area(common)>0.01:
            return [sum(v[0] for v in common)/len(common),depth,sum(v[1] for v in common)/len(common)]
    return None
def validate(root=ROOT):
    errors=shared_validate(root,'ores',tuple(range(61,67)),())
    try:
        config=json.loads((root/'assets/source/art/inventory_models_647/ores/DESIGN.json').read_text())
        for name,item in config['variants'].items():
            core=item['parts'][0]
            if core['part']!='connected_ore_core':errors.append('Missing ore core: '+name)
            for rock in item['parts'][1:]:
                if not rock.get('undercoat') and connection_witness(core,rock) is None:
                    errors.append('Disconnected ore fragment: '+name+'/'+rock['part'])
            settings=config['materials'][item['metal']]
            with Image.open(root/'src'/settings['texture']) as texture:
                if texture.convert('RGBA').getchannel('A').crop(tuple(settings['rect_pixels'])).getextrema()[0]<250:
                    errors.append('Transparent ore core sample: '+name)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
