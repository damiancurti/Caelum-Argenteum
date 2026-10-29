"""Collect executed sofa checks and verify the delivered package against source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-sofas'
PREVIOUS=ROOT.parent/'issue410-reading-work/build/issue410-reading'
NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
expected={'core':59,'input':4,'lifecycle':12,'seed':2,'resume':5,'hub':6,'migration':3,
          'view0-0':2,'view0-1':2,'view1-0':2,'view1-1':2,'view1-2':2}
rows=[]
cases=[('delivery-'+name,count) for name,count in expected.items()]+[('final-target-en',4),('final-localized-es',4),('final-input',4)]
for label,count in cases:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not re.search(r'CA410SF FAIL|VM execution aborted|Script error|failed=[1-9]',log),label
    executed=len(re.findall(r'^CA410SF PASS ',log,re.M))
    assert executed==count,(label,executed,count)
    rows.append({'label':label,'executed_passes':executed,'runtime_sha256':record['package_sha256'].lower(),
                 'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final29d/caelum_argenteum_dev.pk3'
intermediate=WORK/'final29c/caelum_argenteum_dev.pk3'
basepackage=WORK/'final29b/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    oldpath=ROOT.parent/'issue502-weather-work/build/issue502-weather/final28b/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(oldpath) as old:
        kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        assert all(z.read(n)==old.read(n) for n in kept)
assert all(row['runtime_sha256']==digest(basepackage if row['label'].startswith('delivery-') else package if row['label']=='final-localized-es' else intermediate) for row in rows)
with zipfile.ZipFile(basepackage) as a,zipfile.ZipFile(intermediate) as b:
    assert a.namelist()==b.namelist()
    differences=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert differences==['caelum/world/CaelumTargetInfo.zs'],differences
with zipfile.ZipFile(intermediate) as a,zipfile.ZipFile(package) as b:
    differences=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert set(differences)=={'LANGUAGE','localization/index.json','localization/INDEX.md'},differences
    assert b'Sof\xc3\xa1 de tres plazas' in b.read('LANGUAGE')
rollback='reading-interior-rollback'
rollback_log=(PREVIOUS/(rollback+'.txt')).read_text(encoding='utf-8',errors='replace')
assert 'CA410RD RESULT' in rollback_log and not re.search(r'CA410RD FAIL|VM execution aborted|Script error|failed=[1-9]',rollback_log)
for suffix in ('.txt','-run.json'):shutil.copy2(PREVIOUS/(rollback+suffix),NATIVE/(rollback+suffix))
assert digest(WORK/'reading-progress.zds')==digest(PREVIOUS/'reading-progress.zds')
generated=[ROOT/'src/models/caelum/props/sofas/ca_sofa_2.obj',ROOT/'src/models/caelum/props/sofas/ca_sofa_3.obj',
           ROOT/'src/caelum/data/CaelumSofaData.zs',ROOT/'assets/art_source/sofas/GENERATED.json']
before=[digest(p) for p in generated]
subprocess.run(['python','assets/generators/generate_sofas.py'],cwd=ROOT,check=True,capture_output=True)
assert before==[digest(p) for p in generated]
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-16'))
assert not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for path in WORK.glob('sofa-*.png'):shutil.copy2(path,HERE/path.name)
for label in ('lifecycle4','lifecycle7'):
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
result={'version':'5.8.29','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept),
        'deterministic_generated_outputs':len(generated),'original_save_sha256':digest(WORK/'reading-progress.zds'),
        'migration':'Original5.8.26 partial-library save loads unchanged; new sofa revision adds five seat proxies once. Current occupied-seat save and hub return tested.',
        'evidence_reuse':'101 executed assertions against final29b remain applicable: final29c adds only one CanonicalActor mapping and executes8 retained input/EN assertions. Final29d corrects only Spanish text/index encoding, executing4 additional ES target assertions. Prior original-runtime rollback is reused for the identical untouched old save; not counted as newly executed.',
        'performance_scope':'Two visual owners/five proxies; at-most-three seat references; one on-demand native collision probe. Typed sofa installation census runs once/second until the two owners fit, then stops. No frame-presentation or multiplayer acceptance claim.',
        'author_acceptance':'Pending CA410-SOFAS-01. Manual delivery deferred until the fullV5.8 implementation is ready.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members')}))
