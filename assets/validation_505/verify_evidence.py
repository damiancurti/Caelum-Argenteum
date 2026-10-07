"""Check that published #121 timing windows are completed, configured and traceable."""
import hashlib
import json
from pathlib import Path
import re
import summarize

HERE=Path(__file__).resolve().parent
report=json.loads((HERE/'RESULTS.json').read_text(encoding='utf-8'))
checks=[]
for label in summarize.LABELS:
    data=report['runs'][label]
    raw=(HERE/f'{label}.txt').read_bytes()
    metadata=json.loads((HERE/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert metadata.get('completed_utc'),label
    assert metadata['last_sim_tic']==data['sim'][-1]['tic'],label
    expected=3500 if label in ['baseline-b','instrument-a','combined-a','combined-b'] else 1715 if label.startswith('formation') else 2100
    assert data['sim'][-1]['tic']>=expected,label
    assert hashlib.sha256(raw).hexdigest()==data['log_sha256'],label
    assert all(r['roster']==6001 for r in data['sim']),label
    assert data['settings']==[{'pause':0,'lower':0,'render':1,'sound':1,'volume':0.05}],label
    assert not re.search(rb'Script error,|VM execution aborted|CA121 unbalanced|CA121 GUARD_MISMATCH',raw),label
    for key in ['engine_sha256','iwad_sha256','package_sha256','addon_sha256']:
        assert re.fullmatch('[0-9A-Fa-f]{64}',metadata[key]),(label,key)
    if label.startswith('formation'):
        assert len(data['formation_initialization'])==1,label
        init=data['formation_initialization'][0]
        expected_size=1 if label.startswith('formation1-') else 100
        assert init['members']==6000 and init['size']==expected_size and init['groups']==6000//expected_size,label
    checks.append({'run':label,'last_tic':data['sim'][-1]['tic'],'hash_and_settings_verified':True})

for pair in ['baseline-b__instrument-a__common','baseline-c__instrument-b__common',
             'baseline-b__instrument-a__later','baseline-c__events-a__common']:
    assert report['comparisons'][pair]['comparable_behavior'],pair
oracle=report['runs']['guard-check-a']['guard_verification_rows']
assert len(oracle)==756 and {r['machine'] for r in oracle}==set(range(12))
assert max(r['tic'] for r in oracle)==2205
for label,minimum in [('gpu-late-a',2345),('gpu-formation-a',1715),('production-a',1015)]:
    record=json.loads((HERE/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert record['completed_utc'] and record['last_sim_tic']>=minimum,label
    raw=(HERE/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert not re.search(r'Script error,|VM execution aborted|CA121 unbalanced',raw),label
visual=json.loads((HERE/'VISUAL_CHECKS.json').read_text())
for row in visual['captures']:
    assert hashlib.sha256((HERE/row['file']).read_bytes()).hexdigest()==row['sha256'],row['file']
power=json.loads((HERE/'POWER_REQUEST.json').read_text(encoding='utf-8-sig'))
assert power['released_utc'] and power['release_result']
assert power['active_plan_before']==power['active_plan_after']
assert not (HERE.parents[1]/'pending_test.txt').read_bytes()
result={'checks':checks,'ordinary_scene_comparisons':4,'guard_oracle_rows':len(oracle),
        'guard_mismatches':0,'additional_visual_and_production_runs':3,'power_request_released':True,'author_acceptance':False,
        'qualification':'Scene-row equality is not a full-state/save proof. Diagnostic changes remain outside production.'}
(HERE/'EVIDENCE_VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n')
print(f'PASS: {len(checks)} comparison runs plus 3 visual/production runs, four ordinary scene comparisons, {len(oracle)} guard oracle rows; power request released.')
