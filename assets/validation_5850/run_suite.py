"""Run the final focused native suite serially; stop at the first failure."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[2]
runner = root / 'assets/validation_5850/run_native.ps1'

def run(label, script, runtime='final50b', save='', addon='checks.pk3', start_map='MAP01'):
    args = ['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
            str(runner), '-Label', label, '-Runtime', runtime, '-Script', script,
            '-Addon', addon, '-StartMap', start_map, '-Checks']
    if save:
        args += ['-LoadGame', save]
    subprocess.run(args, cwd=root, check=True)

if __name__ == '__main__':
    for case in ['catalogue', 'tent', 'contact', 'seed']:
        run('ready50-' + case, case)
    run('ready50-resume', 'resume', save='adapter-current.zds')
    run('ready50-hub', 'hub')
    run('original49-seed', 'legacyseed', 'original49', addon='legacy-checks.pk3')
    run('ready50-upgrade', 'resume', save='adapter-prior49.zds', addon='bridge/legacy-checks.pk3')
    run('ready50-rollback', 'legacyload', 'original49', 'adapter-prior49.zds', 'legacy-checks.pk3')
