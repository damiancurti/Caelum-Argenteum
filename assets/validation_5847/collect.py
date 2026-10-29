"""Collect executed evidence, asserting exact runtime and source identity."""
from pathlib import Path
from functools import lru_cache
import hashlib,json,re,shutil,zipfile
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-stackables'
N=H/'native';N.mkdir(exist_ok=True)
CURRENT=W/'final47b/caelum_argenteum_dev.pk3'
PRIOR=W/'original46/caelum_argenteum_dev.pk3'
@lru_cache(None)
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def collect(folder,label,package,prefix):
    log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA(?:502[SN]|410[KF]) FAIL|Script error|VM execution aborted|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
    count=len(re.findall(r'^'+prefix+r' PASS ',log,re.M));assert count>0,label
    assert run['package_sha256'].lower()==digest(package),label
    for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),N/(label+suffix))
    return {'label':label,'executed_passes':count,'runtime_sha256':digest(package),'addon_sha256':run['addon_sha256'].lower()}
cases=['core','native','exposure','contact','storage','catalogue','npc','merchant','rebase','perf','seed','hub','ground','groundlive','resume','upgrade']
current=[collect(W,'ready47b-'+case,CURRENT,'CA502S') for case in cases]
regressions=[collect(R/'build/issue502-unloaded-npc','ready47b-absence-'+case,CURRENT,'CA502N') for case in ['core','exposure','production']]
regressions+=[collect(R/'build/issue410-kitchen','ready47b-food-'+case,CURRENT,'CA410F') for case in ['k-transfer','k-pickup','k-market']]
prior=[collect(W,'original46-'+case,PRIOR,'CA502S') for case in ['seed','rollback']]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
    files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(files)==set(z.namelist())
    assert all(z.read(n)==p.read_bytes() for n,p in files.items())
    art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(old.read(n)==z.read(n) for n in art)
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.47' and not static['errors']
performance=[]
for label in ['baseline46-stacks-live','final47b-stacks-live']:
    report=json.loads((W/(label+'.json')).read_text())
    assert report['runtime_sha256']==digest(PRIOR if label.startswith('baseline') else CURRENT)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(W/(label+suffix),N/(label+suffix))
    performance.append(report)
assert performance[0]['fixture_sha256']==performance[1]['fixture_sha256']
assert performance[1]['receivers_exposed']==1000
report={'version':'5.8.47','issue':502,'base':'0ca084ba3304005389bd7eeac15726c0cca9d525',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
    'native_passes':sum(r['executed_passes'] for r in current+regressions),'original_runtime_passes':sum(r['executed_passes'] for r in prior),
    'native_failures':0,'runs':current,'regressions':regressions,'original_runs':prior,'prior_save_sha256':digest(W/'stack-prior46.zds'),
    'scope':'Approved abstract unit surface; native FIFO lots, pickup/toss/storage, crafting quantity hooks, inventory details, independent carried/NPC forecasts, immersion, ground source weather, current save/hub and genuine prior-runtime migration/rollback.',
    'performance':performance,'performance_scope':'1,000 peaceful piles with one million native units each. 700 active tics, 1,199 renderer callback intervals per sample. Current runtime verifies all 1,000 exposed. PresentMon ETW remains denied; callback tails are not displayed FPS. A separate one-billion-unit homogeneous lot completes 1,000 integration steps without a per-unit loop.',
    'probe_findings':'Private probes retained. A fixture initially called a protected pickup method and then used a non-player receiver rejected by the existing game policy; corrected to CallTryPickup with the real player. The first performance map had no known weather profile; it is excluded in favor of the matched MAP01-classified fixture with all current receivers exposed. Early compilation diagnostics corrected data play scope and the fixture method name. No failed probe is counted.',
    'limits':'Only approved abstract geometries are covered here. Other physical-material, food and vessel exteriors plus remaining contact discovery remain separate adapters. No new ingestion dose or crafting inheritance balance is added.',
    'author_acceptance':'CA502-ABSTRACT-STACKS-01 pending final grouped V5.8 handoff; no author entry removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
