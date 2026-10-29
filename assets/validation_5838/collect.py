"""Collect literal assertions, migration evidence and final package identity."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue502-npc-illness';NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final38a/caelum_argenteum_dev.pk3'
counts={'core':14,'recovery':12,'exposure':20,'seed':1,'load':5,'hub':6,'legacy':6,'live':3,'clock':3,'perf':1}
rows=[]
for case,count in counts.items():
 label='releaseb-'+case;log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out'),label
 assert not re.search(r'CA502N FAIL|VM execution aborted|Script error|failures=[1-9]|Trying to serialize out-of-bounds|This savegame needs',log),label
 actual=len(re.findall(r'^CA502N PASS ',log,re.M));assert actual==count,(label,actual,count)
 assert run['package_sha256'].lower()==digest(package)
 rows.append({'label':label,'executed_passes':actual,'package_sha256':run['package_sha256'].lower(),'addon_sha256':run['addon_sha256'].lower()})
 for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows})==1
prior=[]
for label in ('prior-oldseed','prior-oldcheck'):
 log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace');run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not re.search(r'CA502N FAIL|VM execution aborted|Script error',log)
 assert len(re.findall(r'^CA502N PASS ',log,re.M))==1
 assert run['package_sha256'].lower()==digest(WORK/'prior37/caelum_argenteum_dev.pk3')
 prior.append({'label':label,'executed_passes':1,'package_sha256':run['package_sha256'].lower()})
 for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
with zipfile.ZipFile(package) as z,zipfile.ZipFile(WORK/'prior37/caelum_argenteum_dev.pk3') as old:
 source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
 assert set(z.namelist())==set(source) and all(z.read(n)==p.read_bytes() for n,p in source.items())
 kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))];endings=[]
 for n in kept:
  a,b=z.read(n),old.read(n)
  if a==b:continue
  assert n.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),n
  endings.append(n)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'));assert static['version']=='5.8.38' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
perf=(WORK/'releaseb-perf.txt').read_text(encoding='utf-8',errors='replace')
total=float(re.search(r'thousand_bodies_35_ticks_ms=([\d.]+)',perf).group(1))
tails=re.search(r'thousand_body_callback_mean_ms=([\d.]+) p95_ms=([\d.]+) max_ms=([\d.]+)',perf)
timing=dict(zip(('mean_ms','p95_ms','max_ms'),map(float,tails.groups())))
result={'version':'5.8.38','issue':502,'runtime_sha256':digest(package),'native_passes':sum(r['executed_passes'] for r in rows),'original_runtime_passes':2,'native_failures':0,
 'runs':rows,'original_runs':prior,'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),'prior_obj_line_endings_only':endings,
 'original_save_sha256':digest(WORK/'npc-prior37.zds'),'thousand_bodies_35_callbacks_ms':total,'per_thousand_body_callback':timing,
 'migration':'Original5.8.37 NPC save reopens unchanged in its original runtime; final38a retains body concentration/Life and initializes only new fractional damage. Current native save and real hub round trip preserve fractional damage and original carrier identity.',
 'scope':'Loaded NPC illness, Toughness/immunity, active-time clock, native death/armor bypass, full-Life/wounded/busy natural recovery, medicine distinction, late carrier/cache rebuild and accepted exposure regressions.',
 'performance_limit':'Measured1000 individual contaminated peaceful diagnostic bodies across35 direct per-body illness callbacks. Includes ordinary native damage handling, without new population scans. Callback tails are not frame-presentation tails or a displayed-FPS claim; unloaded physiology is outside this patch.',
 'author_acceptance':'CA502-NPC-ILLNESS-01 pending grouped V5.8 handoff. Unloaded NPC physiology, household work, remaining adapters and other issues remain open.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only','per_thousand_body_callback')}))
