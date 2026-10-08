"""Deterministic #132 production, original baseline and isolated native probes."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue132'
BASE = '72eba5fb6b4708c9b38fe3aba79ec95acb6df43e'

def package(name, members):
    with zipfile.ZipFile(OUT / name, 'w', zipfile.ZIP_STORED) as z:
        for key, data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256((OUT / name).read_bytes()).hexdigest()

if __name__ == '__main__':
    processes = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/NH'], text=True)
    if 'gzdoom.exe' in processes.lower():
        raise SystemExit('Wait for the owned engine before replacing packages.')
    OUT.mkdir(exist_ok=True)
    baseline = OUT / 'baseline.pk3'
    if not baseline.exists():
        subprocess.run(['git', 'archive', '--format=zip', '--output', str(OUT/'source.zip'), BASE, 'src'], check=True)
        with zipfile.ZipFile(OUT/'source.zip') as z:
            package('baseline.pk3', {n[4:]: z.read(n) for n in z.namelist() if not n.endswith('/')})
    manifest = {'baseline_commit': BASE, 'baseline_sha256': hashlib.sha256(baseline.read_bytes()).hexdigest()}
    manifest['production_sha256'] = package('production.pk3', {
        p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    (OUT/'upgrade').mkdir(exist_ok=True)
    (OUT/'upgrade/baseline.pk3').write_bytes((OUT/'production.pk3').read_bytes())
    for name in ('checks', 'observer', 'persistence'):
        source = HERE / (name + '.zs')
        if not source.exists():
            continue
        manifest[name] = package(name+'.pk3', {
            'ZSCRIPT': f'version "4.14"\n#include "{name}.zs"\n'.encode(),
            name+'.zs': source.read_bytes(),
            'MAPINFO': f'GameInfo {{ AddEventHandlers = "CA132{name.title()}" }}\n'.encode(),
            'CVARINFO': b'server bool ca132_diagnostic = false;\nserver int ca132_stop_tic = 3500;\n'})
        if name == 'observer':
            import re
            manifest['baseline_observer'] = package('baseline-observer.pk3', {
                'ZSCRIPT': b'version "4.14"\n#include "observer.zs"\n',
                'observer.zs': re.sub(r'        // CURRENT_COUNTERS.*?        // END_CURRENT_COUNTERS', '', source.read_text(encoding='utf-8'), flags=re.S).encode(),
                'MAPINFO': b'GameInfo { AddEventHandlers = "CA132Observer" }\n',
                'CVARINFO': b'server bool ca132_diagnostic = false;\nserver int ca132_stop_tic = 3500;\n'})
    manifest['cap_observer'] = package('cap-observer.pk3', {
        'ZSCRIPT': b'version "4.14"\n#include "observer.zs"\n#include "cap_start.zs"\n',
        'observer.zs': (HERE/'observer.zs').read_bytes(), 'cap_start.zs': (HERE/'cap_start.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers = "CA132CapStart", "CA132Observer" }\n',
        'CVARINFO': b'server bool ca132_diagnostic = false;\nserver int ca132_stop_tic = 3500;\n'})
    (OUT/'MANIFEST.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    for config in HERE.glob('*.cfg'):
        (OUT/config.name).write_bytes(config.read_bytes())
    print(json.dumps(manifest, indent=2))
