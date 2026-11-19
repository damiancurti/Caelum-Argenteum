"""Retain scoped #836 evidence without distributing runtime or test packages."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path(__file__).resolve().parents[2]/'build/v517/work-713';H=Path(__file__).parent
E=R/'assets/validation_v5_17_96/evidence';E.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(source,target):
    assert source.is_file(),source
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def capture_run(label,directory):
    source=R/directory;target=E/'campaign'/label
    for name in ['results.json','presentation.json','peer0/engine.log','peer0/process.log','peer0/presents.csv','peer0/scene.png','peer0/session.ini','peer0/start.cfg']:
        p=source/name
        if p.exists():copy(p,target/name)
    with zipfile.ZipFile(source/'observer.pk3') as z:
        for name in z.namelist():
            assert Path(name).name==name,name
            p=target/'observer-source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
    result=read(source/'results.json');assert result['passed']
    row={'label':label,'local_directory':directory,'runtime_sha256':result['runtime_sha256'],'simulation':result['peers'][0]['simulation'],'states':result['peers'][0]['states'],'overlays':result['overlays']}
    if (source/'presentation.json').exists():row['presentation']=read(source/'presentation.json')['peers'][0]
    return row
campaigns=[('baseline01','build/v516/barracas-profile-20261119-105637-361800'),('sections','build/v516/barracas-profile-20261119-110051-921622'),('methods','build/v516/barracas-profile-20261119-110651-676123'),('prototype','build/v516/barracas-profile-20261119-111755-289458'),('oracle','build/v516/barracas-profile-20261119-112132-964507')]
campaigns += [(v['name'],v['directory']) for v in read(R/'build/issue836-presentation-final.json')]
rows=[capture_run(label,directory) for label,directory in campaigns]
for name in ('issue836-profile01','issue836-profile02','issue836-reach02','issue836-oracle01'):
    source=R/'build'/name
    for p in sorted(source.rglob('*')):
        if p.is_file() and p.suffix!='.pk3':copy(p,E/'overlays'/name/p.relative_to(source))
for name in ('issue836-profile01-sections.json','issue836-profile02-methods.json','issue836-preservation01.json','issue836-suite01.json','issue836-presentation-final.json'):
    copy(R/'build'/name,E/name)
suite=read(R/'build/issue836-suite01.json');edge_rows=[]
extras=[{'name':'initial-base','output':'build/issue836-edges-base01'},{'name':'invalid-one-sided-portal','output':'build/issue836-edges-portal01'},{'name':'prototype-portal','output':'build/issue836-edges-portal02'}]
for item in extras+suite:
    source=R/item['output'];target=E/'edges'/item['name']
    for name in ('RESULTS.json','checks.zs','fixture.txt','engine.log','process.log','session.ini','commands.cfg'):
        copy(source/name,target/name)
    report=read(source/'RESULTS.json')
    row={'label':item['name'],'local_directory':item['output'],'passed':report['passed'],'pass_assertions':sum(s.startswith('CA836 EDGE PASS ') for s in report['checks']),'fail_assertions':sum(s.startswith('CA836 EDGE FAIL ') for s in report['checks']),'loaded_save_sha256':report['loaded_save_sha256']}
    row['output_save_sha256']=sha(source/'reach.zds');edge_rows.append(row)
for name in ('prepare_actor_sections836.py','prepare_method_cost836.py','prepare_group_reach836.py','prepare_reach_oracle836.py','run_reach_edges836.py','adopt_reach836.py','run_suite836.py','run_presentation836.py','archive_reach836.py'):
    copy(H/name,E/'executed-helpers'/name)
oracle=(R/'build/v516/barracas-profile-20261119-112132-964507/peer0/engine.log').read_text(encoding='utf-8',errors='replace')
oracle_line=next(s for s in oracle.splitlines() if s.startswith('CA836 ORACLE '));assert oracle_line.endswith('result=PASS')
assert all(r['states']==rows[0]['states'] for r in rows),'Census/player state changed between campaign runs.'
summary={'issue':836,'version':'5.17.96','parent_commit':'49e9bb5242ca5ad2ec248496e247e7cae55177e8','decision':'Adopt the conservative query reduction in production; siege presentation remains far from fluent. No schema, saved field, balance value or target cadence changes.','runtime':read(R/'build/issue836-preservation01.json'),'campaign_runs':rows,'oracle':oracle_line,'oracle_qualification':'Every37th tic of the700tic window; original and filtered ordered queries in the same scene. Added diagnostic work is not production timing evidence. Prototype differs from final semantics only by relocation of the existing0.01 contact constant; preservation audit checks the inverse source transformation.','edge_runs':edge_rows,'final_suite_assertions':sum(x['pass_assertions'] for x in edge_rows if x['label'] in {q['name'] for q in suite}),'directly_inspected_scenes':['baseline01','prototype','final01','baseline02'],'failed_iterations':['Initial prototype builder asserted on CRLF anchors before launching native code; corrected newline handling restores source exactly.','Initial linked-portal fixture used one-sided lines; native engine downgraded them to visual portals. Three intended linked checks failed. The corrected two-sided fixture has three portal groups and passes native496 versus raw6640 distance.'],'qualifications':['Only the approved normal1000attacker-cap/600defender siege is run; no retired6000actor test. Actual census988attackerNPC+601defenders+player=1590living; machines retain the side cap.','Single-machine Vulkan1280x720 uncapped, background unpaused,5%audio;700simulation intervals per run. No heavy build/export/full validator overlaps measurement.','Queue-present intervals are not display scanout/GPU duration or Internet latency. Sparse nested method timings overlap and are diagnostic.','CA454-MAP03-01 and all earlier author checks remain pending for the final consolidated session; no author acceptance.','No private IWAD/engine/testWAD/PK3/save is retained in tracked evidence.'], 'project_validation_passed':False}
summary['files']={p.relative_to(E).as_posix():sha(p) for p in sorted(E.rglob('*')) if p.is_file()}
assert not any(Path(n).suffix.lower() in ('.pk3','.wad','.exe','.dll','.zds') for n in summary['files'])
(E/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'files':len(summary['files']),'final_suite_assertions':summary['final_suite_assertions'],'oracle':oracle_line}))
