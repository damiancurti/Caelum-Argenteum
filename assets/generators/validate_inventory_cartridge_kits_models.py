"""Check two cartridge-kit drops using the shared independent serialized geometry inspector."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def inspect_planar_uv(root=ROOT):
    source=root/'assets/source/art/inventory_models_647/cartridge_kits'
    config=json.loads((source/'DESIGN.json').read_text());errors=[];checked=0
    for kind,family in config['families'].items():
        required={p['part'] for p in family['parts'] if p.get('planar_uv') or p['kind']=='bevel'}
        coords=[];group=None
        for line in (source/'editable'/(kind+'.obj')).read_text().splitlines():
            row=line.split()
            if not row:continue
            if row[0]=='vt':coords.append(tuple(map(float,row[1:])))
            elif row[0]=='g':group=row[1]
            elif row[0]=='f' and group in required:
                a,b,c=[coords[int(v.split('/')[1])-1] for v in row[1:]]
                if abs((b[0]-a[0])*(c[1]-a[1])-(c[0]-a[0])*(b[1]-a[1]))<1e-12:errors.append('Collapsed projected UV '+kind+'/'+group)
                checked+=1
    if not checked:errors.append('Missing projected surfaces')
    return errors,checked


def validate(root=ROOT):
    errors=validate_family(root,'cartridge_kits',2,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/cartridge_kits';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        ids=[79,80]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup',f'M{n:03}',n) for n in ids]:errors.append('Unexpected cartridge-kit world bindings')
        if config['runtime_cases']!=[dict(item_type=n,tier=t) for n in ids for t in [1]]:errors.append('Changed cartridge-kit type/tier cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque cartridge-kit material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind,'cartridge_kits');errors.extend(kind+': '+e for e in more)
        more,_=inspect_planar_uv(root);errors.extend(more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k,'cartridge_kits')[1] for k in ['carbine_kit','shotgun_kit']}
    print(json.dumps(dict(errors=errors,geometry=stats,noncollapsed_projected_uv_triangles=inspect_planar_uv()[1])));raise SystemExit(bool(errors))
