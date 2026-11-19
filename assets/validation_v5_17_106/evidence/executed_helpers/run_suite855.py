"""Run settled native recognition, reversible saves and real ability controls."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';runner=Path(__file__).with_name('run_navigation855.py')
base='build/issue851-local03.pk3';final='build/issue855-navigation02.pk3';rows=[]
def run(label,runtime,flags=(),load=None,regression=False):
    out='build/issue855-'+label;command=[sys.executable,str(runner),'--runtime',runtime,'--output',out,*flags]
    if load:command+=['--load',load+'/reach.zds']
    with (root/(out+'-run.log')).open('wb') as log:code=subprocess.run(command,cwd=root,stdout=log,stderr=log).returncode
    data=json.loads((root/out/'RESULTS.json').read_text());failures=[s for s in data['checks'] if 'EDGE FAIL' in s]
    if regression:
        assert code==1 and data['exit_code']==0 and len(failures)==2,(label,code,data)
        assert 'excluded navigation preserves ongoing recognition' in failures[0] and 'real target identifies after two observed seconds' in failures[1],failures
    else:assert code==0 and data['passed'],(label,code,data)
    row=dict(label=label,directory=out,runtime=runtime,load=load,regression_expected=regression,checks=len(data['checks'])-1,failures=failures,passed=data['passed'],engine_exit=data['exit_code'])
    rows.append(row);(root/'build/issue855-native-suite.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
    return out
for boss in (False,True):
    family='zupay' if boss else 'mandinga';flags=['--boss'] if boss else []
    for cold in (False,True):
        kind=family+('-cold' if cold else '-warm');caseflags=flags+(['--cold'] if cold else [])
        old=run(kind+'-base01',base,caseflags,regression=True)
        new=run(kind+'-final01',final,caseflags)
        if cold:
            run(kind+'-upgrade01',final,caseflags,old)
            run(kind+'-reload01',final,caseflags,new)
            run(kind+'-rollback01',base,caseflags,new)
run('abilities-base01',base,['--abilities'])
print('All expected baseline regressions and final/save/ability controls verified.',flush=True)
