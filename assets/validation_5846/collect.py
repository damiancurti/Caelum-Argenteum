"""Collect final native evidence and verify the exact source/package contents."""
from pathlib import Path
from functools import lru_cache
import hashlib,json,re,shutil,zipfile
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-unloaded-npc'
N=H/'native';N.mkdir(exist_ok=True)
CURRENT=W/'final46e/caelum_argenteum_dev.pk3'
PRIOR=R.parent/'issue502-contact-work/build/issue502-contact/final45a/caelum_argenteum_dev.pk3'
@lru_cache(None)
def digest(path):
 with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def collect(folder,label,package,prefix):
 log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out'),label
 assert not re.search(r'CA502[AN] FAIL|Script error|VM execution aborted|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
 count=len(re.findall(r'^'+prefix+r' PASS ',log,re.M));assert count>0,label
 assert run['package_sha256'].lower()==digest(package),label
 for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),N/(label+suffix))
 return {'label':label,'executed_passes':count,'runtime_sha256':digest(package),'addon_sha256':run['addon_sha256'].lower()}
cases=['core','exposure','clock','warm','guards','production','resident','lethal','seed','perf','captureperf','resume','upgrade']
current=[collect(W,'ready-'+case,CURRENT,'CA502N') for case in cases]
reg=[collect(R/'build/issue502-npc-illness','ready46-active-'+case,CURRENT,'CA502N') for case in ['core','recovery']]
reg += [collect(R/'build/issue502-housekeeping','ready46-home-'+case,CURRENT,'CA502A') for case in ['seed','core','shortages','limbo']]
prior=[collect(W,label,PRIOR,'CA502N') for label in ['old45-seed-b','ready-rollback']]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
 files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
 assert set(files)==set(z.namelist())
 assert all(z.read(n)==p.read_bytes() for n,p in files.items())
 art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
 assert all(old.read(n)==z.read(n) for n in art)
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.46' and not static['errors']
perf=[]
for folder,label in [(W,'ready-perf'),(W,'ready-captureperf'),(R/'build/issue502-housekeeping','ready46-home-core')]:
 perf.extend(line for line in (folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace').splitlines() if ' TIMING ' in line)
report={'version':'5.8.46','issue':502,'base':'8ab70cb7012ef21efc681354672641474cfb2022',
 'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
 'native_passes':sum(x['executed_passes'] for x in current+reg),'original_runtime_passes':sum(x['executed_passes'] for x in prior),
 'native_failures':0,'fixture_reproducibility_verified':True,'runs':current,'regressions':reg,'original_runs':prior,'prior_save_sha256':digest(W/'absent-prior45b.zds'),
 'scope':'Source-map illness/recovery clock, exposure through original equipment, initial thermal sample, native damage factors/immunities/story protection, native hub and travelling resident restoration, load-time and deferred native deaths, fractional save/resume, genuine original45 migration/rollback, loaded physiology and household work regressions.',
 'performance':perf,
 'performance_scope':'Departure is a single typed census of the loaded default-stat population, not a routine scan. Capture benchmark uses600 added native bodies plus the2 ordinary fixture bodies. Long-absence benchmark repeats600 independent one-day integrations; it is not600 simultaneous attackers or a renderer measurement. Full hub catch-up is in the existing load census, before playable ticks. No displayed-FPS acceptance is claimed.',
 'probe_findings':'Preserved private probes identified a floating-point integer-recovery boundary, an active fixture entering See while resetting Spawn, a zero weather seed, native travel clearing diagnostic TIDs, and legacy-fixture warmup/addon-name requirements. Corrected fixtures and shared rounding use the final runtime; failed probes are excluded. An initial5.8.46 package lacked two diagnostic version labels, and later reviews added first-sample capture and native damage policy preservation; final46e supersedes those retained packages.',
 'limits':'The snapshot retains the last recovery gate and existing combat/status state; battle/status decisions remain#415. It follows original native hub bodies and resident travellers, not replacement actors in reset maps. Stackable/non-solid/contact completion remains#502.',
 'author_acceptance':'CA502-NPC-ABSENCE-01 pending grouped final V5.8 handoff; no prior author test removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members','performance']}))
