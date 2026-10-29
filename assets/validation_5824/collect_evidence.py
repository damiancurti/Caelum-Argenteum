"""Collect wardrobe checks and verify which final package members were tested."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-cooking'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final24d/caelum_argenteum_dev.pk3'
old=WORK/'legacy23/caelum_argenteum_dev.pk3'
files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
variants=('final24-probe','final24','final24b','final24c-probe','final24c','final24d')
equivalent={}
with zipfile.ZipFile(package) as current,zipfile.ZipFile(old) as previous:
 assert set(current.namelist())==set(files)
 for name,p in files.items():assert current.read(name)==p.read_bytes(),name
 preserved=[]
 for name in previous.namelist():
  if name.startswith(('maps/','models/','sprites/','graphics/')):
   assert previous.read(name)==current.read(name),name
   preserved.append(name)
 for variant in variants:
  candidate=WORK/variant/'caelum_argenteum_dev.pk3'
  with zipfile.ZipFile(candidate) as archive:
   assert set(archive.namelist())==set(current.namelist())
   differences=[n for n in current.namelist() if current.read(n)!=archive.read(n)]
   assert set(differences)<={'models/caelum/props/wardrobe/open.obj','LANGUAGE','localization/INDEX.md','localization/index.json'},differences
   if 'LANGUAGE' in differences:
    assert archive.read('LANGUAGE').replace(b'\r\n',b'\n').replace(b'[esp]\nCA_TARGET_CARRY_WARDROBE',b'[es]\nCA_TARGET_CARRY_WARDROBE')==current.read('LANGUAGE').replace(b'\r\n',b'\n')
   equivalent[digest(candidate)]={'variant':variant,'different_members':differences}
report={'version':'5.8.24','issue':410,'runtime_sha256':digest(package),'previous_runtime_sha256':digest(old),
 'source_matching_members':len(files),'preserved_existing_map_art_members':len(preserved),
 'tested_variants':equivalent,'native_passes':0,'native_failures':0,'runs':[],
 'author_check':'CA410-WARDROBE-01','author_acceptance':'pending'}
labels=['wardrobe-final-core','wardrobe-final-mansion','wardrobe-final-placement','wardrobe-final-seed',
 'wardrobe-finalb-carryseed','wardrobe-finalb-hub','wardrobe-finalc-carryhub','wardrobe-final-load',
 'wardrobe-final-carryload','wardrobe-delivery-legacyresume','wardrobe-finalc-view0',
 'wardrobe-finalc2-view1','wardrobe-delivery-view2','wardrobe-finalc2-view3',
 'wardrobe-oldseed23','wardrobe-rollback23','wardrobe-delivery-spanish2']
(HERE/'native').mkdir(exist_ok=True)
for label in labels:
 log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
 run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out')
 assert not re.search(r'CA410W FAIL|Script error|VM execution aborted|Fatal:|failed=[1-9]',log),label
 passes=len(re.findall(r'^CA410W PASS ',log,re.M));assert passes,label
 sha=run['package_sha256'].lower()
 assert sha==report['previous_runtime_sha256'] or sha in equivalent
 report['native_passes']+=passes
 report['runs'].append({'label':label,'executed_passes':passes,'runtime_sha256':sha,'addon_sha256':run['addon_sha256'].lower()})
 for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
raw=(WORK/'static-5824-final.json').read_bytes()
static=json.loads(raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8-sig'))
assert not static['errors'];report['static_errors']=0
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
report['performance']=[]
for label in ('wardrobe-perf-base','wardrobe-perf-final'):
 row=json.loads((WORK/(label+'.json')).read_text());report['performance'].append(row)
 for suffix in ('.json','.txt'):shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
report['save_sha256']={name:digest(WORK/name) for name in ('wardrobe-stored.zds','wardrobe-carried24b.zds','wardrobe-legacy23.zds')}
(HERE/'captures').mkdir(exist_ok=True)
for name in ('wardrobe-view0.png','wardrobe-final-view1.png','wardrobe-final-view2.png','wardrobe-final-view3.png'):
 shutil.copy2(WORK/name,HERE/'captures'/name)
report['generator_manifest_sha256']=digest(ROOT/'assets/art_source/wardrobe/MANIFEST.json')
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({key:value for key,value in report.items() if key not in ('runs','performance','tested_variants')}))
