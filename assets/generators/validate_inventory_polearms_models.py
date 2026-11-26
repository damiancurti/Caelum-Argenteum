"""Verify original polearm assemblies, exact drop states and unchanged gameplay sources."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def validate(root=ROOT):
    errors=validate_family(root,'polearms',4,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/polearms';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        identities=[(6,'CJAV'),(9,'CSPR'),(12,'CHAL'),(21,'CUST')]
        if [(v['item_type'],v['sprite']) for v in config['variants'].values()]!=identities:errors.append('Unexpected physical polearm identities')
        expected=[]
        for key,item in config['variants'].items():
            for binding in [item,*item.get('additional_bindings',[])]:
                expected.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}\n')
            more,_=inspect_geometry(root,key,'polearms');errors.extend(key+': '+v for v in more)
            record=report['variants'][key];bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
            for axis,index in [(0,0),(2,1)]:
                if bounds['max'][axis]-bounds['min'][axis]>(ref[index+2]-ref[index])/item['sprite_scale'][index]+1/32:errors.append('Model exceeds scaled sprite envelope: '+key)
        definitions=(root/'src/TEXTURES').read_text(encoding='utf-8')
        for key in ['javelin','spear','halberd']:
            item=config['variants'][key];path='graphics/caelum/icons/ca_'+key+'.png'
            if item['reference']!='src/'+path or item['sprite_scale']!=[1,1]:errors.append('Changed effective world reference: '+key)
            if not any('Sprite "'+item['sprite']+'A0"' in line and 'Patch "'+path+'", 0, 0' in line for line in definitions.splitlines()):errors.append('Missing authoritative TEXTURES alias: '+key)
        staff=config['variants']['utility_staff']
        if staff['reference_crop']!=[0,0,627,627] or staff['sprite_scale']!=[4.8984375,4.8984375]:errors.append('Changed utility-staff crop or sprite scale')
        if (root/'src/caelum/data/inventory_polearms.modeldef').read_text()!=''.join(expected):errors.append('Unexpected class, state, model or scale')
        cases=[dict(actor_class='CaelumWeaponPickup',item_type=n,tier=t,essence=0,sprite=s) for n,s in identities for t in ([1] if n==21 else [1,2,3])]
        if config['runtime_cases']!=cases:errors.append('Changed ten native cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Changed editable source: '+name)
        for settings in config['materials'].values():
            path=settings['texture'];image=Image.open(root/'src'/path).convert('RGBA');a,b,c,d=settings['rect_pixels']
            if (source/'editable/src'/path).read_bytes()!=(root/'src'/path).read_bytes():errors.append('Changed portable texture: '+path)
            if image.getchannel('A').crop((max(0,a-1),max(0,b-1),min(image.width,c+1),min(image.height,d+1))).getextrema()!=(255,255):errors.append('Transparent polearm material')
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
    errors=validate();names=['javelin','spear','halberd','utility_staff']
    print(json.dumps(dict(errors=errors,geometry={k:inspect_geometry(ROOT,k,'polearms')[1] for k in names})));raise SystemExit(bool(errors))
