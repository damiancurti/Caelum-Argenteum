"""Check exact original book reuse for support and material inventory states."""
import json
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family


def validate(root=ROOT):
    errors=validate_family(root,'books',3)
    try:
        source=root/'assets/source/art/inventory_models_647/books';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        original=json.loads((root/config['source_export']).read_text());record=dict(original['variants']['book']);record['class']='CaelumWeaponPickup'
        if report['variants']['book']!=record:errors.append('Reused book geometry differs from its original export')
        expected=''.join('Model '+kind+' { Path "models/caelum/inventory/documents" Model 0 "book.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex CBOO A 0 0 }\n' for kind in ('CaelumWeaponPickup','CA_LimboMagicImplement','CaelumMaterialPickup'))
        if (root/'src/caelum/data/inventory_books.modeldef').read_text()!=expected:errors.append('Unexpected book bindings, model or scale')
        if '#include "caelum/data/support_implements.modeldef"' in (root/'src/MODELDEF').read_text():errors.append('Rejected legacy implement models must remain inactive')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
