"""Measure final and exact parent packages sequentially without diagnostic game scopes."""
from pathlib import Path
import json,re,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
layer=Path(__file__).resolve().parents[2]/'build/v515/tools/presentation'
reports=[]
for label,runtime in [('final','build/issue840-crops02.pk3'),('control','build/issue838-relation02.pk3')]:
    logpath=root/f'build/issue840-{label}-presentation01.log'
    command=[sys.executable,'assets/validation_v5_16_2/run_barracas_presentation.py','--runtime',runtime,'--map','MAP03','--players','1','--siege','--presentation-layer',str(layer)]
    with logpath.open('wb') as log:result=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    assert result.returncode==0,logpath
    text=logpath.read_text(encoding='utf-8');directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());directory.relative_to(root)
    run=json.loads((directory/'results.json').read_text());assert run['passed']
    with (root/f'build/issue840-{label}-queue01.log').open('wb') as log:subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,stdout=log,stderr=log,check=True)
    presentation=json.loads((directory/'presentation.json').read_text())
    row=dict(label=label,directory=directory.relative_to(root).as_posix(),runtime_sha256=run['runtime_sha256'],engine=run['engine'],layer=run['presentation_layer'],simulation=run['peers'][0]['simulation'],states=run['peers'][0]['states'],census=run['peers'][0]['census'],presentation=presentation['peers'][0])
    reports.append(row);(root/'build/issue840-production-performance.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(row),flush=True)
assert reports[0]['states']==reports[1]['states'] and reports[0]['census']==reports[1]['census']
