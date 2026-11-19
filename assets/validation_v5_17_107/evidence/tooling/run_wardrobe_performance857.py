"""Compare one real equipped player with the candidate enabled and disabled."""
from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');helper=Path(__file__).resolve().parent
runtime=root/'build/issue857-wardrobe01.pk3';layer=root.parents[2]/'v515/tools/presentation'
layer=Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation')
rows=[]
first=root/'build/issue857-bench-studio-candidate01';d=json.loads((first/'RESULTS.json').read_text())
assert d['passed'];rows.append(dict(scene='studio',kind='candidate',directory=first.relative_to(root).as_posix(),presentation=d['presentation'],simulation=d['simulation']))
for scene,mapname in [('studio','CA836A'),('mansion','MAP01'),('sewers','MAP02'),('city','MAP03')]:
    for kind in ('candidate','control'):
        if scene=='studio' and kind=='candidate':continue
        out=root/f'build/issue857-bench-{scene}-{kind}01'
        command=[sys.executable,'-X','utf8',str(helper/'run_wardrobe_continuity857.py'),'--mode','bench','--runtime',str(runtime),'--scene',mapname,'--presentation-layer',str(layer),'--output',str(out)]
        if kind=='control':command+=['--baseline-fixture']
        with out.with_suffix('.log').open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
        d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
        if r.returncode or not d.get('passed'):print(json.dumps(dict(scene=scene,kind=kind,code=r.returncode,errors=d.get('errors'))),flush=True);sys.exit(1)
        row=dict(scene=scene,kind=kind,directory=out.relative_to(root).as_posix(),presentation=d['presentation'],simulation=d['simulation']);rows.append(row)
        (root/'build/issue857-presentation.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(row),flush=True)
