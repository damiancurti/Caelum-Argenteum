"""Exercise each manual fixture and a common saved restart, without author acceptance."""
from pathlib import Path
from types import SimpleNamespace
import argparse,datetime,json
import run_author_suite as suite


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('engine','runtime','anchor'):
        parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    for name in ('engine','runtime','anchor'):
        setattr(args,name,getattr(args,name).resolve(strict=True))
    args=SimpleNamespace(**vars(args),smoke=True,diagnose_ui=False)
    home=suite.ROOT/'build/issue435'/datetime.datetime.now().strftime('author-smoke-%Y%m%d-%H%M%S-%f')
    home.mkdir()
    reports=[]
    for scene in range(7):
        result=suite.launch(args,home,scene)
        reports.append(result)
        (home/'results.json').write_text(json.dumps(dict(runs=reports,passed=False),indent=2)+'\n')
        if not result['passed']:raise RuntimeError('Manual fixture failed; see '+str(home))
        if scene==0:
            restored=suite.launch(args,home,scene,result)
            reports.append(restored)
            if not restored['passed']:raise RuntimeError('Common restart failed; see '+str(home))
            if restored['recovery']['recovery']['revision']<=result['recovery']['recovery']['revision']:
                raise RuntimeError('The restarted session did not publish a new checkpoint')
    report=dict(runs=reports,passed=True,author_accepted=False,
        scope='Seven native fixture startups and one saved restart; not gameplay acceptance.')
    (home/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(directory=str(home),passed=True)))


if __name__=='__main__':main()
