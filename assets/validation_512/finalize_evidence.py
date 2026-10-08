"""Copy bounded measurement artifacts and hash the delivered evidence verbatim."""
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1]/'build/issue132'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name in ('MANIFEST.json', 'power-request.json', 'capture-helper.json'):
    p = WORK/name
    if p.exists():
        (HERE/name).write_bytes(p.read_bytes())

bench = (WORK/'benchmarks.txt').read_bytes()
run_order = sorted((json.loads(p.read_text(encoding='utf-8-sig'))
                    for p in WORK.glob('*-run.json')), key=lambda r:r['started_utc'])
bench_summary = {}
for p in HERE.glob('*-run.json'):
    record = json.loads(p.read_text(encoding='utf-8-sig'))
    count = record['command_script'].count('bench;')
    if not count:
        continue
    start = record['benchmark_offset']
    subsequent = [r for r in run_order if r['started_utc'] > record['started_utc']]
    end = subsequent[0]['benchmark_offset'] if subsequent else len(bench)
    assert end >= start, (p.name, start, end)
    blocks = list(re.finditer(rb'(?m)^Map MAP06:', bench[start:end]))
    # Native bench is deferred: a final request need not finish before quit.
    # Never borrow a later run's first sample to satisfy the requested count.
    assert len(blocks) <= count, p.name
    name = record['label']+'-bench.txt'
    (HERE/name).write_bytes(bench[start:end])
    bench_summary[record['label']] = {'start_byte': start, 'end_byte': end,
                                     'requested_samples': count, 'completed_samples': len(blocks),
                                     'sha256': sha(HERE/name)}
(HERE/'BENCHMARKS.json').write_text(json.dumps(bench_summary, indent=2)+'\n', encoding='utf-8')

# Small reviewed selection; full local captures remain in build/issue132.
for name in ('baseline-natural-b-natural-350.png', 'cap-natural-b-natural-350.png',
             'staged-long-b-long-20650.png', 'staged-long-b-long-24850.png'):
    p = WORK/name
    if p.exists():
        (HERE/name).write_bytes(p.read_bytes())

profiles = {}
for p in HERE.glob('profile-*.txt'):
    rows = []
    for line in p.read_text(encoding='utf-8-sig').splitlines():
        if line.startswith('CA121 COST '):
            rows.append({k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)', line)})
    if not rows:
        continue
    tics = set(r['tic'] for r in rows if r['tic'] > 0)
    profile = {'sampled_tics':len(tics), 'categories':[]}
    for key in sorted(set(r['id'] for r in rows)):
        group = [r for r in rows if r['id'] == key and r['tic'] > 0]
        profile['categories'].append({'id':int(key), 'calls':sum(r['calls'] for r in group),
                                     'inclusive_ms_per_sample_tic':sum(r['inclusive'] for r in group)/len(tics),
                                     'exclusive_ms_per_sample_tic':sum(r['exclusive'] for r in group)/len(tics)})
    profiles[p.stem] = profile
(HERE/'PROFILE_RESULTS.json').write_text(json.dumps(profiles, indent=2)+'\n', encoding='utf-8')

manifest = {'algorithm':'SHA256', 'files':{p.name:sha(p) for p in sorted(HERE.iterdir())
             if p.is_file() and p.name != 'EVIDENCE_SHA256.json'}}
(HERE/'EVIDENCE_SHA256.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print('Hashed', len(manifest['files']), 'evidence files.')
