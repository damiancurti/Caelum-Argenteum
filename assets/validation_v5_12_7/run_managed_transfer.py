"""Exercise production transfer verification with actual native identity gates."""
from pathlib import Path
import argparse,datetime,json,sys,zipfile
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT));sys.path.insert(0,str(ROOT/'assets/validation_v5_12_6'))
from caelum_profiles import ProfileStore
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record
from caelum_transfer_verify import verify_transfer
from campaign_fixture import independent_world

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--anchor',type=Path,required=True)
    parser.add_argument('--map-fixture',type=Path,help='Original diagnostic map archive; copy geometry only, not its test script')
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
        members,name,level=unpack(independent_world(data,'managed-b'));personal_record(level,1)['ProfileCommitted']=0
        campaigns.register('b',pack(members,name,level))
        identity=store.connection.execute("SELECT identity FROM campaign_slots WHERE campaign='a' AND player=0").fetchone()[0]
        reports=[]
        for token,destination,slot in [('outbound','b',1),('return','a',0)]:
            campaigns.stage(identity,destination,slot,token)
            reports.append(verify_transfer(campaigns,token,out/token,engine,iwad,packages))
            print(token,'verified through production session identities',flush=True)
        assert store.get(identity).campaign=='a' and store.get(identity).revision==2
        result=dict(issue=435,directory=str(out),runs=reports,passed=True,author_acceptance=False)
        (out/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(dict(directory=str(out),passed=True),indent=2))
    finally:store.close()

if __name__=='__main__':main()
