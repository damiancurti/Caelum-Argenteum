"""Compare candidate and immutable baseline shelter predicates in the same native calls."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--start',type=int,default=3599);p.add_argument('--end',type=int,default=4299);p.add_argument('--report',type=int,default=4350);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/survival/CaelumThermalEnvironment.zs'
with zipfile.ZipFile(a.runtime) as package:original_bytes=package.read(path)
with zipfile.ZipFile(a.candidate) as package:candidate_bytes=package.read(path)
original=original_bytes.decode('utf-8').replace('\r\n','\n');candidate=candidate_bytes.decode('utf-8').replace('\r\n','\n')
def method(source):
    start=source.index('    static bool WindBlocked(');end=source.index('{',start)+1;depth=1
    masked=re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"',lambda m:' '*len(m[0]),source,flags=re.S)
    while depth:
        if masked[end]=='{':depth+=1
        elif masked[end]=='}':depth-=1
        end+=1
    return source[start:end]
old=method(original);new=method(candidate)
assert original.replace(old,new)==candidate
wrapper='''    static bool WindBlocked(Actor body)
    {
        CA842ShelterOracle probe=null;
        if(level.time>=START_TIC && level.time<END_TIC)probe=CA842ShelterOracle(StaticEventHandler.Find('CA842ShelterOracle'));
        if(probe==null)return CA842Candidate(body);
        double begin,candidateMs,referenceMs;bool result,reference;
        if((probe.Calls&1)==0)
        {
            begin=MSTimeF();result=CA842Candidate(body);candidateMs=MSTimeF()-begin;
            begin=MSTimeF();reference=CA842Reference(body);referenceMs=MSTimeF()-begin;
        }
        else
        {
            begin=MSTimeF();reference=CA842Reference(body);referenceMs=MSTimeF()-begin;
            begin=MSTimeF();result=CA842Candidate(body);candidateMs=MSTimeF()-begin;
        }
        probe.Calls++;if(result)probe.Sheltered++;else probe.Open++;
        probe.CandidateMs+=candidateMs;probe.ReferenceMs+=referenceMs;
        probe.CandidateMax=Max(probe.CandidateMax,candidateMs);probe.ReferenceMax=Max(probe.ReferenceMax,referenceMs);
        if(result!=reference){probe.Errors++;Console.Printf("CA842 SHELTER_FAIL tic=%d class=%s",level.time,body.GetClassName());}
        return result;
    }
'''.replace('START_TIC',str(a.start)).replace('END_TIC',str(a.end))
replacement=wrapper+new.replace(' WindBlocked(',' CA842Candidate(')+'\n'+old.replace(' WindBlocked(',' CA842Reference(')
source=candidate.replace(new,replacement)
assert source.replace(replacement,new)==candidate
handler='''
class CA842ShelterOracle : StaticEventHandler
{
    int Calls,Sheltered,Open,Errors;double CandidateMs,ReferenceMs,CandidateMax,ReferenceMax;
    bool Printed;
    override void WorldTick()
    {
        if(Printed || level.time!=REPORT_TIC)return;Printed=true;
        Console.Printf("CA842 SHELTER_COMPLETE calls=%d sheltered=%d open=%d errors=%d candidate=%.6f reference=%.6f candidate_max=%.6f reference_max=%.6f",Calls,Sheltered,Open,Errors,CandidateMs,ReferenceMs,CandidateMax,ReferenceMax);
    }
}
'''.replace('REPORT_TIC',str(a.report))
files={path:(source+handler).replace('\n','\r\n').encode('utf-8'),'MAPINFO':b'gameinfo { AddEventHandlers="CA842ShelterOracle" }\n'}
with zipfile.ZipFile(out/'oracle.pk3','w') as package:
    for name,data in files.items():
        package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(runtime_sha256=sha(a.runtime.read_bytes()),candidate_sha256=sha(candidate_bytes),baseline_source_sha256=sha(original_bytes),overlay_sha256=sha((out/'oracle.pk3').read_bytes()),inverse_restoration_exact=True,window=[a.start,a.end],report_tic=a.report,qualification='Candidate/reference evaluation order alternates by call at identical actor/geometry state. Native tracing is repeated; local timings include call/timer overhead. Oracle instrumentation is not production throughput.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
