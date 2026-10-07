"""Verify functional/oracle outcomes and summarize work counts, not GPU FPS."""
from pathlib import Path
import hashlib
import json
import re
import statistics

HERE=Path(__file__).resolve().parent
WORK=HERE.parents[1]/'build/issue128'

def raw(label):
    path=HERE/(label+'.txt')
    s=path.read_text(encoding='utf-8-sig')
    assert not re.search(r'Script error,|VM execution aborted|CA128 FAIL|Unable to resolve all fields',s),label
    return s
def rows(label,kind):
    return [{k:float(v) if '.' in v else int(v) for k,v in re.findall(r'(\w+)=(-?\d+(?:\.\d+)?)',line)}
            for line in raw(label).splitlines() if line.startswith('CA128 '+kind+' ')]
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

assert 'CA128 COMPLETE checks=38 failures=0' in raw('final-checks-b')
negative=(HERE/'register-before-a.txt').read_text(encoding='utf-8-sig')
expected='CA128 FAIL tic=10 NOBLOCKMAP registration after census is observed in the same tic'
assert negative.count('CA128 FAIL')==1 and expected in negative
assert not re.search(r'Script error,|VM execution aborted',negative)
assert json.loads((HERE/'register-before-a-run.json').read_text(encoding='utf-8-sig'))['negative_control_verified']
power=json.loads((HERE/'POWER_REQUEST.json').read_text(encoding='utf-8-sig'))
assert power['released_utc'] and power['release_result']>0
assert power['active_plan_before']==power['active_plan_after']
assert 'save or hub return restores population from actors' in raw('final-load-b')
travel=raw('final-travel-b')
assert re.search(r'LOADED_STATE map=QA128B .*alive=1 active=0 bodies=0',travel)
assert re.search(r'LOADED_STATE map=QA128A .*alive=500 active=1 bodies=500',travel)
for label in ['old-save-upgrade-a','old-save-reload-a','old-save-rollback-a']:
    s=raw(label)
    assert 'PORT16 deployed' not in s,label
    assert re.search(r'CA121 SIM .*roster=6001',s),label
    if label!='old-save-rollback-a':assert re.search(r'CA128 BATTLE .*active=1 revision=2',s),label
save=json.loads((HERE/'SAVE_IDENTITY.json').read_text())
assert digest(WORK/'ca121_late_baseline-c.zds')==save['sha256']
guard=rows('final-guard-a','GUARD_VERIFIED')
assert {r['machine'] for r in guard}==set(range(12))
assert max(r['tic'] for r in guard)>=3500
cannon=rows('final-cannon-a','CANNON_VERIFIED')
assert cannon and 'CANNON_ORACLE_SKIP' not in raw('final-cannon-a')
reference=re.findall(r'CA128 CANNON_CASE .*',raw('cannon-reference-a'))
tested=re.findall(r'CA128 CANNON_CASE .*',raw('cannon-final-a'))
assert len(reference)==96 and reference==tested
work={}
for label in ['count-current-a','count-demand-a','count-unshared-a','count-pruned-a']:
    samples=[r for r in rows(label,'WORK') if 35<=r['tic']<735]
    assert len(samples)==700,(label,len(samples))
    work[label]={k:{'total':sum(r[k] for r in samples),'peak_per_tic':max(r[k] for r in samples),
                    'mean_per_tic':statistics.mean(r[k] for r in samples)}
                 for k in ['queries','lists','visits','cannonQueries','cannonSight']}
battle=[r for r in rows('final-visual-a','BATTLE') if r['tic']>=35]
assert battle and min(r['active'] for r in battle)==1
assert all(r['reduced']==0 and r['incomplete']==0 and r['revision']==2 for r in battle)
assert battle[-1]['damage']>0 and battle[-1]['deaths']>0 and battle[-1]['cannonShots']>0
output={'issue':128,'functional_checks':38,'functional_failures':0,
        'same_tic_registration_negative_control_verified':True,
        'keep_awake_released_power_plan_unchanged':True,
        'thresholds':[499,500,501],'native_death_removal_revival_verified':True,
        'cold_load_and_hub_return':[500,1,500],'old_save_upgrade_reload_rollback':True,
        'old_save_sha256_unchanged':save['sha256'],
        'guard_oracle':{'periodic_rows':len(guard),'machines':12,'last_tic':max(r['tic'] for r in guard),'omitted':0},
        'cannon_oracle':{'queries':len(cannon),'last_query_tic':max(r['tic'] for r in cannon),'mismatches':0,'skipped':0},
        'cannon_invisibility_cases_and_native_rng_equal':96,'work_counts':work,'final_battle':battle[-1],
        'test_limitations':['Work-count and oracle runs are not performance measurements.',
                            'Author acceptance is separate from native automated checks.']}
(HERE/'NATIVE_VERIFICATION.json').write_text(json.dumps(output,indent=2)+'\n')
print(json.dumps(output,indent=2))
