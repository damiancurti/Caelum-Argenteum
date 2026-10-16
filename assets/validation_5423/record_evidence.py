"""Record completed #283 native runs, unchanged package parity and export checks."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
WORK=ROOT/'build/issue283-final-15'

def read(path):
    data=path.read_bytes()
    return data.decode('utf-16' if data.startswith((b'\xff\xfe',b'\xfe\xff')) else 'utf-8-sig')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    runs=[];frames=[];captures=[]
    labels=['actions','rest','death','death-console','fallback','preview','save','load','travel',
            'bench-clean-1-0','bench-clean-1-1','bench-clean-64-0','bench-clean-64-1']
    for label in labels:
        log=WORK/(label+'.txt');record=WORK/(label+'-run.json')
        text=read(log);run=json.loads(read(record))
        done=re.search(r'CA283 DONE passes=(\d+) failures=0',text)
        assert done and run['exit_code']==0,label
        assert not re.search(r'^CA283 FAIL|^Script error|VM execution aborted|JIT error',text,re.M),label
        runs.append({'label':label,'assertions':int(done[1]),'log':log.relative_to(ROOT).as_posix(),
                     'log_sha256':digest(log),'record_sha256':digest(record),
                     'runtime_sha256':run['runtime_sha256'].lower(),'fixture_sha256':run['fixture_sha256'].lower()})
        found=re.search(r'CA283 RENDER count=(\d+) model=(\d+) frames=(\d+) mean_ms=([\d.]+) min_ms=([\d.]+) max_ms=([\d.]+)',text)
        if found:
            frames.append(dict(zip(['count','model','frames','mean_ms','min_ms','max_ms'],
                                   [int(found[1]),bool(int(found[2])),int(found[3]),float(found[4]),float(found[5]),float(found[6])])))
        for name in re.findall(r'Captured ([^\r\n]+\.png)',text):
            path=WORK/name
            captures.append({'file':path.relative_to(ROOT).as_posix(),'sha256':digest(path)})
    oldlog=ROOT/'build/issue282-final-06/issue283-final-old-save.txt'
    oldrecord=oldlog.with_name('issue283-final-old-save-run.json')
    oldtext=read(oldlog);old=json.loads(read(oldrecord))
    assert 'CA282 DONE passes=2 failures=0' in oldtext and old['exit_code']==0
    runs.append({'label':'genuine-5.4.22-save','assertions':2,'log':oldlog.relative_to(ROOT).as_posix(),
                 'log_sha256':digest(oldlog),'record_sha256':digest(oldrecord),
                 'runtime_sha256':old['runtime_sha256'].lower(),'fixture_sha256':old['fixture_sha256'].lower()})
    with ZipFile(WORK/'production.pk3') as archive:
        current={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(archive.namelist())==set(current)
        assert all(archive.read(name)==data for name,data in current.items())
        members=len(current)
    with ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as archive:
        assert set(archive.namelist())==set(current)
        assert all(archive.read(name)==data for name,data in current.items())
    static=json.loads(read(ROOT/'build/issue283-project-validation-final.json'))
    assert not static['errors'],static['errors']
    export=json.loads(read(ROOT/'build/issue283-export-validation.json'))
    assert export['deterministic_files']==7
    evidence={'issue':283,'release':'5.4.23','status':'Draft; modular parts, approved timed animations and author review pending',
              'runtime_sha256':digest(WORK/'production.pk3'),'source_members':members,
              'native_runs':len(runs),'native_assertions':sum(r['assertions'] for r in runs),
              'runs':runs,'captures':captures,'frame_intervals':frames,'export':export,
              'static_errors':0,'context_words':static['context_words'],
              'normal_build_sha256':digest(ROOT/'build/caelum_argenteum_dev.pk3'),
              'limitations':['No author acceptance or default replacement.',
                  'Fixed-surface intermediate export; required interchangeable weapon/shield/armor/hair/face parts remain open.',
                  'Approved chair (2 s), lie/get-up (3 s), provision (4 s) animations and control locks are unimplemented; tested rest changes pose immediately.',
                  'Other weapons and crouch use existing appearance; source-only crouch is not production coverage.',
                  'Run/death/raise have minor transient floor intersections; source bounds are recorded for further art polish.',
                  'Benchmarks use 1/64 non-combat render proxies, Vulkan 1280x720, hidden/unpaused at 5% audio, uncapped after warm-up.',
                  'Reported intervals include rendering, simulation and scheduling; native thinker profiles are separate, not GPU timings.',
                  'Native captures remain local because the development fixture uses an installed development IWAD.']}
    (HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:evidence[k] for k in ['native_runs','native_assertions','runtime_sha256','source_members','static_errors','context_words']}))

if __name__=='__main__':main()
