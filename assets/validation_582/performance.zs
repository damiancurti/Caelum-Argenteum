// Ventana equivalente sobre ambos runtimes; controles privados sin cambiar el juego.
class CA414Performance : EventHandler
{
    ui Array<double> Intervals;
    ui double PreviousFrame,StartedAt;
    ui int StartedTic;
    ui bool Capturing;
    override void WorldTick()
    {
        if(level.MapName!="MAP01" || level.maptime>200)return;
        for(int i=0;i<MAXPLAYERS;i++){let u=CaelumPlayer(players[i].mo);if(u!=null)u.MainM00UnknownVoiceDelayTics=1000;}
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Capturing)return;double stamp=MSTimeF();
        if(PreviousFrame>0)Intervals.Push(stamp-PreviousFrame);PreviousFrame=stamp;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca414r_camera' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.bInvulnerable=true;u.RecordMainM00UnknownVoiceHeard();u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.SetOrigin((3552,-4,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
        let nearby=BlockThingsIterator.Create(u,128);int operated=0;
        while(nearby.Next())if(nearby.thing.GetClassName()=='CaelumWaterGateSwitch')operated+=nearby.thing.Used(u);
        u.bNoGravity=true;u.SetOrigin((3512,-176,128),false);u.Angle=42;u.Pitch=35;u.Vel=(0,0,0);
        Console.Printf("CA414R PERF gate_operated=%d",operated);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca414r_perf_start'){Intervals.Clear();PreviousFrame=0;StartedAt=MSTimeF();StartedTic=level.time;Capturing=true;}
        if(e.Name=='ca414r_perf_stop')
        {
            Capturing=false;Console.Printf("CA414R PERF start_ms=%.6f end_ms=%.6f tics=%d",StartedAt,MSTimeF(),level.time-StartedTic);
            for(int i=0;i<Intervals.Size();i++)Console.Printf("CA414R FRAME %.6f",Intervals[i]);
            Console.Printf("CA414R RESULT frame samples=%d",Intervals.Size());
        }
    }
}
