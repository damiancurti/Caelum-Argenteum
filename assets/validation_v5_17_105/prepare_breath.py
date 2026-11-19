"""Measure unchanged demon breath-state/status queries on bounded sampled tics."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--targets',action='store_true');a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/actors/CaelumDemonService.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
nl='\r\n' if b'\r\n' in original else '\n';source=original.decode('utf-8').replace('\r\n','\n')
end=source.index('    static clearscope bool Supports(');body=source[:end];tail=source[end:];edits=[]
def change(old,new,count=1):
    global body
    assert body.count(old)==count,(old,body.count(old));body=body.replace(old,new);edits.append((old,new,count))
metrics=['FindState_Pain','FindState_RacialBreath','Sequence_Pain','Sequence_RacialBreath','Sequence_attack','BattleCry_Active','Telekinesis_Held','Bolas_Restrained','Bolas_Interrupted','Visual_Identify','Breath_CanReach','StopBreath','UpdateBreath']
for label,metric in [('Pain',2),('RacialBreath',3)]:
    change(f'npc.InStateSequence(npc.CurState,npc.FindState("{label}"))',f'CA853BreathProbe.Sequence(npc,npc.CurState,npc.FindState("{label}"),{metric})')
for name in ('MeleeState','MissileState'):
    change(f'npc.InStateSequence(npc.CurState,npc.{name})',f'CA853BreathProbe.Sequence(npc,npc.CurState,npc.{name},4)')
for label,metric in [('Pain',0),('RacialBreath',1)]:change(f'npc.FindState("{label}")',f'CA853BreathProbe.Lookup(npc,"{label}",{metric})',2)
calls=[('CaelumBattleCry.Active(npc)','BattleCry(npc)',3),('CaelumTelekinesisRules.Held(npc)','Held(npc)',1),('CaelumBolas.Restrained(npc)','Restrained(npc)',1),('CaelumBolas.Interrupted(npc)','Interrupted(npc)',1),('CaelumVisualPerception.Identify(npc,npc.target)','Identify(npc,npc.target)',1),('CaelumDemonBreath.CanReach(npc,npc.target)','CanReach(npc,npc.target)',1)]
for old,new,count in calls:change(old,'CA853BreathProbe.'+new,count)
for name,args,metric in [('StopBreath','npc,settle,resume',11),('UpdateBreath','npc',12)]:
    match=re.search(r'    static void '+name+r'\([^)]*\)',body);assert match
    signature=match[0];renamed=signature.replace(' '+name+'(',' CA853Body_'+name+'(')
    wrapper=signature+'\n    {\n        let probe=CA853BreathProbe.Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();\n'
    wrapper+=f'        CA853Body_{name}({args});\n        if(probe!=null)probe.End({metric},stamp);\n    }}\n\n'+renamed
    change(signature,wrapper)
restored=body
for old,new,count in reversed(edits):assert restored.count(new)==count;restored=restored.replace(new,old)
assert (restored+tail).replace('\n',nl).encode('utf-8')==original
handler='''
class CA853BreathProbe : StaticEventHandler
{
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e){Total.Resize(9100);Maximum.Resize(9100);Calls.Resize(9100);Ready=true;}
    static CA853BreathProbe Sample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA853BreathProbe(StaticEventHandler.Find('CA853BreathProbe'));
    }
    void End(int metric,double start)
    {
        double elapsed=MSTimeF()-start;int cell=metric*700+level.time-3599;
        Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;
    }
    static State Lookup(CaelumCombatActor body,StateLabel label,int metric)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        State result=body.FindState(label);
        if(probe!=null)probe.End(metric,stamp);return result;
    }
    static bool Sequence(CaelumCombatActor body,State current,State start,int metric)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=body.InStateSequence(current,start);
        if(probe!=null)probe.End(metric,stamp);return result;
    }
'''
wrappers=[('BattleCry','CaelumCombatActor body','CaelumBattleCry.Active(body)',5),('Held','CaelumCombatActor body','CaelumTelekinesisRules.Held(body)',6),('Restrained','CaelumCombatActor body','CaelumBolas.Restrained(body)',7),('Interrupted','CaelumCombatActor body','CaelumBolas.Interrupted(body)',8),('Identify','CaelumCombatActor body,Actor target','CaelumVisualPerception.Identify(body,target)',9),('CanReach','CaelumCombatActor body,Actor target','CaelumDemonBreath.CanReach(body,target)',10)]
for name,signature,call,metric in wrappers:
    handler+=f'''    static bool {name}({signature})
    {{
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result={call};
        if(probe!=null)probe.End({metric},stamp);return result;
    }}
'''
handler+='''    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<700;tic++)for(int metric=0;metric<13;metric++)
        {int cell=metric*700+tic;if(Calls[cell]>0)Console.Printf("CA853 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA853 SERVICES_COMPLETE");
    }
}
'''
if a.targets:
    anchor='    Array<double> Total,Maximum;Array<int> Calls;'
    handler=handler.replace(anchor,anchor+'''
    Array<Name> TargetNames;Array<int> TargetCalls,TargetIdentified;
    void CountTarget(Actor target,bool identified)
    {
        Name kind='None';if(target!=null)kind=target.GetClassName();int slot=-1;
        for(int i=0;i<TargetNames.Size();i++)if(TargetNames[i]==kind){slot=i;break;}
        if(slot<0){slot=TargetNames.Size();TargetNames.Push(kind);TargetCalls.Push(0);TargetIdentified.Push(0);}
        TargetCalls[slot]++;if(identified)TargetIdentified[slot]++;
    }
''')
    anchor='if(probe!=null)probe.End(9,stamp);return result;'
    assert handler.count(anchor)==1;handler=handler.replace(anchor,'if(probe!=null){probe.End(9,stamp);probe.CountTarget(target,result);}return result;')
    anchor='        Console.Printf("CA853 SERVICES_COMPLETE");'
    handler=handler.replace(anchor,'        for(int i=0;i<TargetNames.Size();i++)Console.Printf("CA853 TARGET class=%s calls=%d identified=%d",TargetNames[i],TargetCalls[i],TargetIdentified[i]);\n'+anchor)
files={path:(body+tail+handler).replace('\n',nl).encode('utf-8'),'MAPINFO':b'gameinfo { AddEventHandlers="CA853BreathProbe" }\n'}
with zipfile.ZipFile(out/'services.pk3','w') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=853,runtime_sha256=sha(a.runtime.read_bytes()),original_source_sha256=sha(original),overlay_sha256=sha((out/'services.pk3').read_bytes()),inverse_exact=True,period=17,metrics=[dict(id=i,path=path,method=name) for i,name in enumerate(metrics)],qualification='Original call counts, operands and order preserved. Native state lookups use StateLabel, not String. Inclusive outer scopes contain the nested probes and must not be summed. Timer/helper overhead remains; no production gain is established.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
