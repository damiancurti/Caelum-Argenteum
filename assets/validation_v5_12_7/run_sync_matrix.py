"""Recheck native consistency from fresh seeds, retaining every failed run."""
from pathlib import Path
import argparse,datetime,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--engine',type=Path,required=True)
    p.add_argument('--previous-runtime',type=Path)
    args=p.parse_args()
    base=ROOT/'build/issue435'
    out=base/datetime.datetime.now().strftime('sync-matrix-%Y%m%d-%H%M%S-%f');out.mkdir()
    reports=[]
    def run(label,script,arguments,prefix,expected=True,runtime=None):
        before=set(base.glob(prefix+'*'))
        cmd=[sys.executable,str(HERE/script),'--runtime',str(runtime or args.runtime),'--engine',str(args.engine),*map(str,arguments)]
        with (out/(label+'.log')).open('wb') as f:
            result=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT,timeout=330)
        created=set(base.glob(prefix+'*'))-before
        if len(created)!=1:raise RuntimeError(f'{label}: ambiguous evidence directory')
        folder=created.pop()
        report=json.loads((folder/'results.json').read_text())
        reports.append(dict(label=label,directory=str(folder),command=cmd,exit=result.returncode,
            expected_pass=expected,matched_expectation=bool(report['passed'])==expected,result=report))
        (out/'results.json').write_text(json.dumps(reports,indent=2)+'\n')
        print(label,'matched=',reports[-1]['matched_expectation'],folder,flush=True)
        if not reports[-1]['matched_expectation']:raise RuntimeError(f'{label} failed; retained complete evidence')
        return folder
    if args.previous_runtime:
        run('old-camera-negative','run_session_probe.py',['--players',2],'session-',False,args.previous_runtime)
    seeds={}
    for count in (2,4,8):
        folder=run(f'seed-{count}','run_session_probe.py',['--players',count],'session-')
        seeds[count]=folder/'peer0/save00.zds'
        run(f'combat-{count}','run_session_probe.py',['--players',count,'--combat','--source',seeds[count]],'session-')
    run('trade-craft-2','run_session_probe.py',['--players',2,'--gameplay','--source',seeds[2]],'session-')
    for scenario in ('truco','trucazo','arena','fool'):
        run(scenario,'run_managed_scenario.py',['--anchor',seeds[2],'--scenario',scenario],'managed-'+scenario+'-')
    print('Complete:',out,flush=True)

if __name__=='__main__':main()
