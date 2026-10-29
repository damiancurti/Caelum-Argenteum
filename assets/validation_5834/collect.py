"""Collect native execution evidence and verify final package/source identity."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-basic-rest-acquisition'
NATIVE=HERE/'native'
NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final34a/caelum_argenteum_dev.pk3'
counts={'catalogue':17,'craft':34,'trade':25,'items':28,'placement':52,
        'seed':4,'resume':8,'hub':12,'legacy':2,'view0':2,'view1':2,'view2':2,'view3':2,'use':6,'oldresume':10}
rows=[]
for case,count in counts.items():
    label='release-'+case
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not re.search(r'CA410RF FAIL|VM execution aborted|Script error|failed=[1-9]',log),label
    passes=len(re.findall(r'^CA410RF PASS ',log,re.M))
    assert passes==count,(label,passes,count)
    assert run['package_sha256'].lower()==digest(package),label
    rows.append({'label':label,'executed_passes':passes,'runtime_sha256':run['package_sha256'].lower(),
                 'addon_sha256':run['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows if r['label']!='release-use'})==1
with zipfile.ZipFile(package) as z:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    prior_path=ROOT.parent/'issue410-basic-rest-work/build/issue410-basic-rest/final33b/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(prior_path) as prior:
        kept=[n for n in prior.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        endings=[]
        for name in kept:
            a,b=z.read(name),prior.read(name)
            if a==b:continue
            assert name.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),name
            endings.append(name)
art=json.loads((ROOT/'assets/art_source/basic_rest_items/MANIFEST.json').read_text())
for record in art['sources']:
    src=ROOT/'assets/art_source/basic_rest_items'/record['source']
    assert digest(src)==record['sha256']
    if record['runtime']:assert digest(ROOT/record['runtime'])==record['sha256']
    raw=src.read_bytes();assert raw[:8]==b'\x89PNG\r\n\x1a\n' and raw[25]==6
    record['pixel_size']=list(struct.unpack('>II',raw[16:24]))
prior_rows=[]
for label,count in [('prior2-seed',4),('prior2-rollback',8)]:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not re.search(r'CA410RF FAIL|VM execution aborted|Script error|failed=[1-9]',log)
    assert len(re.findall(r'^CA410RF PASS ',log,re.M))==count
    assert run['package_sha256'].lower()==digest(WORK/'prior33/caelum_argenteum_dev.pk3')
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
    prior_rows.append({'label':label,'executed_passes':count,'runtime_sha256':run['package_sha256'].lower()})
save=WORK/'reading-progress.zds'
original=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(save)==digest(original)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.34' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for v in range(4):shutil.copy2(WORK/f'rest-inventory-{v}.png',HERE/f'rest-inventory-{v}.png')
result={'version':'5.8.34','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'original_runtime_runs':prior_rows,'original_runtime_passes':12,'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),
        'prior_obj_line_endings_only':endings,'original_save_sha256':digest(save),
        'artwork':art,
        'evidence_reuse':'All selected current-runtime assertions execute on final34a with one identical addon. Native revision19 save is newly generated and reloaded unchanged in original5.8.33; 12 original-runtime assertions are counted separately. Older stored-book rollback evidence is reused, not counted as new execution.',
        'migration':'Recipe revision20 appends two unknown ordinary recipes, retaining learned luxury recipes and depleted shop stock. Actual carried body, title, contamination, learning and native use persist across save/load and hub. Original5.8.26 stored-book progress and original book remain unchanged.',
        'performance_scope':'Only bounded interaction/merchant/inventory loops; parked physical body does not tick or receive duplicate world exposure. No new recurring global scan. No display-FPS or multiplayer claim.',
        'remaining':'Sofa, table and study furniture acquisition and broader V5.8 remain open.',
        'author_acceptance':'CA410-BASIC-ACQUISITION-01 pending; grouped handoff after all V5.8 implementation.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only')}))
