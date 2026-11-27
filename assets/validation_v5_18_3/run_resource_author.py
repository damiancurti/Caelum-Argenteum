"""Prepare the verified standalone resource fixture for unlimited author review."""
from pathlib import Path
import argparse,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--interactive',action='store_true');a=p.parse_args()
    out=a.output.resolve();out.relative_to(ROOT/'build');out.parent.mkdir(parents=True,exist_ok=True)
    record=out.parent/(out.name+'-resource-prepared.json')
    cmd=[sys.executable,'-X','utf8',str(ROOT/'assets/validation_v5_17_123/prepare_runner.py'),
        '--script',str(ROOT/'assets/validation_v5_18_1/run_standalone.py'),'--record',str(record),
        '--','--package',str(a.runtime.resolve(strict=True)),'--output',str(out)]
    with (out.parent/(out.name+'-resource-prepare.log')).open('xb') as log:
        subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=log,check=True)
    prepared=json.loads(record.read_text());command=prepared['command']
    cfg=Path(command[command.index('+exec')+1])
    cfg.write_text('wait 105; event ca467_title; playersounds; wait 5; event ca467_close; map MAP01; wait 210; netevent ca467_world 1; wait 5; event ca467_close; event ca467_gallery 1; bind F1 "event ca467_gallery 1"; bind F2 "event ca467_gallery 0";\n',encoding='utf8')
    print('F1 galería de efectos, sangre, armadura y palanca / F2 volver al mundo. Escape permite guardar; esta escena usa el juego independiente y un observador local.',flush=True)
    if a.interactive:raise SystemExit(subprocess.call(command,cwd=out))
    (out/'prepared.json').write_text(json.dumps(prepared,indent=2)+'\n')

if __name__=='__main__':main()
