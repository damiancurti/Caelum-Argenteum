"""Retain one municipal furnishing comparison window, simulation timings and Vulkan presents."""
from pathlib import Path
import argparse, json, re, subprocess, sys

ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--label',required=True);p.add_argument('--runtime',required=True)
p.add_argument('--overlay',required=True);p.add_argument('--scene',choices=['civic','siege'],required=True)
p.add_argument('--presentation-layer',type=Path,required=True)
a=p.parse_args()
assert re.fullmatch('[a-z0-9-]+',a.label)
active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
assert 'gzdoom.exe' not in active.lower(),'Another native engine is running'
logpath=ROOT/f'build/issue886-{a.label}-run.log';assert not logpath.exists()
command=[sys.executable,str(Path(__file__).with_name('run_profile.py')),'--runtime',a.runtime,
         '--map','MAP03','--players','1','--presentation-layer',str(a.presentation_layer.resolve(strict=True)),
         '--overlay',a.overlay,'--scene',a.scene]
with logpath.open('xb') as log:result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=log)
assert result.returncode==0,f'Read {logpath}'
directory=Path(re.search(r'Campaign peers started: (.+)',logpath.read_text(encoding='utf-8'))[1].strip())
directory.relative_to(ROOT);run=json.loads((directory/'results.json').read_text());assert run['passed']
text=(directory/'peer0/engine.log').read_text(encoding='utf-8',errors='replace')
assert 'CA510 BEGIN map='+'MAP03' in text
uses=text.count('CA454 HOUSE USE PASS')
assert uses==0
with (ROOT/f'build/issue886-{a.label}-queue.log').open('xb') as log:
    subprocess.run([sys.executable,'assets/validation_v5_12_7/analyze_vulkan_presents.py',str(directory)],cwd=ROOT,stdout=log,stderr=log,check=True)
row=dict(issue=886,label=a.label,scene=a.scene,directory=directory.relative_to(ROOT).as_posix(),runtime_sha256=run['runtime_sha256'],
         overlays=run['overlays'],engine=run['engine'],layer=run['presentation_layer'],real_house_uses=uses,
         states=run['peers'][0]['states'],census=run['peers'][0]['census'],simulation=run['peers'][0]['simulation'],
         presentation=json.loads((directory/'presentation.json').read_text())['peers'][0],author_acceptance=False,
         qualification='Municipal interior or approved normal1000-attacker/600-defender siege; unchanged native gameplay and original geometry. Queue presentation is not monitor scanout; no author acceptance.')
(ROOT/f'build/issue886-{a.label}-summary.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8')
print(json.dumps(dict(label=a.label,directory=row['directory'],passed=True,presents=row['presentation']['mean_present_fps'],tic_mean=row['simulation']['mean_ms'])))
