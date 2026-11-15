"""Verify exact magical quality bindings, closed geometry and unchanged source assets."""
import hashlib,json,struct
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def validate(root=ROOT):
    errors=validate_family(root,'magic_tiers',12,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/magic_tiers';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        identities=[(18,t,f) for t,f in zip([1,2,3],'ABC')]+[(24,t,f) for t,f in zip([1,2,3],'JKL')]
        if [(v['item_type'],v['quality'],v['frame']) for v in config['variants'].values()]!=identities:errors.append('Unexpected magical quality identities')
        expected=[];cases=[]
        for key,item in config['variants'].items():
            for kind in ['CaelumWeaponPickup','CA_LimboMagicImplement']:
                expected.append(f'Model {kind} {{ Path "{config["model_path"]}" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex S479 {item["frame"]} 0 0 }}\n')
                cases.append(dict(actor_class=kind,item_type=item['item_type'],tier=item['quality'],essence=item['essence']))
            more,_=inspect_geometry(root,key,'magic_tiers');errors.extend(key+': '+v for v in more)
        if (root/'src/caelum/data/inventory_magic_tiers.modeldef').read_text()!=''.join(expected):errors.append('Unexpected class, frame, model or scale')
        if config['runtime_cases']!=cases:errors.append('Changed twelve native cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Changed editable source: '+name)
        for settings in config['materials'].values():
            path=settings['texture'];image=Image.open(root/'src'/path).convert('RGBA');a,b,c,d=settings['rect_pixels']
            if (source/'editable/src'/path).read_bytes()!=(root/'src'/path).read_bytes():errors.append('Changed portable texture: '+path)
            if image.getchannel('A').crop((max(0,a-1),max(0,b-1),min(image.width,c+1),min(image.height,d+1))).getextrema()!=(255,255):errors.append('Transparent source material')
        for key in ['censer','censer_t2','censer_t3']:
            shell=config['families'][key]['parts'][0];regions=shell['surface_regions'];seen=set()
            if shell['kind']!='perforated_shell' or len(shell['holes'])!=48 or shell['genus']!=49:errors.append('Missing censer holes: '+key)
            blob=(root/'src'/config['model_path']/(key+'.md3')).read_bytes();head=struct.unpack_from('<4sI64s9I',blob);offset=head[10]
            for surface in report['variants'][key]['surfaces']:
                h=struct.unpack_from('<4s64s10I',blob,offset)
                if surface['material']=='censer_surface':
                    uv=[struct.unpack_from('<2f',blob,offset+h[9]+i*8) for i in range(h[5])]
                    for i in range(h[6]):
                        points=[uv[k] for k in struct.unpack_from('<3I',blob,offset+h[7]+i*12)]
                        cells=[name for name,(a,b,c,d) in regions.items() if all(a-1e-6<=u<=c+1e-6 and b-1e-6<=v<=d+1e-6 for u,v in points)]
                        if len(cells)!=1:errors.append('Censer UV triangle crosses atlas regions: '+key)
                        seen.update(cells)
                offset+=h[-1]
            if seen!={'inner','outer'}:errors.append('Missing censer interior or exterior: '+key)
        if '#include "caelum/data/support_implements.modeldef"' in (root/'src/MODELDEF').read_text():errors.append('Rejected procedural support models activated')
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();names=['scepter','scepter_t2','scepter_t3','censer','censer_t2','censer_t3']
    print(json.dumps(dict(errors=errors,geometry={k:inspect_geometry(ROOT,k,'magic_tiers')[1] for k in names})));raise SystemExit(bool(errors))
