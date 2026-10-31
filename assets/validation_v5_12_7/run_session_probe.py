"""Exercise the production session manifest and identity gate with real peers."""
from pathlib import Path
import argparse,datetime,importlib.util,json,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns
from caelum_sessions import Sessions,manifest,command,watch


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--players',type=int,choices=(2,4,8),default=2)
    parser.add_argument('--source',type=Path)
    parser.add_argument('--port',type=int,default=30535)
    parser.add_argument('--wrong-slot',action='store_true')
    parser.add_argument('--source-overlay',action='store_true')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    spec=importlib.util.spec_from_file_location('fixture',ROOT/'assets/validation_v5_12_1/run_network_probe.py');fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
    out=ROOT/'build/issue435'/datetime.datetime.now().strftime('session-%Y%m%d-%H%M%S-%f');out.mkdir()
    fixture.fixture(out/'geometry.pk3',args.players)
    with zipfile.ZipFile(out/'geometry.pk3') as old,zipfile.ZipFile(out/'checks.pk3','w') as z:
        z.writestr('maps/MAP03.wad',old.read('maps/MAP03.wad'))
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA435SessionProbe" }\n')
        z.writestr('ZSCRIPT','version "4.14.2"\n#include "probe.zs"\n')
        z.writestr('probe.zs',(Path(__file__).parent/'session_probe.zs').read_bytes())
        if args.source_overlay:z.writestr('caelum/world/CaelumSessionIdentity.zs',(ROOT/'src/caelum/world/CaelumSessionIdentity.zs').read_bytes())
    packages=[runtime,out/'checks.pk3'];store=None;sessions=None;token='native-probe'
    if args.source:
        store=ProfileStore(out/'profiles.sqlite3',create=True)
        campaigns=Campaigns(store,PersonalGraph(NativeSchema(fixture.ENGINE.parent/'gzdoom.pk3',runtime)))
        campaigns.register('native-session',args.source.read_bytes());sessions=Sessions(campaigns)
        sessions.prepare('native-session',manifest(fixture.ENGINE,fixture.IWAD,packages),token)
        sessions.export(token,out/'bundle')
    processes=[];streams=[];commands=[];peers=[]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for i in range(args.players):
            if sessions:
                cmd,peer=command(out/'bundle',i,fixture.ENGINE,fixture.IWAD,packages,args.port,'127.0.0.1')
                cfg=peer/'start.cfg'
                if args.wrong_slot and i==args.players-1:cfg.write_text(cfg.read_text().replace(f'ca_session_slot {i}',f'ca_session_slot {i-1}'))
                with cfg.open('a') as f:f.write(f'wait {490+(args.players-i)*35}; quit\n')
                sessions.claim(token,i)
            else:
                peer=out/f'peer{i}';peer.mkdir();cfg=peer/'test.cfg';cfg.write_text(f'wait {385+(args.players-i)*35}; quit\n')
                (peer/'session.ini').write_text('[GlobalSettings]\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\nvid_maxfps=60\n')
                network=['-host',str(args.players),'-port',str(args.port),'-netmode','0'] if not i else ['-join',f'127.0.0.1:{args.port}','-port',str(args.port+i)]
                cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',*[str(p) for p in packages],'-config',str(peer/'session.ini'),'-savedir',str(peer),*network,'+logfile',str(peer/'engine.log'),'+map','MAP03','+exec',str(cfg)]
            cmd.extend(['-window','-width','640','-height','480']);commands.append(cmd);peers.append(peer)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            process=subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream);processes.append(process)
            if sessions:sessions.attach(token,i,process.pid)
            time.sleep(.4)
        print('Started session peers:',out,flush=True)
        deadline=time.monotonic()+110
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
            if any(any(x in p.read_text(errors='replace') for x in ('Execution could not continue','Script error','VM execution aborted')) for p in out.glob('**/engine.log')):break
            time.sleep(.2)
    finally:
        for p in processes:
            if p.poll() is None:p.terminate();p.wait(timeout=10)
        for stream in streams:stream.close()
    reports=[]
    for i,(p,peer) in enumerate(zip(processes,peers)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        errors=[l for l in log.splitlines() if any(x in l for x in (' FAIL ','Execution could not continue','Script error','VM execution aborted','errors parsing JSON','out of sync','desync'))]
        expected=4 if sessions else 1
        passed=p.returncode==0 and not errors and (('CA_SESSION REJECT' in log and 'CA_SESSION READY' not in log and 'CA435SESSION RESULT' not in log) if args.wrong_slot else log.count('CA435SESSION PASS')==expected and log.count('CA435SESSION RESULT')==1)
        reports.append(dict(peer=i,exit=p.returncode,errors=errors,passed=passed))
        if sessions:sessions.finished(token,i)
    recovery=None
    if sessions:
        watch(processes[0],peers[0],sessions,token,0)
        recovery=sessions.close(token)
        store.close()
    result=dict(issue=435,directory=str(out),source=str(args.source),players=args.players,wrong_slot=args.wrong_slot,source_overlay=args.source_overlay,commands=commands,runtime_sha256=fixture.digest(runtime),peers=reports,recovery=recovery,passed=all(r['passed'] for r in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(directory=str(out),peers=reports,recovery=recovery),indent=2))
    if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
