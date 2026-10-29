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
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n#include "flights.zs"\n#include "calendar.zs"\n#include "work.zs"\n#include "arrival.zs"\n#include "quiet.zs"\n',
    'checks.zs': (H / 'checks.zs').read_bytes(),
    'flights.zs': (H / 'flights.zs').read_bytes(),
    'calendar.zs': (H / 'calendar.zs').read_bytes(),
    'work.zs': (H / 'work.zs').read_bytes(),
    'arrival.zs': (H / 'arrival.zs').read_bytes(),
    'quiet.zs': (H / 'quiet.zs').read_bytes(),
    'MAPINFO': b'GameInfo {AddEventHandlers="CA415RoundChecks","CA415FlightChecks","CA415CalendarChecks","CA415WorkChecks","CA415ArrivalHarness","CA415QuietChecks"}\ncluster 8551 {hub}\nmap MAP01 "Absent combat" {cluster=8551}\nmap MAP03 "Scheduled city" {cluster=8551}\nmap CABS415B "Away" {cluster=8551}\n',
    'maps/MAP01.wad': arena,
    'maps/CABS415B.wad': arena,
})
for case in ['math', 'rounds', 'physiology', 'potions', 'boundaries', 'breath']:
    (W / (case + '.cfg')).write_text(f'wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_{case}; wait 10; quit\n')
print('Prepared private fixtures')
(W/'calendar.cfg').write_text('wait 105; netevent ca415r_calendar; save calendar-started; wait 10; quit\n')
(W/'calendarload.cfg').write_text('wait 1; netevent ca415r_calendarload; wait 1; quit\n')
(W/'calendarhub.cfg').write_text('wait 105; netevent ca415r_calendardepart; wait 35; netevent ca415r_calendarreturn; wait 2; netevent ca415_await 5\n')
(W/'firstvisit.cfg').write_text('wait 105; netevent ca415r_firstvisit; wait 2; netevent ca415_await 7\n')
(W/'arrivalguards.cfg').write_text('wait 105; netevent ca415r_arrivalguards; wait 1; quit\n')
(W/'worksave.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_worksave; save work-partial; wait 10; quit\n')
(W/'workload.cfg').write_text('wait 1; netevent ca415r_workload; wait 10; quit\n')
(W/'arrivalsave.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_arrivalsave; save arrival-partial; wait 10; quit\n')
(W/'arrivalload.cfg').write_text('wait 1; netevent ca415_await 6\n')
(W/'flights.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_flights; wait 10; quit\n')
(W/'flightsave.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_flightsave; save flight-pending; wait 10; quit\n')
(W/'flightload.cfg').write_text('wait 1; netevent ca415r_flightload; wait 10; quit\n')
(W/'area.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_area; wait 10; quit\n')
(W/'spatial.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_spatial; wait 10; quit\n')
(W/'flighttravel.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_flighttravel; netevent ca415r_away; wait 35; netevent ca415r_home; wait 2; netevent ca415_await 4\n')
(W/'terminal.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_terminal; wait 10; quit\n')
(W/'sleep.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_sleep; wait 10; quit\n')
(W/'preparedsleep.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_preparedsleep; wait 10; quit\n')
(W/'restraint.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_restraint; wait 10; quit\n')
(W/'wake.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_wake; wait 10; quit\n')
(W/'wakesave.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_wakesave; save wake-pending; wait 10; quit\n')
(W/'wakeload.cfg').write_text('wait 1; netevent ca415r_wakeload; wait 10; quit\n')
(W/'machines.cfg').write_text('wait 105; netevent ca415r_machineprepare; wait 3; netevent ca415r_machines; wait 10; quit\n')
(W/'reserve.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_reserve; wait 3; netevent ca415r_reserveafter; wait 10; quit\n')

(W/'persistence.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_persistence; save round-current; wait 10; quit\n')
(W/'saved.cfg').write_text('wait 70; netevent ca415r_saved; wait 5; quit\n')

(W/'hub.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_persistence; netevent ca415r_away; wait 35; netevent ca415r_home; wait 2; netevent ca415_await 1\n')
(W/'resident.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_residentsetup; netevent ca415r_away; wait 35; netevent ca415r_home; wait 2; netevent ca415_await 2\n')
(W/'residentdeath.cfg').write_text('wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_residentweak; netevent ca415r_away; wait 35; netevent ca415r_home; wait 2; netevent ca415_await 3\n')

for case in ["quiet", "quietsave", "weather"]:
    suffix="save quiet-partial; " if case=="quietsave" else ""
    (W/(case+".cfg")).write_text(f"wait 105; netevent ca415r_prepare; wait 3; netevent ca415r_{case}; {suffix}wait 10; quit\n")
(W/"quietload.cfg").write_text("wait 1; netevent ca415r_quietload; wait 10; quit\n")
