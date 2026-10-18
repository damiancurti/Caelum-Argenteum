// Sonda sin instrumentación de FPS: saves reales y viaje nativo del hub.
class CA361Live : StaticEventHandler
{
    int Passes,Failures,CompletedChecks;
    bool SeenCity,SeenHouse;
    override bool InputProcess(InputEvent e){return true;}
    override void WorldLoaded(WorldEvent e)
    {Console.Printf("CA361 LOADED map=%s saved=%d",level.MapName,e.IsSaveGame);}
    override void WorldTick()
    {
        // Mantener vivo al observador de guardados; el daño real se verifica en checks.zs.
        let user=CaelumPlayer(players[0].mo);if(user!=null)user.bInvulnerable=true;
    }
    void Check(bool ok,String label)
    {if(ok)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca361_finish")
        {
            Check(CompletedChecks>=e.Args[0],"all requested checkpoints executed");
            if(e.Args[1]!=0)Check(SeenCity && SeenHouse && level.MapName=="MAP03","both hub legs finished in city");
            Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);return;
        }
        if(e.Name!="ca361_check")return;
        CompletedChecks++;
        let user=CaelumPlayer(players[0].mo);let port=CaelumPortSiege.Get();
        Check(user!=null && user.DerivedStats!=null,"loaded initialized player");
        Check(user.health>0 && user.player.playerstate==PST_LIVE,"save observer remains alive");
        user.CurrentAdrenaline=0;user.UpdateHealthStateEffects();user.UpdateSurvivalStates();
        Check(user.CurrentAdrenaline==0,"loaded player not refilled by active siege or hub");
        user.CombatTimeRemaining=0;user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline/2;
        double reserve=user.CurrentAdrenaline;CaelumPlayerResources.UpdateAdrenalineDecay(user);
        Check(user.CurrentAdrenaline<reserve,"ordinary loaded player decay in city or house");
        if(level.MapName=="MAP03")
        {
            SeenCity=true;
            Check(port!=null && port.SiegeStarted && !port.Victory,"real saved siege active");
            if(port==null)return;
            int attackers,defenders;
            for(int i=0;i<port.Attackers.Size();i++)
            {
                let entry=port.Attackers[i];let body=entry.Body;
                if(body==null || body.health<=0 || entry.Exited)continue;
                attackers++;
                Check(body.CurrentCombatAdrenaline==body.MaximumCombatAdrenaline,"live saved attacker maximum");
            }
            for(int i=0;i<port.Defenders.Size();i++)
            {
                let body=port.Defenders[i];if(body==null || body.health<=0 || body.Port!=port)continue;
                defenders++;
                Check(body.CurrentCombatAdrenaline==body.MaximumCombatAdrenaline,"live saved defender maximum");
            }
            Check(attackers>0 && defenders>0,"both real saved armies represented");
            Console.Printf("CA361 LIVE map=%s attackers=%d defenders=%d player=%.4f maximum=%.4f",level.MapName,attackers,defenders,user.CurrentAdrenaline,user.DerivedStats.MaximumAdrenaline);
        }
        else
        {
            SeenHouse=true;
            Check(CaelumHouseHubData.HouseForMap(level.MapName)>=0,"actual private house reached");
            user.CombatTimeRemaining=0;user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;
            CaelumPlayerResources.UpdateAdrenalineDecay(user);
            Check(user.CurrentAdrenaline<user.DerivedStats.MaximumAdrenaline,"normal decay inside house");
            Console.Printf("CA361 LIVE map=%s player=%.4f maximum=%.4f",level.MapName,user.CurrentAdrenaline,user.DerivedStats.MaximumAdrenaline);
        }
        Console.Printf("CA361 OBSERVER hp=%d state=%d",user.health,user.player.playerstate);
        Console.Printf("CA361 PROGRESS checkpoints=%d passes=%d failures=%d",CompletedChecks,Passes,Failures);
    }
}
