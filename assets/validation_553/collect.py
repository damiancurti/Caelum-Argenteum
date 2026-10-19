"""Gate #312 native evidence, frozen packages and actual serialized pressure."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
REQUIRED={
    'issue312-final01':['probe','flow','combat','motion','hub','current-save','current-load',
                        'old-upgrade','original-rollback','current-rollback'],
    'issue312-save-old':['original-save'],
    'issue312-old-ceiling':['old-ceiling-save'],
    'issue312-final02':['pressure','ceiling-pause','ceiling-save','ceiling-load'],
    'issue312-final04':['ceiling-old-upgrade','ceiling-original-rollback','ceiling-upgraded-rollback'],
    'issue312-preview04':['preview-visible'],
}
COUNTS={'probe':35,'flow':19,'combat':47,'motion':15,'hub':13,'current-save':2,
        'current-load':13,'old-upgrade':13,'original-rollback':6,'current-rollback':6,
        'original-save':2,'old-ceiling-save':4,'pressure':23,'ceiling-pause':56,
        'ceiling-save':4,'ceiling-load':12,'ceiling-old-upgrade':12,
        'ceiling-original-rollback':12,'ceiling-upgraded-rollback':12,'preview-visible':0}
ORIGINAL_RUNTIME='47d92bb8a03cc46aa7b57cec18a5694b290f89c0bc4ea37558aab092ca1a603b'
EARLIER_RUNTIME='72d087e42ccbc578c5243f21fba5a2561b7cefe8c2c4a35299033e1619cedc41'
FINAL_RUNTIME='4693f37eb27a0d3bd7502f8c6bb4f379ac697243dbd69e3d606b9040d329a5de'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def members(p):
    with zipfile.ZipFile(p) as z:
        return {n:z.read(n) for n in z.namelist()}


def save_state(p):
    objects=[]
    with zipfile.ZipFile(p) as z:
        for n in z.namelist():
            if n.endswith(('.map.json','.mapd.json')):
                objects+=json.loads(z.read(n))['objects']
    result={'path':str(p.relative_to(ROOT)),'sha256':sha(p)}
    for kind in ('CaelumWeightPressure','CaelumCeilingPressure','ImpactContactState'):
        result[kind]=[o['class:'+kind] for o in objects if 'class:'+kind in o]
    return result


def main():
    out=HERE/'evidence';out.mkdir(exist_ok=True)
    report={'required':[],'all_runs':[],'saves':{},'notes':[
        'Native checks and author CA312-01 acceptance are separate; FPS is deferred.',
        'Ten final01 runs are reused: only the isolated ceiling-pressure classes differ from final02.',
        'The final ceiling tests and preview use the normal final PK3; all inputs are frozen.',
        'The original ceiling save requires both its original QA sector tag and the ceilingsave.pk3 basename; final04 preserves both.',
        'Excluded failures remain evidence, not passed gates.']}
    engines=set();seen=set()
    for directory in sorted((ROOT/'build').glob('issue312-*')):
        if not directory.is_dir():continue
        manifest_path=directory/'manifest.json'
        if not manifest_path.exists():continue
        manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
        shutil.copyfile(manifest_path,out/(directory.name+'--manifest.json'))
        for record_path in sorted(directory.glob('*-run.json')):
            record=json.loads(record_path.read_text(encoding='utf-8-sig'))
            label=record['label'];log_path=directory/(label+'.txt')
            log=log_path.read_text(encoding='utf-8',errors='replace') if log_path.exists() else ''
            marker=re.findall(r'CA194 DONE failures=(\d+) passes=(\d+)',log)
            problems=[line for line in log.splitlines() if re.search(
                r'CA194 FAIL|Script error|VM execution aborted|Savegame is from a different level|Not in a level|This savegame needs|Could not open|DIED WITH FATAL ERROR',line)]
            required=label in REQUIRED.get(directory.name,[])
            entry={'directory':directory.name,'label':label,'required':required,
                   'exit_code':record.get('exit_code'),'markers':marker,'problems':problems,
                   'pass_lines':len(re.findall(r'^CA194 PASS ',log,re.M)),
                   'record_sha256':sha(record_path),'log_sha256':sha(log_path) if log_path.exists() else None}
            report['all_runs'].append(entry)
            for p in (record_path,log_path):
                if p.exists():shutil.copyfile(p,out/(directory.name+'--'+p.name))
            if not required:continue
            key=(directory.name,label)
            assert key not in seen,key
            seen.add(key)
            assert record.get('exit_code')==0 and marker and not problems,entry
            assert all(int(fail)==0 for fail,_ in marker),entry
            assert int(marker[-1][1])==COUNTS[label],entry
            if label=='hub':assert marker==[('0','6'),('0','13')],entry
            if label=='preview-visible':
                assert 'CA312 PREVIEW weight placed' in log and 'CA312 PREVIEW weight removed' in log,entry
                assert 'CA312 PREVIEW ceiling started' in log,entry
            args=[s.strip('"') for s in record['arguments']]
            file_index=args.index('-file');runtime=Path(args[file_index+1]);fixture=Path(args[file_index+2])
            assert sha(runtime)==record['runtime_sha256'].lower(),entry
            expected_runtime=(ORIGINAL_RUNTIME if label in ('original-rollback','current-rollback','ceiling-original-rollback','ceiling-upgraded-rollback') or directory.name in ('issue312-save-old','issue312-old-ceiling')
                              else EARLIER_RUNTIME if directory.name=='issue312-final01' else FINAL_RUNTIME)
            assert sha(runtime)==expected_runtime,entry
            if runtime.name=='production.pk3':assert sha(runtime)==manifest['runtime_sha256'],entry
            assert sha(fixture)==record['fixture_sha256'].lower()==manifest['fixtures'][fixture.name],entry
            for name,digest in manifest['script_hashes'].items():assert sha(directory/name)==digest,(entry,name)
            command=Path(args[args.index('+exec')+1])
            assert sha(command) in manifest['script_hashes'].values(),(entry,'executed script is not frozen')
            shutil.copyfile(command,out/(directory.name+'--'+command.name))
            entry['executed_script_sha256']=sha(command)
            entry['completed_phase_checks']=int(marker[-1][1])
            engines.add(record['engine_sha256'].lower())
            report['required'].append(entry)
    assert seen=={(d,label) for d,labels in REQUIRED.items() for label in labels}, 'Missing required runs'
    assert len(engines)==1,engines
    final_path=ROOT/'build/issue312-final02/production.pk3'
    final=members(final_path);earlier=members(ROOT/'build/issue312-final01/production.pk3')
    assert set(final)==set(earlier)
    differences=[n for n in final if final[n]!=earlier[n]]
    assert differences==['caelum/world/CaelumPhysicalHazards.zs'],differences
    def without_ceiling(data):
        start=data.index(b'class CaelumCrushingDamage');end=data.index(b'class CaelumHazardDiagnostics')
        return data[:start]+data[end:]
    assert without_ceiling(final[differences[0]])==without_ceiling(earlier[differences[0]])
    assert sha(final_path)==sha(ROOT/'build/caelum_argenteum_dev.pk3')
    for name,data in final.items():assert (ROOT/'src'/name).read_bytes()==data,name
    report['final_runtime_sha256']=sha(final_path);report['runtime_members']=len(final)
    report['reused_runtime_differences']=differences
    for key,name in {
        'old_body':'issue312-save-old/ca312-ongoing.zds',
        'current_body':'issue312-final01/ca312-ongoing.zds',
        'old_body_released':'issue312-final01/ca312-old-after.zds',
        'old_ceiling':'issue312-old-ceiling/ca312-ceiling.zds',
        'current_ceiling':'issue312-final02/ca312-ceiling.zds',
        'converted_ceiling':'issue312-final04/ca312-legacy-converted.zds',
    }.items():report['saves'][key]=save_state(ROOT/'build'/name)
    old=report['saves']['old_body']
    assert old['ImpactContactState'][0]['PendingWorkJoules']==1000
    assert 0<old['CaelumWeightPressure'][0]['DamageCarry']<981
    assert not report['saves']['old_ceiling']['CaelumCeilingPressure'][0].get('SamplingRevision',0)
    for key in ('current_ceiling','converted_ceiling'):
        state=report['saves'][key]['CaelumCeilingPressure'][0]
        assert state['SamplingRevision']==1 and state['PendingCompressionMeters']>0,state
        assert state['LastSampleMeters']==0.25,state
    assert sha(ROOT/'build/issue312-final01/original-ongoing.zds')==old['sha256']
    assert sha(ROOT/'build/issue312-final04/original-ceiling.zds')==report['saves']['old_ceiling']['sha256']
    old_map=members(ROOT/'build/issue312-old-ceiling/ceilingsave.pk3')['maps/MAPQA.wad']
    assert old_map==members(ROOT/'build/issue312-final04/ceilingsave.pk3')['maps/MAPQA.wad']
    report['gate']='PASS'
    report['completed_phase_checks']=sum(e['completed_phase_checks'] for e in report['required'])
    (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'gate':'PASS','required_runs':len(report['required']),
                      'preserved_runs':len(report['all_runs']),'runtime_sha256':sha(final_path)}))


if __name__=='__main__':main()
