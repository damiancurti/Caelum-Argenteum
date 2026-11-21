"""Adapt retained native ownership contracts to current Value equivalence."""
from pathlib import Path

root = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
original = root/'assets/validation_v5_17_103/run_carriers.py'
source = original.read_text(encoding='utf-8')
source = source.replace("ROOT=Path(__file__).resolve().parents[2]", 'ROOT=Path('+repr(str(root))+')')
source = source.replace("start=storage.index('    static CaelumContaminationState Get(Actor body,');end=storage.index('    static double Value(Actor body)',start)", "start=storage.index('    static clearscope bool NativeCarrierBody(Actor body)');end=storage.index('    static void Set(Actor body,double value)',start)")
benchmark = r'''    void Benchmark()
    {
        for(int bodyIndex=0;bodyIndex<SavedBodies.Size();bodyIndex++)
        {
            let body=SavedBodies[bodyIndex];double expected=CA849StorageReference.Value(body);
            for(int mode=0;mode<2;mode++)
            {
                let entry=CaelumContaminationStorage.Get(body,true);
                if(mode==1 && bodyIndex<2)
                {
                    if(entry.Exposure!=null)entry.Exposure.Release();
                    let world=CaelumThermalWorld.Get();Check(world!=null && world.ReferenceClock!=null,"benchmark clock");
                    let exposure=new('CaelumContaminationObject');exposure.Body=body;exposure.Revision=4;
                    exposure.Ready=true;exposure.HistoryReady=true;exposure.HistoryNoWash=true;
                    exposure.Stamp=CaelumThermalRuntime.Stamp(world.ReferenceClock);exposure.HistoryStamp=exposure.Stamp;
                    exposure.HistoryAmbient=entry.Concentration;exposure.HistoryArea=1;entry.Exposure=exposure;
                }
                double original=0,candidate=0;int differences=0;
                for(int round=0;round<16;round++)for(int order=0;order<2;order++)
                {
                    bool current=(round+order)%2==0;double start=MSTimeF();
                    if(current){for(int n=0;n<10000;n++)if(CaelumContaminationStorage.Value(body)!=expected)differences++;}
                    else {for(int n=0;n<10000;n++)if(CA849StorageReference.Value(body)!=expected)differences++;}
                    double elapsed=MSTimeF()-start;if(current)candidate+=elapsed;else original+=elapsed;
                }
                Check(differences==0,"value benchmark parity");
                Console.Printf("CA849 VALUE_BENCH class=%s mode=%d calls_each=160000 original_ms=%.6f candidate_ms=%.6f mismatches=%d",body.GetClassName(),mode,original,candidate,differences);
            }
        }
    }
'''
matrix = r'''    void ValueMatrix(CaelumPlayer user)
    {
        Check(CaelumContaminationStorage.Value(null)==CA849StorageReference.Value(null),"null value");
        Check(CaelumContaminationStorage.Value(user)==CA849StorageReference.Value(user),"player value");
        Array<class<Actor> > types={'CA849GateProbe','CA849VehicleProbe','CaelumMachineBlock','CaelumRamBlock','CaelumRamHead','CaelumCannonBlock','CA849NpcProbe'};
        let world=CaelumThermalWorld.Get();Check(world!=null && world.ReferenceClock!=null,"matrix clock");
        if(world==null || world.ReferenceClock==null)return;
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        for(int typeIndex=0;typeIndex<types.Size();typeIndex++)for(int mode=0;mode<7;mode++)
        {
            let first=Actor.Spawn(types[typeIndex],user.Pos+(1536,1536,0),NO_REPLACE);
            let second=Actor.Spawn(types[typeIndex],user.Pos+(1792,1536,0),NO_REPLACE);
            Check(first!=null && second!=null,"paired native bodies");
            if(first==null || second==null)continue;
            let a=CaelumContaminationStorage.Get(first,true),b=CaelumContaminationStorage.Get(second,true);
            Check(a!=null && b!=null && a!=b,"independent records");
            a.Concentration=17;b.Concentration=17;
            if(a.Exposure!=null)a.Exposure.Release();if(b.Exposure!=null)b.Exposure.Release();
            if(mode>0)
            {
                let x=new('CaelumContaminationObject'),y=new('CaelumContaminationObject');
                x.Body=first;y.Body=second;x.Revision=4;y.Revision=4;
                x.Ready=mode!=1;y.Ready=x.Ready;x.HistoryReady=mode>=3;y.HistoryReady=x.HistoryReady;
                x.Stamp=now-(mode==2?10:0);y.Stamp=x.Stamp;
                x.Ambient=72;y.Ambient=72;x.Rain=0;y.Rain=0;
                x.HistoryStamp=now+(mode==5?10:mode==4?0:-10);y.HistoryStamp=x.HistoryStamp;
                x.HistoryAmbient=72;y.HistoryAmbient=72;x.HistoryArea=1;y.HistoryArea=1;
                x.HistoryNoWash=true;y.HistoryNoWash=true;
                a.Exposure=x;b.Exposure=y;
                if(mode==6){a.Revision=0;b.Revision=0;}
            }
            int phase=world.NextPhase;
            double expected=CA849StorageReference.Value(first);int afterPhase=world.NextPhase;
            world.NextPhase=phase;double actual=CaelumContaminationStorage.Value(second);
            Check(actual==expected,"value matches original");
            Check(a.Concentration==b.Concentration && a.Revision==b.Revision,"record effects match");
            Check(world.NextPhase==afterPhase,"world scheduling effects match");
            if(a.Exposure!=null && b.Exposure!=null)
            {
                let x=a.Exposure,y=b.Exposure;
                Check(x.Ready==y.Ready && x.Stamp==y.Stamp && x.HistoryStamp==y.HistoryStamp && x.HistoryReady==y.HistoryReady,"settlement effects match");
                x.Release();y.Release();
            }
            first.Destroy();second.Destroy();
        }
    }
'''
injection = '\n'+'''start=source.index('    void Benchmark()');end=source.index('    void IsolatePersistence()',start)
source=source[:start]+BENCHMARK+MATRIX+source[end:]
source=source.replace('Resume();Exercise(user);','Resume();Exercise(user);ValueMatrix(user);')
'''.replace('BENCHMARK', repr(benchmark)).replace('MATRIX', repr(matrix))+'\n'
anchor = '\nretained={name:'
assert source.count(anchor) == 1
source = source.replace(anchor, injection+anchor)
source = source.replace('CA849', 'CA864').replace("issue=849,", "issue=864,")
target = Path(__file__).with_name('run_value864.py')
target.write_text(source, encoding='utf-8', newline='\n')
print(target)
