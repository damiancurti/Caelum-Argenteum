"""Collect domestic evidence without counting serialized cumulative totals."""
from pathlib import Path
import hashlib, json, re, shutil, zipfile

root=Path(__file__).resolve().parents[2]
work=root/'build/issue502-hygiene'
out=root/'assets/validation_5812/domestic'
native=out/'native';native.mkdir(parents=True,exist_ok=True)
labels=['domestic-old-save01','domestic-delivery-rollback']
labels+=['domestic-delivery-'+x for x in ['core','load','hub','shortages','clock','skipped','economy','controls','legacy']]
labels+=['domestic-regression-'+x for x in ['object','npc','contact','calendar','accelerated']]
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
runs=[]
for label in labels:
    log=work/(label+'.txt');text=log.read_text(encoding='utf-8-sig')
    record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record.get('exit_code')==0 and not record.get('timed_out') and not record.get('startup_error'),label
    assert not re.search(r'^CA502[HMNCOD] FAIL|VM execution aborted|Script error|Fatal:',text,re.M),label
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),native/(label+suffix))
    runs.append({'label':label,'passed':len(re.findall(r'^CA502[HMNCOD] PASS ',text,re.M)), 'runtime_sha256':record['package_sha256'].lower(), 'fixture_sha256':record['addon_sha256'].lower(), 'log_sha256':digest(log)})
package=work/'domestic-final02/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as final,zipfile.ZipFile(work/'objects-final03/caelum_argenteum_dev.pk3') as old,zipfile.ZipFile(work/'domestic-final01/caelum_argenteum_dev.pk3') as intermediate:
    for name in final.namelist():assert final.read(name)==(root/'src'/name).read_bytes(),name
    changed=[name for name in final.namelist() if final.read(name)!=intermediate.read(name)]
    assert changed==['caelum/world/CaelumStashChest.zs'],changed
    untouched=[name for name in old.namelist() if name.startswith(('maps/','sprites/','models/','graphics/','textures/','patches/'))]
    for name in untouched:assert final.read(name)==old.read(name),name
    members=len(final.namelist())
performance=[]
for label in ['domestic-perf-before01','domestic-perf-delivery02']:
    for suffix in ['.txt','.json']:shutil.copy2(work/(label+suffix),out/(label+suffix))
    performance.append(json.loads((work/(label+'.json')).read_text(encoding='utf-8')))
report={'runtime':'domestic-final02','runtime_sha256':digest(package),'source_identical_members':members,'maps_and_art_unchanged':len(untouched),'executed_passes':sum(x['passed'] for x in runs),'failures':0,'runs':runs,'performance':performance,'reuse':'Object/NPC/contact/calendar core regressions ran on final01. The only subsequent runtime difference is coffer metadata exclusion, covered by final02 economy, controls, saves/hub and calendar acceleration. Their package hashes remain explicit.', 'author_acceptance':'CA502-HOUSEKEEPING-01 accepted 2026-10-25 without reported qualifications; separate treatment/toilet checks unchanged.'}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({key:report[key] for key in ['runtime_sha256','source_identical_members','executed_passes','failures']}))
