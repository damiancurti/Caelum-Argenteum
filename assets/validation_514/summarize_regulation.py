"""Collect bounded native #140 observations without reclassifying lethal controls."""
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
PREFIXES = ('CA140 GREATSWORD_PROFILE', 'CA140 MAGIC_PROFILE', 'CA140 POOL_EXIT',
            'CA140 GREATSWORD_COMPLETE', 'CA140 MAGIC_COMPLETE',
            'CA140 CARBINE_PROFILE', 'CA140 CARBINE_COMPLETE', 'CA140 DRYING')
LABELS = ('carbine-heat-a', 'carbine-heat-b', 'carbine-heat-c', 'greatsword-heat-b',
          'greatsword-regulated-a', 'greatsword-paced-a', 'pool-wet-a',
          'pool-dry-a', 'pool-wet-c', 'mage-fire-cloth-a', 'mage-ice-leather-a',
          'mage-fire-base-a', 'mage-ice-medium-a', 'immersion-drying-a')


def main():
    report = {'issue': 140, 'release': '5.1.4', 'runs': {}}
    for label in LABELS:
        path = HERE / (label + '.txt')
        if not path.exists():
            raise SystemExit(f'Missing completed evidence: {label}')
        run = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        assert 'completed_utc' in run, label
        records = []
        for line in path.read_text(encoding='utf-8').splitlines():
            if not line.startswith(PREFIXES):
                continue
            fields = {key: float(value) for key, value in
                      re.findall(r'([A-Za-z][A-Za-z0-9]*)=(-?[0-9]+(?:\.[0-9]+)?)', line)}
            records.append({'marker': line.split(' ', 2)[1], 'values': fields})
        report['runs'][label] = {'package_sha256': run['package_sha256'],
                                'log_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                                'records': records}
    report['qualifications'] = [
        'Before-regulation lethal controls are reproduced defects, not survival passes.',
        'carbine-heat-b allowed late native pursuit/melee; carbine-heat-c freezes state progression while retaining Tick/resources/reload to isolate firearm work.',
        'Initial fire-cloth cast flag was reset by repeated attack requests; its zero cast counter is invalid. Anima consumption establishes activity; later runs count individual Anima debits.',
        'pool-wet-b was cancelled after uncommanded attacks; it is excluded.',
        'Greatsword final full HP can hide earlier thermal damage followed by natural healing.',
        'These are bounded temperate cases with finite reserves, not universal armor/weather immunity.',
        'Spellcasting does not automatically deposit the outgoing elemental energy in the caster.',
    ]
    (HERE / 'REGULATION_RESULTS.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'Collected {len(report["runs"])} qualified native observations.')


if __name__ == '__main__':
    main()
