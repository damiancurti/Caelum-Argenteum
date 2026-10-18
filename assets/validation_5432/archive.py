"""Archive #320 native evidence and verify tested/normal package contents."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
records = []
for folder in ('issue320-01', 'issue320-02', 'issue320-03', 'issue320-04',
               'issue320-before', 'issue320-release', 'issue320-final02'):
    source = ROOT/'build'/folder
    target = HERE/'evidence'/folder
    target.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(source/'quick.pk3') as package:
        (target/'probe.zs').write_bytes(package.read('probe.zs'))
    for p in sorted(source.iterdir()):
        if p.suffix == '.txt':
            raw = p.read_bytes()
            (target/(p.name+'.gz')).write_bytes(gzip.compress(raw, mtime=0))
            text = raw.decode('utf-8', 'replace')
            records.append({'directory': folder, 'log': p.name,
                'sha256': hashlib.sha256(raw).hexdigest(),
                'passed': len(re.findall(r'^CA282 PASS ', text, re.M)),
                'failed': len(re.findall(r'^CA282 FAIL ', text, re.M)),
                'done': bool(re.search(r'CA282 DONE passes=\d+ failures=0', text)),
                'matrix': re.findall(r'^CA320 MATRIX .*', text, re.M)})
        elif p.suffix in ('.json', '.cfg'):
            (target/p.name).write_bytes(p.read_bytes())
runtime = ROOT/'build/issue320-final02/production.pk3'
with zipfile.ZipFile(runtime) as tested, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    expected = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(tested.namelist()) == set(normal.namelist()) == set(expected)
    assert all(tested.read(n) == normal.read(n) == raw for n, raw in expected.items())
current = [r for r in records if r['directory'] == 'issue320-final02']
baseline = [r for r in records if r['directory'] == 'issue320-before']
assert len(current) == 6 and len(baseline) == 2
assert all(r['done'] and r['failed'] == 0 for r in current+baseline)
result = {'issue': 320, 'release': '5.4.32', 'runs': records,
    'final_passes': sum(r['passed'] for r in current),
    'baseline_passes': sum(r['passed'] for r in baseline),
    'normal_package_members': len(expected), 'normal_equals_tested_source': True,
    'runtime_sha256': hashlib.sha256(runtime.read_bytes()).hexdigest(),
    'fixture_sha256': hashlib.sha256((runtime.parent/'quick.pk3').read_bytes()).hexdigest(),
    'baseline_ref': 'fae45fb6', 'author_acceptance': 'pending CA320-01'}
(HERE/'evidence.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
print(json.dumps({k: v for k, v in result.items() if k != 'runs'}))
