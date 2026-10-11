"""Generate an isolated legacy INI and verify native import/restart preservation."""
from pathlib import Path
import configparser
import json
import sys

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue147'
EXPECTED = {'F6': '+user1', 'F7': '+user2', 'F8': '+user3', 'F9': '+user4',
            'F10': 'ca_journal_toggle', 'F11': 'ca_time_skip', 'F12': '+moveup',
            'U': '+movedown', 'O': 'invprev', 'P': 'invnext',
            'K': 'toggle ca_debug_attributes'}


def read(path):
    config = configparser.RawConfigParser(strict=False)
    config.optionxform = str
    config.read(path, encoding='utf-8-sig')
    return config


def main():
    if '--prepare' in sys.argv:
        source = WORK / 'legacy-a-04.ini'
        config = read(source)
        for suffix, values in [('Bindings', EXPECTED), ('DoubleBindings', {'M': 'ca_journal_toggle'})]:
            name = 'Doom.CaelumArgenteumControls.' + suffix
            config[name] = values
        with (WORK / 'legacy-bindings.ini').open('w', encoding='utf-8') as stream:
            config.write(stream, space_around_delimiters=False)
        print('Prepared isolated legacy remaps; original config unchanged.')
        return
    checks = {}
    for label in ['bindings-import', 'bindings-restart']:
        config = read(WORK / (label + '.ini'))
        log = (WORK / (label + '.txt')).read_text(encoding='utf-8-sig')
        checks[label + '_normal'] = all(config['Doom.Bindings'].get(k) == v for k, v in EXPECTED.items())
        checks[label + '_double'] = config['Doom.DoubleBindings'].get('M') == 'ca_journal_toggle'
        checks[label + '_legacy_empty'] = all(not dict(config['Doom.CaelumArgenteumControls.' + suffix])
                                              for suffix in ['Bindings', 'DoubleBindings'])
        # Native console queries prove the bindings were active before shutdown.
        checks[label + '_live'] = all(f'"{k}" = "{v}"' in log for k, v in EXPECTED.items()) and '"M" = "ca_journal_toggle"' in log
    result = {'checks': checks, 'passed': sum(checks.values()), 'failed': [k for k, v in checks.items() if not v]}
    (HERE / 'bindings.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
    if result['failed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
