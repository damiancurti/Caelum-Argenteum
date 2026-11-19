"""Run scoped final/control relationship, portal and reversible-save checks."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
baseline='build/issue836-reach04.pk3';current='build/issue838-relation02.pk3'
cases=[('base-flat01',baseline,False,None),('final-flat01',current,False,None),('upgrade-flat01',current,False,'build/issue838-base-flat01/reach.zds'),('reload-flat01',current,False,'build/issue838-final-flat01/reach.zds'),('rollback-flat01',baseline,False,'build/issue838-final-flat01/reach.zds'),('final-portal01',current,True,None)]
results=[]
for name,runtime,portal,load in cases:
    output='build/issue838-'+name
    command=[sys.executable,'assets/validation_v5_17_97/run_relation_edges.py','--baseline',baseline,'--runtime',runtime,'--output',output]
    if portal:command+=['--portal']
    if load:command+=['--load',load]
    with (root/(output+'-run.log')).open('wb') as log:done=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    if done.returncode:raise SystemExit(f'Failed {name}; retain {output} and inspect complete logs.')
    report=json.loads((root/output/'RESULTS.json').read_text(encoding='utf-8'))
    row={'name':name,'output':output,'passed':report['passed'],'assertions':sum(s.startswith('CA836 EDGE PASS ') for s in report['checks']),'result':report['checks'][-1]};results.append(row)
    print(json.dumps(row),flush=True)
    (root/'build/issue838-suite01.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
