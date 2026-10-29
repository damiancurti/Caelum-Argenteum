"""Prepare private issue #415 tests; preserve the prior runtime package."""
from pathlib import Path
import argparse
import subprocess
import zipfile

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / 'build/issue415-rounds'
BASE = R.parent / 'issue502-physical-work/build/issue502-adapters/final50b/caelum_argenteum_dev.pk3'


def pack(path, members):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


parser = argparse.ArgumentParser()
parser.add_argument('--probe', action='store_true')
args = parser.parse_args()
if args.probe:
    changed = set(subprocess.check_output(
        ['git', 'diff', '8aab788d', '--name-only', '--', 'src'], cwd=R, text=True).splitlines())
    changed.update(subprocess.check_output(
        ['git', 'ls-files', '--others', '--exclude-standard', '--', 'src'], cwd=R, text=True).splitlines())
    changed = {name[4:] for name in changed}
    with zipfile.ZipFile(BASE) as old:
        pack(W / 'probe/caelum_argenteum_dev.pk3', {
            name: (R / 'src' / name).read_bytes() if name in changed else old.read(name)
            for name in set(old.namelist()) | changed})
    print(f'Probe: {len(changed)} current source members')
arena = (R / 'assets/validation_5826/away.wad').read_bytes()
pack(W / 'checks.pk3', {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs': (H / 'checks.zs').read_bytes(),
    'MAPINFO': b'GameInfo {AddEventHandlers="CA415RoundChecks"}\ncluster 8551 {hub}\nmap MAP01 "Absent combat" {cluster=8551}\nmap CABS415B "Away" {cluster=8551}\n',
    'maps/MAP01.wad': arena,
    'maps/CABS415B.wad': arena,
})
for case in ['math', 'rounds', 'physiology', 'potions', 'boundaries', 'breath']:
    (W / (case + '.cfg')).write_text(f'wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_{case}; wait 10; quit\n')
print('Prepared private fixtures')
(W/'machines.cfg').write_text('wait 105; netevent ca415r_machineprepare; wait 3; netevent ca415r_machines; wait 10; quit\n')
(W/'reserve.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_reserve; wait 3; netevent ca415r_reserveafter; wait 10; quit\n')

(W/'persistence.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_persistence; save round-current; wait 10; quit\n')
(W/'saved.cfg').write_text('wait 70; netevent ca415r_saved; wait 5; quit\n')

(W/'hub.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_persistence; netevent ca415r_away; wait 35; netevent ca415r_home; wait 35; netevent ca415r_hub; wait 5; quit\n')
(W/'resident.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_residentsetup; netevent ca415r_away; wait 35; netevent ca415r_home; wait 35; netevent ca415r_residenthome; wait 5; quit\n')
(W/'residentdeath.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_residentweak; netevent ca415r_away; wait 35; netevent ca415r_home; wait 35; netevent ca415r_residentdeath; wait 5; quit\n')
