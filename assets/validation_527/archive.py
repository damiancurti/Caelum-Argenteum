"""Archive selected successful runs, retaining raw hashes and actual image sizes."""
from pathlib import Path
import hashlib
import json
import struct

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue189'
LABELS = ('menus-final-es', 'menus-final-wide', 'menus-final-ultrawide',
          'actions-final', 'dialogue-final', 'previous-save-02',
          'regression-final', 'lifecycle-final', 'input-edges-final',
          'physical-01', 'physical-dialogue-01')


def main():
    out = HERE / 'logs'
    out.mkdir(exist_ok=True)
    runs = []
    for label in LABELS:
        record = json.loads((WORK / (label + '-run.json')).read_text(encoding='utf-8-sig'))
        raw = (WORK / (label + '.txt')).read_bytes()
        text = raw.decode('utf-8-sig', errors='replace')
        record['raw_log_sha256'] = hashlib.sha256(raw).hexdigest()
        record['completed'] = 'CA189 DONE failures=0' in text
        record['passes'] = text.count('CA189 PASS')
        record['failures'] = text.count('CA189 FAIL')
        record['fatal'] = any(s in text for s in ('VM execution aborted', 'Script error',
            'Unable to resolve', 'errors while parsing', 'DIED WITH FATAL ERROR'))
        if not record['completed'] or record['failures'] or record['fatal']:
            raise RuntimeError(f'Unsuccessful run: {label}')
        if label.startswith('physical-'):
            record['termination'] = 'Owned PID deliberately stopped after physical checks; fixture completed first.'
        elif record.get('exit_code') != 0:
            raise RuntimeError(f'Nonzero exit: {label}')
        lines = ['[Vulkan capability list omitted; original-byte hash retained.]'
                 if line.startswith('Vulkan extensions:') else line.rstrip()
                 for line in text.splitlines()]
        (out / (label + '.txt')).write_text('\n'.join(lines).rstrip() + '\n', encoding='utf-8')
        runs.append(record)
    captures = []
    for path in sorted((HERE / 'captures').rglob('*.png')):
        raw = path.read_bytes()
        width, height = struct.unpack('>II', raw[16:24])
        if path.parent.name == 'es-1024x768':
            run = 'menus-final-es'
        elif path.parent.name == 'en-1600x675':
            run = 'menus-final-ultrawide'
        elif path.name.startswith('ca189-cards-'):
            run = 'regression-final'
        elif path.name == 'ca189-skip-reload.png':
            run = 'lifecycle-final'
        else:
            run = 'dialogue-final'
        captures.append({'file': path.relative_to(HERE).as_posix(), 'width': width,
                         'height': height, 'run': run, 'sha256': hashlib.sha256(raw).hexdigest()})
    (HERE / 'RUNS.json').write_text(json.dumps(runs, indent=2) + '\n', encoding='utf-8')
    (HERE / 'CAPTURES.json').write_text(json.dumps(captures, indent=2) + '\n', encoding='utf-8')
    (HERE / 'manifest.json').write_bytes((WORK / 'manifest.json').read_bytes())
    for run in runs:
        print(f"{run['label']}: {run['passes']} passes; zero failures")


if __name__ == '__main__':
    main()
