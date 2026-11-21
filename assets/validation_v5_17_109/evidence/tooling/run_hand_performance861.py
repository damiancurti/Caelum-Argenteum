"""Sequential matched native first-person windows; no overlapping heavy work."""
from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');layer=Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation');rows=[]
for scene,mapname in [('studio','CA836A'),('mansion','MAP01'),('sewers','MAP02'),('city','MAP03')]:
 for kind,package in [('control','issue859-grips02.pk3'),('candidate','issue861-hands01.pk3')]:
  out=root/f'build/issue861-bench-{scene}-{kind}01'
  command=[sys.executable,'-X','utf8','assets/validation_v5_17_109/run_hand_presentation861.py','--runtime',str(root/'build'/package),'--scene',mapname,'--presentation-layer',str(layer),'--output',str(out)]
  if kind=='control':command+=['--baseline-fixture']
  with out.with_suffix('.log').open('wb') as log:process=subprocess.run(command,cwd=root,stdout=log,stderr=log)
  d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
  if process.returncode or not d.get('passed') or not d.get('presentation') or not d.get('simulation'):print(json.dumps({'scene':scene,'kind':kind,'code':process.returncode,'errors':d.get('errors')}),flush=True);sys.exit(1)
  row={'scene':scene,'kind':kind,'directory':out.relative_to(root).as_posix(),'presentation':d['presentation'],'simulation':d['simulation'],'pass_lines':sum('EDGE PASS' in x for x in d['checks']),'runtime_sha256':d['sha256'][str(root/'build'/package)]};rows.append(row)
  (root/'build/issue861-presentation-final.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps({'scene':scene,'kind':kind,'queue_presents_per_second':d['presentation']['mean_present_fps'],'pass_lines':row['pass_lines']}),flush=True)
