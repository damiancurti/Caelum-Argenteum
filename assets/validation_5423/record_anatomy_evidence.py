"""Record the corrective #283 anatomy build separately from foundation evidence."""
from pathlib import Path
from zipfile import ZipFile
import argparse
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent


def read(path):
    data = path.read_bytes()
    return data.decode('utf-16' if data.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--revision', choices=('anatomy', 'arm-motion'), default='anatomy')
    revision = parser.parse_args().revision
    motion = revision == 'arm-motion'
    current = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
               for p in (ROOT / 'src').rglob('*') if p.is_file()}
    runtime = ROOT / ('build/issue283-arm-motion-01/production.pk3' if motion else 'build/issue283-anatomy-03/production.pk3')
    for path in (runtime, ROOT / 'build/caelum_argenteum_dev.pk3'):
        with ZipFile(path) as archive:
            assert set(archive.namelist()) == set(current)
            assert all(archive.read(name) == data for name, data in current.items())
    runs = []
    captures = []
    cases = [('01', 'actions'), ('01', 'camera'), ('01', 'motion')] if motion else [
        ('01', 'actions'), ('01', 'rest'), ('03', 'camera'), ('02', 'death-console'), ('02', 'previous-pilot-save')]
    for directory, label in cases:
        work = ROOT / ('build/issue283-' + revision + '-' + directory)
        log = work / (label + '.txt')
        record = work / (label + '-run.json')
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
            path = work / name
            captures.append({'file': path.relative_to(ROOT).as_posix(), 'sha256': digest(path)})
    static = json.loads(read(ROOT / ('build/issue283-' + revision + '-project-validation.json')))
    assert not static['errors']
    anatomy = json.loads(read(HERE / (revision + '-joints.json')))
    assert anatomy['source_sha256'] == digest(ROOT / 'assets/source/art/domingo_3d_pilot/domingo.blend')
    export = json.loads(read(ROOT / ('build/issue283-' + revision + '-export-validation.json')))
    assert export['deterministic_files'] == 7
    assert export['md3_sha256'] == digest(ROOT / 'src/models/caelum/domingo/domingo.md3')
    report = {'issue': 283, 'release': '5.4.23', 'status': 'Corrective art candidate; author review pending',
              'runtime_sha256': digest(runtime), 'source_members': len(current),
              'normal_build_sha256': digest(ROOT / 'build/caelum_argenteum_dev.pk3'),
              'native_runs': len(runs), 'native_assertions': sum(run['assertions'] for run in runs),
              'runs': runs, 'captures': captures, 'anatomy': anatomy, 'export': export,
              'static_errors': 0, 'context_words': static['context_words'],
              'foundation': 'evidence.json records the earlier 98 assertions at commit 9515fb2c, not this revised model.',
              'preserved_failure': 'build/issue283-anatomy-01/camera.txt exposed a one-tic WorldTick camera lag; actor Tick fixed it.',
              'open': ['Author anatomy/visual acceptance.', 'Interchangeable equipment/hair/face parts.',
                       'Timed rest/provision animations and approved control locks.',
                       'Shield-block animation; one-second jump preparation and landing.']}
    if motion:
        old = ROOT / 'build/issue283-export-08'
        new = ROOT / 'build/issue283-export-10'
        previous = (old / 'domingo.md3').read_bytes()
        current_model = (new / 'domingo.md3').read_bytes()
        manifest = json.loads(read(new / 'manifest.json'))
        old_manifest = json.loads(read(old / 'manifest.json'))
        assert manifest['actions'] == old_manifest['actions']
        surface = struct.unpack_from('<4sI64s9I', current_model)[10]
        header = struct.unpack_from('<4s64s10I', current_model, surface)
        stride = header[5] * 8
        start = surface + header[10]
        unchanged = 0
        for name, action in manifest['actions'].items():
            if name in ('Walk', 'Run'):
                continue
            for frame in range(action['start'], action['start'] + action['count']):
                offset = start + frame * stride
                assert previous[offset:offset + stride] == current_model[offset:offset + stride], name
                unchanged += 1
        report['unchanged_non_locomotion_frames'] = unchanged
        report['status'] = 'Quiet walk / distinct run candidate; author review pending'
        report['prior_anatomy'] = 'anatomy-evidence.json preserves the previous 52 assertions; no new results are attributed to that model.'
    (HERE / (revision + '-evidence.json')).write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps({key: report[key] for key in ('native_runs', 'native_assertions', 'runtime_sha256', 'static_errors')}))


if __name__ == '__main__':
    main()
