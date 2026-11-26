"""Compare original and filtered ordered queries in the same native scene."""
from pathlib import Path
import argparse,hashlib,json,zipfile

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.mkdir(exist_ok=False)
    path='caelum/actors/CaelumVisualPerception.zs'
    with zipfile.ZipFile(args.candidate) as z:original=z.read(path).decode('utf-8')
    source=original;changes=[];newline='\r\n' if '\r\n' in original else '\n'
    def change(before,after):
        nonlocal source
        before=before.replace('\n',newline);after=after.replace('\n',newline)
        assert source.count(before)==1,(before,source.count(before))
        source=source.replace(before,after,1);changes.append((before,after))
    marker='''            double sightUpper=level.GetPortalGroupCount()==1'''
    change(marker,'''            CA836ReachOracle check=null;
            if(level.time%37==0){check=CA836ReachOracle(EventHandler.Find('CA836ReachOracle'));if(check!=null && !check.Running)check=null;}
            Actor originalNearest;CaelumCombatActor originalAlly;
            double originalBest=1e30,originalAllyDistance=1e30;
'''+marker)
    for subject,nearest,best in [('candidate','originalNearest','originalBest'),('friend','originalAlly','originalAllyDistance')]:
        marker=f'                if(sightUpper>=0 && OutsideGroupReach(observer,{subject},sightUpper))continue;'
        change(marker,f'''                if(check!=null)
                {{
                    check.Candidates++;
                    double originalDistance=observer.Distance3D({subject});
                    bool originalVisible=CanSee(observer,{subject},originalDistance);
                    if(originalDistance<{best} && originalVisible){{{nearest}={subject};{best}=originalDistance;}}
                    if(sightUpper>=0 && OutsideGroupReach(observer,{subject},sightUpper))
                    {{check.Rejected++;if(originalVisible)check.VisibilityMismatch++;}}
                }}
'''+marker)
    marker='''            if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);'''
    change(marker,'''            if(check!=null)
            {
                check.Queries++;
                if(level.GetPortalGroupCount()!=1)check.PortalFallback++;
                if(nearest!=originalNearest)check.NearestMismatch++;
                if(ally!=originalAlly)check.AllyMismatch++;
            }
'''+marker)
    handler='''
class CA836ReachOracle : EventHandler
{
    int Age,Queries,Candidates,Rejected,VisibilityMismatch,NearestMismatch,AllyMismatch,PortalFallback;
    bool Running;
    override void WorldTick()
    {
        Age++;Running=Age>=3600 && Age<4300;
        if(Age!=4300)return;
        bool okay=Queries>0 && Candidates>0 && Rejected>0 && VisibilityMismatch==0 && NearestMismatch==0 && AllyMismatch==0;
        Console.Printf("CA836 ORACLE queries=%d candidates=%d rejected=%d visibility_mismatch=%d nearest_mismatch=%d ally_mismatch=%d portal_fallback=%d portal_groups=%d result=%s",Queries,Candidates,Rejected,VisibilityMismatch,NearestMismatch,AllyMismatch,PortalFallback,level.GetPortalGroupCount(),okay?"PASS":"FAIL");
    }
}
'''.replace('\n',newline)
    restored=source
    for before,after in reversed(changes):restored=restored.replace(after,before,1)
    assert restored==original
    source+=handler
    files={path:source.encode('utf-8'),'MAPINFO':b'gameinfo { AddEventHandlers="CA836ReachOracle" }\n'}
    with zipfile.ZipFile(out/'oracle.pk3','w') as z:
        for name,data in sorted(files.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
            target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
    (out/'manifest.json').write_text(json.dumps({'issue':836,'candidate_sha256':hashlib.sha256(args.candidate.read_bytes()).hexdigest(),'oracle_sha256':hashlib.sha256((out/'oracle.pk3').read_bytes()).hexdigest(),'restores_exact_candidate_source':True,'interval':37,'window':[3600,4300],'qualification':'Diagnostic original predicate oracle, including original ordered nearest opponent and ally. Runs in one scene; extra cache accesses and timings are not production performance evidence.'},indent=2)+'\n',encoding='utf-8')
    print(out/'oracle.pk3')

if __name__=='__main__':main()
