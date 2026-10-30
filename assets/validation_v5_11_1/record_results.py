"""Archive final formation evidence without including engine or save fixtures."""
from pathlib import Path
import gzip
import hashlib
import io
import json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
OUT = ROOT / 'build/issue429'


def archive(path):
    data = path.read_bytes()
    target = HERE / 'evidence' / (path.name + '.gz')
    target.parent.mkdir(exist_ok=True)
    stream = io.BytesIO()
    with gzip.GzipFile(filename='', fileobj=stream, mode='wb', mtime=0) as zipped:
        zipped.write(data)
    target.write_bytes(stream.getvalue())
    return {'file': str(target.relative_to(HERE)),
            'sha256': hashlib.sha256(data).hexdigest()}


def main():
    result = dict(issue=429, release='5.11.1', author_acceptance=False, runs={})
    labels = ['final-state', 'final-reload', 'final-passage', 'final-migration',
              'due-diagnostic', 'legacy-campaign-b', 'campaign-rollback']
    for label in labels:
        path = OUT / (label + '.json')
        if not path.exists():
            if label == 'campaign-rollback':
                continue
            raise FileNotFoundError(path)
        row = json.loads(path.read_text())
        row['evidence'] = [archive(path.with_suffix(s)) for s in ('.log', '.ini', '.cfg')]
        result['runs'][label] = row
    path = OUT / 'performance/final-siege.json'
    result['performance'] = json.loads(path.read_text())
    result['performance']['log'] = archive(path.with_suffix('.log'))
    result['limits'] = ['Author checks deferred until all V5.11 work is ready.',
        'Render callbacks are not frame presentation.',
        'Revised population accounting changes the comparison census.',
        'Large-siege stalls remain; optimization work is tracked separately.']
    (HERE / 'summary.json').write_bytes((json.dumps(result, indent=2) + '\n').encode())


if __name__ == '__main__':
    main()
