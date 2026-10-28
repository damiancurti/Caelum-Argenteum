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
WORK=ROOT/'build/issue410-study-acquisition'
NATIVE=HERE/'native'
NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final36b/caelum_argenteum_dev.pk3'
counts={'catalogue':27,'craft':66,'trade':49,'items':56,'placement':52,'sofaplace':48,'studyseed':20,'studyresume':14,'studyhub':34,'studyinput':14,'studyinstall':16,'studyupgrade':12,'sofamigration':24,'legacy':2,'view6':2,'view7':2,'studygallery0':13,'studygallery1':13,'visual0':2,'visual1':2}
rows=[]
for case,count in counts.items():
    label=('releasec-' if case.startswith('visual') else 'releaseb-')+case
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not re.search(r'CA410RF FAIL|VM execution aborted|Script error|failed=[1-9]|Trying to serialize out-of-bounds',log),label
    passes=len(re.findall(r'^CA410RF PASS ',log,re.M))
    assert passes==count,(label,passes,count)
    assert run['package_sha256'].lower()==digest(package),label
    rows.append({'label':label,'executed_passes':passes,'runtime_sha256':run['package_sha256'].lower(),
                 'addon_sha256':run['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows if '-visual' not in r['label']})==1
assert len({r['addon_sha256'] for r in rows if '-visual' in r['label']})==1
with zipfile.ZipFile(package) as z:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    prior_path=ROOT.parent/'issue410-sofa-acquisition-work/build/issue410-sofa-acquisition/final35a/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(prior_path) as prior:
        kept=[n for n in prior.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        endings=[]
        for name in kept:
            a,b=z.read(name),prior.read(name)
            if a==b:continue
            assert name.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),name
            endings.append(name)
art=json.loads((ROOT/'assets/art_source/study_items/MANIFEST.json').read_text())
for record in art['sources']:
    src=ROOT/'assets/art_source/study_items'/record['source']
    assert digest(src)==record['sha256']
    if record['runtime']:assert digest(ROOT/record['runtime'])==record['sha256']
    raw=src.read_bytes();assert raw[:8]==b'\x89PNG\r\n\x1a\n' and raw[25]==6
    record['pixel_size']=list(struct.unpack('>II',raw[16:24]))
prior_rows=[]
for label,count in [('prior-seed',5),('prior-rollback',14)]:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not re.search(r'CA410RF FAIL|VM execution aborted|Script error|failed=[1-9]|Trying to serialize out-of-bounds',log)
    assert len(re.findall(r'^CA410RF PASS ',log,re.M))==count
    assert run['package_sha256'].lower()==digest(WORK/'prior35/caelum_argenteum_dev.pk3')
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
    prior_rows.append({'label':label,'executed_passes':count,'runtime_sha256':run['package_sha256'].lower()})
save=WORK/'reading-progress.zds'
original=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(save)==digest(original)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.36' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for v in (6,7):shutil.copy2(WORK/f'rest-inventory-{v}.png',HERE/f'rest-inventory-{v}.png')
for k in (0,1):shutil.copy2(WORK/f'study-visual-{k}.png',HERE/f'study-world-{k}.png')
result={'version':'5.8.36','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'original_runtime_runs':prior_rows,'original_runtime_passes':19,'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),
        'prior_obj_line_endings_only':endings,'original_save_sha256':digest(save),
        'artwork':art,
        'evidence_reuse':'All selected current assertions execute on final36b; eighteen functional cases share the same unchanged addon. Two additional isolated visual cases use gallery.pk3 because the original MAP01 gallery capture was obscured by its introduction dialogue. Actual revision21 save is newly created and reopened unchanged in original5.8.35; 19 original-runtime checks are counted separately. Original5.8.26 reading and5.8.35 sofa saves are loaded without rewriting their source files.',
        'migration':'Revision22 appends two unknown study recipes while preserving six learned recipes and depleted stock; merchant revision4 is idempotent. Desk/body and library/shelf/storage/books/lock/TIDs/title/dirt/reading identity survive native save and hub travel. Original storage-cargo Box restriction is preserved. Fixed mansion fixtures are not suppressed by portable subclasses.',
        'performance_scope':'Only bounded interaction/merchant/inventory loops; parked physical body does not tick or receive duplicate world exposure. No new recurring global scan. No display-FPS or multiplayer claim.',
        'remaining':'Dining-table acquisition and broader V5.8 remain open.',
        'author_acceptance':'CA410-STUDY-ACQUISITION-01 pending; grouped handoff after all V5.8 implementation.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only')}))
