"""Prepare deterministic #192 development-only native test packages."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue192'
BASE = '52e3bd01'


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    command = "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*build\\issue192\\*'} | Select-Object -ExpandProperty ProcessId"
    if subprocess.check_output(['powershell', '-NoProfile', '-Command', command], text=True).strip():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    if not (OUT / 'baseline.pk3').exists():
        subprocess.run(['git', 'archive', '--format=zip', f'--output={OUT / "baseline.pk3"}', BASE + ':src'], cwd=ROOT, check=True)
    manifest = {'baseline': hashlib.sha256((OUT / 'baseline.pk3').read_bytes()).hexdigest()}
    manifest['production'] = package(OUT / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()})
    for source in sorted(HERE.glob('*.zs')):
        members = {'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
                   'checks.zs': source.read_bytes(),
                   'CVARINFO': b'server int ca192_stage=0;\n',
                   'MAPINFO': f'GameInfo {{ AddEventHandlers="CA192{source.stem.title()}" }}\n'.encode()}
        if source.stem in ('comparison','collision'):
            members['checks.zs']=(HERE/'native.zs').read_bytes()+b'\n'+source.read_bytes()
        manifest[source.stem] = package(OUT / (source.stem + '.pk3'), members)
        if source.stem=='persistence':
            legacy=OUT/'legacy';legacy.mkdir(exist_ok=True)
            old=re.sub(r'(?ms)^ *// #NEW-BEGIN.*?^ *// #NEW-END\r?\n','',source.read_text(encoding='utf-8'))
            members['checks.zs']=old.encode('utf-8')
            manifest['legacy_persistence']=package(legacy/'persistence.pk3',members)
    for cfg in HERE.glob('*.cfg'):
        (OUT / cfg.name).write_bytes(cfg.read_bytes())
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print('Prepared #192 packages:', ', '.join(manifest))


if __name__ == '__main__':
    main()
