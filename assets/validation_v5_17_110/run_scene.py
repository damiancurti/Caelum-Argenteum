"""Run one native contact/performance scene and retain its bounded results."""
from pathlib import Path
import argparse, json, re, subprocess, sys

root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--label', required=True);p.add_argument('--runtime', required=True)
p.add_argument('--overlay');p.add_argument('--types', action='store_true')
p.add_argument('--map', default='MAP03');p.add_argument('--siege', action='store_true');p.add_argument('--ground', action='store_true')
p.add_argument('--presentation-layer',type=Path,required=True)
a=p.parse_args();layer=a.presentation_layer.resolve(strict=True);logpath=root/f'build/issue864-{a.label}-run.log';assert not logpath.exists()
command=[sys.executable,'assets/validation_v5_16_2/run_barracas_presentation.py','--runtime',a.runtime,
    '--map',a.map,'--players','1','--presentation-layer',str(layer)]
if a.overlay:command+=['--overlay',a.overlay]
if a.siege:command+=['--siege']
if a.ground:command+=['--ground']
with logpath.open('wb') as log:r=subprocess.run(command,cwd=root,stdout=log,stderr=log)
assert r.returncode==0,f'Read {logpath}'
directory=Path(re.search(r'Campaign peers started: (.+)',logpath.read_text(encoding='utf-8'))[1].strip())
directory.relative_to(root);run=json.loads((directory/'results.json').read_text());assert run['passed']
with (root/f'build/issue864-{a.label}-queue.log').open('wb') as log:
    subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=root,stdout=log,stderr=log,check=True)
row=dict(label=a.label,directory=directory.relative_to(root).as_posix(),runtime_sha256=run['runtime_sha256'],
    overlays=run['overlays'],engine=run['engine'],layer=run['presentation_layer'],states=run['peers'][0]['states'],
    census=run['peers'][0]['census'],simulation=run['peers'][0]['simulation'],
    presentation=json.loads((directory/'presentation.json').read_text())['peers'][0])
if a.types:
    text=(directory/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
    complete=re.search(r'CA849 STORAGE_COMPLETE mismatches=(\d+)',text);assert complete and int(complete[1])==0
    row['type_counts']=[dict(name=n,get=int(g),value=int(v)) for n,g,v in re.findall(r'CA849 TYPE name=(\w+) get=(\d+) value=(\d+)',text)]
    row['service_rows']=[dict(tic=int(t),metric=int(m),total_ms=float(v),maximum_ms=float(x),calls=int(n)) for t,m,v,x,n in re.findall(r'CA849 STORAGE tic=(\d+) metric=(\d+) total=([\d.]+) maximum=([\d.]+) calls=(\d+)',text)]
    row['warm_pointer_mismatches']=int(complete[1])
(root/f'build/issue864-{a.label}-summary.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8')
print(json.dumps(dict(label=a.label,directory=row['directory'],passed=True,presents=row['presentation']['mean_present_fps'],tic_mean=row['simulation']['mean_ms'])))
