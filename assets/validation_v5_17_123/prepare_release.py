"""Bind deterministic review options to a supplied complete development runtime.

The inputs are generated local artifacts from their public source builders.
Engine, IWAD, packages and test saves are never redistributed by this tool.
"""
from pathlib import Path
import argparse,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','remasters','vaults','joinery','iqm-model','output']:
        p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args()
    runtime=a.runtime.resolve(strict=True)
    inputs={name:getattr(a,name.replace('-','_')).resolve(strict=True) for name in ['remasters','vaults','joinery','iqm-model']}
    out=a.output.resolve();out.relative_to(ROOT/'build');assert out!=ROOT/'build';out.mkdir(parents=True,exist_ok=False)
    def execute(script,*arguments):
        with (out/(Path(script).stem+'.log')).open('xb') as log:
            subprocess.run([sys.executable,'-X','utf8',str(ROOT/'assets/generators'/script),*map(str,arguments)],cwd=ROOT,stdout=log,stderr=log,check=True)
    execute('build_environment_review.py','--runtime',runtime,'--remasters',inputs['remasters'],'--vaults',inputs['vaults'],'--joinery',inputs['joinery'],'--output',out/'components')
    execute('build_interior_ceiling_review.py','--runtime',runtime,'--composition',out/'components','--output',out/'ceilings')
    execute('build_municipal_review.py','--runtime',runtime,'--composition',out/'ceilings','--output',out/'municipal')
    execute('build_sewer_waterline_review.py','--runtime',runtime,'--composition',out/'municipal','--output',out/'waterline')
    execute('generate_nahuelito_model.py','--output',out/'nahuelito')
    config=dict(issue=889,runtime=str(runtime),components=str(out/'components'),ceilings=str(out/'ceilings'),
        municipal_control=str(out/'ceilings/vaults.pk3'),municipal_overlay=str(out/'municipal/municipal.pk3'),
        municipal_manifest=str(out/'municipal/MANIFEST.json'),waterline_control=str(out/'municipal/municipal.pk3'),
        waterline_overlay=str(out/'waterline/waterline.pk3'),waterline_manifest=str(out/'waterline/MANIFEST.json'),
        nahuelito_model=str(out/'nahuelito'),iqm_model=str(inputs['iqm-model']))
    path=out/'session-config.json';path.write_text(json.dumps(config,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Prepared terminal configuration: '+str(path))

if __name__=='__main__':
    main()
