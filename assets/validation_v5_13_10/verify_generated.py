"""Check #614 byte reproducibility and references without invoking an engine."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
files=[*sorted((ROOT/'src/models/caelum/powerups').glob('*.obj')),
       ROOT/'src/caelum/data/CaelumPowerupData.zs',ROOT/'src/caelum/data/powerups.modeldef',
       ROOT/'src/caelum/data/powerups.textures',ROOT/'assets/powerups/GENERATED.json']
def snapshot():return {str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
before=snapshot()
subprocess.run([sys.executable,str(ROOT/'assets/generators/generate_powerups.py')],cwd=ROOT,check=True)
assert before==snapshot(),'Generated output changed'
report=json.loads((ROOT/'assets/powerups/GENERATED.json').read_text())
assert len(report['points']['CASEWER'])==8 and len(report['points']['CAHUNT'])==16
for name,points in report['points'].items():
    assert len({tuple(p) for p in points})==len(points),name
print(json.dumps({'deterministic':True,'files':before,'point_counts':{k:len(v) for k,v in report['points'].items()}},indent=2))
