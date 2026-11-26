"""Check the appended Barracas Justice arena, active save and native return."""
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
    args = parser.parse_args(); out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    runtime, candidate = args.runtime.resolve(), args.candidate.resolve() if args.candidate else None
    fixture = out / 'justice-probe.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        for name, value in {'ZSCRIPT': 'version "4.14.2"\n' + Path(__file__).with_name('barracas_justice_probe.zs').read_text(encoding='utf-8'),
                            'MAPINFO': 'gameinfo { AddEventHandlers="CA454JusticeProbe" }\ndoomednums {31050=CA454JusticeCity}\n'}.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), value)
    report = {'issue': 454, 'scope': __doc__, 'runtime_sha256': digest(runtime), 'candidate_sha256': digest(candidate) if candidate else None,
              'fixture_sha256': digest(fixture), 'runs': []}
    fatal = ('Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown type')
    for phase in ('fresh', 'reload'):
        folder = out / phase; folder.mkdir(); package = folder / 'caelum_argenteum_dev.pk3'; shutil.copyfile(runtime, package)
        (folder / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        commands = 'wait 140; netevent ca454_justice_start; wait 35; save checkpoint; ' if phase == 'fresh' else 'wait 5; netevent ca454_justice_resume; '
        (folder / 'commands.cfg').write_text(commands + 'wait 10; netevent ca454_justice_expire; wait 35; quit\n')
        entry = ['+map', 'MAP03']
        if phase == 'reload':
            shutil.copyfile(out / 'fresh/checkpoint.zds', folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(package), *([str(candidate)] if candidate else []), str(fixture),
                   '-config', str(folder / 'isolated.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720',
                   '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
            deadline = time.monotonic() + 180; timeout = False
            try:
                while process.poll() is None:
                    path = folder / 'engine.log'
                    if path.exists() and any(s in path.read_text(errors='replace') for s in fatal): break
                    if time.monotonic() > deadline: timeout = True; break
                    time.sleep(.25)
            finally:
                if process.poll() is None: process.terminate(); process.wait(timeout=10)
        log = (folder / 'engine.log').read_text(errors='replace')
        checks = [line for line in log.splitlines() if 'CA454 JUSTICE' in line or any(s in line for s in fatal)]
        passed = process.returncode == 0 and not timeout and not any(s in log for s in fatal) and not any('FAIL' in s for s in checks)
        passed = passed and any('COMPLETE' in s and 'failures=0' in s for s in checks)
        if phase == 'reload': passed = passed and 'CA454 JUSTICE RESUME failures=0' in log
        result = {'phase': phase, 'passed': passed, 'exit_code': process.returncode, 'timeout': timeout, 'checks': checks}
        report['runs'].append(result); (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(result), flush=True)
        if not passed: raise SystemExit(1)


if __name__ == '__main__':
    main()
