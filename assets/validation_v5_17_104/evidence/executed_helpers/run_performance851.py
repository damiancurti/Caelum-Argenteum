"""Final/control siege and representative reference scenes, one engine at a time."""
from pathlib import Path
import json,re,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';layer=Path(__file__).resolve().parents[2]/'build/v515/tools/presentation'
reports=[]
cases=[('siege_final','build/issue851-local03.pk3','MAP03',['--siege']),('siege_control','build/issue849-carrier02.pk3','MAP03',['--siege']),('mansion_final','build/issue851-local03.pk3','MAP01',[]),('sewers_final','build/issue851-local03.pk3','MAP02',[]),('city_final','build/issue851-local03.pk3','MAP03',[]),('city_ground_final','build/issue851-local03.pk3','MAP03',['--ground'])]
for label,runtime,mapname,flags in cases:
    logpath=root/f'build/issue851-{label}.log';command=[sys.executable,'assets/validation_v5_16_2/run_barracas_presentation.py','--runtime',runtime,'--map',mapname,'--players','1','--presentation-layer',str(layer),*flags]
    with logpath.open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    text=logpath.read_text(encoding='utf-8');directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());directory.relative_to(root)
    run=json.loads((directory/'results.json').read_text());assert run['passed']
    with (root/f'build/issue851-{label}-queue.log').open('wb') as log:subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,stdout=log,stderr=log,check=True)
    present=json.loads((directory/'presentation.json').read_text())
    row=dict(label=label,directory=directory.relative_to(root).as_posix(),runtime_sha256=run['runtime_sha256'],engine=run['engine'],layer=run['presentation_layer'],simulation=run['peers'][0]['simulation'],states=run['peers'][0]['states'],census=run['peers'][0]['census'],presentation=present['peers'][0])
    reports.append(row);(root/'build/issue851-production-performance.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
assert reports[0]['states']==reports[1]['states'] and reports[0]['census']==reports[1]['census']
