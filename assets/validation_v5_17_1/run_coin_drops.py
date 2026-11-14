"""Observe real inventory drops, native stacking and bidirectional save compatibility.

Fixtures invoke native pickup/toss on the explicitly selected inventory classes.
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


def main(default_kind='coins'):
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--baseline', type=Path, help='Previous runtime, required for automated compatibility checks.')
    parser.add_argument('--model', type=Path, help='Optional candidate preview.pk3 overlay.')
    parser.add_argument('--kind', choices=('coins', 'consumables', 'water', 'food', 'ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'), default=default_kind, help='Select the issue-specific native inventory fixture.')
    parser.add_argument('--interactive', action='store_true', help='Open the inspection room for author review; no automatic acceptance.')
    parser.add_argument('--visual-only', action='store_true', help='Inspect a changed art candidate in one fresh run; no save compatibility claim.')
    args = parser.parse_args()
    if not args.interactive and not args.visual_only and not args.baseline:
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
    if args.kind == 'coins':
        config = json.loads((ROOT / 'assets/source/art/inventory_models_647/COINS.json').read_text(encoding='utf-8'))
        classes = [item['class'] + suffix for item in config['variants'].values()
                   for suffix in config['denomination_suffixes']]
        source = Path(__file__).with_name('coin_drops.zs').read_text(encoding='utf-8')
        source = source.replace('COIN_CLASSES', ','.join("'%s'" % kind for kind in classes))
        event_class = 'CA647CoinEvents'
    else:
        config = json.loads((ROOT / 'assets/source/art/inventory_models_647' / args.kind / 'DESIGN.json').read_text(encoding='utf-8'))
        classes = [item['class'] for item in config['variants'].values()] + [item['class'] for item in config.get('reused_variants', [])]
        classes += [binding['class'] for item in config['variants'].values() for binding in item.get('additional_bindings', []) if binding.get('inventory')]
        fixture_name = {'headwear': 'headwear_drops.zs', 'ores': 'ore_drops.zs', 'gems': 'gem_drops.zs', 'books': 'book_drops.zs', 'jewelry': 'jewelry_drops.zs', 'locks': 'lock_drops.zs', 'mates': 'mate_drops.zs', 'waterskin': 'waterskin_drops.zs', 'furniture': 'furniture_drops.zs', 'camp': 'camp_drops.zs', 'water': 'water_drops.zs', 'food': 'food_drops.zs', 'ammunition': 'ammunition_drops.zs', 'documents': 'document_drops.zs', 'ingots': 'ingot_drops.zs', 'consumables': 'consumable_drops.zs'}[args.kind]
        fixture_path = (ROOT / 'assets/validation_v5_17_3' / fixture_name) if args.kind == 'ammunition' else Path(__file__).with_name(fixture_name)
        if args.kind == 'documents': fixture_path = ROOT / 'assets/validation_v5_17_6/document_drops.zs'
        if args.kind == 'ingots': fixture_path = ROOT / 'assets/validation_v5_17_7/ingot_drops.zs'
        if args.kind == 'camp': fixture_path = ROOT / 'assets/validation_v5_17_10/camp_drops.zs'
        if args.kind == 'furniture': fixture_path = ROOT / 'assets/validation_v5_17_11/furniture_drops.zs'
        if args.kind == 'waterskin': fixture_path = ROOT / 'assets/validation_v5_17_12/waterskin_drops.zs'
        if args.kind == 'mates': fixture_path = ROOT / 'assets/validation_v5_17_13/mate_drops.zs'
        if args.kind == 'headwear': fixture_path = ROOT / 'assets/validation_v5_17_21/headwear_drops.zs'
        if args.kind == 'ores': fixture_path = ROOT / 'assets/validation_v5_17_20/ore_drops.zs'
        if args.kind == 'gems': fixture_path = ROOT / 'assets/validation_v5_17_17/gem_drops.zs'
        if args.kind == 'books': fixture_path = ROOT / 'assets/validation_v5_17_16/book_drops.zs'
        if args.kind == 'jewelry': fixture_path = ROOT / 'assets/validation_v5_17_15/jewelry_drops.zs'
        if args.kind == 'locks': fixture_path = ROOT / 'assets/validation_v5_17_14/lock_drops.zs'
        source = fixture_path.read_text(encoding='utf-8')
        source = source.replace('ITEM_CLASSES', ','.join("'%s'" % kind for kind in classes))
        if args.kind in ('ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'):
            manifest = json.loads((ROOT / 'assets/source/art/inventory_models_647' / args.kind / 'EXPORT.json').read_text())
            records = list(manifest['variants'].values())
            records += [manifest['variants'][key] for key, item in config['variants'].items() for binding in item.get('additional_bindings', []) if binding.get('inventory')]
            bounds = [item['native_bounds'][0] for item in records]
            source = source.replace('DETAIL_EXTENTS', ','.join(str(max(b['max'][axis] - b['min'][axis] for axis in range(3))) for b in bounds))
            source = source.replace('DETAIL_HEIGHTS', ','.join(str((b['max'][2] + b['min'][2]) / 2) for b in bounds))
        if args.kind in ('gems','ores'): source = source.replace('ITEM_IDS', ','.join(str(item['item_type']) for item in config['variants'].values()))
        if args.kind == 'ingots': source = source.replace('ITEM_IDS', ','.join(str(item['material_id']) for item in config['variants'].values()))
        if args.kind == 'furniture':
            sys.path.insert(0, str(ROOT / 'assets/generators'))
            from generate_inventory_furniture_models import seat_transforms
            transforms = [value for item in config['variants'].values() if 'dining' in item for seat in seat_transforms(item['dining']) for value in seat]
            source = source.replace('DINING_TRANSFORMS', ','.join(str(value) for value in transforms))
        event_class = {'headwear': 'CA686HeadwearEvents', 'ores': 'CA684OreEvents', 'gems': 'CA678GemEvents', 'books': 'CA676BookEvents', 'jewelry': 'CA674JewelryEvents', 'locks': 'CA672LockEvents', 'mates': 'CA670MateEvents', 'waterskin': 'CA668WaterRationEvents', 'furniture': 'CA666FurnitureEvents', 'camp': 'CA664CampEvents', 'water': 'CA647WaterEvents', 'food': 'CA647FoodEvents', 'ammunition': 'CA652AmmoEvents', 'documents': 'CA656DocumentEvents', 'ingots': 'CA658IngotEvents', 'consumables': 'CA647ConsumableEvents'}[args.kind]
    marker = 'CA686' if args.kind == 'headwear' else 'CA684' if args.kind == 'ores' else 'CA678' if args.kind == 'gems' else 'CA676' if args.kind == 'books' else 'CA674' if args.kind == 'jewelry' else 'CA672' if args.kind == 'locks' else 'CA670' if args.kind == 'mates' else 'CA668' if args.kind == 'waterskin' else 'CA666' if args.kind == 'furniture' else 'CA664' if args.kind == 'camp' else 'CA658' if args.kind == 'ingots' else 'CA656' if args.kind == 'documents' else 'CA652' if args.kind == 'ammunition' else 'CA647'
    (out / 'fixture.zs').write_text(source, encoding='utf-8')
    fixture = out / 'fixture.pk3'
    with zipfile.ZipFile(fixture, 'w') as package:
        blobs = {'ZSCRIPT': ('version "4.14.2"\n' + source).encode(),
                 'maps/CA455V.wad': wad(),
                 'MAPINFO': ('gameinfo { AddEventHandlers="' + event_class + '" }\nmap CA455V "Inventory drop inspection" { sky1="CABASKY",0 nointermission }\n').encode()}
        for name, blob in blobs.items():
            package.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), blob)
    (out / 'session.ini').write_text(
        '[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\n'
        'i_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\n'
        'snd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    if args.kind in ('ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'):
        with (out / 'session.ini').open('a') as stream:
            stream.write('vid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n[LastRun]\nVersion=225\n')
    common = 'screenblocks 12; crosshair 0; con_notifytime 0; '
    fresh = common + 'wait 140; netevent ca647_prepare; wait 35; netevent ca647_verify; '
    if args.interactive:
        commands = fresh + ''.join(f'bind F{index + 1} "netevent ca647_view {index}"; ' for index in
                                   range(5 if args.kind == 'coins' else 9 if args.kind == 'food' else 8)) + '\n'
        if args.kind in ('ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'):
            commands += 'bind F9 "fov 30; netevent ca652_next"; bind F10 "fov 30; netevent ca652_rotate"; bind F5 "fov 90; netevent ca652_view 4";\n'
        cfg = out / 'interactive.cfg'
        cfg.write_text(commands.replace('ca647', marker.lower()).replace('ca652', marker.lower()))
        extras = [str(model)] if model else []
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), *extras,
                   str(fixture), '-config', str(out / 'session.ini'), '-savedir', str(out), '-window',
                   '+logfile', str(out / 'interactive.log'), '+map', 'CA455V', '+exec', str(cfg)]
        print('F1 top / F2 low / F3 side / F4 close / F5 player control. F6/F7 additional close views / F8 rear for non-coin fixtures. Food: F9 table. Close the game after review; no automatic acceptance.', flush=True)
        if args.kind in ('ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'):
            print('F9 next item close-up; F10 rotate close-up; F5 restores ordinary field of view.', flush=True)
        subprocess.run(command, cwd=out, check=True)
        return
    load = common + 'wait 35; netevent ca647_verify; '
    views = ''.join(f'netevent ca647_view {index}; wait 20; screenshot candidate-{index}.png; wait 5; ' for index in
                    (range(4) if args.kind == 'coins' else (0, 1, 2, 3, 5, 6, 7)))
    if args.kind == 'food':
        views += 'netevent ca647_view 8; wait 20; screenshot candidate-8.png; wait 5; '
    if args.kind in ('ammunition', 'documents', 'ingots', 'camp', 'furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'gems', 'ores', 'headwear'):
        views += 'fov 30; ' + ''.join(f'netevent ca652_detail {index} {angle}; wait 20; screenshot detail-{index}-{angle}.png; wait 5; '
                                     for index in range(len(classes)) for angle in (((90, 160, 270) if index in (0, 4, 8, 13) else (90,)) if args.kind == 'gems' else (0, 90, 160, 270) if args.kind in ('furniture', 'waterskin', 'mates', 'locks', 'jewelry', 'books', 'headwear') else (90, 160, 270))) + 'netevent ca652_next; wait 5; netevent ca652_rotate; wait 5; fov 90; '
    runs = [
        ('baseline', baseline, False, ['+map', 'CA455V'], fresh + 'screenshot baseline.png; wait 5; save coin-old; wait 20; quit\n'),
        ('old-save-load', runtime, True, ['-loadgame', 'coin-old.zds'], load + views + 'netevent ca647_pickup; wait 20; quit\n'),
        ('candidate-fresh', runtime, True, ['+map', 'CA455V'], fresh + 'save coin-new; wait 20; quit\n'),
        ('candidate-reload', runtime, True, ['-loadgame', 'coin-new.zds'], load + 'netevent ca647_pickup; wait 20; quit\n'),
        ('rollback-load', baseline, False, ['-loadgame', 'coin-new.zds'], load + 'netevent ca647_pickup; wait 20; quit\n'),
    ]
    if args.visual_only:
        runs = [('visual', runtime, True, ['+map', 'CA455V'], fresh + views + 'wait 20; quit\n')]
    report = {'issue': 686 if args.kind == 'headwear' else 684 if args.kind == 'ores' else 678 if args.kind == 'gems' else 676 if args.kind == 'books' else 674 if args.kind == 'jewelry' else 672 if args.kind == 'locks' else 670 if args.kind == 'mates' else 668 if args.kind == 'waterskin' else 666 if args.kind == 'furniture' else 664 if args.kind == 'camp' else 658 if args.kind == 'ingots' else 656 if args.kind == 'documents' else 652 if args.kind == 'ammunition' else 647, 'kind': args.kind, 'scope': 'Native pickup/toss, quantity and saved ownership for ' + args.kind + '; no normal menu or author acceptance.', 'baseline_sha256': digest(baseline),
              'runtime_sha256': digest(runtime), 'model_sha256': digest(model) if model else None,
              'fixture_sha256': digest(fixture), 'engine_sha256': digest(ENGINE), 'runs': []}
    for label, package, candidate, entry, commands in runs:
        cfg = out / (label + '.cfg')
        if args.kind in ('waterskin', 'mates'): commands = commands.replace('netevent ca647_pickup; wait 20; quit','netevent ca647_pickup; wait 40; netevent ca647_effect; wait 5; quit')
        commands = commands.replace('ca647', marker.lower()).replace('ca652', marker.lower())
        if args.kind in ('furniture','jewelry','books','gems','ores','headwear') and len(commands) > 1800:
            # Keep every request in bounded, explicitly chained files.
            chunks=['']
            for command in commands.split(';'):
                if len(chunks[-1])+len(command)>1500: chunks.append('')
                chunks[-1]+=command.strip()+'; '
            paths=[cfg]+[out/f'{label}-part-{i}.cfg' for i in range(1,len(chunks))]
            for i,(path,chunk) in enumerate(zip(paths,chunks)):
                tail=f'exec "{paths[i+1].as_posix()}";' if i+1<len(paths) else ''
                path.write_text(chunk+tail+'\n')
        else:
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
                   'Unknown command', 'Unable to load model', marker + ' FAIL'))]
        passed = code == 0 and not errors and marker + ' COMPLETE failures=0' in log
        assertions = sum(line.startswith(marker + ' PASS') for line in log.splitlines())
        if args.kind == 'gems':
            expected = 1093 if label in ('baseline', 'candidate-fresh', 'visual') else 1219
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'books':
            expected = 160 if label in ('baseline', 'candidate-fresh', 'visual') else 131
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'jewelry':
            expected = 715 if label in ('baseline', 'candidate-fresh', 'visual') else 632
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'locks':
            expected = 349 if label in ('baseline', 'candidate-fresh', 'visual') else 316
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'mates':
            expected = 133 if label in ('baseline', 'candidate-fresh', 'visual') else 117
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'waterskin':
            expected = 47 if label in ('baseline', 'candidate-fresh', 'visual') else 42
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'furniture':
            expected = 743 if label in ('baseline', 'candidate-fresh', 'visual') else 478
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'documents':
            expected = 89 if label in ('baseline', 'candidate-fresh', 'visual') else 98
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'camp':
            expected = 110 if label in ('baseline', 'candidate-fresh', 'visual') else 76
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'headwear':
            expected = 476 if label in ('baseline', 'candidate-fresh', 'visual') else 502
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}');passed=False
        if args.kind == 'ores':
            expected = 175
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        if args.kind == 'ingots':
            expected = 547 if label in ('baseline', 'candidate-fresh', 'visual') else 610
            if assertions != expected:
                errors.append(f'Expected {expected} native assertions, observed {assertions}')
                passed = False
        report['runs'].append({'phase': label, 'exit_code': code, 'passed': passed, 'errors': errors,
                               'assertions': assertions})
        report['captures'] = {path.name: digest(path) for path in sorted(out.glob('*.png'))}
        (out / 'RESULTS.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report['runs'][-1]), flush=True)
        if not passed:
            raise SystemExit(1)


if __name__ == '__main__':
    main()
