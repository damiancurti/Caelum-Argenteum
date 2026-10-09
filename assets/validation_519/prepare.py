"""Prepare isolated #152 tests. Saves and executable packages stay in build/."""
from pathlib import Path
import importlib.util
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue152'
spec = importlib.util.spec_from_file_location('room', ROOT / 'assets/validation_516/prepare.py')
room = importlib.util.module_from_spec(spec)
spec.loader.exec_module(room)
room.OUT = OUT

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/NH'], text=True).lower():
        raise SystemExit('Finish the current native run first.')
    OUT.mkdir(exist_ok=True)
    room.package('observer.pk3', {
        'maps/CA152.wad': room.room().replace(b'CA143', b'CA152'),
        'MAPINFO': b'map CA152 "Shotgun follow-up" {}\nGameInfo { AddEventHandlers="CA152Observer" }\n',
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n#include "observer.zs"\n',
        'checks.zs': (ROOT / 'assets/validation_517/checks.zs').read_bytes(),
        'observer.zs': (HERE / 'observer.zs').read_bytes(),
        'CVARINFO': b'server int ca152_mode=0;\nserver int ca152_stage=0;\nserver int ca152_weapon=14;\n',
    })
    for name in ('saved', 'checks', 'input', 'visual', 'thermal', 'world'):
        p = HERE / (name + '.cfg')
        if p.exists():
            (OUT / p.name).write_bytes(p.read_bytes())
    for kind,name in ((2,'carbine'),(15,'longbow'),(16,'crossbow')):
        (OUT/f'input-{name}.cfg').write_text(f'ca152_weapon {kind}; '+(OUT/'input.cfg').read_text(),encoding='utf-8')
    (OUT/'save-upgrade.cfg').write_text('unbindall; ca152_mode 0; wait 60; save ca152-upgraded; wait 20; quit\n',encoding='utf-8')
    (OUT/'save-reload.cfg').write_text('unbindall; ca152_mode 0; wait 60; quit\n',encoding='utf-8')
    runner = (ROOT / 'assets/validation_518/run_native.ps1').read_text(encoding='utf-8')
    runner = runner.replace('build\\issue137', 'build\\issue152').replace("'CA137'", "'CA152'")
    runner = runner.replace('build/issue137', 'build/issue152')
    runner += '\n$null = $process.Handle\n$process.WaitForExit()\n$record.exit_code = $process.ExitCode\n$record.finished_utc = [DateTime]::UtcNow.ToString("o")\n$record | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath (Join-Path $work "$Label-run.json")\nif ($record.exit_code -ne 0) { throw "Native run failed: $Label ($($record.exit_code))" }\n'
    (HERE / 'run_native.ps1').write_text(runner, encoding='utf-8', newline='\n')
    print('Prepared #152 observer, scripts and isolated native runner.')

if __name__ == '__main__':
    main()
