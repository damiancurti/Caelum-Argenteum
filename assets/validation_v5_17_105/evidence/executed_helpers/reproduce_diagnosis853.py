"""Reproduce diagnostic overlays and the intentionally failing baseline fixture."""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';dest=root/'assets/validation_v5_17_105';reports=[]
for label,flags in [('breath02',[]),('targets02',['--targets'])]:
    out=root/('build/issue853-repro-'+label)
    subprocess.run([sys.executable,str(dest/'prepare_breath.py'),'--runtime','build/issue851-local03.pk3','--output',str(out),*flags],cwd=root,check=True,stdout=subprocess.DEVNULL)
    before=(root/('build/issue853-'+label)/'services.pk3').read_bytes();assert before==(out/'services.pk3').read_bytes()
    reports.append(dict(label=label,exact=True,sha256=hashlib.sha256(before).hexdigest()))
out=root/'build/issue853-repro-navigation01'
with (root/'build/issue853-repro-navigation01.log').open('wb') as log:
    code=subprocess.run([sys.executable,str(dest/'run_navigation.py'),'--runtime','build/issue851-local03.pk3','--output',str(out)],cwd=root,stdout=log,stderr=log).returncode
result=json.loads((out/'RESULTS.json').read_text());assert code==1 and result['exit_code']==0 and not result['passed']
assert result['errors']==['CA836 EDGE FAIL','result=FAIL']
assert sum(' EDGE PASS ' in s for s in result['checks'])==6 and sum(' EDGE FAIL ' in s for s in result['checks'])==2
assert (out/'checks.pk3').read_bytes()==(root/'build/issue853-navigation01/checks.pk3').read_bytes()
assert 'before=35 after=0 previous_visible=0' in (out/'engine.log').read_text(encoding='utf-8',errors='replace')
target=dest/'evidence/reproduction/navigation';target.mkdir(parents=True)
for path in out.iterdir():
    if path.is_file() and path.suffix.lower() in {'.json','.log','.zs','.cfg','.ini'}:shutil.copyfile(path,target/path.name)
reports.append(dict(label='portable_navigation_baseline',exact=True,engine_exit_code=0,expected_regression=True,passing_setup_resource_checks=6,failing_recognition_checks=2))
(dest/'evidence/TOOL_REPRODUCTION.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(reports))
