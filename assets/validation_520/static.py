"""Focused preservation audit for #147; native evidence remains separate."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue147'
BASE = 'f7c4a0dd'


def original(name):
    return subprocess.check_output(['git', 'show', f'{BASE}:{name}'], cwd=ROOT).decode('utf-8-sig').replace('\r\n', '\n')


def current(name):
    return (ROOT / name).read_text(encoding='utf-8-sig')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    checks = {}
    unchanged = ['character/CaelumCharacterProfile.zs', 'character/CaelumCharacterAllocation.zs',
                 'attributes/CaelumAttributes.zs', 'statistics/CaelumGrowthRules.zs',
                 'core/CaelumConstants.zs']
    checks['approved_identity_and_stat_rules_unchanged'] = all(
        current('src/caelum/' + name) == original('src/caelum/' + name) for name in unchanged)
    descriptions = re.compile(r'^(CA_(?:CREATE|RACE|CLASS|PROFESSION|LAYER|ATTRIBUTE)_[A-Z0-9_]+)\s*=.*$', re.M)
    checks['all_existing_creation_descriptions_preserved'] = descriptions.findall(current('src/LANGUAGE')) == descriptions.findall(original('src/LANGUAGE'))
    old_lines = [v for v in original('src/LANGUAGE').splitlines() if descriptions.match(v)]
    new_lines = [v for v in current('src/LANGUAGE').splitlines() if descriptions.match(v)]
    checks['creation_description_text_bytes_preserved'] = old_lines == new_lines
    for prefix in ['alias ', 'defaultbind ']:
        checks[prefix.strip() + '_commands_preserved'] = (
            [v for v in current('src/KEYCONF').splitlines() if v.startswith(prefix)] ==
            [v for v in original('src/KEYCONF').splitlines() if v.startswith(prefix)])
    checks['debug_key_rows_removed_with_legacy_import'] = (
        not re.search(r'^addmenukey ', current('src/KEYCONF'), re.M)
        and re.findall(r'^addkeysection .*$', current('src/KEYCONF'), re.M)
        == ['addkeysection "$CA_CONTROL_LEGACY_SECTION" CaelumArgenteumControls'])
    fields = re.compile(r'^    (?:bool|int|double|String|Vector[23]) (\w+)(?:\[.*?\])?;', re.M)
    old_fields = set(fields.findall(original('src/caelum/equipment/CaelumPersistentCharacterState.zs')))
    new_fields = set(fields.findall(current('src/caelum/equipment/CaelumPersistentCharacterState.zs')))
    checks['legacy_saved_fields_retained'] = old_fields <= new_fields
    checks['sole_native_player_class_retained'] = 'PlayerClasses = "CaelumPlayer"' in current('src/MAPINFO')
    checks['accepted_pending_queue_preserved_as_new_single_check'] = current('pending_test.txt').startswith('CA147-01 | 5.2.0 | #147')

    audit = {}
    pattern = re.compile(r'CharacterProfile|CharacterAllocation|IdentityProfile|IdentityAllocation|ca_newchar_|Player\.(?:DisplayName|ColorRange|SoundClass)|\b(?:GetGender|GetSkin|bNoSkin)\b')
    for path in sorted((ROOT / 'src').rglob('*')):
        if not path.is_file() or path.suffix.lower() not in {'.zs', ''}:
            continue
        try:
            lines = path.read_text(encoding='utf-8-sig').splitlines()
        except UnicodeError:
            continue
        hits = [{'line': i + 1, 'source': line.strip()} for i, line in enumerate(lines) if pattern.search(line)]
        if hits:
            audit[path.relative_to(ROOT).as_posix()] = hits
    (HERE / 'identity-audit.json').write_text(json.dumps({'baseline': BASE, 'scope': 'Custom identity references, CVars and native presentation hooks; ownership contract in SYSTEMS.', 'files': audit}, indent=2) + '\n', encoding='utf-8')

    for variant, old_log in [('a', 'rollback-a-02'), ('b', 'rollback-b-01')]:
        old = (WORK / f'{old_log}.txt').read_text(encoding='utf-8-sig')
        new = (WORK / f'migration-{variant}-01.txt').read_text(encoding='utf-8-sig')
        extract = lambda s: [v for v in s.splitlines() if v.startswith(('CA147 SNAP LOAD', 'CA147 LAYER', 'CA147 ATTRIBUTE', 'CA147 VALUES', 'CA147 ITEM'))]
        checks[f'legacy_{variant}_native_snapshot_exact_match'] = extract(old) == extract(new) and bool(extract(old))
        final = extract((WORK / 'migration-a-delivery.txt').read_text(encoding='utf-8-sig'))
        count = len(extract(old))
        offset = 0 if variant == 'a' else count
        checks[f'legacy_{variant}_final_package_snapshot_exact_match'] = extract(old) == final[offset:offset + count]

    production = WORK / 'production.pk3'
    build = ROOT / 'build/caelum_argenteum_dev.pk3'
    if build.exists():
        with zipfile.ZipFile(production) as a, zipfile.ZipFile(build) as b:
            checks['standard_build_matches_final_native_package'] = set(a.namelist()) == set(b.namelist()) and all(a.read(n) == b.read(n) for n in a.namelist())
    result = {'checks': checks, 'passed': sum(checks.values()), 'failed': [k for k, v in checks.items() if not v],
              'production_sha256': sha(production),
              'original_save_sha256': {p.name: sha(p) for p in WORK.glob('identity-legacy-*-final.zds')}}
    (HERE / 'static.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
    if result['failed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
