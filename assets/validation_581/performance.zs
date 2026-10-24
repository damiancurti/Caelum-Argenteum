// Fixture compatible con ambos runtimes; no desactiva sistemas del mapa.
class CA413Performance : EventHandler
{
    Array<CaelumPortDefender> ProbeDefenders;
    ui Array<double> Intervals;
    ui double PreviousFrame,StartedAt;
    ui int StartedTic;
    ui bool Capturing;
    override void RenderOverlay(RenderEvent e)
    {
        if(!Capturing)return;
        double stamp=MSTimeF();
        if(PreviousFrame>0)Intervals.Push(stamp-PreviousFrame);
        PreviousFrame=stamp;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca413_population')
        {
            let population=CaelumPopulationState.Get();
            Console.Printf("CA413 CENSUS living=%d high_density=%d",population!=null?population.LivingCombatants:-1,population!=null && population.HighDensity);
            return;
        }
        if(e.Name!='ca413_camera' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.bInvulnerable=true;
        if(level.MapName=="MAP03"){u.SetOrigin((0,320,0),false);u.Angle=180;}
        u.Pitch=e.Args[0];u.Vel=(0,0,0);
        if(e.Args[1]>0 && level.MapName=="MAP03" && ProbeDefenders.Size()==0)
        {
            let port=CaelumPortSiege.Get();
            for(int i=0;i<e.Args[1];i++)
            {
                vector3 station=CaelumCityData.GuardStation(i);
                let soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",station,NO_REPLACE));
                if(soldier==null)continue;
                soldier.Port=port;soldier.Station=station;soldier.Lane=i%6;ProbeDefenders.Push(soldier);
            }
            Console.Printf("CA413 DIAGNOSTIC peaceful_defenders=%d",ProbeDefenders.Size());
        }
        let population=CaelumPopulationState.Get();
        Console.Printf("CA413 POPULATION living=%d high_density=%d",population!=null?population.LivingCombatants:-1,population!=null && population.HighDensity);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca413_perf_start')
        {Intervals.Clear();PreviousFrame=0;StartedAt=MSTimeF();StartedTic=level.time;Capturing=true;return;}
        if(e.Name=='ca413_perf_stop')
        {
            Capturing=false;
            Console.Printf("CA413 PERF start_ms=%.6f end_ms=%.6f tics=%d",StartedAt,MSTimeF(),level.time-StartedTic);
            for(int i=0;i<Intervals.Size();i++)Console.Printf("CA413 FRAME %.6f",Intervals[i]);
            Console.Printf("CA413 RESULT frame samples=%d",Intervals.Size());
        }
    }
}
