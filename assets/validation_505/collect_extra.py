"""Collect a completed visual/compile run after its owned GZDoom process exits."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import shutil
import subprocess

HERE=Path(__file__).resolve().parent
WORK=HERE.parents[1]/'build/issue121'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('label')
parser.add_argument('--minimum-tic',type=int,required=True)
args=parser.parse_args()
path=WORK/f'{args.label}-run.json'
record=json.loads(path.read_text(encoding='utf-8-sig'))
processes=subprocess.run(['tasklist','/FI',f'PID eq {record["pid"]}','/NH'],capture_output=True,text=True,check=True).stdout
if 'gzdoom.exe' in processes.lower():raise SystemExit('Wait for the recorded GZDoom process to exit.')
raw=(WORK/f'{args.label}.txt').read_text(encoding='utf-8-sig')
assert not re.search(r'Script error,|VM execution aborted|Unable to resolve all fields|CA121 unbalanced',raw)
ticks=[int(t) for t in re.findall(r'CA121 SIM tic=(\d+)',raw)]
assert ticks,'No native simulation evidence'
assert ticks[-1]>=args.minimum_tic,(ticks[-1],args.minimum_tic)
record.update(completed_utc=datetime.now(timezone.utc).isoformat(),last_sim_tic=ticks[-1])
record['minimum_required_tic']=args.minimum_tic
path.write_text(json.dumps(record,indent=2)+'\n')
bench=WORK/'benchmarks.txt'
if bench.exists() and bench.stat().st_size>record['benchmark_offset']:
    (WORK/f'{args.label}-benchmarks.txt').write_bytes(bench.read_bytes()[record['benchmark_offset']:])
for suffix in ['.txt','.ini','-run.json','-benchmarks.txt']:
    source=WORK/(args.label+suffix)
    if source.exists():shutil.copyfile(source,HERE/source.name)
print(f'Collected {args.label}: last observed simulation tic {ticks[-1]}')
