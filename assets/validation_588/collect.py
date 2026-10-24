"""Collect focused native evidence and verify the complete runtime package."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue411-placement'
RUNS=('core07','storage02','save02','load02','hub02',
      'legacy-seed02','legacy-load02','legacy-rollback02','handoff03')


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
    with zipfile.ZipFile(WORK/'probe04/caelum_argenteum_dev.pk3') as archive:
        probe={name:hashlib.sha256(archive.read(name)).hexdigest() for name in archive.namelist()}
        changed=[name for name in members if members[name]!=probe.get(name)]
        if changed or set(probe)!=set(members):
            raise RuntimeError('Final package differs from the tested gameplay source')
    evidence=HERE/'native'
    evidence.mkdir(exist_ok=True)
    runs=[]
    for label in RUNS:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
        if 'CA411P FAIL' in log or 'Script error' in log or 'VM execution aborted' in log:
            raise RuntimeError('Failed selected run: '+label)
        if label=='handoff03' and (log.count('CA411P placement rejected')!=3
            or log.count('CA411P placement accepted')!=1 or 'CA411P contents=3 owner=CaelumStashChest' not in log):
            raise RuntimeError('Author handoff controls did not preserve expected placement outcomes')
        count=sum(line.startswith('CA411P PASS ') for line in log.splitlines())
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if record.get('timed_out') or record['exit_code']!=0 or count<=0:
            raise RuntimeError('Incomplete selected run: '+label)
        for suffix in ('.txt','-run.json','.ini'):
            shutil.copyfile(WORK/(label+suffix),evidence/(label+suffix))
        runs.append({'label':label,'pass_assertions':count,'package_sha256':record['package_sha256'],
                     'log_sha256':digest(WORK/(label+'.txt'))})
    for label in ('core01','core02','strip03','core04','handoff01','bridge06'):
        for suffix in ('.txt','-run.json','.ini'):
            shutil.copyfile(WORK/(label+suffix),evidence/(label+suffix))
    report={'issue':411,'release':'5.8.8','package_sha256':digest(package),
            'package_members':len(members),'all_source_bytes_verified':True,
            'post_test_changes':{'members':changed,'scope':'None; all runtime bytes match the tested probe04.'},
            'pass_assertions':sum(run['pass_assertions'] for run in runs),'runs':runs,
            'failed_probe':'core01/core02/strip03: nested native collision queries skipped lines in the live block iterator; snapshotting local lines fixes the narrow-liquid regression (core04); bridge06 exposed base-sector support being confused with a continuous 3D floor, fixed in core07. handoff01 was a private Name/String diagnostic typo.',
            'author_acceptance':'Deferred while author is away; no claim of camp deployment or land-permission acceptance.'}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'members':len(members),'pass_assertions':report['pass_assertions'],'runs':len(runs)}))


if __name__=='__main__':
    main()
