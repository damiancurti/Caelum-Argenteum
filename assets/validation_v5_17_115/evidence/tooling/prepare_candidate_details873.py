"""Measure candidate lookup/filter helpers in their real call context."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue871-index01.pk3';out=ROOT/'build/issue873-details01';out.mkdir(exist_ok=False)
specs=[('actors/CaelumVisualPerception.zs', 'Candidate', 'observer', 'observer'), ('actors/CaelumCommunication.zs', 'CandidatesFor', 'body', None), ('actors/CaelumCommunication.zs', 'Refresh', 'leader', None), ('actors/CaelumVisualPerception.zs', 'QueryRadius', 'observer', None), ('actors/CaelumVisualPerception.zs', 'Opponent', 'observer,candidate', None), ('actors/CaelumVisualPerception.zs', 'RelatedOpponent', 'observer,candidate', None), ('actors/CaelumVisualPerception.zs', 'OutsideGroupReach', 'observer,candidate,sightUpper', None), ('actors/CaelumCommunication.zs', 'Eligible', 'sender,receiver', None), ('actors/CaelumCommunication.zs', 'Principal', 'body', None), ('actors/CaelumVisualPerception.zs', 'CanSee', 'observer,candidate,knownDistance', None), ('actors/CaelumVisualPerception.zs', 'Touching', 'observer,candidate', None), ('actors/CaelumVisualPerception.zs', 'Range', 'observer,candidate', None), ('actors/CaelumVisualPerception.zs', 'InsightFactor', 'observer', None), ('actors/CaelumVisualPerception.zs', 'Stealth', 'body', None), ('actors/CaelumPopulationState.zs', 'Get', '', None), ('actors/CaelumCommunication.zs', 'Leader', 'body', None)]

originals={};files={};edits=[]
with zipfile.ZipFile(runtime) as z:
    for short,*_ in specs:
        p='caelum/'+short
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
for metric,(short,name,args,actor) in enumerate(specs):
    p='caelum/'+short;s=files[p]
    pattern=r'(?m)^    (?P<prefix>(?:(?:static|action|virtual|override) )*)(?P<type>\w+) '+name+r'\((?P<params>[^)]*)\)\s*\{'
    matches=list(re.finditer(pattern,s));assert len(matches)==1,(p,name,len(matches));m=matches[0]
    end=end_body(s,m.end()-1);old=s[m.start():end];renamed=old.replace(name+'(',f'CA873Original{metric}(',1)
    family=f'CA873CandidateDetailProbe.Family({actor})' if actor else 'ca873Probe.CurrentFamily'
    begin_context='int ca873Previous=0;if(ca873Probe!=null){ca873Previous=ca873Probe.CurrentFamily;ca873Probe.CurrentFamily=ca873Family;ca873Probe.CandidateDepth++;}' if name=='Candidate' else ''
    end_context='if(ca873Probe!=null){ca873Probe.CurrentFamily=ca873Previous;ca873Probe.CandidateDepth--;}' if name=='Candidate' else ''
    call=f'CA873Original{metric}({args});';is_void=m['type']=='void'
    wrapper=s[m.start():m.end()]+f'''
        let ca873Probe=CA873CandidateDetailProbe.FindCandidateScope({str(metric==0).lower()});
        int ca873Family=ca873Probe!=null?{family}:0;
        {begin_context}
        double ca873Start=ca873Probe!=null?MSTimeF():0;
        '''+('' if is_void else 'let ca873Result=')+call+f'''
        if(ca873Probe!=null)ca873Probe.Record(ca873Family*16+{metric},ca873Start);
        {end_context}
        '''+('' if is_void else 'return ca873Result;')+'''
    }
'''+renamed
    replace(p,old,wrapper)
restored=dict(files)
for p,old,new in reversed(edits):assert restored[p].count(new)==1;restored[p]=restored[p].replace(new,old,1)
for p,s in restored.items():assert s.replace('\n','\r\n' if b'\r\n' in originals[p] else '\n').encode()==originals[p]
handler='''
class CA873CandidateDetailProbe : StaticEventHandler
{
    const METRICS=48;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;int CurrentFamily,CandidateDepth;
    static CA873CandidateDetailProbe FindSample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA873CandidateDetailProbe(StaticEventHandler.Find('CA873CandidateDetailProbe'));
    }
    static CA873CandidateDetailProbe FindCandidateScope(bool entry)
    {let probe=FindSample();return probe!=null && (entry || probe.CandidateDepth>0)?probe:null;}
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);CurrentFamily=2;Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA873 DETAIL tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA873 DETAIL_COMPLETE");
    }
}
'''
files['caelum/actors/CaelumVisualPerception.zs']+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA873CandidateDetailProbe" }\n'
with zipfile.ZipFile(out/'details.pk3','x') as z:
    for p,s in sorted(files.items()):
        data=s.replace('\n','\r\n' if b'\r\n' in originals.get(p,b'') else '\n').encode();z.writestr(zipfile.ZipInfo(p,(2026,11,21,0,0,0)),data)
        target=out/'source'/p;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
stages=[short+':'+name for short,name,*_ in specs]
metrics=[dict(id=family*16+i,family=family_name,stage=stage) for family,family_name in enumerate(['Mandinga','PortDefender','other']) for i,stage in enumerate(stages)]
manifest=dict(issue=873,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'details.pk3').read_bytes()),originals_restored_exactly={p:sha(b) for p,b in originals.items()},metrics=metrics,period=17,qualification='Private inclusive candidate-helper timers; no production statements changed. Candidate tags nested calls by actor family and restores the prior tag; subordinate metrics record only inside that Candidate call stack. Nested timers include wrapper overhead and must not be added as independent CPU costs.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),overlay_sha256=manifest['overlay_sha256'])))
