"""Check600 exterior paths with bounded native TryMove sampling and save reload.

The fixture suppresses siege and ignores actors, retaining geometry collision,
the defender body and exact floor support. It does not validate AI/crowds.
"""
from pathlib import Path
import argparse,json,shutil,subprocess,time,zipfile
from run_barracas_legacy import ROOT,ENGINE,IWAD,digest


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','candidate','output'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--fresh-only',action='store_true');args=parser.parse_args()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    runtime=args.runtime.resolve();candidate=args.candidate.resolve();fixture=out/'deployment-probe.pk3'
    passive=(Path(__file__).parent/'barracas_candidate_probe.zs').read_text().split('class CA454CandidateProbe')[0]
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,source in {'ZSCRIPT':'version "4.14.2"\n'+passive+(Path(__file__).parent/'barracas_deployment_probe.zs').read_text(),
                            'MAPINFO':'gameinfo { AddEventHandlers="CA454DeploymentProbe" }\ndoomednums {31050=CA454PassiveCity}\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),source)
    report={'issue':454,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'candidate_sha256':digest(candidate),'fixture_sha256':digest(fixture),'runs':[]}
    fatal=('Script error','Execution could not continue','VM execution aborted','Unknown type')
    for phase in (('fresh',) if args.fresh_only else ('fresh','reload')):
        folder=out/phase;folder.mkdir();package=folder/'caelum_argenteum_dev.pk3';shutil.copyfile(runtime,package)
        (folder/'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        (folder/'commands.cfg').write_text('wait 210; netevent ca454_deployment; wait 3500; save checkpoint; wait 10; quit\n')
        entry=['+map','MAP03']
        if phase=='reload':shutil.copyfile(out/'fresh/checkpoint.zds',folder/'input.zds');entry=['-loadgame','input.zds']
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(package),str(candidate),str(fixture),'-config',str(folder/'isolated.ini'),'-savedir',str(folder),'-window','-width','1280','-height','720','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (folder/'process.log').open('wb') as log:
            process=subprocess.Popen(command,cwd=folder,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+240;timeout=False
            try:
                while process.poll() is None:
                    path=folder/'engine.log'
                    if path.exists() and any(s in path.read_text(errors='replace') for s in fatal):break
                    if time.monotonic()>deadline:timeout=True;break
                    time.sleep(.25)
            finally:
                if process.poll() is None:process.terminate();process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace');checks=[line for line in log.splitlines() if 'CA454 DEPLOY' in line]
        passed=process.returncode==0 and not timeout and 'CA454 DEPLOY PASS routes=600 points=9453' in log and not any(s in log for s in fatal)
        result={'phase':phase,'passed':passed,'exit_code':process.returncode,'timeout':timeout,'checks':checks};report['runs'].append(result)
        (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(result),flush=True)
        if not passed:raise SystemExit(1)


if __name__=='__main__':main()
