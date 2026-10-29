"""Reuse existing fixtures, preserving their documented maps and rules."""
from pathlib import Path
import subprocess
import sys
import zipfile

root = Path(__file__).resolve().parents[2]
work = root / 'build/issue502-adapters'
subprocess.run([sys.executable, 'assets/validation_5815/prepare.py'], cwd=root, check=True)
(work / 'regression15.pk3').write_bytes((root / 'build/issue412-bags/checks.pk3').read_bytes())
for case in ['entry', 'entry-clean']:
    (work / ('r15-' + case + '.cfg')).write_bytes((root / ('build/issue412-bags/' + case + '.cfg')).read_bytes())
members = {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs': (root / 'assets/validation_5849/checks.zs').read_bytes().replace(b'ProvisionRevision==27', b'ProvisionRevision==28'),
    'MAPINFO': b'GameInfo {AddEventHandlers="CA502PhysicalChecks"}\ncluster 8549 {hub}\nmap MAP01 "Physical contact" {cluster=8549}\nmap CPH502B "Away" {cluster=8549}\n',
    'maps/MAP01.wad': (root / 'assets/validation_5826/away.wad').read_bytes(),
    'maps/CPH502B.wad': (root / 'assets/validation_5826/away.wad').read_bytes(),
}
with zipfile.ZipFile(work / 'regression49.pk3', 'w', zipfile.ZIP_STORED) as out:
    for name, data in sorted(members.items()):
        out.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
for case in ['food', 'forecast', 'support']:
    (work / ('r49-' + case + '.cfg')).write_text(f'wait 105; netevent ca502p_{case}; wait 10; quit\n')
