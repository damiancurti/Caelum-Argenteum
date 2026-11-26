"""Run bounded native sewer startup/save checks in disposable profiles.

This probe reports compilation, map-marker dispatch, clearance and Justice arena
lookup. It does not claim ordinary traversal or author acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
FATAL=('Script error','Execution could not continue','VM execution aborted','compile errors','DIED WITH FATAL ERROR','CA454 NATIVE FAIL')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def run(runtime,out,phase,fixture,save=None,extra='',from_hub=False):
    folder=out/phase;folder.mkdir()
    config=folder/'isolated.ini'
    config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\n'
        'vid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\n'
        'i_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
    commands=folder/'commands.cfg'
    prefix='wait 140; changemap MAP02; ' if from_hub else ''
    commands.write_text(prefix+'wait 140; netevent ca454_probe; wait 5; save checkpoint; '
        'wait 10; screenshot scene.png; '+extra+'wait 10; quit\n',encoding='utf-8')
    if save is not None:
        (folder/'input.zds').write_bytes(save.read_bytes())
    entry=['+map','MAP02'] if save is None else ['-loadgame','input.zds']
    command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(fixture),
        '-config',str(config),'-savedir',str(folder),'-window','-width','960','-height','720',
        '+logfile',str(folder/'engine.log'),*entry,'+exec',str(commands)]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    print(f'#454 native {phase}: {folder}',flush=True)
    timed_out=False
    with (folder/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream)
        try:
            deadline=time.monotonic()+120
            while process.poll() is None:
                log=folder/'engine.log'
                if log.exists() and any(word in log.read_text(errors='replace') for word in FATAL):break
                if time.monotonic()>=deadline:timed_out=True;break
                time.sleep(.25)
        finally:
            if process.poll() is None:process.terminate();process.wait(timeout=10)
    log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
    errors=[word for word in FATAL if word in log]
    passed=not timed_out and not errors and process.returncode==0 and 'CA454 NATIVE PASS map=MAP02' in log and (folder/'checkpoint.zds').exists()
    return dict(phase=phase,passed=passed,timed_out=timed_out,errors=errors,exit_code=process.returncode,command=command)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--load',type=Path)
    parser.add_argument('--hub',action='store_true',help='Also preserve and reload MAP02 inside a stored native hub')
    parser.add_argument('--from-hub',action='store_true',help='The supplied --load save is on MAP03 with MAP02 in its hub')
    args=parser.parse_args();runtime=args.runtime.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    fixture=out/'probe.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,data in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"\n',
            'MAPINFO':b'gameinfo { AddEventHandlers="CA454Probe" }\n','probe.zs':(HERE/'native_probe.zs').read_bytes()}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),data)
    report=dict(issue=454,runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=digest(fixture),scope=__doc__.strip(),runs=[])
    for phase in (('fresh','reload','hub_reload') if args.hub else ('fresh','reload')):
        save=args.load.resolve() if phase=='fresh' and args.load else out/'fresh/checkpoint.zds' if phase=='reload' else None
        if phase=='hub_reload':save=out/'fresh/hub.zds'
        extra='wait 5; god; changemap MAP03; wait 140; save hub; wait 5; changemap MAP02; wait 140; netevent ca454_probe; ' if phase=='fresh' and args.hub else ''
        result=run(runtime,out,phase,fixture,save,extra,phase=='hub_reload' or (phase=='fresh' and args.from_hub))
        report['runs'].append(result)
        (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
        print(f'#454 {phase}: {"PASS" if result["passed"] else "FAIL"}',flush=True)
        if not result['passed']:raise SystemExit(1)

if __name__=='__main__':main()
