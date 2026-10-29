"""Collect selected final native evidence without summing inherited RESULT counters."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue411-fire';OUT=HERE/'native';OUT.mkdir(exist_ok=True)
labels=['core-final03','pot-final03','wait-final03','ui-final03','load-final03','hub-final03b','taskload-final03b','potload-final03b','capture-final05','legacy-seed01','legacy-upgrade02','legacy-rollback02','seed-final02','taskseed-final02','potseed-final02']
rows=[]
for label in labels+['tent-regression-fire-final04']:
    source=ROOT/'build/issue411-placement' if label.startswith('tent-') else WORK
    raw=(source/(label+'.txt')).read_text(encoding='utf-8-sig',errors='replace')
    record=json.loads((source/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record.get('exit_code')==0 and not record.get('timed_out'),label
    assert not re.search(r'^CA411[FD] FAIL|Script error|VM execution aborted|^No map ',raw,re.M),label
    passes=len(re.findall(r'^CA411[FD] PASS ',raw,re.M));assert passes,label
    rows.append({'label':label,'passes':passes,'runtime_sha256':record['package_sha256'],'addon_sha256':record['addon_sha256']})
    for suffix in ('.txt','-run.json'):shutil.copyfile(source/(label+suffix),OUT/(label+suffix))
for label in ['perf-before01','perf-after01','perf-camp-final05']:
    for suffix in ('.txt','.json'):shutil.copyfile(WORK/(label+suffix),OUT/(label+suffix))
captures=HERE/'captures';captures.mkdir(exist_ok=True)
for name in ['fire-world.png','fire-lit.png','fire-menu.png']:shutil.copyfile(WORK/name,captures/name)
package=WORK/'final05/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z:
    for name in z.namelist():assert z.read(name)==(ROOT/'src'/name).read_bytes(),name
    count=len(z.namelist())
with zipfile.ZipFile(WORK/'final03/caelum_argenteum_dev.pk3') as a,zipfile.ZipFile(package) as b:
    changes=[n for n in b.namelist() if a.read(n)!=b.read(n)]
    assert all(n.startswith('models/caelum/world/camp/fire_') for n in changes)
report={'issue':411,'version':'5.8.13','runtime':'final05','sha256':hashlib.sha256(package.read_bytes()).hexdigest(),'source_matching_members':count,'passes':sum(row['passes'] for row in rows),'failures':0,'runs':rows,'changes_since_behavior_suite':changes,'author_acceptance':'Pending CA411-FIRE-01; author away','limitations':'Native single-player/private fixture checks and narrow callback measurements; not cooking, multiplayer, full V5.8 or global performance acceptance.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['passes','failures','sha256','source_matching_members']}))
