"""Collect native contact evidence, counting executed assertions only."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
root=Path(__file__).resolve().parents[2];work=root/'build/issue502-hygiene'
out=root/'assets/validation_5812/contact';native=out/'native';native.mkdir(parents=True,exist_ok=True)
labels=['contact-old-save01','contact-final-legacy02','contact-final-migrated-hub02',
        'contact-old-rollback01','contact-final-core02','contact-final-clock02',
        'contact-final-save02','contact-final-load02','contact-final-hub02',
        'contact-reg-npc01','contact-reg-combat01','contact-reg-calendar01']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
runs=[]
for label in labels:
    log=work/(label+'.txt');data=log.read_text(encoding='utf-8-sig')
    assert not re.search(r'^CA502[HMNC] FAIL|VM execution aborted|Script error',data,re.M),label
    record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record.get('exit_code')==0 and not record.get('timed_out'),label
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),native/(label+suffix))
    runs.append({'label':label,'passed':len(re.findall(r'^CA502[HMNC] PASS ',data,re.M)),
                 'failed':0,'runtime_sha256':record['package_sha256'].lower(),
                 'fixture_sha256':record['addon_sha256'].lower(),'log_sha256':digest(log)})
runtime=work/'contact-final01/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(runtime) as z,zipfile.ZipFile(work/'npc-final02/caelum_argenteum_dev.pk3') as old:
    for name in z.namelist():assert z.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in old.namelist() if n.startswith('maps/')]
    art=[n for n in old.namelist() if n.startswith(('sprites/','models/','graphics/','textures/','patches/'))]
    for name in maps+art:assert z.read(name)==old.read(name),name
    members=len(z.namelist())
perf=[]
for label in ['contact-perf-baseline01','contact-perf-final01']:
    record=json.loads((work/(label+'.json')).read_text());perf.append(record)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(work/(label+suffix),native/(label+suffix))
assert perf[0]['receivers_exposed']==0 and perf[1]['receivers_exposed']==500
failures=out/'development-failures';failures.mkdir(exist_ok=True)
for label in ['contact-core01','contact-core02','contact-core03','contact-core04','contact-hub01','contact-final-legacy01']:
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),failures/(label+suffix))
report={'runtime':'contact-final01','runtime_sha256':digest(runtime),'source_identical_members':members,
        'unchanged_maps':len(maps),'unchanged_art_members':len(art),'runs':runs,
        'executed_passes':sum(r['passed'] for r in runs),'failures':0,'performance':perf,
        'author_acceptance':'CA502-CONTACT-01 pending; NPC, combat and calendar author acceptance retained.'}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['executed_passes','failures','runtime_sha256','source_identical_members','unchanged_maps','unchanged_art_members']}))
