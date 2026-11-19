"""Canonical final-package native equipment, continuity and pose evidence."""
from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');public=root/'assets/validation_v5_17_107'
runtime=root/'build/issue857-wardrobe02.pk3';baseline=root/'build/issue855-navigation02.pk3'
out=root/'build/issue857-final01';out.mkdir(exist_ok=False);rows=[]
plans=[('seed','seed',True,None),('fresh','fresh',False,None),('upgrade','load',False,'seed'),('reload','load',False,'fresh'),('hub','hub',False,'reload'),('disable','disable',False,'reload'),('rollback','rollback',True,'disable'),('death','death',False,None),('dead-load','dead-load',False,'death'),('ownership',None,False,None),('motion','motion',False,None)]
for label,mode,old,previous in plans:
    folder=out/label
    runner=public/('run_wardrobe_continuity857.py' if mode else 'run_wardrobe_ownership857.py')
    command=[sys.executable,'-X','utf8',str(runner),'--runtime',str(baseline if old else runtime),'--output',str(folder)]
    if mode:command+=['--mode',mode]
    if old:command+=['--baseline-fixture']
    if previous:command+=['--load',str(out/previous/'reach.zds')]
    with (out/(label+'.log')).open('wb') as stream:process=subprocess.run(command,cwd=root,stdout=stream,stderr=stream)
    d=json.loads((folder/'RESULTS.json').read_text()) if (folder/'RESULTS.json').exists() else {}
    row=dict(label=label,code=process.returncode,passed=d.get('passed',False),errors=d.get('errors'),pass_lines=sum('EDGE PASS' in line for line in d.get('checks',[])),fail_lines=sum('EDGE FAIL' in line for line in d.get('checks',[])),totals=[x for x in d.get('checks',[]) if 'EDGE_RESULT' in x],runtime='baseline' if old else 'final')
    rows.append(row);(out/'SUMMARY.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
    if process.returncode or not row['passed']:sys.exit(1)
