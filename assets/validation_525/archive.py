"""Preserve bounded native logs, run metadata and original-byte hashes."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
WORK = HERE.parents[1] / 'build/issue185'
OUT = HERE / 'logs'
OUT.mkdir(exist_ok=True)
runs = []
for metadata in sorted(WORK.glob('*-run.json')):
    record = json.loads(metadata.read_text(encoding='utf-8-sig'))
    log = WORK / (record['label'] + '.txt')
    raw = log.read_bytes()
    text = raw.decode('utf-8-sig', errors='replace')
    record['raw_log_sha256'] = hashlib.sha256(raw).hexdigest()
    record['passes'] = text.count('CA185 PASS') + text.count('CA183 PASS')
    record['failures'] = text.count('CA185 FAIL') + text.count('CA183 FAIL')
    record['fatal'] = 'VM execution aborted' in text or 'Script error' in text
    (OUT / log.name).write_text('\n'.join(line.rstrip() for line in text.splitlines()).rstrip() + '\n', encoding='utf-8')
    runs.append(record)
(HERE / 'runs.json').write_text(json.dumps(runs, indent=2) + '\n', encoding='utf-8')
(HERE / 'manifest.json').write_bytes((WORK / 'manifest.json').read_bytes())
print(f'Archived {len(runs)} native runs; original log hashes preserved.')
