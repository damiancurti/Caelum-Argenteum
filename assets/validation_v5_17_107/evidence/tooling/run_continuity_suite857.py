"""Run serialized native continuity phases and stop on the first failure."""
from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');helper=Path(__file__).resolve().parent
base=root/'build/issue855-navigation02.pk3';candidate=root/'build/issue857-prototype05/prototype.pk3'
plans=[('death',False,None),('dead-load',False,'death')]
for label,baseline,previous in plans:
    mode='load' if label=='upgrade' else label
    output=root/('build/issue857-continuity-'+label+'06')
    command=[sys.executable,'-X','utf8',str(helper/'run_wardrobe_continuity857.py'),'--mode',mode,'--runtime',str(base),'--output',str(output)]
    if baseline:command+=['--baseline-fixture']
    else:command+=['--candidate',str(candidate)]
    if previous:
        folder=previous+'06'
        command+=['--load',str(root/('build/issue857-continuity-'+folder)/'reach.zds')]
    with output.with_suffix('.log').open('wb') as log:result=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    report=json.loads((output/'RESULTS.json').read_text()) if (output/'RESULTS.json').exists() else {}
    print(json.dumps(dict(phase=label,code=result.returncode,passed=report.get('passed'),errors=report.get('errors'),totals=[x for x in report.get('checks',[]) if 'EDGE_RESULT' in x])),flush=True)
    if result.returncode:sys.exit(result.returncode)
