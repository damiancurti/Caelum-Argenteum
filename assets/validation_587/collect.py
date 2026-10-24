"""Collect focused native evidence and verify the complete runtime package."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410-food'
RUNS=('core02','commit01','save01','load01','hub01',
      'legacy-seed01','legacy-load01','legacy-rollback01')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    package=WORK/'current/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        members={name:hashlib.sha256(archive.read(name)).hexdigest()
                 for name in archive.namelist()}
    sources={path.relative_to(ROOT/'src').as_posix():digest(path)
             for path in (ROOT/'src').rglob('*') if path.is_file()}
    if sources!=members:
        raise RuntimeError('Packaged membership or bytes differ from current src')
    with zipfile.ZipFile(WORK/'probe01/caelum_argenteum_dev.pk3') as archive:
        probe={name:hashlib.sha256(archive.read(name)).hexdigest() for name in archive.namelist()}
        changed=[name for name in members if members[name]!=probe.get(name)]
        expected=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        if sorted(changed)!=sorted(expected) or set(probe)!=set(members):
            raise RuntimeError('Unexpected source changes after native checks')
        for name in changed:
            normalized=archive.read(name).decode('utf-8').replace('[Caelum 5.8.6]','[Caelum 5.8.7]')
            if normalized!=(ROOT/'src'/name).read_text(encoding='utf-8'):
                raise RuntimeError('A non-label runtime change invalidates reused evidence: '+name)
    evidence=HERE/'native'
    evidence.mkdir(exist_ok=True)
    runs=[]
    for label in RUNS:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
        if 'CA410J FAIL' in log or 'Script error' in log or 'VM execution aborted' in log:
            raise RuntimeError('Failed selected run: '+label)
        count=sum(line.startswith('CA410J PASS ') for line in log.splitlines())
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if record.get('timed_out') or record['exit_code']!=0 or count<=0:
            raise RuntimeError('Incomplete selected run: '+label)
        for suffix in ('.txt','-run.json','.ini'):
            shutil.copyfile(WORK/(label+suffix),evidence/(label+suffix))
        runs.append({'label':label,'pass_assertions':count,'package_sha256':record['package_sha256'],
                     'log_sha256':digest(WORK/(label+'.txt'))})
    for suffix in ('.txt','-run.json','.ini'):
        shutil.copyfile(WORK/('core01'+suffix),evidence/('core01'+suffix))
    report={'issue':410,'release':'5.8.7','package_sha256':digest(package),
            'package_members':len(members),'all_source_bytes_verified':True,
            'post_test_changes':{'members':changed,'scope':'Required diagnostic release labels only; gameplay bytes unchanged.'},
            'pass_assertions':sum(run['pass_assertions'] for run in runs),'runs':runs,
            'failed_probe':'core01: private fixture used the reserved identifier native; no production change required.',
            'author_acceptance':'Deferred while author is away; no claim of food/cooking acceptance.'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'members':len(members),'pass_assertions':report['pass_assertions'],'runs':len(runs)}))


if __name__=='__main__':
    main()
