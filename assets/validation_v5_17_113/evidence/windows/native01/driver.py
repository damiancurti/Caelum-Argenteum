"""Observe real native peers in the actual campaign, without replacing maps.

Reuses the accepted #428/#431 observation window and approved normal siege.
Callback timings are not frame presentation or an Internet-latency measurement.
"""
from pathlib import Path
import argparse,datetime,hashlib,importlib.util,json,re,subprocess,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--engine',type=Path,default=ENGINE,help='Isolated diagnostic engine; never replaces the installed executable')
    parser.add_argument('--presentation-layer',type=Path,help='Explicit diagnostic Vulkan layer directory, enabled only in these children')
    parser.add_argument('--players',type=int,choices=(1,2,4,8),default=2)
    parser.add_argument('--map',choices=('MAP01','MAP02','MAP03'),default='MAP03')
    parser.add_argument('--overlay',type=Path,action='append',default=[],help='Additional diagnostic overlay, loaded before the observer; recorded by hash')
    parser.add_argument('--siege',action='store_true');parser.add_argument('--ground',action='store_true')
    parser.add_argument('--direct-deployment',action='store_true',help='Invoke the existing deployment service at the same diagnostic tic for pre-cooperative-clock comparison')
    parser.add_argument('--isolate-capture-layers',action='store_true',help='Diagnostic only: use the installed OBS/Overwolf Vulkan manifest disable variables in these child processes')
    parser.add_argument('--settled-siege',action='store_true',help='Observe the original siege after5000 native tics, allowing its slower admissions to reach the existing cap')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    if args.settled_siege and (not args.siege or args.direct_deployment):parser.error('Settled siege requires normal siege deployment.')
    engine=args.engine.resolve(strict=True)
    overlays=[p.resolve(strict=True) for p in args.overlay]
    if args.siege and args.map!='MAP03':parser.error('The approved siege is in MAP03.')
    if args.direct_deployment and not args.siege:parser.error('Direct deployment requires the siege scenario.')
    out=ROOT/'build/v516'/datetime.datetime.now().strftime('barracas-profile-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')
    assert source.count('    ui bool FrameWindow;')==1
    source=source.replace('    ui bool FrameWindow;','    ui bool FrameWindow;\n    ui Array<int> FrameTics;\n    ui Array<double> FrameStamps;\n    Array<double> TicStamps;',1)
    assert source.count('        double now=MSTimeF();if(PreviousTic>0)')==1
    source=source.replace('        double now=MSTimeF();if(PreviousTic>0)','        double now=MSTimeF();TicStamps.Push(now);if(PreviousTic>0)',1)
    assert source.count('            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);')==1
    source=source.replace('            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);','            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);\n            for(int i=0;i<TicStamps.Size();i++)Console.Printf("CA870 TICK_TIME i=%d ms=%.6f",i,TicStamps[i]);',1)
    assert source.count('        PreviousFrame=now;FrameWindow=true;')==1
    source=source.replace('        PreviousFrame=now;FrameWindow=true;','        FrameTics.Push(level.time);FrameStamps.Push(now);\n        PreviousFrame=now;FrameWindow=true;',1)
    assert source.count('        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());')==1
    source=source.replace('        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());','        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());\n        for(int i=0;i<FrameTics.Size();i++)Console.Printf("CA870 FRAME_TIME i=%d tic=%d ms=%.6f",i,FrameTics[i],FrameStamps[i]);',1)
    assert source.count('vector3 point=SIEGE ? (-14464,-14000,0) : (0,320,0);')==1 and source.count('user.Angle=SIEGE ? 270 : 180;')==1
    source=source.replace('vector3 point=SIEGE ? (-14464,-14000,0) : (0,320,0);','vector3 point=SIEGE ? (-14464,-14000,0) : (0,320,0);\n                if(CaelumBarracasData.IsCurrent())\n                {\n                    if(SIEGE)\n                    {\n                        int gate=CaelumBarracasFrontData.GateForLane(0);\n                        double outward=CaelumBarracasFrontData.GateOutward(gate);\n                        point=CaelumBarracasFrontData.GatePoint(gate)-(Cos(outward),Sin(outward),0)*CaelumPortData.ROUTE_RADIUS*2;\n                    }\n                    else point=CaelumBarracasData.CurrentPortPoint(point);\n                }').replace('user.Angle=SIEGE ? 270 : 180;','user.Angle=SIEGE ? 270 : CaelumBarracasData.CurrentPortAngle(180);')
    if args.settled_siege:source=source.replace('SIEGE ? 3600 : 350','SIEGE ? 5000 : 350')
    source=source.replace('const SIEGE=0;',f'const SIEGE={int(args.siege)};').replace('const GROUND=0;',f'const GROUND={int(args.ground)};')
    source=source.replace('if(Age==5)\n        {','if(Age==5) for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])\n        {\n            let user=CaelumPlayer(players[slot].mo);if(user==null)continue;')
    source=source.replace('if(Age==135 && SIEGE)\n        {','if(Age==135 && SIEGE) for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])\n        {\n            let user=CaelumPlayer(players[slot].mo);if(user==null)continue;')
    if args.direct_deployment:
        marker='        if(Age==(SIEGE ? 3600 : 350))'
        source=source.replace(marker,'        if(Age==135 && SIEGE)\n        {\n            let port=CaelumPortSiege.Get();\n            if(port!=null && !port.SiegeStarted)port.Deploy(true,CaelumCityWorld.SiegeCivilSeconds());\n        }\n'+marker)
    source=source.replace('if(level.MapName=="MAP03")\n            {','for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])\n            {\n                let user=CaelumPlayer(players[slot].mo);if(user==null)continue;\n                if(level.MapName=="MAP03")\n                {')
    source=source.replace('user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);','user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);\n            }')
    # Two bounded typed-registry observations also include parked house bodies,
    # which the previous default thinker-status iterator did not enumerate.
    start=source.index('    void Census(');end=source.index('    override void WorldTick()',start)
    source=source[:start]+'    void Census(String label){CA435CampaignCensus.Report(label);}\n\n'+source[end:]
    overlay=out/'observer.pk3'
    with zipfile.ZipFile(overlay,'x') as archive:
        members={'ZSCRIPT':b'version "4.14.2"\n#include "census.zs"\n#include "observer.zs"\n',
                 'MAPINFO':b'gameinfo { AddEventHandlers="CA510Performance" }\n',
                 'observer.zs':source.encode('utf-8'),
                 'census.zs':Path(__file__).with_name('campaign_census.zs').read_bytes()}
        import native_sync
        for name,data in sorted(native_sync.instrument(members).items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    spec=importlib.util.spec_from_file_location('previous_profile',ROOT/'assets/validation_v5_11_0/run_profile.py')
    previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
    processes=[];streams=[];commands=[];peers=[];markers=[{} for _ in range(args.players)];offsets=[0]*args.players
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    import os
    child_environment=os.environ.copy();environment_overrides={}
    if args.isolate_capture_layers:
        environment_overrides={name:'1' for name in ('DISABLE_VULKAN_OBS_CAPTURE','DISABLE_VULKAN_OW_OVERLAY_LAYER','DISABLE_VULKAN_OW_OBS_CAPTURE')}
        child_environment.update(environment_overrides)
    if args.presentation_layer:
        environment_overrides.update(VK_LAYER_PATH=str(args.presentation_layer.resolve(strict=True)),VK_INSTANCE_LAYERS='VK_LAYER_CA_presentation')
        child_environment.update(environment_overrides)
    deadline=time.monotonic()+480;error=None
    started=datetime.datetime.now(datetime.timezone.utc).isoformat()
    try:
        for slot in range(args.players):
            peer=out/f'peer{slot}';peer.mkdir();peers.append(peer)
            (peer/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\n'
                'vid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\n'
                'vid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\n'
                'snd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\n'
                'vid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nuse_mouse=false\nlanguage=enu\n')
            duration=((5750 if args.settled_siege else 4350) if args.siege else 1100)+(args.players-slot)*35
            (peer/'start.cfg').write_text('stat think; stat rendertimes; stat VM; wait 3605; echo CA870_THINK_0; profilethinkers -t; wait 5; bench; wait 135; echo CA870_THINK_1; profilethinkers -t; wait 110; bench; wait 30; echo CA870_THINK_2; profilethinkers -t; wait 140; echo CA870_THINK_3; profilethinkers -t; wait 75; bench; wait 65; echo CA870_THINK_4; profilethinkers -t; '+f'wait {duration-4165}; event ca510_frames; screenshot scene.png; wait 3; quit\n')
            network=[] if args.players==1 else ['-host',str(args.players),'-port','31335','-netmode','0'] if slot==0 else ['-join','127.0.0.1:31335','-port',str(31335+slot)]
            command=[str(engine),'-debugfile','-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),*[str(p) for p in overlays],str(overlay),
                '-config',str(peer/'session.ini'),'-savedir',str(peer),*network,'-rngseed','428','-warp',str(int(args.map[3:])),
                '+logfile',str(peer/'engine.log'),'+exec',str(peer/'start.cfg')]
            commands.append(command);stream=(peer/'process.log').open('wb');streams.append(stream)
            peer_environment=child_environment.copy()
            if args.presentation_layer:peer_environment['CA_PRESENT_TRACE']=str(peer/'presents.csv')
            processes.append(subprocess.Popen(command,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream,env=peer_environment));time.sleep(.4)
        print('Campaign peers started:',out,flush=True)
        while any(p.poll() is None for p in processes):
            for slot,peer in enumerate(peers):
                path=peer/'engine.log'
                if not path.exists():continue
                with path.open('rb') as stream:
                    stream.seek(offsets[slot]);chunk=stream.read();offsets[slot]=stream.tell()
                text=chunk.decode(errors='replace')
                for marker in ('BEGIN','END'):
                    if 'CA510 '+marker+' ' in text:markers[slot][marker]=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),qpc_ms=time.perf_counter()*1000)
                if any(m in text for m in ('Script error','Execution could not continue','VM execution aborted','out of sync','desync')):error='Native error; retain the complete logs.'
            if error or time.monotonic()>deadline:
                error=error or 'Bounded observation timeout';break
            time.sleep(.25)
    finally:
        observed=[p.poll() for p in processes]
        for p in processes:
            if p.poll() is None:p.terminate()
        for p in processes:p.wait(timeout=15)
        for stream in streams:stream.close()
    reports=[]
    for slot,(peer,process) in enumerate(zip(peers,processes)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        reports.append(dict(slot=slot,pid=process.pid,exit_code=process.returncode,window=markers[slot],
            simulation=previous.stats([float(v) for v in re.findall(r'CA510 TIC ([\d.]+)',log)]),
            render_callbacks=previous.stats([float(v) for v in re.findall(r'CA510 FRAME ([\d.]+)',log)]),
            states=[re.sub(r'peer=\d+ ','',line) for line in log.splitlines() if line.startswith('CA435PERF STATE')],
            census=[line for line in log.splitlines() if 'CA510 CENSUS' in line],
            scopes=[line for line in log.splitlines() if line.startswith('CA511 SCOPE') or line.startswith('CA511 PROFILE_END')],
            native_sync=native_sync.clean(log),
            passed=process.returncode==0 and native_sync.clean(log) and 'CA510 RESULT' in log and 'CA510 FRAMES_END' in log))
    same=bool(reports) and all(r['states']==reports[0]['states'] for r in reports)
    for report in reports:
        report['complete_window']=(set(report['window'])=={'BEGIN','END'}
            and len(report['states'])==2*(args.players+1)
            and report['simulation'] is not None and report['simulation']['samples']==700
            and report['render_callbacks'] is not None)
        report['passed']=report['passed'] and report['complete_window']
    scenario_valid=not args.siege or all(any(int(v)>0 for line in r['census'] for v in re.findall(r'registered_attackers=(\d+)',line)) for r in reports)
    report=dict(issue=870,started_utc=started,ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),environment_overrides=environment_overrides,
        engine=dict(path=str(engine),sha256=hashlib.sha256(engine.read_bytes()).hexdigest()),
        presentation_layer=(dict(path=str(args.presentation_layer.resolve()),sha256=hashlib.sha256((args.presentation_layer/'ca_presentation.dll').read_bytes()).hexdigest()) if args.presentation_layer else None),
        runtime_sha256=hashlib.sha256(runtime.read_bytes()).hexdigest(),commands=commands,observed_before_cleanup=observed,
        observer_sha256=hashlib.sha256(overlay.read_bytes()).hexdigest(),
        overlays=[dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in overlays],
        map=args.map,siege=args.siege,settled_siege=args.settled_siege,direct_deployment=args.direct_deployment,ground=args.ground,players=args.players,peers=reports,same_state=same,scenario_valid=scenario_valid,error=error,
        passed=not error and same and scenario_valid and all(r['passed'] for r in reports),
        performance_accepted=False,author_accepted=False,
        qualification='Actual campaign geometry on one Windows machine. A one-player control is not network evidence. Observed callback/tic gaps include lockstep waiting and shared hardware contention where applicable. They are not displayed-frame or separate-machine performance.')
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(directory=str(out),passed=report['passed'],peers=reports),indent=2))
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()
