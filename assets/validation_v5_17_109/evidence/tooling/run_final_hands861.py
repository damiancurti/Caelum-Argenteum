"""Run the final native hand-selection/save suite sequentially."""
from pathlib import Path
import json,subprocess,sys
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-final01';out.mkdir(exist_ok=False)
runner='assets/validation_v5_17_109/run_hand_continuity861.py';final=root/'build/issue861-hands01.pk3';old=root/'build/issue859-grips02.pk3'
phases=[('fresh','seed',final,None,[]),('upgrade','load',final,root/'build/issue861-save-baseline02/reach.zds',[]),('reload','load',final,out/'upgrade/reach.zds',[]),('rollback','load',old,out/'reload/reach.zds',['--baseline']),('hub','hub',final,out/'reload/reach.zds',[]),('death','death',final,None,[]),('dead-load','dead-load',final,out/'death/reach.zds',[])]
for sex in [0,1]:
 for glove in ['bare','GP']:phases.append((f'motion-{sex}-{glove}','motion',final,None,['--sex',str(sex),'--glove',glove]))
rows=[]
for label,mode,package,saved,extra in phases:
 folder=out/label;command=[sys.executable,'-X','utf8',runner,'--mode',mode,'--runtime',str(package),'--output',str(folder)]+extra
 if saved:command+=['--load',str(saved)]
 with (out/(label+'.log')).open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
 report=json.loads((folder/'RESULTS.json').read_text()) if (folder/'RESULTS.json').exists() else {}
 row={'label':label,'directory':folder.relative_to(root).as_posix(),'runtime':'baseline' if package==old else 'final','passed':r.returncode==0 and report.get('passed',False),'exit_code':r.returncode,'pass_lines':sum('EDGE PASS' in x for x in report.get('checks',[])),'failed':[x for x in report.get('checks',[]) if 'FAIL' in x],'errors':report.get('errors',[])};rows.append(row)
 (out/'SUMMARY.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
 if not row['passed']:raise SystemExit(1)
folder=out/'ownership';command=[sys.executable,'-X','utf8','C:/GZDooMProjects/CaelumArgenteum/build/v516/run_hands861_ownership.py','--runtime',str(final),'--output',str(folder)]
with (out/'ownership.log').open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
report=json.loads((folder/'RESULTS.json').read_text()) if (folder/'RESULTS.json').exists() else {}
row={'label':'ownership','directory':folder.relative_to(root).as_posix(),'runtime':'final','passed':r.returncode==0 and report.get('passed',False),'exit_code':r.returncode,'pass_lines':sum('EDGE PASS' in x for x in report.get('checks',[])),'failed':[x for x in report.get('checks',[]) if 'FAIL' in x],'errors':report.get('errors',[])};rows.append(row)
(out/'SUMMARY.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True);raise SystemExit(not row['passed'])
