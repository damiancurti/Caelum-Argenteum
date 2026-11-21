"""Publish reproducible full-frame diagnosis and exact native evidence."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');LOCAL=Path(__file__).parent
public=ROOT/'assets/validation_v5_17_113';public.mkdir(exist_ok=False);e=public/'evidence';e.mkdir()
def copy(source,target):
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
labels=['native01','grouping01','native02','stages-run01','calls-run02']
analyses=[]
for label in labels:
    subprocess.run([sys.executable,str(LOCAL/'analyze_frame870.py'),label],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
    source=ROOT/f'build/issue870-{label}';target=e/'windows'/label
    report=json.loads((source/'analysis.json').read_text());analyses.append(report)
    for name in ['analysis.json','manifest.json','driver.py']:copy(source/name,target/name)
    copy(ROOT/f'build/issue870-{label}-run.log',target/'wrapper.log')
    directory=ROOT/report['directory']
    for name in ['results.json','presentation.json','peer0/engine.log','peer0/session.ini','peer0/start.cfg','peer0/presents.csv','peer0/scene.png','peer0/benchmarks.txt','peer0/debug0.txt']:
        p=directory/name
        if p.is_file():copy(p,target/'native'/name)
    with zipfile.ZipFile(directory/'observer.pk3') as z:
        for name in z.namelist():
            if not name.endswith('/'):
                p=target/'observer-source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
assert all(r['states']==analyses[0]['states'] and r['census']==analyses[0]['census'] for r in analyses)
for label in ['stages01','calls03']:
    source=ROOT/f'build/issue870-{label}';target=e/'probes'/label
    for name in ['manifest.json','analysis.json']:copy(source/name,target/name)
    for p in (source/'source').rglob('*'):
        if p.is_file():copy(p,target/'source'/p.relative_to(source/'source'))
# Keep failed generation and compilation separate from passed evidence.
failed=ROOT/'build/v516/barracas-profile-20261121-035022-038144'
for name in ['results.json','peer0/engine.log','peer0/session.ini','peer0/start.cfg']:copy(failed/name,e/'attempts/calls-run01'/name)
for label in ['calls01','calls02']:
    source=ROOT/f'build/issue870-{label}'
    copy(source/'manifest.json',e/'attempts'/label/'manifest.json')
    for p in (source/'source').rglob('*'):
        if p.is_file():copy(p,e/'attempts'/label/'source'/p.relative_to(source/'source'))
for name in ['run_frame_profile870.py','prepare_actor_stages870.py','prepare_actor_calls870.py','analyze_frame870.py','analyze_actor_stages870.py','analyze_actor_calls870.py','archive_frame870.py']:
    copy(LOCAL/name,e/'tooling'/name)

root_line="ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')"
portable_root="ROOT=Path(__file__).resolve().parents[2]"
runner=(LOCAL/'run_frame_profile870.py').read_text().replace(root_line,portable_root)
(public/'run_frame.py').write_text(runner,encoding='utf-8',newline='\n')
analyzer=(LOCAL/'analyze_frame870.py').read_text().replace(root_line,portable_root)
(public/'analyze_frame.py').write_text(analyzer,encoding='utf-8',newline='\n')
for kind in ['stages','calls']:
    s=(LOCAL/f'prepare_actor_{kind}870.py').read_text().replace(root_line,portable_root)
    s=s.replace('import hashlib,json,zipfile','import argparse,hashlib,json,zipfile').replace('import hashlib,json,re,zipfile','import argparse,hashlib,json,re,zipfile')
    old=re.search(r"runtime=ROOT/'build/issue868-diagnosis01.pk3';out=ROOT/'build/issue870-[^']+';out.mkdir\(exist_ok=False\)",s)[0]
    s=s.replace(old,"p=argparse.ArgumentParser(description=__doc__)\np.add_argument('--runtime',type=Path,required=True)\np.add_argument('--output',type=Path,required=True)\na=p.parse_args();runtime=a.runtime.resolve(strict=True);out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)")
    (public/f'prepare_{kind}.py').write_text(s,encoding='utf-8',newline='\n')
    s=(LOCAL/f'analyze_actor_{kind}870.py').read_text().replace(root_line,portable_root)
    s=s.replace('import json,re,statistics','import argparse,json,re,statistics')
    old=re.search(r"out=ROOT/'build/issue870-[^']+';manifest=json.loads\(\(out/'manifest.json'\).read_text\(\)\)",s)[0]
    s=s.replace(old,"p=argparse.ArgumentParser(description=__doc__)\np.add_argument('--probe',type=Path,required=True)\np.add_argument('--run-log',type=Path,required=True)\na=p.parse_args();out=a.probe.resolve(strict=True);manifest=json.loads((out/'manifest.json').read_text())")
    s=re.sub(r"raw=\(ROOT/'build/issue870-[^']+-run.log'\).read_bytes\(\)","raw=a.run_log.read_bytes()",s)
    (public/f'analyze_{kind}.py').write_text(s,encoding='utf-8',newline='\n')
copy(ROOT/'assets/validation_v5_17_112/run_scene.py',public/'run_scene.py')
p=public/'run_scene.py';p.write_text(p.read_text().replace('issue868-','issue870-'),encoding='utf-8',newline='\n')
control=json.loads((ROOT/'build/issue868-siege-final01-summary.json').read_text())
copy(ROOT/'build/issue868-siege-final01-summary.json',e/'uninstrumented-control112.json')
assert control['states']==analyses[0]['states'] and control['census']==analyses[0]['census']
source_root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/gzdoom-g4.14.2')
names=['src/d_main.cpp','src/d_net.cpp','src/playsim/dthinker.cpp','src/common/engine/stats.cpp','src/common/scripting/vm/vmframe.cpp']
hashes={}
for name in names:
    p=source_root/name
    if not p.is_file():
        found=list(source_root.rglob(Path(name).name));assert len(found)==1; p=found[0]
    hashes[p.relative_to(source_root).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
(e/'engine-source.json').write_text(json.dumps(dict(source='Official GZDoom g4.14.2, locally retained source; no replacement engine',files=hashes),indent=2)+'\n',encoding='utf-8',newline='\n')
summary=dict(issue=870,release='5.17.113',tested_runtime='5.17.112',runtime_sha256=analyses[0]['runtime_sha256'],passed_windows=len(analyses),observer_states_match=True,uninstrumented_control='Prior #868 final112 native window, same immutable runtime and observer state; not rerun as113',production_optimization=False,
    conclusion='Observed15-17 actual WorldTick callbacks between complete render intervals. Native actor Tick dominates selected thinker profiles; services and state-action execution are separated by42-tic probes. PortSiege.Pulse, thermal NPCStep and Communication.Pulse are the concrete next costs. Measurements do not demonstrate a GPU bottleneck.',
    failures=['calls01: generated wrong carbine argument name; rejected before native launch.', 'calls02/calls-run01: For is a reserved case-insensitive ZScript keyword; compilation failed. Renamed FindFor; calls03/calls-run02 passes.'],
    limits=['native01 stride140 reuses the same modulo35 phase; retained as biased, superseded by35 coprime-stride native02 snapshots.', 'Snapshot averages and instrumented inclusive timers are not uninstrumented CPU budgets; nested totals overlap.', 'Native bench is a later renderer CPU-scope snapshot, not GPU duration or a whole-window mean.', 'QueuePresent is not monitor scanout. Actual observer-state equality is narrower than full world-state equivalence.', 'Siege performance and broader batch remain open; no author acceptance or partial test terminal.'],full_validation='pending')
(e/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(public=str(public),windows=len(analyses),same_observer_state=True)))
