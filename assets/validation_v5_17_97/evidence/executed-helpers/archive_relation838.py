"""Retain scoped #838 evidence, excluding private runtimes, fixtures and saves."""
from pathlib import Path
import hashlib,json,shutil,zipfile
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helpers=Path(__file__).parent
out=root/'assets/validation_v5_17_97/evidence';out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def copy(p,q):
    assert p.is_file(),p
    q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
def campaign(label,directory):
    source=root/directory;target=out/'campaign'/label
    for name in ['results.json','presentation.json','peer0/engine.log','peer0/process.log','peer0/presents.csv','peer0/scene.png','peer0/benchmarks.txt','peer0/session.ini','peer0/start.cfg']:
        if (source/name).exists():copy(source/name,target/name)
    with zipfile.ZipFile(source/'observer.pk3') as z:
        for name in z.namelist():
            assert Path(name).name==name
            p=target/'observer-source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
    r=read(source/'results.json');assert r['passed']
    row={'label':label,'directory':directory,'runtime_sha256':r['runtime_sha256'],'simulation':r['peers'][0]['simulation'],'states':r['peers'][0]['states'],'overlays':r['overlays']}
    if (source/'presentation.json').exists():row['presentation']=read(source/'presentation.json')['peers'][0]
    return row
runs=[('post836-methods','build/v516/barracas-profile-20261119-114618-901118'),('bursts','build/v516/barracas-profile-20261119-115926-994640'),('gc-control','build/v516/barracas-profile-20261119-120749-784295'),('gc-stop','build/v516/barracas-profile-20261119-121318-686480'),('prototype','build/v516/barracas-profile-20261119-121652-627327'),('oracle','build/v516/barracas-profile-20261119-121948-994314')]
runs += [(r['name'],r['directory']) for r in read(root/'build/issue838-presentation-final.json')]
rows=[campaign(label,directory) for label,directory in runs]
assert all(r['states']==rows[0]['states'] for r in rows)
for name in ['issue836-profile03','issue838-bursts03','issue838-relation01','issue838-oracle01']:
    source=root/'build'/name
    for p in sorted(source.rglob('*')):
        if p.is_file() and p.suffix!='.pk3':copy(p,out/'overlays'/name/p.relative_to(source))
for name in ['issue836-profile03-methods.json','issue838-bursts03-analysis.json','issue838-preservation01.json','issue838-suite01.json','issue838-presentation-final.json']:
    copy(root/'build'/name,out/name)
suite=read(root/'build/issue838-suite01.json');edges=[]
for item in [{'name':f'prototype0{i}','output':f'build/issue838-edges-prototype0{i}'} for i in range(1,4)]+suite:
    source=root/item['output'];target=out/'edges'/item['name']
    for name in ['RESULTS.json','checks.zs','fixture.txt','engine.log','process.log','session.ini','commands.cfg']:
        copy(source/name,target/name)
    r=read(source/'RESULTS.json')
    row={'label':item['name'],'directory':item['output'],'passed':r['passed'],'pass_assertions':sum(s.startswith('CA836 EDGE PASS ') for s in r['checks']),'loaded_save_sha256':r['loaded_save_sha256']}
    if (source/'reach.zds').exists():row['output_save_sha256']=sha(source/'reach.zds')
    edges.append(row)
for name in ['prepare_bursts838.py','analyze_bursts838.py','run_gc838.py','prepare_relation838.py','prepare_relation_oracle838.py','run_relation_edges838.py','relation_edges838.zs','adopt_relation838.py','run_suite838.py','run_bench838.py','run_presentation838.py','archive_relation838.py']:
    copy(helpers/name,out/'executed-helpers'/name)
oracle=next(s for s in (out/'campaign/oracle/peer0/engine.log').read_text(encoding='utf-8').splitlines() if s.startswith('CA838 ORACLE'))
assert oracle.endswith('result=PASS')
summary={'issue':838,'version':'5.17.97','parent_commit':'9387ab0eb2e2095c2d61019730a7a5086a3ff500','runtime':read(root/'build/issue838-preservation01.json'),'decision':'Avoid only read-only relationship queries for candidates already outside the unchanged reach bound; preserve resident and delegated side-effect ordering. Severe siege stalls remain.','campaign_runs':rows,'oracle':oracle,'edge_runs':edges,'final_suite_assertions':sum(r['assertions'] for r in suite),'failed_iterations':['Burst profiler expected a Tick override on abstract CaelumFolkloreCombatActor; preparation assertions stopped before launching, and the actual eight Tick owners were used.','First relationship fixture used adjacent generic closing brackets unsupported by native4.14.2. Second fixture attempted readonly Radius assignment, String addition and an NPC TheftTarget. Corrected test-only syntax/types; original logs retained.','Initial post-window bench requests exited before its five-second wait, so no benchmarks were produced. Final/control adapter allows350 more tics after the unchanged measurement and capture.'], 'qualifications':['28nested scopes over700tics exclude native/frame preparation work and include diagnostic overhead; never sum inclusive child/parent timings.','GC control and ablation both collect at tic3200, outside the window. Stopping cycles does not remove long stalls and grows active objects from979459(control) to3617130(stop) at exit. Not a production setting.','Only the approved normal1000attacker-cap/600defender scene; actual988attackers+601defenders+player=1590living. No retired6000case.','Queue presents are not display-scanout or GPU duration. Native bench is a later CPU snapshot, not the full-window GPU profile.','All earlier mansion/sewer/city/ground-facing evidence is preserved; this siege patch does not establish those views or author acceptance.','CA454-MAP03-01 and all author tests remain pending for the final consolidated batch; no partial terminal.','No private IWAD/engine/testWAD/PK3/save enters tracked evidence.'],'project_validation_passed':False}
summary['files']={p.relative_to(out).as_posix():sha(p) for p in sorted(out.rglob('*')) if p.is_file()}
assert not any(Path(n).suffix.lower() in ('.pk3','.wad','.exe','.dll','.zds') for n in summary['files'])
(out/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'evidence_files':len(summary['files']),'suite_assertions':summary['final_suite_assertions'],'oracle':oracle}))
