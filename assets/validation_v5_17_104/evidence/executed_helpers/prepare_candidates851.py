"""Measure unchanged candidate-selection branches on bounded sampled tics."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
source=original.decode('utf-8').replace('\r\n','\n');start=source.index('    static Actor Candidate(');end=source.index('    static bool Identify(',start)
body=source[start:end];edits=[]
def change(old,new):
    global body
    assert body.count(old)==1,(old,body.count(old));body=body.replace(old,new);edits.append((old,new))
intro='''        CA851CandidateProbe probe=null;double stamp=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {probe=CA851CandidateProbe(StaticEventHandler.Find('CA851CandidateProbe'));if(probe!=null)stamp=MSTimeF();}
'''
change('    static Actor Candidate(CaelumCombatActor observer)\n    {\n','    static Actor Candidate(CaelumCombatActor observer)\n    {\n'+intro)
def mark(metric):return f'        if(probe!=null)stamp=probe.Mark({metric},stamp);\n'
change('        let group=CaelumCommunication.CandidatesFor(observer);',mark(0)+'        let group=CaelumCommunication.CandidatesFor(observer);\n'+mark(1))
change('            for(int i=0;i<group.Candidates.Size();i++)','            if(probe!=null)stamp=MSTimeF();\n            for(int i=0;i<group.Candidates.Size();i++)')
change('            for(int i=0;i<group.Members.Size();i++)',mark(2)+'            for(int i=0;i<group.Members.Size();i++)')
change('            if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);',mark(3)+'            if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);')
change('            return nearest;',mark(4)+'            return nearest;')
local_start='        let localPopulation=CaelumPopulationState.Get();' if '        let localPopulation=CaelumPopulationState.Get();' in body else '        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));'
change(local_start,'        if(probe!=null)stamp=MSTimeF();\n'+local_start)
change('        let population=CaelumPopulationState.Get();',mark(5)+'        let population=CaelumPopulationState.Get();')
change('\n        if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);','\n'+mark(6)+'        if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);')
change('\n        return nearest;','\n'+mark(7)+'        return nearest;')
restored=body
for old,new in reversed(edits):assert restored.count(new)==1;restored=restored.replace(new,old)
assert restored==source[start:end]
assert (source[:start]+restored+source[end:]).replace('\n','\r\n').encode()==original
metrics=['entry_before_group_lookup','group_lookup','group_candidates','group_members','group_finish','local_candidates','unlinked_guards','local_finish']
handler='''
class CA851CandidateProbe : StaticEventHandler
{
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e){Total.Resize(5600);Maximum.Resize(5600);Calls.Resize(5600);Ready=true;}
    double Mark(int metric,double start)
    {
        double elapsed=MSTimeF()-start;int cell=metric*700+level.time-3599;
        Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;
        return MSTimeF();
    }
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<700;tic++)for(int metric=0;metric<8;metric++)
        {int cell=metric*700+tic;if(Calls[cell]>0)Console.Printf("CA851 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA851 SERVICES_COMPLETE");
    }
}
'''
files={path:(source[:start]+body+source[end:]+handler).replace('\n','\r\n').encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA851CandidateProbe" }\n'}
with zipfile.ZipFile(out/'services.pk3','w') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=851,runtime_sha256=sha(a.runtime.read_bytes()),overlay_sha256=sha((out/'services.pk3').read_bytes()),original_source_sha256=sha(original),inverse_exact=True,period=17,metrics=[dict(id=i,path=path,method=name) for i,name in enumerate(metrics)],qualification='Bounded regions within Candidate, preserving all original statements and order. Entry/cache early returns are not included in entry-before-group timing; region counts describe calls reaching each region. Group setup is excluded. Instrumentation overhead remains; these are not whole-frame gains.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
