"""Collect private #414 evidence without distributing packages, saves or IWADs."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue414-runtime'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    report = {'issue': 414, 'version': '5.8.2', 'packages': {}, 'runs': {}, 'performance': {}}
    for mode in ('current', 'compatibility'):
        package = WORK / mode / 'caelum_argenteum_dev.pk3'
        with zipfile.ZipFile(package) as archive:
            expected = {p.relative_to(ROOT/'src').as_posix(): p for p in (ROOT/'src').rglob('*') if p.is_file()}
            if mode == 'compatibility':
                expected['maps/MAP01.wad'] = ROOT/'assets/map01_mansion/legacy_581/MAP01.wad'
            assert set(archive.namelist()) == set(expected), 'Package membership differs from source'
            for name, path in expected.items():
                assert archive.read(name) == path.read_bytes(), f'Package differs: {mode}/{name}'
        report['packages'][mode] = {'sha256': digest(package), 'entries': len(expected), 'source_bytes_match': True}
    native = HERE / 'native'
    native.mkdir(exist_ok=True)
    for record_path in sorted(WORK.glob('*-run.json')):
        label = record_path.name.removesuffix('-run.json')
        log_path = WORK/(label+'.txt')
        if not log_path.exists():
            continue
        log = log_path.read_text(encoding='utf-8', errors='replace')
        report['runs'][label] = {
            'pass_lines': len(re.findall(r'^CA414R PASS ', log, re.M)),
            'fail_lines': len(re.findall(r'^CA414R FAIL ', log, re.M)),
            'runtime_errors': re.findall(r'^.*(?:Script error|VM execution aborted|Fatal:|Not in a saveable game).*$',
                                        log, re.M),
            'record': json.loads(record_path.read_text(encoding='utf-8-sig')),
        }
        for path in WORK.glob(label+'*'):
            if path.suffix in ('.txt', '.json', '.ini', '.cfg'):
                shutil.copy2(path, native/path.name)
        frames = [float(x) for x in re.findall(r'^CA414R FRAME ([0-9.]+)', log, re.M)]
        timing = re.search(r'CA414R PERF start_ms=([0-9.]+) end_ms=([0-9.]+) tics=(\d+)', log)
        if frames and timing:
            ordered = sorted(frames)
            report['performance'][label] = {
                'samples': len(frames), 'mean_ms': sum(frames)/len(frames),
                'p95_ms': ordered[math.ceil(len(frames)*.95)-1],
                'p99_ms': ordered[math.ceil(len(frames)*.99)-1], 'worst_ms': max(frames),
                'tics_per_second': int(timing[3])*1000/(float(timing[2])-float(timing[1])),
                'scope': 'UI render callbacks only; PresentMon ETW denied, not presentation/GPU timings',
            }
    capture = WORK/'mansion-water-clear.png'
    shutil.copy2(capture, HERE/'mansion-water.png')
    report['capture_sha256'] = digest(capture)
    report['private_saves'] = {p.name: digest(p) for p in WORK.glob('ca414r-*.zds')}
    (HERE/'report.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({'packages': report['packages'], 'performance': report['performance'],
                      'checks': {k: v['pass_lines'] for k, v in report['runs'].items()}}, indent=2))


if __name__ == '__main__':
    main()
