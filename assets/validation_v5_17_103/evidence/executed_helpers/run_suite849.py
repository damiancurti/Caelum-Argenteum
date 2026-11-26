"""Run final/fresh and reversible save checks sequentially."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helper=Path(__file__).parent/'run_carrier849.py'
base='build/issue847-review01.pk3';final='build/issue849-carrier02.pk3'
cases=[('base01',base,None),('final01',final,None),('upgrade01',final,'base01'),('reload01',final,'final01'),('rollback01',base,'final01')]
reports=[]
for label,runtime,prior in cases:
    out='build/issue849-fixture-'+label
    command=[sys.executable,str(helper),'--runtime',runtime,'--reference-runtime',base,'--output',out]
    if prior:command+=['--load','build/issue849-fixture-'+prior+'/contamination.zds']
    with (root/(out+'-run.log')).open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    report=json.loads((root/out/'RESULTS.json').read_text());assert report['passed'];reports.append(dict(case=label,report=report))
    (root/'build/issue849-native-suite.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(case=label,checks=report['checks'],passed=report['passed'])),flush=True)
