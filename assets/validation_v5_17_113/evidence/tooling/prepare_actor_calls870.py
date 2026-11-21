"""Wrap measured actor services without changing their original statements."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue868-diagnosis01.pk3';out=ROOT/'build/issue870-calls03';out.mkdir(exist_ok=False)
specs=[
('actors/CaelumCombatActor.zs','A_CaelumBudgetedLook','','self'),
('actors/CaelumCombatActor.zs','A_CaelumBudgetedChase','','self'),
('actors/CaelumCombatActor.zs','ThermalChase','melee,missile,flags','self'),
('actors/CaelumCombatActor.zs','ResourceRecoveryActive','','self'),
('actors/CaelumDemonService.zs','UpdateBreath','npc','npc'),
('survival/CaelumAltitudeService.zs','Update','body','body'),
('survival/CaelumBreathing.zs','UpdateSound','body','body'),
('actors/CaelumCommunication.zs','Pulse','body','body'),
('survival/CaelumThermalRuntime.zs','NPCStep','npc,force','npc'),
('survival/CaelumThermalMotion.zs','Physics','body,before,velocity,grounded,propelled,supportSector,supportFloor,supportHeight','body'),
('world/CaelumSiegeFocus.zs','ApplyToActor','body','body'),
('world/CaelumPortSiege.zs','Pulse','body','body'),
('world/CaelumPortSiege.zs','AttackerTarget','entry','entry!=null?entry.Body:null'),
('world/CaelumPortDefender.zs','RestoreWardrobeState','','self'),
('world/CaelumPortDefender.zs','ApplyWardrobe','','self'),
('equipment/CaelumRangedRules.zs','Tick','owner','owner'),
]
originals={};files={};edits=[]
with zipfile.ZipFile(runtime) as z:
    for short,*_ in specs:
        p='caelum/'+short
        if p not in files:originals[p]=z.read(p);files[p]=originals[p].decode('utf-8').replace('\r\n','\n')

def end_body(source,begin):
    # Ignore braces in comments and literals while finding the original body.
    tokens=re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]')
    depth=0
    for m in tokens.finditer(source,begin):
        if m.group()=='{':depth+=1
        elif m.group()=='}':
            depth-=1
            if depth==0:return m.end()
    raise AssertionError('Unclosed body')

for metric,(short,name,args,actor) in enumerate(specs):
    p='caelum/'+short;s=files[p]
    pattern=r'(?m)^    (?P<prefix>(?:(?:static|action|virtual|override) )*)(?P<type>\w+) '+name+r'\((?P<params>[^)]*)\)\s*\{'
    matches=list(re.finditer(pattern,s));assert len(matches)==1,(p,name,len(matches))
    m=matches[0];end=end_body(s,m.end()-1);old=s[m.start():end]
    renamed=old.replace(name+'(',f'CA870Original{metric}(',1)
    header=s[m.start():m.end()]
    call=f'CA870Original{metric}({args});'
    is_void=m['type']=='void'
    wrapper=header+f'''
        let ca870Probe=CA870CallProbe.FindFor({actor});
        int ca870Family=ca870Probe!=null?CA870CallProbe.Family({actor}):0;
        double ca870Start=ca870Probe!=null?MSTimeF():0;
        '''+('' if is_void else 'let ca870Result=')+call+f'''
        if(ca870Probe!=null)ca870Probe.Record(ca870Family*{len(specs)}+{metric},ca870Start);
        '''+('' if is_void else 'return ca870Result;')+'''
    }
'''+renamed
    files[p]=s[:m.start()]+wrapper+s[end:];edits.append((p,old,wrapper))
restored=dict(files)
for p,old,new in reversed(edits):assert restored[p].count(new)==1;restored[p]=restored[p].replace(new,old,1)
for p,s in restored.items():assert s.replace('\n','\r\n' if b'\r\n' in originals[p] else '\n').encode()==originals[p]
handler='''
class CA870CallProbe : StaticEventHandler
{
    const METRICS=48;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    static CA870CallProbe FindFor(Actor body)
    {
        if(body==null || level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA870CallProbe(StaticEventHandler.Find('CA870CallProbe'));
    }
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA870 CALL tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA870 CALLS_COMPLETE");
    }
}
'''
files['caelum/actors/CaelumCombatActor.zs']+=handler
files['MAPINFO']='gameinfo { AddEventHandlers="CA870CallProbe" }\n'
with zipfile.ZipFile(out/'calls.pk3','x') as z:
    for p,s in sorted(files.items()):
        data=s.replace('\n','\r\n' if b'\r\n' in originals.get(p,b'') else '\n').encode()
        z.writestr(zipfile.ZipInfo(p,(2026,11,21,0,0,0)),data)
        target=out/'source'/p;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
metrics=[dict(id=family*len(specs)+i,family=family_name,stage=short.rsplit('/',1)[-1]+':'+name) for family,family_name in enumerate(['Mandinga','PortDefender','other']) for i,(short,name,*_) in enumerate(specs)]
manifest=dict(issue=870,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'calls.pk3').read_bytes()),originals_restored_exactly={p:sha(b) for p,b in originals.items()},metrics=metrics,period=17,qualification='Private wrappers retain every original statement and argument. Inclusive times overlap: nested calls must not be summed. Includes wrapper, handler lookup and timing overhead. Selected 42 tics, not production CPU budgets. No actor fields or saved schema changed.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(output=str(out),metrics=len(metrics),overlay_sha256=manifest['overlay_sha256'])))
