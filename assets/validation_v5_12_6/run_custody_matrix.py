"""Verify staged cross-campaign custody and return with real native peers."""
from pathlib import Path
import argparse
import datetime
import json
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import PersonalGraph,NativeSchema
from caelum_campaigns import Campaigns,unpack,pack,personal_record


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--anchor',type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    out=ROOT/'build/issue434'/datetime.datetime.now().strftime('custody-matrix-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    store=ProfileStore(out/'profiles.sqlite3',create=True)
    campaigns=Campaigns(store,PersonalGraph(NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),runtime)))
    data=args.anchor.read_bytes();a=campaigns.register('a',data)
    members,name,level=unpack(data);personal_record(level,1)['ProfileCommitted']=0
    campaigns.register('b',pack(members,name,level))
    identity=store.connection.execute("SELECT identity FROM campaign_slots WHERE campaign='a' AND player=0").fetchone()[0]
    result={'issue':434,'runs':[],'transfers':[],'directory':str(out)}
    for token,destination,slot,probe in [('outbound','b',1,'custody_probe.zs'),('return','a',0,'return_profile_probe.zs')]:
        row=campaigns.stage(identity,destination,slot,token);verified={}
        for side in ('source','destination'):
            draft=out/f'{token}-{side}.zds';store.export_anchor(row[side+'_draft'],draft)
            report=out/f'{token}-{side}.json'
            command=[sys.executable,str(Path(__file__).with_name('run_profile_probe.py')),'--runtime',str(runtime),
                '--reload',str(draft),'--probe',str(Path(__file__).with_name(probe)),'--checks','8','--port','30444','--report',str(report)]
            run=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
            (out/f'{token}-{side}.log').write_text(run.stdout+'\n'+run.stderr,encoding='utf-8')
            if run.returncode:raise RuntimeError(f'Native verification failed; see {out}/{token}-{side}.log')
            details=json.loads(report.read_text());result['runs'].append(details)
            saves=sorted((Path(details['directory'])/'peer0').glob('save*.zds'))
            if len(saves)!=1:raise RuntimeError(f'Expected exactly one verification checkpoint, found {len(saves)}')
            verified[side]=saves[0].read_bytes();print(token,side,'native PASS',flush=True)
        published=campaigns.finish(token,verified['source'],verified['destination'])
        assert campaigns.finish(token,verified['source'],verified['destination'])==published
        result['transfers'].append(published)
    assert store.get(identity).campaign=='a' and store.get(identity).revision==2
    try:campaigns.validate('a',store.anchor(a['snapshot']),current=True)
    except ProfileError:result['stale_origin_rejected']=True
    else:raise AssertionError('Original stale checkpoint accepted')
    result['passed']=True;result['native_assertions']=sum(len([c for c in p['checks'] if ' PASS ' in c]) for r in result['runs'] for p in r['peers'])
    (out/'results.json').write_text(json.dumps(result,indent=2),encoding='utf-8');store.close()
    print(json.dumps({'directory':str(out),'passed':True,'native_assertions':result['native_assertions']},indent=2))


if __name__=='__main__':main()
