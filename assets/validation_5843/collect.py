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
WORK = ROOT / 'build/issue502-housekeeping'
NATIVE = HERE / 'native'
NATIVE.mkdir(exist_ok=True)
CURRENT = WORK / 'final43b/caelum_argenteum_dev.pk3'
PRIOR = WORK / 'prior42/caelum_argenteum_dev.pk3'

@lru_cache(maxsize=None)
def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def collect(label, package, frames=False):
    log = (WORK / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
    run = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code'] == 0 and not run.get('timed_out'), label
    assert not re.search(r'CA502A FAIL|VM execution aborted|Script error|fail(?:ed|ures)=[1-9]|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR', log), label
    count = len(re.findall(r'^CA502A PASS ', log, re.M))
    assert count > 0 or (frames and 'CA502A FRAME_END' in log), label
    assert run['package_sha256'].lower() == digest(package), label
    for suffix in ['.txt', '-run.json']:
        shutil.copy2(WORK / (label + suffix), NATIVE / (label + suffix))
    row = {'label': label, 'executed_passes': count, 'package_sha256': digest(package),
           'addon_sha256': run['addon_sha256'].lower()}
    if frames:
        values = sorted(float(value) for value in re.findall(r'^CA502A FRAME ([0-9.]+)', log, re.M))
        assert len(values) > 100, label
        row['callback_intervals_ms'] = {'samples': len(values), 'mean': statistics.mean(values),
            **{key: values[int((len(values)-1)*fraction)] for key, fraction in [('p50', .5), ('p95', .95), ('p99', .99)]}, 'max': max(values)}
    return row

cases = ['seed', 'reload', 'resume', 'limbo', 'core', 'shortages', 'multiple', 'migration']
runs = [collect('release-' + case, CURRENT) for case in cases]
original = [collect('prior43a', PRIOR), collect('release-rollback', PRIOR)]
frames = [collect('frames02-prior', PRIOR, True), collect('frames02-current', CURRENT, True)]
fixtures = ['checks.pk3', 'legacy-checks.pk3', 'frames.pk3', 'legacy-frames.pk3']
before = {name: digest(WORK / name) for name in fixtures}
subprocess.run(['python', str(HERE / 'prepare.py')], cwd=ROOT, check=True, capture_output=True)
digest.cache_clear()
assert before == {name: digest(WORK / name) for name in fixtures}
with zipfile.ZipFile(CURRENT) as archive, zipfile.ZipFile(PRIOR) as old:
    source = {path.relative_to(ROOT / 'src').as_posix(): path for path in (ROOT / 'src').rglob('*') if path.is_file()}
    assert set(archive.namelist()) == set(source)
    assert all(archive.read(name) == path.read_bytes() for name, path in source.items())
    art = [name for name in old.namelist() if name.startswith(('maps/', 'models/', 'sprites/', 'graphics/', 'textures/'))]
    assert all(archive.read(name) == old.read(name) for name in art)
static = json.loads((HERE / 'static-validation.json').read_text(encoding='utf-8-sig'))
assert static['version'] == '5.8.43' and not static['errors']
core = (WORK / 'release-core.txt').read_text(encoding='utf-8', errors='replace')
timing = re.search(r'CA502A TIMING access_targets=(\d+) mean_ms=([\d.]+) p95_ms=([\d.]+) max_ms=([\d.]+)', core)
assert timing, 'Missing native access timing'
catchup = {}
for case in ['seed', 'multiple']:
    log = (WORK / ('release-' + case + '.txt')).read_text(encoding='utf-8', errors='replace')
    match = re.search(r'CA502A TIMING (?:households=2 day_)?catchup_ms=([\d.]+)', log)
    if match:
        catchup[case] = float(match[1])
presentation = {}
for suffix in ['presentmon.txt', 'presentmon-error.txt']:
    path = WORK / ('frames02-current-' + suffix)
    if path.exists():
        shutil.copy2(path, NATIVE / path.name)
        blob = path.read_bytes()
        presentation[suffix] = blob.decode('utf-16' if blob.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig', errors='replace')
report = {'version': '5.8.43', 'issue': 502, 'base': '931bee7c6a7dacbb8e031a4f1edabfaff717d7af',
    'runtime_sha256': digest(CURRENT), 'source_matching_package_members': len(source), 'unchanged_map_art_members': len(art),
    'native_passes': sum(row['executed_passes'] for row in runs), 'original_runtime_passes': sum(row['executed_passes'] for row in original),
    'native_failures': 0, 'runs': runs, 'original_runs': original, 'prior_save_sha256': digest(WORK / 'home-prior42.zds'),
    'fixture_repeat_sha256': before,
    'access_capture': {'targets': int(timing[1]), 'mean_ms': float(timing[2]), 'p95_ms': float(timing[3]), 'max_ms': float(timing[4]), 'iterations': 20},
    'catchup_ms': catchup, 'renderer_callbacks': frames, 'presentation_attempt': presentation,
    'scope': 'Real reachable-house snapshots, chronological shared shop purchases, daily per-home quota, partial progress, real supplies, shortage handling, suspended residents, persistent return/save, original-runtime upgrade/rollback, Limbo exterior-calendar freeze and six direct-versus-cached floor-history comparisons.',
    'performance_limits': 'RenderOverlay cadence is not displayed FPS. PresentMon ETW availability is recorded separately. Native access/catch-up callbacks are synchronous execution timings. No whole-campaign rendering acceptance is inferred.',
    'probe_findings': 'Early fixture/compiler mistakes were corrected and retained privately. A loaded old save omits newly added local EventHandlers; the frame meter uses a StaticEventHandler so the same old save can be compared on both runtimes. The release-frames-prior attempt with no samples is not counted.',
    'limits': 'Visited homes only; captures native straight-line/sight/floor access matching loaded housekeeping. Unloaded NPC physiology, remaining contact adapters and the other V5.8 issues remain separate. No new balance, map or art changes.',
    'author_acceptance': 'CA502-HOME-AWAY-01 remains pending the grouped final V5.8 handoff.'}
(HERE / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ['native_passes', 'original_runtime_passes', 'runtime_sha256', 'source_matching_package_members', 'unchanged_map_art_members', 'access_capture', 'catchup_ms']}))
