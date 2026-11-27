"""Serialize approved peaceful campaign references and the native menu probe."""
from pathlib import Path
import argparse,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--presentation-layer',type=Path,required=True)
    p.add_argument('--only',nargs='+',choices=['MAP01','MAP02','MAP03','menu'])
    p.add_argument('--current-view',action='store_true')
    a=p.parse_args();runtime=a.runtime.resolve(strict=True);out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    common=['--runtime',str(runtime),'--iwad',str(runtime)]
    rows=[]
    for label,script,extra in [
        *[(m,'validation_v5_18_2/run_reference.py',['--map',m,'--players','1','--presentation-layer',str(a.presentation_layer.resolve(strict=True))]) for m in ['MAP01','MAP02','MAP03']],
        ('menu','validation_v5_13_4/run_menu_probe.py',['--engine','C:/Program Files (x86)/GZDoom/gzdoom.exe','--console-event'])]:
        if a.only and label not in a.only:continue
        if a.current_view and label!='menu':extra+=['--current-view']
        active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
        if '"gzdoom.exe"' in active.lower():raise RuntimeError('Another game is running; it has been preserved.')
        command=[sys.executable,'-X','utf8',str(ROOT/'assets'/script),*common,'--output',str(out/label),*extra]
        print('Starting '+label,flush=True)
        with (out/(label+'-runner.txt')).open('xb') as stream:result=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=stream)
        passed=result.returncode==0
        if passed and label!='menu':
            analysis=[sys.executable,str(ROOT/'assets/validation_v5_12_7/analyze_vulkan_presents.py'),str(out/label)]
            with (out/(label+'-analysis.txt')).open('xb') as stream:passed=subprocess.run(analysis,cwd=ROOT,stdout=stream,stderr=stream).returncode==0
        rows.append(dict(case=label,command=command,passed=passed))
        (out/'MATRIX.json').write_text(json.dumps(dict(issue=468,rows=rows,author_acceptance=False),indent=2)+'\n')
        print(json.dumps(rows[-1]),flush=True)
        if not passed:raise SystemExit('Inspect retained '+label+' evidence.')

if __name__=='__main__':main()
