"""Record final #238 native round-trip evidence, preserving failed prototypes."""
import hashlib
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def digest(path):
    return hashlib.file_digest(path.open('rb'), 'sha256').hexdigest()


def main():
    prefix = 'issue238-paid-roundtrip-04-'
    stages = [('current', 'seed'), ('bridge', 'paid'), ('current', 'repeat'),
              ('current', 'resume'), ('current', 'cooldown-seed'),
              ('bridge', 'cooldown'), ('current', 'cooldown')]
    runs = []
    for mode, label in stages:
        work = ROOT / 'build' / (prefix + mode)
        record = json.loads((work / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        log_path = work / (label + '.txt')
        log = log_path.read_text(encoding='utf-8-sig')
        done = re.findall(r'CA238 DONE failures=0 passes=(\d+) PAID_ROLLBACK', log)
        assert record['exit_code'] == 0 and len(done) == 1, (mode, label)
        assert not re.search(r'CA238 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR|Unknown class|invalid state', log, re.I), (mode, label)
        for key, filename in [('runtime_sha256', 'production.pk3'), ('fixture_sha256', 'paid.pk3')]:
            assert record[key].lower() == digest(work / filename)
        arguments = [str(a).replace(str(ROOT), '<repository>') for a in record['arguments']]
        iwad = arguments.index('-iwad')
        arguments[iwad + 1] = '<development-IWAD>'
        runs.append({
            'directory': 'build/' + prefix + mode, 'label': label,
            'started_utc': record['started_utc'], 'finished_utc': record['finished_utc'],
            'exit_code': 0, 'assertions': int(done[0]), 'arguments': arguments,
            'runtime_sha256': record['runtime_sha256'].lower(),
            'fixture_sha256': record['fixture_sha256'].lower(),
            'engine_sha256': record['engine_sha256'].lower(),
            'log_sha256': digest(log_path),
            'checks': [line for line in log.splitlines() if line.startswith('CA238 ')],
        })
    saves = []
    for mode in ['current', 'bridge']:
        work = ROOT / 'build' / (prefix + mode)
        for path in sorted(work.glob('*.zds')):
            if path.name.startswith('auto'):
                continue
            saves.append({'path': path.relative_to(ROOT).as_posix(), 'sha256': digest(path)})
    for name in ['paid.zds', 'cooldown.zds', 'bridged-paid.zds', 'bridged-cooldown.zds']:
        assert digest(ROOT / 'build' / (prefix + 'current') / name) == digest(ROOT / 'build' / (prefix + 'bridge') / name)
    # Canonical Git packages and Windows packages may differ only in text EOL.
    identical, eol_only = [], []
    with zipfile.ZipFile(ROOT / 'build' / (prefix + 'current') / 'production.pk3') as z:
        names = set(z.namelist())
        assert names == {p.relative_to(ROOT / 'src').as_posix() for p in (ROOT / 'src').rglob('*') if p.is_file()}
        for name in sorted(names):
            archived = z.read(name)
            working = (ROOT / 'src' / name).read_bytes()
            if archived == working:
                identical.append(name)
                continue
            assert archived.decode('utf-8-sig').replace('\r\n', '\n') == working.decode('utf-8-sig').replace('\r\n', '\n'), name
            eol_only.append(name)
    evidence = {
        'issue': 238, 'origin_version': '5.4.4', 'recorded_date': '2026-10-15',
        'scope': 'Shared paid-state rollback bridge and re-upgrade; no production gameplay changes',
        'baseline_commit': 'c07be5a263b0b5dc72e3ed69ad5954e087e03468',
        'current_commit': '0e0ae85f5c51f57f6059dfd5bd21009915bf78f5',
        'environment': 'Windows 11 / GZDoom 4.14.2 / Vulkan / isolated config / background unpaused / audio 5%',
        'native_runs': runs, 'assertions': sum(r['assertions'] for r in runs),
        'saved_copies': saves,
        'source_comparison': {'byte_identical_members': len(identical), 'text_eol_only_members': eol_only},
        'determinism': {
            'method': 'Independent pinned Git packaging in roundtrip-02 and roundtrip-04',
            'current_runtime_equal': digest(ROOT / 'build/issue238-paid-roundtrip-02-current/production.pk3') == digest(ROOT / 'build' / (prefix + 'current') / 'production.pk3'),
            'bridge_runtime_equal': digest(ROOT / 'build/issue238-paid-roundtrip-02-bridge/production.pk3') == digest(ROOT / 'build' / (prefix + 'bridge') / 'production.pk3'),
        },
        'preserved_prototypes': [
            'roundtrip-01 bridge package omitted sleeping-pose texture inputs; discovered before launching that bridge; fixed in 02',
            'roundtrip-02 bridge/paid-01 assertions passed but quit before the save was written; current/repeat-01 then failed to find that save. Final scripts wait and the driver verifies each artifact before continuing.',
            'roundtrip-02 current/resume-01 expected an active cast after loading only three remaining tics. It had correctly completed; final oracle accepts completion with the retained ledger.',
            'roundtrip-02 bridge/cooldown-01 and roundtrip-03 current/cooldown-01 exposed a fixture error: a negligible positive floating remainder created a zero-rate instrumented racial during cooldown. Seeding is now explicitly limited to active preparation; cooldown verification also waits for load completion.',
        ],
        'limits': [
            'Bridge only for the pinned 5.4.3 and shared 5.4.4 schemas; later concrete effects are outside this bridge',
            'New preparation/racial fields remain inert in old gameplay; old Sleep and cooldown timers continue',
            'The base racial object isolates serialization; concrete effects retain their own issue evidence',
            'Original save/runtime copies are retained; never load a new-state save with unbridged 5.4.3',
            'No multiplayer, third-party native armor, new manual acceptance, merge or closure claim',
        ],
    }
    assert all(evidence['determinism'][k] for k in ['current_runtime_equal', 'bridge_runtime_equal'])
    validation = ROOT / 'build/issue238-completion-validation.json'
    normal = ROOT / 'build/issue238-completion-normal.pk3'
    if validation.exists():
        checked = json.loads(validation.read_text(encoding='utf-8-sig'))
        assert checked['errors'] == []
        evidence['static_validation'] = {'command': 'python validate_project.py', 'exit_code': 0, 'errors': []}
    if normal.exists():
        with zipfile.ZipFile(normal) as z:
            members = z.namelist()
            assert set(members) == names
            assert all(z.read(n) == (ROOT / 'src' / n).read_bytes() for n in members)
        evidence['normal_packaging'] = {
            'command': 'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1 -Destination build/issue238-completion-normal.pk3',
            'exit_code': 0, 'members': len(members), 'all_members_equal_source': True,
            'sha256': digest(normal),
        }
    target = HERE / 'rollback_evidence.json'
    target.write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'runs': len(runs), 'assertions': evidence['assertions'], 'source_members': len(names), 'eol_only': len(eol_only)}))


if __name__ == '__main__':
    main()
