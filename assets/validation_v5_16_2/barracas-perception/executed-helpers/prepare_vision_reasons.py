from pathlib import Path
import json,hashlib,zipfile
root=Path(__file__).resolve().parents[2];runtime=root/'build/v516/issue454-integrated02.pk3';out=root/'build/v516/barracas-vision-reasons01';out.mkdir(exist_ok=False)
with zipfile.ZipFile(runtime) as package:original=package.read('caelum/actors/CaelumVisualPerception.zs')
source=original.decode('utf-8');start=source.index('    static bool CanSee(');end=source.index('\n    // ',start)
replacement='''    static bool CanSee(CaelumCombatActor observer,Actor candidate)
    {
        let perf=CA454VisionReasons(EventHandler.Find('CA454VisionReasons'));
        bool measured=perf!=null && perf.Running;
        if(!Living(observer)){if(measured)perf.ObserverNotLiving++;return false;}
        if(!Living(candidate) || observer==candidate){if(measured)perf.CandidateNotLiving++;return false;}
        if(observer.bDormant){if(measured)perf.Dormant++;return false;}
        if(observer.ForcedSleepTics>0){if(measured)perf.Sleeping++;return false;}
        if(observer.CombatLucidityPhysicalStunRemaining>0){if(measured)perf.Stunned++;return false;}
        if(Touching(observer,candidate)){if(measured)perf.Contact++;return true;}
        if(Abs(observer.DeltaAngle(observer.Angle,observer.AngleTo(candidate)))>CaelumPerceptionData.VISUAL_FIELD_DEGREES/2)
        {if(measured)perf.Field++;return false;}
        if(observer.Distance3D(candidate)>Range(observer,candidate)){if(measured)perf.RangeReject++;return false;}
        bool visible=observer.CheckSight(candidate);
        if(measured){if(visible)perf.Visible++;else perf.Occluded++;}
        return visible;
    }
'''
source=source[:start]+replacement+source[end:]
metrics=['ObserverNotLiving','CandidateNotLiving','Dormant','Sleeping','Stunned','Contact','Field','RangeReject','Visible','Occluded']
handler='class CA454VisionReasons : EventHandler { int Age; bool Running; '+''.join('int '+n+';' for n in metrics)
handler+='override void WorldTick(){Age++;Running=Age>=3600 && Age<4300;if(Age!=4300)return;'
handler+=''.join(f'Console.Printf("CA454 VISION {n}=%d",{n});' for n in metrics)+'}}'
files={'caelum/actors/CaelumVisualPerception.zs':(source+'\n'+handler+'\n').encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA454VisionReasons" }\n'}
with zipfile.ZipFile(out/'profile.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in sorted(files.items()):package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),data)
(out/'manifest.json').write_bytes((json.dumps({'issue':454,'scope':'Diagnostic CanSee rejection counters preserving predicate order and short-circuit rules. No production source changes.','runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'original_source_sha256':hashlib.sha256(original).hexdigest(),'profile_sha256':hashlib.sha256((out/'profile.pk3').read_bytes()).hexdigest()},indent=2)+'\n').encode())
print(out/'profile.pk3')
