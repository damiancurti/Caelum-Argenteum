"""Record the corrected shield attachment and shorter preparation separately."""
from pathlib import Path
from zipfile import ZipFile
import json
import re
from record_evidence import read, digest

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
WORK = ROOT/'build/issue283-shield-grip-01'


def main():
    runtime = WORK/'production.pk3'
    members = {p.relative_to(ROOT/'src').as_posix():p.read_bytes()
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    for path in [runtime, ROOT/'build/caelum_argenteum_dev.pk3']:
        with ZipFile(path) as archive:
            assert set(archive.namelist()) == set(members)
            assert all(archive.read(name) == data for name,data in members.items())
    runs, captures = [], []
    for label in ['guard','jump','jump-guard','jump-damage','jump-save','jump-load',
                  'jump-attack','jump-travel-03','preview','rest','previous-pilot','camera']:
        log, record = WORK/(label+'.txt'), WORK/(label+'-run.json')
        text, run = read(log), json.loads(read(record))
        done = re.search(r'CA283 DONE passes=(\d+) failures=0',text)
        assert done and run['exit_code'] == 0, label
        assert not re.search(r'CA283 FAIL|Script error|VM execution aborted|JIT error',text)
        assert run['runtime_sha256'].lower() == digest(runtime)
        runs.append({'label':label,'assertions':int(done[1]),'log':log.relative_to(ROOT).as_posix(),
                     'log_sha256':digest(log),'record_sha256':digest(record),
                     'fixture_sha256':run['fixture_sha256'].lower()})
        for name in re.findall(r'Captured ([^\r\n]+\.png)',text):
            path = WORK/name
            captures.append({'file':path.relative_to(ROOT).as_posix(),'sha256':digest(path)})
    geometry = json.loads(read(HERE/'shield-grip-geometry.json'))
    assert geometry['source_sha256'] == digest(ROOT/'assets/source/art/domingo_3d_pilot/domingo.blend')
    export = json.loads(read(ROOT/'build/issue283-shield-grip-export-validation.json'))
    assert export['deterministic_files'] == 7
    assert export['md3_sha256'] == digest(ROOT/'src/models/caelum/domingo/domingo.md3')
    static = json.loads(read(ROOT/'build/issue283-shield-grip-project-validation.json'))
    assert not static['errors'], static['errors']
    failures = [{'log':(WORK/(label+'.txt')).relative_to(ROOT).as_posix(),
                 'log_sha256':digest(WORK/(label+'.txt')),'reason':reason}
                for label,reason in [('jump-travel','Fixture waited until the shortened jump could launch before travel.'),
                                     ('jump-travel-02','Immediate changemap ran before the loaded game was active; native engine rejected the command. jump-travel-03 waits one startup tic.')]]
    report = {'issue':283,'release':'5.4.23','status':'Corrected shield grip and ten-tic jump; CA283-02 pending',
              'runtime_sha256':digest(runtime),'normal_build_sha256':digest(ROOT/'build/caelum_argenteum_dev.pk3'),
              'source_members':len(members),'native_runs':len(runs),
              'native_assertions':sum(r['assertions'] for r in runs),'runs':runs,'captures':captures,
              'geometry':geometry,'export':export,'static_errors':0,'context_words':static['context_words'],
              'preserved_fixture_failures':failures,
              'limitations':['CA283-02 remains pending; positive feedback on the prior jump pose is qualified.',
                             'Modular parts and timed rest/provision transitions remain unfinished.',
                             'Earlier art/native/performance evidence retains its own build scope.']}
    (HERE/'shield-grip-evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['native_runs','native_assertions','source_members','static_errors']}))


if __name__ == '__main__':
    main()
