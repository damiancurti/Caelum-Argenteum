"""Sweep both existing ram sizes through four forecourts and right-angle turns.

Calls the production physical route step32 times per diagnostic tic without
changing movement/rotation constants. No crew AI, combat timing or FPS claim.
Also retains fixed-heading legacy routes and reloads an in-progress turn.
"""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import time
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','candidate','output'):parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    runtime=args.runtime.resolve();candidate=args.candidate.resolve()
    layout=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text(encoding='utf-8'))
    methods='class CA454RamData : Object play {'
    for name,kind,values in [('GatePoint','vector3',['('+','.join(map(str,g['position']))+')' for g in layout['gates']]),('GateAngle','double',[str(g['outward_angle']) for g in layout['gates']]),('GateMaterial','int',[str(g['material']) for g in layout['gates']])]:
        methods+=f'static {kind} {name}(int i){{'+''.join(f'if(i=={i})return {v};' for i,v in enumerate(values))+f'return {values[0]};}}'
    methods+='}'
    passive=(Path(__file__).parent/'barracas_candidate_probe.zs').read_text(encoding='utf-8').split('class CA454CandidateProbe')[0]
    fixture=out/'ram-probe.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        files={'ZSCRIPT':'version "4.14.2"\n'+methods+'\n'+passive+'\n'+(Path(__file__).parent/'barracas_ram_probe.zs').read_text(encoding='utf-8'),
               'MAPINFO':'gameinfo { AddEventHandlers="CA454RamProbe" }\ndoomednums {31050=CA454PassiveCity}\n'}
        for name,source in files.items():archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),source)
    report={'issue':454,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'candidate_sha256':digest(candidate),'fixture_sha256':digest(fixture),'runs':[]}
    fatal=('Script error','Execution could not continue','VM execution aborted','Unknown type')
    for phase in ('fresh','reload'):
        folder=out/phase;folder.mkdir();package=folder/'caelum_argenteum_dev.pk3';shutil.copyfile(runtime,package)
        (folder/'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        commands='wait 210; netevent ca454_ram_start; wait 5; save checkpoint; ' if phase=='fresh' else 'wait 1; netevent ca454_ram_resume; '
        (folder/'commands.cfg').write_text(commands+'wait 1800; quit\n')
        entry=['+map','MAP03']
        if phase=='reload':shutil.copyfile(out/'fresh/checkpoint.zds',folder/'input.zds');entry=['-loadgame','input.zds']
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(package),str(candidate),str(fixture),'-config',str(folder/'isolated.ini'),'-savedir',str(folder),'-window','-width','1280','-height','720','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
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
        log=(folder/'engine.log').read_text(errors='replace');checks=[s for s in log.splitlines() if 'CA454 RAM' in s]
        passed=process.returncode==0 and not timeout and not any(s in log for s in fatal) and 'CA454 RAM COMPLETE passed=10 failures=0' in log
        if phase=='reload':passed=passed and 'CA454 RAM RESUME case=0' in log and 'revision=1 heading=1' in log
        report['runs'].append({'phase':phase,'passed':passed,'exit_code':process.returncode,'timeout':timeout,'checks':checks})
        (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report['runs'][-1]),flush=True)
        if not passed:raise SystemExit(1)


if __name__=='__main__':main()
