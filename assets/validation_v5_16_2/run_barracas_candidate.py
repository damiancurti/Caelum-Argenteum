"""Test candidate city services and private-house native hub routing.

A passive fixture controller suppresses obsolete six-lane siege deployment.
This is not a production siege, ordinary house Use/ACK or author acceptance.
"""
from pathlib import Path
import argparse
import json
import re
import shutil
import subprocess
import sys
import time
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest
sys.path.insert(0,str(ROOT/'assets/generators'))
from generate_barracas_preview import local_point


def factory_data():
    layout=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text(encoding='utf-8'))
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    interior=json.loads((ROOT/'assets/map06_port/INTERIORS.json').read_text(encoding='utf-8'))
    classes=dict(re.findall(r'\b(\d+)\s*=\s*(\w+)',(ROOT/'src/MAPINFO').read_text(encoding='utf-8')))
    by_id={b['id']:b for b in layout['buildings']};points=[];kinds=[]
    for i,old in enumerate(b for b in city['buildings'] if b['kind']=='factory'):
        profile=interior['factory_profiles'][i%len(interior['factory_profiles'])]
        for j,kind in enumerate(profile['stations']):
            points.append((*local_point(by_id[old['id']],*interior['station_positions'][j]),0))
            kinds.append(classes[str(interior['station_editors'][kind])])
    source=f'class CA454FactoryExpected : Object play {{ const COUNT={len(points)};static vector3 Point(int i){{'
    source+=''.join(f'if(i=={i})return ({",".join(map(str,p))});' for i,p in enumerate(points))+'return (0,0,0);}'
    source+='static Name Kind(int i){'+''.join(f"if(i=={i})return '{k}';" for i,k in enumerate(kinds))+"return 'None';}}"
    return source.encode()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--candidate',type=Path,help='Optional map overlay; omit for installed runtime')
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--fresh-only',action='store_true',help='Repeat changed fresh/hub checks without repeating an unchanged reload')
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    runtime=args.runtime.resolve();candidate=args.candidate.resolve() if args.candidate else None
    fixture=out/'candidate-probe.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        files={'ZSCRIPT':b'version "4.14.2"\n#include "factory.zs"\n#include "probe.zs"',
               'factory.zs':factory_data(),
               'probe.zs':(Path(__file__).parent/'barracas_candidate_probe.zs').read_bytes(),
               'MAPINFO':b'gameinfo { AddEventHandlers="CA454CandidateProbe" }\ndoomednums {31050=CA454PassiveCity}\n'}
        for name,data in files.items():archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),data)
    report={'issue':454,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'candidate_sha256':digest(candidate) if candidate else None,'runs':[]}
    fatal=('Script error','Execution could not continue','VM execution aborted','Unknown type','CANDIDATE FAIL','CANDIDATE VENDOR FAIL','CANDIDATE ARRIVAL FAIL','CANDIDATE VEHICLE FAIL')
    for phase in (('fresh',) if args.fresh_only else ('fresh','reload')):
        folder=out/phase;folder.mkdir()
        package=folder/'caelum_argenteum_dev.pk3';shutil.copyfile(runtime,package)
        (folder/'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
        commands='wait 210; netevent ca454_candidate; wait 10; screenshot quay.png; save checkpoint; wait 10; '
        if phase=='fresh':commands+='netevent ca454_inside; wait 140; netevent ca454_candidate; wait 10; netevent ca454_outside; wait 140; netevent ca454_candidate_return; wait 10; screenshot return.png; '
        (folder/'commands.cfg').write_text(commands+'wait 10; quit\n',encoding='utf-8')
        entry=['+map','MAP03']
        if phase=='reload':shutil.copyfile(out/'fresh/checkpoint.zds',folder/'input.zds');entry=['-loadgame','input.zds']
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(package),*([str(candidate)] if candidate else []),str(fixture),'-config',str(folder/'isolated.ini'),'-savedir',str(folder),'-window','-width','1280','-height','720','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+180;timeout=False
            try:
                while process.poll() is None:
                    path=folder/'engine.log'
                    if path.exists() and any(s in path.read_text(errors='replace') for s in fatal):break
                    if time.monotonic()>deadline:timeout=True;break
                    time.sleep(.25)
            finally:
                if process.poll() is None:process.terminate();process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace');checks=[s for s in log.splitlines() if 'CA454 CANDIDATE' in s]
        passed=process.returncode==0 and not timeout and not any(s in log for s in fatal) and log.count('CA454 CANDIDATE PASS')==(3 if phase=='fresh' else 1)
        captures=['quay.png']+(['return.png'] if phase=='fresh' else [])
        passed=passed and all((folder/name).exists() for name in captures)
        result={'phase':phase,'passed':passed,'exit_code':process.returncode,'timed_out':timeout,'checks':checks};report['runs'].append(result)
        (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(result),flush=True)
        if not passed:raise SystemExit(1)


if __name__=='__main__':main()
