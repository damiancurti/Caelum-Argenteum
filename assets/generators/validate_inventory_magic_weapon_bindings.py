"""Verify exact staff, bell and support-statuette reuse without changing item rules."""
import json
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def validate(root=ROOT):
    errors=validate_family(root,'magic_weapons',6,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/magic_weapons';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        original=json.loads((root/config['source_export']).read_text());expected=[]
        if [(k,v['item_type'],v['sprite']) for k,v in config['variants'].items()]!=[('staff',1,'CSTF'),('bell',17,'CBEL'),('statuette',25,'CSTA')]:errors.append('Unexpected weapon identities or sprites')
        cases=[]
        for key,item in config['variants'].items():
            record=dict(original['variants'][key]);record['class']='CaelumWeaponPickup'
            if report['variants'][key]!=record:errors.append('Changed reused geometry record: '+key)
            for kind in ['CaelumWeaponPickup','CA_LimboMagicImplement']:
                expected.append(f'Model {kind} {{ Path "models/caelum/inventory/magic_bases" Model 0 "{key}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}\n')
                cases.extend(dict(actor_class=kind,item_type=item['item_type'],tier=t,essence=item['essence']) for t in [1,2,3])
        if (root/'src/caelum/data/inventory_magic_weapons.modeldef').read_text()!=''.join(expected):errors.append('Unexpected exact binding, model or scale')
        if config['runtime_cases']!=cases:errors.append('Changed eighteen native case identities')
        if '#include "caelum/data/support_implements.modeldef"' in (root/'src/MODELDEF').read_text():errors.append('Rejected legacy models activated')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps(dict(errors=errors)));raise SystemExit(bool(errors))
