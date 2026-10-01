"""Verify byte-identical regeneration of every #61 generated output."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'build_dev.ps1').is_file())
paths=['src/maps/MAP01.wad','src/MODELDEF','src/MAPINFO','src/caelum/world/CaelumMansionTympana.zs','assets/map01_mansion/EXTERIOR_GENERATED.json']
paths += [str(p.relative_to(ROOT)).replace('\\','/') for p in sorted((ROOT/'src/models/caelum/mansion').glob('*.obj'))]
def hashes():return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in paths}
before=hashes()
subprocess.run([sys.executable,'assets/generators/generate_map01_exterior.py'],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
after=hashes()
result={'issue':61,'byte_identical':before==after,'files':after}
(ROOT/'build/issue61_determinism.json').write_text(json.dumps(result,indent=2)+'\n')
assert before==after
print('PASS: byte-identical regeneration of',len(paths),'outputs')
