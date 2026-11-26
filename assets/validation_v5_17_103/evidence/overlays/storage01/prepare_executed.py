"""Classify timed native storage lookups without changing their result paths."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/survival/CaelumContaminationState.zs'
with zipfile.ZipFile(a.runtime) as package:original=package.read(path)
newline='\r\n' if b'\r\n' in original else '\n';source=original.decode('utf-8').replace('\r\n','\n');edits=[]
for method,args,offset in [('Get','body,create,raw',0),('Value','body',6)]:
    pattern=r'    static (\w+) '+method+r'\(([^)]*)\)\s*\{';matches=list(re.finditer(pattern,source));assert len(matches)==1,(method,len(matches));m=matches[0]
    signature=m[0][:-1].rstrip();renamed=signature.replace(' '+method+'(',' CA849Original_'+method+'(')
    create='create' if method=='Get' else 'false'
    oracle='if(category==1 || category==2){let npc=CaelumCombatActor(body);if(result!=npc.ContaminationBody)probe.Mismatches++;}' if method=='Get' else ''
    wrapper=signature+'''
    {
        CA849StorageProbe probe=null;int category=0;double start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {
            probe=CA849StorageProbe(StaticEventHandler.Find('CA849StorageProbe'));
            if(probe!=null){category=probe.Category(body,CREATE);start=MSTimeF();}
        }
        TYPE result=CA849Original_METHOD(ARGS);
        if(probe!=null){probe.Record(OFFSET+category,start);ORACLE}
        return result;
    }
'''.replace('CREATE',create).replace('TYPE',m[1]).replace('METHOD',method).replace('ARGS',args).replace('OFFSET',str(offset)).replace('ORACLE',oracle)+renamed+'\n    {'
    source=source[:m.start()]+wrapper+source[m.end():];edits.append((m[0],wrapper))
restored=source
for old,new in reversed(edits):assert restored.count(new)==1;restored=restored.replace(new,old)
assert restored.replace('\n',newline).encode()==original
handler='''
class CA849StorageProbe : StaticEventHandler
{
    const METRICS=12;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;int Mismatches;
    int Category(Actor body,bool create)
    {
        if(body==null || body is 'CaelumPlayer')return 0;
        let npc=CaelumCombatActor(body);
        if(npc!=null)
        {
            if(npc.ContaminationBodyReady && npc.ContaminationBody!=null)return 1;
            if(npc.ContaminationBodyReady && !create)return 2;
            return 3;
        }
        if(body is 'Inventory')return 4;
        return 5;
    }
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA849 STORAGE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA849 STORAGE_COMPLETE mismatches=%d",Mismatches);
    }
}
'''
files={path:(source+handler).replace('\n',newline).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA849StorageProbe" }\n'}
with zipfile.ZipFile(out/'storage.pk3','w') as z:
    for name,data in sorted(files.items()):
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest();categories=['null_or_player','npc_warm_record','npc_warm_empty_read','npc_cold_or_create','inventory','other_actor']
manifest=dict(issue=849,runtime_sha256=sha(a.runtime.read_bytes()),original_source_sha256=sha(original),overlay_sha256=sha((out/'storage.pk3').read_bytes()),inverse_exact=True,sample_tics=list(range(3599,4299,17)),metrics=[dict(id=i,label=('Get.' if i<6 else 'Value.')+categories[i%6]) for i in range(12)],qualification='Classification is outside the timed original body. Get recursion and Get inside Value remain nested/inclusive and include probe overhead. Warm NPC result identity is compared after the original call; this does not prove cold-state migration or author acceptance.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
