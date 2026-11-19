"""Run final/control saved-state and paired-pixel cases sequentially."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
runner=Path(__file__).with_name('run_pixels840.py')
old='build/issue838-relation02.pk3';new='build/issue840-crops02.pk3'
cases=[('upgrade03',new,'build/issue840-pixels-base06/pixels.zds'),('final01',new,None),('reload01',new,'build/issue840-pixels-final01/pixels.zds'),('rollback01',old,'build/issue840-pixels-final01/pixels.zds')]
reports=[]
for name,runtime,load in cases:
    out='build/issue840-pixels-'+name
    cmd=[sys.executable,str(runner),'--runtime',runtime,'--reference-runtime',old,'--output',out]
    if load:cmd+=['--load',load]
    with (root/(out+'-run.log')).open('wb') as log:r=subprocess.run(cmd,cwd=root,stdout=log,stderr=log)
    result=json.loads((root/out/'RESULTS.json').read_text());reports.append(dict(case=name,result=out+'/RESULTS.json',passed=result['passed'],exit_code=r.returncode))
    (root/'build/issue840-pixel-suite02.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(reports[-1]),flush=True)
    if r.returncode or not result['passed']:raise SystemExit(1)
