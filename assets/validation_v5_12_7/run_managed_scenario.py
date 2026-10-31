"""Reuse the focused issue probes behind production profile/session admission."""
from pathlib import Path
import argparse,datetime,importlib.util,json,subprocess,sys,time,zipfile,re
import native_sync
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns
from caelum_sessions import Sessions,manifest,command,watch,digest

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--anchor',type=Path,required=True)
    p.add_argument('--engine',type=Path,default=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe'))
    p.add_argument('--scenario',choices=('truco','trucazo','arena','fool'),required=True)
    p.add_argument('--port',type=int,default=30935)
    p.add_argument('--timeout',type=int,help='Optional bounded diagnostic time for inspecting a native failure')
    args=p.parse_args()
    if args.timeout is not None and not 1<=args.timeout<=600:p.error('Timeout must be between 1 and 600 seconds')
    if args.scenario=='fool':
        with zipfile.ZipFile(args.anchor) as seed:
            if 'map01.map.json' in seed.namelist():
                p.error('The isolated Fool fixture requires a seed that has not visited MAP01; retain the existing hub save unchanged.')
    runtime=args.runtime.resolve();out=ROOT/'build/issue435'/datetime.datetime.now().strftime('managed-'+args.scenario+'-%Y%m%d-%H%M%S-%f');out.mkdir()
    issue,version,script,prefix,expected={'truco':(590,5,'run_card_probe.py','CA590',17),'trucazo':(590,5,'run_card_probe.py','CA590',17),
        'arena':(438,4,'run_arena_probe.py','CA438',39),'fool':(437,3,'run_lifecycle_probe.py','CA437',36)}[args.scenario]
    spec=importlib.util.spec_from_file_location('scenario',ROOT/f'assets/validation_v5_12_{version}'/script)
    fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
    fixture.ENGINE=args.engine.resolve(strict=True)
    addon=out/'checks.pk3'
    if issue==590:fixture.fixture(addon,2,integration=True,magic=args.scenario=='trucazo')
    elif issue==438:fixture.fixture(addon,2,False,False)
    else:fixture.fixture(addon,2,tutorial=True)
    # The admission seed predates this diagnostic handler. A static probe is
    # newly registered on load, while production saved handlers retain their types.
    with zipfile.ZipFile(addon) as z:members={name:z.read(name) for name in z.namelist()}
    # The native geometry hash includes the exact original TEXTMAP bytes.
    with zipfile.ZipFile(args.anchor.resolve().parent.parent/'checks.pk3') as seed:
        members['maps/MAP03.wad']=seed.read('maps/MAP03.wad')
    probe=members['probe.zs'].replace(b': EventHandler',b': StaticEventHandler')
    probe=re.sub(rb'(?<![.\w])SendNetworkEvent\(',b'EventHandler.SendNetworkEvent(',probe)
    if issue==590:
        probe=probe.replace(b'if(e.IsSaveGame)Reloaded=true;',b'Reloaded=false;')
        probe=probe.replace(b"EventHandler.Find('CaelumSessionLifecycle')",b"StaticEventHandler.Find('CaelumSessionLifecycleEvents')")
    if issue==437:
        probe=probe.replace(b'SceneToken.Amount=4;',b'SceneToken.Amount=4;SceneToken.ChangeTID(435437);')
        probe=probe.replace(b'Check(SceneToken!=null',b"SceneToken=Inventory(level.CreateActorIterator(435437,'CaelumCopperCoin').Next());\n            Check(SceneToken!=null")
    members['probe.zs']=probe
    members=native_sync.instrument(members)
    with zipfile.ZipFile(addon,'w') as z:
        for name,data in members.items():z.writestr(name,data)
    packages=[runtime,addon];store=ProfileStore(out/'profiles.sqlite3',create=True)
    campaigns=Campaigns(store,PersonalGraph(NativeSchema(fixture.ENGINE.parent/'gzdoom.pk3',runtime)))
    campaigns.register('scenario',args.anchor.read_bytes());sessions=Sessions(campaigns)
    token=out.name;sessions.prepare('scenario',manifest(fixture.ENGINE,fixture.IWAD,packages),token);sessions.export(token,out/'bundle')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    processes=[];streams=[];peers=[];commands=[];error=None;observed=[]
    try:
        for slot in range(2):
            cmd,peer=command(out/'bundle',slot,fixture.ENGINE,fixture.IWAD,packages,args.port,'127.0.0.1')
            actions=f'wait {1400+(2-slot)*35}; quit\n'
            if args.scenario=='fool':actions=f'wait 500; +forward; wait 100; -forward; wait {2800+(2-slot)*35}; quit\n'
            with (peer/'start.cfg').open('a') as f:f.write(actions)
            cmd+=['-window','-width','640','-height','480'];commands.append(cmd);peers.append(peer)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            sessions.claim(token,slot);process=subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream)
            processes.append(process);sessions.attach(token,slot,process.pid);time.sleep(.4)
        print('Managed scenario:',out,flush=True)
        deadline=time.monotonic()+(args.timeout or (240 if args.scenario=='fool' else 120))
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
            if any(any(e in p.read_text(errors='replace') for e in ('Execution could not continue','VM execution aborted','This savegame needs these files','Savegame is from a different level')) for p in out.glob('**/engine.log')):
                error='Native error; inspect retained logs';break
            time.sleep(.25)
        if any(p.poll() is None for p in processes) and not error:error='Bounded scenario timeout'
    finally:
        observed=[p.poll() for p in processes]
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
    reports=[]
    for slot,(process,peer) in enumerate(zip(processes,peers)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        errors=[l for l in log.splitlines() if any(e in l for e in (' FAIL ','Execution could not continue','VM execution aborted','Script error','CA_SESSION REJECT','desync','out of sync','Savegame is from a different level','This savegame needs these files'))]
        checks=[l for l in log.splitlines() if l.startswith(prefix+' ')]
        passed=process.returncode==0 and not errors and native_sync.clean(log) and 'CA_SESSION READY' in log and log.count(prefix+' PASS')==expected and log.count(prefix+' RESULT')==1
        reports.append(dict(peer=slot,exit=process.returncode,passed=passed,checks=checks,errors=errors));sessions.finished(token,slot)
    watch(processes[0],peers[0],sessions,token,0);recovery=sessions.close(token);store.close()
    result=dict(issue=435,scenario_issue=issue,directory=str(out),scenario=args.scenario,commands=commands,peers=reports,recovery=recovery,
                runtime_sha256=digest(runtime),engine_sha256=digest(fixture.ENGINE),error=error,observed_before_cleanup=observed,passed=not error and all(r['passed'] for r in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(directory=str(out),passed=result['passed'],peers=[dict(peer=r['peer'],passed=r['passed'],checks=sum(' PASS ' in l for l in r['checks']),errors=r['errors']) for r in reports]),indent=2))
    raise SystemExit(not result['passed'])

if __name__=='__main__':main()
