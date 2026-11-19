"""Sample nonoverlapping actor Tick sections without changing production files."""
from pathlib import Path
import argparse,hashlib,json,zipfile
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'

def digest(blob):return hashlib.sha256(blob).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(R/'build');out.mkdir(exist_ok=False)
    path='caelum/actors/CaelumCombatActor.zs'
    with zipfile.ZipFile(args.runtime) as z:original=z.read(path).decode('utf-8')
    start=original.index('    override void Tick()');opening=original.index('{',start);end=opening+1;depth=1
    while depth:
        if original[end]=='{':depth+=1
        elif original[end]=='}':depth-=1
        end+=1
    body=original[start:end];injections=[];metrics=[]
    def checkpoint(name):
        metrics.append(name)
        text=f'\n        // CA836-BEGIN {name}\n        if(ca836!=null){{double now=MSTimeF();ca836.{name}MS+=now-ca836Start;ca836.{name}Calls++;ca836Start=MSTimeF();}}\n        // CA836-END {name}\n'
        injections.append(text);return text
    def after(anchor,name):
        nonlocal body
        assert body.count(anchor)==1,(name,body.count(anchor));body=body.replace(anchor,anchor+checkpoint(name),1)
    def before(anchor,name):
        nonlocal body
        assert body.count(anchor)==1,(name,body.count(anchor));body=body.replace(anchor,checkpoint(name)+anchor,1)
    initialization='\n        // CA836-BEGIN setup\n        CA836ActorSections ca836=null;\n        if(level.time%37==0){ca836=CA836ActorSections(EventHandler.Find(\'CA836ActorSections\'));if(ca836!=null && !ca836.Running)ca836=null;}\n        double ca836Start=ca836!=null?MSTimeF():0;\n        // CA836-END setup\n'
    injections.append(initialization);pos=body.index('{')+1;body=body[:pos]+initialization+body[pos:]
    after('        CaelumDemonService.Initialize(self);','Initialization')
    after('        ResourceRecoveryActive();','SenseMaintenance')
    after('        CaelumCommunication.Pulse(self);','Communication')
    before('        Vector3 prePhysicsVelocity = Vel;','PrePhysics')
    before('        Super.Tick();','PhysicsPreparation')
    after('        Super.Tick();','NativeTick')
    before('        CaelumThermalMotion.Physics(self,','PostNative')
    after('CaelumThermalMotion.Physics(self,thermalBefore,prePhysicsVelocity,thermalGrounded,thermalPropulsion,thermalSector,thermalSupport,thermalSupportHeight);','ThermalMotion')
    after('        CaelumThermalRuntime.NPCStep(self);','ThermalStep')
    after('        CaelumDemonService.UpdatePotions(self);','Potions')
    before('        UpdateCombatHealthEffects();','ImpactStatus')
    after('        UpdateCombatHealthEffects();','HealthEffects')
    after('        UpdateActorOffensiveStatistics();','OffenseStats')
    after('        UpdateCombatResourceRecovery(sleeping);','ResourceRecovery')
    body=body[:-1]+checkpoint('Timers')+body[-1:]
    source=original[:start]+body+original[end:]
    handler='\n// CA836-BEGIN handler\nclass CA836ActorSections : EventHandler\n{\n'
    handler+=''.join(f'    double {m}MS;int {m}Calls;\n' for m in metrics)
    handler+='    int Age;bool Running;\n    override void WorldTick()\n    {\n        Age++;Running=Age>=3600 && Age<4300;\n        if(Age!=4300)return;\n'
    handler+=''.join(f'        Console.Printf("CA836 SECTION {m} ms=%.6f calls=%d",{m}MS,{m}Calls);\n' for m in metrics)
    handler+='        Console.Printf("CA836 PROFILE_COMPLETE interval=37 window=700");\n    }\n}\n// CA836-END handler\n'
    source+=handler;injections.append(handler)
    restored=source
    for injection in injections:
        assert restored.count(injection)==1
        restored=restored.replace(injection,'',1)
    assert restored==original,'Instrumentation must restore exact original source.'
    files={path:source.encode('utf-8'),'MAPINFO':b'gameinfo { AddEventHandlers="CA836ActorSections" }\n'}
    with zipfile.ZipFile(out/'profile.pk3','w') as z:
        for name,data in sorted(files.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
            target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
    report={'issue':836,'runtime_sha256':digest(args.runtime.read_bytes()),'overlay_sha256':digest((out/'profile.pk3').read_bytes()),'original_source_sha256':digest(original.encode('utf-8')),'restored_source_sha256':digest(restored.encode('utf-8')),'sections':metrics,'sample_interval':37,'window':[3600,4300],
      'qualification':'Nonoverlapping diagnostic Tick sections sampled every37th tic. Early-return paths may have fewer later section samples. Unmeasured work and timer overhead remain; this is not production performance evidence.'}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'profile':str(out/'profile.pk3'),'sections':len(metrics),'exact_source_restoration':True}))

if __name__=='__main__':main()
