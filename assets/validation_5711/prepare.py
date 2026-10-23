"""Prepare #486 presentation checks using the existing #470 station fixture."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue486'
OUT.mkdir(parents=True, exist_ok=True)
members = {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers="CA470Checks" }\n',
    'checks.zs': (ROOT / 'assets/validation_574/checks.zs').read_bytes(),
}
with zipfile.ZipFile(OUT / 'checks.pk3', 'w', zipfile.ZIP_STORED) as package:
    for name, data in sorted(members.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
scripts = {
    'seed': 'wait 105; netevent ca470_author; save ca486-original; wait 10; quit',
    'interactive': 'language es; bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind tab ca_journal; bind q ca_journal; bind f1 "map MAP01; wait 105; netevent ca470_author"; bind f2 "map MAP03; wait 105; netevent ca470_author"; bind f3 "language enu"; bind f4 "language es"; wait 105; netevent ca470_author',
}
for language in ('es', 'enu'):
    scripts[language] = (
        f'language {language}; wait 105; netevent ca470_author; wait 35; '
        f'screenshot "{OUT.as_posix()}/{language}-target.png"; wait 5; '
        '+use; wait 2; -use; wait 35; netevent ca470_use; '
        f'screenshot "{OUT.as_posix()}/{language}-menu.png"; wait 10; quit'
    )
for name, script in scripts.items():
    (OUT / f'{name}.cfg').write_text(script + '\n', encoding='utf-8')
print(f'Prepared {OUT}; existing #470 fixture, no new gameplay test code.')
