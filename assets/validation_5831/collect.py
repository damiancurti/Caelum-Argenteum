"""Check final native executions, source identity and accepted art preservation."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-storage-acquisition'
NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final31b/caelum_argenteum_dev.pk3'
functional_package=WORK/'final31a/caelum_argenteum_dev.pk3'
expected={'catalogue':12,'craft':17,'trade':13,'items':14,'placement':19,
          'seed':6,'resume':5,'hub':11,'legacy':2,'inventory':6,'shop':2}
rows=[]
for case,count in expected.items():
    label=('final-' if case=='inventory' else 'release-')+case
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not re.search(r'CA410SF FAIL|VM execution aborted|Script error|failed=[1-9]',log),label
    passes=len(re.findall(r'^CA410SF PASS ',log,re.M));assert passes==count,(label,passes,count)
    tested=package if case=='inventory' else functional_package
    assert record['package_sha256'].lower()==digest(tested),label
    rows.append({'label':label,'executed_passes':passes,'runtime_sha256':record['package_sha256'].lower(),
                 'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows if r['label']!='final-inventory'})==1
with zipfile.ZipFile(functional_package) as a,zipfile.ZipFile(package) as b:
    assert a.namelist()==b.namelist()
    presentation_changes=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert sorted(presentation_changes)==['caelum/debug/CaelumDebugOverlay.zs','caelum/player/CaelumPlayer.zs']
with zipfile.ZipFile(package) as z:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    with zipfile.ZipFile(ROOT.parent/'issue410-luxury-work/build/issue410-luxury/final30c/caelum_argenteum_dev.pk3') as prior:
        kept=[n for n in prior.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        endings=[]
        for name in kept:
            a,b=z.read(name),prior.read(name)
            if a==b:continue
            assert name.startswith('models/caelum/props/luxury/') and name.endswith('.obj'),name
            assert a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),name
            endings.append(name)
save=WORK/'reading-progress.zds'
original=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(save)==digest(original)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.31' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for name in ('storage-inventory.png','storage-wardrobe.png','storage-shop.png'):shutil.copy2(WORK/name,HERE/name)
result={'version':'5.8.31','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),
        'prior_obj_line_endings_only':endings,'original_save_sha256':digest(save),
        'migration':'Recipe-book revision18 appends two unknown recipes, keeps earlier learning and the original5.8.26 partial-reading session. Current saves and hub retain actual cupboard/cargo/contents/title and independent furniture item dirt.',
        'presentation_only_changes_after_functional_checks':presentation_changes,
        'evidence_reuse':'Functional native assertions use final31a. Final31b changes only selection/crafting icon resolution; the native Spanish inventory/preview check was rerun and both item captures reviewed. All other source bytes match. Original-runtime rollback of the identical untouched legacy save is reused from validation_5826/5829, not counted as new execution.',
        'performance_scope':'Transactions use existing bounded merchant/product/inventory loops and native placement; no new recurring actor scan or thinker. No frame-presentation/FPS or multiplayer claim.',
        'remaining':'Other movable furniture purchase/fabrication/placement and V5.8 issues remain open. Existing art is reused, not new visual acceptance.',
        'author_acceptance':'Pending CA410-STORAGE-ACQUISITION-01; grouped handoff only after all V5.8 implementation.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only')}))
