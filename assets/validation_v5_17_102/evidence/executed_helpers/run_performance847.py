"""Compare the optional material overlay at the retained peaceful sewer entrance."""
from pathlib import Path
import hashlib,json,re,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';layer=Path(__file__).resolve().parents[2]/'build/v515/tools/presentation'
reports=[]
for label,flags in [('sewers_control',[]),('sewers_candidate',['--overlay','build/issue847-material01.pk3'])]:
    logpath=root/f'build/issue847-{label}.log'
    command=[sys.executable,'assets/validation_v5_16_2/run_barracas_presentation.py','--runtime','build/issue847-review01.pk3','--map','MAP02','--players','1','--presentation-layer',str(layer),*flags]
    with logpath.open('wb') as log:subprocess.run(command,cwd=root,stdout=log,stderr=log,check=True)
    directory=Path(re.search(r'Campaign peers started: (.+)',logpath.read_text(encoding='utf-8'))[1].strip());directory.relative_to(root)
    run=json.loads((directory/'results.json').read_text());assert run['passed']
    with (root/f'build/issue847-{label}-queue.log').open('wb') as log:subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,stdout=log,stderr=log,check=True)
    present=json.loads((directory/'presentation.json').read_text())
    row=dict(label=label,directory=directory.relative_to(root).as_posix(),runtime_sha256=run['runtime_sha256'],overlay_sha256=hashlib.sha256((root/'build/issue847-material01.pk3').read_bytes()).hexdigest() if flags else None,engine=run['engine'],layer=run['presentation_layer'],simulation=run['peers'][0]['simulation'],states=run['peers'][0]['states'],census=run['peers'][0]['census'],presentation=present['peers'][0])
    reports.append(row);(root/'build/issue847-production-performance.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(label=label,directory=row['directory'],presents_per_second=row['presentation']['mean_present_fps'])),flush=True)
assert reports[0]['states']==reports[1]['states'] and reports[0]['census']==reports[1]['census']
