"""Verify final source/package parity and preserve the static delivery result."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT/'build/issue132'

def digest(data):
    return hashlib.sha256(data).hexdigest()

before = (WORK/'MANIFEST.json').read_bytes()
subprocess.run([sys.executable, '-X', 'utf8', str(HERE/'prepare.py')], check=True, capture_output=True)
after = (WORK/'MANIFEST.json').read_bytes()
assert before == after, 'Deterministic fixture manifest changed'
manifest = json.loads(after)
with zipfile.ZipFile(WORK/'production.pk3') as fixture, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as delivery:
    source = {p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(source) == set(fixture.namelist()) == set(delivery.namelist())
    for name, path in source.items():
        assert path.read_bytes() == fixture.read(name) == delivery.read(name), name
    count = len(source)

validation = subprocess.run([sys.executable, '-X', 'utf8', 'validate_project.py'],
                            cwd=ROOT, check=True, capture_output=True, text=True, encoding='utf-8')
parsed = json.loads(validation.stdout)
assert not parsed['errors']
save_checks = json.loads((HERE/'SAVE_VERIFICATION.json').read_text())
assert save_checks['count'] == 52
performance = json.loads((HERE/'PERFORMANCE.json').read_text())['runs']
assert all(r['completed'] for r in performance.values())
for label in ('staged-long-a','staged-long-b'):
    r = performance[label]
    assert r['last']['total'] == 6000 and r['last']['remaining'] == 0 and r['max_alive'] <= 2000
for label in ('final-boundaries','final-pending-reload'):
    assert 'CA132 COMPLETE checks=22 failures=0' in (HERE/(label+'.txt')).read_text(encoding='utf-8-sig')

power = json.loads((WORK/'power-request.json').read_text(encoding='utf-8-sig'))
capture = json.loads((WORK/'capture-helper.json').read_text(encoding='utf-8-sig'))
assert power['released_utc'] and power['active_plan_before'] == power['active_plan_after']
assert capture['ended_utc']
for label, r in performance.items():
    if 'presentmon' not in r:
        continue
    err = WORK/(label+'-present.err.txt')
    error_bytes = err.read_bytes()
    encoding = 'utf-16' if error_bytes.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig'
    assert not error_bytes.decode(encoding).strip(), label
    (HERE/err.name).write_bytes(err.read_bytes())
    output = WORK/(label+'-present.out.txt')
    (HERE/output.name).write_bytes(output.read_bytes())

result = {'static_validator':parsed, 'native_assertions':22, 'native_save_comparisons':52,
          'complete_budget_runs':['staged-long-a','staged-long-b'],
          'profile_runs':['profile-full-a','profile-cap-a','profile-late-a','profile-deaths-a'],
          'native_production_sha256':manifest['production_sha256'],
          'standard_build_sha256':digest((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()),
          'source_fixture_delivery_members_equal':count, 'deterministic_fixture_manifest_equal':True,
          'source_changes':{name:digest(source[name].read_bytes()) for name in
             ['ZSCRIPT','CVARINFO','caelum/world/CaelumPortSiege.zs',
              'caelum/world/CaelumSiegeEncounter.zs','caelum/world/CaelumSiegeReinforcements.zs']},
          'power_request_released':power['released_utc'], 'capture_helper_ended':capture['ended_utc'],
          'author_acceptance':'Pending CA132-01; no #132 acceptance inferred'}
(HERE/'DELIVERY.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
print('PASS: final source, measured fixture and standard delivery match across', count, 'members.')
