"""Verify unchanged geometry, authoritative openings and deterministic runtime data."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/generators'))
import generate_city_interiors as interiors

BASE = '1c620037'
data = interiors.DATA
old = json.loads(subprocess.check_output(['git', 'show', BASE+':assets/map06_port/INTERIORS.json'], cwd=ROOT))
checks = {}
checks['original_layout_data_unchanged'] = all(data[k] == v for k, v in old.items() if k != 'constants')
checks['original_rules_unchanged'] = all(data['constants'][k] == v for k, v in old['constants'].items())
homes = interiors.houses(json.loads((ROOT / 'assets/map06_port/CITY.json').read_text()))
groups = {data['constants']['INTERIOR_DOOR_GROUP_BASE'] + house*len(data['doorways']) + door
          for house in range(len(homes)) for door in range(len(data['doorways']))}
entrances = {data['door_group_base'] + h['id'] for h in homes}
checks['groups_unique_and_separate'] = len(groups) == 320 and not groups & entrances
checks['two_leaves_fit_existing_openings'] = all(sorted((x2-x1, y2-y1)) == [64, 4*data['leaf_half_width']] for x1,y1,x2,y2 in data['doorways'])
map_path = ROOT / 'src/maps/MAP06.wad'
map_bytes = map_path.read_bytes()
checks['map_wad_byte_identical'] = map_bytes == subprocess.check_output(['git', 'show', BASE+':src/maps/MAP06.wad'], cwd=ROOT)
generated = ROOT / 'src/caelum/world/CaelumCityData.zs'
original = generated.read_bytes()
subprocess.run(['python', str(ROOT / 'assets/generators/generate_city_interiors.py')], check=True)
checks['deterministic_generated_data'] = generated.read_bytes() == original
package = ROOT / 'build/issue173/production.pk3'
with zipfile.ZipFile(package) as z, zipfile.ZipFile(ROOT / 'build/caelum_argenteum_dev.pk3') as built:
    members = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes() for p in (ROOT / 'src').rglob('*') if p.is_file()}
    checks['tested_package_matches_source'] = set(z.namelist()) == set(members) and all(z.read(n) == b for n,b in members.items())
    checks['standard_build_matches_tested_package'] = set(z.namelist()) == set(built.namelist()) and all(z.read(n) == built.read(n) for n in z.namelist())
result = dict(checks=checks, houses=len(homes), interior_openings=len(groups), leaves=2*len(groups),
              map06_sha256=hashlib.sha256(map_bytes).hexdigest(), production_sha256=hashlib.sha256(package.read_bytes()).hexdigest())
(ROOT / 'build/issue173/static.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))
assert all(checks.values())
