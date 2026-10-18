"""Collect or verify the focused follow-up to the author's double-Melt report."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
CASES=[('issue334-single-melt01','roundtrip',1),('issue334-single-melt02','roundtrip',1),
    ('issue334-single-melt03','roundtrip',1),('issue334-single-reload04','reload',9),
    ('issue334-single-vehicle05','vehicle',13)]
def sha(data):return hashlib.sha256(data).hexdigest()
def delivery():
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    source={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    tested=ROOT/'build/issue334-single-melt01/baseline.pk3'
    with zipfile.ZipFile(package) as normal,zipfile.ZipFile(tested) as probe:
        assert set(normal.namelist())==set(probe.namelist())==set(source)
        for name,data in source.items():
            assert normal.read(name)==data,name
            candidate=probe.read(name)
            if name=='caelum/world/CaelumHouseHub.zs':
                candidate=candidate.replace(b'        EventHandler.SendInterfaceEvent(consoleplayer,"c334_queued");\n',b'')
            assert candidate==data,name
    validation=json.loads(subprocess.check_output(['python','validate_project.py'],cwd=ROOT))
    assert not validation['errors']
    record=dict(issue=334,release='5.4.46',normal_package_sha256=sha(package.read_bytes()),members=len(source),
        source_byte_equality=True,tested_runtime_sha256=sha(tested.read_bytes()),tested_gameplay_identical=True,
        only_runtime_difference='One private queued trace event removed.',validation=validation,
        author_status='Other preview checks accepted; CA334-02 double exit Melt retest pending.')
    (HERE/'single_melt_delivery.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
def collect():
    members={}
    for folder,label,_ in CASES:
        work=ROOT/'build'/folder
        for name in ['manifest.json','probe.cfg',label+'-commands.cfg',label+'.txt',label+'-run.json']:
            data=(work/name).read_bytes()
            if name.endswith('-run.json'):
                run=json.loads(data.decode('utf-8-sig'));run['original_record_sha256']=sha(data)
                run.pop('initial_config',None) # The interactive run copied personal UI preferences.
                data=(json.dumps(run,indent=2)+'\n').encode()
            members[folder+'/'+name]=data
    with zipfile.ZipFile(HERE/'single_melt_evidence.zip','w',zipfile.ZIP_DEFLATED) as z:
        for name,data in sorted(members.items()):
            info=zipfile.ZipInfo(name,(2000,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;z.writestr(info,data)
    record=dict(issue=334,release='5.4.46',cases=CASES,native_assertions=sum(n for _,_,n in CASES),
        sha256={name:sha(data) for name,data in sorted(members.items())},
        visual_limit='84 target-window samples in melt03 include black frames; no full-animation proof.',
        author_status='Other preview checks accepted 2026-10-18; double exit Melt retest pending.')
    (HERE/'single_melt_evidence.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
def verify():
    record=json.loads((HERE/'single_melt_evidence.json').read_text(encoding='utf-8'));engines=set()
    with zipfile.ZipFile(HERE/'single_melt_evidence.zip') as z:
        assert set(z.namelist())==set(record['sha256'])
        for name,digest in record['sha256'].items():assert sha(z.read(name))==digest,name
        for folder,label,count in record['cases']:
            run=json.loads(z.read(f'{folder}/{label}-run.json'));manifest=json.loads(z.read(folder+'/manifest.json'))
            log=z.read(f'{folder}/{label}.txt').decode('utf-8')
            assert run['exit_code']==0 and 'GZDoom version g4.14.2' in log,folder
            assert not any(s in log for s in ['CA282 FAIL','Script error','JIT error','VM execution aborted']),folder
            for key in ['runtime_sha256','fixture_sha256']:assert run[key].lower()==manifest[key].lower()
            engines.add(run['engine_sha256'].lower())
            markers=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',log)
            assert markers==([('4','0'),('8','0'),('1','0')] if label=='reload' else [(str(count),'0')]),markers
            if folder in ['issue334-single-melt02','issue334-single-melt03']:
                selections=re.findall(r'CA334 SELECT map=(\w+) phase=(\w+) type=(\d+) global=(\d+)',log)
                expected=[(m,phase,kind,'1') for m in ['MAP03','CAH008','MAP03'] for phase,kind in [('initial','3'),('visible','1')]]
                assert selections==expected,selections
            if label=='vehicle':
                assert 'CA334 VEHICLE_ARRIVAL wipe=1' in log
                assert 'CA334 SELECT map=CAH158 phase=initial type=3 global=2' in log
                assert 'CA334 SELECT map=CAH158 phase=visible type=1 global=2' in log
                assert 'CA334 SELECT map=MAP03 phase=initial' not in log
        assert len(engines)==1
    print(f'Verified {len(record["cases"])} native runs / {record["native_assertions"]} assertions and scoped transition selections.')
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--collect',action='store_true');p.add_argument('--delivery',action='store_true');a=p.parse_args()
    if a.delivery:delivery()
    if a.collect:collect()
    verify()
