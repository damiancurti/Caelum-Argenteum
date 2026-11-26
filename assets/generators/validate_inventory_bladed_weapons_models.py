"""Verify original blade assemblies, exact drop states and unchanged gameplay sources."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def validate(root=ROOT):
    errors=validate_family(root,'bladed_weapons',6,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/bladed_weapons';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        identities=[(0,'CSWD'),(3,'CDAG'),(5,'CMAC'),(10,'CGRS')]
        if [(v['item_type'],v['sprite']) for v in config['variants'].values()]!=identities:errors.append('Unexpected physical blade identities')
        expected=[]
        for key,item in config['variants'].items():
            for binding in [item,*item.get('additional_bindings',[])]:
                expected.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}\n')
            more,_=inspect_geometry(root,key,'bladed_weapons');errors.extend(key+': '+v for v in more)
        if (root/'src/caelum/data/inventory_bladed_weapons.modeldef').read_text()!=''.join(expected):errors.append('Unexpected class, state, model or scale')
        cases=[dict(actor_class='CaelumWeaponPickup',item_type=n,tier=t,essence=0,sprite=s) for n,s in identities for t in [1,2,3]]
        cases += [dict(actor_class='CA_LimboRonnieSword',item_type=0,tier=t,essence=0,sprite='CSWD') for t in [1,2,3]]+[dict(actor_class='CaelumM01SwordPickup',item_type=0,tier=1,essence=0,sprite='CSWD')]
        if config['runtime_cases']!=cases:errors.append('Changed sixteen native cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Changed editable source: '+name)
        for settings in config['materials'].values():
            path=settings['texture'];image=Image.open(root/'src'/path).convert('RGBA');a,b,c,d=settings['rect_pixels']
            if (source/'editable/src'/path).read_bytes()!=(root/'src'/path).read_bytes():errors.append('Changed portable texture: '+path)
            if image.getchannel('A').crop((max(0,a-1),max(0,b-1),min(image.width,c+1),min(image.height,d+1))).getextrema()!=(255,255):errors.append('Transparent blade material')
        for key in config['variants']:
            blob=(root/'src'/config['model_path']/(key+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10]
            for _ in range(head[6]):
                h=struct.unpack_from('<4s64s10I',blob,offset);uv=[struct.unpack_from('<2f',blob,offset+h[9]+i*8) for i in range(h[5])]
                for i in range(h[6]):
                    a,b,c=[uv[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12)]
                    if abs((b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0]))<1e-12:errors.append('Collapsed native UV triangle: '+key)
                offset+=h[-1]
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();names=['sword','dagger','machete','greatsword']
    print(json.dumps(dict(errors=errors,geometry={k:inspect_geometry(ROOT,k,'bladed_weapons')[1] for k in names})));raise SystemExit(bool(errors))
