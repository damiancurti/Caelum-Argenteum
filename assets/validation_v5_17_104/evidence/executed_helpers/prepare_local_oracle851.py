"""Check every sampled rejected local body against original sight/contact tests."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False);path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(a.candidate) as z:original=z.read(path)
nl='\r\n' if b'\r\n' in original else '\n';source=original.decode().replace('\r\n','\n');edits=[]
def change(old,new):
    global source
    assert source.count(old)==1,(old,source.count(old));source=source.replace(old,new);edits.append((old,new))
anchor='        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));'
change(anchor,'''        CA851LocalOracle oracle=null;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {oracle=CA851LocalOracle(StaticEventHandler.Find('CA851LocalOracle'));if(oracle!=null)oracle.Queries++;}
'''+anchor)
anchor='            let candidate=local.thing;'
change(anchor,anchor+'\n            if(oracle!=null)oracle.Candidates++;')
for name,field in [('readOnlyLocalRelation','PreRejected'),('!readOnlyLocalRelation','PostRejected')]:
    old=f'            if({name} && localSightUpper>=0 && candidate!=null && OutsideGroupReach(observer,candidate,localSightUpper))continue;'
    change(old,old.replace('continue;',f'{{if(oracle!=null){{oracle.{field}++;oracle.Check(observer,candidate);}}continue;}}'))
restored=source
for old,new in reversed(edits):assert restored.count(new)==1;restored=restored.replace(new,old)
assert restored.replace('\n',nl).encode()==original
source+='''
class CA851LocalOracle : StaticEventHandler
{
    int Queries,Candidates,PreRejected,PostRejected,UnexpectedVisible,UnexpectedContact;
    bool Printed;
    void Check(CaelumCombatActor observer,Actor candidate)
    {
        if(CaelumVisualPerception.CanSee(observer,candidate))UnexpectedVisible++;
        if(CaelumVisualPerception.Touching(observer,candidate))UnexpectedContact++;
    }
    override void WorldTick()
    {
        if(Printed || level.time!=4350)return;Printed=true;
        bool okay=Queries>0 && Candidates>0 && PreRejected+PostRejected>0 && UnexpectedVisible==0 && UnexpectedContact==0;
        Console.Printf("CA851 LOCAL_ORACLE queries=%d candidates=%d pre=%d post=%d visible=%d contact=%d result=%s",Queries,Candidates,PreRejected,PostRejected,UnexpectedVisible,UnexpectedContact,okay?"PASS":"FAIL");
    }
}
'''
files={path:source.replace('\n',nl).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA851LocalOracle" }\n'}
with zipfile.ZipFile(out/'oracle.pk3','w') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
(out/'manifest.json').write_text(json.dumps(dict(issue=851,candidate_source_sha256=sha(original),overlay_sha256=sha((out/'oracle.pk3').read_bytes()),inverse_exact=True,period=17,window=[3599,4299],qualification='Only rejected bodies receive diagnostic original CanSee and Touching calls. Source geometry proof says neither query can reach native CheckSight for these bodies. Positive visibility/contact fails the oracle. No production gain is inferred from instrumented runs.'),indent=2)+'\n',encoding='utf-8',newline='\n');print(out/'oracle.pk3')
