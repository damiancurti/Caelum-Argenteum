"""Verify final native runs, unchanged random sequences and package contents."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue415-aim';NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final39a/caelum_argenteum_dev.pk3'
counts={'math':66,'native':14,'seed':14,'load':2,'hub':16,'legacy':2,'mixed':80}
def collect(label,count,expected):
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA415A FAIL|VM execution aborted|Script error|failed=[1-9]|Trying to serialize out-of-bounds|This savegame needs',log),label
    actual=len(re.findall(r'^CA415A PASS ',log,re.M));assert actual==count,(label,actual,count)
    assert run['package_sha256'].lower()==digest(expected)
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
    return {'label':label,'executed_passes':actual,'package_sha256':digest(expected),'addon_sha256':run['addon_sha256'].lower()}
rows=[collect('releasea-'+case,count,package) for case,count in counts.items()]
original=[collect('priorb-oldseed',14,WORK/'prior38/caelum_argenteum_dev.pk3'),collect('priorb-rollback',2,WORK/'prior38/caelum_argenteum_dev.pk3')]
def samples(label):
    return [s for s in (WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace').splitlines() if s.startswith('CA415A SAMPLE')]
old=samples('priorb-oldseed');assert len(old)==36
for label in ('releasea-native','releasea-seed','releasea-hub','releasea-mixed'):assert samples(label)==old,label
with zipfile.ZipFile(package) as z,zipfile.ZipFile(WORK/'prior38/caelum_argenteum_dev.pk3') as prior:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source) and all(z.read(n)==p.read_bytes() for n,p in source.items())
    kept=[n for n in prior.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(z.read(n)==prior.read(n) for n in kept)
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'));assert static['version']=='5.8.39' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
log=(WORK/'releasea-math.txt').read_text(encoding='utf-8',errors='replace')
timing=float(re.search(r'estimates_ms=([\d.]+)',log).group(1))
result={'version':'5.8.39','issue':415,'base':'47fa8dc30455ed6053553ffe716d76706623351b',
 'runtime_sha256':digest(package),'native_passes':sum(counts.values()),'original_runtime_passes':16,'native_failures':0,
 'runs':rows,'original_runs':original,'source_matching_package_members':len(source),'unchanged_map_art_members':len(kept),
 'identical_original_shot_samples':len(old),'quadrature_cases':50,'quadrature_absolute_tolerance':0.000002,
 'estimates_1600_ms':timing,'prior_save_sha256':digest(WORK/'aim-prior38.zds'),
 'scope':'Shared active carbine/spell parameters and stateless analytic angular hit estimates. Native shots across tiers and lucidity preserve exact logged critical flags, damage, velocities, spread, Air and magazine. Calling estimates first preserves the same samples. Current save/load, real hub return and original save reopening/rollback pass.',
 'limitations':'Continuous angular-envelope estimate of discrete sampling, not trajectories/LOS/anatomy or final damage. No unloaded round/resource/death simulation is enabled yet. Timing is an isolated pure-calculation callback, not frame presentation or FPS.',
 'author_acceptance':'No new author-only check for this stateless prerequisite; prior pending checks preserved. Full V5.8 author handoff remains pending.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members','estimates_1600_ms')}))
