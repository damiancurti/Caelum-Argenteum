"""Run canonical local-query fresh, portal and reversible-save fixtures."""
from pathlib import Path
import json,subprocess,sys
h=Path(__file__).resolve().parent;root=h.parents[1]/'build/v517/work-713'
baseline='build/issue849-carrier02.pk3';final='build/issue851-local03.pk3'
cases=[('base01',baseline,None,False),('final01',final,None,False),('upgrade01',final,'base01',False),('reload01',final,'final01',False),('rollback01',baseline,'reload01',False),('portal01',final,None,True),('portal-reload01',final,'portal01',True),('portal-rollback01',baseline,'portal-reload01',True)]
reports=[]
for label,runtime,load,portal in cases:
    out='build/issue851-edges-'+label
    command=[sys.executable,str(h/'run_local_edges851.py'),'--baseline',baseline,'--runtime',runtime,'--output',out]
    if load:command+=['--load','build/issue851-edges-'+load+'/reach.zds']
    if portal:command+=['--portal']
    with (root/('build/issue851-edges-'+label+'-run.log')).open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    result=json.loads((root/out/'RESULTS.json').read_text());assert result['passed']
    row=dict(label=label,runtime=runtime,passed=True,assertions=sum(' EDGE PASS ' in s for s in result['checks']),summaries=[s for s in result['checks'] if 'EDGE_RESULT' in s],directory=out)
    reports.append(row);(root/'build/issue851-native-suite.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(row),flush=True)
