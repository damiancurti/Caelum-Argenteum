"""Record the guard/jump revision, keeping earlier art and failures separate."""
from pathlib import Path
from zipfile import ZipFile
import json
import re
from record_evidence import read, digest

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent


def main():
    runtime = ROOT/'build/issue283-motion-02/production.pk3'
    members = {p.relative_to(ROOT/'src').as_posix():p.read_bytes()
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    for path in [runtime, ROOT/'build/caelum_argenteum_dev.pk3']:
        with ZipFile(path) as archive:
            assert set(archive.namelist()) == set(members)
            assert all(archive.read(name) == data for name,data in members.items())
    groups = {
        'issue283-motion-01': ['guard','jump','jump-guard','jump-damage'],
        'issue283-motion-02': ['jump-save','jump-load','jump-held-damage','jump-stun',
                              'actions','rest','death','fallback','save','load','travel',
                              'migrate','jump-attack','jump-travel'],
        'issue283-motion-rollback': ['rollback-02'],
    }
    runs, captures = [], []
    for directory, labels in groups.items():
        work = ROOT/'build'/directory
        for label in labels:
            log, record = work/(label+'.txt'), work/(label+'-run.json')
            text, run = read(log), json.loads(read(record))
            result = re.search(r'CA283 DONE passes=(\d+) failures=0',text)
            assert result and run['exit_code'] == 0, (directory,label)
            assert not re.search(r'CA283 FAIL|Script error|VM execution aborted|JIT error',text)
            if directory != 'issue283-motion-rollback':
                assert run['runtime_sha256'].lower() == digest(runtime)
            runs.append({'label':label,'assertions':int(result[1]),
                         'log':log.relative_to(ROOT).as_posix(),'log_sha256':digest(log),
                         'record_sha256':digest(record),'runtime_sha256':run['runtime_sha256'].lower(),
                         'fixture_sha256':run['fixture_sha256'].lower()})
            for name in re.findall(r'Captured ([^\r\n]+\.png)',text):
                path = work/name
                captures.append({'file':path.relative_to(ROOT).as_posix(),'sha256':digest(path)})
    static = json.loads(read(ROOT/'build/issue283-guard-jump-project-validation.json'))
    assert not static['errors'], static['errors']
    export = json.loads(read(ROOT/'build/issue283-guard-jump-export-validation.json'))
    geometry = json.loads(read(HERE/'guard-jump-geometry.json'))
    assert geometry['source_sha256'] == digest(ROOT/'assets/source/art/domingo_3d_pilot/domingo.blend')
    assert export['md3_sha256'] == digest(ROOT/'src/models/caelum/domingo/domingo.md3')
    assert export['deterministic_files'] == 7
    failures = []
    for relative, reason in [
        ('build/issue283-motion-01/jump-save.txt','Fixture quit before deferred save/event completion; corrected wait in motion-02.'),
        ('build/issue283-final-15/motion-rollback.txt','Old fixture expected revision 1 rather than the persisted revision 2. Seven body/resource checks passed. rollback-02 changes only that test expectation.')]:
        path = ROOT/relative
        failures.append({'log':relative,'sha256':digest(path),'reason':reason})
    report = {'issue':283,'release':'5.4.23','status':'Guard/jump implemented; CA283-02 pending',
              'runtime_sha256':digest(runtime),'normal_build_sha256':digest(ROOT/'build/caelum_argenteum_dev.pk3'),
              'source_members':len(members),'native_runs':len(runs),
              'native_assertions':sum(run['assertions'] for run in runs),'runs':runs,'captures':captures,
              'geometry':geometry,'export':export,'static_errors':0,'context_words':static['context_words'],
              'preserved_failures':failures,
              'save_scope':'Unmodified revision-1 pilot save migrates and resaves at revision 2; current pending-jump save resumes; map travel cancels it. Resting migrated save also loads in the original runtime with its old fixture version expectation corrected. No claim for downgrading an active new animation.',
              'limitations':['Provisional CA283-01 acceptance covers prior art; CA283-02 is not yet accepted.',
                             'Interchangeable runtime parts and timed rest/provision animations remain open.',
                             'Older rendering measurements belong to their original builds; no new large-battle claim.',
                             'Native captures and development packages stay local under build.']}
    (HERE/'guard-jump-evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({key:report[key] for key in ['native_runs','native_assertions','source_members','static_errors']}))


if __name__ == '__main__':
    main()
