"""Verify #471 provenance, icon alpha, geometry and deterministic generation."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
MANIFEST=ROOT/'assets/generators/alchemy_ingredients_manifest.json'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
data=json.loads(MANIFEST.read_text(encoding='utf-8'))
paths=[MANIFEST,HERE/'ingredient-sheet.png']
for row in data['assets']:
    paths.extend(ROOT/'src'/row[k] for k in ('model','icon'))
paths.extend(ROOT/'src'/name for name in data['textures'])
before={p.relative_to(ROOT).as_posix():sha(p) for p in paths}
for repeat in range(2):
    subprocess.run([sys.executable,str(ROOT/'assets/generators/generate_alchemy_ingredients.py')],check=True,cwd=ROOT)
    assert before=={p.relative_to(ROOT).as_posix():sha(p) for p in paths},'Non-deterministic generation'
records=[]
for row in data['assets']:
    model=ROOT/'src'/row['model'];icon=ROOT/'src'/row['icon']
    assert sha(model)==row['model_sha256'] and sha(icon)==row['icon_sha256']
    text=model.read_text(encoding='utf-8')
    assert len(re.findall(r'^v ',text,re.M))==row['vertices']
    assert len(re.findall(r'^f ',text,re.M))==row['faces']
    assert len(re.findall(r'^usemtl ',text,re.M))==row['surface_runs']<=32
    for material in re.findall(r'^usemtl (.+)$',text,re.M):assert (ROOT/'src'/material).is_file()
    image=Image.open(icon);assert image.mode=='RGBA' and image.size==(128,128)
    alpha=image.getchannel('A');bounds=alpha.getbbox()
    assert alpha.getextrema()==(0,255) and bounds and min(bounds[:2])>0 and max(bounds[2:])<128
    records.append({'key':row['key'],'vertices':row['vertices'],'faces':row['faces'],'alpha_bounds':bounds})
for name,digest in data['inputs'].items():assert sha(ROOT/name)==digest,name
for name,digest in data['textures'].items():assert sha(ROOT/'src'/name)==digest,name
assert len({row['icon_sha256'] for row in data['assets']})==11
original=subprocess.check_output(['git','show','091aa15a:src/models/caelum/world/marine_resources/iodine.obj'],cwd=ROOT)
assert (ROOT/'src/models/caelum/world/marine_resources/iodine.obj').read_bytes().replace(b'\r\n',b'\n')==original.replace(b'\r\n',b'\n')
report={'issue':471,'iterations':2,'records':records,'hashes':before,'iodine_geometry':'Unchanged from accepted 091aa15a; line ending normalization only for Git comparison'}
(HERE/'generation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print('PASS: 11 distinct complete RGBA icons, geometry/textures/provenance, unchanged iodine and two byte-identical generations.')
