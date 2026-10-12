"""Build deterministic isolated #207 fixtures; engine dependencies stay local."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue207'

def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
        "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Select-Object -ExpandProperty ProcessId"],text=True)
    if running.strip():
        raise SystemExit('Close the native test before replacing packages.')
    OUT.mkdir(exist_ok=True)
    baseline = OUT / 'baseline.pk3'
    if not baseline.exists():
        subprocess.run(['git','archive','--format=zip',f'--output={baseline}','1bf5087e:src'],cwd=ROOT,check=True)
    manifest = {'baseline':hashlib.sha256(baseline.read_bytes()).hexdigest()}
    manifest['production'] = package(OUT/'production.pk3',{
        p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    manifest['contract'] = package(OUT/'contract.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "checks/contract.zs"\n',
        'checks/contract.zs':(HERE/'contract.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA207Contract" }\n'})
    for cfg in HERE.glob('*.cfg'):
        (OUT/cfg.name).write_bytes(cfg.read_bytes())
    (OUT/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
    print('Prepared baseline, production and isolated contract packages.')

if __name__=='__main__':
    main()
