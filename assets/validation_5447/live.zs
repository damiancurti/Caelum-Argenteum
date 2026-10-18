// Sonda sin instrumentación de FPS: saves reales y viaje nativo del hub.
class CA361Live : StaticEventHandler
{
    int Passes,Failures;
    override bool InputProcess(InputEvent e){return true;}
    override void WorldLoaded(WorldEvent e)
    {Console.Printf("CA361 LOADED map=%s saved=%d port=%d",level.MapName,e.IsSaveGame,CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents")).FocusPort!=null);}
    void Check(bool ok,String label)
    {if(ok)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca361_check")return;
        let user=CaelumPlayer(players[0].mo);let port=CaelumPortSiege.Get();
        Check(user!=null && user.DerivedStats!=null,"loaded initialized player");
        if(level.MapName=="MAP03")
        {
            Check(port!=null && port.SiegeStarted && !port.Victory,"real saved siege active");
            if(port==null)return;
            Check(user.CurrentAdrenaline==user.DerivedStats.MaximumAdrenaline,"live city player remains at maximum");
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
            Check(CaelumHouseHubData.HouseForMap(level.MapName)>=0,"actual private house reached");
            Check(!CaelumSiegeFocus.ApplyToPlayer(user),"house does not force adrenaline");
            user.CombatTimeRemaining=0;user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;
            CaelumPlayerResources.UpdateAdrenalineDecay(user);
            Check(user.CurrentAdrenaline<user.DerivedStats.MaximumAdrenaline,"normal decay inside house");
            Console.Printf("CA361 LIVE map=%s player=%.4f maximum=%.4f",level.MapName,user.CurrentAdrenaline,user.DerivedStats.MaximumAdrenaline);
        }
        Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);
    }
}
