"""Run one frozen MAP03 matrix sequentially, preserving each native bench range."""
from pathlib import Path
import argparse
import json
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
args=parser.parse_args()
assert args.directory.startswith('issue318-current') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory)
folder=ROOT/'build'/args.directory
bench=folder/'benchmarks.txt'
for label in ('peace-forward','peace-ground','siege-city','siege-front'):
    assert not (folder/(label+'-run.json')).exists(),(label,'already run; prepare a fresh directory')
    start=bench.stat().st_size if bench.exists() else 0
    subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',
        'assets/validation_5422/run_native.ps1','-Directory',args.directory,
        '-Label',label,'-Script',label+'.cfg','-Map','MAP03'],cwd=ROOT,check=True)
    raw=bench.read_bytes()
    assert len(raw)>start,(label,'native benchmark missing')
    (folder/(label+'-bench.txt')).write_bytes(raw[start:])
    (folder/(label+'-bench-range.json')).write_text(json.dumps({'start':start,'end':len(raw)})+'\n',encoding='utf-8')
subprocess.run([sys.executable,str(Path(__file__).with_name('report.py')),args.directory,'--verify'],cwd=ROOT,check=True)
