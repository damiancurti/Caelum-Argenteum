"""Capture actual before/after southern inspection-chamber geometry."""
from pathlib import Path
import argparse
import json
from run_native import run,digest,ENGINE
from build_scene_probe import build

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--before',type=Path,required=True);parser.add_argument('--after',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    out=args.output.resolve();out.mkdir(parents=True,exist_ok=False);fixture=out/'scene.pk3';points=build(fixture)
    results=[]
    for name,path in [('before',args.before),('after',args.after)]:
        runtime=path.resolve();result=run(runtime,out,name,fixture)
        result['runtime_sha256']=digest(runtime);results.append(result)
        if not result['passed']:break
    report=dict(issue=454,scope=__doc__.strip(),cameras=points,engine_sha256=digest(ENGINE),fixture_sha256=digest(fixture),runs=results)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'passed':len(results)==2 and all(r['passed'] for r in results),'output':str(out)}))
    raise SystemExit(not(len(results)==2 and all(r['passed'] for r in results)))

if __name__=='__main__':main()
