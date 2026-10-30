"""Serial native campaign comparisons: never overlap engines or exceed policy."""
from pathlib import Path
import argparse
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--after', default='')
    args = parser.parse_args()
    plan = [('current-complete', ['--siege', '--overlay', 'build/issue431/current-siege-timers-complete.pk3'])]
    for variant in ('current', 'reduced5', 'simplified', 'full35'):
        options = ['--siege']
        if variant != 'current':
            options += ['--overlay', f'build/issue431/{variant}-siege.pk3']
        plan.append((variant+'-siege', options))
    for scene, options in [('mansion', ['--map', 'MAP01']), ('sewers', ['--map', 'MAP02']),
                           ('city', []), ('ground', ['--ground'])]:
        plan.append(('current-'+scene, options))
    active = not args.after
    for name, options in plan:
        if not active:
            active = name == args.after
            continue
        subprocess.run([sys.executable, str(HERE/'run_profile.py'), name,
                        '--package', str(args.package.resolve()), *options], cwd=ROOT, check=True)
        print('Completed '+name, flush=True)


if __name__ == '__main__':
    main()
