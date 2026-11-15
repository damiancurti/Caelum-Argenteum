"""Capture four inherited/default pickup states beside their native parent references."""
from pathlib import Path
import argparse,json,re,struct,zipfile
from run_inventory_model_audit import ROOT,ENGINE,digest,native_run,included_sources,without_comments

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    cases=[('CaelumWeaponPickup','CSWD'),('CA_LimboMagicImplement','CSWD'),('CaelumCarbineAmmo','CCAA'),('CaelumJavelinAmmo','CCAA')];dimensions={}
    with zipfile.ZipFile(runtime) as package:
        models=included_sources(package,'MODELDEF')
        for kind,sprite in [cases[0],cases[2]]:
            found=[]
            for text in models.values():
                for body in re.findall(r'\bModel\s+'+kind+r'\s*\{([^}]+)\}',without_comments(text)):
                    if not re.search(r'\bFrameIndex\s+'+sprite+r'\s+A\s+0\s+0\b',body):continue
                    path=re.search(r'\bPath\s+"([^"]+)"',body)[1];name=re.search(r'\bModel\s+0\s+"([^"]+)"',body)[1];found.append(path+'/'+name)
            if len(found)!=1:raise ValueError('Ambiguous native parent reference: '+kind)
            blob=package.read(found[0]);header=struct.unpack_from('<4sI64s9I',blob);bounds=struct.unpack_from('<6f',blob,header[8]);dimensions[sprite]=dict(model=found[0],extent=max(bounds[i+3]-bounds[i] for i in range(3)),height=(bounds[2]+bounds[5])/2)
    source=Path(__file__).with_name('inherited_defaults.zs').read_text(encoding='utf-8').replace('EXTENTS',','.join(str(dimensions[s]['extent']) for _,s in cases)).replace('HEIGHTS',','.join(str(dimensions[s]['height']) for _,s in cases))
    commands='screenblocks 12; crosshair 0; con_notifytime 0; wait 140; netevent ca785_prepare; wait 35; netevent ca785_verify; wait 5; screenshot overview.png; '
    captures=[]
    for index in range(4):
        for angle in [90,160,270]:
            name=f'detail-{index}-{angle}.png';captures.append(name);commands+=f'netevent ca785_detail {index} {angle}; wait 5; screenshot {name}; '
    commands+='netevent ca785_verify; wait 5; quit\n'
    code,log,errors,fixture_sha=native_run(runtime,out,source,'CA785InheritedViews',commands)
    assertions=len(re.findall(r'^CA785 PASS ',log,re.M));completions=re.findall(r'CA785 COMPLETE failures=(\d+)',log)
    if assertions!=32 or completions!=['0','0']:errors.append('Incomplete native metadata/control checks')
    if any(not (out/n).is_file() for n in captures+['overview.png']):errors.append('Missing capture')
    result=dict(issue=785,scope=__doc__,runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=fixture_sha,cases=cases,dimensions=dimensions,exit_code=code,assertions=assertions,errors=errors,passed=code==0 and not errors,captures=captures,author_accepted=False,visual_acceptance='Requires inspection; assertions only verify native states, world metadata and camera controls.')
    (out/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result),flush=True)
    if not result['passed']:raise SystemExit(1)

if __name__=='__main__':main()
