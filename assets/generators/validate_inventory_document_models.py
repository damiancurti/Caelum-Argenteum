"""Check the six document/supply bindings, five native meshes and owned sources."""
import json
try:
    from .validate_inventory_ammunition_models import ROOT, validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT, validate as validate_family

def validate(root=ROOT):
    return validate_family(root, 'documents', 6)

if __name__ == '__main__':
    errors=validate()
    print(json.dumps({'errors':errors}))
    raise SystemExit(bool(errors))
