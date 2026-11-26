"""Measure thermal subcalls and zero-moisture opportunities without changing math."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue870-diagnosis01.pk3';out=ROOT/'build/issue871-profile01';out.mkdir(exist_ok=False)
specs=[
('CaelumThermalRuntime.zs','NPCStep','npc,force','npc'),
('CaelumThermalService.zs','Advance','body,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,firearmWatts,surfaceKind','body'),
('CaelumThermalService.zs','Integrate','thermal,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,logicalActivitySeconds,firearmWatts',None),
('CaelumThermalService.zs','IntegrateStep','thermal,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,logicalActivitySeconds,coefficients,firearmWatts',None),
('CaelumThermalBody.zs','Refresh','body,thermal','body'),
('CaelumThermalEnvironment.zs','Sample','body,thermal,localMotionMps','body'),
('CaelumContaminationNPC.zs','Step','npc,thermal,seconds','npc'),
('CaelumThermalCoefficients.zs','Prepare','thermal',None)]
originals={};files={};edits=[]
with zipfile.ZipFile(runtime) as z:
    for short,*_ in specs:
        p='caelum/survival/'+short
        if p not in files:originals[p]=z.read(p);files[p]=originals[p].decode('utf-8').replace('\r\n','\n')
def replace(p,old,new):
    assert files[p].count(old)==1,(p,old[:80]);files[p]=files[p].replace(old,new,1);edits.append((p,old,new))
def end_body(source,begin):
    tokens=re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]');depth=0
    for m in tokens.finditer(source,begin):
        if m.group()=='{':depth+=1
        elif m.group()=='}':
            depth-=1
            if depth==0:return m.end()
    raise AssertionError('Unclosed body')
condition='capacity>=0 && fraction>=0 && water==0 && sweat==0 && submerged==0 && (dw<=0 || thermal.Roof || fraction<=0 || thermal.RainMmHour<=0)'
p='caelum/survival/CaelumThermalService.zs';old='            double water=thermal.WorkWaterKg[slot];\n'
replace(p,old,old+f'''            let ca871SlotProbe=CA871ThermalProbe.FindSample();
            if(ca871SlotProbe!=null)ca871SlotProbe.CountSlot({condition});
''')
for metric,(short,name,args,actor) in enumerate(specs):
    p='caelum/survival/'+short;s=files[p]
    pattern=r'(?m)^    (?P<prefix>(?:(?:static|action|virtual|override) )*)(?P<type>\w+) '+name+r'\((?P<params>[^)]*)\)\s*\{'
    matches=list(re.finditer(pattern,s));assert len(matches)==1,(p,name,len(matches));m=matches[0]
    end=end_body(s,m.end()-1);old=s[m.start():end];renamed=old.replace(name+'(',f'CA871Original{metric}(',1)
    family=f'CA871ThermalProbe.Family({actor})' if actor else 'ca871Probe.CurrentFamily'
    begin_context='int ca871Previous=0;if(ca871Probe!=null){ca871Previous=ca871Probe.CurrentFamily;ca871Probe.CurrentFamily=ca871Family;}' if name=='Advance' else ''
    end_context='if(ca871Probe!=null)ca871Probe.CurrentFamily=ca871Previous;' if name=='Advance' else ''
    call=f'CA871Original{metric}({args});';is_void=m['type']=='void'
    wrapper=s[m.start():m.end()]+f'''
        let ca871Probe=CA871ThermalProbe.FindSample();
        int ca871Family=ca871Probe!=null?{family}:0;
        {begin_context}
        double ca871Start=ca871Probe!=null?MSTimeF():0;
        '''+('' if is_void else 'let ca871Result=')+call+f'''
        if(ca871Probe!=null)ca871Probe.Record(ca871Family*10+{metric},ca871Start);
        {end_context}
        '''+('' if is_void else 'return ca871Result;')+'''
    }
'''+renamed
    replace(p,old,wrapper)
restored=dict(files)
for p,old,new in reversed(edits):assert restored[p].count(new)==1;restored[p]=restored[p].replace(new,old,1)
for p,s in restored.items():assert s.replace('\n','\r\n' if b'\r\n' in originals[p] else '\n').encode()==originals[p]
handler='''
class CA871ThermalProbe : StaticEventHandler
{
    const METRICS=30;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;int CurrentFamily;
    static CA871ThermalProbe FindSample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA871ThermalProbe(StaticEventHandler.Find('CA871ThermalProbe'));
    }
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);CurrentFamily=2;Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    void CountSlot(bool dry){Calls[(CurrentFamily*10+(dry?8:9))*WINDOW+level.time-3599]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA871 THERMAL tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA871 THERMAL_COMPLETE");
    }
}
'''
files['caelum/survival/CaelumThermalRuntime.zs']+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA871ThermalProbe" }\n'
with zipfile.ZipFile(out/'thermal.pk3','x') as z:
    for p,s in sorted(files.items()):
        data=s.replace('\n','\r\n' if b'\r\n' in originals.get(p,b'') else '\n').encode();z.writestr(zipfile.ZipInfo(p,(2026,11,21,0,0,0)),data)
        target=out/'source'/p;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
stages=[short+':'+name for short,name,*_ in specs]+['eligible-dry-slots','fallback-slots']
metrics=[dict(id=family*10+i,family=family_name,stage=stage) for family,family_name in enumerate(['Mandinga','PortDefender','other']) for i,stage in enumerate(stages)]
manifest=dict(issue=871,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'thermal.pk3').read_bytes()),originals_restored_exactly={p:sha(b) for p,b in originals.items()},metrics=metrics,period=17,dry_condition=condition,qualification='Private inclusive call timers and branch counts; no math or production statements changed. Advance temporarily tags nested thermal calls by actor family and restores prior tag; direct forecast/other calls remain other. Counts are observed, not a skipped production branch. Overlapping inclusive timers include wrapper/counter overhead and cannot be summed as CPU budgets.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),overlay_sha256=manifest['overlay_sha256'])))
