"""Verify #249 native evidence, deterministic fixtures and ordinary packaging."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
groups={
    'issue249-native10':['placement','contract','casting','save','journey','pending','death','combat','load','pending-load','failure'],
    'issue249-delivery':['save-prep','load-prep'],
    'issue249-ready':['flight'],'issue249-final':['preview'],
    'issue249-seed':['seed'],'issue249-upgrade':['upgrade'],
    'issue249-rollback':['rollback'],'issue249-return':['return'],
}
final=ROOT/'build/issue249-final/production.pk3';old=ROOT/'build/issue248-delivery/production.pk3'
tested=ROOT/'build/issue249-ready/production.pk3'
with zipfile.ZipFile(tested) as a,zipfile.ZipFile(final) as b:
    assert a.namelist()==b.namelist()
    changed=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert set(changed)=={'LANGUAGE','localization/INDEX.md','localization/index.json'},changed
    assert a.read('LANGUAGE').replace(b'\r\n',b'\n')==b.read('LANGUAGE')
runs=[]
for directory,labels in groups.items():
    folder=ROOT/'build'/directory
    expected=sha(old) if directory in ['issue249-seed','issue249-rollback'] else sha(final if directory=='issue249-final' else tested)
    for label in labels:
        log=folder/(label+'.txt');record=folder/(label+'-run.json')
        text=log.read_text(encoding='utf-8-sig');meta=json.loads(record.read_text(encoding='utf-8-sig'))
        assert not re.search(r'CA249 FAIL|Script error|JIT error|REGT_ADDROF|VM execution aborted|DIED WITH FATAL ERROR',text),(directory,label)
        found=re.search(r'CA249 DONE failures=0 passed=(\d+)',text);assert found,(directory,label)
        assert meta['exit_code']==0 and meta['runtime_sha256'].lower()==expected
        assert meta['fixture_sha256'].lower()==sha(folder/'summoning.pk3')
        runs.append({'label':directory+'/'+label,'passes':int(found[1]),'checks':re.findall(r'^CA249 PASS (.*)$',text,re.M),
            'log_sha256':sha(log),'run_record_sha256':sha(record),**meta})
for package in ['production.pk3','summoning.pk3']:
    assert sha(ROOT/'build/issue249-final'/package)==sha(ROOT/'build/issue249-final-repro'/package),package
with zipfile.ZipFile(final) as z,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    members=z.namelist();assert set(members)==set(normal.namelist())
    for name in members:assert z.read(name)==normal.read(name)==(ROOT/'src'/name).read_bytes(),name
saves={}
for directory in ['issue249-upgrade','issue249-rollback','issue249-return']:
    folder=ROOT/'build'/directory;manifest=json.loads((folder/'manifest.json').read_text())
    assert sha(folder/'input.zds')==manifest['original_save_sha256']
    saves[directory]=manifest['original_save_sha256']
validation=json.loads((ROOT/'build/issue249-validation.json').read_text(encoding='utf-8-sig'))
assert validation['version']=='5.4.18' and not validation['errors']
result={'issue':249,'version':'5.4.18','date':'2026-10-15','runtime_sha256':sha(final),
    'static_validation':{'command':'python validate_project.py','exit_code':0,**validation},
    'normal_build':{'command':'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1','exit_code':0,'files_included':len(members),'log_sha256':sha(ROOT/'build/issue249-build.txt')},
    'normal_package_matches_src_and_frozen_runtime':True,'deterministic_runtime_and_fixture':True,
    'native_assertions':sum(r['passes'] for r in runs),'native_runs':runs,
    'qualified_reuse':{'tested_runtime_sha256':sha(tested),'changed_members':changed,'reason':'Only LANGUAGE CRLF-to-LF normalization and regenerated localization indexes differ. Every gameplay ZScript and other asset is byte-identical. Final preview compiles/runs the deliverable and final static validation checks the normalized indexes. Native10/delivery addons precede extra preparation/flight/manual helpers; no duplicate preview is counted.'},
    'copied_save_sha256':saves,'author_acceptance':'Pending CA249-01.',
    'visual_review':{'path':'build/issue249-final/active.png','sha256':sha(ROOT/'build/issue249-final/active.png'),
        'result':'Agent inspected the existing Zupay art, readable Spanish resource/lifetime overlay and native class cooldown HUD. The enemy loses HP while the allied target does not. Physical-input acceptance remains pending.'},
    'diagnostics':[
        'initial/contract: GZDoom JIT rejects scripted out Vector3 with Unknown REGT / REGT_ADDROF not implemented for vectors; exit code alone was zero. A result object removes the unsupported output parameter, and the runner now also watches JIT errors and requires a completion marker.',
        'native02/contract: fixture compared derived Health against stale actor default 44022. It now compares the initialized base profile; actual current body health/stat tests pass.',
        'native03/load: static handler expectations are not serialized. A test-only inventory checkpoint now preserves expected identity/resources across save and hub, and final checks pass.',
        'native04/combat: fixture Vector3(...) constructor was invalid; vector tuple expression compiles.',
        'native05-07/combat: native friendly wandering moved away from the caster. Explicit collision-aware owner following, with native obstacle fallback, passes native08 and final combat.',
        'native09/placement: fixture passed a player where aura eligibility expects an effect. Correct owned test effects compile and the final pending-state checks pass.'
    ],
    'limitations':['Author acceptance is pending; no broad campaign, multiplayer, large-map performance or other class delivery claim.',
        'Rollback to 5.4.17 uses an optional inert-class bridge on copied saves, cancelling unsupported summon/preparation without refund. It does not restore an expired summon; the original save is untouched.']}
acceptance_path=HERE/'acceptance.json'
if acceptance_path.exists():
    acceptance=json.loads(acceptance_path.read_text(encoding='utf-8'))
    assert acceptance['result']=='passed' and acceptance['test_id']=='CA249-01'
    result['author_acceptance']=acceptance
    result['visual_review']['result']=result['visual_review']['result'].replace('Physical-input acceptance remains pending.', 'Author acceptance CA249-01 passed on 2026-10-15.')
    result['limitations'][0]='Author acceptance covers the offered CA249-01 scenario; no broad campaign, multiplayer, large-map performance or other class delivery claim.'
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'assertions':result['native_assertions'],'runs':len(runs),'members':len(members),'runtime':result['runtime_sha256']}))
