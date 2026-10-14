"""Load the genuine pre-fix save with corrected code under its required basename."""
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'build/issue234-city-fix'
OUT = WORK / 'load-baseline'
running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
    "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {$_.CommandLine -like '*issue234-city-fix\\load-baseline\\*'} | Select-Object -ExpandProperty ProcessId"], text=True)
if running.strip():
    raise SystemExit('Finish the old-save run before preparing its files.')
run = json.loads((WORK / 'city-before-07-run.json').read_text(encoding='utf-8-sig'))
assert run['exit_code'] == 0
assert run['runtime_sha256'].lower() == '0b7072e6d6a6468d9b24e1b156ad5af01b11d0e3a4835b6437d8f43ea24b76ec'
OUT.mkdir(exist_ok=True)
for source, destination in [('production.pk3', 'baseline.pk3'), ('production.pk3', 'production.pk3'),
                            ('cityfix.pk3', 'cityfix.pk3'), ('city-before-07-services.zds', 'old-city.zds'),
                            ('cityfix-old-save.cfg', 'cityfix-old-save.cfg')]:
    shutil.copyfile(WORK / source, OUT / destination)
print('Prepared genuine pre-fix save; original baseline/package/save preserved.')
