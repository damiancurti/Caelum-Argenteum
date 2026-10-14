"""Prepare isolated city regressions; preserve earlier packages and active sessions."""
import hashlib
import json
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path
from prepare import package

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue234-city-fix'
running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
    "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*build\\issue234-city-fix\\*'} | Select-Object -ExpandProperty ProcessId"], text=True)
if running.strip():
    raise SystemExit('Finish this city regression session before replacing its packages.')
OUT.mkdir(exist_ok=True)
if not (OUT / 'baseline.pk3').exists():
    shutil.copyfile(ROOT / 'build/issue234-open-padlock/production.pk3', OUT / 'baseline.pk3')
city = json.loads((ROOT / 'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
interiors = json.loads((ROOT / 'assets/map06_port/INTERIORS.json').read_text(encoding='utf-8'))
sites = []
for i, building in enumerate(b for b in city['buildings'] if b['kind'] == 'factory'):
    for j, kind in enumerate(interiors['factory_profiles'][i % len(interiors['factory_profiles'])]['stations']):
        dx, dy = interiors['station_positions'][j]
        sites.append({'id': f'city-factory-{building["id"]}-{kind}',
                      'position': [building['bounds'][0]+dx, building['bounds'][1]+dy, 0],
                      'editor': interiors['station_editors'][kind]})
# Verify authored slots against actual WAD things without rebuilding geometry.
wad = (ROOT / 'src/maps/MAP06.wad').read_bytes()
_, count, directory = struct.unpack_from('<4sii', wad)
for i in range(count):
    start, size, name = struct.unpack_from('<ii8s', wad, directory+i*16)
    if name.rstrip(b'\0') == b'TEXTMAP':
        textmap = wad[start:start+size].decode('utf-8')
things = [dict(re.findall(r'(\w+)\s*=\s*([^;]+);', block))
          for block in re.findall(r'\bthing\s*\{([^}]+)\}', textmap)]
for site in sites:
    x, y, _ = site['position']
    matches = [t for t in things if int(t['type']) == site['editor']
               and float(t['x']) == x and float(t['y']) == y and float(t.get('height', 0)) == 0]
    assert len(matches) == 1, site
assert len({s['id'] for s in sites}) == len(sites)
data = ['class CA234CitySites : Object {', f'const COUNT={len(sites)};']
for result_type, name, field in [('String', 'Id', 'id'), ('Vector3', 'Position', 'position')]:
    data += [f'static {result_type} {name}(int i) {{ switch(i) {{']
    for i, site in enumerate(sites):
        value = '"'+site[field]+'"' if field == 'id' else '('+','.join(map(str, site[field]))+')'
        data.append(f'case {i}: return {value};')
    data += ['} return '+('""' if field == 'id' else '(0,0,0)')+'; }']
data += ['}']
members = {'checks/sites.zs': ('\n'.join(data)+'\n').encode(),
           'checks/legacy.zs': (HERE / 'legacy.zs').read_bytes(),
           'checks/cityfix.zs': (HERE / 'cityfix.zs').read_bytes(),
           'ZSCRIPT': b'version "4.14"\n#include "checks/sites.zs"\n#include "checks/legacy.zs"\n#include "checks/cityfix.zs"\n',
           'MAPINFO': b'GameInfo { AddEventHandlers="CA234Legacy", "CA234Cityfix" }\n'}
manifest = {'authored_stations_verified_in_wad': len(sites),
            'baseline': hashlib.sha256((OUT / 'baseline.pk3').read_bytes()).hexdigest(),
            'fixture': package(OUT / 'cityfix.pk3', members)}
if '--fixtures-only' not in sys.argv:
    package(OUT / 'production.pk3', {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
                                   for p in (ROOT / 'src').rglob('*') if p.is_file()})
manifest['production'] = hashlib.sha256((OUT / 'production.pk3').read_bytes()).hexdigest()
for cfg in HERE.glob('cityfix-*.cfg'):
    (OUT / cfg.name).write_text('; '.join(cfg.read_text(encoding='utf-8').splitlines())+'\n', encoding='utf-8')
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print(json.dumps(manifest))
