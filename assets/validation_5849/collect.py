"""Collect final native runs and verify package/source identity."""
from pathlib import Path
from functools import lru_cache
import hashlib, json, re, shutil, zipfile

R=Path(__file__).resolve().parents[2]; H=Path(__file__).resolve().parent
W=R/'build/issue502-physical'; N=H/'native'; N.mkdir(exist_ok=True)
CURRENT=W/'final49a/caelum_argenteum_dev.pk3'
PRIOR=W/'original48/caelum_argenteum_dev.pk3'
@lru_cache(None)
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def collect(folder,label,package):
    log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'^CA\w* FAIL|Script error|VM execution aborted|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR|Cannot find savegame',log,re.M),label
    count=len(re.findall(r'^CA\w* PASS ',log,re.M));assert count>0,label
    assert run['package_sha256'].lower()==digest(package),label
    for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),N/(label+suffix))
    return {'label':label,'passes':count,'runtime_sha256':digest(package),'addon_sha256':run['addon_sha256'].lower()}
current=[collect(W,'ready49-'+c,CURRENT) for c in ['catalogue','food','forecast','contact','support','absent','seed','resume','hub','upgrade']]
regressions=[collect(R/'build/issue410-kitchen','ready49-'+c,CURRENT) for c in ['k-transfer','k-pickup','k-market','f-clock']]
regressions += [collect(R/'build/issue410-cooking','ready49-'+c,CURRENT) for c in ['process-core','process-guards','process-fast']]
prior=[collect(W,'original48-seed03',PRIOR),collect(W,'ready49-rollback',PRIOR)]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
    files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(files)==set(z.namelist())
    assert all(z.read(n)==p.read_bytes() for n,p in files.items())
    art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(old.read(n)==z.read(n) for n in art)
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.49' and not static['errors']
performance=[]
for label in ['perf49-baseline','perf49-current']:
    item=json.loads((W/(label+'.json')).read_text())
    assert item['runtime_sha256']==digest(PRIOR if label.endswith('baseline') else CURRENT)
    performance.append(item)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(W/(label+suffix),N/(label+suffix))
report={'version':'5.8.49','issue':502,'base':'874d038d9ccf38328da78073be0740c6ff3559c4',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
    'native_passes':sum(r['passes'] for r in current+regressions),'original_runtime_passes':sum(r['passes'] for r in prior),
    'native_failures':0,'runs':current,'regressions':regressions,'original_runs':prior,
    'prior_save_sha256':digest(W/'physical-prior48.zds'),'performance':performance,
    'scope':'Physical material/food surfaces; authoritative food ageing/contact ledger; independent forecasts; absent NPC food climate; local non-solid contact and floor support; actual prior runtime migration/rollback.',
    'limits':'Documented reference densities and gameplay proxies, not mesh surfaces. Other generic physical inventory/contact adapters and issues415-417 remain open. No displayed-frame or campaign FPS acceptance.',
    'author_acceptance':'CA502-PHYSICAL-STACKS-01 pending grouped final V5.8 handoff; no author check removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
