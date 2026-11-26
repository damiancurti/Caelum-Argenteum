"""Compare the former ordered candidate loop inside sampled native queries."""
from pathlib import Path
import argparse,hashlib,json,zipfile
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--candidate',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();out=args.output.resolve();out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(args.candidate) as z:original=z.read(path)
nl='\r\n' if b'\r\n' in original else '\n';source=original.decode().replace('\r\n','\n');edits=[]
def change(before,after):
    global source
    assert source.count(before)==1,(before,source.count(before))
    source=source.replace(before,after,1);edits.append((before,after))
marker='''            // La lista espacial se comparte; cada miembro conserva sus filtros'''
change(marker,'''            CA838RelationOracle check=null;
            if(readOnlyRelation && level.time%37==0)
            {check=CA838RelationOracle(EventHandler.Find('CA838RelationOracle'));if(check!=null && !check.Running)check=null;}
            Actor originalNearest;double originalBest=1e30;
'''+marker)
marker='''                if(candidate==null)continue;'''
change(marker,'''                if(check!=null)
                {
                    check.Candidates++;
                    if(candidate!=null && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))check.SkippedRelations++;
                    // Orden exacto de #836, antes del descarte adelantado.
                    if(Opponent(observer,candidate)
                        && !(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper)))
                    {
                        double distance836=observer.Distance3D(candidate);
                        if(distance836<originalBest && CanSee(observer,candidate,distance836))
                        {originalNearest=candidate;originalBest=distance836;}
                    }
                }
'''+marker)
marker='''            if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);'''
change(marker,'''            if(check!=null)
            {
                check.Queries++;if(nearest!=originalNearest)check.NearestMismatch++;
            }
'''+marker)
restored=source
for before,after in reversed(edits):restored=restored.replace(after,before,1)
assert restored.replace('\n',nl).encode()==original
source+='''
class CA838RelationOracle : EventHandler
{
    int Age,Queries,Candidates,SkippedRelations,NearestMismatch;
    bool Running;
    override void WorldTick()
    {
        Age++;Running=Age>=3600 && Age<4300;
        if(Age!=4300)return;
        bool okay=Queries>0 && Candidates>0 && SkippedRelations>0 && NearestMismatch==0;
        Console.Printf("CA838 ORACLE queries=%d candidates=%d skipped_relations=%d nearest_mismatch=%d result=%s",Queries,Candidates,SkippedRelations,NearestMismatch,okay?"PASS":"FAIL");
    }
}
'''
files={path:source.replace('\n',nl).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA838RelationOracle" }\n'}
with zipfile.ZipFile(out/'oracle.pk3','w') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
        target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
(out/'manifest.json').write_text(json.dumps({'issue':838,'candidate_source_sha256':sha(original),'overlay_sha256':sha((out/'oracle.pk3').read_bytes()),'inverse_source_exact':True,'sampling_interval':37,'window':[3600,4300],'qualification':'Original ordered predicate oracle only for proven read-only relationship paths. No performance claim from instrumented timings.'},indent=2)+'\n',encoding='utf-8')
print(out/'oracle.pk3')
