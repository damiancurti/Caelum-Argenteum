"""Verify #136 follow-up evidence without replacing the original delivery manifest."""
from pathlib import Path
import hashlib,json,re,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue136'
RUNS={
    'activity-delivery':r'CA136 BUDGET COMPLETE checks=36 failures=0',
    'heat-delivery':r'CA136 HEAT COMPLETE',
    'motion-delivery':r'CA136 HEAT COMPLETE',
    'fire-delivery':r'CA136 HEAT COMPLETE',
    'swim-high-delivery':r'CA136 HEAT COMPLETE',
    'swim-normal-delivery':r'CA136 HEAT COMPLETE',
    'push-high-delivery':r'CA136 HEAT COMPLETE',
    'activity-reload-delivery':r'CA136 HEAT RELOAD PASS',
    'catalogue-followup':r'CA136 COMPLETE checks=49 failures=0',
    'fp-final':r'CA136 FP COMPLETE',
    'calor-rollback-final':r'original exposure=24.268683 activity=6393.362475 hp=1092 revision=6',
}

def sha(data):return hashlib.sha256(data).hexdigest()
def records(label):
    log=(HERE/(label+'.txt')).read_text(encoding='utf-8-sig')
    return [{k:float(v) for k,v in re.findall(r'(\w+)=(-?\d+\.\d+|-?\d+)(?= |$)',line)}
            for line in log.splitlines() if line.startswith('CA136 HEAT sec=')]

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish native testing first.')
    validation=subprocess.run([sys.executable,str(ROOT/'validate_project.py')],cwd=ROOT,capture_output=True,check=True)
    (HERE/'FOLLOWUP_VALIDATOR.json').write_bytes(validation.stdout)
    payload={p.relative_to(ROOT/'src').as_posix():sha(p.read_bytes()) for p in (ROOT/'src').rglob('*') if p.is_file()}
    packages={}
    for path in [ROOT/'build/caelum_argenteum_dev.pk3',OUT/'production.pk3',OUT/'heat-fixed/caelum_argenteum_dev.pk3']:
        with zipfile.ZipFile(path) as z:members={n:sha(z.read(n)) for n in z.namelist() if not n.endswith('/')}
        assert members==payload, str(path)+' differs from final source'
        packages[str(path.relative_to(ROOT))]=sha(path.read_bytes())
    runs={}
    for label,expected in RUNS.items():
        record=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        log=(HERE/(label+'.txt')).read_text(encoding='utf-8-sig')
        assert record['exit_code']==0 and re.search(expected,log),label
        assert not re.search(r'CA136 FAIL|CA136 HEAT RELOAD FAIL|VM execution aborted|Script error,|DIED WITH FATAL ERROR',log),label
        if label!='calor-rollback-final':assert record['package_sha256'].lower() in packages.values(),label+' used a different payload'
        runs[label]={'package_sha256':record['package_sha256'],'addon_sha256':record['addon_sha256'],
                     'log_sha256':sha((HERE/(label+'.txt')).read_bytes()),'exit_code':0}
    original=records('heat-baseline-a');fixed=records('heat-delivery');motion=records('motion-delivery');fire=records('fire-delivery')
    assert fixed[-1]['E']<fixed[0]['E'] and original[-1]['E']>original[0]['E']
    assert all(r['activity']==0 and r['motionJ']==fixed[0]['motionJ'] for r in fixed)
    assert any(r['water']==3 and r['net']<0 for r in fixed)
    assert motion[-1]['damage']==0 and motion[-1]['rescues']==0 and motion[-1]['activity']==0
    assert fire[-1]['damage']==0 and fire[-1]['rescues']==0 and fire[-1]['motionJ']==0 and fire[-1]['actionJ']>0
    for label in ['swim-normal-delivery','swim-high-delivery','push-high-delivery']:
        samples=records(label)
        assert samples[-1]['activity']==0 and samples[-1]['damage']==0 and samples[-1]['rescues']==0,label
        assert any(abs(r['activity']-637.260389)<0.00001 for r in samples),label
        maximum=637.260389 if label.startswith('push') else 1147.068701
        assert abs(max(r['activity'] for r in samples)-maximum)<0.00001,label
    power=json.loads((ROOT/'build/issue140/power-136-followup.json').read_text(encoding='utf-8-sig'))
    assert power['released_utc'] and power['active_plan_before']==power['active_plan_after']
    (HERE/'FOLLOWUP_POWER.json').write_text(json.dumps(power,indent=2)+'\n',encoding='utf-8')
    for name in ['fp-ready','fp-aim','fp-open','fp-load','fp-single','fp-partial','carbine-ready','carbine-aim']:
        (HERE/f'fp-final-{name}.png').write_bytes((OUT/f'fp-final-{name}.png').read_bytes())
    subprocess.run(['git','diff','--check'],cwd=ROOT,check=True)
    record={'issue':136,'release':'5.1.7','baseline_commit':'0dfa718e003c4d2f16a78dd41e038698c7cd066b',
            'contract':'Effort heat only during the action; no recovery production',
            'payload_sha256':sha(json.dumps(payload,sort_keys=True).encode()),'src_members':len(payload),
            'packages':packages,'native_runs':runs,'original_save_sha256':sha((OUT/'heat-followup/calor-136-original.zds').read_bytes()),
            'high_stats_save_sha256':sha((OUT/'heat-followup/calor-136-highstats-original.zds').read_bytes()),
            'mid_action_save_sha256':sha((OUT/'heat-action-state.zds').read_bytes()),
            'thermal_last_samples':{label:records(label)[-1] for label in ['heat-baseline-a','heat-delivery','heat-motion-a','motion-delivery','fire-delivery','swim-normal-delivery','swim-high-delivery','push-high-delivery']},
            'validator':json.loads(validation.stdout),'temporary_keep_awake_released':power['released_utc'],
            'author_acceptance_pending':['CA136-01','CA136-02','CA143-01'],
            'capture_sha256':{p.name:sha(p.read_bytes()) for p in sorted(HERE.glob('fp-final-*.png'))}}
    (HERE/'FOLLOWUP_MANIFEST.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'native_runs':len(runs),'source_members':len(payload),'errors':[],'power_released':True}))

if __name__=='__main__':main()
