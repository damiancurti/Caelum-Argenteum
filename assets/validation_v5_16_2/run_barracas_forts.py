"""Test all36 artillery access paths and528 guard posts in the native engine.

The isolated walking body retains defender dimensions/step height. It ignores
other test walkers, not geometry. No live deployment or combat acceptance.
"""
from pathlib import Path
import argparse
import json
import subprocess
import time
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest


def data_source(siege):
    def vector(p):return '('+','.join(str(v) for v in p)+')'
    source='class CA454FortData : Object play { static int Count(int i){'
    for row in siege['defending_guns']:source+=f'if(i=={row["identity"]})return {len(row["crew_route"])};'
    source+='return 0;} static vector3 Route(int i,int p){switch(i){'
    for row in siege['defending_guns']:source+=f'case {row["identity"]}:return R{row["identity"]}(p);'
    source+='}return (0,0,0);}'
    for row in siege['defending_guns']:
        source+=f'static vector3 R{row["identity"]}(int p){{'
        source+=''.join(f'if(p=={i})return {vector(p)};' for i,p in enumerate(row['crew_route']))+'return (0,0,0);}'
    source+='static vector3 Guard(int i){'
    source+=''.join(f'if(i=={i})return {vector(p)};' for i,p in enumerate(siege['guards']))+'return (0,0,0);}'
    source+='static vector3 Gun(int i){'+''.join(f'if(i=={r["identity"]})return {vector(r["position"])};' for r in siege['defending_guns'])+'return (0,0,0);}'
    source+='static double Angle(int i){'+''.join(f'if(i=={r["identity"]})return {r["angle"]};' for r in siege['defending_guns'])+'return 0;}}'
    return source


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','candidate','output'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--views-only',action='store_true',help='Refresh static cannon views without repeating unchanged walking tests')
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    runtime=args.runtime.resolve();candidate=args.candidate.resolve()
    siege_path=ROOT/'assets/barracas_redesign/SIEGE.json';siege=json.loads(siege_path.read_text())
    passive=(Path(__file__).parent/'barracas_candidate_probe.zs').read_text().split('class CA454CandidateProbe')[0]
    fixture=out/'forts-probe.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        files={'ZSCRIPT':'version "4.14.2"\n'+data_source(siege)+'\n'+passive+'\n'+(Path(__file__).parent/'barracas_forts_probe.zs').read_text(),
               'MAPINFO':'gameinfo { AddEventHandlers="CA454FortProbe" }\ndoomednums {31050=CA454PassiveCity}\n'}
        for name,source in files.items():archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),source)
    (out/'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    start='wait 210; netevent ca454_forts_views; wait 10; ' if args.views_only else 'wait 210; netevent ca454_forts; wait 2200; '
    (out/'commands.cfg').write_text(start+'netevent ca454_view_nw; wait 10; screenshot northwest.png; netevent ca454_view_east; wait 10; screenshot east.png; wait 10; quit\n')
    command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(candidate),str(fixture),'-config',str(out/'isolated.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map','MAP03','+exec',str(out/'commands.cfg')]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    fatal=('Script error','Execution could not continue','VM execution aborted','Unknown type')
    with (out/'process.log').open('wb') as log:
        process=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+180;timeout=False
        try:
            while process.poll() is None:
                path=out/'engine.log'
                if path.exists() and any(s in path.read_text(errors='replace') for s in fatal):break
                if time.monotonic()>deadline:timeout=True;break
                time.sleep(.25)
        finally:
            if process.poll() is None:process.terminate();process.wait(timeout=10)
    log=(out/'engine.log').read_text(errors='replace');checks=[line for line in log.splitlines() if 'CA454 FORT' in line]
    expected='operators=72 components=648 failures=0' if args.views_only else 'CA454 FORT PASS walked=72 failed=0 fit_failures=0'
    passed=process.returncode==0 and not timeout and expected in log and not any(s in log for s in fatal)
    passed=passed and all((out/name).is_file() for name in ('northwest.png','east.png'))
    report={'issue':454,'scope':__doc__.strip(),'views_only':args.views_only,'runtime_sha256':digest(runtime),'candidate_sha256':digest(candidate),'siege_sha256':digest(siege_path),'fixture_sha256':digest(fixture),'passed':passed,'exit_code':process.returncode,'timeout':timeout,'checks':checks}
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'passed':passed,'checks':len(checks),'last':checks[-1:]},indent=2),flush=True)
    if not passed:raise SystemExit(1)


if __name__=='__main__':main()
