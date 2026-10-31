"""Interactive entry point for the existing profile and native session adapters."""
from __future__ import annotations
import argparse,datetime,json,os,subprocess,sys,uuid
from pathlib import Path
from caelum_profiles import ProfileStore,ProfileError,recover_backup
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns
from caelum_sessions import Sessions,manifest
from caelum_transfer_verify import verify_transfer
from caelum_new_campaign import create_vacant_save

ROOT=Path(__file__).resolve().parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine',type=Path,required=True);parser.add_argument('--iwad',type=Path,required=True)
    parser.add_argument('--package',type=Path,action='append',required=True)
    parser.add_argument('--store',type=Path,default=Path(os.environ.get('LOCALAPPDATA',str(Path.home())))/'CaelumArgenteum/profiles.sqlite3')
    parser.add_argument('--language',choices=('es','en'),default='es')
    args=parser.parse_args();strings=json.loads((ROOT/'assets/profiles/session-menu.json').read_text(encoding='utf-8'))[args.language]
    def text(key):return strings[key]
    def ask(key):return input(text(key)+' ').strip().strip('"')
    def choose(rows,label):
        if not rows:raise ProfileError(text('empty'))
        for index,row in enumerate(rows,1):print(f'{index}. {label(row)}')
        index=int(ask('choose'))-1
        if not 0<=index<len(rows):raise ProfileError(text('invalid'))
        return rows[index]
    # Hash/check installed assets before creating a coordinator or starting a game.
    engine=args.engine.resolve(strict=True);iwad=args.iwad.resolve(strict=True)
    packages=[p.resolve(strict=True) for p in args.package]
    manifest(engine,iwad,packages)
    args.store=args.store.resolve();args.store.parent.mkdir(parents=True,exist_ok=True)
    store=ProfileStore(args.store,create=not args.store.exists())
    worlds=Campaigns(store,PersonalGraph(NativeSchema(engine.parent/'gzdoom.pk3',packages[0])))
    sessions=Sessions(worlds)
    def campaigns():return [dict(r) for r in store.connection.execute('SELECT * FROM campaigns ORDER BY identity')]
    def world():return choose(campaigns(),lambda r:r['identity'])
    def folder(kind):return args.store.parent/kind/(datetime.datetime.now().strftime('%Y%m%d-%H%M%S-')+uuid.uuid4().hex[:8])
    try:
        while True:
            print('\n'+text('title')+'\n'+text('menu'));print(text('store')+str(args.store))
            action=ask('choose')
            try:
                if action=='0':break
                if action=='1':
                    for row in campaigns():print(row['identity'],text('revision'),row['revision'])
                    for row in store.connection.execute('SELECT name,campaign,player FROM profiles ORDER BY campaign,player'):
                        print(f"  {row['name']} — {row['campaign']} ({row['player']+1})")
                elif action=='2':
                    name=ask('campaign');save=Path(ask('save')).resolve(strict=True)
                    result=worlds.register(name,save.read_bytes());print(text('registered')+result['identity'])
                elif action=='3':
                    selected=world();token=str(uuid.uuid4());directory=folder('sessions')
                    result=sessions.prepare(selected['identity'],manifest(engine,iwad,packages),token)
                    sessions.export(token,directory)
                    print(text('bundle')+str(directory));print(text('share'))
                    for member in result['request']['roster']:print(member['slot']+1,member['name'])
                elif action=='4':
                    directory=Path(ask('bundle_path')).resolve(strict=True)
                    session=json.loads((directory/'session.json').read_text(encoding='utf-8'))
                    member=choose(session['request']['roster'],lambda r:r.get('name',str(r['slot']+1)))
                    slot=member['slot'];host='127.0.0.1' if slot==0 else ask('host')
                    cmd=[sys.executable,str(ROOT/'caelum_sessions.py'),'--engine',str(engine),'--iwad',str(iwad)]
                    for package in packages:cmd+=['--package',str(package)]
                    if slot==0:cmd+=['--store',str(args.store)]
                    cmd+=['start',str(directory),'--slot',str(slot),'--host',host]
                    result=subprocess.run(cmd)
                    if slot==0:sessions.close(session['token'])
                    print(text('finished'),result.returncode)
                elif action=='5':
                    active=[dict(r) for r in store.connection.execute('SELECT token,request FROM network_sessions WHERE result IS NULL')]
                    selected=choose(active,lambda r:json.loads(r['request'])['campaign']+' — '+r['token'][:8])
                    sessions.close(selected['token']);print(text('closed'))
                elif action=='6':
                    rows=[dict(r) for r in store.connection.execute('SELECT * FROM profiles ORDER BY campaign,player')]
                    profile=choose(rows,lambda r:f"{r['name']} — {r['campaign']} ({r['player']+1})")
                    destination=world();slot=int(ask('slot'))-1;token=str(uuid.uuid4());directory=folder('transfers')
                    worlds.stage(profile['identity'],destination['identity'],slot,token)
                    print(text('verifying')+str(directory));print(text('transfer_token')+token)
                    verify_transfer(worlds,token,directory,engine,iwad,packages)
                    print(text('transferred'))
                elif action in ('7','12'):
                    pending=[dict(r) for r in store.connection.execute('SELECT token,request FROM transfers WHERE result IS NULL')]
                    selected=choose(pending,lambda r:json.loads(r['request'])['source']+' → '+json.loads(r['request'])['destination']+' — '+r['token'][:8])
                    if action=='7':worlds.cancel(selected['token']);print(text('cancelled'))
                    else:
                        directory=folder('transfers')
                        print(text('verifying')+str(directory));print(text('transfer_token')+selected['token'])
                        verify_transfer(worlds,selected['token'],directory,engine,iwad,packages)
                        print(text('transferred'))
                elif action=='8':
                    output=Path(ask('backup')).resolve();store.backup(output);print(text('written')+str(output))
                elif action=='9':
                    backup=Path(ask('backup')).resolve(strict=True);target=Path(ask('new_store')).resolve()
                    recover_backup(backup,target);print(text('recovered')+str(target));break
                elif action=='10':
                    selected=world();output=Path(ask('save')).resolve();store.export_anchor(selected['snapshot'],output)
                    print(text('written')+str(output));print(text('export_warning'))
                elif action=='11':
                    name=ask('campaign');store._key(name,'campaign identity')
                    if store.connection.execute('SELECT 1 FROM campaigns WHERE identity=?',(name,)).fetchone():
                        raise ProfileError(text('exists'))
                    count=int(ask('players'));directory=folder('campaigns')
                    print(text('vacancy_notice'));print(text('verifying')+str(directory))
                    save=create_vacant_save(engine,iwad,packages,count,directory)
                    worlds.register(name,save.read_bytes());print(text('registered')+name)
                else:print(text('invalid'))
            except (ProfileError,OSError,ValueError,KeyError) as exc:
                print(text('error')+str(exc))
    finally:store.close()

if __name__=='__main__':
    try:main()
    except (EOFError,KeyboardInterrupt):print('\nSession menu closed.')
