"""Run the author fixture with acquisition/active separation assertions in two native peers."""
from pathlib import Path
import argparse,importlib.util,json,datetime,zipfile
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('author_review',ROOT/'assets/validation_v5_13_9/run_author_suite.py')
suite=importlib.util.module_from_spec(spec);spec.loader.exec_module(suite)
original=suite.fixture
def fixture(path,scene):
    original(path,scene)
    with zipfile.ZipFile(path) as z:members={n:z.read(n) for n in z.namelist()}
    members['ZSCRIPT']+=b'\n#include "passives.zs"\n'
    members['MAPINFO']+=b'\ngameinfo { AddEventHandlers="CA513PassiveReview" }\n'
    members['passives.zs']=Path(__file__).with_name('passives.zs').read_bytes()
    with zipfile.ZipFile(path,'w') as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
suite.fixture=fixture
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--iwad',type=Path,required=True)
args=p.parse_args();args.smoke=True;args.port=32640
for field in ('runtime','engine','iwad'):setattr(args,field,getattr(args,field).resolve(strict=True))
home=ROOT/'build/issue440'/datetime.datetime.now().strftime('review-%Y%m%d-%H%M%S');home.mkdir(parents=True)
result=suite.launch(args,home,0)
checks=[]
for peer in sorted(Path(result['directory']).glob('peer*')):
    log=(peer/'engine.log').read_text(errors='replace')
    rows=[s for s in log.splitlines() if s.startswith('CA513REVIEW')]
    checks.append(dict(peer=peer.name,rows=rows,passed='CA513REVIEW COMPLETE player=1' in log and 'CA513REVIEW FAIL' not in log))
result['checks']=checks;result['passed']=result['passed'] and all(c['passed'] for c in checks)
(Path(__file__).with_name('results.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(passed=result['passed'],checks=checks),indent=2));raise SystemExit(not result['passed'])
