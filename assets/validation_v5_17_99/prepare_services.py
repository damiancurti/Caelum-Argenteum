"""Measure selected service bodies on bounded sample tics; inverse-verify sources."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
specs=[('survival/CaelumThermalEnvironment.zs','WindBlocked','body'),('survival/CaelumThermalEnvironment.zs','Roof','body'),('survival/CaelumThermalEnvironment.zs','Sample','body,thermal,localMotionMps'),('survival/CaelumThermalBody.zs','Refresh','body,thermal'),('survival/CaelumThermalService.zs','Integrate','thermal,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,logicalActivitySeconds,firearmWatts'),('survival/CaelumThermalFire.zs','Sample','body,thermal'),('survival/CaelumThermalSurface.zs','Sample','body,thermal,priorKind'),('actors/CaelumCommunication.zs','ObserveAlly','observer,candidate'),('actors/CaelumCommunication.zs','Pending','body')]
originals={};files={};edits=[];metrics=[]
with zipfile.ZipFile(a.runtime) as package:
    for i,(short,method,arguments) in enumerate(specs):
        path='caelum/'+short
        if path not in files:originals[path]=package.read(path);files[path]=originals[path].decode('utf-8').replace('\r\n','\n')
        source=files[path];matches=list(re.finditer(r'    static (\w+) '+method+r'\(([^)]*)\)\s*\{',source));assert len(matches)==1,(path,method)
        m=matches[0];kind=m[1];signature=m[0][:-1].rstrip();renamed=signature.replace(' '+method+'(',' CA842Body_'+method+'(')
        result='CA842Body_'+method+'('+arguments+');'
        invoke=result if kind=='void' else kind+' ca842Result='+result
        ret='' if kind=='void' else 'return ca842Result;'
        wrapper=signature+'''\n    {
        CA842ServiceProbe ca842Probe=null;double ca842Start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {ca842Probe=CA842ServiceProbe(StaticEventHandler.Find('CA842ServiceProbe'));if(ca842Probe!=null)ca842Start=MSTimeF();}
        '''+invoke+f'''
        if(ca842Probe!=null)ca842Probe.Record({i},ca842Start);
        {ret}
    }}
'''+renamed+'\n    {'
        files[path]=source[:m.start()]+wrapper+source[m.end():];edits.append((path,m[0],wrapper))
        metrics.append(dict(id=i,path=path,method=method))
restored=dict(files)
for path,old,new in reversed(edits):assert restored[path].count(new)==1;restored[path]=restored[path].replace(new,old)
for path,source in restored.items():assert source.replace('\n','\r\n').encode('utf-8')==originals[path],path
handler='''
class CA842ServiceProbe : StaticEventHandler
{
    const METRICS=METRIC_COUNT;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA842 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA842 SERVICES_COMPLETE");
    }
}
'''.replace('METRIC_COUNT',str(len(specs)))
files['caelum/'+specs[0][0]]+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA842ServiceProbe" }\n'
with zipfile.ZipFile(out/'services.pk3','w') as package:
    for path,source in sorted(files.items()):
        data=(source.replace('\n','\r\n') if path in originals else source).encode('utf-8');package.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
        target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest={'runtime_sha256':sha(a.runtime.read_bytes()),'overlay_sha256':sha((out/'services.pk3').read_bytes()),'originals_restored_exactly':{path:sha(data) for path,data in originals.items()},'period':17,'metrics':metrics,'qualification':'Inclusive sampled service bodies; nested functions must not be summed twice. Lookup/timer instrumentation overhead remains. This is not production throughput.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
