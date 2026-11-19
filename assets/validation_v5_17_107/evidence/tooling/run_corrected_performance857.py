"""Repeat affected candidate captures after frame-order correction; retain controls."""
from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=root/'build/issue857-wardrobe02.pk3';layer=Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation')
rows=[dict(row,reused_unchanged_control=True) for row in json.loads((root/'build/issue857-presentation.json').read_text()) if row['kind']=='control']
for scene,mapname in [('studio','CA836A'),('mansion','MAP01'),('sewers','MAP02'),('city','MAP03')]:
    out=root/f'build/issue857-bench-{scene}-candidate02'
    command=[sys.executable,'-X','utf8','assets/validation_v5_17_107/run_wardrobe_continuity857.py','--mode','bench','--runtime',str(runtime),'--scene',mapname,'--presentation-layer',str(layer),'--output',str(out)]
    with out.with_suffix('.log').open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
    if r.returncode or not d.get('passed'):print(json.dumps(dict(scene=scene,code=r.returncode,errors=d.get('errors'))),flush=True);sys.exit(1)
    row=dict(scene=scene,kind='candidate',directory=out.relative_to(root).as_posix(),presentation=d['presentation'],simulation=d['simulation'],reused_unchanged_control=False);rows.append(row)
    (root/'build/issue857-presentation-final.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
