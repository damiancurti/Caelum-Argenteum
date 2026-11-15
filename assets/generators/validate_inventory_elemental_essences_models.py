"""Verify five elemental material meshes, fifteen tier cases and native triangles."""
from collections import Counter
import json,struct
from PIL import Image
try:
    from .validate_inventory_gems_models import ROOT,validate as validate_gems
except ImportError:
    from validate_inventory_gems_models import ROOT,validate as validate_gems


def inspect_native(root=ROOT):
    source=root/'assets/source/art/inventory_models_647/elemental_essences'
    config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text());errors=[];stats={}
    for kind,item in config['variants'].items():
        points=[];expected=Counter();parts={};group=None
        for line in (source/'editable'/(kind+'.obj')).read_text().splitlines():
            row=line.split()
            if not row:continue
            if row[0]=='v':points.append(tuple(map(float,row[1:])))
            elif row[0]=='g':group=row[1];parts.setdefault(group,[])
            elif row[0]=='f':
                tri=tuple(int(v.split('/')[0])-1 for v in row[1:]);parts[group].append(tri)
                native=tuple(tuple(round(v*64) for v in (points[i][0],-points[i][2],points[i][1])) for i in tri)
                u=[native[1][k]-native[0][k] for k in range(3)];v=[native[2][k]-native[0][k] for k in range(3)]
                if not any([u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]):errors.append('Collapsed quantized triangle '+kind+'/'+group)
                expected[native]+=1
        for p in item['parts']:
            faces=parts[p['part']];vertices={points[i] for f in faces for i in f};edges={tuple(sorted((points[f[a]],points[f[b]]))) for f in faces for a,b in [(0,1),(1,2),(2,0)]}
            if len(vertices)-len(edges)+len(faces)!=2-2*p.get('genus',0):errors.append('Unexpected elemental topology '+kind+'/'+p['part'])
        blob=(root/'src'/config['model_path']/(kind+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10];actual=Counter()
        for _ in range(head[6]):
            h=struct.unpack_from('<4s64s10I',blob,offset);vertices=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
            for i in range(h[6]):actual[tuple(vertices[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12))]+=1
            offset+=h[-1]
        if actual!=expected:errors.append('Native/editable triangle mismatch '+kind)
        bounds=report['variants'][kind]['native_bounds'][0]
        if abs(bounds['min'][2])>1/64:errors.append('Incorrect grounded origin '+kind)
        stats[kind]=dict(closed_components=len(parts),native_triangles=sum(actual.values()),depth=bounds['max'][1]-bounds['min'][1],orbit_components=sum(p.get('genus',0) for p in item['parts']))
    return errors,stats


def validate(root=ROOT):
    errors=validate_gems(root,'elemental_essences',tuple(range(20,25)),())
    try:
        c=json.loads((root/'assets/source/art/inventory_models_647/elemental_essences/DESIGN.json').read_text())
        if c['runtime_cases']!=[dict(item_type=n,tier=t) for t in [1,2,3] for n in range(20,25)]:errors.append('Changed elemental type/tier cases')
        for name,item in c['variants'].items():
            alpha=Image.open(root/item['reference']).convert('RGBA').getchannel('A')
            for part in item['parts']:
                if 'texture_region' in part:
                    a,b,d,e=part['texture_region']
                    if alpha.crop((a-1,b-1,d+1,e+1)).getextrema()[0]<250:errors.append('Transparent elemental detail region '+name+'/'+part['part'])
        more,_=inspect_native(root);errors.extend(more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps(dict(errors=errors,geometry=inspect_native()[1])));raise SystemExit(bool(errors))
