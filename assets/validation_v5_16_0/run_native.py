"""Check #452 diagnostic release labels in the unchanged sewer and a new save.

Uses disposable profiles and an additive probe only. This is not an ordinary
campaign walkthrough, a historical-save migration test or V5.16 acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    runtime = args.runtime.resolve()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    fixture = out / 'probe.pk3'
    with zipfile.ZipFile(fixture, 'w', compression=zipfile.ZIP_STORED) as archive:
        for name, data in sorted({
            'ZSCRIPT': b'version "4.14.2"\n#include "probe.zs"\n',
            'MAPINFO': b'gameinfo { AddEventHandlers="CA452Probe" }\n',
            'probe.zs': (HERE / 'native_probe.zs').read_bytes(),
        }.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 12, 0, 0, 0)), data)
    summary = {'issue': 452, 'runtime_sha256': digest(runtime), 'engine_sha256': digest(ENGINE),
               'fixture_sha256': digest(fixture), 'scope': __doc__.strip(), 'runs': []}
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    fatal = ('Script error', 'Execution could not continue', 'VM execution aborted',
             'compile errors', 'DIED WITH FATAL ERROR', 'CA452 NATIVE FAIL')
    for phase in ('fresh', 'reload'):
        folder = out / phase
        folder.mkdir()
        config = folder / 'isolated.ini'
        config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\n'
            'vid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\n'
            'i_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n', encoding='utf-8')
        commands = folder / 'commands.cfg'
        commands.write_text('wait 140; netevent ca452_probe; wait 5; save checkpoint; '
                            'wait 10; screenshot scene.png; wait 10; quit\n', encoding='utf-8')
        entry = ['+map', 'MAP02']
        if phase == 'reload':
            (folder / 'checkpoint.zds').write_bytes((out / 'fresh/checkpoint.zds').read_bytes())
            entry = ['-loadgame', 'checkpoint.zds']
        command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), str(fixture),
                   '-config', str(config), '-savedir', str(folder), '-window', '-width', '960', '-height', '720',
                   '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(commands)]
        print(f'#452 native {phase}: {folder}', flush=True)
        timed_out = False
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, startupinfo=startup, stdout=stream, stderr=stream)
            try:
                deadline = time.monotonic() + 120
                while process.poll() is None:
                    log = folder / 'engine.log'
                    if log.exists() and any(word in log.read_text(errors='replace') for word in fatal):
                        break
                    if time.monotonic() >= deadline:
                        timed_out = True
                        break
                    time.sleep(.25)
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=10)
        text = (folder / 'engine.log').read_text(errors='replace') if (folder / 'engine.log').exists() else ''
        errors = [word for word in fatal if word in text]
        passed = (not timed_out and not errors and process.returncode == 0
                  and 'CA452 NATIVE PASS map=MAP02' in text and text.count('[Caelum 5.16.0]') == 2
                  and (folder / 'checkpoint.zds').is_file())
        summary['runs'].append({'phase': phase, 'passed': passed, 'timed_out': timed_out,
                                'errors': errors, 'exit_code': process.returncode, 'command': command})
        (out / 'results.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
        print(f'#452 {phase}: {"PASS" if passed else "FAIL"}', flush=True)
        if not passed:
            raise SystemExit(1)


if __name__ == '__main__':
    main()
