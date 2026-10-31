"""Exercise production transfer verification with actual native identity gates."""
from pathlib import Path
import argparse,datetime,json,sys,zipfile,subprocess,time
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT));sys.path.insert(0,str(ROOT/'assets/validation_v5_12_6'))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record
from caelum_transfer_verify import verify_transfer
from caelum_new_campaign import create_vacant_save
from caelum_sessions import Sessions,manifest,command,watch
from campaign_fixture import independent_world

def exercise_imported_session(sessions,out,engine,iwad,packages):
    """Normal admission, native Escape-equivalent dialogue input, movement, save."""
    directory=out/'imported-play';directory.mkdir()
    overlay=directory/'input.pk3'
    with zipfile.ZipFile(overlay,'x') as z:
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA435ImportedSessionProbe" }\n')
        z.writestr('ZSCRIPT','version "4.14.2"\n#include "imported.zs"\n')
        z.writestr('imported.zs',Path(__file__).with_name('imported_session_probe.zs').read_bytes())
    files=[*packages,overlay];token='native-imported-play'
    sessions.prepare('b',manifest(engine,iwad,files),token);bundle=directory/'bundle';sessions.export(token,bundle)
    cmd,peer=command(bundle,0,engine,iwad,files,31235,'127.0.0.1')
    with (peer/'session.ini').open('a') as f:f.write('vid_fullscreen=false\nuse_mouse=false\nvid_maxfps=60\n')
    with (peer/'start.cfg').open('a') as f:f.write('\nwait 105; +forward; wait 7; -forward; wait 200; quit\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    sessions.claim(token,0)
    with (peer/'process.log').open('wb') as log:
        process=subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=log,stderr=log)
        sessions.attach(token,0,process.pid)
        try:
            deadline=time.monotonic()+70
            while process.poll() is None and time.monotonic()<deadline:
                logpath=peer/'engine.log';text=logpath.read_text(errors='replace') if logpath.exists() else ''
                if any(mark in text for mark in ('Script error','Execution could not continue','VM execution aborted')):break
                time.sleep(.2)
        finally:
            if process.poll() is None:process.terminate();process.wait(timeout=15)
        watch(process,peer,sessions,token,0);sessions.finished(token,0);closed=sessions.close(token)
    text=(peer/'engine.log').read_text(errors='replace')
    assert process.returncode==0 and text.count('CA435IMPORT PASS')==2 and 'CA435IMPORT FAIL' not in text, directory
    assert closed['recovery']['revision']>1,closed
    return dict(directory=str(directory),checks=2,recovery=closed,passed=True)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--anchor',type=Path,required=True)
    parser.add_argument('--map-fixture',type=Path,help='Original diagnostic map archive; copy geometry only, not its test script')
    parser.add_argument('--native-vacancy',action='store_true',help='Create an actual one-slot MAP01 target, without editing a character into a vacancy')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    out=ROOT/'build/issue435'/datetime.datetime.now().strftime('managed-transfer-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
    iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    packages=[runtime]
    if args.map_fixture:
        with zipfile.ZipFile(args.map_fixture) as source,zipfile.ZipFile(out/'checks.pk3','x') as target:
            for name in source.namelist():
                if name.lower().startswith('maps/'):target.writestr(name,source.read(name))
        packages.append(out/'checks.pk3')
    store=ProfileStore(out/'profiles.sqlite3',create=True)
    try:
        campaigns=Campaigns(store,PersonalGraph(NativeSchema(engine.parent/'gzdoom.pk3',runtime)))
        data=args.anchor.read_bytes();campaigns.register('a',data)
        if args.native_vacancy:
            vacant=create_vacant_save(engine,iwad,packages,1,out/'new-world')
            campaigns.register('b',vacant.read_bytes())
        else:
            members,name,level=unpack(independent_world(data,'managed-b'));personal_record(level,1)['ProfileCommitted']=0
            campaigns.register('b',pack(members,name,level))
        identity=store.connection.execute("SELECT identity FROM campaign_slots WHERE campaign='a' AND player=0").fetchone()[0]
        reports=[]
        sessions=Sessions(campaigns);admission=[];native_play=None
        for token,destination,slot in [('outbound','b',0 if args.native_vacancy else 1),('return','a',0)]:
            campaigns.stage(identity,destination,slot,token)
            reports.append(verify_transfer(campaigns,token,out/token,engine,iwad,packages))
            print(token,'verified through production session identities',flush=True)
            if args.native_vacancy:
                request=sessions.prepare(destination,manifest(engine,iwad,packages),token+'-play')
                bundle=out/(token+'-play');sessions.export(request['token'],bundle)
                command(bundle,0,engine,iwad,packages,31235,'127.0.0.1')
                sessions.close(request['token'])
                departed='a' if destination=='b' else 'b'
                try:sessions.prepare(departed,manifest(engine,iwad,packages),token+'-vacant')
                except ProfileError as exc:
                    assert 'Fill every native slot' in str(exc);admission.append(departed+' vacant normal launch refused')
                else:raise AssertionError('Ordinary play accepted a departed native participant')
                admission.append(destination+' occupied normal session prepared')
                if token=='outbound':native_play=exercise_imported_session(sessions,out,engine,iwad,packages)
        assert store.get(identity).campaign=='a' and store.get(identity).revision==2
        result=dict(issue=435,directory=str(out),runs=reports,native_vacancy=args.native_vacancy,native_play=native_play,admission=admission,passed=True,author_acceptance=False)
        (out/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(dict(directory=str(out),passed=True),indent=2))
    finally:store.close()

if __name__=='__main__':main()
