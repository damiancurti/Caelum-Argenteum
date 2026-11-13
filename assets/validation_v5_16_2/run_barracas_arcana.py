"""Check quay essence placement, native Use/capture and saved-source migration.

Fixture victory and Box ownership isolate the map endpoint. The battle, menu
response selection, cooperative capture and author acceptance are not tested.
"""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'baseline', 'candidate', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--active-migration-only', action='store_true', help='Retain an active capture at the preceding misplaced source, then migrate after completion')
    args = parser.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    runtime, baseline, candidate = (getattr(args, n).resolve(strict=True) for n in ('runtime', 'baseline', 'candidate'))
    fixture = out / 'arcana-probe.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        for name, data in {'ZSCRIPT': 'version "4.14.2"\n' + Path(__file__).with_name('barracas_arcana_probe.zs').read_text(encoding='utf-8'),
                           'MAPINFO': 'gameinfo { AddEventHandlers="CA454ArcanaProbe" }\ndoomednums {31050=CA454ArcanaCity}\n'}.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), data)
    report = {'issue': 454, 'scope': __doc__.strip(), 'runtime_sha256': digest(runtime),
              'baseline_sha256': digest(baseline), 'candidate_sha256': digest(candidate),
              'fixture_sha256': digest(fixture), 'runs': []}
    plans = [('original', False, False, None), ('original-reload', False, False, 'original/midcapture.zds'),
             ('candidate', True, False, None), ('candidate-reload', True, False, 'candidate/midcapture.zds'),
             ('old-source', True, True, None), ('migrated-source', True, False, 'old-source/misplaced.zds')]
    if args.active_migration_only:
        plans = [('old-capture', True, True, None), ('migrated-capture', True, False, 'old-capture/midcapture.zds')]
    for name, overlay, old, seed in plans:
        folder = out / name; folder.mkdir()
        package = folder / 'caelum_argenteum_dev.pk3'; shutil.copyfile(baseline if old else runtime, package)
        (folder / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        finish = 'wait 70; netevent ca454_arcana_result; screenshot captured.png; wait 5; quit;\n'
        (folder / 'finish.cfg').write_text(finish)
        (folder / 'capture.cfg').write_text('netevent ca454_arcana_aim; wait 5; +use; wait 5; -use; netevent ca454_arcana_begin; wait 1; save midcapture; exec finish.cfg;\n')
        entry = ['+map', 'MAP03']
        if seed:
            shutil.copyfile(out / seed, folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
        if name == 'old-capture':
            (folder / 'capture.cfg').write_text('netevent ca454_arcana_aim; wait 5; +use; wait 5; -use; netevent ca454_arcana_begin; wait 1; save midcapture; wait 10; quit;\n')
            commands = 'wait 140; netevent ca454_arcana_prepare; wait 35; netevent ca454_arcana_seed; exec capture.cfg;\n'
        elif name == 'migrated-capture':
            commands = 'wait 1; netevent ca454_arcana_retained; exec finish.cfg;\n'
        elif old:
            commands = 'wait 140; netevent ca454_arcana_prepare; wait 35; netevent ca454_arcana_seed; save misplaced; wait 5; quit;\n'
        elif name.endswith('-reload'):
            commands = 'wait 10; exec finish.cfg;\n'
        else:
            commands = ('wait 140; netevent ca454_arcana_prepare; wait 35; netevent ca454_arcana_seed; ' if not seed else 'wait 35; ')
            commands += 'netevent ca454_arcana_aim; wait 5; +use; wait 5; -use; netevent ca454_arcana_begin; wait 1; netevent ca454_arcana_leave; wait 5; netevent ca454_arcana_interrupted; exec capture.cfg;\n'
        (folder / 'commands.cfg').write_text(commands)
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(package),
                   *([str(candidate)] if overlay else []), str(fixture), '-config', str(folder / 'isolated.ini'),
                   '-savedir', str(folder), '-window', '-width', '960', '-height', '720', '+logfile', str(folder / 'engine.log'),
                   *entry, '+exec', str(folder / 'commands.cfg')]
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
            try:
                code = process.wait(timeout=180)
            except subprocess.TimeoutExpired:
                process.terminate(); process.wait(timeout=10); code = process.returncode
        log = (folder / 'engine.log').read_text(errors='replace')
        errors = [line for line in log.splitlines() if any(s in line for s in ('Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown type', 'CA454 ARCANA FAIL'))]
        checkpoint = 'misplaced.zds' if name == 'old-source' else 'midcapture.zds' if name in ('original', 'candidate', 'old-capture') else None
        if checkpoint and not (folder / checkpoint).exists():
            errors.append('Missing required native checkpoint: ' + checkpoint)
        expected = 'CA454 ARCANA PASS capture response accepted' if name == 'old-capture' else 'CA454 ARCANA PASS native source appeared' if old else 'CA454 ARCANA COMPLETE failures=0'
        row = {'phase': name, 'passed': code == 0 and not errors and expected in log,
               'exit_code': code, 'errors': errors, 'checks': [line for line in log.splitlines() if line.startswith('CA454 ARCANA')]}
        if seed: row['seed_sha256'] = digest(out / seed)
        report['runs'].append(row)
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(row), flush=True)
        if not row['passed']: raise SystemExit(1)


if __name__ == '__main__':
    main()
