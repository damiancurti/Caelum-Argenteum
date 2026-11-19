"""Measure clock/contact service bodies and their exact map-classification leaf."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
specs=[('survival/CaelumThermalRuntime','Stamp','clock'),('survival/CaelumThermalRuntime','WorldTicSeconds',''),('survival/CaelumThermalEnvironment','Get',''),('world/CaelumWorldClock','Get','user,create'),('survival/CaelumContaminationObject','SettleNow','')]
originals={};files={};edits=[];metrics=[]
with zipfile.ZipFile(a.runtime) as package:
    for i,(short,method,arguments) in enumerate(specs):
        path='caelum/'+short+'.zs'
        if path not in files:originals[path]=package.read(path);files[path]=originals[path].decode('utf-8').replace('\r\n','\n')
        source=files[path]
        matches=list(re.finditer(r'    (?:(static|override|virtual) )?(\w+) '+method+r'\(([^)]*)\)\s*\{',source))
        matches=[m for m in matches if ','.join(part.split('=')[0].split()[-1] for part in m[3].split(',') if part.strip())==arguments]
        assert len(matches)==1,(path,method,len(matches))
        m=matches[0];kind=m[2];signature=m[0][:-1].rstrip()
        renamed=signature.replace(' '+method+'(',' CA846Body_'+method+'(').replace('override ','').replace('virtual ','')
        result='CA846Body_'+method+'('+arguments+');';invoke=result if kind=='void' else kind+' ca846Result='+result
        ret='' if kind=='void' else 'return ca846Result;'
        wrapper=signature+'''\n    {
        CA846ServiceProbe ca846Probe=null;double ca846Start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {ca846Probe=CA846ServiceProbe(StaticEventHandler.Find('CA846ServiceProbe'));if(ca846Probe!=null)ca846Start=MSTimeF();}
        '''+invoke+f'''
        if(ca846Probe!=null)ca846Probe.Record({i},ca846Start);
        {ret}
    }}
'''+renamed+'\n    {'
        files[path]=source[:m.start()]+wrapper+source[m.end():];edits.append((path,m[0],wrapper));metrics.append(dict(id=i,path=path,method=method))
path='caelum/survival/CaelumThermalRuntime.zs';old='if(CaelumWorldCatalogue.IsLimboMap(level.MapName))';new='if(CA846ServiceProbe.Classify(level.MapName))'
assert files[path].count(old)==1;files[path]=files[path].replace(old,new);edits.append((path,old,new))
metrics.append(dict(id=5,path='caelum/world/CaelumWorldCatalogue.zs',method='IsLimboMap_from_Stamp'))
restored=dict(files)
for path,old,new in reversed(edits):assert restored[path].count(new)==1;restored[path]=restored[path].replace(new,old)
for path,source in restored.items():assert source.replace('\n','\r\n').encode()==originals[path],path
handler='''
class CA846ServiceProbe : StaticEventHandler
{
    const METRICS=6;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed,BenchDone;int Mismatches;
    static clearscope bool Candidate(String mapName)
    {return mapName ~== CaelumWorldCatalogue.MapForLocation(CaelumWorldCatalogue.LOCATION_MANSION);}
    static bool Classify(String mapName)
    {
        CA846ServiceProbe probe=null;double start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {probe=CA846ServiceProbe(StaticEventHandler.Find('CA846ServiceProbe'));if(probe!=null)start=MSTimeF();}
        bool result=CaelumWorldCatalogue.IsLimboMap(mapName);
        if(probe!=null){probe.Record(5,start);if(result!=Candidate(mapName))probe.Mismatches++;}
        return result;
    }
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!BenchDone && level.time==3500)
        {
            BenchDone=true;double before=0,after=0;int mismatches=0;
            bool expected=CaelumWorldCatalogue.IsLimboMap(level.MapName);
            for(int round=0;round<16;round++)for(int pass=0;pass<2;pass++)
            {
                bool candidate=(round+pass)%2==0;double start=MSTimeF();
                if(candidate){for(int i=0;i<10000;i++)if(Candidate(level.MapName)!=expected)mismatches++;}
                else {for(int i=0;i<10000;i++)if(CaelumWorldCatalogue.IsLimboMap(level.MapName)!=expected)mismatches++;}
                double elapsed=MSTimeF()-start;if(candidate)after+=elapsed;else before+=elapsed;
            }
            Console.Printf("CA846 LOCATION_BENCH map=%s calls_each=160000 reference_ms=%.6f candidate_ms=%.6f mismatches=%d",level.MapName,before,after,mismatches);
        }
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA846 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA846 SERVICES_COMPLETE mismatches=%d",Mismatches);
    }
}
'''
files['caelum/survival/CaelumThermalRuntime.zs']+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA846ServiceProbe" }\n'
with zipfile.ZipFile(out/'services.pk3','w') as z:
    for path,source in sorted(files.items()):
        data=source.replace('\n','\r\n').encode();z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
        target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(runtime_sha256=sha(a.runtime.read_bytes()),overlay_sha256=sha((out/'services.pk3').read_bytes()),originals_restored_exactly={path:sha(data) for path,data in originals.items()},period=17,metrics=metrics,qualification='Inclusive sampled bodies; nested wrapper overhead remains. The map-classification leaf is measured only when called from Stamp. A separate alternating-order pure-predicate loop is diagnostic, not production throughput.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(output=str(out),metrics=len(metrics),overlay_sha256=manifest['overlay_sha256'])))
