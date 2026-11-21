"""Retain acquisition probes, rejected light prototypes and unchanged-runtime evidence."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');LOCAL=Path(__file__).parent
public=ROOT/'assets/validation_v5_17_115';public.mkdir(exist_ok=False);e=public/'evidence';e.mkdir()
def copy(src,dst):dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
def native(directory,target):
    for name in ['results.json','presentation.json','peer0/engine.log','peer0/session.ini','peer0/start.cfg','peer0/presents.csv','peer0/scene.png']:
        if (directory/name).is_file():copy(directory/name,target/'native'/name)
    with zipfile.ZipFile(directory/'observer.pk3') as z:
        for name in z.namelist():
            if name.endswith('/') or name.lower().endswith(('.wad','.pk3')):continue
            p=target/'observer-source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
probes=['target01','candidate01','candidate02','details01','light01','light02','light-oracle01','light-stages02']
for name in probes:
    source=ROOT/f'build/issue873-{name}';target=e/'probes'/name
    for p in source.rglob('*'):
        if p.is_file() and (p.suffix in ['.json','.zs'] or p.relative_to(source).parts[0]=='source'):copy(p,target/p.relative_to(source))
windows=[]
for label in ['target-run01','candidate-run02','details-run01','light-oracle-run01','light-stages-run02']:
    source=ROOT/f'build/issue873-{label}';target=e/'windows'/label
    report=json.loads((source/'analysis.json').read_text());windows.append(report)
    for name in ['analysis.json','manifest.json','driver.py']:copy(source/name,target/name)
    copy(ROOT/f'build/issue873-{label}-run.log',target/'wrapper.log');native(ROOT/report['directory'],target)
assert all(d['states']==windows[0]['states'] and d['census']==windows[0]['census'] for d in windows)
label='candidate-run01';target=e/'attempts'/label;source=ROOT/f'build/issue873-{label}'
for name in ['manifest.json','driver.py']:copy(source/name,target/name)
log=ROOT/f'build/issue873-{label}-run.log';copy(log,target/'wrapper.log')
raw=log.read_bytes();text=raw.decode('utf-16' if raw[:2]==b'\xff\xfe' else 'utf-8')
directory=Path(re.search(r'Campaign peers started: (.+)',text)[1].strip());native(directory,target)
assert not json.loads((directory/'results.json').read_text())['passed']
checks=[]
for label in ['light-edges-flat01','light-expanded-flat01','light-expanded-portal01','light-fast-flat01']:
    source=ROOT/f'build/issue873-{label}';target=e/'checks'/label
    for p in source.iterdir():
        if p.suffix in ['.json','.log','.ini','.cfg','.zs','.txt']:copy(p,target/p.name)
    report=json.loads((source/'RESULTS.json').read_text());assert report['passed'] and (source/'reach.zds').is_file()
    log=(source/'engine.log').read_text(encoding='utf-8');numbers=[int(n) for n in re.findall(r'CA836 EDGE_RESULT (?:checks|relation_checks)=(\d+) failures=0 result=PASS',log)]
    assert len(numbers)==2;checks.append(dict(label=label,assertions=sum(numbers),saved_fixture_produced=True,report=report))
assert sum(r['assertions'] for r in checks)==2663
performance=[]
for label in ['light-control01','light-candidate01','siege-final01','siege-final02']:
    p=ROOT/f'build/issue873-{label}-summary.json';row=json.loads(p.read_text());performance.append(row)
    target=e/'scenes'/label;copy(p,target/'summary.json');copy(ROOT/f'build/issue873-{label}-run.log',target/'wrapper.log');native(ROOT/row['directory'],target)
assert all(d['states']==performance[0]['states'] and d['census']==performance[0]['census'] for d in performance)
for name in ['observer-comparison','light-decision','runtime-comparison','reproduction']:copy(ROOT/f'build/issue873-{name}.json',e/f'{name}.json')
copy(ROOT/'assets/validation_v5_17_114/evidence/production-performance.json',e/'prior-production114.json')
for name in ['prepare_target_profile873.py','prepare_candidate_profile873.py','prepare_candidate_details873.py','prepare_light873.py','prepare_light_fast873.py','prepare_light_oracle873.py','prepare_light_fast_stages873.py','run_frame_profile873.py','analyze_frame873.py','analyze_target873.py','analyze_candidate873.py','analyze_candidate_details873.py','analyze_light_fast_stages873.py','archive_target873.py']:
    copy(LOCAL/name,e/'tooling'/name)
# Relocatable reproduction tools do not contain engine, IWAD, map or save binaries.
root_line="ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')"
for name,dest in [('run_light_edges873.py','run_edges.py'),('run_frame_profile873.py','run_frame.py'),('analyze_frame873.py','analyze_frame.py')]:
    s=(LOCAL/name).read_text(encoding='utf-8').replace(root_line,'ROOT=Path(__file__).resolve().parents[2]')
    (public/dest).write_text(s,encoding='utf-8',newline='\n')
copy(LOCAL/'light_edges873.zs',public/'light_edges873.zs')
s=(LOCAL/'run_scene873.py').read_text(encoding='utf-8').replace("root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')",'root=Path(__file__).resolve().parents[2]')
(public/'run_scene.py').write_text(s,encoding='utf-8',newline='\n')
for name in ['prepare_probe.py','prepare_light.py','prepare_oracle.py','CONTRACT.txt']:copy(LOCAL/'public873'/name,public/name)
for name,data in [('native-checks.json',checks),('production-performance.json',performance)]:
    (e/name).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
summary=dict(issue=873,release='5.17.115',decision='Retain production perception; reject both current-light bounds as insufficiently beneficial.',assertions=2663,passing_edge_runs=4,diagnostic_windows=5,scene_windows=4,failed_fixture_attempts=1,production_changes='Two release log labels only',author_queue_unchanged=True,author_acceptance=False,full_validation='pending',prepared_but_not_run=['light-stages01','light-oracle02'],qualification='Instrumented local costs and a single direct-light full-scene difference do not establish a production gain. No light bound or known-visible shortcut is integrated. Prior peaceful references retain release114 labels. Siege-final01 overlapped the package byte audit during its first approximately two startup seconds, before the measured window; final02 repeats the final scene without that overlap. Siege fluency and the broader batch remain open.')
(e/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(summary))
