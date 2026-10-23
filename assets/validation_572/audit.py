"""Check authored source/model invariants and byte-stable generation for #405."""
from pathlib import Path
import hashlib,json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    data=json.loads((ROOT/'assets/generators/land_resources.json').read_text(encoding='utf-8'))
    assert sorted(data['new_material_ids'].values())==list(range(81,87))
    positions=data['placements'];assert len({p['id'] for p in positions})==11
    assert sum(p['map']=='MAP01' and p['decorative'] for p in positions)==4
    assert sum(p['map']=='MAP03' and not p['decorative'] for p in positions)==7
    paths=[ROOT/p for p in ['src/caelum/data/CaelumLandResourceData.zs','src/caelum/world/CaelumLandSourceProfiles.zs','src/LANGUAGE','src/caelum/data/land_resources.modeldef','src/caelum/data/land_resources.textures','assets/generators/land_resource_models.json']]
    paths+=sorted((ROOT/'src/models/caelum/world/land_resources').glob('*.obj'))
    before={str(p.relative_to(ROOT)):digest(p) for p in paths}
    for script in ['generate_land_resources.py','generate_land_resource_models.py']:
        subprocess.run([sys.executable,str(ROOT/'assets/generators'/script)],cwd=ROOT,check=True,capture_output=True)
    after={str(p.relative_to(ROOT)):digest(p) for p in paths};assert before==after,'Generator output changed'
    manifest=json.loads((ROOT/'assets/generators/land_resource_models.json').read_text())
    assert len(manifest['models'])==14
    for texture in manifest['textures']:assert (ROOT/'src'/texture).is_file()
    for row in manifest['models']:
        obj=(ROOT/'src/models/caelum/world/land_resources'/row['file']).read_text()
        vertices=[list(map(float,line.split()[1:])) for line in obj.splitlines() if line.startswith('v ')]
        assert all(max(v[i] for v in vertices)>min(v[i] for v in vertices) for i in range(3)),row
    registry=(ROOT/'src/caelum/equipment/CaelumSpecialItems.zs').read_text(encoding='utf-8')
    assert all(f'M{i:03d} A 0;' in registry for i in range(81,87))
    constants=(ROOT/'src/caelum/core/CaelumConstants.zs').read_text(encoding='utf-8')
    assert 'MATERIAL_TYPE_COUNT = 87;' in constants
    assert 'MATERIAL_COTTON = 72;' in constants and 'MATERIAL_CARBINE_KIT = 79;' in constants
    changed=subprocess.check_output(['git','diff','b425c0aa','--name-only','--','src/maps'],cwd=ROOT,text=True)
    assert not changed.strip(),'Campaign WAD geometry must stay untouched'
    report={'issue':405,'version':'5.7.2','deterministic_files':after,'models':manifest['models'],'placements':positions,'campaign_wads_unchanged':True}
    (HERE/'audit.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'#405 static audit passed: {len(paths)} byte-stable generated files, 14 volumetric models, 11 approved placements.')
if __name__=='__main__':main()
