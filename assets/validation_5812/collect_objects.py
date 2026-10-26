"""Collect world-object exposure evidence, counting executed assertions only."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
root=Path(__file__).resolve().parents[2];work=root/'build/issue502-hygiene'
out=root/'assets/validation_5812/objects';native=out/'native';native.mkdir(parents=True,exist_ok=True)
labels=['objects-old-save02','objects-final-legacy02','objects-final-migrated-hub02','objects-old-rollback02',
        'objects-final-core02','objects-final-rain02','objects-final-storage02',
        'objects-final-save02','objects-final-load02','objects-final-hub02','objects-city-census01',
        'objects-reg-contact01','objects-reg-npc01','objects-reg-combat01','objects-reg-calendar01']

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
runs=[]
for label in labels:
    log=work/(label+'.txt');data=log.read_text(encoding='utf-8-sig')
    assert not re.search(r'^CA502[HMNCO] FAIL|VM execution aborted|Script error',data,re.M),label
    record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record.get('exit_code')==0 and not record.get('timed_out'),label
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),native/(label+suffix))
    runs.append({'label':label,'passed':len(re.findall(r'^CA502[HMNCO] PASS ',data,re.M)),
                 'failed':0,'runtime_sha256':record['package_sha256'].lower(),
                 'fixture_sha256':record['addon_sha256'].lower(),'log_sha256':digest(log)})
runtime=work/'objects-final03/caelum_argenteum_dev.pk3'
tested=work/'objects-final02/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(tested) as before,zipfile.ZipFile(runtime) as after:
    assert before.namelist()==after.namelist()
    changed=[name for name in before.namelist() if before.read(name)!=after.read(name)]
    assert changed==['caelum/survival/CaelumContaminationObject.zs'],changed
    def without_comment_lines(data):
        return b'\n'.join(line for line in data.splitlines() if not line.lstrip().startswith(b'//'))
    for name in changed:assert without_comment_lines(before.read(name))==without_comment_lines(after.read(name)),name
smoke_label='objects-final-smoke03'
smoke=json.loads((work/(smoke_label+'-run.json')).read_text(encoding='utf-8-sig'))
smoke_text=(work/(smoke_label+'.txt')).read_text(encoding='utf-8-sig')
assert smoke.get('exit_code')==0 and not smoke.get('timed_out') and not smoke.get('startup_error')
assert not re.search(r'Script error|VM execution aborted|Fatal:',smoke_text)
assert smoke['package_sha256'].lower()==digest(runtime)
for suffix in ['.txt','-run.json']:shutil.copy2(work/(smoke_label+suffix),native/(smoke_label+suffix))
with zipfile.ZipFile(runtime) as z,zipfile.ZipFile(work/'contact-final01/caelum_argenteum_dev.pk3') as old:
    for name in z.namelist():assert z.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in old.namelist() if n.startswith('maps/')]
    art=[n for n in old.namelist() if n.startswith(('sprites/','models/','graphics/','textures/','patches/'))]
    for name in maps+art:assert z.read(name)==old.read(name),name
    members=len(z.namelist())
perf=[]
for label in ['objects-perf-baseline01','objects-perf-final01']:
    record=json.loads((work/(label+'.json')).read_text(encoding='utf-8'));perf.append(record)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(work/(label+suffix),native/(label+suffix))
assert perf[0]['receivers_exposed']==0 and perf[1]['receivers_exposed']==1000
failures=out/'development-failures';failures.mkdir(exist_ok=True)
for label in ['objects-smoke01','objects-core01','objects-core02','objects-core03','objects-core04','objects-rain01','objects-rain02','objects-hub01']:
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),failures/(label+suffix))
report={'runtime':'objects-final03','runtime_sha256':digest(runtime),'source_identical_members':members,
        'functional_runtime':'objects-final02','functional_runtime_sha256':digest(tested),
        'final_source_verification':{'changed_members':changed,'only_full_line_comments_changed':True,
                                     'native_smoke':smoke_label,'native_exit_code':smoke['exit_code']},
        'unchanged_maps':len(maps),'unchanged_art_members':len(art),'runs':runs,
        'executed_passes':sum(r['passed'] for r in runs),'failures':0,'performance':perf,
        'author_acceptance':'CA502-OBJECTS-01 accepted 2026-10-25; accepted contact, NPC, combat and calendar checks retained.'}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['executed_passes','failures','runtime_sha256','source_identical_members','unchanged_maps','unchanged_art_members']}))
