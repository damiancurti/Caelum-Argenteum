"""Check the seven existing metal identities and their original opaque shaders."""
import json
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT, validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT, validate as validate_family

def validate(root=ROOT):
    errors=validate_family(root,'ingots',7,False)
    try:
        config=json.loads((root/'assets/source/art/inventory_models_647/ingots/DESIGN.json').read_text())
        for name,material in config['materials'].items():
            alpha=Image.open(root/'src'/material['texture']).convert('RGBA').getchannel('A')
            left,top,right,bottom=material['rect_pixels']
            if min(alpha.crop((left-1,top-1,right+1,bottom+1)).get_flattened_data())<250:
                errors.append('Ingot shader patch is not opaque: '+name)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors

if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
