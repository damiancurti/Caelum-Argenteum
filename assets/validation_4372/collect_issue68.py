"""Collect the executed #68 checks and verify the tested PK3 against source."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys,zipfile
root=Path(__file__).resolve().parents[2 if Path(__file__).parent.name=='validation_4372' else 1]
out=root/'assets/validation_4372';out.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
cases={
 'legacy_pending':('LEGACY revision=2',1),
 'rules_final':('RULES_DONE quotes=240',502),
 'live_staff':('LIVE_DONE shape=0',36),
 'live_book':('LIVE_DONE shape=1',36),
 'live_bell':('LIVE_DONE shape=2',36),
 'live_statuette':('LIVE_DONE shape=3',36),
 'migration':('native saved cast pays its updated quote exactly once',10),
 'migration_reload':('native saved cast pays its updated quote exactly once',10),
 'paid_reload':('next cast pays reduced cost after reload',4),
 'rollback':('original save and original package restore original cost',1),
 'caella':('stage 45 and secret passage unlocked',0),
 'clean':('QA68_CLEAN_DONE',0),
}
records=[]
for label,(marker,minimum) in cases.items():
 p=root/f'build/issue68_{label}.log';s=p.read_text(encoding='utf-8',errors='replace')
 assert not re.search(r'QA(?:62|68) FAIL|Script error|VM execution aborted|Execution could not continue',s),label
 assert marker in s,(label,marker)
 count=s.count('QA68 PASS');assert count>=minimum,(label,count,minimum)
 evidence='\n'.join(line for line in s.splitlines() if line.startswith(('GZDoom version','adding build/caelum','adding build/issue68','adding src','MAP01','QA68','QA62','Partida guardada','Captured')))+'\n'
 (out/f'{label}.txt').write_text(evidence,encoding='utf-8')
 records.append({'label':label,'pass_assertions':count,'support_fixture_assertions':s.count('QA62 PASS'),'completion_marker':marker,'commands':(root/f'build/issue68_{label}.cfg').read_text(encoding='utf-8'),'log_sha256':sha(p.read_bytes()),'evidence':f'{label}.txt'})
package=root/'build/caelum_argenteum_dev.pk3';baseline=root/'build/issue68_baseline_4371.pk3'
with zipfile.ZipFile(package) as z,zipfile.ZipFile(baseline) as old:
 files={p.relative_to(root/'src').as_posix():p for p in (root/'src').rglob('*') if p.is_file()}
 assert set(files)==set(z.namelist())
 for name,p in files.items():assert z.read(name)==p.read_bytes(),name
 changed=[n for n in z.namelist() if z.read(n).replace(b'\r\n',b'\n')!=old.read(n).replace(b'\r\n',b'\n')]
 expected={'caelum/core/CaelumConstants.zs','caelum/equipment/CaelumWeaponModel.zs','caelum/player/CaelumPlayer.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
 assert set(changed)==expected,changed
 runtime={n:sha(z.read(n)) for n in changed}
 for n in ['maps/MAP01.wad','caelum/statistics/CaelumDerivedStats.zs','caelum/equipment/CaelumPersistentCharacterState.zs','caelum/world/CaelumSleepRules.zs']:
  assert z.read(n).replace(b'\r\n',b'\n')==old.read(n).replace(b'\r\n',b'\n'),n
 result=subprocess.run([sys.executable,'validate_project.py'],cwd=root,capture_output=True,text=True,encoding='utf-8')
 assert result.returncode==0,result.stdout+result.stderr
 (out/'STATIC.json').write_text(result.stdout,encoding='utf-8')
shutil.copytree(root/'build/issue68_qa',out/'fixture',dirs_exist_ok=True)
shutil.copyfile(root/'build/run_issue68.ps1',out/'run_issue68.ps1')
shutil.copyfile(root/'build/issue68_staff.png',out/'staff.png')
report={
 'issue':68,'version':'4.37.2','date':'2026-10-01','base_commit':'62dbdf33c96c1a6e83d427454dbde00c64bbf700',
 'author_request':'Magic-weapon base Anima costs divided by ten; corresponding attribute Type 4 divisor, one third at 100.',
 'base_costs':{'staff':50,'book':70,'bell':100,'statuette':100},
 'formula':'base * tier(1,1.6,2.5) * charge(1,2) / (1 + 2*E*(E+1)/10100), E=max(0,effective Eloquence)',
 'engine':'GZDoom 4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti',
 'package':{'sha256':sha(package.read_bytes()),'entries':len(files),'all_entries_match_src':True},
 'baseline':{'version':'4.37.1','sha256':sha(baseline.read_bytes()),'runtime_accepted_in':'#62 / PR #67'},
 'runtime_file_hashes':runtime,'native_cases':records,
 'author_acceptance':'PENDING CA-4372-ANIMA-01; #62 acceptance does not accept the subsequent balance change.',
 'methodology':[
  'The support overlay is assets/validation_4371/fixture. Native setup seeds Argento completion and uses production Caella Begin/equipment; neither fixture is included in the PK3.',
  '240 cost quotations execute native PerformDebugStaffAttack over 4 shapes x 3 tiers x 5 Eloquence levels (0,25,50,100,200) x charge on/off x primary/secondary. Each cancellation is checked to spend nothing. Expected costs independently use the author-specified bases and Type 4 equation.',
  '48 live casts complete on native ticks across all shapes, tiers, modes and charge states; normal cases use Eloquence 0 and charged cases 100. The fixture suppresses regeneration solely to measure the actual debit, and controls aim to keep the visible spells on the dummy.',
  'NPC checks use native GetTierOneMagicAnimaCost/TrySpendTierOneMagicAnima for the authored staff/statuette shapes. Exact-reserve checks seed the native floating-point quote; independent expected-value comparisons use a tolerance of 0.00001. An initial independent floating-point boundary setup was corrected without changing gameplay.',
  'The original pending save is produced in the 4.37.1 package. Its real native cast/animation clock is extended to 30 seconds solely to permit save/load inspection; an initial probe extended only the legacy timer and was superseded. Forward load observes revision 3 without manually invoking the initial migration.',
  'The original pending quote 471.433905900 becomes 47.143390590 before payment. Equipment/quest identity and partial reserve remain; repeated migration calls, current-version save/load and the next cast do not divide twice. Original-save rollback is checked using the preserved original package, not by treating a new revision-3 save as an old-price save.',
  'Type 4 derived-stat code, Sleep rules, persistent character-state fields and MAP01 geometry remain identical to the accepted baseline (ignoring checkout line endings for text). Only three gameplay files and two required diagnostic version labels change.',
  'Static/native checks do not replace author balance acceptance. No private author save, IWAD, executable or development PK3 is distributed.'
 ],
 'reproduction':[
  'Build with build_dev.ps1. From the repository root, use run_issue68.ps1 -Label <label> -Package -BaseMap assets/validation_4371/fixture -Fixture assets/validation_4372/fixture -Commands <recorded commands> -Wait. Configure its local engine/IWAD paths and supply build/gzdoom.ini.',
  'legacy_pending and rollback use -Runtime <original 4.37.1 PK3>, built from base_commit in an isolated checkout and preserving the basename caelum_argenteum_dev.pk3. Migration uses -LoadSave build/issue68_saves/legacy68_pending.zds; migration_reload uses migrated68_pending.zds; paid_reload uses migrated68_paid.zds.',
  'The clean case uses -Clean and omits -BaseMap so no fixture is loaded. Logs/saves/captures stay under build. The evidence collector rejects absent completion markers or any failed assertion.'
 ]}
(out/'RESULTS.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'cases':len(records),'cost_assertions':sum(r['pass_assertions'] for r in records),'support_assertions':sum(r['support_fixture_assertions'] for r in records),'package_entries':len(files)},indent=2))
