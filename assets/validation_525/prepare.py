"""Build deterministic development-only fixtures and isolated runtime aliases."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue185'
BASE = '0894d41d'


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    command = "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*build\\issue185\\*'} | Select-Object -ExpandProperty ProcessId"
    if subprocess.check_output(['powershell', '-NoProfile', '-Command', command], text=True).strip():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    if not (OUT / 'baseline.pk3').exists():
        subprocess.run(['git', 'archive', '--format=zip', f'--output={OUT / "baseline.pk3"}', BASE + ':src'], cwd=ROOT, check=True)
    manifest = {'baseline': hashlib.sha256((OUT / 'baseline.pk3').read_bytes()).hexdigest()}
    members = {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()}
    manifest['production'] = package(OUT / 'production.pk3', members)
    members['MAPINFO'] = members['MAPINFO'].replace(b'AddDialogues = "dialogues/runtime.usdf"', b'AddDialogues = "CAPALOMO"')
    manifest['compatibility'] = package(OUT / 'compatibility.pk3', members)
    for source in sorted(HERE.glob('*.zs')):
        handlers = f'"CA185{source.stem.title()}"'
        members = {'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
                   'checks.zs': source.read_bytes(),
                   'CVARINFO': b'server int ca185_stage=0;\n',
                   'MAPINFO': f'GameInfo {{ AddEventHandlers={handlers} }}\n'.encode()}
        manifest[source.stem] = package(OUT / (source.stem + '.pk3'), members)
    for cfg in HERE.glob('*.cfg'):
        (OUT / cfg.name).write_bytes(cfg.read_bytes())
    # Reuse the committed #183 fixture to verify loading its saved MAP02 state.
    prior = ROOT / 'assets/validation_524'
    manifest['journey'] = package(OUT / 'journey.pk3', {
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs': (prior / 'journey.zs').read_bytes(),
        'CVARINFO': b'server int ca183_stage=0;\n',
        'MAPINFO': b'GameInfo { AddEventHandlers="CA183Journey" }\n'})
    (OUT / 'reload.cfg').write_bytes((prior / 'reload.cfg').read_bytes())
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print('Prepared #185 packages:', ', '.join(manifest))


if __name__ == '__main__':
    main()
