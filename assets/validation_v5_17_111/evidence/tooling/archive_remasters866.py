"""Retain exact text/image evidence for the isolated author material review."""
from pathlib import Path
import json
import re
import shutil

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
dest=root/'assets/validation_v5_17_111';ev=dest/'evidence';ev.mkdir(exist_ok=True)
assert not any(ev.iterdir()),'Evidence already populated; do not overwrite an archive.'
allowed={'.json','.log','.png','.zs','.cfg','.ini','.csv','.py','.txt'}

def copy_tree(source,target,images=True):
    for p in sorted(source.rglob('*')):
        if not p.is_file() or p.suffix.lower() not in allowed or '__pycache__' in p.parts:continue
        if not images and p.suffix.lower()=='.png':continue
        q=target/p.relative_to(source);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)

sets=['lab04','map0102','map0201','map0301','street01'];sizes=places=walks=images=0
for name in sets:
    folder=root/'build'/('issue866-'+name);d=json.loads((folder/'RESULTS.json').read_text());assert d['passed']
    left,right=d['runs'];assert left['passed'] and right['passed']
    for token in (' VIEW ',' WALK '):
        assert [x for x in left['markers'] if token in x]==[x for x in right['markers'] if token in x],(name,token)
    for row in d['runs']:
        size_rows=[x for x in row['markers'] if ' SIZE ' in x];assert len(size_rows)==24
        assert all('scaled=128.000x128.000' in x for x in size_rows)
        # GetSize and GetScaledSize both return display size in4.14.2.
        assert all('raw=128x128' in x or 'display_int=128x128' in x for x in size_rows)
        sizes+=len(size_rows);images+=len(row['images'])
        for x in row['markers']:
            if ' VIEW ' in x:
                room,height=re.search(r'headroom=([\d.]+) height=([\d.]+)',x).groups();assert float(room)>=float(height);places+=1
            if ' WALK ' in x:
                assert 'distance=26.663' in x;walks+=1
    copy_tree(folder,ev/'views'/name)
for name in ('lab01','lab02','lab03','map0101'):
    copy_tree(root/'build'/('issue866-'+name),ev/'attempts'/name,images=False)
scenes=json.loads((root/'build/issue866-performance.json').read_text());assert len(scenes)==10
for row in scenes:copy_tree(root/row['directory'],ev/'scenes'/row['label'])
for source,target in [('issue866-preservation.json','preservation.json'),('issue866-performance.json','performance.json'),('issue866-visual-review.json','VISUAL_REVIEW.json')]:
    shutil.copyfile(root/'build'/source,ev/target)
for script in ('document_remasters866.py','archive_remasters866.py'):
    p=Path(__file__).parent/script;(ev/'tooling').mkdir(exist_ok=True);shutil.copyfile(p,ev/'tooling'/script)
summary=dict(issue=866,version='5.17.111',view_sets=sets,native_runs=10,native_size_observations=sizes,clearance_placements=places,movement_checks=walks,retained_final_view_images=images,
             private_fixtures_not_distributed=True,performance_windows=len(scenes),full_validation_pending=True,
             qualification='Short diagnostic camera/movement checks; exact unchanged production geometry. No author acceptance or full campaign traversal.',
             size_api_qualification='The raw field in retained logs is GetSize rounded display dimensions, not texel resolution. GetScaledSize uses the same display dimensions as doubles. Original PNG IHDR/source bytes establish512x512 texels. Portable logging label corrected without gameplay change.',
             superseded_attempts=dict(lab01='Reserved state identifier: compile failed',lab02='Unknown sector floorpic/ceilingpic fields: compile failed',lab03='Passed; possible overlap with MAP01-01, superseded by serial lab04',map0101='Passed; possible overlap with lab03, superseded by serial MAP01-02'))
(ev/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
contract=dict(issue=866,version='5.17.111',scope='Exact author-provided optional environment remasters; isolated global aliases',
             runtime='build/issue866-review01.pk3',baseline='build/issue864-value03.pk3',overlay='build/issue866-remasters03.pk3',
             build_overlay='python assets/generators/build_environment_remaster_review.py --output build/author-remasters.pk3 --inventory build/author-remasters-inventory.json',
             native_views='python assets/validation_v5_17_111/run_material_views.py --runtime build/caelum_argenteum_dev.pk3 --overlay build/author-remasters.pk3 --map MAP01 --output build/author-remasters-map01',
             maps=['C866LAB','MAP01','MAP02','MAP03'],optional_named_view='--view street_outward',
             performance='python assets/validation_v5_17_111/run_scene.py --runtime build/caelum_argenteum_dev.pk3 --label UNIQUE --map MAP03 --overlay build/author-remasters.pk3 --presentation-layer LOCAL_LAYER_DIRECTORY',
             performance_variants=['mansion MAP01','Justice room MAP02','peaceful city MAP03','ground MAP03 --ground','normal siege MAP03 --siege'],
             paths_must_be_fresh=True,engine='Native Windows GZDoom4.14.2; local licensed development IWAD; neither distributed',
             limitations=['Fixture camera and pawn grants are not ordinary progression','No save schema change; no new save migration claimed','No production asset replacement or artistic acceptance','Unchanged raw-image compositions and model consumers listed in inventory','No retired6000 tests'])
(dest/'NATIVE_CONTRACT.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8')
print(json.dumps(summary))
