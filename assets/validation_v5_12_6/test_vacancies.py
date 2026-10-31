"""Check real native empty worlds and refusal of malformed vacancy enrollment."""
from pathlib import Path
import argparse,copy,datetime,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record,require_world_ledger

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--vacancy',type=Path,action='append',required=True)
    args=parser.parse_args()
    out=ROOT/'build/issue434'/datetime.datetime.now().strftime('vacancy-checks-%Y%m%d-%H%M%S-%f');out.mkdir()
    adapter=PersonalGraph(NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),args.runtime.resolve()))
    checks=[];reports=[]
    for index,path in enumerate(args.vacancy):
        data=path.read_bytes();members,name,level=unpack(data)
        store=ProfileStore(out/f'{index}.sqlite3',create=True);worlds=Campaigns(store,adapter)
        try:
            head=worlds.register('empty',data)
            worlds.validate('empty',store.anchor(head['snapshot']),current=True)
            assert store.connection.execute('SELECT COUNT(*) FROM profiles').fetchone()[0]==0
            assert store.connection.execute('SELECT COUNT(*) FROM campaign_slots').fetchone()[0]==0
            assert store.anchor(hashlib.sha256(data).hexdigest())==data
            for slot in range(len(level['players'])):
                require_world_ledger(level,slot);record=personal_record(level,slot)
                assert record['ProfileVacancyRevision']==1 and record['ProfileDeparted'] and not record.get('ProfileCommitted')
            checks.append(f'{len(level["players"])} native vacancies: zero profiles, world ledger, original retained')
            def refused(label,changed):
                before=list(store.connection.execute('SELECT identity FROM campaigns'))
                try:worlds.register(label,pack(members,name,changed))
                except ProfileError:pass
                else:raise AssertionError(label+' was accepted')
                assert list(store.connection.execute('SELECT identity FROM campaigns'))==before
                checks.append(label+' refused atomically')
            for field,value in (('ExternalProfileId','occupied'),('ExternalProfileCampaign','another'),('ProfileVacancyRevision',2),('ProfileDeparted',0)):
                changed=copy.deepcopy(level);personal_record(changed,0)[field]=value
                refused(field,changed)
            changed=copy.deepcopy(level);owner=changed['players'][0]['mo'];body=changed['objects'][owner]
            changed['objects'].append({'classtype':'BasicArmor','class:Inventory':{'Owner':owner,'Amount':1},'inventory':body.get('inventory')})
            body['inventory']=len(changed['objects'])-1
            refused('material_inventory',changed)
            changed=copy.deepcopy(level);owner=changed['players'][0]['mo'];cursor=changed['objects'][owner]['inventory']
            changed['objects'][cursor]['inventory']=cursor
            refused('cyclic_inventory',changed)
            assert path.read_bytes()==data
            reports.append(dict(save=str(path.resolve()),players=len(level['players']),sha256=hashlib.sha256(data).hexdigest()))
        finally:store.close()
    result=dict(issue=434,native_inputs=reports,checks=checks,passed=True)
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(directory=str(out),checks=len(checks),passed=True)))

if __name__=='__main__':main()
