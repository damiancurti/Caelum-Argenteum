"""Check serialized hygiene solids, rooted contacts and the open jar mouth."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def inspect_soap_uv(root=ROOT):
    path=root/'assets/source/art/inventory_models_647/hygiene/editable/soap.obj'
    coords=[];checked=0;errors=[]
    for line in path.read_text().splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='vt':coords.append(tuple(map(float,row[1:])))
        elif row[0]=='f':
            a,b,c=[coords[int(value.split('/')[1])-1] for value in row[1:]]
            if abs((b[0]-a[0])*(c[1]-a[1])-(c[0]-a[0])*(b[1]-a[1]))<1e-12:errors.append('Collapsed soap surface UV')
            checked+=1
    if not checked:errors.append('Missing soap surface triangles')
    return errors,checked


def validate(root=ROOT):
    errors=validate_family(root,'hygiene',3,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/hygiene';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        ids=[105,106,107]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup',f'M{n:03}',n) for n in ids]:errors.append('Unexpected hygiene world bindings')
        if config['runtime_cases']!=[dict(item_type=n,tier=t) for n in ids for t in [1]]:errors.append('Changed hygiene type/tier cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque hygiene material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind,'hygiene');errors.extend(kind+': '+e for e in more)
        more,_=inspect_soap_uv(root);errors.extend(more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k,'hygiene')[1] for k in ['fat','soda','soap']}
    print(json.dumps(dict(errors=errors,geometry=stats,noncollapsed_soap_uv_triangles=inspect_soap_uv()[1])));raise SystemExit(bool(errors))
