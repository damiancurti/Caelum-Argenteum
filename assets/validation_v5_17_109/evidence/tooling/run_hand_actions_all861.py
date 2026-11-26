from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');rows=[]
for sex in [0,1]:
 for glove in ['bare','GP']:
  out=root/f'build/issue861-actions-{sex}-{glove}01'
  command=[sys.executable,'-X','utf8','assets/validation_v5_17_109/run_hand_actions861.py','--sex',str(sex),'--glove',glove,'--runtime',str(root/'build/issue861-hands01.pk3'),'--output',str(out)]
  with out.with_suffix('.log').open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
  d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
  row=dict(sex=sex,glove=glove,directory=out.relative_to(root).as_posix(),passed=r.returncode==0 and d.get('passed',False),pass_lines=sum('EDGE PASS' in x for x in d.get('checks',[])),errors=d.get('errors',[]),failures=[x for x in d.get('checks',[]) if 'FAIL' in x]);rows.append(row)
  (root/'build/issue861-actions-final.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
  if not row['passed']:raise SystemExit(1)
