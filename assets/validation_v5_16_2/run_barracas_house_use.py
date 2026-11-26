"""Exercise house Used/rendered capture/ACK round trips in four orientations.

Place the user at each door to isolate interaction. Keep native collision,
camera capture, renderer ACK, map travel and return coordinates. No walking to
the door, property purchase, siege, multiplayer or author acceptance claim.
"""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import time
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'candidate', 'output'):
        parser.add_argument('--' + name, type=Path, required=name != 'candidate')
    parser.add_argument('--shops', action='store_true', help='Instead exercise native Use at64 shops and one finite-stock purchase')
    parser.add_argument('--stations', action='store_true', help='Instead exercise native Use and existing crafting networks at96 factory stations')
    parser.add_argument('--vehicles', action='store_true', help='Instead exercise native Use at four parked vehicle boarding points')
    args = parser.parse_args()
    if sum((args.shops, args.stations, args.vehicles)) > 1: parser.error('Select one interaction suite')
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    runtime, candidate = args.runtime.resolve(), args.candidate.resolve() if args.candidate else None
    fixture = out / 'house-use.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        name = 'vehicle' if args.vehicles else 'station' if args.stations else 'shop' if args.shops else 'house'
        kind = name.title()
        extra = ''
        if args.stations:
            from run_barracas_candidate import factory_data
            extra = factory_data().decode('utf-8') + '\n'
        files = {'ZSCRIPT': 'version "4.14.2"\n' + extra + (Path(__file__).parent / f'barracas_{name}_use_probe.zs').read_text(encoding='utf-8'),
                 'MAPINFO': f'gameinfo {{ AddEventHandlers="CA454{kind}UseProbe" }}\ndoomednums {{31050=CA454{kind}UseCity}}\n'}
        for name, value in files.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), value)
    report = {'issue': 454, 'scope': __doc__.strip(), 'runtime_sha256': digest(runtime),
              'candidate_sha256': digest(candidate) if candidate else None, 'fixture_sha256': digest(fixture), 'runs': []}
    if args.shops:
        report['scope'] = 'Native +use input at64 retained merchants and one actual finite-stock purchase; fixture places user and provides Box/currency. Native price, stock and wallet transfer retained. No walking, full catalogue, siege, multiplayer or author acceptance.'
    if args.stations:
        report['scope'] = 'Native +use input at96 retained factory stations with existing connected crafting networks. Fixture places user at a clear reachable side and provides persistent Box ownership. No crafting recipe completion, siege, multiplayer or author acceptance.'
    if args.vehicles:
        report['scope'] = 'Native +use input at four parked vehicles and their reachable physical boarding parts; validates source-specific transport sessions. Fixture places user. No ticket purchase, actual journey, siege, multiplayer or author acceptance.'
    fatal = ('Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown type')
    for phase in ('fresh', 'reload'):
        folder = out / phase; folder.mkdir()
        package = folder / 'caelum_argenteum_dev.pk3'; shutil.copyfile(runtime, package)
        (folder / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        commands = 'wait 140; save checkpoint; wait 10; ' if phase == 'fresh' else 'wait 35; '
        if args.shops or args.stations or args.vehicles:
            count = 4 if args.vehicles else 96 if args.stations else 64
            event = 'vehicle' if args.vehicles else 'station' if args.stations else 'shop'
            for identity in range(count):
                # Keep each console execution bounded; long single-line scripts
                # can overrun GZDoom's pending command buffer and reorder events.
                tail = f'exec shop-{identity+1}.cfg' if identity < count-1 else f'netevent ca454_{event}_report; screenshot {event}-final.png; wait 10; quit'
                (folder / f'shop-{identity}.cfg').write_text(f'netevent ca454_{event}_aim {identity}; wait 10; +use; wait 10; netevent ca454_{event}_check {identity}; -use; wait 10; {tail};\n')
            commands += 'exec shop-0.cfg;\n'
        else:
            for orientation in range(4):
                commands += f'netevent ca454_house_in {orientation}; wait 140; netevent ca454_house_inside {orientation}; wait 140; netevent ca454_house_back {orientation}; wait 35; '
            commands += 'screenshot house-return.png; wait 10; quit;\n'
        (folder / 'commands.cfg').write_text(commands)
        entry = ['+map', 'MAP03']
        if phase == 'reload':
            shutil.copyfile(out / 'fresh/checkpoint.zds', folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(package), *([str(candidate)] if candidate else []), str(fixture),
                   '-config', str(folder / 'isolated.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720',
                   '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
            deadline = time.monotonic() + 240; timeout = False
            while process.poll() is None:
                log = (folder / 'engine.log').read_text(errors='replace') if (folder / 'engine.log').exists() else ''
                if any(value in log for value in fatal): break
                if time.monotonic() > deadline: timeout = True; break
                time.sleep(.25)
            if process.poll() is None: process.terminate(); process.wait(timeout=10)
        log = (folder / 'engine.log').read_text(errors='replace')
        prefix = 'CA454 VEHICLE' if args.vehicles else 'CA454 STATION' if args.stations else 'CA454 SHOP' if args.shops else 'CA454 HOUSE'
        checks = [line for line in log.splitlines() if prefix in line or any(value in line for value in fatal)]
        passed = process.returncode == 0 and not timeout and not any('FAIL' in line or any(value in line for value in fatal) for line in checks)
        if args.vehicles:
            passed = passed and 'CA454 VEHICLE COMPLETE PASS opened=4 failures=0' in log
        elif args.stations:
            passed = passed and 'CA454 STATION COMPLETE PASS opened=96 failures=0' in log
        elif args.shops:
            passed = passed and 'CA454 SHOP COMPLETE PASS opened=64 bought=1 failures=0' in log
        else:
            passed = passed and sum('USE PASS' in line for line in checks) == 8 and sum('RETURN PASS' in line for line in checks) == 4
        report['runs'].append({'phase': phase, 'passed': passed, 'exit_code': process.returncode, 'timeout': timeout, 'checks': checks})
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(report['runs'][-1]), flush=True)
        if not passed: raise SystemExit(1)


if __name__ == '__main__':
    main()
