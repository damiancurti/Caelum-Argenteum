"""Compare original/candidate city presentation sequentially on one machine."""
from pathlib import Path
import argparse
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'candidate', 'presentation-layer', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    rows = []
    for scene, flags in [('peace', []), ('ground', ['--ground']), ('siege', ['--siege'])]:
        for geometry in ('original', 'candidate'):
            inventory = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH']).decode(errors='replace')
            if '"gzdoom.exe"' in inventory.lower():
                raise SystemExit('Another GZDoom process is running; do not mix presentation measurements.')
            label = geometry + '-' + scene
            command = [sys.executable, str(Path(__file__).with_name('run_barracas_presentation.py')),
                       '--runtime', str(args.runtime.resolve()), '--map', 'MAP03', '--players', '1',
                       '--presentation-layer', str(args.presentation_layer.resolve()), *flags]
            if geometry == 'candidate': command += ['--overlay', str(args.candidate.resolve())]
            print('Starting ' + label, flush=True)
            run = subprocess.run(command, cwd=ROOT, capture_output=True)
            (out / (label + '.log')).write_bytes(run.stdout + run.stderr)
            match = re.search(r'Campaign peers started:\s*(.+)', run.stdout.decode(errors='replace'))
            if run.returncode or not match:
                raise SystemExit('Native scene failed; inspect ' + str(out / (label + '.log')))
            folder = Path(match.group(1).strip())
            analysis = subprocess.run([sys.executable, str(ROOT / 'assets/validation_v5_12_7/analyze_vulkan_presents.py'), str(folder)], capture_output=True)
            (out / (label + '-analysis.log')).write_bytes(analysis.stdout + analysis.stderr)
            if analysis.returncode:
                raise SystemExit('Presentation trace failed validation: ' + str(folder))
            report = json.loads((folder / 'presentation.json').read_text())
            assert report['issue'] == 454 and len(report['peers']) == 1
            peer = report['peers'][0]
            row = {'scene': scene, 'geometry': geometry, 'directory': str(folder.relative_to(ROOT)),
                   'mean_present_fps': peer['mean_present_fps'], 'intervals': peer['present_intervals']}
            rows.append(row)
            (out / 'results.json').write_text(json.dumps({'issue': 454, 'runs': rows,
                'complete': len(rows) == 6, 'performance_accepted': False, 'author_accepted': False,
                'qualification': 'Sequential actual QueuePresent intervals, one Windows machine. No compositor/scanout, Internet or full-battle acceptance.'}, indent=2) + '\n')
            print(json.dumps(row), flush=True)


if __name__ == '__main__':
    main()
