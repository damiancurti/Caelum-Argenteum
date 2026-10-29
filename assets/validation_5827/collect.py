"""Collect scoped interior-placement evidence and source/package equality."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue411-interior'
PREVIOUS=ROOT.parent/'issue410-reading-work/build/issue410-reading'
native=HERE/'native';native.mkdir(exist_ok=True)
runs=[(WORK,'interior-delivery-'+name,'CA411IN') for name in ['core','property','seed','resume','hub','migration02','city']]
runs += [(WORK,'interior-target07','CA411IN'),(PREVIOUS,'reading-interior-rollback','CA410RD')]
rows=[]
for folder,label,tag in runs:
    log=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not re.search(tag+r' FAIL|VM execution aborted|Script error|failed=[1-9]',log)
    rows.append({'label':label,'executed_passes':len(re.findall('^'+tag+' PASS ',log,re.M)),
                 'runtime_sha256':record['package_sha256'].lower(),'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ['.txt','-run.json']:shutil.copy2(folder/(label+suffix),native/(label+suffix))
package=WORK/'final27/caelum_argenteum_dev.pk3'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
with zipfile.ZipFile(package) as z:
    sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(sources)
    assert all(z.read(n)==p.read_bytes() for n,p in sources.items())
    with zipfile.ZipFile(PREVIOUS/'final26c/caelum_argenteum_dev.pk3') as old:
        kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        assert all(z.read(n)==old.read(n) for n in kept)
assert digest(WORK/'reading-progress.zds')==digest(PREVIOUS/'reading-progress.zds')
shutil.copy2(WORK/'interior-view.png',HERE/'interior-view.png')
result={'version':'5.8.27','issue':411,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,
        'source_matching_package_members':len(sources),'preserved_map_art_members':len(kept),
        'original_save_sha256':digest(WORK/'reading-progress.zds'),
        'migration':'No production schema changes. Original5.8.26 save forward-loaded and its untouched source reopened by original final26c runtime.',
        'performance_scope':'Only on-demand local placement permission changed; no new tick work, global census, render or physical dimensions. No new display/frame-rate claim.',
        'author_acceptance':'Pending CA411-INTERIOR-01; do not offer manual tests until allV5.8 is implemented.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ['native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members']}))
