"""Run only the affected native terminal paths, serially, retaining each result."""
from pathlib import Path
import argparse,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build/author-889')
    out.mkdir(parents=True,exist_ok=False);rows=[]
    base=[sys.executable,'-X','utf8',str(ROOT/'assets/validation_v5_17_123/author_terminal.py'),
          '--config',str(args.config.resolve(strict=True)),'--smoke']
    cases=[('motion','action','motion-author'),('motion-reload','reload',out/'motion'),
           ('resources','action','independent-resources'),('resources-reload','reload',out/'resources'),
           ('campaign','action','campaign'),('equipment','action','equipment'),
           ('equipment-reload','reload',out/'equipment'),
           ('ceilings','action','env883-house-vaults'),
           ('waterline','action','env887-candidate'),
           ('waterline-reload','reload',out/'waterline')]
    for label,kind,value in cases:
        destination=out/label
        command=base+['--output',str(destination)]
        command+=['--action',value] if kind=='action' else ['--reload',str(value),'--save',str(value/'terminal-smoke.zds')]
        with (out/(label+'-runner.txt')).open('xb') as stream:
            result=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=stream)
        path=destination/'RESULTS.json'
        data=json.loads(path.read_text()) if path.exists() else dict(passed=False,runner_exit=result.returncode)
        row=dict(case=label,**data);rows.append(row)
        (out/'MATRIX.json').write_text(json.dumps(dict(issue=469,passed=all(r['passed'] for r in rows),rows=rows),indent=2)+'\n')
        print(json.dumps(row),flush=True)
        if result.returncode or not data['passed']:raise SystemExit(1)

if __name__=='__main__':main()
