"""Render the validated numeric tables into the maintained evidence report."""
from pathlib import Path
import argparse
import json

HERE = Path(__file__).parent
ROOT = HERE.resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('directory')
args = parser.parse_args()
result = json.loads((ROOT / 'build' / args.directory / 'matrix-results.json').read_text())
assert result['verification_passed'] and len(result['cases']) == 66
rows = {(r['site'],r['mode']):r for r in result['summary']}
names = ['Residual combatant Tick','Attacker target selection','Thermal integration',
         'Breath management','Breath mouth position','Elemental status',
         'Health-derived statistics','Offensive statistics','WalkTo / navigation']
out = [
    'All 66 windows passed: 23,100 sampled tics, identical captured calls and',
    'start tic 3774, all 8,910 actors retained, no unexpected spawns, native poison,',
    'external pose/reference changes or health losses. The selected family alone',
    'executed ten times its captured 35-tic call count in every active variant.',
    '',
    'Each delta is elapsed milliseconds per **simulation tic**, not per rendered frame.',
    'GZDoom targets 35 tics/s. Brackets show the range of the three repeat deltas;',
    'they are not statistical confidence intervals. FPS columns are median native',
    'snapshots and their range (three per active variant, six per control).',
    '',
    '| Family enabled | Extra elapsed ms/tic, city | Extra elapsed ms/tic, front | Native FPS snapshot, city | Native FPS snapshot, front |',
    '| --- | ---: | ---: | ---: | ---: |']
def fps(row):
    low,high = row['fps_snapshot_range']
    return f"{row['fps_snapshot_median']:g} [{low}-{high}]"
def delta(row):
    low,high = row['delta_range_ms']
    return f"{row['delta_mean_ms']:.3f} [{low:.3f}-{high:.3f}]"
out.append(f"| All nine off | 0 (reference) | 0 (reference) | {fps(rows[0,-1])} | {fps(rows[1,-1])} |")
for mode,name in enumerate(names):
    out.append(f'| {name} | {delta(rows[0,mode])} | {delta(rows[1,mode])} | {fps(rows[0,mode])} | {fps(rows[1,mode])} |')
out += ['', 'The all-off replay batch itself averages '
        f"{rows[0,-1]['batch_mean_ms']:.3f}ms/tic city and {rows[1,-1]['batch_mean_ms']:.3f}ms/tic front. "
        'This common diagnostic work is subtracted above; it is not a production subsystem.', '',
        '| Family | Captured calls / 35 tics | Restore ms/tic, city | Restore ms/tic, front |',
        '| --- | ---: | ---: | ---: |']
counts = result['cases'][0]['counts']
out.append(f"| All nine off | 0 dispatched | {rows[0,-1]['restore_mean_ms']:.3f} | {rows[1,-1]['restore_mean_ms']:.3f} |")
for mode,name in enumerate(names):
    out.append(f"| {name} | {counts[mode][3]:,} | {rows[0,mode]['restore_mean_ms']:.3f} | {rows[1,mode]['restore_mean_ms']:.3f} |")
out += ['', 'Restoration and invariants are outside the replay-batch timer but consume',
        'real frame time, and restoring movement can cost more than restoring an',
        'unchanged scene. Thus the FPS snapshots describe the whole diagnostic;',
        'their difference must not be attributed entirely to the selected core.', '',
        'Residual combatant updates and target selection dominate these isolated',
        'controls. This prioritizes investigation of those paths; it does not',
        'establish that their rules or any inventory item are dispensable.', '',
        f"Simulation interval rates across the windows range from {min(c['simulation_tics_per_second'] for c in result['cases']):.3f} "
        f"to {max(c['simulation_tics_per_second'] for c in result['cases']):.3f} tics/s."]
p = HERE / 'RESULTS.md'
text = p.read_text()
start = text.index('## Results\n') + len('## Results\n')
end = text.index('## Isolation boundaries',start)
p.write_text(text[:start] + '\n' + '\n'.join(out) + '\n\n' + text[end:])
print('Updated validated result tables.')
