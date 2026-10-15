"""Audit #248 native logs, package parity and copied-save evidence."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]; HERE=Path(__file__).parent
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
groups={
 'issue248-delivery':['contract','damage','casting','cadence','save','load2','save_prep','load_prep','feedback'],
 'issue248-final':['advanced','flight'],
 'issue248-seed':['seed'], 'issue248-upgrade':['upgrade'],
 'issue248-rollback':['rollback'], 'issue248-return':['return'],
}
final=ROOT/'build/issue248-delivery/production.pk3'
old=ROOT/'build/issue247-confirmed/production.pk3'
runs=[]
for directory,labels in groups.items():
 folder=ROOT/'build'/directory
 expected=sha(old) if directory in ['issue248-seed','issue248-rollback'] else sha(final)
 for label in labels:
  log=folder/(label+'.txt');record=folder/(label+'-run.json')
  text=log.read_text(encoding='utf-8-sig');meta=json.loads(record.read_text(encoding='utf-8-sig'))
  assert not re.search(r'CA248 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR',text),(directory,label)
  found=re.search(r'CA248 DONE failures=0 passed=(\d+)',text);assert found,(directory,label)
  assert meta['exit_code']==0 and meta['runtime_sha256'].lower()==expected
  assert meta['fixture_sha256'].lower()==sha(folder/'rally.pk3')
  runs.append({'label':directory+'/'+label,'passes':int(found[1]),'log':str(log.relative_to(ROOT)).replace('\\','/'),
    'log_sha256':sha(log),'run_record_sha256':sha(record),**meta})
with zipfile.ZipFile(final) as z,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
 members=z.namelist();assert set(members)==set(normal.namelist())
 for name in members:
  assert z.read(name)==normal.read(name)==(ROOT/'src'/name).read_bytes(),name
saves={}
for directory in ['issue248-upgrade','issue248-rollback','issue248-return']:
 folder=ROOT/'build'/directory;manifest=json.loads((folder/'manifest.json').read_text())
 assert sha(folder/'input.zds')==manifest['original_save_sha256']
 saves[directory]=manifest['original_save_sha256']
validation=json.loads((ROOT/'build/issue248-validation.json').read_text(encoding='utf-8-sig'))
assert validation['version']=='5.4.17' and not validation['errors']
result={'issue':248,'version':'5.4.17','date':'2026-10-15','runtime_sha256':sha(final),
 'static_validation':{'command':'python validate_project.py','exit_code':0,**validation},
 'normal_build':{'command':'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1','exit_code':0,'files_included':len(members),'log_sha256':sha(ROOT/'build/issue248-build.txt')},
 'normal_package_matches_src_and_frozen_runtime':True,
 'native_assertions':sum(r['passes'] for r in runs),'native_runs':runs,
 'qualified_reuse':'Advanced/flight use the identical production SHA-256. Their earlier addon differs only by the subsequently added manual controls/overlay. The current addon compiles and passes its remaining scenarios. Preview duplicates are not counted.',
 'copied_save_sha256':saves,'author_acceptance':'Pending CA248-01.',
 'visual_review':{'path':'build/issue248-delivery/feedback.png','sha256':sha(ROOT/'build/issue248-delivery/feedback.png'),
  'result':'Agent inspected readable Spanish resource/factor/HP overlay, friendly/hostile placement and native class HUD. At 50% Adrenaline the controlled 300-HP hit removes 200 HP; author acceptance pending.'},
 'diagnostics':[
  'audit02/advanced: granting a seal recalculated player evasion; pin test defenses afterward. Reviewed payload checks pass without production changes.',
  'diagnostics/advanced: immediate reactive spawn had not run PostBeginPlay, so its controlled maximum remained zero. Explicit fixture reserves fix the intended pre-block/nested-hit checks.',
  'reviewed/flight: native missile damage still rolls; fixture DoSpecialDamage pins 300 HP before real receiver defenses, preserving real flight. Final in-flight check passes.',
  'manual/contract: ZScript sibling-class conditional required explicit Actor casts in manual controls; delivery compiles and passes.',
  'delivery/load: forward-slash absolute save path was prefixed twice by Windows GZDoom. load2 uses the savedir-relative name and passes current reload/hub checks.',
  'delivery/preview: screenshot preceded queued network events; feedback waits three tics and shows the resolved hit. Original capture/log preserved.'
 ],'limitations':['No author acceptance, broad campaign, multiplayer, performance or other class delivery claim.',
 'Rollback requires the documented inert-class bridge on copied saves; unsupported temporary area/preparation is cancelled without refund. Original saves remain unchanged.']}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'assertions':result['native_assertions'],'runs':len(runs),'members':len(members),'runtime':result['runtime_sha256']}))
