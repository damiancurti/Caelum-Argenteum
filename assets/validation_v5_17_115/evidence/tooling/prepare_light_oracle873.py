"""Check newly rejected broadphase bodies against immutable native sight/contact."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue871-index01.pk3';candidate=ROOT/'build/issue873-light01/light.pk3'
out=ROOT/'build/issue873-light-oracle01';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(runtime) as z:baseline=z.read(path).decode().replace('\r\n','\n')
with zipfile.ZipFile(candidate) as z:original=z.read(path)
source=original.decode().replace('\r\n','\n')
anchor='    static bool OutsideGroupReach(CaelumCombatActor observer,Actor candidate,double sightUpper)'
replacement='''    static bool OutsideGroupReach(CaelumCombatActor observer,Actor candidate,double sightUpper)
    {
        bool outside=CA873LightBound(observer,candidate,sightUpper);
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {
            let oracle=CA873LightOracle(StaticEventHandler.Find('CA873LightOracle'));
            if(oracle!=null)oracle.Check(observer,candidate,sightUpper,outside);
        }
        return outside;
    }

    static bool CA873LightBound(CaelumCombatActor observer,Actor candidate,double sightUpper)'''
assert source.count(anchor)==1;source=source.replace(anchor,replacement,1)
restored=source.replace(replacement,anchor,1)
nl='\r\n' if b'\r\n' in original else '\n';assert restored.replace('\n',nl).encode()==original
baseline=baseline.replace('class CaelumVisualPerception : Object play','class CA873OldPerception : Object play',1)
source+='\n'+baseline+'''
class CA873LightOracle : StaticEventHandler
{
    Array<int> Visits,Rejected,NewRejected,Visible,Contacts,RangeMismatch;
    bool Printed;
    override void WorldLoaded(WorldEvent e)
    {Visits.Resize(3);Rejected.Resize(3);NewRejected.Resize(3);Visible.Resize(3);Contacts.Resize(3);RangeMismatch.Resize(3);}
    void Check(CaelumCombatActor observer,Actor candidate,double sightUpper,bool outside)
    {
        int family=observer is 'CaelumMandinga'?0:observer is 'CaelumPortDefender'?1:2;
        Visits[family]++;if(!outside)return;Rejected[family]++;
        if(CA873OldPerception.OutsideGroupReach(observer,candidate,sightUpper))return;
        NewRejected[family]++;
        bool insightReady=observer.VisualInsightReady;int insightKey=observer.VisualInsightKey;
        double insightFactor=observer.VisualInsightFactor;
        let npc=CaelumCombatActor(candidate);bool stealthReady=false;int stealthKey=0;double stealthPercent=0;
        if(npc!=null){stealthReady=npc.VisualStealthReady;stealthKey=npc.VisualStealthKey;stealthPercent=npc.VisualStealthPercent;}
        if(CA873OldPerception.CanSee(observer,candidate))Visible[family]++;
        if(CA873OldPerception.Touching(observer,candidate))Contacts[family]++;
        if(CA873OldPerception.Range(observer,candidate)!=CaelumVisualPerception.Range(observer,candidate))RangeMismatch[family]++;
        observer.VisualInsightReady=insightReady;observer.VisualInsightKey=insightKey;observer.VisualInsightFactor=insightFactor;
        if(npc!=null){npc.VisualStealthReady=stealthReady;npc.VisualStealthKey=stealthKey;npc.VisualStealthPercent=stealthPercent;}
    }
    override void WorldTick()
    {
        if(Printed || level.time!=4350)return;Printed=true;int failures=0;int checked=0;
        for(int family=0;family<3;family++)
        {
            failures+=Visible[family]+Contacts[family]+RangeMismatch[family];checked+=NewRejected[family];
            Console.Printf("CA873 LIGHT_ORACLE family=%d visits=%d rejected=%d new=%d visible=%d contact=%d range=%d",family,Visits[family],Rejected[family],NewRejected[family],Visible[family],Contacts[family],RangeMismatch[family]);
        }
        Console.Printf("CA873 LIGHT_ORACLE_RESULT checked=%d failures=%d result=%s",checked,failures,checked>0 && failures==0?"PASS":"FAIL");
    }
}
'''
files={path:source.replace('\n',nl).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA873LightOracle" }\n'}
with zipfile.ZipFile(out/'oracle.pk3','x') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
        target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
(out/'manifest.json').write_text(json.dumps(dict(issue=873,baseline_sha256=sha(runtime.read_bytes()),candidate_sha256=sha(candidate.read_bytes()),overlay_sha256=sha((out/'oracle.pk3').read_bytes()),inverse_exact=True,period=17,window=[3599,4299],scope='Count each real bound invocation; every newly rejected body is checked with immutable 114 sight and contact, plus bit-exact range equality. Restore derived Insight/stealth cache fields after diagnostic calls. This includes group enemies, allies and dense local candidates; it is instrumented, not production throughput.'),indent=2)+'\n',encoding='utf-8',newline='\n')
print(out/'oracle.pk3')
