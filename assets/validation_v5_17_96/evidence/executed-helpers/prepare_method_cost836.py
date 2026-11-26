"""Sample focused inclusive method costs from the exact #836 baseline package."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'

def class_span(source,name):
    masked=re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27',lambda m:' '*len(m[0]),source,flags=re.S)
    start=re.search(r'^class\s+'+re.escape(name)+r'\b',masked,re.M).start()
    pos=masked.index('{',start)+1;depth=1
    while depth:
        if masked[pos]=='{':depth+=1
        elif masked[pos]=='}':depth-=1
        pos+=1
    return start,pos

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(R/'build');out.mkdir(exist_ok=False)
    visual='caelum/actors/CaelumVisualPerception.zs';combat='caelum/actors/CaelumCombatActor.zs'
    specs=[
      (visual,'CaelumVisualPerception','static ','Actor','Candidate','CaelumCombatActor observer','observer','Candidate'),
      (visual,'CaelumVisualPerception','static ','Actor','Acquire','CaelumCombatActor observer,Actor hint=null','observer,hint','Acquire'),
      (visual,'CaelumVisualPerception','static ','bool','CanSee','CaelumCombatActor observer,Actor candidate,double knownDistance=-1','observer,candidate,knownDistance','CanSee'),
      (visual,'CaelumVisualPerception','static ','bool','Touching','Actor observer,Actor candidate','observer,candidate','Touching'),
      (visual,'CaelumVisualPerception','static ','double','Range','CaelumCombatActor observer,Actor candidate','observer,candidate','Range'),
      (visual,'CaelumVisualPerception','static ','bool','Opponent','CaelumCombatActor observer,Actor candidate','observer,candidate','Opponent'),
      (combat,'CaelumCombatActor','','void','ThermalChase',"statelabel melee='_a_chase_default',statelabel missile='_a_chase_default',int flags=0",'melee,missile,flags','Chase'),
      ('caelum/survival/CaelumContaminationContact.zs','CaelumContaminationContact','override ','void','Tick','','','Contact'),
      ('caelum/survival/CaelumContaminationObject.zs','CaelumContaminationObject','override ','void','Tick','','','ObjectExposure'),
      ('caelum/survival/CaelumThermalRuntime.zs','CaelumThermalRuntime','static ','void','NPCStep','CaelumCombatActor npc,bool force=false','npc,force','Thermal'),
      ('caelum/actors/CaelumCommunication.zs','CaelumCommunication','static ','void','Pulse','CaelumCombatActor body','body','Communication'),
    ]
    files={};originals={};edits=[]
    with zipfile.ZipFile(args.runtime) as package:
        for path,cls,prefix,result,name,parameters,arguments,metric in specs:
            if path not in files:files[path]=package.read(path).decode('utf-8');originals[path]=files[path]
            source=files[path];a,b=class_span(source,cls);prior=source[a:b];anchor=prefix+result+' '+name+'('
            assert prior.count(anchor)==1,(cls,name)
            replacement=('' if prefix=='override ' else prefix)+result+' ProfileBody836'+name+'('
            candidate=prior.replace(anchor,replacement,1)
            call='ProfileBody836'+name+'('+arguments+');'
            if result!='void':call=result+' value='+call
            wrapper=f'''
    {prefix}{result} {name}({parameters})
    {{
        CA836MethodCosts perf=null;
        if(level.time%37==0){{perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}}
        double start=perf!=null?MSTimeF():0;
        {call}
        if(perf!=null){{double elapsed=MSTimeF()-start;perf.{metric}MS+=elapsed;perf.{metric}Calls++;perf.{metric}Max=Max(perf.{metric}Max,elapsed);}}
        {'return value;' if result!='void' else ''}
    }}
'''
            candidate=candidate[:-1]+wrapper+candidate[-1:];files[path]=source[:a]+candidate+source[b:];edits.append((path,prior,candidate))
    restored=dict(files)
    for path,prior,candidate in reversed(edits):
        assert restored[path].count(candidate)==1
        restored[path]=restored[path].replace(candidate,prior,1)
    assert restored==originals
    metrics=[row[-1] for row in specs]
    handler='\nclass CA836MethodCosts : EventHandler\n{\n'
    handler+=''.join(f'    double {m}MS,{m}Max;int {m}Calls;\n' for m in metrics)
    handler+='    int Age;bool Running;\n    override void WorldTick()\n    {\n        Age++;Running=Age>=3600 && Age<4300;\n        if(Age!=4300)return;\n'
    handler+=''.join(f'        Console.Printf("CA836 METHOD {m} ms=%.6f calls=%d max=%.6f",{m}MS,{m}Calls,{m}Max);\n' for m in metrics)
    handler+='        Console.Printf("CA836 PROFILE_COMPLETE interval=37 window=700");\n    }\n}\n'
    files[visual]+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA836MethodCosts" }\n'
    with zipfile.ZipFile(out/'profile.pk3','w') as package:
        for name,source in sorted(files.items()):
            data=source.encode('utf-8');package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
            p=out/'source'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
    sha=lambda b:hashlib.sha256(b).hexdigest()
    report={'issue':836,'runtime_sha256':sha(args.runtime.read_bytes()),'overlay_sha256':sha((out/'profile.pk3').read_bytes()),'instrumented_functions':[row[1]+'.'+row[4] for row in specs],
      'exact_source_restoration':{p:sha(s.encode('utf-8')) for p,s in restored.items()},'sample_interval':37,'window':[3600,4300],
      'qualification':'Sparse inclusive timings; nested scopes and diagnostic overhead overlap. Samples do not establish production savings. No production source or game rule changes.'}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'profile':str(out/'profile.pk3'),'functions':len(specs),'source_files':len(restored)}))

if __name__=='__main__':main()
