"""Run final clock checks, reversible saves and the positive Limbo context."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helper=Path(__file__).parent/'run_location846.py'
base='build/issue844-null02.pk3';final='build/issue846-location02.pk3';reports=[]
cases=[('final01',final,None,'CA846N'),('upgrade01',final,'base02','CA846N'),('reload01',final,'final01','CA846N'),('rollback01',base,'final01','CA846N'),('limbo01',final,None,'MAP01')]
for label,runtime,prior,mapname in cases:
    out='build/issue846-fixture-'+label;command=[sys.executable,str(helper),'--runtime',runtime,'--reference-runtime',base,'--output',out,'--map',mapname]
    if prior:command+=['--load','build/issue846-fixture-'+prior+'/clock.zds']
    with (root/(out+'-run.log')).open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    report=json.loads((root/out/'RESULTS.json').read_text());assert report['passed'];reports.append(dict(case=label,report=report))
    (root/'build/issue846-native-suite.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(case=label,result=report['result'],passed=True)),flush=True)
