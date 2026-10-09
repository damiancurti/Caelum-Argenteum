"""Collect the #152 hand follow-up without replacing initial test history."""
from collections import Counter
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue152'
LABELS = ('hands-followup-a', 'hands-followup-save')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def write_json(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def main():
    normalization = []
    for label in LABELS:
        for suffix in ('.txt', '.ini', '-run.json', '-exec.cfg'):
            p = WORK / (label + suffix)
            raw = p.read_bytes()
            normalized = ('\n'.join(line.rstrip() for line in
                          raw.decode('utf-8-sig').splitlines()).rstrip('\n') + '\n').encode('utf-8')
            (HERE / p.name).write_bytes(normalized)
            normalization.append({'file': p.name, 'raw_sha256': digest(raw),
                                  'normalized_sha256': digest(normalized)})
        for p in WORK.glob(label + '-*.png'):
            (HERE / p.name).write_bytes(p.read_bytes())
        record = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8'))
        assert record['exit_code'] == 0, label
        log = (HERE / (label + '.txt')).read_text(encoding='utf-8')
        for error in ('CA152 FAIL', 'Script error', 'VM execution aborted'):
            assert error not in log, (label, error)
    write_json('HANDS_NORMALIZATION.json', normalization)

    log = (HERE / 'hands-followup-a.txt').read_text(encoding='utf-8')
    assert 'CA152 HANDS COMPLETE' in log
    pattern = (r'CA152 HANDS stage=(\d+) tier=(\d+) kind=(\d+) aim=(\d+) '
               r'reload=(\d+) remaining=([\d.]+) layers=([\d,]+)')
    rows = re.findall(pattern, log)
    assert rows
    # Observe actual native overlays, with the full hand pair on just one side.
    for stage, tier, kind, aim, reload, remaining, layers in rows:
        if kind == '14':
            expected = {'1,1,0'} if aim == '1' else {'0,1,0', '0,0,1'}
            assert layers in expected, (stage, tier, aim, reload, layers)
            if reload == '0' and aim == '0':
                assert layers == '0,1,0'
    for stage in ('0', '3', '4'):
        assert any(r[0] == stage and r[6] == '0,0,1' for r in rows), stage
    assert any(r[3] == '1' and r[6] == '1,1,0' for r in rows)
    for stage, tier in (('5', '2'), ('6', '3'), ('8', '1')):
        assert any(r[0] == stage and r[1] == tier and r[6] == '0,1,0' for r in rows)
    assert all(r[6] == '0,0,0' for r in rows if r[0] == '10')
    assert any(r[0] == '10' for r in rows)
    groups = Counter((r[0], r[1], r[2], r[3], r[4], r[6]) for r in rows)
    screenshots = sorted(p.name for p in HERE.glob('hands-followup-a-hands-*.png'))
    assert len(screenshots) == 14
    saved = (HERE / 'hands-followup-save.txt').read_text(encoding='utf-8')
    for kind, amount in (('Carbine', 895), ('Shotgun', 1081)):
        assert (f'class=Caelum{kind}Ammo owner=1 amount={amount} special=0 '
                'nosector=1 noblockmap=1') in saved
    write_json('HAND_CHECKS.json', {
        'native_runs': list(LABELS), 'sample_count': len(rows),
        'layer_order': [48, 49, 51],
        'groups': [{'stage_tier_kind_aim_reload_layers': key, 'samples': count}
                   for key, count in groups.items()],
        'captures': screenshots, 'preserved_shells': 1081, 'preserved_bullets': 895,
        'qualification': 'Weapon switching retains lowering overlays briefly. '
                         'Final dagger samples are clear; author artwork acceptance remains pending.'})

    outputs = ('src/graphics/caelum/shotgun.textures',
               'assets/source/art/shotgun_517/REGISTRATION.json')
    original = {p: (ROOT / p).read_bytes() for p in outputs}
    for _ in range(2):
        subprocess.run(['python', 'assets/generators/register_shotgun.py'], cwd=ROOT, check=True)
        assert all((ROOT / p).read_bytes() == original[p] for p in outputs)
    source = ROOT / 'assets/source/art/shotgun_517/hands_domingo.png'
    runtime = ROOT / 'src/graphics/caelum/shotgun/hands_domingo.png'
    assert source.read_bytes() == runtime.read_bytes()
    write_json('HANDS_DETERMINISM.json', {
        'generator': 'assets/generators/register_shotgun.py', 'two_runs_identical': True,
        'outputs': {p: digest(original[p]) for p in outputs},
        'selected_source_equals_runtime': True, 'selected_png_sha256': digest(source.read_bytes())})

    power = json.loads((ROOT / 'build/issue140/power-152-hands.json').read_text(encoding='utf-8-sig'))
    assert power['release_result'] and power['active_plan_before'] == power['active_plan_after']
    write_json('power-152-hands.json', power)
    package = ROOT / 'build/caelum_argenteum_dev.pk3'
    package_hash = digest(package.read_bytes())
    with zipfile.ZipFile(package) as z:
        assert len(z.namelist()) == 6294
        for name in z.namelist():
            assert z.read(name) == (ROOT / 'src' / name).read_bytes(), name
    for label in LABELS:
        record = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8'))
        assert record['package_sha256'].lower() == package_hash
    check = subprocess.run(['python', 'validate_project.py'], cwd=ROOT,
                           capture_output=True, check=True)
    (HERE / 'hands-static-validation.txt').write_bytes(check.stdout.replace(b'\r\n', b'\n'))
    previous = json.loads((HERE / 'DELIVERY.json').read_text(encoding='utf-8'))
    initial = previous.get('initial_delivery', previous)
    write_json('DELIVERY.json', {
        'release': '5.1.9', 'issue': 152, 'package_sha256': package_hash,
        'files': 6294, 'all_entries_match_src': True, 'native_final': list(LABELS),
        'validation': json.loads(check.stdout), 'initial_delivery': initial,
        'accepted_author_checks': {'date': '2026-10-09', 'ids': ['CA152-01', 'CA152-03']},
        'pending_author_checks': ['CA152-02'], 'temporary_power_request_released': True})
    print('Collected hand follow-up: 14 captures, native layers/save, deterministic export and final package.')


if __name__ == '__main__':
    main()
