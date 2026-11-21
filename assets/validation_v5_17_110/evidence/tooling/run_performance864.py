"""Run final/control siege and four retained reference views sequentially."""
from pathlib import Path
import json, subprocess, sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
layer=Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation')
base='build/issue861-hands01.pk3';final='build/issue864-value03.pk3'
cases=[('siege-control01',base,'MAP03',['--siege']),('siege-final01',final,'MAP03',['--siege']),
    ('mansion-final01',final,'MAP01',[]),('sewers-final01',final,'MAP02',[]),
    ('city-final01',final,'MAP03',[]),('ground-final01',final,'MAP03',['--ground'])]
rows=[]
for label,runtime,mapname,flags in cases:
    command=[sys.executable,'assets/validation_v5_17_110/run_scene.py','--label',label,'--runtime',runtime,
        '--map',mapname,'--presentation-layer',str(layer),*flags]
    subprocess.run(command,cwd=root,check=True)
    row=json.loads((root/f'build/issue864-{label}-summary.json').read_text());rows.append(row)
    (root/'build/issue864-production-performance.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
assert rows[0]['states']==rows[1]['states'] and rows[0]['census']==rows[1]['census']
print('All six scenes completed; final/control siege state and census agree.')
