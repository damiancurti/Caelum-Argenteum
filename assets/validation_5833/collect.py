"""Verify final runtime identity and collect serial native execution evidence."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-basic-rest'
OUT=HERE/'native'
OUT.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final33b/caelum_argenteum_dev.pk3'
old=ROOT.parent/'issue410-rest-acquisition-work/build/issue410-rest-acquisition/final32a/caelum_argenteum_dev.pk3'
counts={'core':35,'seed':2,'resume':6,'hub':8,'legacyresume':9,'migration':3,
        'view0':2,'view1':2,'side3':4,'side4':4,'side5':4,'input0':3,'input1':3,
        'legacyseed':4,'legacyrollback':5}
rows=[]
for case,expected in counts.items():
    label='release-'+case
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not re.search(r'CA410BR FAIL|Script error|VM execution aborted|failed=[1-9]',log),label
    passes=len(re.findall(r'^CA410BR PASS ',log,re.M))
    assert passes==expected,(case,passes,expected)
    baseline=case in ('legacyseed','legacyrollback')
    assert run['package_sha256'].lower()==digest(old if baseline else package)
    rows.append({'case':case,'executed_passes':passes,'runtime_sha256':run['package_sha256'].lower(),
                 'addon_sha256':run['addon_sha256'].lower(),'role':'original-runtime compatibility' if baseline else 'final runtime'})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),OUT/(label+suffix))
assert len({r['addon_sha256'] for r in rows if r['role']=='final runtime'})==1
with zipfile.ZipFile(package) as z,zipfile.ZipFile(old) as before:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    changed={'models/caelum/props/rest/ca_rest_chair.obj','models/caelum/props/rest/ca_rest_bed.obj'}
    art=[n for n in before.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/')) and n not in changed]
    endings=[]
    for n in art:
        a,b=before.read(n),z.read(n)
        if a!=b:
            assert n.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),n
            endings.append(n)
    for kind in ('chair','bed'):
        original=HERE.parent/'art_source/basic_rest_furniture'/f'legacy-{kind}.obj'
        assert original.read_bytes().replace(b'\r\n',b'\n')==before.read(f'models/caelum/props/rest/ca_rest_{kind}.obj').replace(b'\r\n',b'\n')
original_save=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(original_save)==digest(WORK/'reading-progress.zds')
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.33' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for name in ['basic-rest-0.png','basic-rest-1.png','basic-side-3.png','basic-side-4.png','basic-side-5.png']:
    shutil.copy2(WORK/name,HERE/name)
report={'version':'5.8.33','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_final_passes':sum(r['executed_passes'] for r in rows if r['role']=='final runtime'),
        'native_baseline_passes':sum(r['executed_passes'] for r in rows if r['role']!='final runtime'),
        'native_failures':0,'source_matching_package_members':len(source),
        'preserved_map_art_members':len(art)-len(endings),'prior_obj_line_endings_only':endings,
        'modified_art':sorted(changed),'legacy_occupied_save_sha256':digest(WORK/'basic-old.zds'),
        'original_reading_save_sha256':digest(original_save),
        'migration':'5.8.32 generates an occupied cot save with actual inventory and dirt. The untouched save loads in both original32 and final33b; new code retains occupant/inventory and migrates collision, support height and headboard facing. Separate current save/hub and original5.8.26 campaign checks pass.',
        'reproduction':'Prepare diagnostics; run legacyseed then legacyrollback against the retained5.8.32 package to create basic-old.zds. Copy original5.8.26 reading-progress.zds from its validation work. Run run_suite.ps1 on final33b with a fresh Prefix. Neither engine/IWAD nor save fixtures are distributed.',
        'visual_review':'Native Spanish views inspected: human-scale chair, raised four-leg cot, centered sitting, headboard-aligned lying and unchanged floor bag. Side diagnostic camera changes only the view; actual native rest remains active.',
        'early_probes':'Retained locally: reserved Stop identifier/incompatible fixture ternaries; fixture failed to explicitly create dining seats. Fixed fixtures. Visual review then corrected chair horizontal offset and cot headboard facing; all final selected runtime cases follow those corrections.',
        'scope':'No map geometry, character art, inventory sprites, recovery rules, luxury/sofa dimensions or bag meshes changed. Furniture acquisition remains subsequent work.',
        'performance':'One revision comparison in each existing rest-furniture Tick; exact-class initialization/migration, no new recurring global scan. No display-FPS claim.',
        'author_acceptance':'CA410-BASIC-REST-01 pending; grouped V5.8 handoff remains deferred.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['runtime_sha256','native_final_passes','native_baseline_passes','native_failures','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only']}))
