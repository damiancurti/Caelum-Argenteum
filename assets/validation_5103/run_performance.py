"""Compare common campaign observations; frame callbacks are not display presents."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue428/performance'
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def stats(values):
    if not values:return None
    values=sorted(values);n=len(values)
    return dict(samples=n,mean_ms=sum(values)/n,p95_ms=values[int((n-1)*.95)],
        p99_ms=values[int((n-1)*.99)],max_ms=values[-1])

def main():
    p=argparse.ArgumentParser();p.add_argument('label');p.add_argument('--package',type=Path,required=True)
    p.add_argument('--overlay',type=Path);p.add_argument('--map',default='MAP03');p.add_argument('--siege',action='store_true')
    p.add_argument('--ground',action='store_true');args=p.parse_args();OUT.mkdir(parents=True,exist_ok=True)
    running=subprocess.check_output(['powershell','-NoProfile','-Command',"Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"],text=True)
    if running.strip():raise SystemExit('Preserve the existing native process before another run.')
    log=OUT/(args.label+'.log')
    if log.exists():raise SystemExit('Choose a fresh label to retain previous evidence.')
    src=(HERE/'performance.zs').read_text().replace('const SIEGE=0;',f'const SIEGE={int(args.siege)};').replace('const GROUND=0;',f'const GROUND={int(args.ground)};')
    addon=OUT/(args.label+'.pk3')
    with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as z:
        for name,data in {'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n','performance.zs':src.encode(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA510Performance" }\n'}.items():
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    ini=OUT/(args.label+'.ini');ini.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\n'
        'vid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\n'
        'i_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\n'
        'snd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8')
    cfg=OUT/(args.label+'.cfg');cfg.write_text(f'wait {4350 if args.siege else 1100}; event ca510_frames; wait 3; quit\n')
    packages=[args.package.resolve(),addon]
    if args.overlay:packages.append(args.overlay.resolve())
    command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',*map(str,packages),'-config',str(ini),
        '-window','-width','1280','-height','720','-rngseed','428','+logfile',str(log),'+map',args.map,'+exec',str(cfg)]
    info=dict(command=command,packages={str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in packages})
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
    start=time.time();proc=subprocess.Popen(command,cwd=OUT,startupinfo=startup);info['pid']=proc.pid
    failed=False
    while proc.poll() is None:
        text=log.read_text(encoding='utf-8',errors='replace') if log.exists() else ''
        if any(x in text for x in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')) or time.time()-start>420:
            proc.terminate();failed=True;break
        time.sleep(.5)
    proc.wait(timeout=10);text=log.read_text(encoding='utf-8',errors='replace') if log.exists() else ''
    info.update(exit_code=proc.returncode,elapsed_seconds=round(time.time()-start,3),
        simulation=stats([float(x) for x in re.findall(r'CA510 TIC ([\d.]+)',text)]),
        render_callbacks=stats([float(x) for x in re.findall(r'CA510 FRAME ([\d.]+)',text)]),
        census=[x for x in text.splitlines() if 'CA510 CENSUS' in x],
        limit='RenderOverlay callbacks do not measure displayed frames; presentation capture remains separate.')
    (OUT/(args.label+'.json')).write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in info.items() if k not in ('command','packages')},indent=2))
    if failed or proc.returncode or 'CA510 RESULT' not in text or info['render_callbacks'] is None:
        print('\n'.join(text.splitlines()[-18:]));raise SystemExit('Campaign performance run failed; evidence retained.')

if __name__=='__main__':main()
