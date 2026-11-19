"""Sample unchanged combat tick regions without altering production source."""
from pathlib import Path
import argparse,hashlib,json,zipfile

ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
parser.add_argument('--period',type=int,default=17)
parser.add_argument('--detail',action='store_true')
args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
assert args.period>0
path='caelum/actors/CaelumCombatActor.zs'
with zipfile.ZipFile(args.runtime) as package:original_bytes=package.read(path)
original=original_bytes.decode('utf-8').replace('\r\n','\n')
start=original.index('    override void Tick()');end=original.index('\n    States',start)
body=original[start:end];edits=[]
def change(old,new):
    global body
    assert body.count(old)==1,(old,body.count(old))
    body=body.replace(old,new);edits.append((old,new))
intro='''
        CA842MaintenanceProbe ca842Probe=null;
        double ca842Stamp=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%SAMPLE_PERIOD==0)
        {
            ca842Probe=CA842MaintenanceProbe(StaticEventHandler.Find('CA842MaintenanceProbe'));
            if(ca842Probe!=null)ca842Stamp=MSTimeF();
        }
'''.replace('SAMPLE_PERIOD',str(args.period))
change('    override void Tick()\n    {','    override void Tick()\n    {'+intro)
metrics=['empty','entry_and_absence','initialization','demon_focus_altitude_breath','recovery_communication_armor','illness','pre_native_physics','native_actor_tick','post_native_thermal','potions','elemental_and_impact','health_effects','offensive_statistics','resource_recovery','timers']
def mark(i):return f'\n        if(ca842Probe!=null)ca842Stamp=ca842Probe.Mark({i},ca842Stamp);\n'
anchors=[(0,'        if(VisualEvidence==null'),(1,'        MigrateNativeFrozenDeathState();'),(2,'        CaelumDemonService.Initialize(self);'),(3,'        ResourceRecoveryActive();'),(4,'        CaelumContaminationNPC.IllnessStep(self);'),(5,'        if (!CaelumRedemption.PreviouslyRaised(self)'),(6,'        Super.Tick();\n        if(held'),(7,'        if(held && !sleeping'),(8,'        CaelumDemonService.UpdatePotions(self);'),(9,'        // Los actores diagnósticos'),(10,'        UpdateCombatHealthEffects();'),(11,'        UpdateActorOffensiveStatistics();'),(12,'        UpdateCombatResourceRecovery(sleeping);'),(13,'        if (CombatLucidityPhysicalStunRemaining > 0.0)')]
for i,anchor in anchors:change(anchor,mark(i)+anchor)
if args.detail:
    extra=[('siege_focus','        CaelumSiegeFocus.ApplyToActor(self);'),('altitude','        CaelumAltitudeService.Update(self);'),('breathing_audio','        CaelumBreathing.UpdateSound(self);'),('communication','        CaelumCommunication.Pulse(self);'),('demon_breath','        CaelumDemonService.UpdateBreath(self);'),('armor_revision','        // Los valores base quedan intactos'),('recognition','        UpdateCaelumRecognitionSound();'),('thermal_motion','        CaelumThermalMotion.Physics(self,thermalBefore'),('thermal_runtime','        CaelumThermalRuntime.NPCStep(self);\n')]
    for name,anchor in extra:
        key=len(metrics);metrics.append('before_'+name);change(anchor,mark(key)+anchor)
# Preserve all original exits. No missing-region time is attributed on early returns.
change('if((Companion!=null && Companion.Parked) || CaelumRedemption.Pending(self))return;','if((Companion!=null && Companion.Parked) || CaelumRedemption.Pending(self)){'+mark(1)+'return;}')
# The two existing block exits belong to withdrawal/prephysics and diagnostics.
if body.count('            return;')==2:
    old='            if (!SiegeCombatant.Exited) { Super.Tick();CaelumThermalRuntime.NPCStep(self); }\n            return;'
    change(old,old.replace('            return;','            if(ca842Probe!=null)ca842Probe.Mark(6,ca842Stamp);\n            return;'))
    old='        if (CaelumMassAIScheduleActive || CaelumDiagnosticPassiveAI)\n        {\n            return;'
    change(old,old.replace('            return;','            if(ca842Probe!=null)ca842Probe.Mark(10,ca842Stamp);\n            return;'))
suffix='    }\n'
assert body.endswith(suffix)
body=body[:-len(suffix)]+mark(14)+suffix
restored=body[:-len(mark(14)+suffix)]+suffix
for old,new in reversed(edits):assert restored.count(new)==1;restored=restored.replace(new,old)
assert restored==original[start:end]
assert (original[:start]+restored+original[end:]).replace('\n','\r\n').encode('utf-8')==original_bytes
handler='''
class CA842MaintenanceProbe : StaticEventHandler
{
    const METRICS=METRIC_COUNT;
    const WINDOW=700;
    Array<double> Total,Maximum;
    Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e)
    { Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true; }
    double Mark(int metric,double stamp)
    {
        double elapsed=MSTimeF()-stamp;
        int cell=metric*WINDOW+level.time-3599;
        Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;
        return MSTimeF();
    }
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;
        Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {
            int cell=metric*WINDOW+tic;
            if(Calls[cell]>0)Console.Printf("CA842 REGION tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);
        }
        Console.Printf("CA842 COMPLETE");
    }
}
'''.replace('METRIC_COUNT',str(len(metrics)))
files={path:original[:start]+body+original[end:]+handler,'MAPINFO':'gameinfo { AddEventHandlers="CA842MaintenanceProbe" }\n'}
with zipfile.ZipFile(out/'maintenance.pk3','w') as package:
    for name,source in files.items():
        data=(source.replace('\n','\r\n') if name==path else source).encode('utf-8');package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
        target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda data:hashlib.sha256(data).hexdigest()
manifest={'issue':842,'runtime_sha256':sha(args.runtime.read_bytes()),'original_source_sha256':sha(original_bytes),'overlay_sha256':sha((out/'maintenance.pk3').read_bytes()),'exact_inverse_source_restoration':True,'period':args.period,'metrics':dict(enumerate(metrics)),'qualification':'Sampled region timings include conditional/call overhead; metric0 measures an empty interval. Native Tick includes action functions. Original statement order and exits preserved. Diagnostic overhead prevents production performance claims.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps(manifest))
