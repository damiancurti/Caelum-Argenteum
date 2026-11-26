"""Measure every approved-window tic with nested inclusive/exclusive scopes."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'

def classes(source):
    masked=re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27',lambda m:' '*len(m[0]),source,flags=re.S)
    result=[]
    for match in re.finditer(r'^class\s+(\w+)\b',masked,re.M):
        start=match.start();end=masked.index('{',match.end())+1;depth=1
        while depth:
            if masked[end]=='{':depth+=1
            elif masked[end]=='}':depth-=1
            end+=1
        result.append((match[1],start,end))
    return result

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(R/'build');out.mkdir(exist_ok=False)
    actor_classes={'CaelumCombatActor','CaelumPortDefender','CaelumMandinga','CaelumAnchoredResident','CaelumPortSiege','CaelumContaminationContact','CaelumContaminationObject','CaelumPlayer'}
    files={};originals={};specs=[];edits=[]
    with zipfile.ZipFile(args.runtime) as z:
        for path in sorted(z.namelist()):
            if not path.startswith('caelum/') or not path.endswith('.zs'):continue
            original=z.read(path).decode('utf-8')
            if 'override void WorldTick()' not in original and not any('class '+name+' ' in original for name in actor_classes):continue
            for cls,a,b in classes(original):
                body=original[a:b]
                if 'override void WorldTick()' in body:specs.append((path,cls,'WorldTick'))
                if cls in actor_classes and 'override void Tick()' in body:specs.append((path,cls,'Tick'))
            if any(s[0]==path for s in specs):files[path]=original;originals[path]=original
    assert len(specs)>=20 and {s[1] for s in specs if s[2]=='Tick'}==actor_classes, (len(specs),sorted(actor_classes-{s[1] for s in specs if s[2]=='Tick'}))
    for key,(path,cls,method) in enumerate(specs):
        source=files[path];_,a,b=next(row for row in classes(source) if row[0]==cls);prior=source[a:b]
        anchor='override void '+method+'()';assert prior.count(anchor)==1
        body_name='CA838Body_'+cls+'_'+method
        updated=prior.replace(anchor,'void '+body_name+'()',1)
        wrapper=f'''
    override void {method}()
    {{
        CA838BurstProfile probe=null;
        if(level.time>=3599 && level.time<4299)probe=CA838BurstProfile(StaticEventHandler.Find('CA838BurstProfile'));
        if(probe!=null)probe.Begin({key});
        {body_name}();
        if(probe!=null)probe.End();
    }}
'''
        updated=updated[:-1]+wrapper+updated[-1:]
        files[path]=source[:a]+updated+source[b:];edits.append((path,prior,updated))
    restored=dict(files)
    for path,prior,updated in reversed(edits):
        assert restored[path].count(updated)==1
        restored[path]=restored[path].replace(updated,prior,1)
    assert restored==originals
    handler='''
class CA838BurstProfile : StaticEventHandler
{
    const WINDOW=700;
    const METRICS=METRIC_COUNT;
    Array<double> Inclusive,Exclusive,Maximum,Wall;
    Array<int> Calls,StackKey,StackTic;
    Array<double> StackStart,StackChildren;
    double Previous;
    int PreviousTic,Errors;
    bool Ready,Printed;
    override void OnRegister(){SetOrder(-2147483647);}
    override void WorldLoaded(WorldEvent e)
    {
        Inclusive.Resize(WINDOW*METRICS);Exclusive.Resize(WINDOW*METRICS);Maximum.Resize(WINDOW*METRICS);Calls.Resize(WINDOW*METRICS);
        Wall.Resize(WINDOW);Ready=true;PreviousTic=-1;
    }
    void Begin(int metric)
    {
        StackKey.Push(metric);StackTic.Push(level.time-3599);StackChildren.Push(0);StackStart.Push(MSTimeF());
    }
    void End()
    {
        int last=StackKey.Size()-1;if(last<0){Errors++;return;}
        double elapsed=MSTimeF()-StackStart[last];int cell=StackKey[last]*WINDOW+StackTic[last];
        Inclusive[cell]+=elapsed;Exclusive[cell]+=Max(0.0,elapsed-StackChildren[last]);Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;
        StackKey.Pop();StackTic.Pop();StackStart.Pop();StackChildren.Pop();
        if(last>0)StackChildren[last-1]+=elapsed;
    }
    override void WorldTick()
    {
        if(!Ready)return;
        double now=MSTimeF();
        if(level.time>=3600 && level.time<=4299 && PreviousTic==level.time-1)Wall[level.time-3600]=now-Previous;
        Previous=now;PreviousTic=level.time;
        if(level.time==4350 && !Printed)
        {
            Printed=true;
            Console.Printf("CA838 BEGIN metrics=%d window=%d errors=%d depth=%d",METRICS,WINDOW,Errors,StackKey.Size());
            for(int tic=0;tic<WINDOW;tic++)
            {
                Console.Printf("CA838 WALL tic=%d ms=%.6f",tic+3599,Wall[tic]);
                for(int metric=0;metric<METRICS;metric++)
                {
                    int cell=metric*WINDOW+tic;
                    if(Calls[cell]>0)Console.Printf("CA838 SCOPE tic=%d metric=%d inclusive=%.6f exclusive=%.6f maximum=%.6f calls=%d",tic+3599,metric,Inclusive[cell],Exclusive[cell],Maximum[cell],Calls[cell]);
                }
            }
            Console.Printf("CA838 COMPLETE errors=%d depth=%d",Errors,StackKey.Size());
        }
    }
}
'''.replace('METRIC_COUNT',str(len(specs)))
    first=specs[0][0];files[first]+=handler
    files['MAPINFO']='gameinfo { AddEventHandlers="CA838BurstProfile" }\n'
    with zipfile.ZipFile(out/'bursts.pk3','w') as z:
        for name,source in sorted(files.items()):
            data=source.encode('utf-8');z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
            p=out/'source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
    sha=lambda b:hashlib.sha256(b).hexdigest()
    manifest={'issue':838,'runtime_sha256':sha(args.runtime.read_bytes()),'overlay_sha256':sha((out/'bursts.pk3').read_bytes()),'metrics':[{'id':i,'path':p,'class':c,'method':m} for i,(p,c,m) in enumerate(specs)],'exact_source_restoration':{p:sha(s.encode('utf-8')) for p,s in restored.items()},'window_tics':[3599,4299],'report_tic':4350,'qualification':'Diagnostic every-tic nested scope timers: inclusive contains children; exclusive subtracts measured child bodies. Lookup/stack/timer overhead and uninstrumented work remain. Static first-order boundary precedes ordinary WorldTick callbacks; player-think/native engine work outside scopes remains residual. No production performance or universal equivalence claim.'}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps({'overlay':str(out/'bursts.pk3'),'metrics':len(specs),'files':len(restored),'originals_restored_exactly':True}))

if __name__=='__main__':main()
