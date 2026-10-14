"""Collect focused final evidence without packaging native development data."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue232'
RUNS=['core-02','reload-02','hooks-03','blocked-01','transport-05',
      'old-save-01','migration-02','hub-02','privacy-03','layout-01',
      'author-delay-map04-02']

def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def saved(name,map_id='map03'):
    with zipfile.ZipFile(WORK/(name+'.zds')) as archive:
        return json.loads(archive.read(map_id+'.map.json'))
def objects(data,kind): return [o for o in data['objects'] if o['classtype']==kind]
def record(data): return objects(data,'CaelumPersistentCharacterState')[0]['class:CaelumPersistentCharacterState']
def facts(data):
    return sorted((o['class:CaelumKnownPoi'] for o in objects(data,'CaelumKnownPoi')),key=lambda o:(o['MapId'],o['PoiId']))

runtime=digest(WORK/'production.pk3')
tested_runtime=digest(WORK/'pre-version-labels.pk3')
with zipfile.ZipFile(WORK/'pre-version-labels.pk3') as before, zipfile.ZipFile(WORK/'production.pk3') as after:
    assert before.namelist()==after.namelist()
    changed=[n for n in before.namelist() if before.read(n)!=after.read(n)]
    assert set(changed)=={'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'},changed
    assert all(before.read(n).replace(b'5.3.4',b'5.3.5')==after.read(n) for n in changed)
records=[];captures=[]
(HERE/'captures').mkdir(exist_ok=True)
for label in RUNS:
    run=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code']==0 and 'CA232 DONE failures=0' in log,label
    assert not any(s in log for s in ('CA232 FAIL','Script error','VM execution aborted','This savegame needs')),label
    if run['production_sha256']:assert run['runtime_sha256'].lower() in (tested_runtime,runtime),label
    run['assertions']=log.count('CA232 PASS ');records.append(run)
    for name in (label+'.txt',label+'-run.json'):shutil.copyfile(WORK/name,HERE/name)
    for path in WORK.glob(label+'-*.png'):
        shutil.copyfile(path,HERE/'captures'/path.name)
        captures.append({'file':'captures/'+path.name,'sha256':digest(path)})

old=saved('c232-old');migrated=saved('c232-migrated')
new_record=record(migrated).copy()
for key in ('KnownPois','LocalKnowledgeRevision','LocalKnowledgeSerial'):new_record.pop(key,None)
current=saved('c232-known');reloaded=saved('c232-reloaded');returned=saved('c232-hubback')
checks={
 'old_save_all_prior_record_fields': record(old)==new_record,
 'old_save_native_automap':objects(old,'Automap')==objects(migrated,'Automap'),
 'old_save_native_linedefs':old['linedefs']==migrated['linedefs'],
 'current_reload_exact_facts':facts(current)==facts(reloaded),
 'current_reload_native_linedefs':current['linedefs']==reloaded['linedefs'],
 'hub_original_map_exact_facts':facts(current)==[x for x in facts(returned) if x['MapId']=='MAP03'],
 'hub_distinct_other_map_fact':len([x for x in facts(returned) if x['MapId']=='MAP04'])==1,
}
assert all(checks.values()),checks
validation=json.loads((WORK/'validate.txt').read_text(encoding='utf-8-sig'))
assert validation['errors']==[]
for name,source in [('validate.json','validate.txt'),('build.txt','build.txt')]:shutil.copyfile(WORK/source,HERE/name)
evidence={'issue':232,'version':'5.3.5','baseline_commit':'edf9aa76',
 'runtime_sha256':runtime,'tested_runtime_sha256':tested_runtime,'release_label_only_delta':changed,
 'runs':records,'native_assertions':sum(r['assertions'] for r in records),
 'save_comparisons':checks,'original_save_sha256':digest(WORK/'c232-old.zds'),
 'captures':captures,'author_acceptance':{'id':'CA232-01','status':'corrected MAP04 fixture retest pending',
   'report':'Merchant marker visible; bed/station missing with brief appearance/disappearance.'},
 'limits':['Fixture registrations; authored map catalogues remain #234.',
 'Native Use is scripted, not a physical input acceptance claim.',
 'Native bot privacy check does not certify multiplayer gameplay.',
 'Disabled coastal transport remains disabled; knowledge is not permission.']}
compile_run=json.loads((WORK/'final-compile-01-run.json').read_text(encoding='utf-8-sig'))
assert compile_run['exit_code']==0 and compile_run['runtime_sha256'].lower()==runtime
evidence['final_compile']=compile_run
with zipfile.ZipFile(WORK/'production.pk3') as a, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as b:
    assert set(a.namelist())==set(b.namelist()) and all(a.read(n)==b.read(n) for n in a.namelist())
evidence['normal_build_members_match_frozen']=True
reproduction='author-regression-01'
failed_log=(WORK/f'{reproduction}.txt').read_text(encoding='utf-8-sig')
assert 'CA232 DONE failures=2' in failed_log and failed_log.count('CA232 FAIL ')==2
evidence['handoff_failure_reproduction']={'label':reproduction,'map':'MAP03',
 'expected_failures':2,'cause':'Existing gallery cleanup retires bed/station fixtures before delayed Use.'}
for name in (reproduction+'.txt',reproduction+'-run.json'):
    shutil.copyfile(WORK/name,HERE/name)
for label in (reproduction,'author-delay-map04-02'):
    shutil.copyfile(WORK/f'{label}-exec.cfg',HERE/f'{label}-exec.cfg')
for name in ('final-compile-01-run.json','final-compile-01.txt'):shutil.copyfile(WORK/name,HERE/name)
(HERE/'evidence.json').write_bytes((json.dumps(evidence,indent=2)+'\n').encode())
print(f"Collected {len(records)} runs, {evidence['native_assertions']} assertions, {len(checks)} save comparisons and {len(captures)} captures.")
