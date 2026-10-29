"""Collect native tent evidence and verify final packaged/source bytes."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2];WORK=ROOT/'build/issue411-placement'
RUNS=['deploycore06','deploywait09','handoff04','climate03','land02','measure02',
      'deploysave03','deployload04','deployhub04','tasksave02','taskload03','taskhub03',
      'campoldload04','campoldrollback04','campstorage04']
FAILED=['campcompile01','deployhub01','deploywait01','deploywait02','deploywait03',
        'deploywait04','deploywait05','deploywait06']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def members(p):
 with zipfile.ZipFile(p) as z:return {n:hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist()}
def main():
 package=WORK/'camp-final/caelum_argenteum_dev.pk3'
 source={p.relative_to(ROOT/'src').as_posix():digest(p) for p in (ROOT/'src').rglob('*') if p.is_file()}
 assert source==members(package),'Final package does not exactly match src'
 assert source==members(WORK/'probe13/caelum_argenteum_dev.pk3'),'Runtime changed after final native probe'
 assert digest(WORK/'ca411p-legacy-final.zds')=='c507d98fac35cc2a200febb43eacedad5bd2d01bed8c7ac4148d9af585a3bd7e','Original legacy save changed'
 evidence=HERE/'native';evidence.mkdir(exist_ok=True);runs=[]
 for label in RUNS:
  rec=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
  log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
  assert rec['exit_code']==0 and not rec.get('timed_out'),label
  assert not re.search(r'CA411[DP] FAIL|Script error|VM execution aborted|Fatal:',log),label
  count=len(re.findall(r'^CA411[DP] PASS ',log,re.M))
  if count==0 and 'CA411P LEGACY result=PASS' in log:count=1
  assert count>0,label
  runs.append({'label':label,'pass_assertions':count,'runtime_sha256':rec['package_sha256'],'addon_sha256':rec['addon_sha256']})
 for label in RUNS+FAILED:
  for suffix in ['.txt','-run.json']:
   src=WORK/(label+suffix)
   if src.exists():shutil.copyfile(src,evidence/src.name)
 raw=(WORK/'camp-static.json').read_bytes()
 static=json.loads(raw.decode('utf-16') if raw[:2] in [b'\xff\xfe',b'\xfe\xff'] else raw.decode('utf-8-sig'))
 assert not static['errors']
 (HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
 report={'issue':411,'version':'5.8.8','pass_assertions':sum(r['pass_assertions'] for r in runs),'runs':runs,
 'runtime_members':len(source),'package_sha256':digest(package),'probe_sha256':digest(WORK/'probe13/caelum_argenteum_dev.pk3'),
 'complete_source_and_tested_bytes_equal':True,'legacy_original_sha256':digest(WORK/'ca411p-legacy-final.zds'),
 'schema':'Additive revision 1 for deployed structure/task; original pre-camp save remains reversible.',
 'author_acceptance':'Pending CA411-TENT-01; terminal prepared, not launched during absence.',
 'performance':'Event-maintained registry; one typed census per load. Twenty tents / 1600 parts, 100 rebuilds: mean 0.008428 ms, max 0.037800 ms. No rendering/FPS acceptance claim.',
 'failed_probes':{'campcompile01':'cross is a reserved identifier; renamed across.',
 'deployhub01':'Private proof incorrectly dereferenced an actor in an unloaded map; now verifies original saved marker/quantity on return.',
 'deploywait01':'Camp work was missing from existing wait/accelerated-work eligibility; added the narrow attended-camp case.',
 'deploywait02-04':'Private MAP01 introduction conversation still active; close its test conversation before waiting.',
 'deploywait05-06':'Exact forecast preserves existing nonzero thermal-exposure guard. Isolated exact forecast resets fixture exposure; actual accelerated-work test retains normal evolving physiology.'},
 'limitations':['No author acceptance yet.','No fire/cooking or new two-occupant sleeping arrangement.','Unknown land has no implicit camp permission.','Native exact-wait forecast retains its existing effect/thermal guard; manual wait and accelerated work remain supported.']}
 (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 lines=['# 5.8.8 / #411 - Persistent tents and camp permissions','',
 'The inventory action assembles the original tent; native Use packs it. Approved ten/five game minutes run through ordinary time, waiting and accelerated attended work. Cancellation preserves the original instance, and packing checks title and capacity. The square footprint faces its entrance towards the placer on the nearest cardinal direction. No campaign map geometry changes.','',
 'Land includes mansion gardens, current owned/rented homes and the authored unowned countryside rectangles. Complete dry/stable geometry and access checks are reused. The local shelter excludes rain, applies wind x0.1 and preserves the existing air temperature/humidity. Save/load, map return, original-save rollback and current inventory interaction are checked separately from author acceptance.','',
 f"{report['pass_assertions']} native PASS across {len(runs)} selected runs. All {len(source)} final package members exactly match current src and the complete tested probe13. Windows 11, GZDoom 4.14.2, Ryzen 9 5950X / RTX 3070 Ti, Vulkan 1280x720, background unpaused at 5% audio.",'','| Run | PASS |','| --- | ---: |']
 lines += [f"| {r['label']} | {r['pass_assertions']} |" for r in runs]
 lines += ['',report['performance'],'',
 'The exact-wait check isolates initial exposure for the existing forecast adapter; the accelerated-work handoff executes normal evolving physiology and stops at completion. Source fixture failures and their corrections remain in native/ and report.json. No development IWAD, executable, built test addon or private save is tracked.','',
 'CA411-TENT-01 is pending in the single root pending_test.txt. The author terminal is prepared but deliberately not opened during the requested absence. Fire, cooking, new sleeping arrangements and unknown-land grants remain open.']
 (HERE/'RESULTS.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
 print(json.dumps({'passes':report['pass_assertions'],'runs':len(runs),'members':len(source),'sha256':report['package_sha256']}))
if __name__=='__main__':main()
