"""Sequential final/control presentation windows with post-window native stats."""
from pathlib import Path
import json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
rows=[]
for name,runtime in [('final01','build/issue838-relation02.pk3'),('baseline01','build/issue836-reach04.pk3')]:
    prior=set((root/'build/v516').glob('barracas-profile-*'))
    command=[sys.executable,str(Path(__file__).with_name('run_bench838.py')),'--runtime',runtime,'--map','MAP03','--players','1','--siege','--presentation-layer','C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation']
    with (root/f'build/issue838-{name}-presentation.log').open('wb') as log:done=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    assert done.returncode==0,name
    added=set((root/'build/v516').glob('barracas-profile-*'))-prior;assert len(added)==1
    directory=added.pop();subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,check=True,stdout=subprocess.DEVNULL)
    result=json.loads((directory/'results.json').read_text());assert result['passed']
    row={'name':name,'directory':directory.relative_to(root).as_posix(),'passed':True,'simulation':result['peers'][0]['simulation'],'presentation':json.loads((directory/'presentation.json').read_text())['peers'][0]};rows.append(row)
    print(json.dumps(row),flush=True)
    (root/'build/issue838-presentation-final.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
