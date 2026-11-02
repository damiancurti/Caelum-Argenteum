"""Exercise native Use, dialogue admission and capture for each actual peer."""
from pathlib import Path
import argparse,importlib.util,json,datetime,zipfile
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('capture_author',ROOT/'assets/validation_v5_13_9/run_author_suite.py')
suite=importlib.util.module_from_spec(spec);spec.loader.exec_module(suite)
original_fixture=suite.fixture;original_prepare=suite.prepare
def fixture(path,scene):
    original_fixture(path,scene)
    with zipfile.ZipFile(path) as z:members={n:z.read(n) for n in z.namelist()}
    members['ZSCRIPT']+=b'\n#include "capture.zs"\n'
    members['MAPINFO']+=b'\ngameinfo { AddEventHandlers="CA513CaptureReview" }\n'
    members['capture.zs']=Path(__file__).with_name('capture.zs').read_bytes()
    with zipfile.ZipFile(path,'w') as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
def prepare(selection,peer,*args):
    result=original_prepare(selection,peer,*args)
    slot=selection['role'];wait=155+slot*100
    with (peer/'controls.cfg').open('a',encoding='utf-8') as f:
        f.write(f'wait {wait}; +use; wait 3; -use; wait 5; screenshot "{(peer/"native-use.png").as_posix()}"; netevent ca_review_capture; wait {400-wait-8}; netevent ca_review_result; wait 30; quit\n')
    return result
suite.fixture=fixture;suite.prepare=prepare
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--iwad',type=Path,required=True)
args=p.parse_args();args.smoke=False;args.port=32642
for field in ('runtime','engine','iwad'):setattr(args,field,getattr(args,field).resolve(strict=True))
home=ROOT/'build/issue596'/datetime.datetime.now().strftime('capture-review-%Y%m%d-%H%M%S');home.mkdir(parents=True)
result=suite.launch(args,home,1);checks=[]
for peer in sorted(Path(result['directory']).glob('peer*')):
    log=(peer/'engine.log').read_text(errors='replace');rows=[s for s in log.splitlines() if s.startswith('CA513CAPTURE')]
    checks.append(dict(peer=peer.name,rows=rows,passed=len(rows)==6 and all(' PASS ' in s for s in rows)))
result['checks']=checks;result['passed']=result['passed'] and all(c['passed'] for c in checks)
Path(__file__).with_name('capture_results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(passed=result['passed'],checks=checks),indent=2));raise SystemExit(not result['passed'])
