"""Check exact original key-model reuse for the native lock inventory class."""
import json
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
def validate(root=ROOT):
    errors=validate_family(root,'locks',1)
    try:
        source=root/'assets/source/art/inventory_models_647/locks';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        original=json.loads((root/config['source_export']).read_text());record=dict(original['variants']['key']);record['class']='CaelumLockItem'
        if report['variants']['key']!=record:errors.append('Reused key geometry record differs from original export')
        expected='Model CaelumLockItem { Path "models/caelum/inventory/documents" Model 0 "key.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex CKEY A 0 0 }\n'
        if (root/'src/caelum/data/inventory_locks.modeldef').read_text()!=expected:errors.append('Unexpected lock model binding or scale')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
