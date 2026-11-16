"""Check that GZDoom registers all diagnostic gallery keys without changing global settings."""
from pathlib import Path
import argparse,json,subprocess
from build_gallery import ROOT,SOURCE,build,digest
from run_gallery import ENGINE,IWAD

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    fixture,_=build(out);config=json.loads((SOURCE/'GALLERY.json').read_text())
    binds=''.join(f'bind {v["key"]} "netevent ca825_view {i}"; bind {v["key"]}; ' for i,v in enumerate(config['views']))
    (out/'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_maxfps=60\n')
    (out/'commands.cfg').write_text('wait 70; '+binds+'wait 5; quit\n')
    command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'engine.log'),'+map',config['map'],'+exec',str(out/'commands.cfg')]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream)
        try:code=process.wait(timeout=90)
        except subprocess.TimeoutExpired:process.terminate();code=process.wait(timeout=10)
    text=(out/'engine.log').read_text(errors='replace')
    errors=[line for line in text.splitlines() if any(token.lower() in line.lower() for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unknown key'])]
    lines=[line for line in text.splitlines() if 'netevent ca825_view' in line]
    recorded={line.strip() for line in lines}
    expected={f'"{v["key"].lower()}" = "netevent ca825_view {i}"' for i,v in enumerate(config['views'])}
    missing=sorted(expected-{line.lower() for line in recorded})
    result=dict(issue=config['issue'],runtime_sha256=digest(runtime.read_bytes()),exit_code=code,errors=errors,recorded=lines,missing=missing,passed=code==0 and not errors and not missing,scope='Native bind registration and query; author interactive keypress acceptance remains pending.')
    (out/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result));raise SystemExit(not result['passed'])

if __name__=='__main__':main()
