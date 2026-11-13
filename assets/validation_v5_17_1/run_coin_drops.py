"""Observe real coin drops, native stacking and bidirectional save compatibility.

The fixture invokes native pickup/toss methods on all 15 actual denominations.
It does not exercise ordinary menu selection or confer author acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad

ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--baseline', type=Path, help='Previous runtime, required for automated compatibility checks.')
    parser.add_argument('--model', type=Path, help='Optional candidate preview.pk3 overlay.')
    parser.add_argument('--interactive', action='store_true', help='Open the inspection room for author review; no automatic acceptance.')
    args = parser.parse_args()
    if not args.interactive and not args.baseline:
        parser.error('--baseline is required for automated compatibility checks.')
    runtime = args.runtime.resolve(strict=True)
    baseline = args.baseline.resolve(strict=True) if args.baseline else runtime
    model = args.model.resolve(strict=True) if args.model else None
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH'])
    if b'"gzdoom.exe"' in active.lower():
        parser.error('Another native engine is running.')
    out = args.output.resolve()
    out.relative_to(ROOT / 'build')
    out.mkdir(parents=True, exist_ok=False)
    config = json.loads((ROOT / 'assets/source/art/inventory_models_647/COINS.json').read_text(encoding='utf-8'))
    classes = [item['class'] + suffix for item in config['variants'].values()
               for suffix in config['denomination_suffixes']]
    source = Path(__file__).with_name('coin_drops.zs').read_text(encoding='utf-8')
    source = source.replace('COIN_CLASSES', ','.join("'%s'" % kind for kind in classes))
    (out / 'fixture.zs').write_text(source, encoding='utf-8')
    fixture = out / 'fixture.pk3'
    with zipfile.ZipFile(fixture, 'w') as package:
        blobs = {'ZSCRIPT': ('version "4.14.2"\n' + source).encode(),
                 'maps/CA455V.wad': wad(),
                 'MAPINFO': b'gameinfo { AddEventHandlers="CA647CoinEvents" }\nmap CA455V "Coin drop inspection" { sky1="CABASKY",0 nointermission }\n'}
        for name, blob in blobs.items():
            package.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), blob)
    (out / 'session.ini').write_text(
        '[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\n'
        'i_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\n'
        'snd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    common = 'screenblocks 12; crosshair 0; con_notifytime 0; '
    fresh = common + 'wait 140; netevent ca647_prepare; wait 35; netevent ca647_verify; '
    if args.interactive:
        commands = fresh + ''.join(f'bind F{index + 1} "netevent ca647_view {index}"; ' for index in range(5)) + '\n'
        cfg = out / 'interactive.cfg'
        cfg.write_text(commands)
        extras = [str(model)] if model else []
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), *extras,
                   str(fixture), '-config', str(out / 'session.ini'), '-savedir', str(out), '-window',
                   '+logfile', str(out / 'interactive.log'), '+map', 'CA455V', '+exec', str(cfg)]
        print('F1 top / F2 low / F3 side / F4 close / F5 player control. Close the game after review; no automatic acceptance.', flush=True)
        subprocess.run(command, cwd=out, check=True)
        return
    load = common + 'wait 35; netevent ca647_verify; '
    views = ''.join(f'netevent ca647_view {index}; wait 20; screenshot candidate-{index}.png; wait 5; ' for index in range(4))
    runs = [
        ('baseline', baseline, False, ['+map', 'CA455V'], fresh + 'screenshot baseline.png; wait 5; save coin-old; wait 20; quit\n'),
        ('old-save-load', runtime, True, ['-loadgame', 'coin-old.zds'], load + views + 'netevent ca647_pickup; wait 20; quit\n'),
        ('candidate-fresh', runtime, True, ['+map', 'CA455V'], fresh + 'save coin-new; wait 20; quit\n'),
        ('candidate-reload', runtime, True, ['-loadgame', 'coin-new.zds'], load + 'netevent ca647_pickup; wait 20; quit\n'),
        ('rollback-load', baseline, False, ['-loadgame', 'coin-new.zds'], load + 'netevent ca647_pickup; wait 20; quit\n'),
    ]
    report = {'issue': 647, 'scope': __doc__.strip(), 'baseline_sha256': digest(baseline),
              'runtime_sha256': digest(runtime), 'model_sha256': digest(model) if model else None,
              'fixture_sha256': digest(fixture), 'engine_sha256': digest(ENGINE), 'runs': []}
    for label, package, candidate, entry, commands in runs:
        cfg = out / (label + '.cfg')
        cfg.write_text(commands)
        extras = [str(model)] if model and candidate else []
        command = [str(ENGINE), '-noautoload', '-nomouse', '-iwad', str(IWAD), '-file', str(package), *extras,
                   str(fixture), '-config', str(out / 'session.ini'), '-savedir', str(out), '-window',
                   '-width', '1280', '-height', '720', '+logfile', str(out / (label + '.log')),
                   *entry, '+exec', str(cfg)]
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 0
        with (out / (label + '-process.log')).open('wb') as stream:
            process = subprocess.Popen(command, cwd=out, stdout=stream, stderr=stream, startupinfo=startup)
            deadline = time.monotonic() + 120
            while process.poll() is None and time.monotonic() < deadline:
                log_path = out / (label + '.log')
                text = log_path.read_text(errors='replace') if log_path.exists() else ''
                if any(token in text for token in ('Script error', 'Execution could not continue', 'VM execution aborted')):
                    break
                time.sleep(.2)
            if process.poll() is None:
                process.terminate()
            code = process.wait(timeout=10)
        log_path = out / (label + '.log')
        log = log_path.read_text(errors='replace') if log_path.exists() else ''
        errors = [line for line in log.splitlines() if any(token in line for token in
                  ('Script error', 'Execution could not continue', 'VM execution aborted',
                   'Unknown command', 'Unable to load model', 'CA647 FAIL'))]
        passed = code == 0 and not errors and 'CA647 COMPLETE failures=0' in log
        report['runs'].append({'phase': label, 'exit_code': code, 'passed': passed, 'errors': errors,
                               'assertions': sum(line.startswith('CA647 PASS') for line in log.splitlines())})
        report['captures'] = {path.name: digest(path) for path in sorted(out.glob('*.png'))}
        (out / 'RESULTS.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report['runs'][-1]), flush=True)
        if not passed:
            raise SystemExit(1)


if __name__ == '__main__':
    main()
