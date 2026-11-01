"""Validate every numbered author scenario and the two new common-save recoveries."""
import argparse,datetime,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','engine','iwad'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--port',type=int,default=32720)
    args=parser.parse_args()
    out=ROOT/'build/issue596'/datetime.datetime.now().strftime('final-%Y%m%d-%H%M%S');out.mkdir(parents=True)
    base=[sys.executable,str(Path(__file__).with_name('run_author_suite.py')),'--smoke']
    for name in ('runtime','engine','iwad'):base+=['--'+name,str(getattr(args,name).resolve(strict=True))]
    reports=[];saved={}
    for index in range(16):
        scene=index if index<14 else index-2
        previous=set((ROOT/'build/issue596').glob('author-suite-*'))
        command=base+['--scene',str(scene),'--port',str(args.port+index*2)]
        if index>=14:command+=['--reload',str(saved[scene])]
        print(f'Scenario {scene+1}/14'+(' recovery' if index>=14 else ''),flush=True)
        with (out/f'{index}.log').open('wb') as log:
            result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        if result.returncode:
            print((out/f'{index}.log').read_text(errors='replace'),flush=True);return 1
        current=(set((ROOT/'build/issue596').glob('author-suite-*'))-previous).pop()
        path=next(current.glob('scene*/results.json'));report=json.loads(path.read_text())
        assert report['passed'],path
        reports.append(report);saved[scene]=path
        (out/'results.json').write_text(json.dumps(reports,indent=2)+'\n')
        print('PASS '+str(path),flush=True)
    print('FINAL SWEEP '+str(out),flush=True)
    return 0
if __name__=='__main__':raise SystemExit(main())
