"""Sequential final endpoint fixture checks; stop at the first failed engine run."""
from pathlib import Path
import json,subprocess,sys
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runner=Path(__file__).with_name('run_endpoints868.py')
rows=[]
cases=[('baseline02',False,None),('fresh02',True,None),('upgrade03',True,'baseline02'),('reload02',True,'upgrade03'),('rollback02',False,'reload02')]
for label,candidate,load in cases:
    command=[sys.executable,'-X','utf8',str(runner),'--output',f'build/issue868-{label}']
    if candidate:command+=['--candidate','build/issue868-exterior02/prototype.pk3']
    if load:command+=['--load',f'build/issue868-{load}/endpoints.zds']
    subprocess.run(command,cwd=ROOT,check=True)
    report=json.loads((ROOT/f'build/issue868-{label}/RESULTS.json').read_text())
    rows.append(dict(label=label,**report))
    (ROOT/'build/issue868-suite.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(passed=True,runs=len(rows),checks=sum(r['checks'] for r in rows))))
