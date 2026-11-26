"""Verify generator determinism, exact scope and final package source identity."""
from pathlib import Path
import hashlib,importlib.util,json,subprocess,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');public=root/'assets/validation_v5_17_107'
spec=importlib.util.spec_from_file_location('bindings',public/'prepare_wardrobe_data857.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
first=module.generate();second=module.generate();assert first==second
for name,content in zip(['CaelumWornClothingModelData.zs','wardrobe_candidate.modeldef'],first[:2]):assert (root/'src/caelum/data'/name).read_text(encoding='utf-8')==content
runtime=root/'build/issue857-wardrobe02.pk3';baseline=root/'build/issue855-navigation02.pk3'
sha=lambda data:hashlib.sha256(data).hexdigest()
expected={'CVARINFO','MODELDEF','caelum/character/CaelumDomingoPilot.zs','caelum/equipment/CaelumInventoryService.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
new={'caelum/character/CaelumWardrobePilot.zs','caelum/data/CaelumWornClothingModelData.zs','caelum/data/wardrobe_candidate.modeldef'}
with zipfile.ZipFile(runtime) as final,zipfile.ZipFile(baseline) as old,zipfile.ZipFile(root/'build/issue857-prototype06/prototype.pk3') as prototype:
    assert set(final.namelist())-set(old.namelist())==new
    assert not set(old.namelist())-set(final.namelist())
    changed={name for name in old.namelist() if final.read(name)!=old.read(name)};assert changed==expected,changed
    for name in final.namelist():assert final.read(name)==(root/'src'/name).read_bytes(),name
    for name in prototype.namelist():
        if name not in ('CVARINFO','MODELDEF'):assert prototype.read(name)==final.read(name),name
    members=len(final.namelist())
report=dict(issue=857,passed=True,runtime_sha256=sha(runtime.read_bytes()),baseline_sha256=sha(baseline.read_bytes()),members=members,changed=sorted(changed),added=sorted(new),deterministic_binding_generation=True,existing_geometry_textures_exact=True,prototype_gameplay_exact=True,scope='Native equipment-driven candidate only. Visual attachment defect is explicitly tracked in #859; not author acceptance.',binding_sources=first[2])
(root/'build/issue857-scope.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
