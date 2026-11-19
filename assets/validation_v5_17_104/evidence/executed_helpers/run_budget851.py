"""Measure separate native, combat-region and environmental views sequentially."""
from pathlib import Path
import json,re,subprocess,sys
h=Path(__file__).parent;root=h.parents[1]/'build/v517/work-713';layer=h.parents[1]/'build/v515/tools/presentation'
cases=[('native01',h/'run_snapshots851.py',None,None),('regions01',root/'assets/validation_v5_16_2/run_barracas_presentation.py','maintenance.pk3','analyze_regions851.py'),('environment01',root/'assets/validation_v5_16_2/run_barracas_presentation.py','services.pk3','analyze_environment851.py')]
reports=[]
for label,script,overlay,analyzer in cases:
    command=[sys.executable,str(script),'--runtime','build/issue849-carrier02.pk3','--map','MAP03','--players','1','--siege','--presentation-layer',str(layer)]
    if overlay:command+=['--overlay',f'build/issue851-{label}/{overlay}']
    path=root/f'build/issue851-{label}-run.log'
    with path.open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    text=path.read_text(encoding='utf-8');directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());directory.relative_to(root)
    run=json.loads((directory/'results.json').read_text());assert run['passed']
    with (root/f'build/issue851-{label}-queue.log').open('wb') as log:subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,stdout=log,stderr=log,check=True)
    if analyzer:
        with (root/f'build/issue851-{label}-analysis.log').open('wb') as log:subprocess.run([sys.executable,str(h/analyzer),'--profile',f'build/issue851-{label}','--run',str(directory),'--output',f'build/issue851-{label}-analysis.json'],cwd=root,stdout=log,stderr=log,check=True)
    else:
        engine=(directory/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
        assert 'Benchmark info saved' in engine and (directory/'peer0/benchmarks.txt').stat().st_size>0
    row=dict(label=label,directory=directory.relative_to(root).as_posix(),runtime_sha256=run['runtime_sha256'],engine=run['engine'],layer=run['presentation_layer'],states=run['peers'][0]['states'],census=run['peers'][0]['census'],simulation=run['peers'][0]['simulation'],presentation=json.loads((directory/'presentation.json').read_text())['peers'][0])
    reports.append(row);(root/'build/issue851-budget-runs.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(label=label,directory=row['directory'],passed=True)),flush=True)
assert all(r['states']==reports[0]['states'] and r['census']==reports[0]['census'] for r in reports)
