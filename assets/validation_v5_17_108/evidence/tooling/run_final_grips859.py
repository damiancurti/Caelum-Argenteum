"""Final-package native grip poses, equipment authority and save continuity."""
from pathlib import Path
import json,subprocess,sys
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue859-final01';out.mkdir(exist_ok=False)
runtime=root/'build/issue859-grips01.pk3';baseline=root/'build/issue857-wardrobe02.pk3';public=root/'assets/validation_v5_17_107';rows=[]
plans=[]
for glove in ['bare','GF','GC','GW','GP']:
    plans.append((glove,root/'assets/validation_v5_17_108/run_grip_motion859.py',runtime,['--glove',glove]))
for label,mode,old,previous in [('fresh','fresh',False,None),('upgrade','load',False,'previous'),('reload','load',False,'fresh'),('disable','disable',False,'reload'),('rollback','load',True,'disable'),('death','death',False,None),('dead-load','dead-load',False,'death')]:
    flags=['--mode',mode]
    if previous:flags+=['--load',str(root/'build/issue857-final01/fresh/reach.zds' if previous=='previous' else out/previous/'reach.zds')]
    plans.append((label,public/'run_wardrobe_continuity857.py',baseline if old else runtime,flags))
plans.append(('ownership',public/'run_wardrobe_ownership857.py',runtime,[]))
for label,runner,package,flags in plans:
    command=[sys.executable,'-X','utf8',str(runner),'--runtime',str(package),'--output',str(out/label)]+flags
    with (out/(label+'.log')).open('wb') as stream:process=subprocess.run(command,cwd=root,stdout=stream,stderr=stream)
    result=out/label/'RESULTS.json';d=json.loads(result.read_text()) if result.exists() else {}
    row={'label':label,'passed':process.returncode==0 and d.get('passed',False),'exit_code':process.returncode,'pass_lines':sum('EDGE PASS' in x for x in d.get('checks',[])),'fail_lines':sum('EDGE FAIL' in x for x in d.get('checks',[])),'errors':d.get('errors'),'capture_pose_checks':d.get('capture_pose_checks'),'runtime':'baseline' if package==baseline else 'final'}
    rows.append(row);(out/'SUMMARY.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
    if not row['passed']:sys.exit(1)
