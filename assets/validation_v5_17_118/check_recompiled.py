"""Verify the facade render bound without replacing any installed map/model."""
from pathlib import Path
import argparse,hashlib,json,math,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from install_barracas_map import sources
SHA=lambda b:hashlib.sha256(b).hexdigest()
p=argparse.ArgumentParser(description=__doc__)
for n in ['compiled','baseline-manifest','output']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();baseline=json.loads(a.baseline_manifest.read_text(encoding='utf-8'))
with zipfile.ZipFile(a.compiled/'preview.pk3') as z:
    assert set(z.namelist())=={'ZSCRIPT','MAPINFO','MODELDEF','maps/MAP03.wad','models/house-960-1216.obj'}
    code=z.read('ZSCRIPT');assert code.startswith(b'version "4.14.2"\n')
    generated={
        'assets/barracas_redesign/BASE_MAP03.wad':z.read('maps/MAP03.wad'),
        'src/caelum/world/CaelumBarracasFacades.zs':code.split(b'\n',1)[1]+b'\n',
        'src/caelum/data/barracas_facades.mapinfo':z.read('MAPINFO'),
        'src/caelum/data/barracas_facades.modeldef':z.read('MODELDEF').replace(b'Path "models"',b'Path "models/caelum/architecture/barracas"')+b'\n',
        'src/models/caelum/architecture/barracas/house-960-1216.obj':z.read('models/house-960-1216.obj')}
model=generated['src/models/caelum/architecture/barracas/house-960-1216.obj']
vertices=[tuple(map(float,line.split()[1:])) for line in model.decode().splitlines() if line.startswith('v ')]
raw=max(math.hypot(v[0],v[2]) for v in vertices);radius=math.ceil(raw)
assert radius==781
name='src/caelum/world/CaelumBarracasFacades.zs';needle=f' RenderRadius {radius};'.encode()
assert generated[name].count(needle)==1
assert SHA(generated[name].replace(needle,b''))==baseline['files_sha256'][name]
for n,b in generated.items():
    assert (ROOT/n).read_bytes()==b,n
    if n!=name:assert SHA(b)==baseline['files_sha256'][n],n
assert SHA((ROOT/'src/maps/MAP03.wad').read_bytes())==baseline['files_sha256']['src/maps/MAP03.wad']
current=sources(ROOT)
changed=[n for n,h in current.items() if baseline['source_sha256'].get(n)!=h]
assert set(current)==set(baseline['source_sha256'])
assert sorted(changed)==['assets/generators/generate_barracas_facades.py','assets/generators/generate_barracas_preview.py']
result=dict(issue=879,passed=True,raw_horizontal_radius=raw,render_radius=radius,vertices=len(vertices),geometry_revision=4,
    original_model_sha256=SHA(model),base_map_sha256=SHA(generated['assets/barracas_redesign/BASE_MAP03.wad']),
    installed_map_sha256=baseline['files_sha256']['src/maps/MAP03.wad'],
    original_actor_sha256=baseline['files_sha256'][name],updated_actor_sha256=SHA(generated[name]),
    class_only_change=needle.decode().strip(),source_changes=changed,
    generated_members={n:SHA(b) for n,b in generated.items()},source_sha256=current,
    qualification='Full current base-map recompilation is byte-identical to the installed original. Source model and bindings are exact. Only the derived native render-bound property differs in the generated actor. No production map is reinstalled or save schema added.')
a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:result[k] for k in ['passed','raw_horizontal_radius','render_radius','vertices','class_only_change','source_changes']}))
