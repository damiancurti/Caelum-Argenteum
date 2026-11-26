"""Read-only furniture source, complete assembly and exact export validation."""
import json
try:
    from .generate_inventory_furniture_models import ROOT,output_files
except ImportError:
    from generate_inventory_furniture_models import ROOT,output_files

def validate(root=ROOT):
    errors=[]
    try:
        source=root/'assets/source/art/inventory_models_647/furniture'
        for name,blob in output_files(root).items():
            path=source/('EXPORT.json' if name=='manifest.json' else name) if name=='manifest.json' or name.startswith('editable/') else root/'src'/name
            if not path.is_file() or path.read_bytes()!=blob:errors.append('Stale original geometry/UVs/materials/export: '+name)
        if (root/'src/MODELDEF').read_text().count('#include "caelum/data/inventory_furniture.modeldef"')!=1:errors.append('Expected one furniture drop include')
    except (OSError,KeyError,ValueError,IndexError) as exc:errors.append(str(exc))
    return ['Furniture inventory models: '+message for message in errors]
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
