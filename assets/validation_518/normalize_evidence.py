"""Normalize whitespace in tracked text copies; retain original local native evidence."""
from pathlib import Path
import hashlib, json

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue137'


def main():
    records = []
    for path in sorted(list(HERE.glob('*.ini')) + list(HERE.glob('*.txt'))):
        raw = path.read_bytes()
        original = raw.decode('utf-8-sig')
        normalized = '\n'.join(line.rstrip(' \t') for line in original.splitlines()).rstrip('\n') + '\n'
        data = normalized.encode('utf-8')
        if data == raw:
            continue
        local = WORK / path.name
        records.append({'file': path.name, 'original_copy_sha256': hashlib.sha256(raw).hexdigest(),
                        'normalized_sha256': hashlib.sha256(data).hexdigest(),
                        'raw_local_file_retained': local.is_file()})
        path.write_bytes(data)
    if records:
        manifest = HERE / 'TEXT_NORMALIZATION.json'
        previous = json.loads(manifest.read_text(encoding='utf-8'))['files'] if manifest.exists() else []
        previous_by_name = {r['file']: r for r in previous}
        for record in records:
            old = previous_by_name.get(record['file'])
            if old is None or old['normalized_sha256'] != record['normalized_sha256']:
                previous_by_name[record['file']] = record
        records = list(previous_by_name.values())
        manifest.write_text(json.dumps({
            'policy': 'UTF-8, LF, no trailing spaces or extra EOF blank lines in repository copies; values and log content unchanged. Original native files remain local.',
            'files': records}, indent=2) + '\n', encoding='utf-8')
    print(f'Normalized {len(records)} text copies; no native PNG, video or game file changed.')


if __name__ == '__main__':
    main()
