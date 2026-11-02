"""Exercise native title-menu selection and the explicit launch request."""
import argparse,datetime,json,subprocess,sys,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_sessions import digest
from caelum_standalone import request,MARKER,isolated_config

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True)
    p.add_argument('--language',choices=('es','enu'),default='es')
    p.add_argument('--console-event',action='store_true',help='Check the launch event via startup CFG; this does not verify a physical menu click.')
    a=p.parse_args()
    a.runtime=a.runtime.resolve(strict=True);a.engine=a.engine.resolve(strict=True)
    out=ROOT/'build/issue597'/datetime.datetime.now().strftime('menu-native-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    iw=Path('C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD')
    addon=out/'checks.pk3'
    with zipfile.ZipFile(addon,'w') as z:
        z.writestr('ZSCRIPT','version "4.14.2"\n#include "menu_probe.zs"\n')
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA597MenuProbe" }\n')
        z.writestr('menu_probe.zs',Path(__file__).with_name('menu_probe.zs').read_bytes())
    (out/'game.ini').write_bytes(isolated_config()+b'vid_maxfps=60\n')
    base=[str(a.engine),'-noautoload','-iwad',str(iw),'-file',str(a.runtime),str(addon)]
    preflight=subprocess.run(base+['-norun','-nosound','-errorlog',str(out/'compile.log'),'-config',str(out/'compile.ini')],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
    (out/'compile-process.log').write_bytes(preflight.stdout)
    if preflight.returncode!=1337:
        print(out)
        lines=(out/'compile.log').read_text(errors='replace').splitlines()
        start=next((i for i,line in enumerate(lines) if 'LoadActors:' in line),0)
        print('\n'.join(line for line in lines[start:] if not line.startswith('Vulkan extensions:')))
        raise SystemExit(1)
    (out/'start.cfg').write_text('wait 60; screenshot menu.png; '+('wait 150; event ca_standalone_launch; quit' if a.console_event else '')+'\n')
    command=base+['-config',str(out/'game.ini'),'-savedir',str(out),'+logfile',str(out/'engine.log'),
                 '+language',a.language,'+ca_standalone_bridge','1','+exec',str(out/'start.cfg'),'-window','-width','1000','-height','700']
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    error=None
    try:
        print(out,flush=True)
        result=subprocess.run(command,cwd=out,startupinfo=startup,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120)
        (out/'process.log').write_bytes(result.stdout);code=result.returncode
    except subprocess.TimeoutExpired as e:
        error='Native menu timeout';code=None;(out/'process.log').write_bytes(e.stdout or b'')
    log=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
    checks=[line for line in log.splitlines() if line.startswith('CA597 ')]
    launches=[request(line) for line in log.splitlines() if line.startswith(MARKER)]
    passed=code==0 and not error and 'CA597 RESULT menu' in log and 'CA597 FAIL' not in log and len(launches)==1
    report=dict(directory=str(out),runtime_sha256=digest(a.runtime),engine_sha256=digest(a.engine),language=a.language,
                exit=code,error=error,physical_button_verified=not a.console_event and code==0,checks=checks,launches=launches,passed=passed)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2));return not passed
if __name__=='__main__':raise SystemExit(main())
