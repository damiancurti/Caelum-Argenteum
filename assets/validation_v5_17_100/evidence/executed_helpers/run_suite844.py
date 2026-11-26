"""Run final/fresh and reversible save checks sequentially."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helper=Path(__file__).parent/'run_null844.py'
base='build/issue842-shelter02.pk3';final='build/issue844-null02.pk3'
cases=[('final02',final,None),('upgrade02',final,'base03'),('reload02',final,'final02'),('rollback02',base,'final02')]
reports=[]
for label,runtime,prior in cases:
    out='build/issue844-fixture-'+label
    command=[sys.executable,str(helper),'--runtime',runtime,'--reference-runtime',base,'--output',out]
    if prior:command+=['--load','build/issue844-fixture-'+prior+'/contamination.zds']
    with (root/(out+'-run.log')).open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    report=json.loads((root/out/'RESULTS.json').read_text());assert report['passed'];reports.append(dict(case=label,report=report))
    (root/'build/issue844-native-suite.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(case=label,checks=report['checks'],passed=report['passed'])),flush=True)
