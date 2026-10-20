// Observador privado: resultados acumulados fuera de la ventana medida.
class CA369Performance : EventHandler
{
    int Start,End;
    Array<CaelumBull> Bodies;
    Array<double> Ticks;
    ui Array<double> Frames;
    ui double LastFrame;
    ui bool Flushed;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c369_perf")return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Args[0]>0)for(int i=0;i<512;i++)
        {
            let bull=CaelumBull(Actor.Spawn("CaelumBull",(-1100+(i%32)*72,-500+(i/32)*72,0),ALLOW_REPLACE));
            bull.bDormant=true;bull.SetStateLabel("RestLying");Bodies.Push(bull);
        }
        if(level.MapName=="TBULL"){user.SetOrigin((-1500,-1500,160),false);user.bNoGravity=true;user.Angle=45;user.Pitch=10;}
        Start=level.time+70;End=Start+350;
    }
    override void WorldTick()
    {
        if(Start<=0)return;
        if(level.time==Start)
        {
            let population=CaelumPopulationState.Get();
            Console.Printf("CA369 PERF BEGIN population=%d census=%d high_density=%d",Bodies.Size(),population!=null?population.LivingCombatants:-1,population!=null && population.HighDensity);
            if(Bodies.Size()>0)Console.Printf("CA369 %s shared >=500 census includes peaceful bulls",population!=null && population.LivingCombatants>=Bodies.Size() && population.HighDensity?"PASS":"FAIL");
        }
        if(level.time>=Start && level.time<=End)Ticks.Push(MSTimeF());
        if(level.time==End)
        {
            int alive=0;double exposure=0;
            for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null && Bodies[i].health>0)
            {alive++;if(Bodies[i].ThermalState!=null)exposure+=Bodies[i].ThermalState.Exposure;}
            Console.Printf("CA369 PERF END alive=%d mean_exposure=%.6f",alive,Bodies.Size()>0?exposure/Bodies.Size():0);
            for(int i=0;i<Ticks.Size();i++)Console.Printf("CA369 TICK %.6f",Ticks[i]);
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Start<=0)return;
        double now=MSTimeF();
        if(level.time>=Start && level.time<End)
        {if(LastFrame>0)Frames.Push(now-LastFrame);LastFrame=now;}
        if(level.time>=End && !Flushed)
        {Flushed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA369 FRAME %.6f",Frames[i]);}
    }
}
