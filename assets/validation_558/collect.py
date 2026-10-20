"""Collect frozen #369 evidence without distributing engines, IWADs or saves."""
from pathlib import Path
import json
import math
import re
import shutil
import statistics
import zipfile
from verify import ROOT, HERE, sha, verify

RUNS = {
    'issue369-final01': ['final-poses', 'final-cast', 'final-encounter', 'final-recall',
        'final-fade', 'final-upgrade', 'final-reload', 'final-rollback-prep',
        'final-hub-out', 'final-hub-current', 'final-perf-model', 'final-map01-model'],
    'issue369-baseline02': ['final-rollback-old', 'final-hub-old', 'final-perf-old', 'final-map01-old'],
    'issue369-baseline01': ['baseline-cast01', 'baseline-encounter01'],
}
FAILURES = {
    ('issue369-current01','smoke01'): 'Unavailable owner.DeathState accessor; use FindState(Death).',
    ('issue369-current02','smoke02'): 'Fixture used unqualified GetSpriteIndex; qualify Actor.GetSpriteIndex.',
    ('issue369-current04','cast04'): 'Fixture killed before deferred PostBeginPlay profile initialization; wait, then native DamageMobj.',
    ('issue369-baseline01','hub-rollback-old01'): 'Production lifecycle defect: final tic recreated helpers after WorldUnloaded; fixed transition gate.',
    ('issue369-current08','poses08'): 'Invalid fixture gore target/timing; also exposed preparation priority hiding the gore notification (fixed).',
    ('issue369-current09','poses09'): 'Fixture sampled gore before the following helper tick; reorder independent poses and wait two tics.',
}


def trace(path):
    # Sprite registration numbers shift when MODELDEF sprites are added.
    rows = [line.split()[2:] for line in path.read_text(encoding='utf-8-sig').splitlines() if line.startswith('CA369 TRACE ')]
    return [row[:1]+row[2:] for row in rows]


def main():
    report = verify()
    evidence = HERE/'evidence'
    evidence.mkdir(exist_ok=True)
    def retain(path, name=None):
        target = evidence/(name or path.name)
        if target.exists():
            assert target.read_bytes() == path.read_bytes(), f'Evidence changed: {target}'
        else:
            shutil.copyfile(path, target)
        return {'file':target.relative_to(HERE).as_posix(), 'sha256':sha(target)}
    report.update(issue=369, version='5.5.8', runs=[], failed_attempts=[], performance={})
    report['author_acceptance'] = {'id':'CA369-01', 'accepted':False}
    previous = HERE/'report.json'
    if previous.exists():
        report['author_acceptance'] = json.loads(previous.read_text(encoding='utf-8'))['author_acceptance']
    for directory, labels in RUNS.items():
        folder=ROOT/'build'/directory
        manifest=json.loads((folder/'manifest.json').read_text(encoding='utf-8'))
        for label in labels:
            path=folder/(label+'.txt')
            text=path.read_text(encoding='utf-8-sig')
            record_path=folder/(label+'-run.json')
            record=json.loads(record_path.read_text(encoding='utf-8-sig'))
            assert record['exit_code']==0 and not record.get('failure'), label
            assert not re.search(r'CA369 FAIL|Unknown object class|VM execution aborted|Script error', text), label
            assert re.search(r'CA369 DONE passes=\d+ failures=0', text), label
            assert record['runtime_sha256'].lower()==manifest['runtime_sha256'].lower()
            assert record['fixture_sha256'].lower()==manifest['fixture_sha256'].lower()
            entry={'directory':directory, 'label':label, 'pass_lines':text.count('CA369 PASS '),
                'log':retain(path,directory+'--'+path.name),
                'run':retain(record_path,directory+'--'+record_path.name)}
            report['runs'].append(entry)
            frames=[float(x) for x in re.findall(r'^CA369 FRAME ([\d.]+)$',text,re.M)]
            ticks=[float(x) for x in re.findall(r'^CA369 TICK ([\d.]+)$',text,re.M)]
            if frames:
                assert len(ticks)==351
                ordered=sorted(frames)
                values={'callback_count':len(frames),'mean_ms':statistics.mean(frames),
                    'p95_ms':ordered[math.ceil(len(ordered)*.95)-1],
                    'p99_ms':ordered[math.ceil(len(ordered)*.99)-1], 'max_ms':max(frames),
                    'simulation_tics_per_second':350000/(ticks[-1]-ticks[0]),
                    'population':re.findall(r'^CA369 PERF (?:BEGIN|END) .*$',text,re.M)}
                if 'perf-' in label:
                    assert 'END alive=512' in text and 'shared >=500 census includes peaceful bulls' in text
                report['performance'][label]=values
    baseline=trace(ROOT/'build/issue369-baseline01/baseline-encounter01.txt')
    final=trace(ROOT/'build/issue369-final01/final-encounter.txt')
    assert len(final)==181 and final==baseline
    report['combat_trace']={'equal_rows':181,'excluded_field':'numeric native sprite registration index only'}
    with zipfile.ZipFile(ROOT/'build/issue369-final01/hub-rollback.zds') as archive:
        counts={name:archive.read(name).count(b'CaelumBullModelBody') for name in archive.namelist() if name.endswith('.map.json')}
    assert counts and not any(counts.values())
    report['hub_snapshot_helper_mentions']=counts
    stopped=ROOT/'build/issue369-final01/stopped-pixels.json'
    report['stopped_mesh_pixels']=json.loads(stopped.read_text(encoding='utf-8-sig'))
    assert report['stopped_mesh_pixels']['changed']==0
    report['stopped_mesh_evidence']=retain(stopped)
    for (directory,label), reason in FAILURES.items():
        path=ROOT/'build'/directory/(label+'.txt')
        report['failed_attempts'].append({'reason':reason, 'log':retain(path,directory+'--'+path.name)})
    report['export_manifest']=retain(ROOT/'build/issue369-export04/manifest.json','export-manifest.json')
    report['exporter_sha256']=sha(ROOT/'assets/generators/export_bull_model.py')
    static=ROOT/'build/issue369-static-final.json'
    validation=json.loads(static.read_text(encoding='utf-16'))
    assert validation['version']=='5.5.8' and not validation['errors']
    report['static_validation']=retain(static)
    report['normal_build_log']=retain(ROOT/'build/issue369-final-build-log.txt')
    report['export_log']=retain(ROOT/'build/issue369-export04-log.txt')
    report['rig_report']=retain(ROOT/'build/issue369-rig05/rig-report.json')
    captures=[]
    for name in ['final-poses-quick-idle-side.png','final-poses-quick-walk.png',
        'final-poses-quick-stopped-a.png','final-poses-quick-stopped-b.png','quick-run.png',
        'quick-gore.png','quick-death.png','quick-corpse.png','final-encounter-quick-map01.png',
        'final-perf-model-quick-perf.png','final-map01-model-quick-reference.png']:
        captures.append(retain(ROOT/'build/issue369-final01'/name))
    for name in ['front.png','angle.png']:
        captures.append(retain(ROOT/'build/issue369-clean14'/name,'cleaned-'+name))
    report['captures']=captures
    report['presentation']={'available':False,
        'reason':'Earlier same-session PresentMon ETW access denied; not retried or elevated. Callbacks are not presents.',
        'prior_evidence':'../validation_556/evidence/issue314-baseline01--neutral-before-presentmon.txt'}
    report['run_count']=len(report['runs'])
    report['pass_lines']=sum(run['pass_lines'] for run in report['runs'])
    report['tooling_sha256']={p.name:sha(p) for p in HERE.iterdir() if p.suffix in ('.py','.ps1','.zs')}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({key:report[key] for key in ['run_count','pass_lines','combat_trace','performance']},indent=2))


if __name__=='__main__':
    main()
