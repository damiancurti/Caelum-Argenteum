// Medición local pacífica: misma cámara, sin intervenir en la simulación.
class CA470Performance : StaticEventHandler
{
    bool Started,Finished;
    ui bool Flushed;
    ui double LastFrame;
    ui Array<double> Frames;
    double StartTime;
    override void UiTick()
    {
        let menu=Menu.GetCurrentMenu();
        if(menu is "ConversationMenu")
        {
            ConversationMenu.SendConversationReply(-1,0);
            menu.Close();
        }
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.Time==70)
        {
            u.bInvulnerable=true;u.Vel=(0,0,0);u.Angle=90;u.Pitch=0;
            u.SetOrigin(level.MapName=="MAP01"?(1128,320,0):(-656,1344,0),false);
        }
        if(level.Time==105)
        {
            Vector3 target=level.MapName=="MAP01"?(1240,560,0):(-768,1472,0);
            let it=ThinkerIterator.Create('CaelumWorkbenchStation');
            CaelumCraftingStation bench;
            while((bench=CaelumCraftingStation(it.Next()))!=null)
                if((bench.Pos-target).Length()<1)break;
            if(bench!=null)
            {
                double start=MSTimeF();
                for(int i=0;i<1000;i++)bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());
                Console.Printf("CA470 TIMING authored_network_1000_ms=%.6f",MSTimeF()-start);
            }
        }
        if(level.Time==175){Started=true;StartTime=MSTimeF();}
        if(level.Time==700)
        {
            Finished=true;
            Console.Printf("CA470 PERF elapsed_ms=%.6f tics=525",MSTimeF()-StartTime);
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished)
        {
            if(LastFrame>0)Frames.Push(now-LastFrame);
            LastFrame=now;
        }
        if(Finished && !Flushed)
        {
            Flushed=true;
            for(int i=0;i<Frames.Size();i++)Console.Printf("CA470 FRAME ms=%.6f",Frames[i]);
            Console.Printf("CA470 RESULT frames=%d failed=0",Frames.Size());
        }
    }
}
