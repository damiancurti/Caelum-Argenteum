"""Verify native camp bindings, original selected geometry and owned pixels."""
from pathlib import Path
import hashlib
import json
import re
try:
    from .generate_inventory_camp_models import ROOT, read_obj
except ImportError:
    from generate_inventory_camp_models import ROOT, read_obj

def validate(root=ROOT):
    errors=[]
    try:
        source=root/'assets/source/art/inventory_models_647/camp'
        config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        for name,checksum in config['source_sha256'].items():
            if hashlib.sha256((root/name).read_bytes()).hexdigest()!=checksum:errors.append('Original camp resource changed: '+name)
        if hashlib.sha256(Path(__file__).with_name('generate_inventory_camp_models.py').read_bytes()).hexdigest()!=report['generator_sha256']:errors.append('Stale camp generator hash')
        for name,checksum in report['source_sha256'].items():
            if hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale camp source: '+name)
        for name,checksum in report['sha256'].items():
            path=source/name if name.startswith('editable/') else root/'src'/name
            if hashlib.sha256(path.read_bytes()).hexdigest()!=checksum:errors.append('Stale camp export: '+name)
        definition=(root/'src/caelum/data/inventory_camp.modeldef').read_text()
        expected=[(item['class'],item['sprite']) for item in config['variants'].values()]
        actual=re.findall(r'\bModel\s+(\w+)\s*\{[^}]*FrameIndex\s+(\w+)\s+A\s+0\s+0',definition)
        if actual!=expected:errors.append('Camp drop binding identity changed')
        if (root/'src/MODELDEF').read_text().count('#include "caelum/data/inventory_camp.modeldef"')!=1:errors.append('Expected one camp drop include')
        for key,item in config['variants'].items():
            original=read_obj((root/item['source_obj']).read_bytes(),item.get('selected_materials'))
            if item['extract']:
                extracted=read_obj((root/'src'/item['runtime_model']).read_bytes())
                if original!=extracted:errors.append('Selected original geometry/UVs changed: '+key)
            record=report['variants'][key];bounds=record['source_obj_bounds']
            expected_scale=min(record['target_art_extent']/max(bounds['max'][i]-bounds['min'][i] for i in (0,2)),record['target_art_height']/(bounds['max'][1]-bounds['min'][1]))
            if abs(record['modeldef_scale']-expected_scale)>1e-10:errors.append('Camp sprite fitting changed: '+key)
        for index,material in enumerate(sorted(config['materials'])):
            if (source/f'editable/materials/material_{index}.png').read_bytes()!=(root/'src'/material).read_bytes():errors.append('Original material pixels changed: '+material)
    except (OSError,KeyError,ValueError,IndexError) as exc:errors.append(str(exc))
    return ['Camp inventory models: '+message for message in errors]
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
