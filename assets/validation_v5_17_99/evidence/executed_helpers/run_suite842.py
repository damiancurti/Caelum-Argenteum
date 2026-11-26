"""Run final fresh/upgrade/reload/rollback shelter fixtures sequentially."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helper=Path(__file__).with_name('run_shelter842.py')
cases=[('final01','build/issue842-shelter02.pk3',None),('upgrade01','build/issue842-shelter02.pk3','build/issue842-fixture-base01/shelter.zds'),('reload01','build/issue842-shelter02.pk3','build/issue842-fixture-final01/shelter.zds'),('rollback01','build/issue840-crops02.pk3','build/issue842-fixture-final01/shelter.zds')]
reports=[]
for label,runtime,saved in cases:
    output='build/issue842-fixture-'+label;command=[sys.executable,str(helper),'--runtime',runtime,'--reference-runtime','build/issue840-crops02.pk3','--output',output]
    if saved:command+=['--load',saved]
    with (root/(output+'.log')).open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    result=json.loads((root/output/'RESULTS.json').read_text());assert result['passed'];reports.append({'label':label,'report':output+'/RESULTS.json','checks':int(result['result'][1])})
    (root/'build/issue842-native-suite.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8');print(json.dumps(reports[-1]),flush=True)
