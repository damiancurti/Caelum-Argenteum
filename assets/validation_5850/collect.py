"""Collect final native runs and verify package/source identity."""
from pathlib import Path
from functools import lru_cache
import hashlib, json, re, shutil, zipfile

R=Path(__file__).resolve().parents[2]; H=Path(__file__).resolve().parent
W=R/'build/issue502-adapters'; N=H/'native'; N.mkdir(exist_ok=True)
CURRENT=W/'final50b/caelum_argenteum_dev.pk3'
PRIOR=W/'original49/caelum_argenteum_dev.pk3'
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
current=[collect(W,'ready50-'+c,CURRENT) for c in ['catalogue','tent','contact','seed','resume','hub','upgrade']]
regressions=[collect(W,'ready50-r49-'+c,CURRENT) for c in ['food','forecast','support']]
regressions += [collect(W,'ready50-r15-'+c,CURRENT) for c in ['entry02','entry-clean']]
prior=[collect(W,'original49-seed',PRIOR),collect(W,'ready50-rollback',PRIOR)]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
    files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(files)==set(z.namelist())
    assert all(z.read(n)==p.read_bytes() for n,p in files.items())
    art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(old.read(n)==z.read(n) for n in art)
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.50' and not static['errors']
performance=[]
for label in ['perf50-baseline','perf50-current']:
    item=json.loads((W/(label+'.json')).read_text())
    assert item['runtime_sha256']==digest(PRIOR if label.endswith('baseline') else CURRENT)
    performance.append(item)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(W/(label+suffix),N/(label+suffix))
report={'version':'5.8.50','issue':502,'base':'35c5ff4ec1675ae7448233b6df53df4a0b705b4d',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
    'native_passes':sum(r['passes'] for r in current+regressions),'original_runtime_passes':sum(r['passes'] for r in prior),
    'native_failures':0,'runs':current,'regressions':regressions,'original_runs':prior,
    'prior_save_sha256':digest(W/'adapter-prior49.zds'),'performance':performance,
    'scope':'Generic native quantity transfer, independent furniture/table forecasts, reusable cloth, deployment boundaries, NPC floor/wall contacts and unlinked local grid; original 5.8.49 migration/rollback.',
    'limits':'Approved collision-cylinder proxies, not mesh surfaces. Unloaded encounter integration remains in415; transport/incidents416-417 remain open. No displayed-frame or whole-campaign FPS acceptance.',
    'fixture_correction':'The inherited 5815 timed entry case requires CDEP411, as its original evidence records. MAP01 rejects timed Limbo rest in both 5.8.49 and 5.8.50; corrected launch passes without production changes.',
    'author_acceptance':'CA502-ADAPTERS-01 pending grouped final V5.8 handoff; no author check removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
