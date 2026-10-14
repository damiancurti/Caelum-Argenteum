"""Collect exact native evidence and compare persistent records for issue #235."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue235'
RUNS = ['main-03', 'reload-03', 'terminal-01', 'migration-01', 'migration-notes-01',
        'hub-01', 'port-03', 'trial-01', 'presentation-en-01',
        'presentation-small-01', 'stages-01', 'navigation-02', 'presentation-large-02']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name) for name in archive.namelist()}


def saved(name):
    with zipfile.ZipFile(WORK/(name+'.zds')) as archive:
        map_id=json.loads(archive.read('info.json'))['Current Map'].lower()
        return json.loads(archive.read(map_id+'.map.json'))


def objects(data, kind):
    return [o for o in data['objects'] if o['classtype']==kind]


def record(data):
    result=objects(data,'CaelumPersistentCharacterState')[0]['class:CaelumPersistentCharacterState'].copy()
    for name in ('IdentityProfile','IdentityAllocation'):
        if name in result:
            result[name]=data['objects'][result[name]]
    for name in ('KnownPois','ManualNotes'):
        if name in result:
            result[name]=[data['objects'][i] for i in result[name]]
    return result


final=members(WORK/'production.pk3')
runtime=digest(WORK/'production.pk3')
variants={}
for archive in ('production.pk3','before-practice.pk3','before-overflow.pk3','before-menu-guard.pk3','before-whitespace.pk3'):
    earlier=members(WORK/archive)
    assert set(final)==set(earlier)
    changes=[name for name in final if final[name]!=earlier[name]]
    assert set(changes)<={'caelum/data/CaelumQuestTrackingData.zs','caelum/hud/CaelumCartography.zs',
                         'caelum/ui/CaelumLiveMenu.zs','caelum/equipment/CaelumPersistentCharacterState.zs',
                         'LANGUAGE','localization/INDEX.md','localization/index.json'}, changes
    assert final['LANGUAGE'].rstrip()==earlier['LANGUAGE'].rstrip()
    variants[digest(WORK/archive)]={'local_archive':archive,'different_members_from_final':changes}
runs=[];captures=[]
(HERE/'captures').mkdir(exist_ok=True)
for label in RUNS:
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    assert run['exit_code']==0 and 'CA235 DONE failures=0' in log,label
    assert not any(s in log for s in ('CA235 FAIL','Script error','VM execution aborted',
                                     'This savegame needs','Savegame is from a different level')),label
    assert run['runtime_sha256'].lower() in variants,label
    run['assertions']=log.count('CA235 PASS ')
    assert run['assertions']>0,label
    runs.append(run)
    for suffix in ('.txt','-run.json','-exec.cfg'):
        shutil.copyfile(WORK/(label+suffix),HERE/(label+suffix))
    for source in sorted(WORK.glob(label+'-*.png')):
        shutil.copyfile(source,HERE/'captures'/source.name)
        captures.append({'file':'captures/'+source.name,'sha256':digest(source)})

checks={}
before=saved('c235-before');tracked=saved('c235-tracked');reloaded=saved('c235-reloaded')
a,b=record(before),record(tracked)
a.pop('QuestTracked');b.pop('QuestTracked')
checks['tracking_changes_no_prior_record_value']=a==b
checks['tracking_keeps_native_automap']=objects(before,'Automap')==objects(tracked,'Automap')
checks['tracking_keeps_native_linedefs']=before['linedefs']==tracked['linedefs']
checks['reload_exact_whole_record']=record(tracked)==record(reloaded)
checks['reload_native_automap']=objects(tracked,'Automap')==objects(reloaded,'Automap')
checks['reload_native_linedefs']=tracked['linedefs']==reloaded['linedefs']
for source,target in [('c235-source537','c235-migrated-mansion'),('c235-source537-notes','c235-migrated-notes')]:
    old=saved(source);new=saved(target);a,b=record(old),record(new)
    checks[source+'_no_inferred_selection']=b.pop('QuestTracked')==[0]*32
    checks[source+'_revision_one']=b.pop('QuestTrackingRevision')==1
    checks[source+'_all_prior_record_values']=a==b
    checks[source+'_native_automap']=objects(old,'Automap')==objects(new,'Automap')
    checks[source+'_native_linedefs']=old['linedefs']==new['linedefs']
a,b=record(tracked),record(saved('c235-hubback'))
# Native travel legitimately persists these live survival/thermal observations.
for field in ('StoredSleep','StoredHunger','StoredThirst','ThermalState'):
    a.pop(field,None);b.pop(field,None)
checks['hub_all_other_record_values']=a==b
checks['offmap_original_known_places']=record(tracked)['KnownPois']==record(saved('c235-hub-sewers'))['KnownPois']
assert all(checks.values()),{k:v for k,v in checks.items() if not v}

validation=json.loads((WORK/'validate.json').read_text(encoding='utf-8-sig'))
assert validation['errors']==[]
assert members(ROOT/'build/caelum_argenteum_dev.pk3')==final
for name in ('validate.json','build.txt'):
    shutil.copyfile(WORK/name,HERE/name)
diagnostics=['compile-01','main-01','main-02','reload-01','reload-02','port-01','port-02','presentation-large-01','navigation-01']
for label in diagnostics:
    for suffix in ('.txt','-run.json','-exec.cfg'):
        p=WORK/(label+suffix)
        if p.exists():shutil.copyfile(p,HERE/p.name)
evidence={'issue':235,'version':'5.3.8','baseline_commit':'fc947471',
          'runtime_sha256':runtime,'runtime_variants':variants,'runs':runs,
          'native_assertions':sum(r['assertions'] for r in runs),'save_comparisons':checks,
          'captures':captures,'diagnostics':diagnostics,'normal_build_matches_frozen':True,
          'source537_save_sha256':digest(WORK/'c235-source537.zds'),
          'source537_notes_save_sha256':digest(WORK/'c235-source537-notes.zds'),
          'reuse':'Checked member differences cover the known practice-room association, the zero-row cartouche-fit fallback, a null guard in menu latch cleanup, a saved-field comment and trailing LANGUAGE whitespace with regenerated indexes. LANGUAGE equality after rstrip is asserted. Stage, large-scale, navigation and final reload cases exercise affected paths. Positive-budget cases do not enter the fallback; stored quest/runtime logic remains unchanged.',
          'author_acceptance':{'id':'CA235-01','status':'deferred until author returns'},
          'limits':['Diagnostic positioning and direct native UI action dispatch are not physical author acceptance.',
                    'Terminal/rescue/stage cases prepare isolated state; existing optional movement/reward/abandonment rules and the actual port deployment also run.',
                    'Port deployment invokes the production calendar deployment action early in a disposable copy; this does not certify a full battle.',
                    'Native save comparisons retain all prior record values; hub excludes four legitimately persisted survival/thermal observations.',
                    'No new exact NPC-disclosure event or hidden-content waypoint is inferred.',
                    'Multiplayer gameplay and physical controller input are not certified.']}
(HERE/'evidence.json').write_bytes((json.dumps(evidence,indent=2)+'\n').encode())
print(f"Collected {len(runs)} runs, {evidence['native_assertions']} assertions, {len(checks)} save comparisons, {len(captures)} captures.")
