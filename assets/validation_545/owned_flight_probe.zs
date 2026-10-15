// #251: segunda fuente de laboratorio; no representa la nube implementada.
class CA251OwnedFlightStub : PowerFlight
{
    override void EndEffect()
    {
        Actor owner=Owner;
        bool wasFlying=owner!=null && owner.bFly;
        bool hadNoGravity=owner!=null && owner.bNoGravity;
        bool wasCentering=owner!=null && owner.player!=null && owner.player.centering;
        Super.EndEffect();
        CaelumFlightOwnership.AfterEnd(owner,self,wasFlying,hadNoGravity,wasCentering);
    }
}

class CA251OwnedFlightProbe : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA251 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick()
    {if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c251_owned_flight")return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();user.bInvulnerable=true;
        user.SetOrigin((0,0,128),false);user.Vel=(0,0,0);
        let record=user.GetPersistentCharacterState(true);
        record.TarotActive[CaelumConstants.TAROT_THE_FOOL]=true;
        record.TarotEffectTics=30*TICRATE;
        for(int order=0;order<2;order++)
        {
            let tarot=PowerFlight(user.GiveInventoryType("CaelumTarotFlight"));
            let stub=PowerFlight(user.GiveInventoryType("CA251OwnedFlightStub"));
            Check(tarot!=null && stub!=null && user.bFly && user.bNoGravity,
                "real Tarot and secondary flight coexist");
            PowerFlight ending=order==0?tarot:stub;
            PowerFlight survivor=order==0?stub:tarot;
            int before=survivor.EffectTics;double reserve=user.CurrentAnima;
            user.Vel=(1,2,-3);user.player.centering=false;
            ending.Destroy();
            Check(survivor.Owner==user && user.bFly && user.bNoGravity,
                "ending either source preserves the surviving flight");
            Check(survivor.EffectTics==before && user.CurrentAnima==reserve
                && user.Vel==(1,2,-3) && !user.player.centering,
                "restoration preserves time Anima velocity and view centering");
            survivor.Destroy();
            Check(!user.bFly && !user.bNoGravity,
                "ending the last source restores ordinary falling");
        }
        let tarot=PowerFlight(user.GiveInventoryType("CaelumTarotFlight"));
        let stub=PowerFlight(user.GiveInventoryType("CA251OwnedFlightStub"));
        user.bNoGravity=false;
        tarot.Destroy();
        Check(user.bFly && !user.bNoGravity,"landed native flight permission remains landed");
        stub.Destroy();
        tarot=PowerFlight(user.GiveInventoryType("CaelumTarotFlight"));
        user.bFlyCheat=true;tarot.Destroy();
        Check(user.bFly && user.bNoGravity,"native fly cheat survives last-source removal");
        user.bFlyCheat=false;user.bFly=false;user.bNoGravity=false;
        record.TarotActive[CaelumConstants.TAROT_THE_FOOL]=false;record.TarotEffectTics=0;
        Console.Printf("CA251 DONE failures=%d passes=%d OWNED_FLIGHT_COMPONENT",Failed,Passed);
    }
}
