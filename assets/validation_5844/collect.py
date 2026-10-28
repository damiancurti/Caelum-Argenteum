"""Collect actual native assertions, package identity and bounded timing evidence."""
from pathlib import Path
from functools import lru_cache
import hashlib
import json
import re
import shutil
import statistics
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue410-decor'
NATIVE = HERE / 'native'
NATIVE.mkdir(exist_ok=True)
CURRENT = WORK / 'final44b/caelum_argenteum_dev.pk3'
PRIOR = WORK / 'prior43/caelum_argenteum_dev.pk3'

@lru_cache(maxsize=None)
def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def collect(label, package, frames=False):
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
    run = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code'] == 0 and not run.get('timed_out'), label
    assert not re.search(r'CA410O FAIL|VM execution aborted|Script error|fail(?:ed|ures)=[1-9]|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR', log), label
    count = len(re.findall(r'^CA410O PASS ', log, re.M))
    assert count > 0 or (frames and 'CA410O FRAME_END' in log), label
    assert run['package_sha256'].lower() == digest(package), label
    for suffix in ['.txt', '-run.json']:
        shutil.copy2(WORK / (label + suffix), NATIVE / (label + suffix))
    row = {'label': label, 'executed_passes': count, 'package_sha256': digest(package),
           'addon_sha256': run['addon_sha256'].lower()}
    if frames:
        values = sorted(float(value) for value in re.findall(r'^CA410O FRAME ([0-9.]+)', log, re.M))
        assert len(values) > 100, label
        row['callback_intervals_ms'] = {'samples': len(values), 'mean': statistics.mean(values),
            **{key: values[int((len(values)-1)*fraction)] for key, fraction in [('p50', .5), ('p95', .95), ('p99', .99)]}, 'max': max(values)}
    return row

cases = ['craft','trade','items','reject','seed','hub','input','view0','view1','icon0','icon1','resume','upgrade']
runs = [collect('release-catalogue', CURRENT)] + [collect('release2-'+case, CURRENT) for case in cases]
original = [collect('original43-seed', PRIOR), collect('release2-rollback', PRIOR)]
with zipfile.ZipFile(CURRENT) as archive, zipfile.ZipFile(PRIOR) as old:
    source = {p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(source) == set(archive.namelist())
    assert all(archive.read(n)==p.read_bytes() for n,p in source.items())
    art = [n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(archive.read(n)==old.read(n) for n in art)
manifest=ROOT/'assets/art_source/ornamental_decor/GENERATED.json'
before=manifest.read_bytes()
subprocess.run(['python','assets/generators/generate_ornamental_decor.py'],cwd=ROOT,check=True,capture_output=True)
assert before==manifest.read_bytes()
for name,sha in json.loads(before)['outputs'].items():
    assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==sha
for name in ['decor-view0.png','decor-view1.png','decor-icon0.png','decor-icon1.png']:
    shutil.copy2(WORK/name,NATIVE/name)
static=json.loads((HERE/'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.44' and not static['errors']
report={'version':'5.8.44','issue':410,'base':'47acf3e376379e074c15504594be0380ac5757de',
    'runtime_sha256':digest(CURRENT),'source_matching_package_members':len(source),'unchanged_map_art_members':len(art),
    'native_passes':sum(r['executed_passes'] for r in runs),'original_runtime_passes':sum(r['executed_passes'] for r in original),
    'native_failures':0,'runs':runs,'original_runs':original,'prior_save_sha256':digest(WORK/'decor-prior43.zds'),
    'art_generation_repeat':'Byte-identical manifest and all generated output hashes.',
    'scope':'Two approved decorative types, real crafting/materials/pricing/trade, learned catalogue migration, actual wall/floor placement, collisions/permissions/title/weight, Box, native crouch/use, source identity/dirt, save/hub and genuine5.8.43 migration/rollback. Existing art/maps unchanged.',
    'probe_findings':'Early out-vector JIT rejected; result object substituted. An inventory UI fixture field corrected. Native changemap intermission did not complete the first hub probe; CHANGELEVEL_NOINTERMISSION and a required final-map marker now verify the real return. Craft fixture narrowed to the two newly learned recipes instead of querying unlearned old recipes. The mirrored painting and flat carved texture were corrected before final visual checks. Failed private probes remain available but are excluded.',
    'reuse':'The passing release-catalogue final-runtime run is reused; the later fixture change affects only the crafting station assertions. All other accepted cases use release2 fixtures against the same final44b package.',
    'performance_limits':'No routine scans added; placement uses local native queries only on activation. No displayed-FPS acceptance inferred; the same-session PresentMon ETW denial is recorded under validation_5843.',
    'author_acceptance':'CA410-DECOR-01 remains pending the requested grouped final V5.8 handoff; earlier entries retained.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members']}))
