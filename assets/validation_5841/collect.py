"""Collect exact-build native household persistence evidence."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
from functools import lru_cache
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent
W=R/'build/issue502-house-absence';N=H/'native';N.mkdir(exist_ok=True)
@lru_cache(maxsize=None)
def digest(p):
 with p.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
package=W/'final41b/caelum_argenteum_dev.pk3';prior=W/'prior40/caelum_argenteum_dev.pk3'
cases=['seed','load','back','samehub','perf','migration','domestic-core','domestic-load','domestic-hub','domestic-shortages','domestic-clock','domestic-skipped']
def collect(label,runtime):
 log=(W/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 run=json.loads((W/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out'),label
 assert not re.search(r'CA502H FAIL|VM execution aborted|Script error|fail(?:ed|ures)=[1-9]|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
 count=len(re.findall(r'^CA502H PASS ',log,re.M));assert count>0,label
 assert run['package_sha256'].lower()==digest(runtime),label
 for suffix in ('.txt','-run.json'):shutil.copy2(W/(label+suffix),N/(label+suffix))
 return {'label':label,'executed_passes':count,'package_sha256':digest(runtime),'addon_sha256':run['addon_sha256'].lower()}
rows=[collect('releaseb-'+n,package) for n in cases]
original=[collect('prior01-'+n,prior) for n in ['seed','rollback']]+[collect('prior05-skipped',prior)]
with zipfile.ZipFile(package) as z,zipfile.ZipFile(prior) as old:
 source={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
 assert set(z.namelist())==set(source)
 assert all(z.read(n)==p.read_bytes() for n,p in source.items())
 kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
 newline_only=[]
 for n in kept:
  current,previous=z.read(n),old.read(n)
  if current==previous:continue
  assert n in ['models/caelum/props/dining_sets/ca_dining_'+k+'.obj' for k in ['large','normal','small']],n
  assert current.replace(b'\r\n',b'\n')==previous.replace(b'\r\n',b'\n'),n
  newline_only.append(n)
static=json.loads((W/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.41' and not static['errors']
(H/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
perf=(W/'releaseb-perf.txt').read_text(encoding='utf-8',errors='replace')
timing=re.search(r'CA502H TIMING snapshot_restore_targets=(\d+) mean_ms=([\d.]+) p95_ms=([\d.]+) max_ms=([\d.]+)',perf);assert timing
report={'version':'5.8.41','issue':502,'base':'4b9b70d329b325a654f7a0540691b32941e1e427',
 'runtime_sha256':digest(package),'source_matching_package_members':len(source),'unchanged_map_art_members':len(kept)-len(newline_only),'checkout_newline_only_obj_members':newline_only,
 'native_passes':sum(r['executed_passes'] for r in rows),'original_runtime_passes':sum(r['executed_passes'] for r in original),'native_failures':0,'runs':rows,'original_runs':original,
 'prior_save_sha256':digest(W/'house-prior40.zds'),
 'timing':{'target_count':int(timing[1]),'snapshot_restore_mean_ms':float(timing[2]),'p95_ms':float(timing[3]),'max_ms':float(timing[4]),'scope':'20 synchronous production snapshot/restore callbacks, one real household. Not displayed-frame or FPS evidence.'},
 'scope':'Actual domestic coffer/inventory persistence, source-home food ageing/water cooling/coffer exposure, exact remote purchase transaction, scalar partial work keys, current save/load, same-hub and real cross-hub Limbo return, actual5.8.40 save adoption and original-runtime rollback. Existing loaded-house resources, shortages and calendar-skip checks reused.',
 'known_limits':'No automatic unloaded household scheduler or purchases, unloaded NPC physiology or general furnishing-state migration. No map/art geometry or balance rates changed. Three existing OBJ texts acquired CRLF on worktree checkout; exact newline-normalized content matches the prior package and git records no asset edit. RESULT counters restored from saves are cumulative; only literal executed PASS lines are counted.',
 'probe_findings':'Food Item/item field shadow fixed with self qualification. Native MAP01 is outside hub434: fixed installations need declared keys rather than temporary actor identities. Earlier failing probes retained in build, excluded from final evidence. The inherited accelerated-clock fixture chose a visible but physically blocked route on both current and original runtimes (done=1, progress=0, native blocking actor present). Its scoped adapter now verifies a native collision path before exercising the real accelerated clock; original and current checks pass.',
 'author_acceptance':'Pending CA502-HOME-STORAGE-01, held for grouped final V5.8 handoff. All prior pending checks retained.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','native_failures','runtime_sha256','source_matching_package_members','timing']}))
