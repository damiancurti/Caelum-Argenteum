"""Collect scoped native evidence and verify the released source package."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue502-seal-history';NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final37a/caelum_argenteum_dev.pk3'
counts={'core':14,'weather':20,'seed':1,'load':4,'hub':5,'legacy':4,'rainseed':1,'rainload':3,'perf':1}
rows=[]
for case,count in counts.items():
 label='releasea-'+case;log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out'),label
 assert not re.search(r'CA502W FAIL|VM execution aborted|Script error|failed=[1-9]|Trying to serialize out-of-bounds|This savegame needs',log),label
 actual=len(re.findall(r'^CA502W PASS ',log,re.M));assert actual==count,(label,actual,count)
 assert run['package_sha256'].lower()==digest(package)
 rows.append({'label':label,'executed_passes':actual,'package_sha256':run['package_sha256'].lower(),'addon_sha256':run['addon_sha256'].lower()})
 for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows})==1
prior=[]
for label in ('prior-oldseed','prior-oldcheck'):
 log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace');run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not re.search(r'CA502W FAIL|VM execution aborted|Script error',log)
 assert len(re.findall(r'^CA502W PASS ',log,re.M))==2
 assert run['package_sha256'].lower()==digest(WORK/'prior36/caelum_argenteum_dev.pk3')
 prior.append({'label':label,'executed_passes':2,'package_sha256':run['package_sha256'].lower()})
 for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
with zipfile.ZipFile(package) as z,zipfile.ZipFile(WORK/'prior36/caelum_argenteum_dev.pk3') as old:
 source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
 assert set(z.namelist())==set(source) and all(z.read(n)==p.read_bytes() for n,p in source.items())
 kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))];endings=[]
 for n in kept:
  a,b=z.read(n),old.read(n)
  if a==b:continue
  assert n.endswith('.obj') and a.replace(b'\r\n',b'\n')==b.replace(b'\r\n',b'\n'),n
  endings.append(n)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'));assert static['version']=='5.8.37' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
timings=[]
for label in ('probe07-perf','probe09-perf','releasea-perf'):
 log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 value=float(re.search(r'boundary_1000_ms=([\d.]+)',log).group(1));timings.append({'label':label,'boundary_1000_ms':value})
 if label!='releasea-perf':
  for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
result={'version':'5.8.37','issue':502,'runtime_sha256':digest(package),'native_passes':sum(x['executed_passes'] for x in rows),'original_runtime_passes':4,'native_failures':0,
 'runs':rows,'original_runs':prior,'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(endings),'prior_obj_line_endings_only':endings,
 'original_save_sha256':digest(WORK/'seal-prior36.zds'),'boundary_timings':timings,
 'migration':'Actual original5.8.36 sealed-object save is reopened unchanged under original runtime and migrated under final37a. Missing temporary history starts now without altering its concentration; repeated migration is idempotent.',
 'scope':'Loaded Fire/Water surface sampling, default versus surface trace and intervening solid, rain/temporary interval save persistence, stop/departure boundaries, original-runtime migration, natural regional history, real hub absence and repeat queries. Same immutable final runtime and addon across all selected current assertions.',
 'performance_limit':'One typed traversal at unload over current-map exposure nodes; no recurring population scan. The1000-object dense peaceful callback measures synchronous boundary work, not presented-frame tails, simulation throughput or FPS. The uncached prototype is historical diagnostic evidence, not accepted production.',
 'author_acceptance':'CA502-SEAL-HISTORY-01 pending grouped V5.8 handoff; NPC physiology, unloaded housekeeping and other issue scopes remain unfinished.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','preserved_map_art_members','prior_obj_line_endings_only','boundary_timings')}))
