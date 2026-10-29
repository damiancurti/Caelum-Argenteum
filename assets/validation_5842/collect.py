"""Collect literal native assertions and exact release/source evidence."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
from functools import lru_cache
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent
W=R/'build/issue502-furnishing';N=H/'native';N.mkdir(exist_ok=True)
@lru_cache(maxsize=None)
def digest(p):
    with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
package=W/'final42a/caelum_argenteum_dev.pk3';prior=W/'prior41/caelum_argenteum_dev.pk3'
def collect(label,runtime):
    log=(W/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    run=json.loads((W/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    assert not re.search(r'CA502H FAIL|VM execution aborted|Script error|fail(?:ed|ures)=[1-9]|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
    count=len(re.findall(r'^CA502H PASS ',log,re.M));assert count>0,label
    assert run['package_sha256'].lower()==digest(runtime),label
    for suffix in ['.txt','-run.json']:shutil.copy2(W/(label+suffix),N/(label+suffix))
    return {'label':label,'executed_passes':count,'package_sha256':digest(runtime),'addon_sha256':run['addon_sha256'].lower()}
cases=['seed','reload','away-load','samehub','core','clean','clean-load','migration','reg-core','reg-shortages','reg-skipped']
rows=[collect('release-'+n,package) for n in cases]
original=[collect('prior01-'+n,prior) for n in ['seed','rollback']]
with zipfile.ZipFile(package) as z,zipfile.ZipFile(prior) as old:
    source={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(z.read(n)==old.read(n) for n in kept)
static=json.loads((W/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.42' and not static['errors']
(H/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
perf=(W/'release-core.txt').read_text(encoding='utf-8',errors='replace')
match=re.search(r'CA502H TIMING furnishings=(\d+) targets=(\d+) mean_ms=([\d.]+) p95_ms=([\d.]+) max_ms=([\d.]+)',perf);assert match
report={'version':'5.8.42','issue':502,'base':'6544753fce7d436ca7c25be0269c54647d3ff54d',
    'runtime_sha256':digest(package),'source_matching_package_members':len(source),'unchanged_map_art_members':len(kept),
    'native_passes':sum(r['executed_passes'] for r in rows),'original_runtime_passes':sum(r['executed_passes'] for r in original),
    'native_failures':0,'runs':rows,'original_runs':original,'prior_save_sha256':digest(W/'furniture-prior41.zds'),
    'timing':{'furnishings':int(match[1]),'targets':int(match[2]),'mean_ms':float(match[3]),'p95_ms':float(match[4]),'max_ms':float(match[5]),
        'scope':'20 synchronous real-house capture/restore callbacks, not displayed frames or FPS evidence.'},
    'scope':'Automatic departure capture and once-only restoration of furnishing contamination and natural exposure. Native same-hub/cross-hub returns, save while absent, later cleaning/save/return, actual5.8.41 migration and original-save rollback. Exact fields, source climate/seal termination, missing history and class mismatch checked.',
    'limits':'Only existing housekeeping furniture targets; this does not add exposure eligibility to non-solid table bodies, preserve other furnishing properties, or implement automatic unloaded purchases/work, NPC physiology or remaining contact adapters. No balance/art/maps changed.',
    'probe_findings':'A reserved state identifier and case-insensitive Key/key shadow were caught before final validation and corrected. An overbroad fixture requirement that every body have an exposure node was narrowed to existing exposed types; non-solid eligibility remains explicitly pending. Failed probes are retained under private build, never counted as final passes.',
    'author_acceptance':'Pending CA502-HOME-FURNISHINGS-01, held for grouped final V5.8 handoff. Earlier pending entries retained.'}
(H/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','native_failures','runtime_sha256','source_matching_package_members','unchanged_map_art_members','timing']}))
