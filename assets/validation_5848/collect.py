"""Verify the tested release bytes and retain bounded native evidence."""
from pathlib import Path
from functools import lru_cache
import hashlib,json,re,shutil,zipfile
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-vessels'
N=H/'native';N.mkdir(exist_ok=True)
CURRENT=W/'final48b/caelum_argenteum_dev.pk3';PRIOR=W/'original47/caelum_argenteum_dev.pk3'
@lru_cache(None)
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def collect(folder,label,package,prefix):
    log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA(?:502[VS]|410DS) FAIL|Script error|VM execution aborted|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR|Cannot find savegame',log),label
    count=len(re.findall(r'^'+prefix+r' PASS ',log,re.M));assert count>0,label
    assert run['package_sha256'].lower()==digest(package),label
    for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),N/(label+suffix))
    return {'label':label,'executed_passes':count,'runtime_sha256':digest(package),'addon_sha256':run['addon_sha256'].lower()}
cases=['catalogue','storage','immersion','camp','packed','contact','seed','resume','hub','awaysave','packedtravel','awayload','packedload','upgrade']
current=[collect(W,'ready48-'+c,CURRENT,'CA502V') for c in cases]
regressions=[collect(R/'build/issue410-dining','ready48-dining-'+c,CURRENT,'CA410DS') for c in ['hub','nestedhub']]
regressions += [collect(R/'build/issue502-stackables','ready48-stacks-'+c,CURRENT,'CA502S') for c in ['native','contact','storage','exposure','npc']]
prior=[collect(W,'original47-'+c,PRIOR,'CA502V') for c in ['seed','rollback']]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
    files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(files)==set(z.namelist())
    assert all(z.read(n)==p.read_bytes() for n,p in files.items())
    art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(old.read(n)==z.read(n) for n in art)
geometry=json.loads((H/'geometry.json').read_text())
log=(W/'ready48-catalogue.txt').read_text()
observed={int(k):float(v) for k,v in re.findall(r'CA502V AREA kind=(\d+) m2=([.\d]+)',log)}
for row in geometry['rows']:assert abs(observed[row['kind']]-row['area_m2'])<1e-11,row
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.48' and not static['errors']
assert 'PASS: absent save rejected' in (H/'launcher-guard.txt').read_text(encoding='utf-8-sig')
report={'version':'5.8.48','issue':502,'base':'1d58a455085b46823dbf22db669c7f4cfa95b899',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
    'native_passes':sum(r['executed_passes'] for r in current+regressions),'original_runtime_passes':sum(r['executed_passes'] for r in prior),
    'native_failures':0,'runs':current,'regressions':regressions,'original_runs':prior,'prior_save_sha256':digest(W/'vessel-prior47.zds'),
    'crash_archive_sha256':digest(W/'probe04-packedtravel-author-crash.zip'),
    'crash_diagnosis':'probe04 synthetic table skipped existing Park before native travel; C0000005/write0xbeefcafe on CVS502B. Corrected setup uses Park and real Box acquisition. Subsequent vessel-packed.zds load failed because the crashed run never saved it. New runner rejects absent saves before native launch; batches stop on failure. Real production dining hub and nested coffer transport pass without altering native dining travel.',
    'probe_findings':'Preserved private probe02/03 camp fixture used a wall location, fixed to clear geometry. Probe04 contact assertion inserted an older timestamp and expected the opposite FIFO order, fixed to the current stamp. Probe06 lacked actual Magic Box acquisition, corrected. Probe48 dining regression used an unmapped placement-permission diagnostic level; rerun on the mansion with established fixture. Failed probes are excluded.',
    'scope':'Ten native vessel exteriors, retained contents, camp owner boundary, nested carrier exposure and shielding, model-only contact endpoints, real current save/load/hub, actual 5.8.47 migration and original-runtime rollback.',
    'limits':'Thermal equivalent geometry, not mesh surface. No separate uncalibrated handles/straw area. No water-content, ingestion, recipe, mass, price or artwork change. Other physical-material/food/contact adapters remain pending.',
    'performance':'No global or per-unit scan added. Existing per-lot exposure scheduler reused; nested contents inspect only the owned fixed-capacity dining roster. No new FPS or presentation claim; prior matched stack timing remains scoped to 5.8.47.',
    'author_acceptance':'CA502-VESSELS-01 pending final grouped V5.8 handoff; no author check removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
