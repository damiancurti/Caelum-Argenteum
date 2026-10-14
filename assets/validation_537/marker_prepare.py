"""Prepare a separate regression package without replacing the author's session."""
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path
from prepare import package

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue234-marker-fix'
running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
    "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*build\\issue234-marker-fix\\*'} | Select-Object -ExpandProperty ProcessId"], text=True)
if running.strip():
    raise SystemExit('Finish the marker regression run before replacing its packages.')
OUT.mkdir(exist_ok=True)
baseline = OUT / 'baseline.pk3'
if not baseline.exists():
    shutil.copyfile(ROOT / 'build/issue234/production.pk3', baseline)
sources = ['legacy', 'probe', 'marker']
members = {f'checks/{name}.zs': (HERE / f'{name}.zs').read_bytes() for name in sources}
members['ZSCRIPT'] = ('version "4.14"\n' + ''.join(f'#include "checks/{name}.zs"\n' for name in sources)).encode()
members['MAPINFO'] = b'GameInfo { AddEventHandlers="CA234Legacy", "CA234Probe", "CA234Marker" }\n'
manifest = {'baseline': hashlib.sha256(baseline.read_bytes()).hexdigest(),
    'production': (hashlib.sha256((OUT / 'production.pk3').read_bytes()).hexdigest() if '--fixtures-only' in sys.argv
        else package(OUT / 'production.pk3', {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
            for p in (ROOT / 'src').rglob('*') if p.is_file()})),
    'marker': package(OUT / 'marker.pk3', members)}
for cfg in HERE.glob('marker-*.cfg'):
    (OUT / cfg.name).write_text('; '.join(cfg.read_text(encoding='utf-8').splitlines())+'\n', encoding='utf-8')
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print(json.dumps(manifest))
