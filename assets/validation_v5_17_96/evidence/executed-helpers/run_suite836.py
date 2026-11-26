"""Run final-package reach, linked-portal and reversible save checks sequentially."""
from pathlib import Path
import json,subprocess,sys
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'
baseline='build/issue834-format01.pk3';current='build/issue836-reach04.pk3'
cases=[
 ('final-flat01',current,False,None),
 ('upgrade-flat01',current,False,'build/issue836-edges-base01/reach.zds'),
 ('reload-flat01',current,False,'build/issue836-final-flat01/reach.zds'),
 ('rollback-flat01',baseline,False,'build/issue836-final-flat01/reach.zds'),
 ('base-portal01',baseline,True,None),
 ('final-portal01',current,True,None),
 ('upgrade-portal01',current,True,'build/issue836-base-portal01/reach.zds'),
 ('reload-portal01',current,True,'build/issue836-final-portal01/reach.zds'),
 ('rollback-portal01',baseline,True,'build/issue836-final-portal01/reach.zds')]
results=[]
for name,runtime,portal,load in cases:
    output='build/issue836-'+name
    command=[sys.executable,'assets/validation_v5_17_96/run_reach_edges.py','--runtime',runtime,'--output',output]
    if portal:command+=['--portal']
    if load:command+=['--load',load]
    with (R/(output+'-run.log')).open('wb') as log:
        done=subprocess.run(command,cwd=R,stdout=log,stderr=log)
    if done.returncode:raise SystemExit(f'Failed {name}; retain {output} and inspect its complete logs.')
    report=json.loads((R/output/'RESULTS.json').read_text(encoding='utf-8'))
    row={'name':name,'output':output,'passed':report['passed'],'result':report['checks'][-1]};results.append(row)
    print(json.dumps(row),flush=True)
(R/'build/issue836-suite01.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
