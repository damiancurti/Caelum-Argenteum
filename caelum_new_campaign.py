"""Create a native mansion campaign with vacant slots for existing profiles.

The engine builds the world. No existing save, character or map is replaced, and
the vacancy mode does not grant development equipment or create playable profiles.
"""
from __future__ import annotations
import argparse,hashlib,json,subprocess,time
from pathlib import Path
from caelum_profiles import ProfileStore,ProfileError,validate_anchor
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,personal_record,require_world_ledger

def create_vacant_save(engine: Path,iwad: Path,packages: list[Path],players: int,directory: Path,port: int=31135) -> Path:
    if type(players) is not int or not 1<=players<=8:raise ProfileError('Vacant campaigns support one to eight native slots.')
    directory.mkdir(parents=True,exist_ok=False)
    processes=[];streams=[];peers=[];commands=[];result=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for slot in range(players):
            peer=directory/f'peer{slot}';peer.mkdir();peers.append(peer)
            config=peer/'bootstrap.ini'
            config.write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_maxfps=60\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\n'
                'vid_fullscreen=false\nvid_defwidth=640\nvid_defheight=480\nwin_w=656\nwin_h=519\n'
                '[Doom.LocalServerInfo.Mod]\nca_profile_bootstrap=true\n',encoding='utf-8')
            network=[] if players==1 else ['-host',str(players),'-netmode','0','-port',str(port)] if slot==0 else ['-join',f'127.0.0.1:{port}','-port',str(port+slot)]
            cmd=[str(engine),'-noautoload','-iwad',str(iwad),'-file',*[str(p) for p in packages],'-config',str(config),'-savedir',str(peer),'-window','-width','640','-height','480',*network,'+logfile',str(peer/'engine.log'),'+set','ca_profile_bootstrap','true','-warp','1']
            commands.append(cmd);stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.4)
        deadline=time.monotonic()+120;last=None
        while time.monotonic()<deadline:
            logs=[(p/'engine.log').read_text(errors='replace') if (p/'engine.log').exists() else '' for p in peers]
            if any(any(mark in log for mark in ('CA_PROFILE VACANCY REJECT','Execution could not continue','Script error','VM execution aborted','out of sync','desync')) for log in logs):
                raise ProfileError(f'Native vacancy preparation failed; retained evidence: {directory}')
            if any(p.poll() is not None for p in processes):raise ProfileError(f'A native vacancy peer exited early: {directory}')
            ready=all(f'CA_PROFILE VACANCY READY peer={i} players={players}' in log for i,log in enumerate(logs))
            saves=list(peers[0].glob('save*.zds'))
            if ready and len(saves)==1:
                stat=saves[0].stat();fingerprint=(stat.st_size,stat.st_mtime_ns)
                if last==fingerprint:
                    data=saves[0].read_bytes();validate_anchor(data,0);level=unpack(data)[2]
                    if len(level['players'])!=players:raise ProfileError('Native vacancy roster size differs.')
                    for slot in range(players):
                        record=personal_record(level,slot);require_world_ledger(level,slot)
                        if record.get('ProfileVacancyRevision')!=1 or record.get('ProfileCommitted') or not record.get('ProfileDeparted'):
                            raise ProfileError('Native vacancy was not preserved by the checkpoint.')
                    result=dict(players=players,save=str(saves[0]),sha256=hashlib.sha256(data).hexdigest(),commands=commands,passed=True)
                    (directory/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
                    return saves[0]
                last=fingerprint
            time.sleep(.25)
        raise ProfileError(f'Native vacancy preparation timed out: {directory}')
    finally:
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
        if result is None:(directory/'failure.json').write_text(json.dumps(dict(commands=commands,passed=False),indent=2)+'\n',encoding='utf-8')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine',type=Path,required=True);parser.add_argument('--iwad',type=Path,required=True)
    parser.add_argument('--package',type=Path,action='append',required=True)
    parser.add_argument('--players',type=int,choices=range(1,9),default=1);parser.add_argument('--port',type=int,default=31135)
    parser.add_argument('--store',type=Path);parser.add_argument('--campaign')
    parser.add_argument('directory',type=Path);args=parser.parse_args()
    if bool(args.store)!=bool(args.campaign):parser.error('--store and --campaign must be supplied together')
    engine=args.engine.resolve(strict=True);iwad=args.iwad.resolve(strict=True);packages=[p.resolve(strict=True) for p in args.package]
    store=ProfileStore(args.store) if args.store else None
    try:
        if store and store.connection.execute('SELECT 1 FROM campaigns WHERE identity=?',(args.campaign,)).fetchone():raise ProfileError('Campaign already exists; no new native world was started.')
        save=create_vacant_save(engine,iwad,packages,args.players,args.directory.resolve(),args.port)
        if store:
            worlds=Campaigns(store,PersonalGraph(NativeSchema(engine.parent/'gzdoom.pk3',packages[0])))
            print(json.dumps(worlds.register(args.campaign,save.read_bytes()),indent=2))
        else:print(save)
    finally:
        if store:store.close()

if __name__=='__main__':main()
