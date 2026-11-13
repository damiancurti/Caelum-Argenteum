"""Check both native ration bindings, closed components and original materials."""
import json
import hashlib
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
def validate(root=ROOT):
    errors=validate_family(root,'waterskin',2)
    try:
        source=root/'assets/source/art/inventory_models_647/waterskin'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable waterskin geometry: '+name)
        for material in config['materials'].values():
            if (source/'editable/src'/material['texture']).read_bytes()!=(root/'src'/material['texture']).read_bytes():errors.append('Original portable waterskin texture changed')
        dark=config['materials']['dark'];left,top,right,bottom=dark['rect_pixels']
        with Image.open(root/'src'/dark['texture']) as picture:
            if picture.convert('RGBA').getchannel('A').crop((left-1,top-1,right+1,bottom+1)).getextrema()[0]<250:errors.append('Cup interior UV margin includes transparent pixels')
        record=report['variants']['waterskin'];bounds=record['native_bounds'][0];ref=record['reference_opaque_bounds']
        if bounds['max'][0]-bounds['min'][0]>ref[2]-ref[0]+1/32 or bounds['max'][2]-bounds['min'][2]>ref[3]-ref[1]+1/32:errors.append('Waterskin exceeds its original sprite envelope')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
