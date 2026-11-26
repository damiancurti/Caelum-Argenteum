"""Check the owned Cuyo material against the shared authoritative gallery."""
from pathlib import Path
import json
try:
    from .validate_regional_materials import validate as shared_validate
except ImportError:
    from validate_regional_materials import validate as shared_validate
ROOT=Path(__file__).resolve().parents[2]

def validate(root=ROOT):
    errors=shared_validate(root,issue=700)
    try:
        inventory=json.loads((root/'assets/source/art/regional_gallery_700/INVENTORY.json').read_text())
        assert inventory['gallery_source']=='assets/source/art/regional_gallery_682/GALLERY.json'
        assert inventory['gallery_map']=='CA682G'
        assert [(x['key'],x['texture']) for x in inventory['gaps']]==[('cuyo_ground','CRCUYGR')]
        gallery=json.loads((root/inventory['gallery_source']).read_text())
        assert len(gallery['subjects'])==10 and len(gallery['plots'])==5
        assert [v['key'] for v in gallery['views']]==['F'+str(i) for i in range(1,13)]+['1','2','3','4']
    except (OSError,KeyError,ValueError,AssertionError) as exc:errors.append('Cuyo material/gallery contract: '+str(exc))
    return errors

if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
