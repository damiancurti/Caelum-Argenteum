"""Verify retained #150 engine evidence without mutating game state."""
from pathlib import Path
import hashlib
import json
import re
import struct

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue150'
EVIDENCE = WORK if (WORK / 'combat-base-01.txt').exists() else HERE


def read(name):
    return (EVIDENCE / name).read_text(encoding='utf-8-sig')


def main():
    labels = ['compile-02', 'official-01', 'visual-169-01', 'visual-43-02', 'panels-43-01',
              'visual-wide-04', 'extras-03', 'crosshair-01', 'combat-base-01',
              'combat-final-01', 'combat-zero-01', 'combat-high-01', 'persist-01',
              'restart-02', 'legacy-before-01', 'legacy-after-01']
    report = {'baseline': 'b36ef830', 'runs': {}, 'combat': {}, 'dimensions': {}}
    for label in labels:
        text = read(label + '.txt')
        assert 'CA150 DONE failures=0' in text, label
        assert not re.search(r'CA150 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR', text), label
        report['runs'][label] = {'assertions': text.count('CA150 PASS'),
                                'log_sha256': hashlib.sha256((EVIDENCE / (label + '.txt')).read_bytes()).hexdigest()}
    records = {}
    for label in ['combat-base-01', 'combat-final-01', 'combat-zero-01', 'combat-high-01']:
        records[label] = [line for line in read(label + '.txt').splitlines()
                          if line.startswith(('CA150 TRACE', 'CA150 PROJECTILE'))]
    baseline = records['combat-base-01']
    assert sum(line.startswith('CA150 TRACE') for line in baseline) == 474
    assert sum(line.startswith('CA150 PROJECTILE') for line in baseline) == 7
    for label, rows in records.items():
        assert rows == baseline, f'Combat divergence: {label}'
        report['combat'][label] = hashlib.sha256('\n'.join(rows).encode()).hexdigest()
    for name, expected in [('hud-small.png', (1280, 720)),
                           ('panels-43-01-crafting-large.png', (960, 720)),
                           ('visual-wide-04-journal-large.png', (1600, 675))]:
        data = (EVIDENCE / name).read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        size = struct.unpack('>II', data[16:24])
        assert size == expected, (name, size)
        report['dimensions'][name] = size
    # Accepted feedback remains exactly the same source, independent of scale.
    import subprocess
    path = 'src/caelum/hud/CaelumDamageFeedback.zs'
    old = subprocess.check_output(['git', 'show', 'b36ef830:' + path], cwd=ROOT)
    current = (ROOT / path).read_bytes()
    assert old.replace(b'\r\n', b'\n') == current.replace(b'\r\n', b'\n')
    report['damage_feedback_unchanged'] = True
    WORK.mkdir(parents=True,exist_ok=True)
    (WORK / 'summary.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f'PASS: {len(labels)} native runs; 474 states + 7 projectiles match in all four runs; 3 aspect ratios.')


if __name__ == '__main__':
    main()
