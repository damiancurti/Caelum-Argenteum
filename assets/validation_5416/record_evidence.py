"""Audit preserved #247 logs, package parity and qualified evidence reuse."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
groups={
 'issue247-final':['crouch','steer','scaled','expiry','wall','ordinary','flight','defense','cast','interrupt1','interrupt2','interrupt3','jump','prediction','death','diagonal'],
 'issue247-delivery':['water','renew','hub'],
 'issue247-boundaries':['low'],
 'issue247-reviewed':['preview','contract','save','load'],
 'issue247-confirmed':['body','save_prep','load_prep'],
 'issue247-upgrade':['upgrade'], 'issue247-rollback':['rollback'], 'issue247-return':['return'],
}
runs=[]
for directory,labels in groups.items():
 for label in labels:
  folder=ROOT/'build'/directory;record=json.loads((folder/f'{label}-run.json').read_text(encoding='utf-8-sig'))
  log=(folder/f'{label}.txt').read_text(encoding='utf-8-sig')
  done=re.findall(r'CA247 DONE failures=(\d+) passes=(\d+)',log)
  assert record['exit_code']==0 and done and done[-1][0]=='0',(directory,label)
  assert 'CA247 FAIL' not in log and 'VM execution aborted' not in log
  runs.append({'directory':directory,'label':label,'passes':int(done[-1][1]),
   'runtime_sha256':record['runtime_sha256'],'fixture_sha256':record['fixture_sha256'],
   'engine_sha256':record['engine_sha256'],'exit_code':record['exit_code'],
   'arguments':record['arguments'],'log_sha256':sha(folder/f'{label}.txt'),
   'checks':re.findall(r'CA247 PASS ([^\r\n]+)',log)})
final=ROOT/'build/issue247-confirmed/production.pk3'
with zipfile.ZipFile(final) as current:
 members=current.namelist()
 assert all(current.read(n)==(ROOT/'src'/n).read_bytes() for n in members)
 with zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
  assert set(normal.namelist())==set(members)
  assert all(current.read(n)==normal.read(n) for n in members)
 reuse={}
 for directory in ['issue247-final','issue247-delivery','issue247-boundaries']:
  with zipfile.ZipFile(ROOT/'build'/directory/'production.pk3') as older:
   changed=[n for n in members if current.read(n)!=older.read(n)]
   for n in changed:
    old=older.read(n).decode();new=current.read(n).decode()
    if n.endswith(('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs')):
     assert old.replace('[Caelum 5.4.15]','[Caelum 5.4.16]')==new
    else:
     assert n=='caelum/world/CaelumFormationBreaker.zs'
     added='''                // La cabeza modular puede recibir Tick después del jugador.
                // Sin sincronizarla, la fotografía queda un paso detrás del cuerpo.
                if(user.AppearanceHead!=null)user.AppearanceHead.UpdateVisual();
'''
     assert new.replace(added,'')==old
   reuse[directory]={'changed_members':changed,'scope':'Nonvisual gameplay evidence reused; only diagnostic labels and modular-head snapshot synchronization differ. Final runtime retests native drive/contact, trails, save/load and preparation.'}
saves={}
for directory in ['issue247-upgrade','issue247-rollback','issue247-return']:
 folder=ROOT/'build'/directory;manifest=json.loads((folder/'manifest.json').read_text())
 assert sha(folder/'input.zds')==manifest['original_save_sha256']
 saves[directory]=manifest['original_save_sha256']
result={'issue':247,'version':'5.4.16','date':'2026-10-15','runtime_sha256':sha(final),
 'static_validation':{'command':'python validate_project.py','exit_code':0,'errors':[],'version':'5.4.16'},
 'normal_build':{'command':'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1','exit_code':0,'files_included':len(members)},
 'normal_package_members':len(members),'normal_package_matches_src_and_frozen_runtime':True,
 'native_assertions':sum(r['passes'] for r in runs),'native_runs':runs,'qualified_reuse':reuse,
 'copied_save_sha256':saves,'author_acceptance':'Pending CA247-01; author away, no manual launch.',
 'visual_review':{'path':'build/issue247-reviewed/trail.png','sha256':sha(ROOT/'build/issue247-reviewed/trail.png'),
 'result':'Agent inspected frozen translucent body/head appearance and aligned snapshot positions; author appearance acceptance pending.'},
 'diagnostics':[
 'compile01: Stop is a reserved ZScript token; renamed EndDash. compile02 passed 5 native #260 regression assertions.',
 'audit01-03: fixture Power parameter shadowed the case-insensitive field, producing zero-duration test effect; fixed fixture.',
 'audit04: moving-body obstruction escaped cleared native BlockingMobj; production now tests actual forward displacement; later contact passes.',
 'audit04: fixture expected family-two Toughness (130) instead of existing family-three (170); corrected expectation, not gameplay.',
 'audit04 save/preview: cleanup check ran before ongoing dash ended; corrected fixture wait.',
 'final/low: actor-overhead stand-in did not establish a low native ceiling; actual MoveCeiling fixture passes with 42-unit clearance and 56-unit full body.',
 'boundaries/preview: head snapshot lagged body by one tic; synchronize modular head before photographing. Reviewed snapshot pairs share exact positions/age.'
 ],'limitations':['No author acceptance, broad campaign, multiplayer, performance or other class delivery claim.','Rollback requires the documented inert-class bridge on copied saves; unsupported transient effect is cancelled without refund. Original saves remain unchanged.']}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'assertions':result['native_assertions'],'runs':len(runs),'members':len(members),'runtime':result['runtime_sha256']}))
