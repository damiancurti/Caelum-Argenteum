// Observador privado del guardado del autor: no cambia blancos ni posiciones.
class CA353Performance : EventHandler
{
    const REQUIRE_FIXED=0;
    int Age,StartTic;
    bool SeedReady,Started,Finished;
    CaelumPortSiege Port;
    Array<CaelumCombatActor> Bodies;
    Array<double> Stamps;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
    transient int ObservationTics;
    transient Array<CaelumCombatActor> Watched;
    transient Array<double> InitialX,InitialY,InitialZ;
    transient Array<int> Identities;
    transient int Failures;
    override bool InputProcess(InputEvent e){return true;}
    void Sample()
    {
        if(Port==null)Port=CaelumPortSiege.Get();
        if(Port==null){Console.Printf("CA282 FAIL no port siege");return;}
        int living=0,active=0,navigation=0,real=0,cold=0,ropes=0,rows=0;
        for(int i=0;i<Port.Attackers.Size();i++)
        {
            let entry=Port.Attackers[i];let body=entry.Body;
            if(body==null || body.health<=0 || !CaelumDemonService.Supports(body))continue;
            living++;
            if(body.DemonBreath==null)continue;
            active++;let victim=body.target;
            bool nav=victim is 'CaelumSewerEscapeTarget';
            bool chilled=body.ThermalState!=null && body.ThermalState.Exposure<0 && body.ThermalState.Severity>0;
            bool tied=CaelumBolas.Restrained(body);
            if(ObservationTics==1 && nav)
            {Watched.Push(body);InitialX.Push(body.Pos.X);InitialY.Push(body.Pos.Y);InitialZ.Push(body.Pos.Z);Identities.Push(entry.StableIdentity);}
            if(nav)navigation++;else real++;
            if(REQUIRE_FIXED && ObservationTics>1 && nav && !chilled && !tied)
            {Failures++;Console.Printf("CA282 FAIL navigation-only breath persists id=%d",entry.StableIdentity);}
            if(chilled)cold++;if(tied)ropes++;
            if((ObservationTics==1 || ObservationTics==176) && rows<12)
            {
                rows++;
                Console.Printf("CA357 TARGET id=%d class=%s nav=%d own_goal=%d machine=%d cold=%d ropes=%d x=%.3f y=%.3f z=%.3f anima=%.9f paid=%.9f",entry.StableIdentity,
                    victim==null?'None':victim.GetClassName(),nav,victim==entry.NavigationTarget,entry.CrewMachine!=null,chilled,tied,
                    body.Pos.X,body.Pos.Y,body.Pos.Z,body.CurrentCombatAnima,body.DemonBreath.TotalPaidSeconds);
            }
        }
        Console.Printf("CA357 SAMPLE elapsed=%d tic=%d map=%s living=%d breath=%d nav=%d other=%d cold=%d ropes=%d",ObservationTics,level.time,level.MapName,living,active,navigation,real,cold,ropes);
        if(ObservationTics==176 && living>0)
        {
            int moved=0,released=0;
            for(int i=0;i<Watched.Size();i++)
            {
                let body=Watched[i];if(body==null)continue;
                double distance=(body.Pos-(InitialX[i],InitialY[i],InitialZ[i])).Length();
                if(distance>0)moved++;
                if(body.DemonBreath==null)released++;
                Console.Printf("CA357 RECOVERY id=%d distance=%.6f breath=%d health=%d",Identities[i],distance,body.DemonBreath!=null,body.health);
            }
            Console.Printf("CA357 RECOVERY watched=%d moved=%d released=%d",Watched.Size(),moved,released);
            if(Failures==0)Console.Printf("CA282 DONE passes=1 failures=0");
        }
    }
    override void WorldTick()
    {
        ObservationTics++;
        if(ObservationTics==1 || ObservationTics%35==1)Sample();
    }
}
