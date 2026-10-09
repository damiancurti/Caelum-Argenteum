"""Check the mechanical-work delivery and preserve the preceding evidence."""
from pathlib import Path
import hashlib, io, json, re, subprocess, sys, zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue136'
BASELINE = '3366aba4b31ab339eacdf52bbde62a735e30b636'
RUNS = {
    'energy-compile-a': r'CA136 COMPLETE checks=49 failures=0',
    'energy-checks-b': r'CA136 ENERGY COMPLETE checks=74 failures=0',
    'energy-checks-c': r'CA136 ENERGY COMPLETE checks=76 failures=0',
    **{f'energy-live-{name}': r'CA136 ENERGY LIVE COMPLETE' for name in
       ['normal-b', 'high-a', 'caelith-a', 'goblin-a']},
    'energy-save-seed-b': r'CA136 ENERGY SAVE SEED revision=7',
    'energy-save-upgrade-a': r'CA136 ENERGY SAVE PASS',
    'energy-save-reload-a': r'CA136 ENERGY SAVE PASS',
    'energy-save-rollback-a': r'CA136 ENERGY ROLLBACK PASS',
    'energy-swim-normal-a': r'CA136 HEAT COMPLETE',
    'energy-swim-high-a': r'CA136 HEAT COMPLETE',
    'energy-block-normal-a': r'CA136 ENERGY BLOCK COMPLETE',
    'energy-block-high-a': r'CA136 ENERGY BLOCK COMPLETE',
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {n: archive.read(n) for n in archive.namelist() if not n.endswith('/')}


def stable_zip(payload):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(payload.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return buffer.getvalue()


def samples(label, prefix):
    log = (HERE / (label + '.txt')).read_text(encoding='utf-8-sig')
    return [{k: float(v) for k, v in re.findall(r'(\w+)=(-?\d+(?:\.\d+)?)(?= |$)', line)}
            for line in log.splitlines() if line.startswith(prefix)]


def main():
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/NH'], text=True)
    assert 'gzdoom.exe' not in active.lower(), 'Finish native testing first.'
    source = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
              for p in (ROOT / 'src').rglob('*') if p.is_file()}
    packages = {}
    for path in [ROOT / 'build/caelum_argenteum_dev.pk3', OUT / 'production.pk3',
                 OUT / 'energy-current/caelum_argenteum_dev.pk3']:
        assert members(path) == source, f'{path} differs from final source'
        packages[str(path.relative_to(ROOT))] = sha(path.read_bytes())

    # Reconstruct the earlier measured package exactly. Its only runtime delta
    # is the charged-javelin factor, covered by the final 76-check suite.
    prior = dict(source)
    player = 'caelum/player/CaelumPlayer.zs'
    final_call = b'RecordWeaponAction(self,CaelumConstants.WEAPON_TYPE_JAVELIN,true,chargedAttack);'
    prior_call = b'RecordWeaponAction(self,CaelumConstants.WEAPON_TYPE_JAVELIN,true);'
    assert prior[player].count(final_call) == 1
    prior[player] = prior[player].replace(final_call, prior_call)
    prior_hash = sha(stable_zip(prior))
    baseline_path = OUT / 'energy-baseline/caelum_argenteum_dev.pk3'
    baseline = members(baseline_path)
    tree = subprocess.check_output(['git', 'ls-tree', '-r', BASELINE, 'src'], cwd=ROOT, text=True)
    expected = {line.split('\t')[1][4:]: line.split()[2] for line in tree.splitlines()}
    assert set(baseline) == set(expected)
    def blob(data):
        return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    for name, data in baseline.items():
        assert expected[name] in [blob(data), blob(data.replace(b'\r\n', b'\n'))], name
    baseline_hash = sha(baseline_path.read_bytes())
    runs = {}
    for label, marker in RUNS.items():
        record = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        log = (HERE / (label + '.txt')).read_text(encoding='utf-8-sig')
        assert record['exit_code'] == 0 and re.search(marker, log), label
        assert not re.search(r'CA136[^\r\n]*\bFAIL\b|VM execution aborted|Script error,|DIED WITH FATAL ERROR|Unknown command', log), label
        assert all(value in record['initial_config'] for value in
                   ['snd_mastervolume=0.05', 'i_pauseinbackground=false', 'vid_activeinbackground=true'])
        tested = record['package_sha256'].lower()
        if label in ['energy-save-seed-b', 'energy-save-rollback-a']:
            assert tested == baseline_hash, label
            scope = 'Preserved revision-7 baseline'
        elif label in ['energy-checks-c', 'energy-swim-normal-a', 'energy-swim-high-a',
                       'energy-block-normal-a', 'energy-block-high-a']:
            assert tested in packages.values(), label
            scope = 'Final runtime'
        else:
            assert tested == prior_hash, f'{label}: prior payload cannot be reproduced exactly'
            scope = 'Identical runtime except charged-javelin argument; final suite covers that correction'
        runs[label] = {'package_sha256': tested, 'addon_sha256': record['addon_sha256'],
                       'log_sha256': sha((HERE / (label + '.txt')).read_bytes()),
                       'exit_code': 0, 'evidence_scope': scope}

    live = {}
    for name in ['normal-b', 'high-a', 'caelith-a', 'goblin-a']:
        label = 'energy-live-' + name
        rows = samples(label, 'CA136 ENERGY LIVE sec=')
        jump = samples(label, 'CA136 ENERGY JUMP PASS')[0]
        complete = samples(label, 'CA136 ENERGY LIVE COMPLETE')[0]
        assert rows[-1]['thermalHP'] == 0 and rows[-1]['activity'] == 0
        assert abs(jump['actual'] - jump['expected']) < 0.00001
        assert complete['meleeJ'] > 0 and complete['meleeJ'] % 900 == 0
        live[name] = {'jump': jump, 'last_sample': rows[-1],
                      'primary_greatsword_attacks': int(complete['meleeJ'] / 900)}
    assert live['normal-b']['jump']['actual'] == live['high-a']['jump']['actual']
    swim = {}
    for name in ['normal-a', 'high-a']:
        rows = samples('energy-swim-' + name, 'CA136 HEAT sec=')
        assert rows[-1]['activity'] == rows[-1]['damage'] == rows[-1]['rescues'] == 0
        assert any(abs(r['activity'] - 477.945292) < 0.00001 for r in rows)
        assert abs(max(r['activity'] for r in rows) - 860.301526) < 0.00001
        swim[name] = {'maximum_watts': max(r['activity'] for r in rows), 'last_sample': rows[-1]}
    blocks = {}
    for name in ['normal-a', 'high-a']:
        label = 'energy-block-' + name
        active = samples(label, 'CA136 ENERGY BLOCK ACTIVE PASS')[0]
        end = samples(label, 'CA136 ENERGY BLOCK COMPLETE')[0]
        assert abs(active['actual'] - active['expected']) < 0.000001
        assert end['activity'] == end['thermalHP'] == 0
        blocks[name] = {'active': active, 'last_sample': end}
    assert blocks['normal-a']['active']['actual'] == blocks['high-a']['active']['actual']

    power = json.loads((ROOT / 'build/issue140/power-136-energy.json').read_text(encoding='utf-8-sig'))
    assert power['released_utc'] and power['active_plan_before'] == power['active_plan_after']
    (HERE / 'ENERGY_POWER.json').write_text(json.dumps(power, indent=2) + '\n', encoding='utf-8')
    validation = subprocess.run([sys.executable, str(ROOT / 'validate_project.py')],
                                cwd=ROOT, capture_output=True, check=True)
    (HERE / 'ENERGY_VALIDATOR.json').write_bytes(validation.stdout)
    subprocess.run(['git', 'diff', '--check'], cwd=ROOT, check=True)
    save_paths = ['heat-followup/calor-136-original.zds', 'heat-followup/calor-136-highstats-original.zds',
                  'ca136-energy-old.zds', 'ca136-energy-new.zds']
    payload_hashes = {name: sha(data) for name, data in source.items()}
    report = {'issue': 136, 'release': '5.1.7', 'baseline_commit': BASELINE,
              'contract': 'Fixed work, 25 percent efficiency, heat = 3 * work; Type-2 adaptation',
              'packages': packages, 'previous_measured_package_sha256': prior_hash,
              'baseline_package_sha256': baseline_hash, 'source_members': len(source),
              'payload_sha256': sha(json.dumps(payload_hashes, sort_keys=True).encode()),
              'native_runs': runs, 'live_cases': live, 'swimming': swim, 'blocking': blocks,
              'save_sha256': {name: sha((OUT / name).read_bytes()) for name in save_paths},
              'validator': json.loads(validation.stdout), 'power_released': power['released_utc'],
              'author_acceptance_pending': ['CA136-01', 'CA136-02', 'CA143-01']}
    (HERE / 'ENERGY_MANIFEST.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'native_runs': len(runs), 'source_members': len(source),
                      'errors': [], 'power_released': True}))


if __name__ == '__main__':
    main()
