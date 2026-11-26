"""Measure final production then repeat its original control, sequentially."""
from pathlib import Path
import json,subprocess,sys
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'
cases=[('final01','build/issue836-reach04.pk3'),('baseline02','build/issue834-format01.pk3')]
results=[]
for name,runtime in cases:
    before=set((R/'build/v516').glob('barracas-profile-*'))
    command=[sys.executable,'assets/validation_v5_16_2/run_barracas_presentation.py','--runtime',runtime,'--map','MAP03','--players','1','--siege','--presentation-layer','C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation']
    print('Starting sequential #836 '+name,flush=True)
    with (R/f'build/issue836-presentation-{name}-run.log').open('wb') as log:
        subprocess.run(command,cwd=R,stdout=log,stderr=log,check=True)
    added=set((R/'build/v516').glob('barracas-profile-*'))-before;assert len(added)==1
    out=added.pop()
    with (R/f'build/issue836-presentation-{name}-analysis.log').open('wb') as log:
        subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(out)],cwd=R,stdout=log,stderr=log,check=True)
    report=json.loads((out/'results.json').read_text());presentation=json.loads((out/'presentation.json').read_text())
    assert report['passed']
    row={'name':name,'directory':out.relative_to(R).as_posix(),'runtime_sha256':report['runtime_sha256'],'simulation':report['peers'][0]['simulation'],'presentation':presentation['peers'][0],'states':report['peers'][0]['states']}
    results.append(row)
    (R/'build/issue836-presentation-final.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'name':name,'directory':row['directory'],'presents_s':row['presentation']['mean_present_fps'],'simulation':row['simulation']}),flush=True)
