"""Prepare an exact-source null eligibility guard and bounded native oracle."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--oracle',action='store_true');a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/survival/CaelumContaminationStack.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
source=original.decode('utf-8').replace('\r\n','\n')
anchor='    static bool Eligible(Inventory item)\n    {\n'
assert source.count(anchor)==1
guard='        // Un contacto sin inventario no puede contener una pila.\n        if(item==null)return false;\n'
candidate=source.replace(anchor,anchor+guard)
assert candidate.replace(guard,'').replace('\n','\r\n').encode()==original
files={path:candidate}
if a.oracle:
    start=source.index(anchor);end=source.index('    static CaelumContaminationState Record(',start)
    reference=source[start:end].replace(' Eligible(',' ReferenceEligible(',1)
    files[path]=candidate[:candidate.index(anchor)]+reference+candidate[candidate.index(anchor):]
    original_call=anchor+guard
    wrapper=anchor+'''        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {
            let probe=CA844NullProbe(StaticEventHandler.Find('CA844NullProbe'));
            if(probe!=null){if(item==null){probe.NullCalls++;if(ReferenceEligible(item))probe.Mismatches++;}else probe.NonNullCalls++;}
        }
'''+guard
    assert files[path].count(original_call)==1;files[path]=files[path].replace(original_call,wrapper)
    files[path]+='''
class CA844NullProbe : StaticEventHandler
{
    int NullCalls,NonNullCalls,Mismatches;
    bool BenchDone;
    bool Candidate(Inventory item){if(item==null)return false;return CaelumContaminationStack.ReferenceEligible(item);}
    override void WorldTick()
    {
        if(!BenchDone && level.time==3500)
        {
            BenchDone=true;double before=0,after=0;int unexpected=0;
            for(int round=0;round<16;round++)for(int pass=0;pass<2;pass++)
            {
                bool candidate=(round+pass)%2==0;double start=MSTimeF();
                if(candidate){for(int i=0;i<10000;i++)if(Candidate(null))unexpected++;}
                else {for(int i=0;i<10000;i++)if(CaelumContaminationStack.ReferenceEligible(null))unexpected++;}
                double elapsed=MSTimeF()-start;if(candidate)after+=elapsed;else before+=elapsed;
            }
            Console.Printf("CA844 NULL_BENCH calls_each=160000 before_ms=%.6f after_ms=%.6f unexpected=%d",before,after,unexpected);
        }
        if(level.time==4350)Console.Printf("CA844 NULL_ORACLE null=%d nonnull=%d mismatches=%d",NullCalls,NonNullCalls,Mismatches);
    }
}
'''
    files['MAPINFO']='gameinfo { AddEventHandlers="CA844NullProbe" }\n'
with zipfile.ZipFile(out/'null.pk3','w') as z:
    for name,text in sorted(files.items()):
        data=text.replace('\n','\r\n').encode();z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
        target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(runtime_sha256=sha(a.runtime.read_bytes()),original_sha256=sha(original),candidate_sha256=sha(candidate.replace('\n','\r\n').encode()),overlay_sha256=sha((out/'null.pk3').read_bytes()),inverse_exact=True,oracle=a.oracle)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
