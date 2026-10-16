// Demostracion manual: mapa real y cuerpos reales, sin cambiar la campana.
class CA304Author : EventHandler
{
    Array<CaelumMandinga> Bodies;
    int PendingDeaths;
    override void WorldTick()
    {
        if(PendingDeaths>0 && level.time>=PendingDeaths)
        {
            PendingDeaths=0;
            for(int i=0;i<Bodies.Size();i++)
            {Bodies[i].health=0;Bodies[i].Die(null,null,DMG_FORCED,'None');}
        }
        if(level.time!=70)return;
        let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;
        user.SetOrigin((-14464,-15700,0),false);user.Angle=270;
        Console.Printf("CA304 MANUAL: F6 creates 105 dead Mandingas; F7 casts Redemption; F8 counts retained bodies.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(e.Name=="ca304_bodies" && Bodies.Size()==0)
        {
            for(int i=0;i<105;i++)
            {
                let body=CaelumMandinga(Actor.Spawn("CaelumMandinga",(-14954+(i%15)*70,-16050-(i/15)*70,0)));
                if(body==null)continue;
                body.bFriendly=true;body.SetFriendPlayer(user.player);Bodies.Push(body);
            }
            // Esperar la inicializacion nativa de atributos y suministros.
            PendingDeaths=level.time+2;
        }
        if(e.Name=="ca304_raise")CaelumRedemption.Release(user);
        if(e.Name=="ca304_clock" && Bodies.Size()>0)
        {
            for(int i=0;i<2;i++)
            {
            let body=Bodies[i==0?0:104];let thermal=CaelumThermalBody.Get(body,true);
            thermal.RuntimeReady=true;thermal.RuntimeMap=level.MapName;
            thermal.LastRealTic=level.maptime-35*3600;
            thermal.LastWorldStamp=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user,true))-86400;
            let coefficients=CaelumThermalCoefficients.Get(thermal);int before=coefficients.FluxUpdates;
            bool restored=CaelumResurrection.Restore(body,body.Pos);
            bool fresh=!thermal.RuntimeReady;
            CaelumThermalRuntime.NPCStep(body,true);
            bool ok=restored && fresh && body.health>0 && thermal.LastRealTic==level.maptime
                && coefficients.FluxUpdates==before;
            Console.Printf("CA304 %s thermal clock resumes without dead time archived=%d",ok?"PASS":"FAIL",i==0);
            }
        }
        if(e.Name=="ca304_count")
        {
            int alive=0,visible=0,hidden=0;
            for(int i=0;i<Bodies.Size();i++)
            {
                if(Bodies[i]==null)continue;
                if(Bodies[i].health>0)alive++;
                else if(CaelumCorpseArchive.Suspended(Bodies[i]))hidden++;else visible++;
            }
            Console.Printf("CA304 MANUAL alive=%d visible_dead=%d suspended_dead=%d",alive,visible,hidden);
            CaelumNotifications.Notify(user,String.Format("CA304: vivos %d | cuerpos visibles %d | ocultos %d",alive,visible,hidden));
        }
    }
}
