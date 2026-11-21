"""Continue final #861 evidence, retaining seven qualified continuity phases."""
from pathlib import Path
import json,subprocess,sys
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-final04';out.mkdir(exist_ok=False)
runner='assets/validation_v5_17_109/run_hand_continuity861.py';final=root/'build/issue861-hands01.pk3';old=root/'build/issue859-grips02.pk3'
rows=json.loads((root/'build/issue861-final03/SUMMARY.json').read_text())[:7]
assert len(rows)==7 and all(row['passed'] for row in rows)
for row in rows:row['qualification']='Reused: Pose-only diagnostic correction does not affect completed continuity checks.'
phases=[]
for sex in [0,1]:
 for glove in ['bare','GP']:phases.append((f'motion-{sex}-{glove}',runner,['--mode','motion','--sex',str(sex),'--glove',glove],final))
phases.extend([
 ('ownership','C:/GZDooMProjects/CaelumArgenteum/build/v516/run_hands861_ownership.py',[],final),
 ('legacy-death',runner,['--mode','death','--baseline'],old),
 ('legacy-dead-upgrade',runner,['--mode','dead-load','--legacy-death','--load',str(out/'legacy-death/reach.zds')],final),
 ('legacy-dead-reload',runner,['--mode','dead-load','--legacy-death','--load',str(out/'legacy-dead-upgrade/reach.zds')],final),
 ('lookup-counters','C:/GZDooMProjects/CaelumArgenteum/build/v516/run_hands861_cache.py',['--candidate',str(root/'build/issue861-cache-overlay01/prototype.pk3')],final)])
for label,script,extra,package in phases:
 folder=out/label;command=[sys.executable,'-X','utf8',script,'--runtime',str(package),'--output',str(folder)]+extra
 with (out/(label+'.log')).open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
 report=json.loads((folder/'RESULTS.json').read_text()) if (folder/'RESULTS.json').exists() else {}
 row={'label':label,'directory':folder.relative_to(root).as_posix(),'runtime':'baseline' if package==old else 'instrumented final' if label=='lookup-counters' else 'final','passed':r.returncode==0 and report.get('passed',False),'exit_code':r.returncode,'pass_lines':sum('EDGE PASS' in x for x in report.get('checks',[])),'failed':[x for x in report.get('checks',[]) if 'FAIL' in x],'errors':report.get('errors',[])};rows.append(row)
 (out/'SUMMARY.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
 if not row['passed']:raise SystemExit(1)
