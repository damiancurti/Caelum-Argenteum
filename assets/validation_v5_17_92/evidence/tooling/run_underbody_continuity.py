"""Verify unchanged production pilot saves across the #827 asset-only patch.

Reuse the accepted #283 fixture for parent-save, forward-load, candidate-save
and rollback-load. This does not test new anatomy in production actors.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);baseline=args.baseline.resolve(strict=True)
    existing=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in existing.lower():parser.error('Close the other native engine before this test.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    spec=importlib.util.spec_from_file_location('previous',ROOT/'assets/validation_5421/prepare.py')
    previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(baseline) as package:
        model=package.read('MODELDEF').decode().replace('\r\n','\n').split('// BEGIN DOMINGO 3D PILOT\n')[1].split('// END DOMINGO 3D PILOT')[0]
    model=model.replace('Model CaelumDomingoPilotBody','Model CA283ModelProxy')
    members={'ZSCRIPT':b'version "4.14.2"\n#include "equipment.zs"\n#include "probe.zs"\n',
        'equipment.zs':(ROOT/'assets/validation_541/session.zs').read_bytes(),
        'probe.zs':(ROOT/'assets/validation_5423/probe.zs').read_bytes(),'MODELDEF':model.encode(),
        'maps/MAP99.wad':previous.wad(),'maps/MAP98.wad':previous.wad(),
        'MAPINFO':b'gameinfo { PlayerClasses="CA283MotionPlayer" AddEventHandlers="CA283Probe" }\ncluster 99 { hub }\nmap MAP99 "Domingo continuity" { cluster=99 nointermission sky1="CABASKY",0 }\nmap MAP98 "Domingo continuity hub" { cluster=99 nointermission sky1="CABASKY",0 }\n'}
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in sorted(members.items()):package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    start='wait 100; netevent c283_setup; wait 35; con_notifytime 0; '
    done='netevent c283_done; wait 35; quit\n'
    plans=[
        ('baseline-save',baseline,start+'save pilot-old; wait 35; '+done,None),
        ('old-save-load',runtime,'wait 35; netevent c283_loaded; screenshot old-loaded.png; wait 5; '+done,'baseline-save/pilot-old.zds'),
        ('candidate-save',runtime,start+'save pilot-new; wait 35; '+done,None),
        ('rollback-load',baseline,'wait 35; netevent c283_loaded; '+done,'candidate-save/pilot-new.zds'),
    ]
    report={'issue':827,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'baseline_sha256':digest(baseline),
            'engine_sha256':digest(ENGINE),'fixture_sha256':digest(fixture),'runs':[]}
    for label,package,commands,save in plans:
        folder=out/label;folder.mkdir()
        if save:shutil.copyfile(out/save,folder/'resume.zds')
        (folder/'commands.cfg').write_text(commands)
        (folder/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nuse_mouse=false\nlanguage=enu\n')
        entry=['-loadgame','resume.zds'] if save else ['+map','MAP99']
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(package),str(fixture),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,stdout=stream,stderr=stream,startupinfo=startup)
            try:code=process.wait(timeout=150)
            except subprocess.TimeoutExpired:process.terminate();process.wait(timeout=10);code=process.returncode
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA283 FAIL'])]
        totals=re.findall(r'CA283 DONE passes=(\d+) failures=(\d+)',log)
        passed=code==0 and not errors and bool(totals) and all(int(p)>0 and int(f)==0 for p,f in totals)
        result={'phase':label,'passed':passed,'exit_code':code,'totals':totals,'errors':errors,
                'checks':[line for line in log.splitlines() if line.startswith('CA283 ')],
                'captures':{path.name:digest(path) for path in folder.glob('*.png')}}
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps({'phase':label,'passed':passed,'totals':totals,'errors':errors}),flush=True)
        if not passed:raise SystemExit(1)

if __name__=='__main__':main()
