"""Collect executed reading checks and verify the final package against source."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-reading'
labels=['reading-delivery-core','reading-delivery-spanish','reading-delivery-view2']
labels+=['reading-final-'+x for x in ['limits','access','input','seed','resume','hub','view0','view1','oldseed','migration','rollback','label-smoke']]
native=HERE/'native';native.mkdir(exist_ok=True)
rows=[]
for label in labels:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert not re.search(r'CA410RD FAIL|VM execution aborted|Script error|failed=[1-9]',log)
    assert record['exit_code']==0
    rows.append({'label':label,'executed_passes':len(re.findall(r'^CA410RD PASS ',log,re.M)),
                 'runtime_sha256':record['package_sha256'].lower(),'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ['.txt','-run.json']:shutil.copy2(WORK/(label+suffix),native/(label+suffix))
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final26c/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as current:
    sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(current.namelist())==set(sources)
    assert all(current.read(name)==path.read_bytes() for name,path in sources.items())
    with zipfile.ZipFile(WORK/'previous25/caelum_argenteum_dev.pk3') as old:
        kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        assert all(current.read(n)==old.read(n) for n in kept)
    with zipfile.ZipFile(WORK/'final26/caelum_argenteum_dev.pk3') as first:
        changed=[n for n in current.namelist() if current.read(n)!=first.read(n)]
    assert set(changed)=={'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs','caelum/hud/CaelumNotifications.zs'}
performance=[]
for part in ['base','current']:
    name='reading-final-perf-'+part
    performance.append(json.loads((WORK/(name+'.json')).read_text(encoding='utf-8')))
    for suffix in ['.txt','.json']:shutil.copy2(WORK/(name+suffix),native/(name+suffix))
for i in range(3):shutil.copy2(WORK/('reading-view'+str(i)+'.png'),HERE/('view'+str(i)+'.png'))
result={'version':'5.8.26','issue':410,'runtime':'final26c','runtime_sha256':digest(package),
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,'runs':rows,
        'source_matching_package_members':len(sources),'preserved_map_art_members':len(kept),
        'final_runtime_changes_since_first_selected_runs':changed,
        'evidence_qualification':'Final26c corrects two diagnostic release labels and disambiguates the stored recipe-book name. Final26c repeats both languages/core and storage visual checks; unaffected access/limits/save/hub evidence uses final26. Migration/rollback and callback comparison use final26b or the exact previous package as recorded per run.',
        'performance':performance,'author_acceptance':'Pending CA410-READING-01; manual delivery deferred until V5.8 is complete.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ['native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members']}))
