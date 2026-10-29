"""Collect final native evidence without treating saved cumulative counters as new tests."""
from pathlib import Path
from functools import lru_cache
import hashlib
import json
import re
import shutil
import zipfile

R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-contact'
N=H/'native';N.mkdir(exist_ok=True)
CURRENT=W/'final45a/caelum_argenteum_dev.pk3';PRIOR=W/'prior44/caelum_argenteum_dev.pk3'
@lru_cache(None)
def digest(p):
    with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def collect(folder,label,package,prefix):
    log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA502[AD] FAIL|Script error|VM execution aborted|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
    count=len(re.findall(r'^'+prefix+r' PASS ',log,re.M));assert count>0,label
    assert run['package_sha256'].lower()==digest(package),label
    for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),N/(label+suffix))
    return {'label':label,'executed_passes':count,'runtime_sha256':digest(package),'addon_sha256':run['addon_sha256'].lower()}
current=[collect(W,'release-'+case,CURRENT,'CA502D') for case in ['core','input','seed','hub','resume','upgrade']]
reg=[collect(R/'build/issue502-housekeeping','dining-reg-'+case,CURRENT,'CA502A') for case in ['core','shortages']]
prior=[collect(W,label,PRIOR,'CA502D') for label in ['original44-seed','release-rollback']]
with zipfile.ZipFile(CURRENT) as z,zipfile.ZipFile(PRIOR) as old:
    files={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(files)==set(z.namelist())
    assert all(z.read(n)==p.read_bytes() for n,p in files.items())
    art=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(old.read(n)==z.read(n) for n in art)
static=json.loads((H/'static-validation.json').read_text(encoding='utf-8'))
assert static['version']=='5.8.45' and not static['errors']
report={'version':'5.8.45','issue':502,'base':'666328b5515a906a45294df49c15bb5c6b9fc8e3',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(files),'unchanged_map_art_members':len(art),
    'native_passes':sum(x['executed_passes'] for x in current+reg),'original_runtime_passes':sum(x['executed_passes'] for x in prior),
    'native_failures':0,'runs':current,'regressions':reg,'original_runs':prior,
    'prior_save_sha256':digest(W/'contact-prior44.zds'),
    'scope':'Logical dining contamination, physical native support contact, adjacent-cell dose deduplication, saved duplicate links, full collision-envelope exposure, distinct chairs, real packing/redeployment, native save/hub, genuine prior-runtime migration and rollback; household access/resources regressions.',
    'probe_findings':'Native compiler rejected a subclass/base-class ternary; explicit return corrected it. The fixture initially used an obsolete mansion slot, then selected an actual table. Array.Find missing-value semantics were corrected to a size assertion. Failed private probes are retained, excluded from final evidence.',
    'performance':'No new routine global scans. Migration touches at most 32 owned cells once per table. Native home access regression: 856 targets, mean3.095135/p953.128900/max3.357000ms over20 runs. This is a subsystem timing, not displayed-FPS acceptance; no art/map/geometry changes.',
    'author_acceptance':'CA502-DINING-CONTACT-01 remains pending the requested grouped final V5.8 handoff. No prior pending entry removed.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
