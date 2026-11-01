"""Retain compact native evidence without shipping private engines or saves."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).parent
RUNS = {
    'effects': 'hunt-32670-20261101-190351-209203',
    'integrity': 'hunt-32662-20261101-185438-937093',
    'recovery': 'hunt-32664-20261101-185654-230697',
    'art_ring_exclusion': 'hunt-32672-20261101-190516-433765',
}

def quantile(values, p):
    values = sorted(values)
    at = (len(values) - 1) * p
    lo = int(at)
    return values[lo] + (values[min(lo + 1, len(values) - 1)] - values[lo]) * (at - lo)

reports = {}
for name, folder in RUNS.items():
    source = ROOT / 'build/issue614' / folder
    report = json.loads((source / 'results.json').read_text())
    assert report['passed'], folder
    for peer in report['peers']:
        text = (source / f"peer{peer['slot']}/engine.log").read_text(errors='replace')
        with (OUT / f"{name}-peer{peer['slot']}.log.gz").open('wb') as stream:
            with gzip.GzipFile(filename='', mode='wb', fileobj=stream, mtime=0) as compressed:
                compressed.write(text.encode())
        frame = [float(x) for x in re.findall(r'^CA614 FRAME ([\d.]+)', text, re.M)]
        peer['frame_callback_ms'] = (dict(count=len(frame), mean=sum(frame)/len(frame),
             p95=quantile(frame,.95), p99=quantile(frame,.99), maximum=max(frame)) if frame else None)
        peer['rest_cost_ms'] = {k:float(v) for k,v in re.findall(r'^CA614 COST (\w+)=([\d.]+)',text,re.M)}
    reports[name] = report
image = ROOT / 'build/issue614' / RUNS['art_ring_exclusion'] / 'peer0/objectives.png'
shutil.copyfile(image, OUT / 'six-powerups.png')
generated = subprocess.check_output([sys.executable, str(OUT / 'verify_generated.py')], cwd=ROOT, text=True)
start = generated.index('{')
report = dict(issue=614, version='5.13.10', date='2026-11-01',
    evidence='Native engine fixtures, four local peers; not author acceptance or Internet validation.',
    performance_limit='MSTimeF local effect timing and short RenderOverlay callback gaps. No ETW/display FPS claim; four peers share one GPU.',
    final_runtime_sha256=reports['effects']['runtime_sha256'],
    integrity_runtime_note='r4 and final r6 share gameplay; r6 changes diagnostic labels and MODELDEF frame visibility/facing only.',
    generated=json.loads(generated[start:]), runs=reports,
    image_sha256=hashlib.sha256(image.read_bytes()).hexdigest())
(OUT / 'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({name: {p['slot']: p['rest_cost_ms'] for p in r['peers']} for name,r in reports.items()},indent=2))
