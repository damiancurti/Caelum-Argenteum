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
    parser.add_argument('--players',type=int,choices=(1,2,4,8),default=2)
    parser.add_argument('--map',choices=('MAP01','MAP02','MAP03'),default='MAP03')
    parser.add_argument('--overlay',type=Path,action='append',default=[],help='Additional diagnostic overlay, loaded before the observer; recorded by hash')
    parser.add_argument('--siege',action='store_true');parser.add_argument('--ground',action='store_true')
    parser.add_argument('--direct-deployment',action='store_true',help='Invoke the existing deployment service at the same diagnostic tic for pre-cooperative-clock comparison')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    overlays=[p.resolve(strict=True) for p in args.overlay]
    if args.siege and args.map!='MAP03':parser.error('The approved siege is in MAP03.')
    if args.direct_deployment and not args.siege:parser.error('Direct deployment requires the siege scenario.')
    out=ROOT/'build/issue435'/datetime.datetime.now().strftime('campaign-profile-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')
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
        for name,data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    spec=importlib.util.spec_from_file_location('previous_profile',ROOT/'assets/validation_v5_11_0/run_profile.py')
    previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
    processes=[];streams=[];commands=[];peers=[];markers=[{} for _ in range(args.players)];offsets=[0]*args.players
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
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
            duration=(4350 if args.siege else 1100)+(args.players-slot)*35
            (peer/'start.cfg').write_text(f'wait {duration}; event ca510_frames; wait 3; quit\n')
            network=[] if args.players==1 else ['-host',str(args.players),'-port','31335','-netmode','0'] if slot==0 else ['-join','127.0.0.1:31335','-port',str(31335+slot)]
            command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),*[str(p) for p in overlays],str(overlay),
                '-config',str(peer/'session.ini'),'-savedir',str(peer),*network,'-rngseed','428','-warp',str(int(args.map[3:])),
                '+logfile',str(peer/'engine.log'),'+exec',str(peer/'start.cfg')]
            commands.append(command);stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(command,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.4)
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
            passed=process.returncode==0 and 'CA510 RESULT' in log and 'CA510 FRAMES_END' in log))
    same=bool(reports) and all(r['states']==reports[0]['states'] for r in reports)
    for report in reports:
        report['complete_window']=(set(report['window'])=={'BEGIN','END'}
            and len(report['states'])==2*(args.players+1)
            and report['simulation'] is not None and report['simulation']['samples']==700
            and report['render_callbacks'] is not None)
        report['passed']=report['passed'] and report['complete_window']
    scenario_valid=not args.siege or all(any(int(v)>0 for line in r['census'] for v in re.findall(r'registered_attackers=(\d+)',line)) for r in reports)
    report=dict(issue=435,started_utc=started,ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        runtime_sha256=hashlib.sha256(runtime.read_bytes()).hexdigest(),commands=commands,observed_before_cleanup=observed,
        observer_sha256=hashlib.sha256(overlay.read_bytes()).hexdigest(),
        overlays=[dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in overlays],
        map=args.map,siege=args.siege,direct_deployment=args.direct_deployment,ground=args.ground,players=args.players,peers=reports,same_state=same,scenario_valid=scenario_valid,error=error,
        passed=not error and same and scenario_valid and all(r['passed'] for r in reports),
        performance_accepted=False,author_accepted=False,
        qualification='Actual campaign geometry on one Windows machine. A one-player control is not network evidence. Observed callback/tic gaps include lockstep waiting and shared hardware contention where applicable. They are not displayed-frame or separate-machine performance.')
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(directory=str(out),passed=report['passed'],peers=reports),indent=2))
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()
