"""Verify final native ownership and reversible saves with current references."""
from pathlib import Path
import json, subprocess, sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runner=Path(__file__).with_name('run_value864_full.py')
base='build/issue861-hands01.pk3';final='build/issue864-value03.pk3'
cases=[('baseline',base,None),('fresh',final,None),('upgrade',final,'baseline'),('reload',final,'upgrade'),('rollback',base,'reload')]
rows=[]
for label,runtime,previous in cases:
    out=root/f'build/issue864-native-{label}01';assert not out.exists()
    command=[sys.executable,str(runner),'--runtime',runtime,'--reference-runtime',base,'--output',str(out)]
    if previous:command+=['--load',str(root/f'build/issue864-native-{previous}01/contamination.zds')]
    logpath=root/f'build/issue864-native-{label}01-run.log';assert not logpath.exists()
    with logpath.open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    assert r.returncode==0,f'Read {logpath}'
    report=json.loads((out/'RESULTS.json').read_text());assert report['passed'] and not report['errors']
    rows.append(dict(label=label,runtime=runtime,directory=out.relative_to(root).as_posix(),checks=report['checks'],passed=True))
    (root/'build/issue864-native-suite.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(rows[-1]),flush=True)
assert len(rows)==5
