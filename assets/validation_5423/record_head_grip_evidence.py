"""Record the #283 head/hair/grip candidate separately from older art trials."""
from pathlib import Path
from zipfile import ZipFile
import json
import re

from record_evidence import read, digest

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
WORK = ROOT / 'build/issue283-head-grip-02'


def main():
    runtime = WORK / 'production.pk3'
    current = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
               for p in (ROOT / 'src').rglob('*') if p.is_file()}
    for path in (runtime, ROOT / 'build/caelum_argenteum_dev.pk3'):
        with ZipFile(path) as archive:
            assert set(archive.namelist()) == set(current)
            assert all(archive.read(name) == data for name, data in current.items())
    runs = []
    captures = []
    intervals = []
    for label in ('actions', 'motion', 'camera', 'rest', 'preview', 'death-console',
                  'bench-64-0', 'bench-64-1'):
        log = WORK / (label + '.txt')
        record = WORK / (label + '-run.json')
        text = read(log)
        run = json.loads(read(record))
        result = re.search(r'CA283 DONE passes=(\d+) failures=0', text)
        assert result and run['exit_code'] == 0, label
        assert not re.search(r'CA283 FAIL|Script error|VM execution aborted|JIT error', text), label
        assert run['runtime_sha256'].lower() == digest(runtime)
        runs.append({'label': label, 'assertions': int(result[1]),
                     'log': log.relative_to(ROOT).as_posix(), 'log_sha256': digest(log),
                     'record_sha256': digest(record), 'fixture_sha256': run['fixture_sha256'].lower()})
        for name in re.findall(r'Captured ([^\r\n]+\.png)', text):
            path = WORK / name
            captures.append({'file': path.relative_to(ROOT).as_posix(), 'sha256': digest(path)})
        sample = re.search(r'CA283 RENDER count=(\d+) model=(\d+) frames=(\d+) mean_ms=([\d.]+) min_ms=([\d.]+) max_ms=([\d.]+)', text)
        if sample:
            intervals.append(dict(zip(('count', 'model', 'frames', 'mean_ms', 'min_ms', 'max_ms'),
                                      (int(sample[1]), bool(int(sample[2])), int(sample[3]),
                                       float(sample[4]), float(sample[5]), float(sample[6])))))
    static = json.loads(read(ROOT / 'build/issue283-head-grip-project-validation.json'))
    assert not static['errors'], static['errors']
    geometry = json.loads(read(HERE / 'head-grip-geometry.json'))
    assert geometry['source_sha256'] == digest(ROOT / 'assets/source/art/domingo_3d_pilot/domingo.blend')
    export = json.loads(read(ROOT / 'build/issue283-head-grip-export-validation.json'))
    assert export['deterministic_files'] == 7
    assert export['md3_sha256'] == digest(ROOT / 'src/models/caelum/domingo/domingo.md3')
    report = {'issue': 283, 'release': '5.4.23', 'status': 'Human head, layered hair and running grip; author review pending',
              'runtime_sha256': digest(runtime), 'source_members': len(current),
              'normal_build_sha256': digest(ROOT / 'build/caelum_argenteum_dev.pk3'),
              'native_runs': len(runs), 'native_assertions': sum(run['assertions'] for run in runs),
              'runs': runs, 'captures': captures, 'geometry': geometry, 'export': export,
              'static_errors': 0, 'context_words': static['context_words'], 'frame_intervals': intervals,
              'prior_evidence': 'Earlier foundation/anatomy/arm-motion records describe their own preserved builds, not this model.',
              'preserved_candidate': 'head-grip-01 passed six functional runs; native review found flat hair detail, corrected through UV sampling in head-grip-02.',
              'limitations': ['Not overall #283 acceptance; modular parts and timed/block/jump animations remain open.',
                              '64 non-combat render proxies measure local frame intervals, not large-battle performance.',
                              'Native captures stay in build because the isolated fixture uses a development IWAD.']}
    (HERE / 'head-grip-evidence.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps({key: report[key] for key in ('native_runs', 'native_assertions', 'runtime_sha256', 'static_errors')}))
    print(json.dumps(intervals))


if __name__ == '__main__':
    main()
