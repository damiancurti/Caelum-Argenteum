"""Verify deterministic native registration and format export, preserving originals."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
paths=[ROOT/'src/TEXTURES',ROOT/'src/graphics/caelum/demon_breath.textures']
paths+=list((ROOT/'src/graphics/caelum/icons/potions').glob('*.png'))
paths+=list((ROOT/'assets/art_source/demon_breath_515').glob('*.json'))
sources=list((ROOT/'assets/art_source/demon_breath_515').glob('*.png'))
sources+=list((ROOT/'assets/art_source/potions_515').glob('*.png'))
before={p.relative_to(ROOT).as_posix():sha(p) for p in sources}
runs=[]
for _ in range(2):
    subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(ROOT/'assets/generators/export_potion_tiers.ps1')],check=True)
    for generator in ('register_demon_breath.py','register_zupay_directions.py'):
        subprocess.run([sys.executable,'-X','utf8',str(ROOT/'assets/generators'/generator)],check=True)
    runs.append({p.relative_to(ROOT).as_posix():sha(p) for p in paths})
assert runs[0]==runs[1]
assert before=={p.relative_to(ROOT).as_posix():sha(p) for p in sources}
for name in ('mandinga','zupay'):
    assert sha(ROOT/f'assets/art_source/demon_breath_515/{name}.png')==sha(ROOT/f'src/sprites/caelum/demon_breath/{name}.png')
(HERE/'ART_DETERMINISM.json').write_text(json.dumps({'passes':2,'identical':True,'original_sources':before,'outputs':runs[1]},indent=2)+'\n',encoding='utf-8')
print('PASS: two identical exports/registrations; original PNG bytes preserved.')
