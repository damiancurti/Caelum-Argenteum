"""Measure existing candidate stages and loop entries without changing selection."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue871-index01.pk3';out=ROOT/'build/issue873-light-stages02';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(ROOT/'build/issue873-light02/light.pk3') as z:raw=z.read(path)
s=raw.decode('utf-8').replace('\r\n','\n');original=s
def end_body(text,begin):
    depth=0
    for m in re.finditer(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]',text[begin:]):
        if m[0]=='{':depth+=1
        elif m[0]=='}':
            depth-=1
            if depth==0:return begin+m.end()
    raise AssertionError('Unclosed body')
start=s.index('    static Actor Candidate(');opening=s.index('{',start);end=end_body(s,opening)
old=s[start:end];body=old
header='    static Actor Candidate(CaelumCombatActor observer)\n    {'
assert body.count(header)==1
body=body.replace(header,header+'''
        let ca873Probe=CA873CandidateProbe.FindFor(observer);
        int ca873Family=ca873Probe!=null?CA873CandidateProbe.Family(observer):0;
        double ca873Start=0;int ca873Items=0;
''',1)
def timing(statement,metric):
    return f'ca873Start=ca873Probe!=null?MSTimeF():0;ca873Items=0;\n        '+statement+f'\n        if(ca873Probe!=null)ca873Probe.Record(ca873Family*7+{metric},ca873Start,ca873Items);'
setup='let group=CaelumCommunication.CandidatesFor(observer);';assert body.count(setup)==1
body=body.replace(setup,timing(setup,1),1)
for needle,metric,prefix in [
    ('for(int i=0;i<group.Candidates.Size();i++)',2,''),
    ('for(int i=0;i<group.Members.Size();i++)',3,''),
    ('while(local.Next())',4,'let local=BlockThingsIterator.Create(observer,QueryRadius(observer));'),
    ('if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)',5,''),
]:
    a=body.index(needle);b=body.index('{',a);c=end_body(body,b)
    original_loop=body[a:c];loop=original_loop[:b-a+1]+'ca873Items++;'+original_loop[b-a+1:]
    if prefix:
        a=body.index(prefix);assert body[a:c].endswith(original_loop)
        loop=body[a:c].replace(original_loop,loop,1)
    body=body[:a]+timing(loop,metric)+body[c:]
ally='if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);';assert body.count(ally)==2
body=body.replace(ally,'''if(ally!=null)
        {
            ca873Start=ca873Probe!=null?MSTimeF():0;
            CaelumCommunication.ObserveAlly(observer,ally);
            if(ca873Probe!=null)ca873Probe.Record(ca873Family*7+6,ca873Start,1);
        }''')
renamed=body.replace('Candidate(', 'CA873OriginalCandidate(',1)
wrapper=header+'''
        let ca873Probe=CA873CandidateProbe.FindFor(observer);
        double ca873Start=ca873Probe!=null?MSTimeF():0;
        let ca873Result=CA873OriginalCandidate(observer);
        if(ca873Probe!=null)ca873Probe.Record(CA873CandidateProbe.Family(observer)*7,ca873Start,0);
        return ca873Result;
    }
'''+renamed
s=s[:start]+wrapper+s[end:];assert s.replace(wrapper,old,1)==original
handler='''
class CA873CandidateProbe : StaticEventHandler
{
    const METRICS=21;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls,Items;
    bool Ready,Printed;
    static CA873CandidateProbe FindFor(Actor body)
    {
        if(body==null || level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA873CandidateProbe(StaticEventHandler.Find('CA873CandidateProbe'));
    }
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Items.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start,int loopEntries)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;Items[cell]+=loopEntries;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA873 CANDIDATE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d items=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell],Items[cell]);}
        Console.Printf("CA873 CANDIDATES_COMPLETE");
    }
}
'''
files={path:(s+handler).replace('\n','\r\n' if b'\r\n' in raw else '\n').encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA873CandidateProbe" }\n'}
with zipfile.ZipFile(out/'candidate.pk3','x') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
        p=out/'source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
stages=['total','group-setup','group-enemies','group-allies','local-query','unlinked-fallback','observe-ally']
metrics=[dict(id=f*7+i,family=family,stage=stage) for f,family in enumerate(['Mandinga','PortDefender','other']) for i,stage in enumerate(stages)]
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=873,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'candidate.pk3').read_bytes()),originals_restored_exactly={path:sha(raw)},metrics=metrics,period=17,qualification='Light-factor prototype, compared with its own uninstrumented source. Existing Candidate statements/arguments/list order are retained and restore exactly. Private stage timers and loop-entry integer counters add overhead; no new query, second traversal, saved actor fields or gameplay changes. Inclusive total overlaps stage timings. Items count existing loop entries, not unique actors or successful visibility checks.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),overlay_sha256=manifest['overlay_sha256'])))
