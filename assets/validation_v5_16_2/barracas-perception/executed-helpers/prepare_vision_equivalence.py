from pathlib import Path
import zipfile,hashlib,json
root=Path(__file__).resolve().parents[2];runtime=root/'build/v516/issue454-integrated02.pk3';candidate=root/'build/v516/barracas-distance-reuse01/preview.pk3';out=root/'build/v516/barracas-vision-equivalence01';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(runtime) as package:original=package.read(path).decode('utf-8')
with zipfile.ZipFile(candidate) as package:source=package.read(path).decode('utf-8')
start=original.index('    static bool CanSee(');end=original.index('    // ',start)
old=original[start:end].replace('static bool CanSee(','static bool OriginalCanSee(',1)
source=source.replace('static bool CanSee(','static bool OptimizedCanSee(',1)
wrapper='''    static bool CanSee(CaelumCombatActor observer,Actor candidate,double knownDistance=-1)
    {
        bool actual=OptimizedCanSee(observer,candidate,knownDistance);
        let check=CA454VisionEquivalence(EventHandler.Find('CA454VisionEquivalence'));
        if(check!=null && check.Running)
        {
            check.Calls++;
            if(knownDistance>=0)
            {
                check.Reused++;
                if(knownDistance!=observer.Distance3D(candidate))check.DistanceMismatch++;
            }
            if(actual!=OriginalCanSee(observer,candidate))check.VisibilityMismatch++;
        }
        return actual;
    }
'''
index=source.index('    static Actor Candidate(');source=source[:index]+old+wrapper+source[index:]
source+='''
class CA454VisionEquivalence : EventHandler
{
    int Age,Calls,Reused,DistanceMismatch,VisibilityMismatch; bool Running;
    override void WorldTick()
    {
        Age++;Running=Age>=3600 && Age<4300;
        if(Age!=4300)return;
        Console.Printf("CA454 EQUIVALENCE calls=%d reused=%d distance_mismatch=%d visibility_mismatch=%d result=%s",Calls,Reused,DistanceMismatch,VisibilityMismatch,Calls>0 && Reused>0 && DistanceMismatch==0 && VisibilityMismatch==0?"PASS":"FAIL");
    }
}
'''
with zipfile.ZipFile(out/'checks.pk3','w',zipfile.ZIP_STORED) as package:
    package.writestr(zipfile.ZipInfo(path,(2026,11,13,0,0,0)),source.encode())
    package.writestr(zipfile.ZipInfo('MAPINFO',(2026,11,13,0,0,0)),b'gameinfo { AddEventHandlers="CA454VisionEquivalence" }\n')
(out/'manifest.json').write_bytes((json.dumps({'issue':454,'scope':'Compare candidate visibility and supplied distance against original expressions for every real query in the700-tic siege window. Diagnostic overhead; not a performance measurement.','runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'candidate_sha256':hashlib.sha256(candidate.read_bytes()).hexdigest(),'checks_sha256':hashlib.sha256((out/'checks.pk3').read_bytes()).hexdigest()},indent=2)+'\n').encode())
print(out/'checks.pk3')
