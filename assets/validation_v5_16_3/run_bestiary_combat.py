"""Compare all approved provisional actors with the live Mandinga template.

Reuse the owned visual-pilot room, without a model overlay or campaign placement.
Passive AI isolates profile/state/inventory equivalence; actual action execution
and campaign population/visual acceptance require separate evidence.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import zipfile
from run_nahuelito_preview import wad

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--actions', action='store_true', help='Execute melee/projectile/breath for one representative of each taxonomy plus a Mandinga control')
    mode.add_argument('--loot', action='store_true', help='Check finite native death drops and their guard after reload')
    args = parser.parse_args(); runtime = args.runtime.resolve(strict=True)
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    fixture = out / 'profile-probe.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        for name, data in {'maps/CA455V.wad': wad(), 'ZSCRIPT': b'version "4.14.2"\n' + Path(__file__).with_name('bestiary_combat_probe.zs').read_bytes(),
                           'MAPINFO': b'gameinfo { AddEventHandlers="CA455CombatProbe" }\nmap CA455V "Folklore profile diagnostic" { sky1="CABASKY",0 nointermission }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), data)
    report = {'issue': 455, 'scope': __doc__.strip(), 'runtime_sha256': digest(runtime), 'fixture_sha256': digest(fixture), 'engine_sha256': digest(ENGINE), 'runs': []}
    for phase in (('actions',) if args.actions else ('fresh', 'reload')):
        folder = out / phase; folder.mkdir()
        (folder / 'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_maxfps=60\n')
        commands = 'wait 70; netevent ca455_prepare; wait 70; netevent ca455_audit; netevent ca455_deplete; wait 5; save checkpoint; wait 10; quit\n' if phase == 'fresh' else 'wait 35; netevent ca455_audit; wait 5; quit\n'
        if args.actions:
            commands = 'wait 70; netevent ca455_prepare; wait 70; netevent ca455_audit; '
            commands += ''.join(f'netevent ca455_action {index} {mode}; wait 147; ' for index in (-1,0,2,5,26,42) for mode in range(3))
            commands += 'netevent ca455_action_result; wait 10; quit\n'
        if args.loot:
            commands = 'wait 70; netevent ca455_prepare; wait 70; netevent ca455_audit; netevent ca455_loot; wait 5; netevent ca455_audit_loot; wait 5; netevent ca455_audit_loot; save checkpoint; wait 10; quit\n' if phase == 'fresh' else 'wait 35; netevent ca455_audit_loot; wait 5; netevent ca455_audit_loot; wait 5; quit\n'
        (folder / 'commands.cfg').write_text(commands)
        entry = ['+map', 'CA455V']
        if phase == 'reload':
            shutil.copyfile(out / 'fresh/checkpoint.zds', folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), str(fixture), '-config', str(folder / 'session.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720', '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
            try: code = process.wait(timeout=180)
            except subprocess.TimeoutExpired: process.terminate(); process.wait(timeout=10); raise
        log = (folder / 'engine.log').read_text(encoding='utf-8', errors='replace')
        errors = [line for line in log.splitlines() if any(s in line for s in ['Script error', 'Execution could not continue', 'VM execution aborted', 'CA455 COMBAT FAIL', 'CA455 ACTION FAIL', 'CA455 ACTIONS FAIL', 'CA455 LOOT FAIL'])]
        result = {'phase': phase, 'command': command, 'exit_code': code, 'errors': errors,
                  'passed': code == 0 and not errors and ('CA455 LOOT PASS' if args.loot else 'CA455 COMBAT PASS') in log and (not args.actions or 'CA455 ACTIONS PASS' in log) and (phase != 'fresh' or (folder / 'checkpoint.zds').exists()),
                  'checks': [line for line in log.splitlines() if any(s in line for s in ('CA455 COMBAT', 'CA455 ACTION', 'CA455 LOOT'))]}
        report['runs'].append(result); (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps({key: result[key] for key in ('phase', 'exit_code', 'passed', 'errors')}), flush=True)
        if not result['passed']: raise SystemExit(1)


if __name__ == '__main__':
    main()
