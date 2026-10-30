"""Archive bounded native #431 evidence, retaining failures and metric limits."""
from pathlib import Path
import gzip
import hashlib
import io
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
OUT = ROOT / 'build/issue431'
ARCHIVE = HERE / 'evidence'
ARCHIVE.mkdir(exist_ok=True)


def archive(path):
    data = path.read_bytes()
    target = ARCHIVE / (path.name + '.gz')
    stream = io.BytesIO()
    with gzip.GzipFile(filename='', fileobj=stream, mode='wb', mtime=0) as zipped:
        zipped.write(data)
    target.write_bytes(stream.getvalue())
    return {'file': str(target.relative_to(HERE)), 'source_sha256': hashlib.sha256(data).hexdigest()}


def main():
    names = ['current-siege-profile-a', 'current-siege-profile-b', 'current-complete',
             'current-siege', 'reduced5-siege', 'simplified-siege', 'full35-siege',
             'current-mansion', 'current-sewers', 'current-city', 'current-ground',
             'display-mansion', 'display-sewers', 'display-city', 'display-ground',
             'display-siege', 'current-contacts', 'current-surfaces'] + [
             'present-'+scene for scene in ('mansion','sewers','city','ground','siege')]
    result = {'baseline_commit': 'd1ae50345cb5b95d00da32f7a17467e51a0e0e58',
        'issue': 431, 'release': '5.11.0', 'production_gameplay_changed': False, 'runtime_label_changes': 2,
        'author_acceptance': False, 'runs': {}, 'thermal_accuracy': {}}
    for name in names:
        path = OUT / 'performance' / (name + '.json')
        if not path.is_file():
            continue
        entry = json.loads(path.read_text())
        log = path.with_suffix('.log')
        if log.is_file():
            text = log.read_text(encoding='utf-8', errors='replace')
            entry['log'] = archive(log)
            entry['scopes'] = [dict(label=label,calls=int(calls),inclusive_ms=float(inc),exclusive_ms=float(exc))
                for label,calls,inc,exc in re.findall(r'CA511 SCOPE (\w+) calls=(\d+) inclusive_ms=([\d.]+) exclusive_ms=([\d.]+)',text)]
            entry['profile_depth'] = re.findall(r'CA511 PROFILE_END depth=(\d+)', text)
            entry['native_completed'] = 'CA510 RESULT' in text
            entry['environment'] = [line for line in text.splitlines() if line.startswith(
                ('OS:', 'GZDoom version', 'Vulkan device:', 'Vulkan version:', 'Resolution:', '  Name:'))]
        for suffix in ('.ini','.cfg'):
            config = path.with_suffix(suffix)
            if config.is_file():
                entry[suffix[1:]] = archive(config)
        result['runs'][name] = entry
    for name in ('current','simplified'):
        path = OUT / 'accuracy' / (name + '.log')
        if not path.is_file():
            continue
        text = path.read_text(encoding='utf-8',errors='replace')
        rows = []
        for line in text.splitlines():
            if not line.startswith('CA511 THERMAL '):
                continue
            row = {key:float(value) for key,value in re.findall(r'(\w+)=([-\d.]+)',line)}
            row['case'] = int(row['case']);row['interval'] = int(row['interval'])
            rows.append(row)
        result['thermal_accuracy'][name] = {'rows':rows,'log':archive(path),
            'completed':'CA511 RESULT' in text,'failures':[line for line in text.splitlines() if 'CA511 FAIL' in line]}
    result['limitations'] = [
        'Profiled scopes include instrumentation overhead; nested inclusive scopes must not be summed.',
        'Current ordinary NPC thermal cadence is 35 tics, not every tic; forced surfaces remain earlier.',
        'full35/reduced5 alter the shared thermal AND contamination schedule. Their gains are not isolated heat-model gains.',
        'Simplified and frequency variants are diagnostic only and are not approved production changes.',
        'RenderOverlay intervals are not display presents. Separate ETW capture reports its own coverage and tails.',
        'The campaign reinforcement window changes its living census; no fixed 1600 claim or retired stress case.',
        'Pure thermal cases compare conserved elapsed time, transition flushes, exposure, moisture, hydration, damage and activity.'
    ]
    (HERE / 'summary.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'runs':len(result['runs']),'accuracy':{k:len(v['rows']) for k,v in result['thermal_accuracy'].items()}}))


if __name__ == '__main__':
    main()
