"""Verify focused #250 evidence and its explicitly qualified reuse."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
final=ROOT/'build/issue250-release/production.pk3'
old=ROOT/'build/issue249-final/production.pk3'
groups={
 'issue250-final':['cure','renew','friendly','fit','casting','defense','combat'],
 'issue250-delivery':['contract','death','save-prep','save','pending','load','pending-load','load-prep'],
 'issue250-author':['player','preview'],
 'issue250-ready':['journey'],
 'issue250-release':['pending-expire'],
 'issue250-compat-seed2':['seed'],'issue250-compat-final':['upgrade'],
 'issue250-compat-final-return':['return'],
 'issue250-summoning-regression':['placement'],
}
with zipfile.ZipFile(ROOT/'build/issue250-final/production.pk3') as a,zipfile.ZipFile(final) as b:
    assert a.namelist()==b.namelist()
    changed=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert changed==['caelum/world/CaelumResurrection.zs'],changed
    before=a.read(changed[0]).decode();after=b.read(changed[0]).decode()
    added=after[after.index('        if(user!=null)\n        {',after.index('static bool Restore')):after.index('        int monsters=level.total_monsters;')]
    assert added and after.replace(added,'',1)==before
runs=[]
for directory,labels in groups.items():
    folder=ROOT/'build'/directory
    expected=sha(old) if directory in ['issue250-compat-seed2','issue250-compat-final-return'] else sha(folder/'production.pk3')
    if directory not in ['issue250-compat-seed2','issue250-compat-final-return','issue250-final']:
        assert expected==sha(final),directory
    for label in labels:
        prefix='CA249' if directory=='issue250-summoning-regression' else 'CA250'
        fixture=folder/('summoning.pk3' if prefix=='CA249' else 'redemption.pk3')
        log=folder/(label+'.txt');record=folder/(label+'-run.json')
        content=log.read_text(encoding='utf-8-sig');meta=json.loads(record.read_text(encoding='utf-8-sig'))
        assert not re.search(prefix+r' FAIL|Script error|JIT error|REGT_ADDROF|VM execution aborted|DIED WITH FATAL ERROR',content),(directory,label)
        found=re.search(prefix+r' DONE failures=0 passed=(\d+)',content);assert found,(directory,label)
        assert meta['exit_code']==0 and meta['runtime_sha256'].lower()==expected
        assert meta['fixture_sha256'].lower()==sha(fixture)
        # User configuration is irrelevant to these checks and may contain local preferences.
        meta.pop('initial_config',None)
        runs.append({'label':directory+'/'+label,'passes':int(found[1]),
          'checks':re.findall(r'^'+prefix+r' PASS (.*)$',content,re.M),
          'log_sha256':sha(log),'run_record_sha256':sha(record),**meta})
for name in ['production.pk3','redemption.pk3']:
    assert sha(ROOT/'build/issue250-release'/name)==sha(ROOT/'build/issue250-release-repro'/name),name
with zipfile.ZipFile(final) as a,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as b:
    assert set(a.namelist())==set(b.namelist())
    assert all(a.read(n)==b.read(n)==(ROOT/'src'/n).read_bytes() for n in a.namelist())
validation=json.loads((ROOT/'build/issue250-validation.json').read_text(encoding='utf-8-sig'))
assert validation['errors']==[],validation['errors']
evidence={
 'issue':250,'version':'5.4.19','branch':'feat/issue250-redemption','base':'6578c8b7',
 'runtime_sha256':sha(final),'fixture_sha256':sha(ROOT/'build/issue250-release/redemption.pk3'),
 'native_runs':len(runs),'native_passes':sum(r['passes'] for r in runs),'runs':runs,
 'qualification':'The earlier final suite differs only by the added same-tic player-death effect cleanup in CaelumResurrection.Restore. NPC behavior, defenses, casting, following and combat are identical. The final runtime separately passes active-player cleanup, corpse/drop contract, death, preparation/effect reload, travel and native journey. Later fixture edits only add assertions/diagnostics, execute the real journey transaction and clamp displayed dead Health to zero. No earlier failed run counts as a pass.',
 'compatibility':'Copied neutral 5.4.18 save upgrade and roundtrip to 5.4.18; active 5.4.19 effect and preparation reload/hub transfer tested separately. An active Redemption save is not claimed to load in an older runtime without support. Original snapshots are retained for rollback.',
 'static_validation':{'errors':validation['errors'],'report_sha256':sha(ROOT/'build/issue250-validation.json')},
 'normal_package_all_members_equal':True,'deterministic_runtime_and_fixture':True,
 'agent_visual_review':'Spanish overlay, before/active/expired native captures in build/issue250-author; existing corpses/living art, class hands and HUD reused.',
 'author_acceptance':'Pending CA250-01. No merge or issue closure.',
 'limits':'Focused native fixtures are not broad campaign, network multiplayer, or large-map performance acceptance.',
 'development_failures':'Preserved under build/issue250-*; reserved keyword Protected and fixture PlayerPawn type were corrected. Fixtures were corrected for deferred PostBeginPlay, native non-monster corpse marking, inverted-dose threshold, DOT ticking, a real directed damage source and collision Health budget. An absolute -loadgame argument was replaced with a savedir-relative filename. All relevant final checks pass.'
}
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:evidence[k] for k in ['runtime_sha256','fixture_sha256','native_runs','native_passes']}))
