"""Check nine assembly drops using the shared independent serialized geometry inspector."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def validate(root=ROOT):
    errors=validate_family(root,'assembly_components',9,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/assembly_components';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        ids=[25,26,27,30,31,32,33,34,35]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup',f'M{n:03}',n) for n in ids]:errors.append('Unexpected assembly-component world bindings')
        if config['runtime_cases']!=[dict(item_type=n,tier=t) for n in ids for t in [1,2,3]]:errors.append('Changed assembly-component type/tier cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque assembly-component material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind,'assembly_components');errors.extend(kind+': '+e for e in more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k,'assembly_components')[1] for k in ['hilt','long_hilt','point','bowstring','reinforced_bowstring','strap','reinforced_strap','barrel','mechanism']}
    print(json.dumps(dict(errors=errors,geometry=stats)));raise SystemExit(bool(errors))
