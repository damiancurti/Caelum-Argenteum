// Observador privado: resultados acumulados fuera de la ventana medida.
class CA314Performance : EventHandler
{
    int Start,End;
    Array<CaelumBull> Bodies;
    Array<double> Ticks;
    ui Array<double> Frames;
    ui double LastFrame;
    ui bool Flushed;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c314_perf")return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Args[0]>0)for(int i=0;i<CA314Data.POPULATION;i++)
        {
            let bull=CaelumBull(Actor.Spawn("CaelumBull",CA314Data.BodyPosition(i),ALLOW_REPLACE));
            bull.bDormant=true;bull.SetStateLabel("RestLying");Bodies.Push(bull);
        }
        Start=level.time+70;End=Start+350;
    }
    override void WorldTick()
    {
        if(Start<=0)return;
        if(level.time==Start)Console.Printf("CA314 PERF BEGIN population=%d",Bodies.Size());
        if(level.time>=Start && level.time<=End)Ticks.Push(MSTimeF());
        if(level.time==End)
        {
            int alive=0;double exposure=0;
            for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null && Bodies[i].health>0)
            {alive++;if(Bodies[i].ThermalState!=null)exposure+=Bodies[i].ThermalState.Exposure;}
            Console.Printf("CA314 PERF END alive=%d mean_exposure=%.6f",alive,Bodies.Size()>0?exposure/Bodies.Size():0);
            for(int i=0;i<Ticks.Size();i++)Console.Printf("CA314 TICK %.6f",Ticks[i]);
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Start<=0)return;
        double now=MSTimeF();
        if(level.time>=Start && level.time<End)
        {if(LastFrame>0)Frames.Push(now-LastFrame);LastFrame=now;}
        if(level.time>=End && !Flushed)
        {Flushed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA314 FRAME %.6f",Frames[i]);}
    }
}
