"""Check native #251 results, qualified reuse and exact final package parity."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read_json(p):
    b=p.read_bytes();return json.loads(b.decode('utf-16') if b.startswith(b'\xff\xfe') else b.decode('utf-8-sig'))
final=ROOT/'build/issue251-release-5420/production.pk3'
groups={
 'issue251-gameplay-03':['timing','cry','stops','movement','coexist','journey','roof','casting','death','save'],
 'issue251-gameplay-07':['repaired','rain','overlap2','collision','save-prep','load-prep','water','preview'],
 'issue251-release-5420':['side'],
 'issue251-compat-seed2':['seed'],'issue251-compat-up':['upgrade'],'issue251-compat-return':['rollback'],
}
with zipfile.ZipFile(ROOT/'build/issue251-gameplay-03/production.pk3') as a,zipfile.ZipFile(final) as b:
    assert a.namelist()==b.namelist()
    changed=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert changed==['caelum/world/CaelumArcaneCloud.zs'],changed
    before=a.read(changed[0]).decode();after=b.read(changed[0]).decode()
    def without_travel(s):
        x=s.index('    override void PreTravelled()');y=s.index('    override void OnDestroy()',x)
        return s[:x]+s[y:]
    assert without_travel(before)==without_travel(after)
runs=[]
for directory,labels in groups.items():
    folder=ROOT/'build'/directory
    for label in labels:
        log=folder/(label+'.txt');record=folder/(label+'-run.json')
        content=log.read_text(encoding='utf-8-sig');meta=read_json(record)
        assert not re.search(r'CA251 FAIL|Script error|JIT error|VM execution aborted|DIED WITH FATAL ERROR',content),(directory,label)
        found=re.search(r'CA251 DONE failures=0 passed=(\d+)',content);assert found,(directory,label)
        assert meta['exit_code']==0 and meta['runtime_sha256'].lower()==sha(folder/'production.pk3')
        assert meta['fixture_sha256'].lower()==sha(folder/'cloud.pk3')
        meta.pop('initial_config',None)
        runs.append({'label':directory+'/'+label,'passes':int(found[1]),
            'checks':re.findall(r'^CA251 PASS (.*)$',content,re.M),
            'log_sha256':sha(log),'run_record_sha256':sha(record),**meta})
for name in ['production.pk3','cloud.pk3']:
    assert sha(ROOT/'build/issue251-release-5420'/name)==sha(ROOT/'build/issue251-release-repro'/name),name
with zipfile.ZipFile(final) as a,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as b:
    assert set(a.namelist())==set(b.namelist())
    assert all(a.read(n)==b.read(n)==(ROOT/'src'/n).read_bytes() for n in a.namelist())
validation=read_json(ROOT/'build/issue251-validation.json');assert validation['errors']==[],validation['errors']
evidence={
 'issue':251,'version':'5.4.20','branch':'feat/issue251-rain-cloud-model','base':'e9c79de8',
 'runtime_sha256':sha(final),'fixture_sha256':sha(ROOT/'build/issue251-release-5420/cloud.pk3'),
 'native_runs':len(runs),'native_passes':sum(r['passes'] for r in runs),'runs':runs,
 'qualified_reuse':'Earlier successful gameplay-03 runs have identical production sources except the model PreTravelled/Travelled methods. Final native checks reload that original failing active save, transfer out/back through the hub and outside it, and verify one owned visual plus continued paid state/flight. Fixture changes only fix test setup/order, add assertions, skip non-hub intermission and add visual cameras/controls. Failed runs are excluded.',
 'crash':{'original_report_sha256':sha(ROOT/'build/issue251-gameplay-03/CrashReport.zip'),
    'scenario':'gameplay-03/load2; MAP98; native C0000005 write 0xbeefcafe',
    'repair':'Keep effect inventory state; destroy the disposable model before travel and recreate it at destination.',
    'final_reproduction':'gameplay-07/repaired, 20 assertions and exit 0 using the original active save'},
 'compatibility':'Copied neutral accepted 5.4.19 save upgrades and roundtrips to 5.4.19 without resource mutation/free effect. Active preparation and cloud reload tested in 5.4.20; no claim that an active new effect loads in unsupported older code. Original snapshots retained for rollback.',
 'static_validation':{'errors':validation['errors'],'report_sha256':sha(ROOT/'build/issue251-validation.json')},
 'normal_package_all_members_equal':True,'deterministic_runtime_and_fixture':True,
 'visual_review':'Native rear/side seated rider and dark translucent model inspected; owned mesh/material unchanged. Rain particles and Air-seal VFX are presentation; known concave surface bands remain. CA251-01 author review outstanding.',
 'author_acceptance':'Pending CA251-01; draft PR281. No merge or issue closure.',
 'limits':'Focused single-process native tests, including two bot/player slots for rain overlap; not network transport, campaign-wide or large-map performance acceptance.',
 'development_failures':'Fixture virtual override defaults and read-only WaterLevel assignments corrected. Overlapping test bodies initially blocked the eligibility trace as designed. Absolute loadgame paths replaced by savedir-relative names. Non-hub intermission skipped through the same native ChangeLevel flag used by production journeys. Native bot needs the existing isolated executable directory with zcajun/bots.cfg. Original crash and failed/incomplete runs retained outside src.'
}
if (HERE/'acceptance.json').exists():
    acceptance=read_json(HERE/'acceptance.json')
    if acceptance['result']=='passed':
        evidence['author_acceptance']='CA251-01 passed on '+acceptance['confirmation_date']+'; see acceptance.json. PR281 ready. No merge or issue closure.'
        evidence['visual_review']=evidence['visual_review'].replace('CA251-01 author review outstanding.','CA251-01 accepted on '+acceptance['confirmation_date']+'.')
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:evidence[k] for k in ['runtime_sha256','fixture_sha256','native_runs','native_passes']}))
