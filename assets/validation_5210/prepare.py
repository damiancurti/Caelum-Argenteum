"""Build deterministic, local-only packages for the #192 ranged amendment."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue192-ranged'


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
    if not (OUT / 'baseline.pk3').exists():
        subprocess.run(['git', 'archive', '--format=zip', f'--output={OUT / "baseline.pk3"}',
                        'c8518c6e:src'], cwd=ROOT, check=True)
    manifest = {'baseline': hashlib.sha256((OUT / 'baseline.pk3').read_bytes()).hexdigest()}
    manifest['production'] = package(OUT / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()})
    for source in sorted(HERE.glob('*.zs')):
        data = source.read_bytes()
        if source.stem == 'ranged':
            data = (HERE / 'base.zs.inc').read_bytes() + b'\n' + data
        manifest[source.stem] = package(OUT / (source.stem + '.pk3'), {
            'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n', 'checks.zs': data,
            'MAPINFO': f'GameInfo {{ AddEventHandlers="CA192{source.stem.title()}" }}\n'.encode()})
    for cfg in HERE.glob('*.cfg'):
        (OUT / cfg.name).write_bytes(cfg.read_bytes())
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8', newline='\n')
    print('Prepared:', ', '.join(manifest))


if __name__ == '__main__':
    main()
