"""Exercise the actual final-review fixture through wrapping views and house return.

This hidden isolated engine check does not open an author review or accept style.
Native menu interaction remains an author check; source inspection verifies that
the capture-only automatic menu dismissal is removed from the review fixture.
"""
from pathlib import Path
import argparse, json, subprocess, sys, time, zipfile

ROOT = Path(__file__).resolve().parents[2]
FATAL = ['Script error', 'Execution could not continue', 'VM execution aborted', 'CA866 FAIL', 'CA454 HOUSE FAIL', 'CA454 HOUSE USE FAIL', 'CA454 HOUSE RETURN FAIL']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime', 'overlay-directory', 'output']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH'], text=True, errors='replace')
    assert 'gzdoom.exe' not in active.lower()
    out = args.output.resolve(); out.relative_to(ROOT / 'build')
    out.mkdir(parents=True, exist_ok=False)
    runs = []
    for scene in ['house', 'sewer']:
        folder = out / scene
        subprocess.run([sys.executable, str(Path(__file__).with_name('run_review.py')), '--runtime', str(args.runtime.resolve()), '--overlay-directory', str(args.overlay_directory.resolve()), '--scene', scene, '--variant', 'vaults', '--output', str(folder), '--prepare-only'], cwd=ROOT, check=True)
        session = json.loads((folder / 'review-session.json').read_text(encoding='utf-8'))
        with zipfile.ZipFile(folder / 'review.pk3') as archive:
            source = archive.read('probe.zs').decode('utf-8')
        assert 'override void UiTick()' not in source and '.Close()' not in source
        (folder / 'probe.zs').write_text(source, encoding='utf-8', newline='\n')
        cfg = folder / 'start.cfg'
        commands = [cfg.read_text(encoding='utf-8').strip()]
        commands += ['wait 5; netevent ca866_next'] * (len(session['cameras']) + 1)
        if scene == 'house':
            commands += ['wait 5', 'netevent ca454_house_inside 0', 'wait 140', 'netevent ca454_house_back 0']
        commands += ['save checkpoint', 'wait 10', 'echo CA881_REVIEW_SMOKE_COMPLETE', 'quit']
        cfg.write_text('; '.join(commands) + '\n', encoding='utf-8', newline='\n')
        command = [*session['command'], '-nomouse', '-rngseed', '428']
        startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
        timed_out = False
        with (folder / 'process.log').open('wb') as stream:
            process = subprocess.Popen(command, cwd=folder, startupinfo=startup, stdout=stream, stderr=stream)
            deadline = time.monotonic() + 180
            while process.poll() is None:
                log = folder / 'engine.log'
                text = log.read_text(encoding='utf-8', errors='replace') if log.exists() else ''
                if any(marker in text for marker in FATAL):
                    break
                if time.monotonic() > deadline:
                    timed_out = True; break
                time.sleep(.25)
            if process.poll() is None:
                process.terminate(); process.wait(timeout=10)
        text = (folder / 'engine.log').read_text(encoding='utf-8', errors='replace')
        errors = [marker for marker in FATAL if marker in text]
        views = text.count('CA866 VIEW ')
        row = dict(scene=scene, command=command, exit_code=process.returncode, timed_out=timed_out, errors=errors,
                   views=views, first_view_samples=text.count('CA866 VIEW 0 '),
                   real_house_uses=text.count('CA454 HOUSE USE PASS'), exact_house_returns=text.count('CA454 HOUSE RETURN PASS'),
                   checkpoint_exists=(folder / 'checkpoint.zds').is_file(), capture_menu_dismissal_removed=True)
        row['passed'] = (process.returncode == 0 and not timed_out and not errors and row['checkpoint_exists']
                         and 'CA881_REVIEW_SMOKE_COMPLETE' in text and views == len(session['cameras']) + 2
                         and row['first_view_samples'] == 2
                         and (scene != 'house' or (row['real_house_uses'] == 2 and row['exact_house_returns'] == 1)))
        runs.append(row)
        (folder / 'RESULTS.json').write_text(json.dumps(row, indent=2) + '\n', encoding='utf-8', newline='\n')
        print(json.dumps({k: row[k] for k in ['scene', 'passed', 'views', 'errors']}), flush=True)
        if not row['passed']:
            break
    report = dict(issue=881, runs=runs, passed=len(runs)==2 and all(r['passed'] for r in runs), qualification=__doc__)
    (out / 'RESULTS.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    raise SystemExit(not report['passed'])


if __name__ == '__main__':
    main()
