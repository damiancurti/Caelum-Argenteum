"""Retain the surface-index diagnosis, native equivalence and scene evidence."""
from pathlib import Path
import hashlib,json,shutil,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
LOCAL=Path(__file__).parent
public=ROOT/'assets/validation_v5_17_114';public.mkdir(exist_ok=False)
e=public/'evidence';e.mkdir()
def copy(source,target):
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
def native(directory,target):
    for name in ['results.json','presentation.json','peer0/engine.log','peer0/session.ini','peer0/start.cfg','peer0/presents.csv','peer0/scene.png']:
        p=directory/name
        if p.is_file():copy(p,target/'native'/name)
    with zipfile.ZipFile(directory/'observer.pk3') as z:
        for name in z.namelist():
            if name.endswith('/') or name.lower().endswith(('.wad','.pk3')):continue
            p=target/'observer-source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(name))
diagnosis=[]
for probe,label in [('profile01','thermal-run01'),('maintenance01','maintenance-run01'),('surface01','surface-run01'),('index01','index-run01')]:
    source=ROOT/f'build/issue871-{probe}';target=e/'probes'/probe
    for name in ['manifest.json','analysis.json','distribution.json']:
        if (source/name).exists():copy(source/name,target/name)
    for p in (source/'source').rglob('*'):
        if p.is_file():copy(p,target/'source'/p.relative_to(source/'source'))
    source=ROOT/f'build/issue871-{label}';target=e/'windows'/label
    report=json.loads((source/'analysis.json').read_text());diagnosis.append(report)
    for name in ['analysis.json','manifest.json','driver.py']:copy(source/name,target/name)
    copy(ROOT/f'build/issue871-{label}-run.log',target/'wrapper.log')
    native(ROOT/report['directory'],target)
assert all(d['states']==diagnosis[0]['states'] and d['census']==diagnosis[0]['census'] for d in diagnosis)
native_tests=[]
for name in ['baseline01','baseline02','baseline03','baseline04','baseline05','fresh01','upgrade01','reload01','rollback01','final-fresh01','final-upgrade01']:
    source=ROOT/f'build/issue871-index-{name}';target=e/('attempts' if name in ['baseline01','baseline02','baseline03','baseline04'] else 'checks')/name
    assert source.is_dir(),source
    for p in source.iterdir():
        if p.suffix in ['.json','.log','.ini','.cfg','.zs']:copy(p,target/p.name)
    result=source/'RESULTS.json'
    if result.exists():native_tests.append(dict(label=name,**json.loads(result.read_text())))
performance=[]
for label in ['siege-control01','siege-candidate01','siege-final01','mansion-control01','mansion-final01','sewers-control01','sewers-final01','city-control01','city-final01','ground-control01','ground-final01']:
    p=ROOT/f'build/issue871-{label}-summary.json';d=json.loads(p.read_text());performance.append(d)
    target=e/'scenes'/label;copy(p,target/'summary.json')
    copy(ROOT/f'build/issue871-{label}-run.log',target/'wrapper.log');native(ROOT/d['directory'],target)
assert all(d['states']==performance[0]['states'] and d['census']==performance[0]['census'] for d in performance[:3])
for i in range(3,len(performance),2):
    a,b=performance[i:i+2]
    assert a['states']==b['states'] and a['census']==b['census'],(a['label'],b['label'])
copy(ROOT/'assets/validation_v5_17_110/evidence/production-performance.json',e/'prior-controls110.json')
for name in ['manifest.json','original.zs','candidate.zs']:copy(ROOT/'build/issue871-index-prototype01'/name,e/'prototype'/name)
for name in ['run_frame_profile871.py','analyze_frame871.py','prepare_thermal_profile871.py','analyze_thermal871.py','prepare_maintenance_profile871.py','analyze_maintenance871.py','prepare_surface_profile871.py','analyze_surface871.py','prepare_index_profile871.py','analyze_index871.py','archive_index871.py']:
    copy(LOCAL/name,e/'tooling'/name)
root_line="ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')"
portable="ROOT=Path(__file__).resolve().parents[2]"
for source,target in [('prepare_surface_index871.py','prepare_index.py'),('run_surface_index871.py','run_checks.py')]:
    s=(LOCAL/source).read_text(encoding='utf-8').replace(root_line,portable)
    s=s.replace("ROOT/'build/issue871-index01/distribution.json'","Path(__file__).with_name('evidence')/'probes/index01/distribution.json'")
    (public/target).write_text(s,encoding='utf-8',newline='\n')
copy(LOCAL/'index_checks871.zs',public/'index_checks871.zs')
copy(LOCAL/'index_contract871.txt',public/'CONTRACT.txt')
# Preserve path case while making the campaign runner relocatable.
s=(LOCAL/'run_scene871.py').read_text(encoding='utf-8').replace("root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","root=Path(__file__).resolve().parents[2]")
(public/'run_scene.py').write_text(s,encoding='utf-8',newline='\n')
(e/'native-checks.json').write_text(json.dumps(native_tests,indent=2)+'\n',encoding='utf-8',newline='\n')
(e/'production-performance.json').write_text(json.dumps(performance,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(native_tests=len(native_tests),scene_windows=len(performance),diagnostic_windows=len(diagnosis))))
