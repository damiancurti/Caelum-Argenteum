"""Check aimed rock containment using two native User3 presses in the author scene."""
from pathlib import Path
import argparse,importlib.util,json,datetime,zipfile
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('rock_author',ROOT/'assets/validation_v5_13_9/run_author_suite.py')
suite=importlib.util.module_from_spec(spec);spec.loader.exec_module(suite)
original_fixture=suite.fixture;original_prepare=suite.prepare
def fixture(path,scene):
    original_fixture(path,scene)
    with zipfile.ZipFile(path) as z:members={n:z.read(n) for n in z.namelist()}
    members['ZSCRIPT']+=b'\n#include "rock.zs"\n'
    members['MAPINFO']+=b'\ngameinfo { AddEventHandlers="CA513RockReview" }\n'
    members['rock.zs']=Path(__file__).with_name('rock.zs').read_bytes()
    with zipfile.ZipFile(path,'w') as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
def prepare(selection,peer,*args):
    result=original_prepare(selection,peer,*args)
    with (peer/'controls.cfg').open('a',encoding='utf-8') as f:
        if selection['role']==0:
            f.write(f'wait 180; netevent ca_review_rock_setup; netevent ca513_place; wait 10; +user3; wait 2; -user3; wait 10; screenshot "{(peer/"rock-before.png").as_posix()}"; +user3; wait 2; -user3; wait 10; netevent ca_review_rock_result; screenshot "{(peer/"rock-after.png").as_posix()}"; wait 136; quit\n')
        else:f.write('wait 355; quit\n')
    return result
suite.fixture=fixture;suite.prepare=prepare
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--iwad',type=Path,required=True)
args=p.parse_args();args.smoke=False;args.port=32644
for field in ('runtime','engine','iwad'):setattr(args,field,getattr(args,field).resolve(strict=True))
home=ROOT/'build/issue440'/datetime.datetime.now().strftime('rock-review-%Y%m%d-%H%M%S');home.mkdir(parents=True)
result=suite.launch(args,home,3);checks=[]
for peer in sorted(Path(result['directory']).glob('peer*')):
    log=(peer/'engine.log').read_text(errors='replace');rows=[s for s in log.splitlines() if s.startswith('CA513ROCK')]
    checks.append(dict(peer=peer.name,rows=rows,passed='CA513ROCK PASS' in log and 'CA513ROCK FAIL' not in log))
result['checks']=checks;result['passed']=result['passed'] and all(c['passed'] for c in checks)
Path(__file__).with_name('rock_results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(passed=result['passed'],checks=checks),indent=2));raise SystemExit(not result['passed'])
