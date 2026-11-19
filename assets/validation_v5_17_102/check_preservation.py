"""Verify the review release and opt-in overlay retain all production content."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
sha=lambda b:hashlib.sha256(b).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','baseline','overlay','repeat','output'):p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();inventory=json.loads((ROOT/'assets/source/art/sewer_material_847/INVENTORY.json').read_text(encoding='utf-8'))
    with zipfile.ZipFile(a.baseline) as before,zipfile.ZipFile(a.runtime) as after:
        assert before.namelist()==after.namelist()
        changed=[n for n in before.namelist() if before.read(n)!=after.read(n)]
        assert changed==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        assert all(before.read(n).replace(b'[Caelum 5.17.101]',b'[Caelum 5.17.102]')==after.read(n) for n in changed)
        for name in after.namelist():assert after.read(name)==(ROOT/'src'/name).read_bytes(),name
        members=len(after.namelist())
    assert a.overlay.read_bytes()==a.repeat.read_bytes()
    with zipfile.ZipFile(a.overlay) as overlay:
        assert set(overlay.namelist())=={'TEXTURES','graphics/caelum/review847/brick-v1.png'}
        assert overlay.read('graphics/caelum/review847/brick-v1.png')==(ROOT/'assets/source/art/sewer_material_847/brick-v1.png').read_bytes()
        assert sha(overlay.read('graphics/caelum/review847/brick-v1.png'))==inventory['wall']['sha256']
    for row in inventory['map_consumers']:assert sha((ROOT/'src/maps'/row['map']).read_bytes())==row['sha256'],row['map']
    report=dict(issue=847,passed=True,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sha256=sha(a.baseline.read_bytes()),overlay_sha256=sha(a.overlay.read_bytes()),members=members,changed=changed,only_release_diagnostics=True,overlay_deterministic=True,source_image_exact=True,all_map_bytes_preserved=True,geometry_and_gameplay_unchanged=True)
    a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(report))

if __name__=='__main__':main()
