"""Deterministic native appearance fixtures; generated packages remain local."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue148'


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
        "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Select-Object -ExpandProperty ProcessId"], text=True)
    if running.strip():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    baseline = OUT / 'baseline.pk3'
    if not baseline.exists():
        subprocess.run(['git', 'archive', '--format=zip', f'--output={baseline}',
                        '74c31ca5:src'], cwd=ROOT, check=True)
    manifest = {'baseline': hashlib.sha256(baseline.read_bytes()).hexdigest()}
    manifest['production'] = package(OUT / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()})
    for source in sorted(HERE.glob('*.zs')):
        manifest[source.stem] = package(OUT / (source.stem + '.pk3'), {
            'ZSCRIPT': f'version "4.14"\n#include "checks/{source.stem}.zs"\n'.encode(),
            f'checks/{source.stem}.zs': source.read_bytes(),
            'MAPINFO': f'GameInfo {{ AddEventHandlers="CA148{source.stem.title()}" }}\n'.encode()})
    for cfg in HERE.glob('*.cfg'):
        (OUT / cfg.name).write_bytes(cfg.read_bytes())
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print('Prepared:', ', '.join(manifest))


if __name__ == '__main__':
    main()
