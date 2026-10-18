"""Preserve validated logs/configs/hashes; exclude packages, saves and engine."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('directory')
args = parser.parse_args()
folder = ROOT / 'build' / args.directory
subprocess.run([sys.executable, str(HERE / 'report.py'), args.directory], check=True, stdout=subprocess.DEVNULL)
order = json.loads((folder / 'matrix-order.json').read_text())
target = HERE / 'evidence' / args.directory
target.mkdir(parents=True, exist_ok=True)
names = {'manifest.json', 'matrix-plan.json', 'matrix-order.json', 'matrix-results.json', 'solo.zs',
         'seed.cfg', 'seed01.txt', 'seed01-run.json', 'benchmarks.txt'}
for row in order:
    for suffix in ('.cfg', '-commands.cfg', '.txt', '.ini', '-run.json', '-bench.txt'):
        names.add(row['label'] + suffix)
records = []
for name in sorted(names):
    raw = (folder / name).read_bytes()
    compressed = name.endswith('.ini') or (name.endswith('.txt') and not name.endswith('-bench.txt'))
    stored = name + '.gz' if compressed else name
    (target / stored).write_bytes(gzip.compress(raw, mtime=0) if compressed else raw)
    records.append({'source':name, 'stored':stored, 'bytes':len(raw), 'sha256':hashlib.sha256(raw).hexdigest()})
seed = folder / 'solo-seed.zds'
metadata = {'directory':args.directory, 'seed_sha256':hashlib.sha256(seed.read_bytes()).hexdigest(),
            'seed_bytes':seed.stat().st_size, 'records':records,
            'excluded':'Runtime/fixture PK3, private save, engine and IWAD stay local.',
            'presentmon':'Non-elevated preflight exit6/access denied; Windows reported UAC cancellation. No frame-presentation series captured.'}
(HERE / 'evidence.json').write_text(json.dumps(metadata,indent=2) + '\n')
print(json.dumps({'archived_files':len(records),'directory':args.directory}))
