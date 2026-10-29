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
WORK=ROOT/'build/issue410-rest-acquisition'
NATIVE=HERE/'native'
NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final32a/caelum_argenteum_dev.pk3'
counts={'catalogue':12,'craft':16,'trade':13,'items':14,'placement':26,
        'seed':2,'resume':6,'hub':8,'legacy':2,'view0':2,'view1':2,'use':4}
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
    prior_path=ROOT.parent/'issue410-storage-acquisition-work/build/issue410-storage-acquisition/final31b/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(prior_path) as prior:
        kept=[n for n in prior.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        endings=[]
        for name in kept:
            a,b=z.read(name),prior.read(name)
            if a==b:continue
            assert name.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),name
            endings.append(name)
art=json.loads((ROOT/'assets/art_source/rest_furniture_items/MANIFEST.json').read_text())
for name,record in art['sources'].items():
    src=ROOT/'assets/art_source/rest_furniture_items'/name
    assert digest(src)==record['sha256']==digest(ROOT/record['runtime'])
    raw=src.read_bytes()
    assert raw[:8]==b'\x89PNG\r\n\x1a\n' and raw[25]==6
    record['pixel_size']=list(struct.unpack('>II',raw[16:24]))
save=WORK/'reading-progress.zds'
original=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(save)==digest(original)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.32' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for v in range(2):shutil.copy2(WORK/f'rest-inventory-{v}.png',HERE/f'rest-inventory-{v}.png')
result={'version':'5.8.32','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),
        'prior_obj_line_endings_only':endings,'original_save_sha256':digest(save),
        'artwork':art,
        'evidence_reuse':'All selected native assertions execute on final32a. The last run adds only the native crouch/Use diagnostic to the addon. Original-runtime rollback of the identical untouched legacy save is reused from validation_5826/5829, not counted as new execution.',
        'migration':'Recipe revision19 appends two unknown recipes. Actual carried body, title, contamination, learning and native use persist across save/load and hub. Original5.8.26 stored-book progress and original book remain unchanged.',
        'performance_scope':'Only bounded interaction/merchant/inventory loops; parked physical body does not tick or receive duplicate world exposure. No new recurring global scan. No display-FPS or multiplayer claim.',
        'remaining':'Ordinary furniture, sofa, table and study furniture acquisition and broader V5.8 remain open.',
        'author_acceptance':'CA410-REST-ACQUISITION-01 pending; grouped handoff after all V5.8 implementation.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only')}))
