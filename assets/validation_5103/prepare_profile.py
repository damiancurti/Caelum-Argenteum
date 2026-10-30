"""Build a diagnostic-only timing overlay; never package these wrappers in src."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue428/performance';OUT.mkdir(parents=True,exist_ok=True)
files={}
with zipfile.ZipFile(ROOT/'build/issue428/current/iteration.pk3') as z:
    files.update({n:z.read(n) for n in z.namelist()})
specs=[
 ('caelum/actors/CaelumVisualPerception.zs','Candidate','Actor','CaelumCombatActor observer','observer'),
 ('caelum/actors/CaelumVisualPerception.zs','Acquire','Actor','CaelumCombatActor observer,Actor hint=null','observer,hint'),
 ('caelum/actors/CaelumNoise.zs','Emit','void','Actor origin,int kind,double overrideRange=-1','origin,kind,overrideRange'),
 ('caelum/actors/CaelumCommunication.zs','Pulse','void','CaelumCombatActor body','body'),
]
for file,name,result,params,args in specs:
    text=files.get(file,(ROOT/'src'/file).read_bytes()).decode('utf-8')
    old=f'static {result} {name}(';assert old in text
    text=text.replace(old,f'static {result} Unprofiled{name}(',1)
    metric={'Emit':'Noise','Pulse':'Communication'}.get(name,name)
    call=f'Unprofiled{name}({args});'
    if result!='void':call='Actor value='+call
    wrapper=f'''\n    static {result} {name}({params})
    {{
        let perf=CA510Timings(EventHandler.Find("CA510Timings"));
        bool measured=perf!=null && perf.Running;
        double start=measured ? MSTimeF() : 0;
        {call}
        if(measured){{perf.{metric}MS+=MSTimeF()-start;perf.{metric}Calls++;}}
        {'return value;' if result!='void' else ''}
    }}
'''
    pos=text.rfind('}');text=text[:pos]+wrapper+text[pos:];files[file]=text.encode()
files['caelum/actors/CaelumCommunication.zs']+=b'\nclass CA510Timings : EventHandler\n{\n    double CandidateMS,NoiseMS,CommunicationMS,AcquireMS;\n    int CandidateCalls,NoiseCalls,CommunicationCalls,AcquireCalls,Age;\n    bool Running;\n    override void WorldTick()\n    {\n        Age++;Running=Age>=3600 && Age<4300;\n        if(Age==4300)Console.Printf("CA510 MEASURE candidate_ms=%.6f candidate_calls=%d noise_ms=%.6f noise_calls=%d communication_ms=%.6f communication_calls=%d acquire_ms=%.6f acquire_calls=%d",CandidateMS,CandidateCalls,NoiseMS,NoiseCalls,CommunicationMS,CommunicationCalls,AcquireMS,AcquireCalls);\n    }\n}\n'
files['MAPINFO']=b'GameInfo { AddEventHandlers="CA510Timings" }\n'
with zipfile.ZipFile(OUT/'profile.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared diagnostic-only profile overlay; inclusive timings overlap.')
