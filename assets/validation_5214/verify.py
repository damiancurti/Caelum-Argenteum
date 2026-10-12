"""Verify retained native config evidence and deterministic control outputs."""
from pathlib import Path
import configparser
import hashlib
import json
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue149'


def read_config(label):
    config = configparser.RawConfigParser(strict=False)
    config.optionxform = str
    config.read(WORK / (label + '.ini'), encoding='utf-8-sig')
    return config


def main():
    if '--prepare-legacy' in sys.argv:
        config = read_config('persist-01')
        config['Doom.CaelumArgenteumControls.Bindings'] = {
            key: config['Doom.Bindings'].pop(key) for key in ['J', 'Q', 'F5']}
        config['Doom.CaelumArgenteumControls.DoubleBindings'] = {
            'Mouse3': config['Doom.DoubleBindings'].pop('Mouse3')}
        with (WORK / 'legacy-source.ini').open('w', encoding='utf-8') as stream:
            config.write(stream, space_around_delimiters=False)
        return
    checks = {}
    with zipfile.ZipFile(ROOT / 'build/caelum_argenteum_dev.pk3') as official, zipfile.ZipFile(WORK / 'production.pk3') as tested:
        checks['official_members_match_tested'] = set(official.namelist()) == set(tested.namelist()) and all(
            official.read(name) == tested.read(name) for name in official.namelist())
        checks['official_member_count'] = len(official.namelist())
    paths = [ROOT / name for name in ['src/KEYCONF', 'src/DEFBINDS', 'assets/playtest/default_controls.cfg']]
    before = {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    subprocess.run([sys.executable, str(ROOT / 'assets/generators/generate_controls.py')], check=True)
    checks['controls_generator_deterministic'] = before == {
        p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    checks['generator_hashes'] = before
    for label in ['persist-01', 'restart-01', 'legacy-01']:
        config = read_config(label)
        expected = {'J': 'ca_journal_toggle', 'Q': '+attack', 'F5': 'ca_time_skip', 'M': 'togglemap'}
        checks[label + '_normal'] = all(config['Doom.Bindings'].get(k) == v for k, v in expected.items())
        checks[label + '_cleared_use'] = '+use' not in config['Doom.Bindings'].values()
        checks[label + '_double'] = config['Doom.DoubleBindings'].get('Mouse3') == '+user2'
        checks[label + '_map'] = config['Doom.AutomapBindings'].get('N') == 'am_setmark'
        if label == 'legacy-01':
            checks[label + '_legacy_empty'] = all(not dict(config['Doom.CaelumArgenteumControls.' + suffix])
                                                 for suffix in ['Bindings', 'DoubleBindings'])
    checks['failures'] = [key for key, value in checks.items() if value is False]
    (HERE / 'summary.json').write_text(json.dumps(checks, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(checks, indent=2))
    if checks['failures']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
