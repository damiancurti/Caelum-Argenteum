"""Verify #866 source provenance, deterministic overlays and production isolation."""
from pathlib import Path
import argparse
import hashlib
import json
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from build_environment_remaster_review import audit

sha=lambda b:hashlib.sha256(b).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','baseline','overlay','repeat','output'):
        parser.add_argument('--'+name,type=Path,required=True)
    a=parser.parse_args();inventory=audit()
    with zipfile.ZipFile(a.baseline) as before,zipfile.ZipFile(a.runtime) as after:
        assert before.namelist()==after.namelist()
        changed=[n for n in before.namelist() if before.read(n)!=after.read(n)]
        assert changed==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        assert all(before.read(n).replace(b'[Caelum 5.17.110]',b'[Caelum 5.17.111]')==after.read(n) for n in changed)
        for name in after.namelist():
            assert after.read(name)==(ROOT/'src'/name).read_bytes(),name
        members=len(after.namelist())
    assert a.overlay.read_bytes()==a.repeat.read_bytes()
    source=ROOT/'assets/source/art/environment_remasters_866'
    with zipfile.ZipFile(a.overlay) as package:
        expected={'TEXTURES':(source/'TEXTURES_MEJORAS_V3.txt').read_bytes()}
        for row in inventory['exports']:
            expected['graphics/caelum/textures/entornos_v1/mejoradas/'+Path(row['file']).name]=(source/row['file']).read_bytes()
        assert set(package.namelist())==set(expected)
        assert all(package.read(n)==data for n,data in expected.items())
    reference_matches={p.name:p.read_bytes()==(ROOT/'src/graphics/caelum/textures/mansion'/p.name).read_bytes() for p in (source/'references').glob('*.png')}
    report=dict(issue=866,passed=True,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sha256=sha(a.baseline.read_bytes()),overlay_sha256=sha(a.overlay.read_bytes()),runtime_members=members,changed=changed,only_release_diagnostics=True,overlay_members=len(expected),overlay_deterministic=True,source_files_verified=inventory['source_files_verified'],reference_matches_current_png=reference_matches,all_map_bytes_preserved=True,production_art_models_light_collision_gameplay_saves_unchanged=True)
    with a.output.open('x',encoding='utf-8',newline='\n') as stream:stream.write(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__=='__main__':main()
