"""Run one engine at a time from an identical frozen diagnostic save."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory', required=True)
parser.add_argument('--prefix', default='matrix')
parser.add_argument('--sites', default='0,1')
parser.add_argument('--rounds', type=int, default=3)
parser.add_argument('--modes', default='-1,0,1,2,3,4,5,6,7,8')
args = parser.parse_args()
assert re.fullmatch(r'issue318-isolation[a-z0-9-]+', args.directory)
assert re.fullmatch(r'[a-z0-9-]+', args.prefix)
folder = ROOT / 'build' / args.directory
bench = folder / 'benchmarks.txt'
order = []
seed_hash = hashlib.sha256((folder / 'solo-seed.zds').read_bytes()).hexdigest()
plan = folder / (args.prefix + '-plan.json')
assert not plan.exists(), 'Preserve the existing plan; use another prefix.'
plan.write_text(json.dumps(dict(vars(args),seed_sha256=seed_hash),indent=2) + '\n')
modes = [int(x) for x in args.modes.split(',')]
assert all(-1 <= x <= 8 for x in modes)
for repeat in range(args.rounds):
    # Reverse order on the second repeat; retain baseline at both ends.
    active = [m for m in modes if m != -1]
    if repeat % 2:
        active.reverse()
    selected = ([-1] if -1 in modes else []) + active
    if -1 in modes and active:
        selected.append(-1)
    for site in [int(x) for x in args.sites.split(',')]:
        assert site in (0, 1)
        for index, mode in enumerate(selected):
            label = f'{args.prefix}-s{site}-r{repeat}-n{index}-m{mode}'
            assert not (folder / (label + '.ini')).exists(), label
            script = f'{label}.cfg'
            text = (folder / f'mode{mode}.cfg').read_text()
            (folder / script).write_text(text.replace('ca318_solo_mode', f'ca318_solo_site {site}; ca318_solo_mode', 1))
            start = bench.stat().st_size if bench.exists() else 0
            print(f'RUN {label}', flush=True)
            subprocess.run([
                'powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                'assets/validation_5422/run_native.ps1', '-Directory', args.directory,
                '-Label', label, '-Script', script, '-LoadGame', 'solo-seed.zds',
                '-Map', 'MAP03'], cwd=ROOT, check=True)
            log = (folder / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
            assert 'CA282 DONE passes=3 failures=0' in log, label
            raw = bench.read_bytes()
            assert len(raw) > start, (label, 'missing native bench')
            (folder / (label + '-bench.txt')).write_bytes(raw[start:])
            order.append({'label': label, 'site': site, 'repeat': repeat, 'mode': mode,
                          'seed_sha256':seed_hash,
                          'bench_start': start, 'bench_end': len(raw)})
            (folder / (args.prefix + '-order.json')).write_text(json.dumps(order, indent=2) + '\n')
            print(f'PASS {label}', flush=True)
assert hashlib.sha256((folder / 'solo-seed.zds').read_bytes()).hexdigest() == seed_hash
