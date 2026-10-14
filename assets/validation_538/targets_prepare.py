"""Package the #235 target-marker regression without replacing prior evidence."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
from prepare import package

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue235-targets'
OUT.mkdir(exist_ok=True)
running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
    "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*build\\issue235-targets\\*'} | Select-Object -ExpandProperty ProcessId"], text=True)
if running.strip():
    raise SystemExit('Finish the active target-marker run before packaging.')
baseline = OUT / 'baseline.pk3'
if not baseline.exists():
    subprocess.run(['git', 'archive', '--format=zip', f'--output={baseline}',
                    '71bdfc11:src'], cwd=ROOT, check=True)
manifest = {'baseline': hashlib.sha256(baseline.read_bytes()).hexdigest()}
manifest['production'] = package(OUT / 'production.pk3', {
    p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
    for p in (ROOT / 'src').rglob('*') if p.is_file()})
for name in ('probe', 'targets'):
    manifest[name] = package(OUT / (name + '.pk3'), {
        'ZSCRIPT': f'version "4.14"\n#include "checks/{name}.zs"\n'.encode(),
        f'checks/{name}.zs': (HERE / (name + '.zs')).read_bytes(),
        'MAPINFO': f'GameInfo {{ AddEventHandlers="CA235{name.title()}" }}\n'.encode()})
for source in HERE.glob('targets-*.cfg'):
    lines = [line.strip() for line in source.read_text(encoding='utf-8').splitlines()
             if line.strip() and not line.lstrip().startswith('//')]
    (OUT / source.name).write_text('; '.join(lines) + '\n', encoding='utf-8')
save = OUT / 'c235-tracked.zds'
if not save.exists():
    shutil.copyfile(ROOT / 'build/issue235/c235-tracked.zds', save)
manifest['input_save'] = hashlib.sha256(save.read_bytes()).hexdigest()
# Native saves remember the original runtime archive basename.
load = OUT / 'load-baseline'
load.mkdir(exist_ok=True)
shutil.copyfile(baseline, load / 'production.pk3')
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
print(json.dumps(manifest, indent=2))
