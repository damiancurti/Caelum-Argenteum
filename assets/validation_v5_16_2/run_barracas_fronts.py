"""Run production gate/machine deployment and reserve policy in isolation.

Suppress automatic battle-controller Tick. This checks object ownership,
counts, gate labels and persistent reserve activation, not crowd traversal,
capture transactions, firing coverage or full battle performance.
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
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--march', action='store_true', help='Run15 actual pedestrians at normal cadence on the complete southern approaches (up to30 minutes per phase)')
    parser.add_argument('--retreat', action='store_true', help='Test six terminal exits and36 elevated-route descents at normal cadence')
    parser.add_argument('--retreat-full', action='store_true', help='Test six complete city-to-south withdrawals at normal cadence')
    parser.add_argument('--crowd', action='store_true', help='Deploy all600 retained residents with real collision and native AI; isolate thermal survival')
    parser.add_argument('--commander', action='store_true', help='Test native wound-triggered commander escape from five origins')
    parser.add_argument('--capture', action='store_true', help='Test capture ownership and paired reserve activation without enemy crews')
    parser.add_argument('--refill', action='store_true', help='Run full native controller through1000-cap refill; thermal exposure isolated')
    parser.add_argument('--aftermath', action='store_true', help='Continue refill test through native objective destruction, wounded escape and surviving army withdrawal')
    parser.add_argument('--migration-only', action='store_true', help='Audit revised withdrawal state on a saved aftermath, without claiming army completion')
    parser.add_argument('--seed-save', type=Path, help='Resume one existing isolated checkpoint with the same package basenames')
    args = parser.parse_args()
    if args.migration_only and not (args.aftermath and args.seed_save):
        parser.error('--migration-only requires --aftermath and --seed-save')
    args.retreat = args.retreat or args.retreat_full
    args.refill = args.refill or args.aftermath
    if sum((args.march, args.retreat, args.crowd, args.commander, args.capture, args.refill)) > 1: parser.error('Select one navigation probe')
    movement = args.march or args.retreat or args.crowd or args.commander or args.capture or args.refill
    prefix = 'REFILL' if args.refill else 'CAPTURE' if args.capture else 'COMMANDER' if args.commander else 'CROWD' if args.crowd else 'RETREAT' if args.retreat else 'MARCH'
    event = prefix.lower()
    start_event = 'retreat_full' if args.retreat_full else event
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    runtime, candidate = args.runtime.resolve(), args.candidate.resolve()
    fixture = out / 'front-probe.pk3'
    probe = 'barracas_march_probe.zs' if args.march else 'barracas_front_probe.zs'
    handler, controller = ('CA454MarchProbe', 'CA454MarchCity') if args.march else ('CA454FrontProbe', 'CA454FrontCity')
    if args.retreat: probe, handler, controller = 'barracas_retreat_probe.zs', 'CA454RetreatProbe', 'CA454RetreatCity'
    if args.crowd: probe, handler, controller = 'barracas_crowd_probe.zs', 'CA454CrowdProbe', 'CA454CrowdCity'
    if args.commander: probe, handler, controller = 'barracas_commander_probe.zs', 'CA454CommanderProbe', 'CA454CommanderCity'
    if args.capture: probe, handler, controller = 'barracas_capture_probe.zs', 'CA454CaptureProbe', 'CA454CaptureCity'
    if args.refill: probe, handler, controller = 'barracas_refill_probe.zs', 'CA454RefillProbe', 'CA454RefillCity'
    with zipfile.ZipFile(fixture, 'w') as archive:
        source = (Path(__file__).parent / probe).read_text(encoding='utf-8')
        if args.aftermath: source = source.replace('const FINISH_BATTLE=0;', 'const FINISH_BATTLE=1;')
        files = {'ZSCRIPT': 'version "4.14.2"\n' + source,
                 'MAPINFO': f'gameinfo {{ AddEventHandlers="{handler}" }}\ndoomednums {{31050={controller}}}\n'}
        for name, data in files.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), data)
    report = {'issue': 454, 'scope': __doc__.strip(), 'runtime_sha256': digest(runtime),
              'candidate_sha256': digest(candidate), 'fixture_sha256': digest(fixture), 'runs': []}
    if args.march:
        report['scope'] = 'Three infantry and12 cannon operators traverse full southern approaches at native speed/cadence, with six static ram frames and six cannons. Gates are opened, player is notarget, no full battle/performance/author acceptance.'
    if args.retreat:
        report['scope'] = 'Six terminal exits and36 artillery-stair descents at normal native speed/cadence; no full-city withdrawal/crowds/performance/author acceptance.'
    if args.retreat_full:
        report['scope'] = 'Six complete withdrawals from three inner gate approaches and three residential road positions, native speed/collision, normal gate timers with victory passage requests, thermal exposure neutralized each fixture tick; no crowd/battle/FPS/survival/author acceptance.'
    if args.crowd:
        report['scope'] = 'All600 retained residents emitted by production house deployment,72 gun operators and528 guards, real collision/native AI and shared>=500 census. Automatic battle controller suppressed and thermal exposure neutralized each fixture tick. No attackers, firing, climate survival, full battle/FPS or author acceptance.'
    if args.commander:
        report['scope'] = 'Native wound-triggered commander escape from original southern spawn, three inner gates and house159 road, sequential identities, unchanged flee speed/collision. Fixture holds gates open and neutralizes thermal exposure. No combat, gate permissions, crowds, climate survival, FPS or author acceptance.'
    if args.capture:
        report['scope'] = 'Native capture of three active rams and one reserve; enemy reserve activation and captured reserve exclusion persist after reload. Empty enemy crews and fixture faction membership. No timed work, combat, refill or author acceptance.'
    if args.refill:
        report['scope'] = 'Full native city controller,600 defender records and1000 living attacker cap, finite6600 cumulative reserve, five fixture deaths through native Die followed by actual refill opportunities. Thermal exposure neutralized; no accelerated time or frozen combatants. Not full battle completion, FPS, climate survival or author acceptance.'
    if args.aftermath:
        report['scope'] += ' Then call native DestroyByTarot on12 objectives and wound the initialized commander at the accepted threshold. Require physical commander retreat, exactly one victory, stopped admissions and every surviving attacker physically exited. This simulates objective completion; it does not test winning the fight or card targeting/payment.'
    if args.migration_only:
        report['scope'] = 'Load a preceding-revision aftermath checkpoint, retain all saved actors and native withdrawal. After35 tics require every surviving withdrawing body to hold the current route revision; repeated initialization preserves its position, health and cached route. Save the migrated world. This checks continuation/idempotence, not completed army withdrawal.'
    fatal = ('Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown type')
    if args.seed_save: report['seed_save_sha256'] = digest(args.seed_save.resolve())
    for phase in (('reload',) if args.seed_save else ('fresh', 'reload')):
        folder = out / phase; folder.mkdir()
        package = folder / 'caelum_argenteum_dev.pk3'; shutil.copyfile(runtime, package)
        (folder / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        commands = 'wait 140; netevent ca454_front_start; wait 10; save checkpoint; ' if phase == 'fresh' else 'wait 10; netevent ca454_front_resume; '
        if movement:
            commands = f'wait 140; netevent ca454_{start_event}_start; wait 35; save checkpoint; ' if phase == 'fresh' else f'wait 1; netevent ca454_{event}_resume; '
            if args.migration_only:
                commands += 'wait 35; netevent ca454_refill_migration; save migrated; wait 35; '
            # Re-read a console file so a completed native probe exits normally.
            # No UI injection, simulation acceleration or guessed script API.
            (folder / 'poll.cfg').write_text('wait 35; exec poll.cfg\n')
            commands += 'exec poll.cfg; '
        else:
            commands += 'wait 10; quit; '
        (folder / 'commands.cfg').write_text(commands + '\n')
        entry = ['+map', 'MAP03']
        if phase == 'reload':
            shutil.copyfile(args.seed_save.resolve() if args.seed_save else out / 'fresh/checkpoint.zds', folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(package), str(candidate), str(fixture),
                   '-config', str(folder / 'isolated.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720',
                   '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
            deadline = time.monotonic() + (6000 if args.commander else 3000 if args.retreat_full or args.crowd or args.aftermath else 2100 if args.march else 900 if args.refill else 480 if args.retreat else 180); timeout = False
            try:
                while process.poll() is None:
                    path = folder / 'engine.log'
                    if path.exists():
                        current = path.read_text(errors='replace')
                        if any(s in current for s in fatal): break
                        if movement and (f'CA454 {prefix} COMPLETE' in current or f'CA454 {prefix} FAIL' in current):
                            (folder / 'poll.cfg').write_text('wait 10; quit\n')
                    if time.monotonic() > deadline: timeout = True; break
                    time.sleep(.25)
            finally:
                if process.poll() is None: process.terminate(); process.wait(timeout=10)
        log = (folder / 'engine.log').read_text(errors='replace')
        checks = [line for line in log.splitlines() if ('CA454 ' + prefix if movement else 'CA454 FRONT') in line or any(s in line for s in fatal)]
        required = ['DEPLOY PASS', 'POLICY PASS'] if phase == 'fresh' else ['RESUME PASS', 'CONTINUATION PASS']
        passed = process.returncode == 0 and not timeout and not any(s in log for s in fatal) and all('CA454 FRONT ' + s in log for s in required) and not any('FAIL' in line for line in checks)
        if movement:
            expected = 1 if args.refill else 4 if args.capture else 5 if args.commander else 600 if args.crowd else 6 if args.retreat_full else 42 if args.retreat else 15
            passed = process.returncode == 0 and not timeout and not any(s in log for s in fatal) and f'CA454 {prefix} COMPLETE passed={expected} failures=0' in log and not any('FAIL' in line for line in checks)
            if phase == 'reload': passed = passed and f'CA454 {prefix} RESUME PASS' in log
        report['runs'].append({'phase': phase, 'passed': passed, 'exit_code': process.returncode, 'timeout': timeout, 'checks': checks})
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(report['runs'][-1]), flush=True)
        if not passed: raise SystemExit(1)


if __name__ == '__main__':
    main()
