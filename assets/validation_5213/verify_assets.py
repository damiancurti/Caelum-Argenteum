"""Read-only checks for registered appearance output and source provenance."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/appearance_5213'
errors = []
count = 0
for name in ('REGISTRATION.json', 'HAND_REGISTRATION.json'):
    manifest = json.loads((SOURCE / name).read_text())
    for relative, expected in manifest['module_sha256'].items():
        path = ROOT / relative
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            errors.append(f'Output mismatch: {relative}')
        count += 1
provenance = json.loads((SOURCE / 'PROVENANCE.json').read_text())
for asset in provenance['assets']:
    if not (SOURCE / asset['file']).is_file() or not asset['prompt']:
        errors.append(f'Missing source/prompt: {asset["file"]}')
world = (ROOT / 'src/graphics/caelum/appearance.textures').read_text()
names = re.findall(r'^Sprite "([^"]+)"', world, re.M)
if len(names) != 19488 or len(set(names)) != len(names):
    errors.append('World composition coverage or uniqueness mismatch')
for relative in re.findall(r'Patch "(graphics/caelum/appearance/[^"]+)"', world):
    if not (ROOT / 'src' / relative).is_file():
        errors.append(f'Missing patch: {relative}')
result = {'module_hashes_checked': count, 'world_compositions': len(names),
          'source_atlases': len(provenance['assets']), 'errors': sorted(set(errors))}
print(json.dumps(result, indent=2))
raise SystemExit(bool(errors))
